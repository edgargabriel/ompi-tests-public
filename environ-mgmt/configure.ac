# -*- shell-script -*-
#
# Copyright (c) 2012-2020 Cisco Systems, Inc.  All rights reserved.
# Copyright (c) 2025      UT-Battelle, LLC.    All rights reserved.
#
# $COPYRIGHT$
#

dnl
dnl Init autoconf
dnl

AC_PREREQ([2.67])
AC_INIT([mpi-environmgmt-test], [1.0], [http://www.open-mpi.org])
AC_CONFIG_AUX_DIR([config])
AC_CONFIG_MACRO_DIR([config])
AC_CONFIG_SRCDIR([.])

echo "Configuring Environmental Management test"

AM_INIT_AUTOMAKE([1.11 foreign -Wall -Werror])

# If Automake supports silent rules, enable them.
m4_ifdef([AM_SILENT_RULES], [AM_SILENT_RULES([yes])])

AH_TOP([/* -*- c -*-
 *
 *	Environmental Management test suite configuation header file.
 *      See the top-level LICENSE file for license and copyright
 *      information.
 */

#ifndef MPI_ENVIRONMGMT_TEST_CONFIG_H
#define MPI_ENVIRONMGMT_TEST_CONFIG_H
])
AH_BOTTOM([#endif /* MPI_ENVIRONMGMT_TEST_CONFIG_H */])

dnl
dnl Make automake clean emacs ~ files for "make clean"
dnl

CLEANFILES="*~"
AC_SUBST(CLEANFILES)

dnl
dnl Get various programs
dnl Bias towards mpicc/mpic++/mpif77
dnl C compiler
dnl

if test "$CC" != ""; then
    BASE="`basename $CC`"
else
    BASE=
fi
if test "$BASE" = "" -o "$BASE" = "." -o "$BASE" = "cc" -o \
    "$BASE" = "gcc" -o "$BASE" = "xlc" -o "$BASE" = "pgcc" -o \
    "$BASE" = "icc"; then
    AC_CHECK_PROG(HAVE_MPICC, mpicc, yes, no)
    if test "$HAVE_MPICC" = "yes"; then
        CC=mpicc
        export CC
    fi
fi

CFLAGS_save=$CFLAGS
AC_PROG_CC
CFLAGS=$CFLAGS_save

dnl
dnl Fortran compiler - prefer mpifort if available
dnl

if test "$FC" = ""; then
    AC_CHECK_PROG(HAVE_MPIFORT, mpifort, yes, no)
    if test "$HAVE_MPIFORT" = "yes"; then
        FC=mpifort
        export FC
    fi
fi

FFLAGS_save=$FFLAGS
AC_PROG_FC
FFLAGS=$FFLAGS_save


dnl
dnl Because these are meant to be used for debugging, after all
dnl

if test -z "$CFLAGS"; then
    CFLAGS="-g"
fi

dnl
dnl Ensure that we can compile and link a C MPI program
dnl

AC_LANG_PUSH([C])
AC_CHECK_HEADERS(mpi.h)

AC_MSG_CHECKING([if linking MPI program works])
AC_LINK_IFELSE([AC_LANG_PROGRAM([[#include <mpi.h>
]],
                                [[MPI_Comm a = MPI_COMM_WORLD]])],
               [AC_MSG_RESULT([yes])],
               [AC_MSG_RESULT([no])
                AC_MSG_WARN([Simple MPI program fails to link])
                AC_MSG_ERROR([Cannot continue])
               ])

AC_CHECK_LIB([mpi], [MPI_Add_error_code],
  [AC_DEFINE([HAVE_MPI_ADD_ERROR_CODE], [1], [Define if have MPI_Add_error_code])],
  [AC_MSG_WARN([MPI_Add_error_code not found; disable related features])])


AC_CHECK_LIB([mpi], [MPI_Remove_error_code],
  [AC_DEFINE([HAVE_MPI_REMOVE_ERROR_CODE], [1], [Define if have MPI_Remove_error_code])],
  [AC_MSG_WARN([MPI_Remove_error_code not found; disable related features])])

AC_CHECK_LIB([mpi], [MPI_Remove_error_class],
  [AC_DEFINE([HAVE_MPI_REMOVE_ERROR_CLASS], [1], [Define if have MPI_Remove_error_class])],
  [AC_MSG_WARN([MPI_Remove_error_class not found; disable related features])])

AC_CHECK_LIB([mpi], [MPI_Remove_error_string],
  [AC_DEFINE([HAVE_MPI_REMOVE_ERROR_STRING], [1], [Define if have MPI_Remove_error_string])],
  [AC_MSG_WARN([MPI_Remove_error_string not found; disable related features])])

AC_SUBST([MPI_LIBS])

dnl
dnl Check for pthreads support
dnl

AC_SEARCH_LIBS([pthread_create], [pthread], [have_pthread=yes], [have_pthread=no])
if test "$have_pthread" = "yes"; then
    AC_DEFINE([HAVE_PTHREAD], [1], [Define if have pthreads])
fi

AC_LANG_POP([C])

dnl
dnl Party on
dnl

AC_CONFIG_HEADERS([config.h])
AC_CONFIG_FILES([
    Makefile
    src/Makefile
])
AC_OUTPUT
