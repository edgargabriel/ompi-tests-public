!
! Contents of this file was created by claude/sonnet from
! the corresponding C MPI test originally distributed as part of the
! MESSAGE PASSING INTERFACE TEST CASE SUITE  Copyright IBM Corp. 1995
!

      program gatherv_init_f90
      use mpi
      implicit none

      integer, parameter :: MAXLEN = 10000
      integer, allocatable :: out(:), in(:)
      integer, allocatable :: displs(:), rcounts(:)
      integer :: i, j, k, root
      integer :: myself, tasks, ierr
      integer :: alloc_stat
      integer :: request

      call MPI_Init(ierr)
      call MPI_Comm_rank(MPI_COMM_WORLD, myself, ierr)
      call MPI_Comm_size(MPI_COMM_WORLD, tasks, ierr)

      ! Allocate arrays
      allocate(in(MAXLEN * tasks), out(MAXLEN * tasks), &
               displs(tasks), rcounts(tasks), stat=alloc_stat)
      if (alloc_stat /= 0) then
         write(*,*) 'ERROR: Rank ', myself, ' was not able to allocate enough memory.'
         call MPI_Abort(MPI_COMM_WORLD, 1, ierr)
      end if

      j = 1
      root = 0
      do while (j <= MAXLEN)
         ! Initialize output array
         do i = 1, j
            out(i) = i - 1  ! Fortran arrays are 1-based, so subtract 1 to match C
         end do

         ! Set up receive counts and displacements on root
         if (myself == root) then
            do i = 1, tasks
               rcounts(i) = j
               displs(i) = (i - 1) * j  ! Fortran 1-based, but displacement is 0-based offset
            end do
         end if

         ! Perform persistent gatherv operation
         call MPI_Gatherv_init(out, j, MPI_INTEGER, in, rcounts, displs, MPI_INTEGER, &
                               root, MPI_COMM_WORLD, MPI_INFO_NULL, request, ierr)
         call MPI_Start(request, ierr)
         call MPI_Wait(request, MPI_STATUS_IGNORE, ierr)
         call MPI_Request_free(request, ierr)

         ! Check results on root process
         if (myself == root) then
            do i = 0, tasks - 1
               do k = 0, j - 1
                  if (in(i*j + k + 1) /= k) then  ! +1 for Fortran 1-based indexing
                     write(*,'(A,I0,A,I0,A,I0,A,I0,A,I0)') &
                        'ERROR: bad answer (', in(i*j + k + 1), ') at index ', i*j+k, &
                        ' of ', j*tasks, ' (should be ', k, ') on rank ', myself
                     call MPI_Abort(MPI_COMM_WORLD, 1, ierr)
                  end if
               end do
            end do
         end if

         j = j * 10
         root = mod(root + 1, tasks)
      end do

      call MPI_Barrier(MPI_COMM_WORLD, ierr)
      call MPI_Finalize(ierr)

      ! Clean up
      deallocate(in, out, displs, rcounts)

      end program gatherv_init_f90
