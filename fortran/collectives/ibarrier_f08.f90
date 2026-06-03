!
! Contents of this file was created by claude/sonnet from
! the corresponding C MPI test originally distributed as part of the
! MESSAGE PASSING INTERFACE TEST CASE SUITE  Copyright IBM Corp. 1995
!

      program ibarrier
      use mpi_f08
      implicit none

      integer i
      integer myself,tasks
      type(MPI_Request) req(100)

      call MPI_Init()
      call MPI_Comm_rank(MPI_COMM_WORLD, myself)
      call MPI_Comm_size(MPI_COMM_WORLD, tasks)

!
! Simple barrier first
!
      call MPI_Ibarrier(MPI_COMM_WORLD, req(1))
      call MPI_Wait(req(1), MPI_STATUS_IGNORE)

!
! Now do a bunch of pending barriers
!
      do i = 1, 100
         call MPI_Ibarrier(MPI_COMM_WORLD, req(i))
      end do
      call MPI_Waitall(100, req, MPI_STATUSES_IGNORE)

      call MPI_Barrier(MPI_COMM_WORLD)
      call MPI_Finalize()

      end program
