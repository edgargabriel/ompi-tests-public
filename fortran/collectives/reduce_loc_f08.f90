!
! Contents of this file was created by claude/sonnet from
! the corresponding C MPI test originally distributed as part of the
! MESSAGE PASSING INTERFACE TEST CASE SUITE  Copyright IBM Corp. 1995
!

program reduce_loc_test
   use mpi_f08
   implicit none

   integer, parameter :: MAXLEN = 100000
   integer :: rank, size
   integer :: ierr

   call MPI_Init(ierr)
   call MPI_Comm_rank(MPI_COMM_WORLD, rank, ierr)
   call MPI_Comm_size(MPI_COMM_WORLD, size, ierr)

   call check_2int(rank, size)

   call MPI_Finalize(ierr)

contains

   subroutine check_2int(rank, size)
      integer, intent(in) :: rank, size
      integer :: i, count, root
      integer, allocatable :: in(:,:), out(:,:)
      integer :: ierr

      allocate(in(2, MAXLEN), out(2, MAXLEN), stat=ierr)
      if (ierr /= 0) then
         write(*,*) "Doh!  Rank ", rank, " was not able to allocate enough memory.  MPI test aborted!"
         call MPI_Abort(MPI_COMM_WORLD, 1, ierr)
      end if

      count = 2000
      do while (count <= MAXLEN)
         do root = 0, size - 1
            do i = 1, count
               out(1, i) = rank
               out(2, i) = i - 1 + rank
               in(1, i) = 1
               in(2, i) = 3
            end do

            call MPI_Reduce(out, in, count, MPI_2INTEGER, MPI_MINLOC, root, &
                           MPI_COMM_WORLD, ierr)

            if (root == rank) then
               do i = 1, count
                  if (in(1, i) /= 0 .or. in(2, i) /= i - 1) then
                     write(*,*) "root ", root, ", bad answer in(", i - 1, " of ", count, ")=(", &
                               in(1, i), ",", in(2, i), ") (should be ", 0, ",", i - 1, ")"
                     call MPI_Abort(MPI_COMM_WORLD, 1, ierr)
                  end if
               end do
            end if
         end do

         count = count * 10
      end do

      deallocate(in, out)

      call MPI_Barrier(MPI_COMM_WORLD, ierr)

   end subroutine check_2int

end program reduce_loc_test
