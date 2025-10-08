! -*- f90 -*-
!
! Copyright (c) 2025      UT-Battelle, LLC.    All rights reserved.
!
! Tests for MPI_LASTUSEDCODE, MPI_Add_error_{class,code,string}, and
! MPI_Remove_error{class,code,string}.
!
! File: test_add_del_err_codes_usempif08.f90
!
! Referenced examples online and in ompi-tests:
!  - "ompi-tests/random/add_error_class.c"
!  - example from Lisandro Dalcin
!    https://www.open-mpi.org/community/lists/devel/2014/04/14578.php
!
program main
    use mpi_f08
    implicit none
    integer :: rank, size, eclass, ecode, ierr
    integer(kind=MPI_ADDRESS_KIND) :: last
    integer(kind=MPI_ADDRESS_KIND) :: newlast
    logical :: flag
    character(len=*), parameter :: estr = "My Dummy Error String"

    call MPI_INIT(ierr)
    if (ierr /= MPI_SUCCESS) then
        write(*,*) 'Error: MPI_INIT failed (ierr=', ierr, ')'
        stop 1
    end if

    call MPI_COMM_RANK(MPI_COMM_WORLD, rank, ierr)
    if (ierr /= MPI_SUCCESS) then
        write(*,*) 'Error: MPI_COMM_RANK failed (ierr=', ierr, ')'
        stop 1
    end if

    call MPI_COMM_SIZE(MPI_COMM_WORLD, size, ierr)
    if (ierr /= MPI_SUCCESS) then
        write(*,*) 'Error: MPI_COMM_SIZE failed (ierr=', ierr, ')'
        stop 1
    end if

    write(*, '("Hello rank: ", i2, " of ", i2)') &
          rank, size

    call MPI_COMM_GET_ATTR(MPI_COMM_WORLD, MPI_LASTUSEDCODE, last, flag, ierr)
    if (ierr /= MPI_SUCCESS) then
        write(*,*) 'Error: MPI_COMM_GET_ATTR failed (ierr=', ierr, ')'
        stop 1
    end if
    write(*, '("DBG last: ", i0)') &
          last
    ! Add error class/code/string
    call MPI_ADD_ERROR_CLASS(eclass, ierr)
    if (ierr /= MPI_SUCCESS) then
        write(*,*) 'Error: MPI_ADD_ERROR_CLASS failed (ierr=', ierr, ')'
        stop 1
    end if

    call MPI_ADD_ERROR_CODE(eclass, ecode, ierr)
    if (ierr /= MPI_SUCCESS) then
        write(*,*) 'Error: MPI_ADD_ERROR_CODE failed (ierr=', ierr, ')'
        stop 1
    end if

    call MPI_ADD_ERROR_STRING(ecode, estr, ierr)
    if (ierr /= MPI_SUCCESS) then
        write(*,*) 'Error: MPI_ADD_ERROR_STRING failed (ierr=', ierr, ')'
        stop 1
    end if

    call MPI_COMM_GET_ATTR(MPI_COMM_WORLD, MPI_LASTUSEDCODE, newlast, flag, ierr)
    if (ierr /= MPI_SUCCESS) then
        write(*,*) 'Error: MPI_COMM_GET_ATTR failed (ierr=', ierr, ')'
        stop 1
    end if

    ! Check that last error code increased
    if (newlast > last) then
        write(*, '("TEST: Success creating error class/code/string last: ", i0, " newlast: ", i0)') &
              last, newlast
    else
        write(*, '("Error: MPI_Add_error_xxx failed LastUsedCode not increased l ast: ", i0, " newlast: ", i0)') &
              last, newlast
    end if

    write(*,*) '==== Adds done ===='

    ! Remove error string
    write(*,*) '==== Remove estring ===='
    call MPI_REMOVE_ERROR_STRING(ecode, ierr)
    if (ierr /= MPI_SUCCESS) then
        write(*,*) 'Error: MPI_REMOVE_ERROR_STRING failed (ierr=', ierr, ')'
        stop 1
    end if
    write(*,*) 'TEST: Success removing error string'

    ! Remove error code
    write(*,*) '==== Remove ecode ===='
    call MPI_COMM_GET_ATTR(MPI_COMM_WORLD, MPI_LASTUSEDCODE, last, flag, ierr)
    if (ierr /= MPI_SUCCESS) then
        write(*,*) 'Error: MPI_COMM_GET_ATTR failed (ierr=', ierr, ')'
        stop 1
    end if

    call MPI_REMOVE_ERROR_CODE(ecode, ierr)
    if (ierr /= MPI_SUCCESS) then
        write(*,*) 'Error: MPI_REMOVE_ERROR_CODE failed (ierr=', ierr, ')'
        stop 1
    end if

    call MPI_COMM_GET_ATTR(MPI_COMM_WORLD, MPI_LASTUSEDCODE, newlast, flag, ierr)
    if (ierr /= MPI_SUCCESS) then
        write(*,*) 'Error: MPI_COMM_GET_ATTR failed (ierr=', ierr, ')'
        stop 1
    end if

    ! Check that last error code decreased
    if (newlast < last) then
        write(*, '("TEST: Success removed error code last: ", i0, " newlast: ", i0)') &
              last, newlast
    else
        write(*, '("Error: MPI_REMOVE_ERROR_CODE failed LastUsedCode not decreas ed last: ", i0, " newlast: ", i0)') &
              last, newlast
    end if

    ! Remove error class
    write(*,*) '==== Remove eclass ===='
    call MPI_COMM_GET_ATTR(MPI_COMM_WORLD, MPI_LASTUSEDCODE, last, flag, ierr)
    if (ierr /= MPI_SUCCESS) then
        write(*,*) 'Error: MPI_COMM_GET_ATTR failed (ierr=', ierr, ')'
        stop 1
    end if

    call MPI_REMOVE_ERROR_CLASS(eclass, ierr)
    if (ierr /= MPI_SUCCESS) then
        write(*,*) 'Error: MPI_REMOVE_ERROR_CLASS failed (ierr=', ierr, ')'
        stop 1
    end if

    call MPI_COMM_GET_ATTR(MPI_COMM_WORLD, MPI_LASTUSEDCODE, newlast, flag, ierr)
    if (ierr /= MPI_SUCCESS) then
        write(*,*) 'Error: MPI_COMM_GET_ATTR failed (ierr=', ierr, ')'
        stop 1
    end if


    ! Check that last error code decreased
    if (newlast < last) then
        write(*, '("TEST: Success removed error class last: ", i0, " newlast: ", i0)') &
              last, newlast
    else
        write(*, '("Error: MPI_REMOVE_ERROR_CLASS failed LastUsedCode not decreased last: ", i0, " newlast: ", i0)') &
              last, newlast
    end if

    call MPI_FINALIZE(ierr)
    if (ierr /= MPI_SUCCESS) then
        write(*,*) 'Error: MPI_FINALIZE failed (ierr=', ierr, ')'
        stop 1
    end if
end

