!
! Contents of this file was created by claude/sonnet from
! the corresponding C MPI test originally distributed as part of the
! MESSAGE PASSING INTERFACE TEST CASE SUITE  Copyright IBM Corp. 1995
!

program reduce_scatter_block_init_test
   use mpi_f08
   implicit none

   integer, parameter :: MAXLEN = 1000
   integer, allocatable :: out(:), in(:)
   integer :: i, j, k
   integer :: myself, tasks, recvcount
   type(MPI_Request) :: request
   integer :: ierr

   call MPI_Init(ierr)
   call MPI_Comm_rank(MPI_COMM_WORLD, myself, ierr)
   call MPI_Comm_size(MPI_COMM_WORLD, tasks, ierr)

   ! Allocate memory
   allocate(in(MAXLEN * tasks), out(MAXLEN * tasks * tasks), stat=ierr)
   if (ierr /= 0) then
      write(*,*) "Doh!  Rank ", myself, " was not able to allocate enough memory.  MPI test aborted!"
      call MPI_Abort(MPI_COMM_WORLD, 1, ierr)
   end if

   do i = 1, MAXLEN * tasks
      out(i) = 1
   end do

   j = 1
   do while (j <= MAXLEN * tasks)
      recvcount = j
      do i = 1, j * tasks
         out(i) = i - 1
      end do

      call MPI_Reduce_scatter_block_init(out, in, recvcount, MPI_INTEGER, MPI_SUM, &
                                         MPI_COMM_WORLD, MPI_INFO_NULL, request, ierr)
      call MPI_Start(request, ierr)
      call MPI_Wait(request, MPI_STATUS_IGNORE, ierr)

      do k = 1, j
         if (in(k) /= tasks * (myself * j + k - 1)) then
            write(*,*) "bad answer (", in(k), ") at index ", k - 1, " of ", j, &
                      " (should be ", tasks * (myself * j + k - 1), ")"
            call MPI_Abort(MPI_COMM_WORLD, 1, ierr)
         end if
      end do

      j = j * 10
   end do

   call MPI_Barrier(MPI_COMM_WORLD, ierr)
   call MPI_Finalize(ierr)

   deallocate(in, out)

end program reduce_scatter_block_init_test
