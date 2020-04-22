#!bash
##
## What's this?
## A script to locally install Anaconda, setup an environment and download the latest version of
## GEOS Chem classic code to a folder called geos_code_version.VERSION, where VERSION is the current
## version (it reads it automatically)
## It also saves paths of compilers and libraries to a file called versions.txt
## You may need this info to pass to GEOS
##
## Requirements
## You need to have the following stuff installed:
## git curl gcc gfortran g++ libnetcdf-dev libnetcdff-dev netcdf-bin libopenmpi-dev
## You can install everything by running the init_script or manually.
## 
## To understand what each line of this script does, check the README from 
## https://github.com/kameruchi/instructions-geos
## 
##

echo"
Note: This script will modify your .bash_profile and .bashrc
If you are not sure this is what you want to do, abort. Otherwise, go ahead
"
read -p "Proceed? [y/n]"  ANS
if [ $ANS != "y" ]; then
	exit 1
fi

cd ~


### Fetch files we'll need
curl https://repo.anaconda.com/archive/Anaconda3-2020.02-Linux-x86_64.sh > install_anaconda3-2020.02.sh
curl -O https://raw.githubusercontent.com/kameruchi/instructions-geos/master/script_files/conda_env.yml
curl https://raw.githubusercontent.com/kameruchi/instructions-geos/master/script_files/bash_p.sh >> .bash_profile


## Bash profile

#don't hardcode the Number of virtual CPUs
#This will indicate GEOS to use ALL of the Threads / virtual CPUs
NCPUS=$(nproc --all)

echo "export OMP_NUM_THREADS=${NCPUS}" >> .bash_profile

source .bash_profile

#Python conda

bash install_anaconda3-2020.02.sh

conda deactivate

conda env create -f conda_env.yml

conda activate geos-python-env


## Download the GEOS Chem code
## Don't hardcode the version. But having it on the directory name helps for GEOS

git clone https://github.com/geoschem/geos-chem.git geos
cd geos
VERSION=`git describe --tags`
NEW_DIR="geos_code_version.${VERSION}"
cd ..
mv geos $NEW_DIR

#And download the Unit Test too
git clone https://github.com/geoschem/geos-chem-unittest UT

##Done!

## Save the paths of all the installed stuff we may need to know for GEOS on a file for reference
gfortran --version >> versions.txt

nc-config --all >> versions.txt

nf-config --all >> versions.txt

which mpirun mpicc mpifort mpic++ >> versions.txt

mpicc --show >> versions.txt

##And tell the user what to do next
echo "
#####
Done!
Environment ready to run GEOS Chem classic!

If you want to know the paths where the libraries were installed, I'v saved that info on versions.txt

If you want to give it a try, follow the quick guide from https://github.com/kameruchi/instructions-geos
and start from it says Ready to Run!
#####
"



