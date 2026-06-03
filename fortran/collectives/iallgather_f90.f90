!
! Contents of this file was created by claude/sonnet from
! the corresponding C MPI test originally distributed as part of the
! MESSAGE PASSING INTERFACE TEST CASE SUITE  Copyright IBM Corp. 1995
!

program iallgather_test
    use mpi
    implicit none

    integer, parameter :: MAXLEN = 1000
    integer, allocatable :: out(:), in(:)
    integer :: i, j, k
    integer :: myself, tasks
    integer :: ierr
    integer :: request
    character(len=256) :: error_msg

    call MPI_Init(ierr)
    call MPI_Comm_rank(MPI_COMM_WORLD, myself, ierr)
    call MPI_Comm_size(MPI_COMM_WORLD, tasks, ierr)

    ! Allocate arrays
    allocate(out(MAXLEN), stat=ierr)
    if (ierr /= 0) then
        write(error_msg, '(A,I0,A)') 'Rank ', myself, ' was not able to allocate enough memory. MPI test aborted!'
        call MPI_Abort(MPI_COMM_WORLD, 1, ierr)
    end if

    allocate(in(MAXLEN * tasks), stat=ierr)
    if (ierr /= 0) then
        write(error_msg, '(A,I0,A)') 'Rank ', myself, ' was not able to allocate enough memory. MPI test aborted!'
        call MPI_Abort(MPI_COMM_WORLD, 1, ierr)
    end if

    j = 1
    do while (j <= MAXLEN)
        do i = 1, j
            out(i) = myself
        end do

        call MPI_Iallgather(out, j, MPI_INTEGER, in, j, MPI_INTEGER, MPI_COMM_WORLD, request, ierr)
        call MPI_Wait(request, MPI_STATUS_IGNORE, ierr)

        do i = 0, tasks - 1
            do k = 1, j
                if (in(k + i * j) /= i) then
                    write(error_msg, '(A,I0,A,I0,A,I0,A,I0,A)') &
                        'bad answer (', in(k + i * j), ') at index ', k + i * j, &
                        ' of ', j * tasks, ' (should be ', i, ')'
                    call MPI_Abort(MPI_COMM_WORLD, 1, ierr)
                end if
            end do
        end do

        j = j * 10
    end do

    call MPI_Barrier(MPI_COMM_WORLD, ierr)
    call MPI_Finalize(ierr)

    deallocate(in)
    deallocate(out)

end program iallgather_test
