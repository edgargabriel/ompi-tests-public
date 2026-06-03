!
! Contents of this file was created by claude/sonnet from
! the corresponding C MPI test originally distributed as part of the
! MESSAGE PASSING INTERFACE TEST CASE SUITE  Copyright IBM Corp. 1995
!

program allgatherv_test
   use mpi
   implicit none

   integer, parameter :: MAXLEN = 1000
   integer, allocatable :: out(:), in(:)
   integer, allocatable :: recvcounts(:), disp(:)
   integer :: i, j, k, count
   integer :: myself, tasks, sendcount
   integer :: scan_size
   integer :: ierr

   call MPI_Init(ierr)
   call MPI_Comm_rank(MPI_COMM_WORLD, myself, ierr)
   call MPI_Comm_size(MPI_COMM_WORLD, tasks, ierr)

   allocate(in(MAXLEN * (tasks+1) * tasks / 2), out(MAXLEN * tasks), stat=ierr)
   allocate(recvcounts(tasks), disp(tasks), stat=ierr)
   if (ierr /= 0) then
      write(*,*) "Doh!  Rank ", myself, " was not able to allocate enough memory.  MPI test aborted!"
      call MPI_Abort(MPI_COMM_WORLD, 1, ierr)
   end if

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

      call MPI_Allgatherv(out, sendcount, MPI_INTEGER, in, recvcounts, disp, &
                          MPI_INTEGER, MPI_COMM_WORLD, ierr)

      count = 1
      do k = 0, tasks - 1
         do i = 1, j * (k + 1)
            if (in(count) /= k) then
               write(*,*) "bad answer (", in(count), ") at index ", count - 1, &
                         " of ", j * tasks, " (should be ", k, ")"
               call MPI_Abort(MPI_COMM_WORLD, 1, ierr)
            end if
            count = count + 1
         end do
      end do

      j = j * 10
   end do

   call MPI_Barrier(MPI_COMM_WORLD, ierr)
   call MPI_Finalize(ierr)

   ! Clean up, 'cause it's the Right Thing to do
   deallocate(in, out, recvcounts, disp)

end program allgatherv_test
