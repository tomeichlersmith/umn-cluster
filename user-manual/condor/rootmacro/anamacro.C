#include "/local/cms/user/gsorrent/antgc_analysis/hltSF/UL17/hltScaleFactorNtuples.cc"

/**
 * Run like:
 *    root -b -l -q '/full/path/to/macro.C("input_file","output_file",xsec,"mcpu")'
 */
void anamacro(std::string input_file, std::string output_file, 
                         double xsec, std::string mcpu){
	std::cout<<getCurrentTime()<<std::endl;
	std::cout<<"Begin root macro..."<<std::endl;
	
	hltScaleFactorNtuples(input_file, output_file, xsec, mcpu, 
      "/local/cms/user/wadud/aNTGCmet/aNTGC_analysis/data/pileupUL17/pileup_2017_data.root");

	std::cout<<"End root macro!"<<std::endl;
	std::cout<<getCurrentTime()<<std::endl;
};
