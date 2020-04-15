#Env vars needed by GEOS Chem
export FC=gfortran
export CC=gcc
export CXX=g++
#netCDF Library:
export NETCDF_HOME=/usr
export NETCDF_FORTRAN_HOME=/usr

#Tell GEOS-Chem where to find netCDF library files
#Point to the bin/ subfolder of the root netCDF path.
#This is where the nc-config and nf-config files are located
export GC_BIN=$NETCDF_HOME/bin
#Point to the include/ subfolder of the root netCDF path.
#This is where netCDF include files (*.h, *.inc) and compiled module files (*.mod) for the netCDF (and HDF5) libraries are located. 
export GC_INCLUDE=$NETCDF_HOME/include
#Point to the lib/ subfolder of the root netCDF path.
#some systems may be lib64/ instead. This is where the netCDF library files (*.a) are located. 
export GC_LIB=$NETCDF_HOME/lib

#If netCDF-Fortran was loaded as a separate module, then
#define these variables. Not our case.                
#export GC_F_BIN=$NETCDF_FORTRAN_HOME/bin
#export GC_F_INCLUDE=$NETCDF_FORTRAN_HOME/include
#export GC_F_LIB=$NETCDF_FORTRAN_HOME/lib

#Parallelization

#Max out the stack memory for OpenMP
#The stack memory is where local automatic variables
#and temporary !$OMP PRIVATE variables will be created
#tell the Unix shell to use the maximum amount of stack memory available
ulimit -s unlimited
#OMP_STACKSIZE must also be set to a very large number for the Fortran compiler. 500M seems like a good general number but we could go much higher.
#Edit if you want
export OMP_STACKSIZE=500m

#set the number of computational cores (aka threads) that you would like GEOS-Chem to use. 
#This is setted by the script later
#export OMP_NUM_THREADS=30
#NOTE: It seems that OMP_NUM_THREADS and OMP_STACKSIZE should be defined not only in the bash startup script, but in also each GEOS-Chem run script that you use.

###also load bashrc if needed
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
    fi
fi
