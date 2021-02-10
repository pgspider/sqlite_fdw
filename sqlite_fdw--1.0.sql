/*-------------------------------------------------------------------------
 *
 * SQLite Foreign Data Wrapper for PostgreSQL
 *
 * Portions Copyright (c) 2018, TOSHIBA CORPORATION
 *
 * IDENTIFICATION
 *        sqlite_fdw--1.0.sql
 *
 *-------------------------------------------------------------------------
 */

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
  RETURNS pg_catalog.int4 STRICT
  AS 'MODULE_PATHNAME' LANGUAGE C;
