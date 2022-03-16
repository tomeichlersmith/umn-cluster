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
std::ifstream::pos_type filesize(const std::string& filename) {
  std::ifstream in(filename, std::ifstream::ate | std::ifstream::binary);
  return in.tellg();
}

/**
 * get the filesystem the input file is hosted on
 */
std::string filesystem(const std::string& filename) {
  if (filename.find("hdfs") != std::string::npos) {
    return "hdfs";
  } else {
    return "zfs";
  }
}

/**
 * Do a system cp, return true if successful
 */
bool cp(const std::string& src, const std::string& dest) {
  std::string destdir = dest.substr(0,dest.find_last_of("/"));
  std::string cmd{"mkdir -p "+destdir+" && cp "+src+" "+dest+" && sync"};
  return (system(cmd.c_str()) == 0);
}

/**
 * copy a file to scratch, return the new filepath to read from
 *
 * return empty string if failed to copy
 */
std::string cp_to_scratch(const std::string& filename) {
  std::string destname = filename.substr(filename.find_last_of("/")+1);
  destname = "/export/scratch/users/eichl008/"+destname;
  if (cp(filename, destname)) { 
    // successful copy
    return destname;
  } else {
    return "";
  }
}

/**
 * pretend analysis of the tree name 'tree_name' in the file 'input_file'.
 *
 * cp_to_scratch - copies file to /export/scratch/users/eichl008 before reading and then
 *  deletes the scratch file after processing. Copying and deleting included in timing
 *
 * max_branches - maximum number of branches to be processed
 *  if negative, process all branches
 *
 * actually_process - actually loop through events
 *
 * Run like:
 * 
 *    root -l -q '/full/path/to/analysim.C("/full/path/to/input_file.root","tree/name",true,-1)'
 *
 * Prints out a CSV row formatted as
 *  file size in bytes, time analysis took in s, cp_to_scratch, filesystem input_file was on, max_branches
 * to the terminal. This can be captured by condor's 'output' command and then concatenated into
 * one CSV file with all the jobs for later analysis.
 */
void analysim(std::string input_file, const char* tree_name, bool do_cp_to_scratch, int max_branches, bool actually_process) {
  auto begin = std::chrono::steady_clock::now();
  TFile* f;
  if (do_cp_to_scratch) {
    // perform system copy
    auto file = cp_to_scratch(input_file);
    if (file.empty()) {
      std::cerr << "Unable to cp " << input_file << " to scratch" << std::endl;
      return;
    }
    f = TFile::Open(file.c_str());
    if (f == 0) {
      std::cerr << "Unable to open " << file << std::endl;
      return;
    }
  } else {
    f = TFile::Open(input_file.c_str());
    if (f == 0) {
      std::cerr << "Unable to open " << input_file << std::endl;
      return;
    }
  }
  if (actually_process) {
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
  }
  if (do_cp_to_scratch) {
    // perform system delete
    if (remove(f->GetName()) != 0) {
      std::cerr << "Could not delete " << f->GetName() << std::endl;
      return;
    }
  }
  auto end = std::chrono::steady_clock::now();
  std::chrono::duration<double> time = end - begin;

  char hostname[HOST_NAME_MAX];
  gethostname(hostname, HOST_NAME_MAX);

  std::cout << std::boolalpha
    << filesize(input_file) << ","
    << time.count() << ","
    << do_cp_to_scratch << ","
    << filesystem(input_file) << ","
    << max_branches << ","
    << actually_process << ","
    << hostname << ","
    << input_file.substr(input_file.find_last_of("/")+1)
    << std::endl;
}
