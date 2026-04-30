!
! Contents of this file was created by claude/sonnet from
! the corresponding C MPI test originally distributed as part of the
! MESSAGE PASSING INTERFACE TEST CASE SUITE  Copyright IBM Corp. 1995
!

program reduce_test
   use mpi_f08
   implicit none

   integer, parameter :: MAXLEN = 10000
   integer :: root, out(MAXLEN), in(MAXLEN), i, j, k
   integer :: myself, tasks
   integer :: ierr

   call MPI_Init(ierr)
   call MPI_Comm_rank(MPI_COMM_WORLD, myself, ierr)
   call MPI_Comm_size(MPI_COMM_WORLD, tasks, ierr)
   root = tasks / 2

   j = 1
   do while (j <= MAXLEN)
      do i = 1, j
         out(i) = i - 1
      end do

      call MPI_Reduce(out, in, j, MPI_INTEGER, MPI_SUM, root, MPI_COMM_WORLD, ierr)

      if (myself == root) then
         do k = 1, j
            if (in(k) /= (k - 1) * tasks) then
               write(*,*) "bad answer (", in(k), ") at index ", k - 1, " of ", j, &
                         " (should be ", (k - 1) * tasks, ")"
               call MPI_Abort(MPI_COMM_WORLD, 1, ierr)
            end if
         end do
      end if

      j = j * 10
   end do

   call MPI_Barrier(MPI_COMM_WORLD, ierr)
   call MPI_Finalize(ierr)

end program reduce_test
