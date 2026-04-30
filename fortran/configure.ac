# -*- shell-script -*-
#
# Copyright (c) 2024      Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# $HEADER$
#
# modified from ompi-tests/cxx-test-suite's autoconf by Luke Robison 2024.

#
# Init autoconf
#

AC_PREREQ([2.69])
AC_INIT([fortran_validation], [1.0], [devel@open-mpi.org], [ompi-tests-public-fortran])
AC_CONFIG_AUX_DIR([config])
AC_CONFIG_MACRO_DIR([config])

#
# Get the version of ompitest that we are configuring
#

echo "Configuring Open MPI Fortran test suite"

AM_INIT_AUTOMAKE([1.10 foreign dist-bzip2 no-define])

# If Automake supports silent rules, enable them.
m4_ifdef([AM_SILENT_RULES], [AM_SILENT_RULES([yes])])

AH_TOP([/* -*- c -*-
 *
 *	ompitest configuration header file.
 *
 * Function: - OS, CPU and compiler dependent configuration
 */

#ifndef OMPITEST_CONFIG_H
#define OMPITEST_CONFIG_H
])
AH_BOTTOM([#endif /* OMPITEST_CONFIG_H */])

#
# This is useful later
#

AC_CANONICAL_HOST
AC_DEFINE_UNQUOTED(OMPITEST_ARCH, "$host",
    [Architecture that we are compiled for])

#
# We always want debugging flags
#
CXXFLAGS="$CXXFLAGS -g"
CFLAGS="$CFLAGS -g"

#
# Get various programs
# C compiler - bias towards mpicc
#

if test "$CC" != ""; then
    BASE="`basename $CC`"
else
    BASE=
fi
if test "$BASE" = "" -o "$BASE" = "." -o "$BASE" = "cc" -o \
    "$BASE" = "gcc" -o "$BASE" = "xlc" -o \
    "$BASE" = "icc" -o "$BASE" = "pgcc"; then
    AC_CHECK_PROG(HAVE_MPICC, mpicc, yes, no)
    if test "$HAVE_MPICC" = "yes"; then
        CC=mpicc
        export CC
    fi
fi

CFLAGS_save="$CFLAGS"
AC_PROG_CC
CFLAGS="$CFLAGS_save"

#
# Get various programs
# C++ compiler - bias towards mpic++, with fallback to mpiCC
#

if test "$CXX" != ""; then
    BASE="`basename $CXX`"
else
    BASE=
fi
if test "$BASE" = "" -o "$BASE" = "." -o "$BASE" = "CC" -o \
    "$BASE" = "g++" -o "$BASE" = "c++" -o "$BASE" = "xlC" -o \
    "$BASE" = "icpc" -o "$BASE" = "pgCC"; then
    AC_CHECK_PROG(HAVE_MPICPP, mpic++, yes, no)
    if test "$HAVE_MPICPP" = "yes"; then
        CXX=mpic++
        export CXX
    else
        AC_CHECK_PROG(HAVE_MPICXX, mpiCC, yes, no)
        if test "$HAVE_MPICXX" = "yes"; then
            CXX=mpiCC
            export CXX
        fi
    fi
fi

CXXFLAGS_save="$CXXFLAGS"
AC_PROG_CXX
CXXFLAGS="$CXXFLAGS_save"

#
# Fortran compiler
#

if test "$FC" != ""; then
    BASE="`basename $FC`"
else
    BASE=
fi
if test "$BASE" = "" -o "$BASE" = "." -o "$BASE" = "f77" -o \
    "$BASE" = "g77" -o "$BASE" = "f90" -o "$BASE" = "g90" -o \
    "$BASE" = "xlf" -o "$BASE" = "ifc" -o "$BASE" = "pgf77" -o \
    "$BASE" = "ifx" -o "$BASE" = "gfortran" -o "$BASE" = "flang"; then
    if test "$HAVE_MPIFORT" = "yes"; then
        FC=mpifort
        export FC
    else
        AC_CHECK_PROG(HAVE_MPIF90, mpif90, yes, no)
        if test "$HAVE_MPIF90" = "yes"; then
            FC=mpif90
            export FC
        fi
    fi
fi


FCFLAGS_save=$FCFLAGS
AC_PROG_FC
FCFLAGS=$FCFLAGS_save

# Find a flag to specify defines for preprocessed Fortran.
# Not all Fortran compilers use -D.
# Substitute FC_DEFINE with the result.
AC_FC_PP_DEFINE

#
# Find ranlib
#

AC_PROG_RANLIB

#
# Ensure that we can compile and link an MPI Fortran program
#

AC_MSG_CHECKING([for fortran module mpi])
AC_LANG_PUSH([Fortran])
AC_COMPILE_IFELSE([AC_LANG_PROGRAM([], [
      USE mpi
      IMPLICIT NONE
    ])],
    [AC_MSG_RESULT([yes])
     # Action if found, e.g., AC_DEFINE(...)
    ],
    [AC_MSG_RESULT([no])
     AC_MSG_ERROR([Could not find Fortran module mpi])
    ])

AC_MSG_CHECKING([for fortran module mpi_f08])
AC_COMPILE_IFELSE([AC_LANG_PROGRAM([], [
      USE mpi_f08
      IMPLICIT NONE
    ])],
    [AC_MSG_RESULT([yes])
     # Action if found, e.g., AC_DEFINE(...)
    ],
    [AC_MSG_RESULT([no])
     AC_MSG_ERROR([Could not find Fortran module mpi_f08])
    ])
AC_LANG_POP([Fortran])

#
# Party on
#

AC_CONFIG_HEADERS([config/test_config.h])
AC_CONFIG_FILES([
    Makefile
    collectives/Makefile
])
AC_OUTPUT
