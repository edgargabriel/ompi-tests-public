# Open MPI public API interface rules

## Authoritative interface source

For public Open MPI C and Fortran API interface definitions, treat the Open MPI
manual pages as the authoritative source for routine names, argument order,
argument intent, handle types, Fortran kind parameters, optional `ierror`
arguments, and persistent/nonblocking request/info arguments.

The MPI API manual pages are under:

https://docs.open-mpi.org/en/main/man-openmpi/man3/

For an MPI routine named `MPI_Foo`, the corresponding page is usually:

https://docs.open-mpi.org/en/main/man-openmpi/man3/MPI_Foo.3.html

When reviewing or editing code that calls, wraps, tests, or declares a public
Open MPI C or Fortran interface, do not infer the signature from memory or from
a different language binding. Verify the binding-specific signature against the
relevant Open MPI man page or against the local generated interface definitions
before suggesting a change.

## Binding-specific rules

- Keep C binding arguments as the C MPI types shown in the relevant man page,
  such as `MPI_Comm`, `MPI_Datatype`, `MPI_Info`, `MPI_Request`, `MPI_Count`,
  and `MPI_Aint`.
- Keep Fortran `use mpi_f08` handle arguments as typed derived types, such as
  `TYPE(MPI_Comm)`, `TYPE(MPI_Datatype)`, `TYPE(MPI_Info)`, and
  `TYPE(MPI_Request)`.
- Do not rewrite `use mpi_f08` typed MPI handles as plain `INTEGER`.
  Plain `INTEGER` handles belong to the older `use MPI` / `mpif.h` style
  bindings, not to the Fortran 2008 `mpi_f08` binding.
- Preserve Fortran 2008 kind-specific integer arguments when present, such as
  `INTEGER(KIND=MPI_COUNT_KIND)` for counts and
  `INTEGER(KIND=MPI_ADDRESS_KIND)` for byte displacements.
- For nonblocking and persistent routines, preserve `TYPE(MPI_Request)` request
  arguments. For persistent initialization routines, preserve `TYPE(MPI_Info)`
  info arguments when the interface requires them.
- If a proposed change alters a public API signature, argument order, MPI handle
  type, Fortran kind, optional `ierror`, `ASYNCHRONOUS` attribute, or
  nonblocking/persistent argument, flag the change unless the Open MPI man page
  or local generated interface definition clearly supports it.

## Example: Fortran 2008 collectives

For `use mpi_f08` collective tests, especially files such as
`fortran/collectives/*_f08.f90`, preserve the typed MPI handles from the
Fortran 2008 binding. For example, `MPI_Alltoallw` and related nonblocking or
persistent forms use `TYPE(MPI_Datatype)` arrays for datatype arguments and
`TYPE(MPI_Comm)` for the communicator; nonblocking/persistent forms use
`TYPE(MPI_Request)`, and persistent init forms use `TYPE(MPI_Info)` where
specified. Do not replace these with plain `INTEGER` declarations.
