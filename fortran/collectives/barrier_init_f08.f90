!
! Contents of this file was created by claude/sonnet from
! the corresponding C MPI test originally distributed as part of the
! MESSAGE PASSING INTERFACE TEST CASE SUITE  Copyright IBM Corp. 1995
!

      program barrier_init_f08
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
      call MPI_Barrier_init(MPI_COMM_WORLD, MPI_INFO_NULL, req(1))
      call MPI_Start(req(1))
      call MPI_Wait(req(1), MPI_STATUS_IGNORE)
      call MPI_Request_free(req(1))

!
! Now do a bunch of pending barriers
!
      do i = 1, 100
         call MPI_Barrier_init(MPI_COMM_WORLD, MPI_INFO_NULL, req(i))
      end do
      call MPI_Startall(100, req)
      call MPI_Waitall(100, req, MPI_STATUSES_IGNORE)
      do i = 1, 100
         call MPI_Request_free(req(i))
      end do

      call MPI_Barrier(MPI_COMM_WORLD)
      call MPI_Finalize()

      end program
