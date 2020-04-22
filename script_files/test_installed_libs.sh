#!bash
##
## Very basic script to check NetCDF library and MPI are intalled properly 
## to run GEOS Chem classic code
## Check the README from 
## https://github.com/kameruchi/instructions-geos
## 
##
## ToDo:
## -Ask for user confirmation or input of includedir
## -Add error codes exit check

echo"
Check out the --includedir below.
"

nf-config --all



echo"
I'm assuming the --includedir is /usr/include

I'll download some sample code, compile and run it to check NetCDF is working.
"

wget https://www.unidata.ucar.edu/software/netcdf/examples/programs/simple_xy_wr.f90

gfortran simple_xy_wr.f90 -o test_nc.exe -I/usr/include -lnetcdff

./test_nc.exe

ncdump -h simple_xy.nc

echo"
##### 
Done. The output aboce should be something like:

netcdf simple_xy {
dimensions:
      x = 6 ;
      y = 12 ;
variables:
      int data(x, y) ;
}

If that's not the case, you may have an issue with your NetCDF library installation.
"

echo"
Now I'll check Open MPI installation
"

wget https://www.open-mpi.org/papers/workshop-2006/hello.c
mpicc -o hello.exe hello.c
mpirun -np 2 ./hello.exe

echo"
#####
Done. If you didn't see any error, MPI is also working :)
####
"

