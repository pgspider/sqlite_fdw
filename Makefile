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
OBJS = connection.o option.o deparse.o sqlite_query.o sqlite_fdw.o sqlite_data_norm.o sqlite_gis.o

EXTENSION = sqlite_fdw
DATA = sqlite_fdw--1.0.sql sqlite_fdw--1.0--1.1.sql

ifdef ENABLE_GIS
PG_CFLAGS += -DSQLITE_FDW_GIS_ENABLE
GIS_DEP_TESTS_DIR = with_gis_support
GIS_TEST = postgis
$(info  There is PostGIS support for SQLite FDW)
else
GIS_DEP_TESTS_DIR = without_gis_support
GIS_TEST = nogis
$(info  There is NO PostGIS support for SQLite FDW)
endif

# Tests for PostgreSQL data types support
DATA_TYPE_TESTS = types/bitstring types/bool types/float4 types/float8 types/int4 types/int8 types/json types/numeric  types/macaddr types/macaddr8 types/out_of_range types/timestamp types/uuid
# Tests with different versions with GIS support and without GIS support
GIS_DEP_TESTS = $(GIS_DEP_TESTS_DIR)/type $(GIS_DEP_TESTS_DIR)/auto_import $(GIS_DEP_TESTS_DIR)/$(GIS_TEST)

ifndef REGRESS
# System tests, full default sequence
REGRESS = libsqlite extra/sqlite_fdw_post $(DATA_TYPE_TESTS) extra/join extra/limit extra/aggregates extra/prepare extra/select_having extra/select extra/insert extra/update extra/encodings sqlite_fdw aggregate selectfunc extra/returning $(GIS_DEP_TESTS)
endif

# Other encodings also are tested. Client encoding should be UTF-8.
REGRESS_OPTS = --encoding=utf8

UNAME = uname
OS := $(shell $(UNAME))
ifeq ($(OS), Darwin)
DLSUFFIX = .dylib
else
DLSUFFIX = .so
endif

ifdef SQLITE_FOR_TESTING_DIR
SHLIB_LINK := -L$(SQLITE_FOR_TESTING_DIR)/lib -lsqlite3
PG_CFLAGS += -I$(SQLITE_FOR_TESTING_DIR)/include -Wl,-rpath,$(SQLITE_FOR_TESTING_DIR)/lib
else
SHLIB_LINK := -lsqlite3
endif

ifdef ENABLE_GIS
override SHLIB_LINK += -lspatialite
endif

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
$(shell mkdir -p results/$(REGRESS_PREFIX_SUB)/$(GIS_DEP_TESTS_DIR))

# $(info    ENABLE_GIS      is $(ENABLE_GIS))
# $(info    SHLIB_LINK      is $(SHLIB_LINK))
# $(info    LD_LIBRARY_PATH is $(LD_LIBRARY_PATH))
# $(info    PG_CFLAGS       is $(PG_CFLAGS))
# $(info    PG_CPPFLAGS     is $(PG_CPPFLAGS))
# $(info    REGRESS         is $(REGRESS))
# $(info    DLSUFFIX        is $(DLSUFFIX))

ifdef ENABLE_GIS
check: temp-install
temp-install: EXTRA_INSTALL+=contrib/postgis
checkprep: EXTRA_INSTALL+=contrib/postgis
endif

