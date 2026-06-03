!
! Contents of this file was created by claude/sonnet from
! the corresponding C MPI test originally distributed as part of the
! MESSAGE PASSING INTERFACE TEST CASE SUITE  Copyright IBM Corp. 1995
!

      program ibcast
      use mpi_f08
      implicit none

      integer count, root, i,j,k
      integer myself,tasks
      integer out(10001)
      type(MPI_Request) req(100)

      call MPI_Init()
      call MPI_Comm_rank(MPI_COMM_WORLD, myself)
      call MPI_Comm_size(MPI_COMM_WORLD, tasks)

      root = tasks-1;
      count = 1
      do j = 1, 10001, 1000
         do i = 1, j
            if (myself .eq. root) then
               out(i) = i
            else
               out(i) = -1
            end if
         end do

         call MPI_Ibcast(out,j,MPI_INTEGER,root,MPI_COMM_WORLD, req(1))
         call MPI_Wait(req(1), MPI_STATUS_IGNORE)

         do k = 1, j
            if (out(k) .ne. k) then
               print *,'bad answer in reduce buffer'
               call MPI_Abort(MPI_COMM_WORLD, -1)
            end if
         end do
      end do

      call MPI_Barrier(MPI_COMM_WORLD)
      call MPI_Finalize()

      end program
