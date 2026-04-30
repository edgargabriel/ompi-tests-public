!
! Contents of this file was created by claude/sonnet from
! the corresponding C MPI test originally distributed as part of the
! MESSAGE PASSING INTERFACE TEST CASE SUITE  Copyright IBM Corp. 1995
!
!

program iallgatherv_test
    use mpi
    implicit none

    integer, parameter :: MAXLEN = 1000
    integer, allocatable :: out(:), in(:)
    integer, allocatable :: recvcounts(:), disp(:)
    integer :: i, j, k, count
    integer :: myself, tasks, sendcount
    integer :: ierr, scan_size
    integer :: request
    character(len=256) :: error_msg

    call MPI_Init(ierr)
    call MPI_Comm_rank(MPI_COMM_WORLD, myself, ierr)
    call MPI_Comm_size(MPI_COMM_WORLD, tasks, ierr)

    ! Allocate arrays
    allocate(in(MAXLEN * (tasks + 1) * tasks / 2), stat=ierr)
    if (ierr /= 0) then
        write(error_msg, '(A,I0,A)') 'Rank ', myself, ' was not able to allocate enough memory. MPI test aborted!'
        call MPI_Abort(MPI_COMM_WORLD, 1, ierr)
    end if

    allocate(out(MAXLEN * tasks), stat=ierr)
    if (ierr /= 0) then
        write(error_msg, '(A,I0,A)') 'Rank ', myself, ' was not able to allocate enough memory. MPI test aborted!'
        call MPI_Abort(MPI_COMM_WORLD, 1, ierr)
    end if

    allocate(recvcounts(tasks), stat=ierr)
    if (ierr /= 0) then
        write(error_msg, '(A,I0,A)') 'Rank ', myself, ' was not able to allocate enough memory. MPI test aborted!'
        call MPI_Abort(MPI_COMM_WORLD, 1, ierr)
    end if

    allocate(disp(tasks), stat=ierr)
    if (ierr /= 0) then
        write(error_msg, '(A,I0,A)') 'Rank ', myself, ' was not able to allocate enough memory. MPI test aborted!'
        call MPI_Abort(MPI_COMM_WORLD, 1, ierr)
    end if

    ! Initialize out array
    do i = 1, MAXLEN * tasks
        out(i) = 1
    end do

    j = 1
    do while (j <= MAXLEN)
        scan_size = 0
        do i = 0, tasks - 1
            disp(i + 1) = scan_size
            recvcounts(i + 1) = j * (i + 1)
            scan_size = scan_size + recvcounts(i + 1)
        end do
        sendcount = recvcounts(myself + 1)
        
        do k = 1, sendcount
            out(k) = myself
        end do

        call MPI_Iallgatherv(out, sendcount, MPI_INTEGER, in, recvcounts, disp, MPI_INTEGER, &
                            MPI_COMM_WORLD, request, ierr)
        call MPI_Wait(request, MPI_STATUS_IGNORE, ierr)

        count = 1
        do k = 0, tasks - 1
            do i = 1, j * (k + 1)
                if (in(count) /= k) then
                    write(error_msg, '(A,I0,A,I0,A,I0,A,I0,A)') &
                        'bad answer (', in(count), ') at index ', count, &
                        ' of ', j * tasks, ' (should be ', k, ')'
                    call MPI_Abort(MPI_COMM_WORLD, 1, ierr)
                end if
                count = count + 1
            end do
        end do

        j = j * 10
    end do

    call MPI_Barrier(MPI_COMM_WORLD, ierr)
    call MPI_Finalize(ierr)

    deallocate(in)
    deallocate(out)
    deallocate(recvcounts)
    deallocate(disp)

end program iallgatherv_test
