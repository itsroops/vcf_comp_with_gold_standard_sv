#! /bin/sh

# Proving executable permissions to the install.sh file for all
chmod a+x install.sh

echo -e "\nThe installation is being done. This usually takes a couple of minutes."
echo -e "\nThe installation path is `pwd`/temp\n"

# Executing the install.sh script from the current shell
source ./install.sh
