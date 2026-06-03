!
! Contents of this file was created by claude/sonnet from
! the corresponding C MPI test originally distributed as part of the
! MESSAGE PASSING INTERFACE TEST CASE SUITE  Copyright IBM Corp. 1995
!

      program barrier_init_f90
      use mpi
      implicit none

      integer i,ierr
      integer myself,tasks
      integer req(100)
      integer, dimension(MPI_STATUS_SIZE, 100) :: statuses

      call MPI_Init(ierr)
      call MPI_Comm_rank(MPI_COMM_WORLD, myself, ierr)
      call MPI_Comm_size(MPI_COMM_WORLD, tasks, ierr)

!
! Simple barrier first
!
      call MPI_Barrier_init(MPI_COMM_WORLD, MPI_INFO_NULL, req(1), ierr)
      call MPI_Start(req(1), ierr)
      call MPI_Wait(req(1), MPI_STATUS_IGNORE, ierr)
      call MPI_Request_free(req(1), ierr)

!
! Now do a bunch of pending barriers
!
      do i = 1, 100
         call MPI_Barrier_init(MPI_COMM_WORLD, MPI_INFO_NULL, req(i), ierr)
      end do
      call MPI_Startall(100, req, ierr)
      call MPI_Waitall(100, req, statuses, ierr)
      do i = 1, 100
         call MPI_Request_free(req(i), ierr)
      end do

      call MPI_Barrier(MPI_COMM_WORLD, ierr)
      call MPI_Finalize(ierr)

      end program
