!
! Contents of this file was created by claude/sonnet from
! the corresponding C MPI test originally distributed as part of the
! MESSAGE PASSING INTERFACE TEST CASE SUITE  Copyright IBM Corp. 1995
!

      program scan_f08
      use mpi_f08
      implicit none

      integer, parameter :: MAXLEN = 10000
      integer :: out(MAXLEN), in(MAXLEN)
      integer :: i, j, k
      integer :: myself, tasks, ierr
      integer :: expected

      call MPI_Init(ierr)
      call MPI_Comm_rank(MPI_COMM_WORLD, myself, ierr)
      call MPI_Comm_size(MPI_COMM_WORLD, tasks, ierr)

      j = 1
      do while (j <= MAXLEN)
         ! Initialize output array
         do i = 1, j
            out(i) = i - 1  ! Fortran arrays are 1-based, so subtract 1 to match C
         end do

         ! Perform scan operation
         call MPI_Scan(out, in, j, MPI_INTEGER, MPI_SUM, MPI_COMM_WORLD, ierr)

         ! Check results
         do k = 1, j
            expected = (k - 1) * (myself + 1)
            if (in(k) /= expected) then
               write(*,'(A,I0,A,I0,A,I0,A,I0,A,I0)') &
                  'ERROR: bad answer (', in(k), ') at index ', k-1, &
                  ' of ', j, ' (should be ', expected, ') on rank ', myself
               call MPI_Abort(MPI_COMM_WORLD, 1, ierr)
            end if
         end do

         j = j * 10
      end do

      call MPI_Barrier(MPI_COMM_WORLD, ierr)
      call MPI_Finalize(ierr)

      end program scan_f08
