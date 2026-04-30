# Fortran tests

A bunch of Fortran tests (use mpi and use mpi_f08 as mpif.h is dead and deprecated and should not be used).
This test suite will only work with an MPI implementation that supports MPI 4.1 or higher

Dirt simple configury for now.

# Compile
```
$ ./autogen.sh && ./configure FC=mpifort && make
```

# Run
Only support run by hand or via a script or something for now
