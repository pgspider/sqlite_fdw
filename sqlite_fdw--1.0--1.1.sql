/* contrib/sqlite_fdw/sqlite_fdw--1.0--1.1.sql */

-- complain if script is sourced in psql, rather than via ALTER EXTENSION
\echo Use "ALTER EXTENSION sqlite_fdw UPDATE TO '1.1'" to load this file. \quit

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
