!
! Contents of this file was created by claude/sonnet from
! the corresponding C MPI test originally distributed as part of the
! MESSAGE PASSING INTERFACE TEST CASE SUITE  Copyright IBM Corp. 1995
!

program iscatter_test
   use mpi
   implicit none

   integer, parameter :: MAXLEN = 10000
   integer, allocatable :: out(:), in(:)
   integer :: root, i, j, k
   integer :: myself, tasks
   integer :: request
   integer :: ierr

   call MPI_Init(ierr)
   call MPI_Comm_rank(MPI_COMM_WORLD, myself, ierr)
   call MPI_Comm_size(MPI_COMM_WORLD, tasks, ierr)

   ! Add this section because some os/architectures can't allocate
   ! this much memory on the stack
   allocate(in(MAXLEN), out(MAXLEN * tasks), stat=ierr)
   if (ierr /= 0) then
      write(*,*) "Doh!  Rank ", myself, " was not able to allocate enough memory.  MPI test aborted!"
      call MPI_Abort(MPI_COMM_WORLD, 1, ierr)
   end if

   j = 1
   root = 0
   do while (j <= MAXLEN)
      if (myself == root) then
         do i = 1, j * tasks
            out(i) = i - 1
         end do
      end if

      call MPI_Iscatter(out, j, MPI_INTEGER, in, j, MPI_INTEGER, root, &
                        MPI_COMM_WORLD, request, ierr)
      call MPI_Wait(request, MPI_STATUS_IGNORE, ierr)

      do k = 1, j
         if (in(k) /= k - 1 + myself * j) then
            write(*,*) "task ", myself, ": bad answer (", in(k), ") at index ", k - 1, &
                      " of ", j, " (should be ", k - 1 + myself * j, ")"
            call MPI_Abort(MPI_COMM_WORLD, 1, ierr)
         end if
      end do

      j = j * 10
      root = mod(root + 1, tasks)
   end do

   call MPI_Barrier(MPI_COMM_WORLD, ierr)
   call MPI_Finalize(ierr)

   ! Clean up, 'cause it's the Right Thing to do
   deallocate(in, out)

end program iscatter_test
