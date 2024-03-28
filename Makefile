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
OBJS = connection.o option.o deparse.o sqlite_query.o sqlite_fdw.o sqlite_data_norm.o

EXTENSION = sqlite_fdw
DATA = sqlite_fdw--1.0.sql sqlite_fdw--1.0--1.1.sql

REGRESS = extra/sqlite_fdw_post extra/bitstring extra/bool extra/float4 extra/float8 extra/int4 extra/int8 extra/numeric extra/out_of_range extra/timestamp extra/uuid extra/join extra/limit extra/aggregates extra/prepare extra/select_having extra/select extra/insert extra/update extra/encodings sqlite_fdw type aggregate selectfunc 
REGRESS_OPTS = --encoding=utf8

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
ifeq (,$(findstring $(MAJORVERSION), 12 13 14 15 16))
$(error PostgreSQL 12, 13, 14, 15 or 16 is required to compile this extension)
endif

else
subdir = contrib/sqlite_fdw
top_builddir = ../..
include $(top_builddir)/src/Makefile.global
include $(top_srcdir)/contrib/contrib-global.mk
endif

ifdef REGRESS_PREFIX
REGRESS_PREFIX_SUB = $(REGRESS_PREFIX)
else
REGRESS_PREFIX_SUB = $(VERSION)
endif

REGRESS := $(addprefix $(REGRESS_PREFIX_SUB)/,$(REGRESS))
$(shell mkdir -p results/$(REGRESS_PREFIX_SUB)/extra)
