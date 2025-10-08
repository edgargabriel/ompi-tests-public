!
! Copyright (c) 2004-2006 The Trustees of Indiana University and Indiana
!                         University Research and Technology
!                         Corporation.  All rights reserved.
! Copyright (c) 2004-2005 The Regents of the University of California.
!                         All rights reserved.
! Copyright (c) 2006-2015 Cisco Systems, Inc.  All rights reserved.
! Copyright (c) 2025      UT-Battelle, LLC.    All rights reserved.
! $COPYRIGHT$
!
! Tests the use of Add/Remove error_{class,code,string}.
!
program main
    use mpi
    implicit none
    integer :: ierr, rank, size, len, eclass, ecode
    integer(kind=MPI_ADDRESS_KIND) :: last
    integer(kind=MPI_ADDRESS_KIND) :: newlast
    logical :: flag
    character(len=*), parameter :: estr = "My Dummy Error String"

    call MPI_INIT(ierr)
    call MPI_COMM_RANK(MPI_COMM_WORLD, rank, ierr)
    call MPI_COMM_SIZE(MPI_COMM_WORLD, size, ierr)

    write(*, '("Hello rank: ", i2, " of ", i2)') &
          rank, size

    call MPI_COMM_GET_ATTR(MPI_COMM_WORLD, MPI_LASTUSEDCODE, last, flag, ierr)
    write(*, '("DBG last: ", i2)') &
          last

    ! Add error class/code/string
    call MPI_ADD_ERROR_CLASS(eclass, ierr)
    call MPI_ADD_ERROR_CODE(eclass, ecode, ierr)
    call MPI_ADD_ERROR_STRING(ecode, estr, ierr)

    call MPI_COMM_GET_ATTR(MPI_COMM_WORLD, MPI_LASTUSEDCODE, newlast, flag, ierr)

    ! Check that last error code increased
    if (newlast > last) then
        write(*, '("TEST: Success creating error class/code/string last: ", i2, " newlast: ", i2)') &
              last, newlast
    else
        write(*, '("Error: MPI_Add_error_xxx failed LastUsedCode not increased l ast: ", i2, " newlast: ", i2)') &
              last, newlast
    end if

    ! TODO: Remove error class/code/string

    call MPI_FINALIZE(ierr)
end
