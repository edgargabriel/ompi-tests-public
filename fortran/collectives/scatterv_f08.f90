!
! Contents of this file was created by claude/sonnet from
! the corresponding C MPI test originally distributed as part of the
! MESSAGE PASSING INTERFACE TEST CASE SUITE  Copyright IBM Corp. 1995
!
!

program scatterv_test
    use mpi_f08
    implicit none

    integer, parameter :: MAXLEN = 10000
    integer, allocatable :: out(:), in(:)
    integer, allocatable :: displs(:), rcounts(:)
    integer :: root, i, j, k
    integer :: myself, tasks
    integer :: ierr
    character(len=256) :: error_msg

    call MPI_Init(ierr)
    call MPI_Comm_rank(MPI_COMM_WORLD, myself, ierr)
    call MPI_Comm_size(MPI_COMM_WORLD, tasks, ierr)

    ! Allocate arrays
    allocate(in(MAXLEN), stat=ierr)
    if (ierr /= 0) then
        write(error_msg, '(A,I0,A)') 'Rank ', myself, ' was not able to allocate enough memory. MPI test aborted!'
        call MPI_Abort(MPI_COMM_WORLD, 1, ierr)
    end if

    allocate(out(MAXLEN * tasks), stat=ierr)
    if (ierr /= 0) then
        write(error_msg, '(A,I0,A)') 'Rank ', myself, ' was not able to allocate enough memory. MPI test aborted!'
        call MPI_Abort(MPI_COMM_WORLD, 1, ierr)
    end if

    allocate(displs(tasks), stat=ierr)
    if (ierr /= 0) then
        write(error_msg, '(A,I0,A)') 'Rank ', myself, ' was not able to allocate enough memory. MPI test aborted!'
        call MPI_Abort(MPI_COMM_WORLD, 1, ierr)
    end if

    allocate(rcounts(tasks), stat=ierr)
    if (ierr /= 0) then
        write(error_msg, '(A,I0,A)') 'Rank ', myself, ' was not able to allocate enough memory. MPI test aborted!'
        call MPI_Abort(MPI_COMM_WORLD, 1, ierr)
    end if

    j = 1
    root = 0
    do while (j <= MAXLEN)
        if (myself == root) then
            do i = 1, j * tasks
                out(i) = i - 1
            end do

            do i = 0, tasks - 1
                rcounts(i + 1) = j
                displs(i + 1) = i * j
            end do
        end if

        call MPI_Scatterv(out, rcounts, displs, MPI_INTEGER, in, j, MPI_INTEGER, root, &
                         MPI_COMM_WORLD, ierr)

        do k = 1, j
            if (in(k) /= k - 1 + myself * j) then
                write(error_msg, '(A,I0,A,I0,A,I0,A,I0,A,I0,A)') &
                    'task ', myself, ': bad answer (', in(k), ') at index ', k, &
                    ' of ', j, ' (should be ', k - 1 + myself * j, ')'
                call MPI_Abort(MPI_COMM_WORLD, 1, ierr)
            end if
        end do

        j = j * 10
        root = mod(root + 1, tasks)
    end do

    call MPI_Barrier(MPI_COMM_WORLD, ierr)
    call MPI_Finalize(ierr)

    deallocate(in)
    deallocate(out)
    deallocate(displs)
    deallocate(rcounts)

end program scatterv_test
