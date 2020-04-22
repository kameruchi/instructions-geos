#!bash
##
## Script to initialize a fresh copy of Ubuntu with all the stuff needed
## to run GEOS Chem classic code
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
Environment ready to install GEOS Chem classic!
You should now prepare a python environment and download the source code.
You can do this by running the script local_GEOS_install_script 

If you want to know the paths where the libraries were installed, I'v saved that info on versions.txt
#####
"



