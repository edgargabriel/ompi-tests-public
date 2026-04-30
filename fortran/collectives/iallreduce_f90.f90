!
! Contents of this file was created by claude/sonnet from
! the corresponding C MPI test originally distributed as part of the
! MESSAGE PASSING INTERFACE TEST CASE SUITE  Copyright IBM Corp. 1995
!
!
program iallreduce_test
   use mpi
   implicit none

   integer, parameter :: MAXLEN = 100000
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
   allocate(in(MAXLEN))
   allocate(out(MAXLEN))

   ! Test with various sizes: j = 1, 10, 100, 1000, 10000, 100000
   j = 1
   do while (j <= MAXLEN)
      ! Initialize out array with values 0, 1, 2, 3, ...
      do i = 1, j
         out(i) = i - 1  ! Use 0-based values like C
      end do

      ! Perform non-blocking allreduce
      call MPI_Iallreduce(out, in, j, MPI_INTEGER, MPI_SUM, &
                          MPI_COMM_WORLD, request, ierr)
      call MPI_Wait(request, MPI_STATUS_IGNORE, ierr)

      ! Verify results
      ! Each process contributes k, so sum across all processes is k * tasks
      do k = 1, j
         if (in(k) /= (k - 1) * tasks) then
            write(error_msg, '(A,I0,A,I0,A,I0,A,I0,A)') &
               'bad answer (', in(k), ') at index ', k, ' of ', j, &
               ' (should be ', (k - 1) * tasks, ')'
            print *,error_msg
            call MPI_Abort(MPI_COMM_WORLD, -1, ierr)
         end if
      end do

      j = j * 10
   end do

   ! Clean up
   deallocate(in)
   deallocate(out)

   call MPI_Barrier(MPI_COMM_WORLD, ierr)
   call MPI_Finalize(ierr)

end program iallreduce_test
