# Notes about setting up GEOS-Chem

These are some notes about my experience setting up a new cluster to run GEOS–Chem.

**What is GEOS-Chem?**

GEOS-Chem is a [Chemical Transport Model](https://en.wikipedia.org/wiki/Chemical_transport_model) for simulating atmospheric chemical compositions.
It has been developed over 20 years and is used by [more than 100 research groups worldwide](http://acmg.seas.harvard.edu/geos/geos_people.html).
The program is mainly written in Fortran 90.
You can find [all model source code on github](https://github.com/geoschem) and it is [distributed freely under the MIT license](http://acmg.seas.harvard.edu/geos/geos_licensing.html).
If you want to know, input and output data formats are mostly NetCDF.

**Now, let's start**

We'll assume you are more or less familiar with a _terminal_ and unix systems (linux).

_Starting with a clean Linux installation_

We'll use a freshly installed Ubuntu 18.04 (aka bionic) on a _AMD Ryzen Threadripper 2950X 16-Core Processor_  CPU with 62 GB of RAM.

If you want to know which version of linux you have, type:
`lsb_release -a`

If you want info about your CPU:
`lscpu`
And for the RAM (in Gb): 
`free -g`

Let's start by installing stuff we'll need.

First, let's update the package list

`sudo apt update`

# C, C++ and Fortran compilers

`sudo apt install gcc gfortran g++`

This will install them to /ust/bin/ 
If you want or need to find out which version has been installed, just do --version, like:
`gfortran --version`


# The NetCDF library

We'll need to install the [Network Common Data Form lib](https://www.unidata.ucar.edu/software/netcdf/), a set of software libraries and machine-independent data formats that support the creation, access, and sharing of array-oriented scientific data.
Type:

`sudo apt-get install libnetcdf-dev libnetcdff-dev`

That will install the NetCDF for C and for Fortran.
To check the NetCDF configuration for each one, you can do:

`nc-config --all
 nf-config --all`

Pay attention to the "--includedir": We will need it when compiling Fortran code.

Now let's install **ncdum**, a tool that reads a netCDF file and outputs text.

`sudo apt install netcdf-bin`

While we are here, it's a good idea to test some sample NetCDF code. You can do something like:

`wget https://www.unidata.ucar.edu/software/netcdf/examples/programs/simple_xy_wr.f90`

_That will fetch some code and save it to your current directory. Then you can compile the fortran code like:_

`gfortran simple_xy_wr.f90 -o test_nc.exe -I/usr/include -lnetcdff`

See how we had included the /usr/include I mentioned before?
You should see a message saying something like _SUCCESS writing example file simple_xy.nc_. Let's check the file content (with our new tool, ncdump)

`ncdump -h simple_xy.nc`

You should see something like:
`netcdf simple_xy {
dimensions:
      x = 6 ;
      y = 12 ;
variables:
      int data(x, y) ;
}`

# The Message Passing Interface ~~library~~ standard 
The MPI is a library standard _for portable, efficient, and flexible message passing widely used for writing message passing programs_ You can read more about it [here](https://computing.llnl.gov/tutorials/mpi/).
Bottom line is, we need to install a _library_ that uses this standard. We'll use [Open MPI](https://www.open-mpi.org/)

`sudo apt install libopenmpi-dev`

You can see where they were installed with:

`which mpirun mpicc mpifort mpic++`

And the MPI version with, guess what, --version.

`mpirun --version`

If you need to know the full command of the mpicc wrapper, do:

`mpicc --show`

We don't care about all of that extra info for now anyway, but it is always good to know how to get it.

Let's test the Open MPI installation. Get some sample code, compile and run it:

`wget https://www.open-mpi.org/papers/workshop-2006/hello.c
mpicc -o hello.exe hello.c
mpirun -np 2 ./hello.exe
`

Cool, right?

# Python3

Your system probably came with Python 3 already, but let's install the 3.7 and make it the default python.











