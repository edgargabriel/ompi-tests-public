!
! Contents of this file was created by claude/sonnet from
! the corresponding C MPI test originally distributed as part of the
! MESSAGE PASSING INTERFACE TEST CASE SUITE  Copyright IBM Corp. 1995
!


      program ireduce_scatter
      use mpi_f08
      implicit none

      integer, parameter :: MAXLEN = 1000
      integer, allocatable :: out(:), in(:), recvcounts(:)
      integer :: i, j, k
      integer :: myself, tasks
      integer :: expected
      type(MPI_Request) :: request

      call MPI_Init()
      call MPI_Comm_rank(MPI_COMM_WORLD, myself)
      call MPI_Comm_size(MPI_COMM_WORLD, tasks)

      ! Allocate arrays
      allocate(in(MAXLEN * tasks))
      allocate(out(MAXLEN * tasks * tasks))
      allocate(recvcounts(tasks))

      ! Initialize out array
      do i = 1, MAXLEN * tasks
         out(i) = 1
      end do

      ! Loop over different sizes
      j = 1
      do while (j .le. MAXLEN * tasks)
         ! Set recvcounts for all processes
         do i = 1, tasks
            recvcounts(i) = j
         end do

         ! Initialize output array with indices (0-based in C, but we use 1-based values minus 1)
         do i = 1, j * tasks
            out(i) = i - 1
         end do

         ! Perform non-blocking reduce_scatter
         call MPI_Ireduce_scatter(out, in, recvcounts, MPI_INTEGER, &
                                  MPI_SUM, MPI_COMM_WORLD, request)
         call MPI_Wait(request, MPI_STATUS_IGNORE)

         ! Check results
         do k = 1, j
            expected = tasks * (myself * j + k - 1)
            if (in(k) .ne. expected) then
               print *,'bad answer in ireduce_scatter'
               call MPI_Abort(MPI_COMM_WORLD, -1)
            end if
         end do

         ! Multiply j by 10 for next iteration
         j = j * 10
      end do

      call MPI_Barrier(MPI_COMM_WORLD)
      call MPI_Finalize()

      ! Deallocate arrays
      deallocate(in)
      deallocate(out)
      deallocate(recvcounts)

      end program
