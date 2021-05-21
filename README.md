# Automated benchmarking of a set of VCF files with a gold standard file using Truvari tool

## About
This tool would use the **Truvari** comparison tool for comparing the generated VCF files with the gold standard file. This can be used to automate the process of comparing several vcf files with the gold standard file, and specifically used for the structural variants. It can be used either in an interactive way or by using  the command line interface by providing the parameters as options. The interactive method would aid a novice user to make the comparisons without much technical knowledge of the software requirements and other usages. However, for the integration of this tool into any existing bioinformatics pipleline, the command line interface needs to be used. This interface is for users having basic knowledge of linux commands and for those who know how to run such interfaces.

## Prerequisites

1. Linux clusters having **slurm workload manager**. 
2. Availability of **git** program. It can be checked using `which git`. This is required for cloning the guthub repository.

## Installation
Following are the steps of installation:
1. Execute the command `git clone https://github.com/itsroops/vcf_comp_with_gold_standard_sv`
2. Navigate to the directory by running `cd vcf_comp_with_gold_standard_sv`
3. Run the script by executing `sh start_install.sh`

*In case of installation failure: If you have to restart the installation process, please delete the **temp** folder that has been created by `rm -rf temp` and then begin fresh installation.*

## Running the tool
The tool can either be run in the interactive mode or in the command line by passing the required arguments.
Mandatory files required are:
1. The set of VCF files stored in a single folder and all ending with .vcf extension. If the vcf files are in a compressed
 form, please decompress the files and keep it in .vcf extension only.  
2. A genome reference fasta file ending with .fasta extension
3. A gold standard file ending with .vcf extension


### Interactive mode
Run the tool by executing the command `sh main.sh`

### Command line mode
The tool is run by the following command:
`sh main.sh [option 1] [argument 1] [option 2] [argument 2]....[option n] [argument n]`

The compulsory options are the *gold standard file*, *genome reference fasta file* and the *output folder name*. Both long as well as the short options or a combination of both can be used. 

A sample command line run would look like the following:
`sh main.sh --vcf <path of vcf files> --ref <absolute pathname of genome reference fasta file> --gold <absolute pathname of the gold standard file> --out_name <output folder name> --out <output path> --acc <account name> --par <partition name>`

Other slurm options can also be used in conjunction. Please refer to the detailed documentation by using the command `sh main.sh -h` to see all the options that can be used.


## Outputs
The outputs from the tool can be categorized into three forms, namely, *log files* and *plot files* and *other result files*.

1. There are two types of *log files* which are generated in the $installation_path/vcf_comp_with_gold_standard folder.
       
   * *mainlog.txt*: This file is generated during the actual execution of the tool and it records all the steps in details.
   * *slurm-jobid.out*: There are several of these files which log the events of the slurm jobs which have been submitted to the scheduler. 

2. The *parameters.txt* file is also generated which cotains the list of parameters which have been passed by the user for running the program. This is also found in the $installation_path/vcf_comp_with_gold_standard folder.
  
3.  A *summary file* containing the metrices is generated in the *xlsx* format. Also, there are *plot files* which are generated that include the combined bar plots comparing the values for different metrices like recall, precision and  f1 scores for all the vcf files. They are generated in the *pdf* format. These are generated in the output path which is specified by the user.

4.  The *other result files* contain outputs from the *hap.py* tool run. These are also generated in the output path which is specified by the user.

## References
1. For the **Truvari** tool: https://github.com/spiralgenetics/truvari

2. For installing **git**: https://git-scm.com/book/en/v2/Getting-Started-Installing-Git

3. For **Slurm Workload Manager**: https://slurm.schedmd.com/quickstart.html

## Acknowledgements

This work is guided by Dr. Susanne Motameny and supported by Cologne Center for Genomics (CCG), Germany

## Contact
For any queries/issues, please mail to *avirupgn@gmail.com*

