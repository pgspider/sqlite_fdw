/* contrib/sqlite_fdw/sqlite_fdw--1.1.sql */

-- complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "CREATE EXTENSION sqlite_fdw" to load this file. \quit

CREATE FUNCTION sqlite_fdw_handler()
RETURNS fdw_handler
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT;

CREATE FUNCTION sqlite_fdw_validator(text[], oid)
RETURNS void
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT;

CREATE FOREIGN DATA WRAPPER sqlite_fdw
  HANDLER sqlite_fdw_handler
  VALIDATOR sqlite_fdw_validator;

CREATE OR REPLACE FUNCTION sqlite_fdw_version()
RETURNS pg_catalog.int4
AS 'MODULE_PATHNAME' LANGUAGE C STRICT;

CREATE FUNCTION sqlite_fdw_get_connections (OUT server_name text,
    OUT valid boolean)
RETURNS SETOF record
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT PARALLEL RESTRICTED;

CREATE FUNCTION sqlite_fdw_disconnect (text)
RETURNS bool
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT PARALLEL RESTRICTED;

CREATE FUNCTION sqlite_fdw_disconnect_all ()
RETURNS bool
AS 'MODULE_PATHNAME'
LANGUAGE C STRICT PARALLEL RESTRICTED;
