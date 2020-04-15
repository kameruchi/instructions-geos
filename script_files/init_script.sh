#!bash
##
## Script to initialize a fresh copy of Ubuntu with all the stuff needed
## to run GEOS Chem classic code
## Change hardcoded directories approperly. 
## To understand what each line of this script does, check the README from 
## https://github.com/kameruchi/instructions-geos
## 
##

echo"
Let's install all the stuff needed to run GEOS Chem.
Note: This script is intended to be run on a fresh ubuntu install.
It will install a bunch of libraries and it will modify your .bash_profile and .bashrc
If you are not sure this is what you want to do, abort. Otherwise, go ahead
"
read -p "Proceed? [y/n]"  ANS
if [ $ANS != "y" ]; then
	exit 1
fi

cd ~


# Install ubuntu packages
sudo apt update

sudo apt install git tmux curl

sudo apt install gcc gfortran g++

sudo apt-get install libnetcdf-dev libnetcdff-dev

sudo apt install netcdf-bin

sudo apt install libopenmpi-dev

### Fetch files we'll need
curl https://repo.anaconda.com/archive/Anaconda3-2020.02-Linux-x86_64.sh > install_anaconda3-2020.02.sh
curl -O https://github.com/kameruchi/instructions-geos/script_files/conda_env.yml
curl https://github.com/kameruchi/instructions-geos/script_files/bash_p.sh >> .bash_profile


#Python conda

bash install_anaconda3-2020.02.sh

conda deactivate

conda env create -f conda_env.yml

conda activate geos-python-env

## Bash profile

#don't hardcode the Number of virtual CPUs
#This will indicate GEOS to use ALL of the Threads / virtual CPUs
N_CPUS=`nproc --all`

echo "export OMP_NUM_THREADS=$(N_CPUS)" >> .bash_profile

source .bash_profile

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



