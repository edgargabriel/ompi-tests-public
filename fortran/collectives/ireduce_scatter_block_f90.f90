!
! Contents of this file was created by claude/sonnet from
! the corresponding C MPI test originally distributed as part of the
! MESSAGE PASSING INTERFACE TEST CASE SUITE  Copyright IBM Corp. 1995
!

program ireduce_scatter_block_test
   use mpi
   implicit none

   integer, parameter :: MAXLEN = 1000
   integer, allocatable :: out(:), in(:)
   integer :: i, j, k
   integer :: myself, tasks, recvcount
   integer :: ierr
   integer :: request
   character(len=256) :: error_msg

   call MPI_Init(ierr)
   call MPI_Comm_rank(MPI_COMM_WORLD, myself, ierr)
   call MPI_Comm_size(MPI_COMM_WORLD, tasks, ierr)

   ! Allocate arrays
   allocate(in(MAXLEN * tasks))
   allocate(out(MAXLEN * tasks * tasks))

   ! Initialize out array
   do i = 1, MAXLEN * tasks
      out(i) = 1
   end do

   ! Test with various sizes: j = 1, 10, 100, 1000, etc.
   j = 1
   do while (j <= MAXLEN * tasks)
      recvcount = j

      ! Initialize out array with values 0, 1, 2, 3, ... (converted to 1-based)
      do i = 1, j * tasks
         out(i) = i - 1  ! Use 0-based values like C
      end do

      ! Perform non-blocking reduce scatter block
      call MPI_Ireduce_scatter_block(out, in, recvcount, MPI_INTEGER, &
                                      MPI_SUM, MPI_COMM_WORLD, request, ierr)
      call MPI_Wait(request, MPI_STATUS_IGNORE, ierr)

      ! Verify results
      do k = 1, j
         ! Expected value: tasks * (myself*j + (k-1))
         ! in(k) should equal sum of out[myself*j + k-1] across all processes
         if (in(k) /= tasks * (myself * j + k - 1)) then
            write(error_msg, '(A,I0,A,I0,A,I0,A,I0,A)') &
               'bad answer (', in(k), ') at index ', k, ' of ', j, &
               ' (should be ', tasks * (myself * j + k - 1), ')'
            print *,error_msg
            call MPI_Abort(MPI_COMM_WORLD, -1, ierr)
         end if
      end do

      j = j * 10
   end do

   call MPI_Barrier(MPI_COMM_WORLD, ierr)
   call MPI_Finalize(ierr)

   ! Clean up
   deallocate(in)
   deallocate(out)

end program ireduce_scatter_block_test
