!
! Contents of this file was created by claude/sonnet from
! the corresponding C MPI test originally distributed as part of the
! MESSAGE PASSING INTERFACE TEST CASE SUITE  Copyright IBM Corp. 1995
!

program alltoall_init_test
   use mpi_f08
   implicit none

   integer, parameter :: MAXLEN = 10000
   integer, allocatable :: out(:), in(:)
   integer :: i, j, k
   integer :: myself, tasks
   integer :: ierr
   type(MPI_Request) :: request

   call MPI_Init(ierr)
   call MPI_Comm_rank(MPI_COMM_WORLD, myself, ierr)
   call MPI_Comm_size(MPI_COMM_WORLD, tasks, ierr)

   ! Add this section because some os/architectures can't allocate
   ! this much memory on the stack

   allocate(in(MAXLEN * tasks), out(MAXLEN * tasks), stat=ierr)
   if (ierr /= 0) then
      write(*,*) "Doh!  Rank ", myself, " was not able to allocate enough memory.  MPI test aborted!"
      call MPI_Abort(MPI_COMM_WORLD, 1, ierr)
   end if

   do i = 1, MAXLEN * tasks
      out(i) = myself
   end do

   j = 1
   do while (j <= MAXLEN)

      call MPI_Alltoall_init(out, j, MPI_INTEGER, in, j, MPI_INTEGER, &
                             MPI_COMM_WORLD, MPI_INFO_NULL, request, ierr)
      call MPI_Start(request, ierr)
      call MPI_Wait(request, MPI_STATUS_IGNORE, ierr)
      call MPI_Request_free(request, ierr)

      do i = 0, tasks - 1
         do k = 1, j
            if (in(k + i * j) /= i) then
               write(*,*) "bad answer ", in(k + i * j), " at index ", k + i * j - 1, &
                         " of ", j * tasks, " (should be ", i, ")"
               call MPI_Abort(MPI_COMM_WORLD, 1, ierr)
            end if
         end do
      end do

      j = j * 10
   end do

   call MPI_Barrier(MPI_COMM_WORLD, ierr)
   call MPI_Finalize(ierr)

   ! Clean up, 'cause it's the Right Thing to do
   deallocate(in, out)

end program alltoall_init_test
