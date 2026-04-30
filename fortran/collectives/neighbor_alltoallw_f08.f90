! -*- Mode: Fortran; -*-
!!
!! Copyright (c) 2013      Los Alamos National Security, LLC. All rights
!!                         reserved.
!! $COPYRIGHT!!
!!
!! Additional copyrights may follow
!!
!! $HEADER!!
!!

      program neighbor_alltoallw_f08
      use mpi_f08
      implicit none

      integer, parameter :: MAXEDGES = 32
      integer, parameter :: MAXLEN = 10000

      integer :: i, j, k, myself, tasks, rc, err
      integer :: edges, num_edges
      integer, dimension(0:MAXEDGES-1) :: counts, disps, expected, destinations
      integer, dimension(0:MAXLEN*MAXEDGES-1) :: in, out
      integer, dimension(:), allocatable :: index, edges_array
      type(MPI_Comm) :: cart, graph, dist_graph
      integer, dimension(2) :: dims, coords
      type(MPI_Datatype), dimension(0:MAXEDGES-1) :: datatypes_out, datatypes_in
      logical,  dimension(2) :: periods

      call MPI_Init()
      call MPI_Comm_rank(MPI_COMM_WORLD, myself)
      call MPI_Comm_size(MPI_COMM_WORLD, tasks)

      if (tasks < 4) then
         write(*,*) 'Test requires at least 4 processes'
         call MPI_Abort(MPI_COMM_WORLD, 1)
      end if

      num_edges = min(tasks, MAXEDGES)
      num_edges = num_edges - mod(num_edges, 2)  ! Make even

      ! Allocate buffers
      allocate(index(0:tasks-1))
      allocate(edges_array(0:tasks*num_edges-1))

      ! Initialize output buffer
      out = myself

      ! Initialize datatypes
      datatypes_out = MPI_INTEGER
      datatypes_in = MPI_INTEGER

      ! Cartesian topology
      dims = [4, tasks/4]
      periods = [.false., .true.]
      call MPI_Cart_create(MPI_COMM_WORLD, 2, dims, periods, .false., cart)
      if (cart .ne. MPI_COMM_NULL) then
         call MPI_Cart_coords(cart, myself, 2, coords)
         call MPI_Cart_shift(cart, 0, 1, expected(0), expected(1))
         call MPI_Cart_shift(cart, 1, 1, expected(2), expected(3))

         if (myself == 0) then
            write(*,*) 'Testing MPI_Neighbor_alltoallw on cartesian communicator'
         end if

         ! Check cartesian all to all
         rc = run_test(expected, 4, cart, out, in, datatypes_out, datatypes_in)
         if (rc .ne. 0) then
            write(*,*) 'Neighborhood alltoallw test on cart failed'
            err = err + 1
         else if (myself == 0) then
            write(*,*) 'Pass!'
         end if
      end if

      call MPI_Barrier(MPI_COMM_WORLD)
      if (cart .ne. MPI_COMM_NULL) call MPI_Comm_free(cart)

      ! Graph topology
      do i = 0, tasks-1
         index(i) = num_edges * (i + 1)
         do j = 0, num_edges/2 - 1
            edges_array(j + num_edges*i) = mod(i - j - 1 + tasks, tasks)
         end do
         do j = 0, num_edges/2 - 1
            edges_array(num_edges/2 + j + num_edges*i) = mod(i + j + 1, tasks)
         end do
      end do

      call MPI_Graph_create(MPI_COMM_WORLD, tasks, index, edges_array, .false., graph)
      if (rc .ne. MPI_SUCCESS) then
         write(*,*) 'Could not create graph communicator. MPI test aborted!'
         call MPI_Abort(MPI_COMM_WORLD, 1)
      end if

      do j = 0, num_edges-1
         expected(j) = edges_array(myself*num_edges + j)
      end do

      if (myself == 0) then
         write(*,*) 'Testing MPI_Neighbor_alltoallw on graph communicator'
      end if

      rc = run_test(expected, num_edges, graph, out, in, datatypes_out, datatypes_in)
      if (rc .ne. 0) then
         write(*,*) 'Neighborhood alltoallw test on graph failed'
         err = err + 1
      else if (myself == 0) then
         write(*,*) 'Pass!'
      end if

      call MPI_Barrier(MPI_COMM_WORLD)
      call MPI_Comm_free(graph)

      ! Distributed graph topology
      do j = 0, num_edges-1
         expected(j) = mod(myself + 13*j, tasks)
         destinations(j) = mod(myself - 13*j + 13*tasks, tasks)
      end do

      call MPI_Dist_graph_create_adjacent(MPI_COMM_WORLD, num_edges, expected, MPI_UNWEIGHTED, &
                                         num_edges, destinations, MPI_UNWEIGHTED, MPI_INFO_NULL, &
                                         .false., dist_graph)
      if (myself == 0) then
         write(*,*) 'Testing MPI_Neighbor_alltoallw on dist graph communicator'
      end if

      rc = run_test(expected, num_edges, dist_graph, out, in, datatypes_out, datatypes_in)
      if (rc .ne. 0) then
         write(*,*) 'Neighborhood alltoallw test on dist graph failed'
         err = err + 1
      else if (myself == 0) then
         write(*,*) 'Pass!'
      end if

      call MPI_Barrier(MPI_COMM_WORLD)
      call MPI_Comm_free(dist_graph)

      call MPI_Barrier(MPI_COMM_WORLD)
      call MPI_Finalize()

      ! Clean up
      deallocate(index)
      deallocate(edges_array)

      contains

      function run_test(expected, edges, comm, out, in, datatypes_out, datatypes_in) result(res)
        integer, intent(in) :: edges
        integer, intent(in), dimension(0:edges-1) :: expected
        type(MPI_Comm), intent(in) :: comm
        integer, intent(inout), dimension(0:) :: out, in
        type(MPI_Datatype), intent(in), dimension(0:edges-1) :: datatypes_out, datatypes_in
        integer :: res
        integer, dimension(0:edges-1) :: counts
        integer(KIND=MPI_ADDRESS_KIND), dimension(0:edges-1) :: disps_bytes, disps
        integer(KIND=MPI_ADDRESS_KIND) :: sizeof_datatype, lb
        integer :: i, j, k

        j = 1
        do while (j <= MAXLEN)

          ! In and out will have holes where the remote is MPI_PROC_NULL so
          ! fill the array in with MPI_PROC_NULL now.
          do i = 0, edges-1
             do k = 0, j-1
                in(k + i*MAXLEN) = MPI_PROC_NULL
             end do
             do k = j, MAXLEN-1
                in(k + i*MAXLEN) = -3
             end do
          end do

          do i = 0, edges-1
             counts(i) = j
             disps(i)  = MAXLEN * i
             call MPI_Type_get_extent(datatypes_out(i), lb, sizeof_datatype)
             disps_bytes(i)  = disps(i) * sizeof_datatype
          end do

          call MPI_Neighbor_alltoallw(out, counts, disps_bytes, datatypes_out, &
                                      in, counts, disps_bytes, datatypes_in, comm)

          do i = 0, edges-1
             ! Check that we received the expected values
             do k = 0, j-1
                if (in(k + disps(i)) .ne. expected(i)) then
                   write(*,*) 'bad answer ', in(k+disps(i)), ' at index ', k+disps(i), &
                            ' of ', MAXLEN*edges, ' (should be ', expected(i), ')'
                   return
                end if
             end do

             ! Check that the space after the receive buffer is untouched
             do k = j, MAXLEN-1
                if (in(k + disps(i)) .ne. -3) then
                   write(*,*) 'bad answer ', in(k+disps(i)), ' at index ', k+disps(i), &
                            ' of ', MAXLEN*edges, ' (should be -3)'
                   return
                end if
             end do
          end do
          j = j * 10
        end do

        ! ok!
        res = 0
      end function run_test

      end program neighbor_alltoallw_f08
