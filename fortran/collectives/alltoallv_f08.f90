!
! Contents of this file was created by claude/sonnet from
! the corresponding C MPI test originally distributed as part of the
! MESSAGE PASSING INTERFACE TEST CASE SUITE  Copyright IBM Corp. 1995
!

program alltoallv_test
   use mpi_f08
   implicit none

   type(MPI_Comm) :: comm
   integer, allocatable :: sbuf(:), rbuf(:)
   integer :: rank, size
   integer, allocatable :: sendcounts(:), recvcounts(:), rdispls(:), sdispls(:)
   integer :: i, j
   integer :: ierr

   call MPI_Init(ierr)

   comm = MPI_COMM_WORLD

   ! Create the buffer
   call MPI_Comm_size(comm, size, ierr)
   call MPI_Comm_rank(comm, rank, ierr)

   allocate(sbuf(size * size), rbuf(size * size), stat=ierr)
   if (ierr /= 0) then
      write(*,*) "Doh!  Rank ", rank, " was not able to allocate enough memory.  MPI test aborted!"
      call MPI_Abort(MPI_COMM_WORLD, 1, ierr)
   end if

   ! Load up the buffers
   do i = 1, size * size
      sbuf(i) = i - 1 + 100 * rank
      rbuf(i) = -(i - 1)
   end do

   ! Create and load the arguments to alltoallv
   allocate(sendcounts(size), recvcounts(size), rdispls(size), sdispls(size), stat=ierr)
   if (ierr /= 0) then
      write(*,*) "Doh!  Rank ", rank, " was not able to allocate enough memory.  MPI test aborted!"
      call MPI_Abort(MPI_COMM_WORLD, 1, ierr)
   end if

   do i = 1, size
      sendcounts(i) = i - 1
      recvcounts(i) = rank
      rdispls(i) = (i - 1) * rank
      sdispls(i) = ((i - 1) * i) / 2
   end do

   call MPI_Alltoallv(sbuf, sendcounts, sdispls, MPI_INTEGER, &
                      rbuf, recvcounts, rdispls, MPI_INTEGER, comm, ierr)

   ! Check rbuf
   do i = 1, size
      do j = 1, rank
         if (rbuf(rdispls(i) + j) /= (i - 1) * 100 + (rank * (rank + 1)) / 2 + j - 1) then
            write(*,*) "bad answer (", rbuf(rdispls(i) + j), ") (should be ", &
                      (i - 1) * 100 + (rank * (rank + 1)) / 2 + j - 1, ")"
            call MPI_Abort(MPI_COMM_WORLD, 1, ierr)
         end if
      end do
   end do

   deallocate(sdispls, rdispls, recvcounts, sendcounts, rbuf, sbuf)

   call MPI_Barrier(MPI_COMM_WORLD, ierr)
   call MPI_Finalize(ierr)

end program alltoallv_test
