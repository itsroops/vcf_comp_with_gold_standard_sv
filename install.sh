#! /bin/sh

start_time=$(date +"%s")

# Recording the current path
k=`pwd`

# Making a temporary directory
mkdir temp

echo -e "\nThe temp install folder created......"

# Navigating to the temporary directory
cd temp

echo -e "\nNavigating to the temporary directory......"

echo -e "\nDownloading the latest miniconda3 installer......"

# Downloading the miniconda installer
wget --no-check-certificate https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh

echo -e "\nStarting miniconda3 installation......"
echo -e "\n"

# Installing the Miniconda3 in the current path
sh Miniconda3-latest-Linux-x86_64.sh -b -p $k/temp/miniconda3

# Removing the miniconda installer
rm Miniconda3-latest-Linux-x86_64.sh

# Setting the conda path
conda_path=$k/temp/miniconda3/condabin
echo -e "\nSetting the conda path......"

echo -e "\nminiconda3 installation completed and it is installed in the minconda3 folder......"

echo -e "\nInstalling the Truvari tool......"

# Installing the truvari tool
$k/temp/miniconda3/bin/pip install Truvari

echo -e "\nInstalling tabix......"

# Installing tabix
$conda_path/conda install -y -c bioconda tabix

echo -e "\n"

echo -e "\nAll required softwares are installed in the path: $k/temp....."

end_time=$(date +"%s")

# Computing the elapsed seconds
secs=$((end_time-start_time))

# Dividing seconds into hours, minutes and seconds
h=$((secs/3600))
m=$((secs%3600/60))
s=$((secs%60))

echo -e "\nThe total running time of the installation process is $h hour(s) $m minute(s) and $s second(s)\n"
