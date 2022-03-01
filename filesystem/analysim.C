/**
 * loop through a ROOT file
 */
#include <chrono>
#include <fstream>
#include <string>

#include "TFile.h"
#include "TTree.h"

/**
 * get the filesize in bytes of the input file
 */
std::ifstream::pos_type filesize(const char* filename) {
  std::ifstream in(filename, std::ifstream::ate | std::ifstream::binary);
  return in.tellg();
}

/**
 * get the filesystem the input file is hosted on
 */
std::string filesystem(std::string filename) {
  if (filename.find("hdfs") != std::string::npos) {
    return "hdfs";
  } else {
    return "zfs";
  }
}

/**
 * copy a file to scratch, return the new filepath to read from
 *
 * return empty string if failed to copy
 */
std::string cp_to_scratch(std::string filename) {
  std::ifstream src(filename, std::ios::binary);
  std::string destname = filename.substr(filename.find_last_of("/")+1);
  destname = "/export/scratch/users/eichl008/"+destname;
  std::ofstream dest(destname, std::ios::binary);
  dest << src.rdbuf();
  if (src and dest) {
    // successful copy
    return destname;
  } else {
    return "";
  }
}

/**
 * pretend analysis of the tree name 'tree_name' in the file 'input_file'.
 *
 * cp_to_local - copies file to /export/scratch/users/eichl008 before reading and then
 *  deletes the scratch file after processing. Copying and deleting included in timing
 *
 * max_branches - maximum number of branches to be processed
 *  if negative, process all branches
 *
 * Run like:
 * 
 *    root -lq '/full/path/to/analysim.C("/full/path/to/input_file.root","tree/name",true,-1)'
 *
 * Prints out a CSV row formatted as
 *  file size in bytes, time analysis took in s, cp_to_local, filesystem input_file was on, max_branches
 * to the terminal. This can be captured by condor's 'output' command and then concatenated into
 * one CSV file with all the jobs for later analysis.
 */
void analysim(const char* input_file, const char* tree_name, bool cp_to_local, int max_branches) {
  auto begin = std::chrono::steady_clock::now();
  TFile* f;
  if (cp_to_local) {
    // perform system copy
    auto file = cp_to_scratch(input_file);
    if (file.empty()) {
      std::cerr << "Unable to cp " << input_file << " to scratch" << std::endl;
      return;
    }
    f = TFile::Open(file.c_str());
    if (f == 0) {
      std::cerr << "Unable to open " << file << std::endl;
    }
  } else {
    f = TFile::Open(input_file);
    if (f == 0) {
      std::cerr << "Unable to open " << input_file << std::endl;
    }
  }
  auto t = (TTree*)f->Get(tree_name);
  long long int size = t->GetEntriesFast();
  if (max_branches < 0) {
    // activate all branches
    t->SetBranchStatus("*",1);
  } else {
    // loop through branches activating them until max_branches is reached
    t->SetBranchStatus("*",0);
    TObjArray* l = t->GetListOfBranches();
    for (std::size_t i{0}; i < l->GetEntriesFast(); i++) {
      if (i >= max_branches)
        break;

      TBranch* b = (TBranch*)l->At(i);
      b->SetStatus(1);
    }
  }
  for (long long int i{0}; i < size; i++) {
    t->GetEntry(i);
  }
  if (cp_to_local) {
    // perform system delete
    if (remove(f->GetName()) != 0) {
      std::cerr << "Could not delete " << f->GetName() << std::endl;
      return;
    }
  }
  auto end = std::chrono::steady_clock::now();
  std::chrono::duration<double> time = end - begin;

  std::cout
    << filesize(input_file) << "," // size
    << time.count() << "," // time
    << std::boolalpha << cp_to_local << "," // local
    << filesystem(input_file) << "," // filesystem
    << max_branches
    << std::endl;
}
