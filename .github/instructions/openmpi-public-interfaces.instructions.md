---
applyTo: "**/*.{c,h,cc,cpp,cxx,hpp,f90,F90}"
---

# Open MPI public C and Fortran interface rules

When reviewing public Open MPI C or Fortran APIs, verify interface definitions
against the Open MPI MPI API man pages:

https://docs.open-mpi.org/en/main/man-openmpi/man3/

Do not infer a public API signature from another language binding. C, legacy
Fortran, and Fortran 2008 bindings may use different type spellings.

For `use mpi_f08` code:
- Preserve `TYPE(MPI_Comm)`, `TYPE(MPI_Datatype)`, `TYPE(MPI_Info)`,
  and `TYPE(MPI_Request)` handles.
- Do not convert these handles to plain `INTEGER`.
- Preserve `INTEGER(KIND=MPI_COUNT_KIND)` and
  `INTEGER(KIND=MPI_ADDRESS_KIND)` where the Fortran 2008 interface uses them.
- Preserve optional `ierror` arguments and `ASYNCHRONOUS` attributes where
  present in the interface.
