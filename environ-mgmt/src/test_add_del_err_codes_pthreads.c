/*
 * Copyright (c) 2025 UT-Battelle, LLC. All rights reserved.
 * $COPYRIGHT$
 */

#include "config.h"

#include <stdio.h>
#include <stdlib.h>
#include <mpi.h>

#ifdef HAVE_PTHREAD
#include <pthread.h>
#include <unistd.h>
#include <time.h>

#define NUM_THREADS 10
#define MAX_SLEEP_MS 100

typedef struct {
    int thread_id;
} thread_arg_t;

void *thread_func(void *arg)
{
    thread_arg_t *targ = (thread_arg_t *)arg;
    int thread_id = targ->thread_id;
    int errorclass, errorcode;
    char errorstring[MPI_MAX_ERROR_STRING];
    char code_string[MPI_MAX_ERROR_STRING];
    int len;
    unsigned int sleep_time;

    /* Seed random number generator with thread id and time */
    unsigned int seed = (unsigned int)(time(NULL) ^ (thread_id << 16));

    /* Add error class */
    MPI_Add_error_class(&errorclass);
    printf("Thread %d: Added error class %d\n", thread_id, errorclass);

    /* Add error code */
    MPI_Add_error_code(errorclass, &errorcode);
    printf("Thread %d: Added error code %d\n", thread_id, errorcode);

    /* Add error string */
    snprintf(errorstring, MPI_MAX_ERROR_STRING,
             "Error string for thread %d", thread_id);
    MPI_Add_error_string(errorcode, errorstring);
    printf("Thread %d: Added error string '%s'\n", thread_id, errorstring);

    /* Verify the error string was added correctly */
    MPI_Error_string(errorcode, code_string, &len);
    printf("Thread %d: Verified error string: '%s'\n", thread_id, code_string);

    /* Sleep for random time to stress concurrent operations */
    sleep_time = rand_r(&seed) % MAX_SLEEP_MS;
    usleep(sleep_time * 1000);
    printf("Thread %d: Slept for %u ms\n", thread_id, sleep_time);

    /* Remove error string */
    MPI_Remove_error_string(errorcode);
    printf("Thread %d: Removed error string for code %d\n", thread_id, errorcode);

    /* Remove error code */
    MPI_Remove_error_code(errorcode);
    printf("Thread %d: Removed error code %d\n", thread_id, errorcode);

    /* Remove error class */
    MPI_Remove_error_class(errorclass);
    printf("Thread %d: Removed error class %d\n", thread_id, errorclass);

    printf("Thread %d: Completed successfully\n", thread_id);
    return NULL;
}
#endif

int main(int argc, char **argv)
{
    int rank, size;
    int provided;

    MPI_Init_thread(&argc, &argv, MPI_THREAD_MULTIPLE, &provided);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    if (provided < MPI_THREAD_MULTIPLE) {
        printf("Warning: MPI does not provide MPI_THREAD_MULTIPLE support\n");
    }

    if (rank == 0) {
        printf("MPI initialized with %d processes\n", size);

#ifdef HAVE_PTHREAD
        pthread_t threads[NUM_THREADS];
        thread_arg_t args[NUM_THREADS];
        int i;

        printf("pthread support available - creating %d threads\n", NUM_THREADS);

        /* Create threads */
        for (i = 0; i < NUM_THREADS; i++) {
            args[i].thread_id = i;
            if (pthread_create(&threads[i], NULL, thread_func, &args[i]) != 0) {
                fprintf(stderr, "Failed to create thread %d\n", i);
                MPI_Abort(MPI_COMM_WORLD, 1);
            }
        }

        /* Join threads */
        for (i = 0; i < NUM_THREADS; i++) {
            pthread_join(threads[i], NULL);
        }

        printf("All threads completed successfully\n");
#else
        printf("pthread support not available - test running without threads\n");
#endif
    }

    MPI_Finalize();
    return 0;
}
