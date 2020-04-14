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
```lsb_release -a```

If you want info about your CPU:
```lscpu```
(Note the number of cores)

And for the RAM (in Gb): 
```free -g```

Let's start by installing stuff we'll need.

First, let's update the package list

```sudo apt update```

And install git
```sudo apt install git```

# C, C++ and Fortran compilers

```sudo apt install gcc gfortran g++```

This will install them to /ust/bin/ 
If you want or need to find out which version has been installed, just do --version, like:
```gfortran --version```


# The NetCDF library

We'll need to install the [Network Common Data Form lib](https://www.unidata.ucar.edu/software/netcdf/), a set of software libraries and machine-independent data formats that support the creation, access, and sharing of array-oriented scientific data.
Type:

```sudo apt-get install libnetcdf-dev libnetcdff-dev```

That will install the NetCDF for C and for Fortran.
To check the NetCDF configuration for each one, you can do:

```
nc-config --all
nf-config --all
```

Pay attention to the "--includedir": We will need it when compiling Fortran code (and also when we define Environment Variables later on).

Now let's install **ncdum**, a tool that reads a netCDF file and outputs text.

```
sudo apt install netcdf-bin
```

While we are here, it's a good idea to test some sample NetCDF code. You can do something like:

```
wget https://www.unidata.ucar.edu/software/netcdf/examples/programs/simple_xy_wr.f90
```

_That will fetch some code and save it to your current directory. Then you can compile the fortran code like:_

```
gfortran simple_xy_wr.f90 -o test_nc.exe -I/usr/include -lnetcdff
```

See how we had included the /usr/include I mentioned before?
You should see a message saying something like _SUCCESS writing example file simple_xy.nc_. Let's check the file content (with our new tool, ncdump)

```
ncdump -h simple_xy.nc
```

You should see something like:
```
netcdf simple_xy {
dimensions:
      x = 6 ;
      y = 12 ;
variables:
      int data(x, y) ;
}
```

# The Message Passing Interface ~~library~~ standard 
The MPI is a library standard _for portable, efficient, and flexible message passing widely used for writing message passing programs_ You can read more about it [here](https://computing.llnl.gov/tutorials/mpi/).
Bottom line is, we need to install a _library_ that uses this standard. We'll use [Open MPI](https://www.open-mpi.org/)

```
sudo apt install libopenmpi-dev
```

You can see where they were installed with:

```
which mpirun mpicc mpifort mpic++
```

And the MPI version with, guess what, --version.

```
mpirun --version
```

If you need to know the full command of the mpicc wrapper, do:

```
mpicc --show
```

We don't care about all of that extra info for now anyway, but it is always good to know how to get it.

Let's test the Open MPI installation. Get some sample code, compile and run it:

```
wget https://www.open-mpi.org/papers/workshop-2006/hello.c
mpicc -o hello.exe hello.c
mpirun -np 2 ./hello.exe
```

Cool, right?

# Python3

Lots of documentation out there recommend using conda (anaconda / miniconda). ~~I don't see the reason to use conda in a unix environment (it would make sense in Windows)~~ We'll need to install some packages that are available on conda but not with pip. So using conda _makes sense_.

Install curl and retrieve the anaconda installer script
```
sudo apt install curl

curl -O https://repo.anaconda.com/archive/Anaconda3-2020.02-Linux-x86_64.sh

```

It's always a good idea to check the integrity of the file. You can do that with:

```
md5sum Anaconda3-2020.02-Linux-x86_64.sh

```

The output should be the same as listed on [here](https://repo.anaconda.com/archive/).

Now let's run the installation script:
```
bash Anaconda3-2020.02-Linux-x86_64.sh
```
This will install Anaconda. Say yes to everything. Once its done, do:
```
conda deactivate
```
To get out of the "base" virtual environment.

Let's create a file to put all the python packages we want to install in our virtual env, and copy a bunch of packages. This file is copied from  from [here](https://github.com/geoschem/geos-chem-cloud/blob/master/scripts/build_environment/python/geo.yml)

```
nano geos_python_req.yml
```
Paste the following:

~~~
name: geos-python-env
channels:
    - defaults
    - conda-forge
dependencies:
    - python=3.6    # Python version 3.6
    - bottleneck    # C-optimized array functions for NumPy
    - cartopy       # Geographic plotting toolkit
    - cython        # Transpile Python->C
    - dask          # Parallel processing library
    - graphviz      # visualize dask graph (binary)
    - future        # Python 2/3 compatibility
    - h5py          # Wrapper for HDF5
    - ipython       # IPython interpreter and tools
    - jupyter       # Jupyter federation architecture
    - jupyterlab    # next-generation Jupyter
    - matplotlib    # 2D plotting library
    - netcdf4       # netcdf4 Python API, backend for xarray
    - numpy         # N-d array and numerics
    - pandas        # Labeled array library
    - scipy         # Common math/stats/science functions
    - scikit-learn  # Machine learning library
    - statsmodels   # Regression/modeling toolkit
    - seaborn       # Statistical visualizations
    - six           # Python 2/3 compatibility
    - tqdm          # Nice progressbar for longer computations
    - xarray        # the major tool to work with NetCDF data
    - xbpch         # Interface for bpch output files
    - esmpy         # Python interface to ESMF (xesmf dependency)
    - pip:
        # These are additional libraries to search for on PyPI
        - xesmf    # Regridding xarray and numpy data
        - "git+https://github.com/JiaweiZhuang/cubedsphere.git@v0.1.1"  # plot GCHP data
        - h5netcdf # allow HDF5-backend for xarray
        - graphviz # visualize dask graph (python package)
        - awscli   # AWS command line interface
        - pypdf2   # Save output to PDF (and allows for bookmarks in PDF files)
~~~

Save (Ctrl+o, enter, Ctrl+X) and then run:
```
conda env create -f python_req.yml 
```
This will create a python environment called _geos-python-env_. Activate it
```
conda activate geos-python-env
```
By the way, all the virtual envirnments you create with conda will be under _~/anaconda3/envs_.

We are done with the python setup! :)

# Environment Variables

We'll need to define some env vars to point to the compilers, libraries and stuff we have installed before. These envs will be used by GEOS Chem.
Let's use .bash_profile for that:

```
cd ~
nano .bash_profile
```

You'll enter on a text editor called nano. Add the following lines to the .bash_profile file (It will probably be empty ifyou are on a fresh installation):

~~~
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
#OMP_STACKSIZE must also be set to a very large number for the Fortran compiler. 500M seems like a good number but we could go much higher.
export OMP_STACKSIZE=1000m

#set the number of computational cores (aka threads) that you would like GEOS-Chem to use. 
export OMP_NUM_THREADS=30
#NOTE: It seems that OMP_NUM_THREADS and OMP_STACKSIZE should be defined not only in the bash startup script, but in also each GEOS-Chem run script that you use. 
~~~

Then press Ctrl+O enter to save the file and then Ctrl+X to exit.
**Note that the OMP_NUM_THREADS can be as high as the number of threads or virtual cores your CPUs you have**
Remember we checked the information about our hardware when we just started?
The CPU I'm using, as I noted, is a _AMD Ryzen Threadripper 2950X Processor_. It tells me it has 16 cores. If you do a quick google search, you'll see this CPU has 32 _threads_. This mean I can use up to 32 threads for the parallelization with OpenMP. Adjust your number accordingly.
By thw way, to find the number of threads you have, you can also use nproc:

```
nproc
```
# Initial setup is done!
Congrats! If you made it to here, you deserve a cookie 🍪 
Maybe even two 🍪 🍪 .

Now lets start dealing with the actual code....

First download the source:

```
git clone https://github.com/geoschem/geos-chem.git GEOS_Chem_Classic_Code_V_12.7.2
```
This will download the source code to a folder called GEOS_Chem_Classic_Code_V_12.7.2

Let's also download the _Unit Test_ so we can test the installation:

```
git clone https://github.com/geoschem/geos-chem-unittest UT
cd UT
```
Now let's edit a test file to create a _run directory_:

```
cd perl
CopyRunDirs.input
```
Find the following lines and replace. Let's asume your user name is _totoro_ (you have to replace _totoro_ by your user name)

~~~
GCGRID_ROOT    : /media/totoro/bigfathd/GEOS-CHEM/gcgrid
CODE_DIR       : {HOME}/geos_chem_classic/GEOS_Chem_Classic_Code_V_{VERSION}
UNIT_TEST_ROOT : {HOME}/geos_chem_classic/UT
COPY_PATH      : {HOME}/geos_chem_classic/Test/rundirs
~~~
**OK, let's pause here for a moment**
You need to understand what we are doing here, so:
GCGRID_ROOT is the full path to where the DATA for your simulation is (Meteorological data, etc). Even if you don't have the data yet, just create the appropiate directories / folders.

CODE_DIR is where the _source code_ of GEOS Chem is.
UNITE_TEST_ROOT is where the Unit Test code lives.
And COPY_PATH is where the script will output the _run directory_

While we are here, you need to also create the following structure under your 
directory with the DATA:
/data/ExtData
In our example, it would be:
/media/totoro/bigfathd/GEOS-CHEM/gcgrid/data/ExtData/
**It's ok if this is empty, but it needs to be there**

_Let's create now the run directory_:

`

`

This will create a /Test/rundirs under /geos_chem_classic. Go to that folder
```
cd ~/geos_chem_classic/Test/rundirs/geosfp_4x5_standard
```
This is a _run directory_
We'll now compile this! But before that, let's make sure you have applied the environments we created waaaay above, in the beginning. Remember when you edited .bash_profile? Well, it's going to pay off now:
```
source ~/.bash_profile
```
Now, to compile 🤞:
```
make
```
Hopefully everything went well.

Finally, we will run a _dry simulation_. This is a simulation without any data files: It will check which data files we need for this specific simulation and then create a file we can use to download **only the data we need**. Once we do that, we'll then be able to run the _real_ simulation (aka _production simulation_)
```
./geos --dryrun > log.dryrun
```
This will take a while. Once it finishes, log.dryrun will have a list of the files we need to download. 
Fear not! It won't be a manual download. Luckily each run directory comes with a python script to download it!
```
./download_data.py log.dryrun --cc
```
And this may take a long time, since it will fetch a looot of data. Pat youself in the back and go do something else.







