#! /bin/sh

# Navigating to the vcf files
files=`ls $vcf_folder/*.vcf`

echo -e "Submitting jobs for all the vcf files:\n"

job_time=$(date +"%s")

# Submitting jobs for all the vcf files
for var in $files

do

# Reading the filename
file_name=`echo $var | rev | cut -d'/' -f 1 | rev`
file_name=$out/$out_name/$file_name

# Declaring array for storing submitted jobs
declare -a jobs

# Declaring array for storing different status of jobs

declare -a runnning
declare -a completed
declare -a cancelled
declare -a failed
declare -a deadline
declare -a node_fail
declare -a pending
declare -a timeout
declare -a preempted
declare -a out_of_memory

# The case when the account, partition and mail_id parameters are null
if [[ -z $acc && -z $par && -z $mail_id ]] ; then
   k=`sbatch --cpus-per-task=$cpt --mem=$mem --time=$tot_time --mail-type=$mail_type vcf_comp.sh $truvari_path $vcf_gold $var $file_name $ref`

# The case when the account and  partition are null whereas mail_id parameters is not null
elif [[ -z $acc && -z $par && ! -z $mail_id ]] ; then
     k=`sbatch --cpus-per-task=$cpt --mem=$mem --time=$tot_time --mail-type=$mail_type --mail-user=$mail_id vcf_comp.sh $truvari_path $vcf_gold $var $file_name $ref`

# The case when the account and mail_id are null whereas the partition is not null
elif [[	-z $acc	&& ! -z $par && -z $mail_id ]] ; then
     k=`sbatch --cpus-per-task=$cpt --mem=$mem --time=$tot_time  --partition=$par --mail-type=$mail_type vcf_comp.sh $truvari_path $vcf_gold $var $file_name $ref`

# The case when the account is null whereas partition and mail_id parameters are not null
elif [[ -z $acc && ! -z $par && ! -z $mail_id ]] ; then
     k=`sbatch --cpus-per-task=$cpt --mem=$mem --time=$tot_time  --partition=$par --mail-type=$mail_type --mail-user=$mail_id vcf_comp.sh $truvari_path $vcf_gold $var $file_name $ref`

# The case when the partition and mail id are null whereas the account is not null
elif [[ ! -z $acc && -z $par && -z $mail_id ]] ; then
     k=`sbatch --cpus-per-task=$cpt --mem=$mem --time=$tot_time --account=$acc --mail-type=$mail_type vcf_comp.sh $truvari_path $vcf_gold $var $file_name $ref`

# The case when the partition is null whereas the account and mail_id are not null
elif [[ ! -z $acc && -z $par && ! -z $mail_id ]] ; then
     k=`sbatch --cpus-per-task=$cpt --mem=$mem --time=$tot_time --account=$acc --mail-type=$mail_type --mail-user=$mail_id vcf_comp.sh $truvari_path $vcf_gold $var $file_name $ref`

# The case when the account and partition parameters are not null and mail id is null
elif [[ ! -z $acc && ! -z $par && -z $mail_id ]] ; then
     k=`sbatch --cpus-per-task=$cpt --mem=$mem --time=$tot_time --account=$acc --partition=$par --mail-type=$mail_type vcf_comp.sh $truvari_path $vcf_gold $var $file_name $ref`

# The case when the account, partition and mail id are not null
else
  k=`sbatch --cpus-per-task=$cpt --mem=$mem --time=$tot_time --account=$acc --partition=$par --mail-type=$mail_type --mail-user=$mail_id vcf_comp.sh $truvari_path $vcf_gold $var $file_name $ref`

fi

echo $k
echo $k......`date` >> mainlog.txt

# Extracting the job ids
j=$(echo $k | cut -d ' ' -f4)
jobs+=($j)
done

echo -e "\nThe 'squeue' command can be used to check the status of the jobs submitted" >> mainlog.txt
echo -e "\nMoreover, the running status of individual jobs can be found here $curr_path/slurm-jobid.out" >> mainlog.txt

sleep 5
echo -e "\nThe 'squeue' command can be used to check the status of the jobs submitted"
echo -e "\nMoreover, the running status of individual jobs can be found here $curr_path/slurm-jobid.out\n"

# Running the infinite loop  till all the queued jobs terminate
l=0
while [ $l -lt 10 ]
do

flag=0

# Setting the runtime of the jobs
run_time=$(date +"%s")

# Computing the elapsed seconds
secs=$((run_time-job_time))

# Dividing seconds into hours, minutes and seconds
h=$((secs/3600))
m=$((secs%3600/60))
s=$((secs%60))

echo -e "\nPlease wait while the jobs are running.......Time elapsed for the job(s) is $h hour(s) : $m minute(s) : $s second(s)\n"

# Initializing the job status arrays with null values 
running=()
completed=()
cancelled=()
failed=()
deadline=()
node_fail=()
pending=()
timeout=()
preempted=()
out_of_memory=()

for c in "${jobs[@]}"
do

# Checking the status of the jobs
s_comp=`sacct -j $c | grep vcf | grep COMPLETED`
s_run=`sacct -j $c | grep vcf | grep RUNNING`
s_can=`sacct -j $c | grep vcf | grep CANCELLED`
s_fail=`sacct -j $c | grep vcf | grep FAILED`
s_dead=`sacct -j $c | grep vcf | grep DEADLINE`
s_nfail=`sacct -j $c | grep vcf | grep NODE_FAIL`
s_pen=`sacct -j $c | grep vcf | grep PENDING`
s_time=`sacct -j $c | grep vcf | grep TIMEOUT`
s_pre=`sacct -j $c | grep vcf | grep PREEMPTED`
s_outmem=`sacct -j $c | grep vcf | grep OUT_OF_MEMORY`

# Adding the completed jobs to its status array
if [[ ! -z $s_comp ]] ; then
   completed+=($c)
fi

# Adding the running jobs to its status array
if [[ ! -z $s_run ]] ; then
   running+=($c)

fi

# Adding the cancelled jobs to its status array
if [[ ! -z $s_can ]] ; then
   cancelled+=($c)
fi

# Adding the failed jobs to its status array
if [[ ! -z $s_fail ]] ; then
   failed+=($c)
fi

# Adding the jobs terminated on deadline to its status array
if [[ ! -z $s_dead ]] ; then
   deadline+=($c)

fi

# Adding the jobs terminated due to failure of one or more allocated nodes to its status array
if [[ ! -z $s_nfail ]] ; then
   node_fail+=($c)
fi

# Adding the jobs awaiting resource allocation to its status array
if [[ ! -z $s_pen ]] ; then
   pending+=($c)
fi

# Adding the jobs terminated upon reaching its time limit to its status array
if [[ ! -z $s_time ]] ; then
   timeout+=($c)

fi

# Adding the jobs terminated due to preemption to its status array
if [[ ! -z $s_pre ]] ; then
   preempted+=($c)
fi

# Adding the jobs experienced out of memory error to its status array
if [[ ! -z $s_outmem ]] ; then
   out_of_memory+=($c)
fi

done

# Displaying the completed job array
if [[ ${#completed[@]} != 0 ]] ; then
   echo "Completed jobs: ${completed[*]}"
fi

# Displaying the running job array
if [[ ${#running[@]} != 0 ]] ; then
   echo "Running jobs: ${running[*]}"
fi

# Displaying the cancelled job array
if [[ ${#cancelled[@]} != 0 ]] ; then
   echo "Cancelled jobs: ${cancelled[*]}"
fi

# Displaying the failed job array
if [[ ${#failed[@]} != 0 ]] ; then
   echo "Failed jobs: ${failed[*]}"
fi

# Displaying the deadline job array
if [[ ${#deadline[@]} != 0 ]] ; then
   echo "Failed jobs due to deadline: ${deadline[*]}"
fi

# Displaying the node failed job array
if [[ ${#node_fail[@]} != 0 ]] ; then
   echo "Failed jobs due to node failure: ${node_fail[*]}"
fi

# Displaying the pending job array
if [[ ${#pending[@]} != 0 ]] ; then
   echo "Pending jobs: ${pending[*]}"
fi

# Displaying the timeout job array 
if [[ ${#timeout[@]} != 0 ]] ; then
   echo "Timeout jobs: ${timeout[*]}"
fi

# Displaying the preempted job array
if [[ ${#preempted[@]} != 0 ]] ; then
   echo "Preempted jobs: ${preempted[*]}"
fi

# Displaying the out of memory job array
if [[ ${#out_of_memory[@]} != 0 ]] ; then
   echo "Out of memory jobs: ${out_of_memory[*]}"
fi


for i in "${jobs[@]}"
do
k=`squeue | grep $i`
len=${#k}
if [[ $len = 0 ]]; then
flag=$((flag+1))
fi
done

if [[ $flag = ${#jobs[@]} ]]; then
break
fi

# Sleeping for two seconds
sleep 2

done

# Checking if the jobs that are queued have run successfully or not
count=`ls -1 $out/$out_name/*.summary.txt 2>/dev/null | wc -l`

if [[ $count == 0 ]] ; then
   echo -e "\nNone of the jobs have run successfully. Please check the slurm log files for details.\n"
   echo -e "\nNone of the jobs have run successfully. Please check the slurm log files for details......." `date` >> mainlog.txt

   # Displaying the cancelled job array
   if [[ ! ${#cancelled[@]} -eq 0 ]] ; then
      echo -e "\nJobs that are cancelled : ${cancelled[*]}"
      echo -e "\nJobs that are cancelled : ${cancelled[*]}" >> mainlog.txt
   fi

   # Displaying the failed job array
   if [[ ! ${#failed[@]} -eq 0 ]] ; then
      echo -e "\nJobs that failed : ${failed[*]}"
      echo -e "\nJobs that failed : ${failed[*]}" >> mainlog.txt
   fi

   # Displaying the deadline job array
   if [[ ! ${#deadline[@]} -eq 0 ]] ; then
      echo -e "\nJobs that are terminated on deadline are : ${deadline[*]}"
      echo -e "\nJobs that are terminated on deadline are : ${deadline[*]}" >> mainlog.txt
   fi

   # Displaying the node failed job array
   if [[ ! ${#node_fail[@]} -eq 0 ]] ; then
      echo -e "\nJobs that are terminated due to failure of nodes are : ${node_fail[*]}"
      echo -e "\nJobs that are terminated due to failure of nodes are : ${node_fail[*]}" >> mainlog.txt
   fi

   # Displaying the timeout job array
   if [[ ! ${#timeout[@]} -eq 0 ]] ; then
      echo -e "\nJobs that are terminated upon reaching its time limit are : ${timeout[*]}"
      echo -e "\nJobs that are terminated upon reaching its time limit are : ${timeout[*]}" >> mainlog.txt
   fi

   # Displaying the preempted job array
   if [[ ! ${#preempted[@]} -eq 0 ]] ; then
      echo -e "\nJobs that are terminated due to preemption are : ${preempted[*]}"
      echo -e "\nJobs that are terminated due to preemption are : ${preempted[*]}" >> mainlog.txt
   fi

   # Displaying the out of memory job array
   if [[ ! ${#out_of_memory[@]} -eq 0 ]] ; then
      echo -e "\nJobs that are terminated due to out of memory are : ${out_of_memory[*]}"
      echo -e "\nJobs that are terminated due to out of memory are : ${out_of_memory[*]}" >> mainlog.txt
   fi

   exit 1

fi

echo -e	"\nThe execution of jobs is complete"
echo -e "\nThe execution of jobs is complete......" `date` >> mainlog.txt

# Displaying the completed job array
if [[ ! ${#completed[@]} -eq 0 ]] ; then
   echo -e "\nJobs that are successfully executed are : ${completed[*]}"
   echo -e "\nJobs that are successfully executed are : ${completed[*]}"  >> mainlog.txt
fi

# Displaying the cancelled job array
if [[ ! ${#cancelled[@]} -eq 0 ]] ; then
   echo -e "\nJobs that are cancelled : ${cancelled[*]}"
   echo -e "\nJobs that are cancelled : ${cancelled[*]}" >> mainlog.txt
fi

# Displaying the failed job array
if [[ ! ${#failed[@]} -eq 0 ]] ; then
   echo -e "\nJobs that failed : ${failed[*]}"
   echo -e "\nJobs that failed : ${failed[*]}" >> mainlog.txt
fi

# Displaying the deadline job array
if [[ ! ${#deadline[@]} -eq 0 ]] ; then
   echo -e "\nJobs that are terminated on deadline are : ${deadline[*]}"
   echo -e "\nJobs that are terminated on deadline are : ${deadline[*]}" >> mainlog.txt
fi

# Displaying the node failed job array
if [[ ! ${#node_fail[@]} -eq 0 ]] ; then
   echo -e "\nJobs that are terminated due to failure of nodes are : ${node_fail[*]}"
   echo -e "\nJobs that are terminated due to failure of nodes are : ${node_fail[*]}" >> mainlog.txt
fi

# Displaying the timeout job array
if [[ ! ${#timeout[@]} -eq 0 ]] ; then
   echo -e "\nJobs that are terminated upon reaching its time limit are : ${timeout[*]}"
   echo -e "\nJobs that are terminated upon reaching its time limit are : ${timeout[*]}" >> mainlog.txt
fi

# Displaying the preempted job array
if [[ ! ${#preempted[@]} -eq 0 ]] ; then
   echo -e "\nJobs that are terminated due to preemption are : ${preempted[*]}"
   echo -e "\nJobs that are terminated due to preemption are : ${preempted[*]}" >> mainlog.txt
fi

# Displaying the out of memory job array
if [[ ! ${#out_of_memory[@]} -eq 0 ]] ; then
   echo -e "\nJobs that are terminated due to out of memory are : ${out_of_memory[*]}"
   echo -e "\nJobs that are terminated due to out of memory are : ${out_of_memory[*]}" >> mainlog.txt
fi

# Plotting the vcf comparison values
$curr_path/temp/miniconda3/bin/python3 truvari_plots.py $out/$out_name

# Checking if the plots are generated successfully or not
count=`ls -1 $out/$out_name/*.pdf 2>/dev/null | wc -l`

if [[ $count == 0 ]] ; then
   echo -e "\nThere is(are) some error(s) in the generation of plot files.\n"
   echo -e "\nThere is(are) some error(s) in the generation of plot files......" `date` >> mainlog.txt
   exit	1
fi


echo -e "\nThe bar charts of the comparison are generated in the path $out/$out_name......" `date` >> mainlog.txt
echo -e "\nThe bar charts of the comparison are generated in the path $out/$out_name"

end_time=$(date +"%s")

# Computing the elapsed seconds
secs=$((end_time-start_time))

# Dividing seconds into hours, minutes and seconds
h=$((secs/3600))
m=$((secs%3600/60))
s=$((secs%60))

echo -e "\nThe total running time of the program is $h hour(s) $m minute(s) and $s second(s)" >> mainlog.txt
echo -e "\nThe total running time of the program is $h hour(s) $m minute(s) and $s second(s)"

echo -e "\nThe log file is generated in the following path: $curr_path/mainlog.txt\n"

exit 0
