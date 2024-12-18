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

ifndef REGRESS
REGRESS = extra/sqlite_fdw_post types/bitstring types/bool types/float4 types/float8 types/int4 types/int8 types/numeric types/macaddr types/macaddr8 types/out_of_range types/timestamp types/uuid extra/join extra/limit extra/aggregates extra/prepare extra/select_having extra/select extra/insert extra/update extra/encodings sqlite_fdw type aggregate selectfunc 
endif

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
ifeq (,$(findstring $(MAJORVERSION), 13 14 15 16 17))
$(error PostgreSQL 13, 14, 15, 16 or 17 is required to compile this extension)
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
$(shell mkdir -p results/$(REGRESS_PREFIX_SUB)/types)
