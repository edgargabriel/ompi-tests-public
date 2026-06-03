!
! Contents of this file was created by claude/sonnet from
! the corresponding C MPI test originally distributed as part of the
! MESSAGE PASSING INTERFACE TEST CASE SUITE  Copyright IBM Corp. 1995
!

      program ibarrier
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
      call MPI_Ibarrier(MPI_COMM_WORLD, req(1), ierr)
      call MPI_Wait(req(1), MPI_STATUS_IGNORE, ierr)

!
! Now do a bunch of pending barriers
!
      do i = 1, 100
         call MPI_Ibarrier(MPI_COMM_WORLD, req(i), ierr)
      end do
      call MPI_Waitall(100, req, statuses, ierr)

      call MPI_Barrier(MPI_COMM_WORLD, ierr)
      call MPI_Finalize(ierr)

      end program
