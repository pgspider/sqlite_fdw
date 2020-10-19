######################################################################-------------------------------------------------------------------------
#
# SQLite Foreign Data Wrapper for PostgreSQL
#
# Portions Copyright (c) 2018, TOSHIBA CORPORATION
#
# IDENTIFICATION
# 		Makefile
#
##########################################################################

MODULE_big = sqlite_fdw
OBJS = connection.o option.o deparse.o sqlite_query.o sqlite_fdw.o

EXTENSION = sqlite_fdw
DATA = sqlite_fdw--1.0.sql

REGRESS = extra/sqlite_fdw_post extra/float4 extra/float8 extra/int4 extra/int8 extra/numeric extra/join extra/limit extra/aggregates extra/prepare extra/select_having extra/select extra/insert extra/update extra/timestamp sqlite_fdw type aggregate 

SQLITE_LIB = sqlite3

UNAME = uname
OS := $(shell $(UNAME))
ifeq ($(OS), Darwin)
DLSUFFIX = .dylib
else
DLSUFFIX = .so
endif

SHLIB_LINK := -lsqlite3

ifdef USE_PGXS
PG_CONFIG = pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)
ifndef MAJORVERSION
MAJORVERSION := $(basename $(VERSION))
endif
ifeq (,$(findstring $(MAJORVERSION),9.6 10 11 12 13))
$(error PostgreSQL  9.6, 10, 11, 12 or 13 is required to compile this extension)
endif

else
subdir = contrib/sqlite_fdw
top_builddir = ../..
include $(top_builddir)/src/Makefile.global
include $(top_srcdir)/contrib/contrib-global.mk
endif

