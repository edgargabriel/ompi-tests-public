/*
 * Copyright (c) 2025      UT-Battelle, LLC.    All rights reserved.
 *
 * Tests for MPI_LASTUSEDCODE, MPI_Add_error_{class,code,string}, and
 * MPI_Remove_error{class,code,string}.
 *
 * File: test_add_del_err_codes.c
 *
 * Referenced examples online and in ompi-tests:
 *  - "ompi-tests/random/add_error_class.c"
 *  - example from Lisandro Dalcin
 *    https://www.open-mpi.org/community/lists/devel/2014/04/14578.php
 */
#include "config.h"

#include <stdio.h>
#include <stdlib.h>

#include "mpi.h"

#define SUCCESS  (0)
#define FAILURE  (-1)
#define SKIPTEST (-2)

#define CHECK_RC(_rc,_msg) do {\
    if (_rc != MPI_SUCCESS) { \
        fprintf(stderr, "[%s:%d] Error: %s failed (rc=%d)\n", __FUNCTION__, __LINE__, _msg, _rc); \
        exit(1); \
    } \
   } while(0)

int get_lastused(MPI_Comm comm);
int do_add_error(MPI_Comm comm, int *eclass, int *ecode, char *estr);
int do_del_error_string(MPI_Comm comm, int eclass, int ecode, char *estr);
int do_del_error_code(MPI_Comm comm, int eclass, int ecode, char *estr);
int do_del_error_class(MPI_Comm comm, int eclass, int ecode, char *estr);

int get_lastused(MPI_Comm comm)
{
    int *last = NULL;
    int flag = 0;

    CHECK_RC( MPI_Comm_get_attr(comm, MPI_LASTUSEDCODE, &last, &flag),
              "MPI_Comm_get_attr");

    if (flag == 0)
        return (-1);   /* no key found */
    else
        return (*last);
}

int do_add_error(MPI_Comm comm, int *eclass, int *ecode, char *estr)
{
    int ret = SUCCESS;

#ifdef HAVE_MPI_ADD_ERROR_CODE
    int last = 0, newlast = 0;
    last = get_lastused(MPI_COMM_WORLD);

    CHECK_RC( MPI_Add_error_class(eclass),        "MPI_Add_error_class");
    CHECK_RC( MPI_Add_error_code(*eclass, ecode), "MPI_Add_error_code");
    CHECK_RC( MPI_Add_error_string(*ecode, estr), "MPI_Add_error_string");

    newlast = get_lastused(MPI_COMM_WORLD);

    if (newlast > last) {
        printf("TEST: Success creating error class/code/string (last=%d, newlast=%d)\n", last, newlast);
        ret = SUCCESS;
    } else {
        printf("Error: MPI_Add_error_xxx failed LastUsedCode not increased (last=%d, new=%d)\n", last, newlast);
        ret = FAILURE;
    }

#else
    printf("Warning: MPI_Add_error_xxx code/class/string NOT available!\n");
    ret = SKIPTEST;
#endif /* HAVE_MPI_ADD_ERROR_CODE */

    return(ret);
}


int do_del_error_string(MPI_Comm comm, int eclass, int ecode, char *estr)
{
    int ret = SUCCESS;

#ifdef HAVE_MPI_REMOVE_ERROR_CODE
    CHECK_RC( MPI_Remove_error_string(ecode), "MPI_Remove_error_string");
#else
    /* We should have MPI_Remove_error_xxx with MPI >= 4.1 */
    printf("Warning: MPI_Remove_error_string NOT available!\n");
    ret = SKIPTEST;
#endif /* HAVE_MPI_REMOVE_ERROR_CODE */

    return(ret);
}

int do_del_error_code(MPI_Comm comm, int eclass, int ecode, char *estr)
{
    int ret = SUCCESS;

#ifdef HAVE_MPI_REMOVE_ERROR_CODE
    int last = 0, newlast = 0;
    last = get_lastused(MPI_COMM_WORLD);

    CHECK_RC( MPI_Remove_error_code(ecode),   "MPI_Remove_error_code");

    newlast = get_lastused(MPI_COMM_WORLD);

    if (newlast < last) {
        printf("TEST: Success removed error code (oldlast=%d, newlast=%d)\n", last, newlast);
        ret = SUCCESS;
    } else {
        printf("Error: MPI_Remove_error_code failed LastUsedCode not decreased (last=%d, new=%d)\n", last, newlast);
        ret = FAILURE;
    }

#else
    /* We should have MPI_Remove_error_xxx with MPI >= 4.1 */
    printf("Warning: MPI_Remove_error_code NOT available!\n");
    ret = SKIPTEST;
#endif /* HAVE_MPI_REMOVE_ERROR_CODE */

    return(ret);
}

int do_del_error_class(MPI_Comm comm, int eclass, int ecode, char *estr)
{
    int ret = SUCCESS;

#ifdef HAVE_MPI_REMOVE_ERROR_CODE
    int last = 0, newlast = 0;
    last = get_lastused(MPI_COMM_WORLD);

    CHECK_RC( MPI_Remove_error_class(eclass), "MPI_Remove_error_class");

    newlast = get_lastused(MPI_COMM_WORLD);

    if (newlast < last) {
        printf("TEST: Success removed error class (oldlast=%d, newlast=%d)\n", last, newlast);
        ret = SUCCESS;
    } else {
        printf("Error: MPI_Remove_error_class failed LastUsedCode not decreased (last=%d, new=%d)\n", last, newlast);
        ret = FAILURE;
    }

#else
    /* We should have MPI_Remove_error_xxx with MPI >= 4.1 */
    printf("Warning: MPI_Remove_error_class NOT available!\n");
    ret = SKIPTEST;
#endif /* HAVE_MPI_REMOVE_ERROR_CODE */

    return(ret);
}


int main (int argc, char **argv)
{
    int rc, rank=0, size;
    int retval = EXIT_SUCCESS;
    int eclass, ecode;
    char *estr = "My Dummy Error String";

    CHECK_RC( MPI_Init(&argc, &argv),               "MPI_Init");
    CHECK_RC( MPI_Comm_rank(MPI_COMM_WORLD, &rank), "MPI_Comm_rank");
    CHECK_RC( MPI_Comm_size(MPI_COMM_WORLD, &size), "MPI_Comm_size");

    rc = do_add_error(MPI_COMM_WORLD, &eclass, &ecode, estr);
    if ((SUCCESS != rc) && (SKIPTEST != rc)) {
        printf("Error: Failed during do_add_error testing (rc=%d)\n", rc);
        retval = EXIT_FAILURE;
        goto fini;
    }

    printf("==== Adds done ====\n");

    printf("==== Remove estring ====\n");
    rc = do_del_error_string(MPI_COMM_WORLD, eclass, ecode, estr);
    if ((SUCCESS != rc) && (SKIPTEST != rc)) {
        printf("Error: Failed during do_del_error_string testing (rc=%d)\n", rc);
        retval = EXIT_FAILURE;
        goto fini;
    }

    printf("==== Remove ecode ====\n");
    rc = do_del_error_code(MPI_COMM_WORLD, eclass, ecode, estr);
    if ((SUCCESS != rc) && (SKIPTEST != rc)) {
        printf("Error: Failed during do_del_error_code testing (rc=%d)\n", rc);
        retval = EXIT_FAILURE;
        goto fini;
    }

    printf("==== Remove eclass  ====\n");
    rc = do_del_error_class(MPI_COMM_WORLD, eclass, ecode, estr);
    if ((SUCCESS != rc) && (SKIPTEST != rc)) {
        printf("Error: Failed during do_del_error_class testing (rc=%d)\n", rc);
        retval = EXIT_FAILURE;
        goto fini;
    }

fini:
    CHECK_RC( MPI_Finalize(), "MPI_Finalize");

    if (rank == 0) {
        if (retval == EXIT_SUCCESS) {
            printf("DONE: Success\n");
        } else {
            printf("DONE: Failure\n");
        }
    }

    return(retval);
}

