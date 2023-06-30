#include "/data/cmszfs1/user/wadud/aNTGCmet/aNTGC_analysis/Systematics/systematicsAnalyzer.cc"

/**
 * Run like:
 *    root -b -l -q '/full/path/to/macro.C("input_file","output_file",xsec,"pu_file")'
 */
void anamacro(std::string input_file, std::string output_file, 
                         double xsec, std::string pu_file){
	std::cout<<getCurrentTime()<<std::endl;
	std::cout<<"Begin root macro..."<<std::endl;
	
	systematicsAnalyzer(input_file, output_file, xsec, pu_file);

	std::cout<<"End root macro!"<<std::endl;
	std::cout<<getCurrentTime()<<std::endl;
};
