/* contrib/sqlite_fdw/sqlite_fdw--1.0.sql */

-- complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "CREATE EXTENSION sqlite_fdw" to load this file. \quit

CREATE FUNCTION sqlite_fdw_handler()
RETURNS fdw_handler
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT;

COMMENT ON FUNCTION sqlite_fdw_handler()
IS 'SQLite foreign data wrapper handler';

CREATE FUNCTION sqlite_fdw_validator(text[], oid)
RETURNS void
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT;

COMMENT ON FUNCTION sqlite_fdw_validator(text[], oid)
IS 'SQLite foreign data wrapper options validator';

CREATE FOREIGN DATA WRAPPER sqlite_fdw
  HANDLER sqlite_fdw_handler
  VALIDATOR sqlite_fdw_validator;

COMMENT ON FOREIGN DATA WRAPPER sqlite_fdw
IS 'SQLite foreign data wrapper';

CREATE OR REPLACE FUNCTION sqlite_fdw_version()
  RETURNS pg_catalog.int4 STRICT
  AS 'MODULE_PATHNAME' LANGUAGE C;
