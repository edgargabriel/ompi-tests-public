!
! Contents of this file was created by claude/sonnet from
! the corresponding C MPI test originally distributed as part of the
! MESSAGE PASSING INTERFACE TEST CASE SUITE  Copyright IBM Corp. 1995
!

program alltoallw_init_test
   use mpi_f08
   implicit none

   type(MPI_Comm) :: comm
   integer, allocatable :: sbuf(:), rbuf(:)
   integer :: rank, size
   integer(kind=MPI_ADDRESS_KIND) :: lb, extent
   integer, allocatable :: sendcounts(:), recvcounts(:), rdispls(:), sdispls(:)
   integer :: i, j
   integer, pointer :: p
   type(MPI_Datatype), allocatable :: sdtypes(:), rdtypes(:)
   type(MPI_Request) :: req
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

   ! Create and load the arguments to alltoallw
   allocate(sendcounts(size), recvcounts(size), rdispls(size), sdispls(size), stat=ierr)
   allocate(sdtypes(size), rdtypes(size), stat=ierr)
   if (ierr /= 0) then
      write(*,*) "Doh!  Rank ", rank, " was not able to allocate enough memory.  MPI test aborted!"
      call MPI_Abort(MPI_COMM_WORLD, 1, ierr)
   end if

   call MPI_Type_get_extent(MPI_INTEGER, lb, extent, ierr)

   do i = 1, size
      sendcounts(i) = i - 1
      recvcounts(i) = rank
      rdispls(i) = (i - 1) * rank * extent
      sdispls(i) = ((i - 1) * i) / 2 * extent
      sdtypes(i) = MPI_INTEGER
      rdtypes(i) = MPI_INTEGER
   end do

   call MPI_Alltoallw_init(sbuf, sendcounts, sdispls, sdtypes, &
                           rbuf, recvcounts, rdispls, rdtypes, comm, MPI_INFO_NULL, req, ierr)
   call MPI_Start(req, ierr)
   call MPI_Wait(req, MPI_STATUS_IGNORE, ierr)
   call MPI_Request_free(req, ierr)

   ! Check rbuf
   do i = 1, size
      do j = 1, rank
         if (rbuf(rdispls(i) / extent + j) /= (i - 1) * 100 + (rank * (rank + 1)) / 2 + j - 1) then
            write(*,*) "bad answer (", rbuf(rdispls(i) / extent + j), ") (should be ", &
                      (i - 1) * 100 + (rank * (rank + 1)) / 2 + j - 1, ")"
            call MPI_Abort(MPI_COMM_WORLD, 1, ierr)
         end if
      end do
   end do

   deallocate(sdispls, rdispls, sdtypes, rdtypes, recvcounts, sendcounts, rbuf, sbuf)

   call MPI_Barrier(MPI_COMM_WORLD, ierr)
   call MPI_Finalize(ierr)

end program alltoallw_init_test
