#!/bin/sh

if [[ $# -eq 0 ]] ; then

# Running the program in interactive mode

# Writing the log file
echo -e "\nProgram Started......" `date` > mainlog.txt

# Writing the program description for users's convenience
clear
echo "************************************************************************************************************"
echo -e "\n                       VCF files Comparison tool with gold standard for Structural Variants           \n"
echo -e "                                            Author: Avirup Guha Neogi                                  "
echo -e "************************************************************************************************************"
echo -e "\nThis is an interactive tool which will guide you to perform VCF comparisons"
echo -e "\n*Please keep all the VCF files (to be compared with the gold standard file) into a folder"
echo -e "\n*The extension of the VCF files including the gold standard must end with '.vcf'. If you use any compressor please decompress and place the normal '.vcf' files"
echo -e "\n*Other required file is genome reference fasta file"
echo -e "\n*At any point of entering input, if you want to keep the default value, then press ENTER"
echo -e "\n"
read -p "Press ENTER to continue or CTRL+c to abort...."

start_time=$(date +"%s")

# Storing the current path
curr_path=`pwd`

# Setting the truvari path
truvari_path=$curr_path/temp/truvari/bin

# Setting the bin path
bin_path=$curr_path/temp/miniconda3/bin

# Reading the full path of the vcf files
echo -e "\nPlease enter the folder path of the VCF files which need to be compared. Default:current directory"
read vcf_folder
vcf_folder=${vcf_folder:-$curr_path} 

# Checking the validity of the argument
if [[ $vcf_folder != /* ]] ; then
   echo -e "\nInvalid argument for the vcf files path\n"
   echo -e "\nInvalid argument for the vcf files path......" `date` >> mainlog.txt
   echo -e "\nExiting the program......" `date` >> mainlog.txt
   exit 1

elif [[ ! -d $vcf_folder ]] ; then
     echo -e "\nThe vcf folder path does not exist\n"
     echo -e "\nThe vcf folder path does not exist......" `date` >> mainlog.txt
     echo -e "\nExiting the program......" `date` >> mainlog.txt
     exit 1

else
    echo -e "\nFolder of the VCF files read......" `date` >> mainlog.txt

fi

# Reading the full path of the gold standard files 
echo -e "\nPlease enter the filename along with the full path for the gold standard file"
read vcf_gold

# Checking whether the argument is null or not
if [[ -z $vcf_gold ]] ; then
   echo -e "\nNull argument for the gold standard file\n"
   echo -e "\nNull argument for the gold standard file......" `date` >> mainlog.txt
   echo -e "\nExiting the program......" `date` >> mainlog.txt
   exit 1


# Checking the validity of the argument
elif [[ $vcf_gold != /*.vcf ]] ; then
   echo -e "\nInvalid argument for the gold standard file\n"
   echo -e "\nInvalid argument for the gold standard file......" `date` >> mainlog.txt
   echo -e "\nExiting the program......" `date` >> mainlog.txt
   exit 1

# Checking the existence of the gold standard file path
elif [[	! -f $vcf_gold ]] ; then
     echo -e "\nThe gold standard file does not exist\n"
     echo -e "\nThe gold standard file does not exist......" `date` >> mainlog.txt
     echo -e "\nExiting the program......" `date` >> mainlog.txt
     exit 1

else
    echo -e "\nPath of the gold standard file read......" `date` >> mainlog.txt

fi

# Reading the full path of the genome reference fasta file
echo -e "\nPlease enter the filename along with the full path for the genome reference fasta file"
read ref

# Checking if the argument is null
if [[ -z $ref ]] ; then
   echo -e "\nNull argument for the genome reference fasta file\n"
   echo -e "\nNull argument for the genome reference fasta file......" `date` >> mainlog.txt
   echo -e "\nExiting the program......" `date` >> mainlog.txt
   exit 1


# Checking the validity of the argument
elif [[ $ref != /*.fasta ]] ; then
   echo -e "\nInvalid argument for the genome reference fasta file\n"
   echo -e "\nInvalid argument for the genome reference fasta file......" `date` >> mainlog.txt
   echo -e "\nExiting the program......" `date` >> mainlog.txt
   exit 1

# Checking the existence of the genome reference fasta file   
elif [[ ! -f $ref ]] ; then
     echo -e "\nThe genome reference fasta file does not exist\n"
     echo -e "\nThe genome reference fasta file does not exist......" `date` >> mainlog.txt
     echo -e "\nExiting the program......" `date` >> mainlog.txt
     exit 1

else
echo -e "\nPath of the genome reference fasta file read......" `date` >> mainlog.txt

fi

# Reading the output folder name
echo -e "\nPlease enter the output folder name"
read out_name

# Reading the output folder path
echo -e "\nPlease enter the path where the output folder should be placed. Default: Current directory"
read out
out=${out:-$curr_path}

# Checking the validity of the argument
if [[ $out != /* ]] ; then
   echo -e "\nInvalid argument for the output folder path\n"
   echo -e "\nInvalid argument for the output folder path......" `date` >> mainlog.txt
   echo -e "\nExiting the program......" `date` >> mainlog.txt
   exit 1

# Checking the existence of the output folder path
elif [[ ! -d $out ]] ; then
     echo -e "\nThe output folder path does not exist\n"
     echo -e "\nThe output folder path does not exist......" `date` >> mainlog.txt
     echo -e "\nExiting the program......" `date` >> mainlog.txt
     exit 1

# Checking the existence of the output folder path
elif [[ -d $out/$out_name ]] ; then
     echo -e "\nThe output folder already exists\n"
     echo -e "\nThe output folder already exists......" `date` >> mainlog.txt
     echo -e "\nExiting the program......" `date` >> mainlog.txt
     exit 1

# Creating the new output folder
else
    mkdir $out/$out_name
    echo -e "\nPath of the output folder read and a new folder named "$out_name" created......" `date` >> mainlog.txt

fi

# Checking if the gold standard file contains 'chr' in its chromosome numbers
x=`tail -n 1 $vcf_gold | cut -f1 | grep chr`

if [[ ! -z $x ]] ; then
   ch=Y
else
   ch=N
fi


if [[ $ch == Y ]] ; then
   echo -e "\nThe gold standard file contains 'chr' in their chromosome numbers. This would be removed in order to make it compatible for comparison"
   echo -e "\nDo you want to keep the original file and make a new file or replace the original file?"
   echo -e "\nPlease enter (Y/y) if you want to replace the original file. Default value is N"
   read ch2
   ch2=${ch2:-N}

   # Removing the "chr" from the chromosome numbers present in the gold standard file in order to make it compatible for comparison
   echo -e "\nPlease wait......"
   f_name=$($curr_path/temp/miniconda3/bin/python3 remove_chr.py $vcf_gold $ch2 2>&1)
   echo -e "\nchr removed from the chromosome numbers......" `date` >> mainlog.txt
   vcf_gold=$f_name

fi

clear

echo -e "\nAccepting slurm scheduling options from the user"
sleep 1

# Reading the cpu(s) per task
echo -e "\nPlease enter the cpus-per-task. Default:1. Press ENTER to keep default"
read cpt
cpt=${cpt:-1}

# Checking the validity of the argument
if [[ $cpt != [1-9]* || $cpt == *[aA-zZ]* ]] ; then
   echo -e "\nInvalid argument for number of cpu(s) per task\n"
   echo -e "\nInvalid argument for number of cpu(s) per task......" `date` >> mainlog.txt
   echo -e "\nExiting the program......" `date` >> mainlog.txt
   exit 1

else
   echo -e "\nNumber of CPU(s)-per-task read......" `date` >> mainlog.txt

fi

# Reading the memory required per node
echo -e "\nPlease enter the memory required per node.Default units are in MB"
echo -e "\nDifferent units can be specified using the suffix [K|M|G|T]. Default value set is 15G"
read mem
mem=${mem:-15G}

# Checking the validity of the argument
if [[ $mem != [0-9]* ]] ; then
   echo -e "\nInvalid argument for the size of the memory required per node\n"
   echo -e "\nInvalid argument for the size of the memory required per node......" `date` >> mainlog.txt
   echo -e "\nExiting the program......" `date` >> mainlog.txt
   exit 1

else
   echo -e "\nMemory required per node read......" `date` >> mainlog.txt

fi

# Setting a time limit on the total runtime of the job allocation
echo -e "\nPlease enter the total time allocation for the job"
echo -e "\nAcceptable time formats include 'minutes', 'minutes:seconds', 'hours:minutes:seconds', 'days-hours', 'days-hours:minutes' and 'days-hours:minutes:seconds"
echo -e "\nDefault time limit set is 48:00:00"
read tot_time
tot_time=${tot_time:-48:00:00}

# Checking the validity of the input
if [[ $tot_time != [0-9]* ]] ; then
   echo -e "\nInvalid argument for total time of the slurm execution\n"
   echo -e "\nInvalid argument for total time of the slurm execution......" `date` >> mainlog.txt
   echo -e "\nExiting the program......" `date` >> mainlog.txt
   exit 1

else
   echo -e "\nTotal time allocation for the job read......" `date` >> mainlog.txt

fi 

# Reading the account name for the job
echo -e "\nPlease enter the account name. Default: Default account name set by the cluster manager for your account."
read acc
echo -e "\nAccount name read......" `date` >> mainlog.txt

# Reading the partition name
echo -e "\nPlease enter the partition name. Default: Default partition name set by the cluster mannager."
read par
echo -e "\nPartition name read......" `date` >> mainlog.txt

# Reading the mail type to notify users
echo -e "\nPlease enter mail type to notify users when certain event occurs. Default is ALL"
read mail_type
mail_type=${mail_type:-ALL}    
echo -e "\nMail type read......" `date` >> mainlog.txt

# Reading the user mail id to notify users
echo -e "\nPlease enter the email address to get notified. Default: The email address of your account set by the cluster manager."
read mail_id

# Checking the validity of the argument
if [[ ! -z $mail_id && $mail_id != *@*.* ]] ; then
   echo -e "\nInvalid Email Address\n"
   echo -e "\nInvalid Email Address......" `date` >> mainlog.txt
   echo -e "\nExiting the program......" `date` >> mainlog.txt
   exit 1

else
   echo -e "\nEmail address read......" `date` >> mainlog.txt

fi

echo -e "\n" >> mainlog.txt

else

# Running the program in comman-line mode

echo -e "\nProgram Started......" `date` > mainlog.txt

# Defining th version function
function version() {
echo "************************************************************************************************************"
echo -e "\n                      VCF files Comparison tool with gold standard for structural variants          \n"
echo -e "                                           Author: Avirup Guha Neogi                                  "
echo -e "                                                 VERSION: 1.0                                        "
echo -e "************************************************************************************************************"
}

# Defining the help function
function help() {
clear
echo -e "This is a tool to perform VCF comparisons"
echo -e "Please keep all the VCF files (to be compared with the gold standard file) into a folder"
echo -e "The extension of the VCF must end with '.vcf'. If you use any compressor please decompress and place the normal '.vcf' files"
echo -e "Other required file is genome fasta reference file"
echo -e "\nYou can either use long or short options or a combination of both"
echo -e "Format for using it is as follows:"
echo -e "\n\033[1msh main.sh [option 1] [argument 1] [option 2] [argument 2]....[option n] [argument n]\033[0m"
echo -e "\nThe compulsory options are the gold standard file, the genome reference fasta files and the output folder name."
echo -e "\nFollowing are the options for running in command line"
echo -e "\n\033[1m--help\033[0m | \033[1m-help\033[0m | \033[1m-h\033[0m: Help"
echo -e "\033[1m--version\033[0m | \033[1m-version\033[0m | \033[1m-v\033[0m: Version" 
echo -e "\033[1m--vcf\033[0m | \033[1m-f\033[0m: The folder path of the VCF files which need to be compared. Default:current directory"
echo -e "\033[1m--gold\033[0m | \033[1m-g\033[0m: The filename along with the full path for the gold standard file"
echo -e "\033[1m--ref\033[0m | \033[1m-r\033[0m: The filename along with the full path for the genome reference fasta file"
echo -e "\033[1m--out_name\033[0m | \033[1m-c\033[0m: The output folder name"
echo -e "\033[1m--out\033[0m | \033[1m-o\033[0m: The output folder path. Default:current directory. Please note: option --out must be entered before output folder path"
echo -e "\n\033[1m--rem_chr_newfile\033[0m | \033[1m-k\033[0m: The option indicates whether one would like to replace the original gold standard file with the file after removing the characters 'chr' or whether one would like to create a new file with the removed characters. Acceptable values are Y|y|other. Default value: N. Any other value is automatically treated as N"
echo -e "\n\033[1m--cpt\033[0m | \033[1m-n\033[0m: The number of CPUs-per-task"
echo -e "\n\033[1m--mem\033[0m | \033[1m-s\033[0m: The memory required per node.Default units are in MB. Different units can be specified using the suffix [K|M|G|T]. Default value set is 15G"
echo -e "\n\033[1m--tot_time\033[0m | \033[1m\033[1m-t\033[0m: The total time allocation for the job. Acceptable time formats include 'minutes', 'minutes:seconds', 'hours:minutes:seconds', 'days-hours', 'days-hours:minutes' and 'days-hours:minutes:seconds'. Default time limit set is 48:00:00"
echo -e "\n\033[1m--acc\033[0m | \033[1m-a\033[0m: The account name"
echo -e "\033[1m--par\033[0m | \033[1m-p\033[0m: The partition name"
echo -e "\033[1m--mail_type\033[0m | \033[1m-m\033[0m: The mail type to notify users when certain event occurs. Default is ALL"
echo -e "\033[1m--mail_id\033[0m | \033[1m-e\033[0m: The user email address to get notified"
}

# Recording the start time of the process
start_time=$(date +"%s")

# Storing the current path
curr_path=`pwd`

# Setting the truvari path
truvari_path=$curr_path/temp/miniconda3/bin

# Setting the default value of the vcf folder
vcf_folder=$curr_path

# Setting the default value of the output folder
out=$curr_path

# Setting the default number of CPUs-per-task
cpt=1

# Setting the default memory required per node
mem=15G

# Setting the default total time allocation for the job
tot_time=48:00:00

# Setting the deafult mail type to notify users when certain event occurs
mail_type=ALL

# Accepting the long options from the  user and converting it to short form
for arg in "$@"; do
 shift
  case "$arg" in
   "--help") set -- "$@" "-h" ;;
   "--version") set -- "$@" "-v" ;;
   "--vcf") set -- "$@" "-f" ;;
   "--gold") set -- "$@" "-g" ;;
   "--ref") set -- "$@" "-r" ;;
   "--rem_chr_newfile") set -- "$@" "-k" ;;
   "--out_name") set -- "$@" "-c" ;;
   "--out") set -- "$@" "-o" ;;
   "--cpt") set -- "$@" "-n" ;;
   "--mem") set -- "$@" "-s" ;;
   "--par") set -- "$@" "-p" ;;
   "--acc") set -- "$@" "-a" ;;
   "--tot_time")  set -- "$@" "-t" ;;
   "--mail_type") set -- "$@" "-m" ;;
   "--mail_id")   set -- "$@" "-e" ;;
    *) set -- "$@" "$arg" ;;

  esac
done


OPTIND=1

# Executing the short options that have been accepted from the user
while getopts "f:g:r:o:c:k:n:s:p:t:m:a:e:hv" opt; do
  case $opt in
  
    f)
      vcf_folder=$OPTARG 

      # Checking the validity of the argument
      if [[ $vcf_folder != /* ]] ; then
         echo -e "\nInvalid argument for the vcf files path\n"
         echo -e "\nInvalid argument for the vcf files path......" `date` >> mainlog.txt
         echo -e "\nExiting the program......" `date` >> mainlog.txt
         exit 1

      elif [[ ! -d $vcf_folder ]] ; then
           echo -e "\nThe vcf folder path does not exist\n"
           echo -e "\nThe vcf folder path does not exist......" `date` >> mainlog.txt
           echo -e "\nExiting the program......" `date` >> mainlog.txt
           exit 1

      fi
      ;;
  
    g)
      vcf_gold=$OPTARG

      # Checking the validity of the argument
      if [[ $vcf_gold != /*.vcf ]] ; then
         echo -e "\nInvalid argument for the gold standard file\n"
         echo -e "\nInvalid argument for the gold standard file......" `date` >> mainlog.txt
         echo -e "\nExiting the program......" `date` >> mainlog.txt
         exit 1
      
      elif [[ ! -f $vcf_gold ]] ; then
           echo -e "\nThe gold standard file does not exist\n"
           echo -e "\nThe gold standard file does not exist......" `date` >> mainlog.txt
           echo -e "\nExiting the program......" `date` >> mainlog.txt
           exit 1
      
      fi

      # Checking if the gold standard file contains 'chr' in its chromosome numbers
      x=`tail -n 1 $vcf_gold | cut -f1 | grep chr`

      if [[ ! -z $x ]] ; then
        ch=Y
      else
        ch=N
      fi
      ;;

    r)
      ref=$OPTARG
    
      #	Checking the validity of the argument
      if [[ $ref != /*.fasta ]] ; then
         echo -e "\nInvalid argument for the genome reference fasta file\n"
         echo -e "\nInvalid argument for the genome reference fasta file......" `date` >> mainlog.txt
         echo -e "\nExiting the program......" `date` >> mainlog.txt
         exit 1
      
      elif [[ ! -f $ref ]] ; then
           echo -e "\nThe genome reference fasta file does not exist\n"
           echo -e "\nThe genome reference fasta file does not exist......" `date` >> mainlog.txt
           echo -e "\nExiting the program......" `date` >> mainlog.txt
           exit 1

      fi
      ;;

    c) 
      out_name=$OPTARG
      ;;

     o)
      out=$OPTARG
      if [[ -z $out_name ]]; then
         echo -e "\nThe output folder name option --out_name must be given before the output folder path\n"
         echo -e "\nThe output folder name option --out_name must be given before the output folder path......" `date` >> mainlog.txt
         echo -e "\nExiting the program......" `date` >> mainlog.txt
         echo -e "\nType 'sh main.sh -h' for help\n"
         exit 1
      fi
      # Checking the validity of the argument
      if [[ $out != /* ]] ; then
         echo -e "\nInvalid argument for the output folder path\n"
         echo -e "\nInvalid argument for the output folder path......" `date` >> mainlog.txt
         echo -e "\nExiting the program......" `date` >> mainlog.txt
         exit 1

      # Checking the existence of the output folder path
      elif [[ ! -d $out ]] ; then
           echo -e "\nThe output folder path does not exist\n"
           echo -e "\nThe output folder path does not exist......" `date` >> mainlog.txt
           echo -e "\nExiting the program......" `date` >> mainlog.txt
           exit 1

      # Checking the existence of the output folder path
      elif [[ -d $out/$out_name ]] ; then
          echo -e "\nThe output folder already exists\n"
          echo -e "\nThe output folder already exists......" `date` >> mainlog.txt
          echo -e "\nExiting the program......" `date` >> mainlog.txt
          exit 1

      # Creating the new output folder
      else
          mkdir $out/$out_name
          echo -e "\nA new output folder named "$out_name" is created in the path $out......" `date` >> mainlog.txt

      fi
      ;;
    
    k)
      ch2=$OPTARG
     
      if [[ $ch != Y ]]; then
        echo -e "\nInvalid option --rem_chr_newfile as the gold standard file does not contain 'chr' in the chromosome number\n"
        echo -e "\nInvalid option --rem_chr_newfile as the gold standard file does not contain 'chr' in the chromosome number\n......" `date` >> mainlog.txt
        echo -e "\nExiting the program......" `date` >> mainlog.txt
        exit 1
      fi

      echo -e "\nPlease wait............"
      f_name=$($curr_path/temp/miniconda3/bin/python3 remove_chr.py $vcf_gold $ch2 2>&1)
      vcf_gold=$f_name
      
      ;;

    n)
      cpt=$OPTARG

      # Checking the validity of the argument
      if [[ $cpt != [1-9]* || $cpt == *[aA-zZ]* ]] ; then
        echo -e "\nInvalid argument for number of cpu(s) per task\n"
        echo -e "\nInvalid argument for number of cpu(s) per task......" `date` >> mainlog.txt
        echo -e "\nExiting the program......" `date` >> mainlog.txt
        exit 1
      fi
      ;;
   
    s)
      mem=$OPTARG
     
      # Checking the validity of the argument
      if [[ $mem != [0-9]* ]] ; then
        echo -e "\nInvalid argument for the size of the memory required per node\n"
        echo -e "\nInvalid argument for the size of the memory required per node......" `date` >> mainlog.txt
        echo -e "\nExiting the program......" `date` >> mainlog.txt
        exit 1
      fi
      ;;
    
    p)
      par=$OPTARG
      ;;
    
    t)
      tot_time=$OPTARG

      # Checking the validity of the input
      if [[ $tot_time != [0-9]* ]] ; then
        echo -e "\nInvalid argument for total time of the slurm execution\n"
        echo -e "\nInvalid argument for total time of the slurm execution......" `date` >> mainlog.txt
        echo -e "\nExiting the program......" `date` >> mainlog.txt
        exit 1
      fi
      ;;
    
    m)
      mail_type=$OPTARG
      ;;
    
    a)
      acc=$OPTARG
      ;;
    
    e)
      mail_id=$OPTARG

      # Checking the validity of the argument
      if [[ $mail_id != *@*.* ]] ; then
        echo -e "\nInvalid Email Address\n"
        echo -e "\nInvalid Email Address......" `date` >> mainlog.txt
        echo -e "\nExiting the program......" `date` >> mainlog.txt    
        exit 1
      fi
      ;;
    
    h)
      help
      echo -e "\nExiting the program......" `date` >> mainlog.txt
      exit 0;;
    
    v)
      version
      echo -e "\nExiting the program......" `date` >> mainlog.txt
      exit 0;;  
    
    *)
      echo -e "\nType 'sh main.sh -h' for help"
      echo -e "\nExiting the program......" `date` >> mainlog.txt
      exit 1
      ;;
  esac
done

# Checking if all the mandatory arguments have been entered

if [[ $ch == Y && -z $ch2 ]]; then
  echo -e "\nThe reference file contains 'chr' in the chromosome number. Hence, --rem_chr_newfile option is mandatory"
  echo -e "\nThe reference file contains 'chr' in the chromosome number. Hence, --rem_chr_newfile option is mandatory......" `date` >> mainlog.txt
  echo -e "\nType 'sh main.sh -h' for help\n"
  echo -e "\nExiting the program......" `date` >> mainlog.txt
  exit 1
fi

if [[ -z "$ref" || -z "$vcf_gold" || -z "$out_name" ]] ; then
  echo -e "\nNot all the mandatory arguments are entered..."
  echo -e "\nNot all mandatory arguments are entered......" `date` >> mainlog.txt
  echo -e "\nType 'sh main.sh -h' for help\n"
  echo -e "\nExiting the program......" `date` >> mainlog.txt
  exit 1
fi

echo -e "\nAll commannd line arguments have been accepted......" `date` >> mainlog.txt

fi

# Creating a parameter file to record all the parameters that have been entered

echo "Execution Parameters:" > parameters.txt
echo -e "----------------------------------------------------------------------------" >> parameters.txt
echo -e "\nCurrent path: $curr_path" >> parameters.txt
echo "VCF folder path: $vcf_folder" >> parameters.txt
echo "Gold standard file: $vcf_gold" >> parameters.txt
echo "Genome reference fasta file: $ref" >> parameters.txt
echo "Output folder path: $out/$out_name" >> parameters.txt
echo "Does the gold standard file contain 'chr' in the chromosome number?: $ch" >> parameters.txt
echo "For gold standard file containing 'chr' in the chromosome number, does the user want to create a new file with the removed 'chr' word?: $ch2" >> parameters.txt

echo -e "\nSlurm Options:\n" >> parameters.txt
echo "Number of cpu(s) per task: $cpt" >> parameters.txt
echo "Amount of memory required per node: $mem" >> parameters.txt
echo "The time limit on the total runtime of the job allocation: $tot_time" >> parameters.txt

# Checking if account name is null
if [[ -z $acc ]] ; then
   echo "The account name for the job: Default that is set by the cluster manager" >> parameters.txt
else
   echo "The account name for the job: $acc" >> parameters.txt
fi

# Checking if partition is null
if [[ -z $par ]] ; then
   echo "The partition name: Default that is set by the cluster manager" >> parameters.txt
else
   echo "The partition name: $par" >> parameters.txt
fi

echo "The mail type to notify users: $mail_type" >> parameters.txt

# Checking if the mail id is null
if [[ -z $mail_id ]] ; then
   echo "The email address to notify user:  Default that is set by the cluster manager" >> parameters.txt
else
   echo "The email address to notify user: $mail_id" >> parameters.txt 
fi

echo -e "\nParameter file generated......" `date` >> mainlog.txt
echo -e "\n" >> mainlog.txt

# Proving executable permissions to the file for all
chmod a+x generate_plots.sh

echo -e "\nThe parameter file is generated in the following path: $curr_path/parameters.txt\n"

files=`ls $vcf_folder/*.vcf`

# Creating zipped files of the vcf files
for var in $files
do

$truvari_path/bgzip -c $var > $var.gz

done

echo -e "\nThe vcf files are compressed using the bgzip program" `date` >> mainlog.txt

files_index=`ls $vcf_folder/*.gz`

# Creating index files of the zipped vcf files
for var in $files_index
do

$bin_path/tabix -p vcf $var

done

echo -e "\nThe indexed files are created of the zipped vcf files\n\n" `date` >> mainlog.txt

# Executing the generation of plots script in the background by taking the variables from the current shell
source ./generate_plots.sh
