--
-- TIMESTAMP
--
--Testcase 1:
CREATE EXTENSION sqlite_fdw;
--Testcase 2:
CREATE SERVER sqlite_svr FOREIGN DATA WRAPPER sqlite_fdw
OPTIONS (database '/tmp/sqlite_fdw_test/core.db');
--Testcase 3:
CREATE FOREIGN TABLE dates1 (
	name varchar(20),
	date_as_text timestamp without time zone,
	date_as_number timestamp without time zone OPTIONS (column_type 'INT'))
SERVER sqlite_svr
OPTIONS (table 'dates');

--Testcase 4:
CREATE FOREIGN TABLE dates2 (
	name varchar(20),
	date_as_text timestamp without time zone,
	date_as_number double precision)
SERVER sqlite_svr
OPTIONS (table 'dates');

-- Showing timestamp column from SQLite value as TEXT and as INTEGER/FLOAT has same value
--Testcase 5:
SELECT name,
	to_char(date_as_text, 	'YYYY-MM-DD HH24:MI:SS.MS') as date_as_text, 
	to_char(date_as_number, 'YYYY-MM-DD HH24:MI:SS.MS') as date_as_number
FROM dates1;
--Testcase 6:
SELECT * FROM dates2;

-- Comparing exact values showing same results even comparing to a text source sqlite column or numerical source sqlite column
--Testcase 7:
SELECT * FROM dates1
WHERE date_as_text = to_timestamp('2020-05-10 10:45:29.000', 'YYYY-MM-DD HH24:MI:SS.MS');

--Testcase 8:
SELECT * FROM dates1
WHERE date_as_number = to_timestamp('2020-05-10 10:45:29.000', 'YYYY-MM-DD HH24:MI:SS.MS');

--Testcase 9:
SELECT * FROM dates1
WHERE date_as_text = to_timestamp('2020-05-10 10:45:29', 'YYYY-MM-DD HH24:MI:SS.MS');

--Testcase 10:
SELECT * FROM dates1
WHERE date_as_number = to_timestamp('2020-05-10 10:45:29', 'YYYY-MM-DD HH24:MI:SS.MS');

-- Comparing greater values showing same results even comparing to a text source sqlite column or numerical source sqlite column
--Testcase 11:
SELECT * FROM dates1
WHERE date_as_text > to_timestamp('2020-05-10 10:45:29.000', 'YYYY-MM-DD HH24:MI:SS.MS');

--Testcase 12:
explain (verbose, costs off)
SELECT * FROM dates1
WHERE date_as_text > to_timestamp('2020-05-10 10:45:29.000', 'YYYY-MM-DD HH24:MI:SS.MS');

--Testcase 13:
SELECT * FROM dates1
WHERE date_as_number > to_timestamp('2020-05-10 10:45:29.000', 'YYYY-MM-DD HH24:MI:SS.MS');

--Testcase 14:
explain (verbose, costs off)
SELECT * FROM dates1
WHERE date_as_number > to_timestamp('2020-05-10 10:45:29.000', 'YYYY-MM-DD HH24:MI:SS.MS');

--Testcase 15:
SELECT * FROM dates1
WHERE date_as_text > to_timestamp('2020-05-10 10:45:29', 'YYYY-MM-DD HH24:MI:SS.MS');

--Testcase 16:
explain (verbose, costs off)
SELECT * FROM dates1
WHERE date_as_text > to_timestamp('2020-05-10 10:45:29', 'YYYY-MM-DD HH24:MI:SS.MS');

--Testcase 17:
SELECT * FROM dates1
WHERE date_as_number > to_timestamp('2020-05-10 10:45:29', 'YYYY-MM-DD HH24:MI:SS.MS');

--Testcase 18:
explain (verbose, costs off)
SELECT * FROM dates1
WHERE date_as_number > to_timestamp('2020-05-10 10:45:29', 'YYYY-MM-DD HH24:MI:SS.MS');

--- Comparing without using to_timestamp
--Testcase 19:
SELECT * FROM dates1
WHERE date_as_text = (('2020-05-10 10:45:29.000')::timestamp);

--Testcase 20:
explain (verbose, costs off)
SELECT * FROM dates1
WHERE date_as_text = (('2020-05-10 10:45:29.000')::timestamp);

--Testcase 21:
SELECT * FROM dates1
WHERE date_as_number = (('2020-05-10 10:45:29.000')::timestamp);

--Testcase 22:
explain (verbose, costs off)
SELECT * FROM dates1
WHERE date_as_number = (('2020-05-10 10:45:29.000')::timestamp);

--Testcase 23:
SELECT * FROM dates1
WHERE date_as_text = (('2020-05-10 10:45:29')::timestamp);

--Testcase 24:
explain (verbose, costs off)
SELECT * FROM dates1
WHERE date_as_text = (('2020-05-10 10:45:29')::timestamp);

--Testcase 25:
SELECT * FROM dates1
WHERE date_as_number = (('2020-05-10 10:45:29')::timestamp);

--Testcase 26:
explain (verbose, costs off)
SELECT * FROM dates1
WHERE date_as_number = (('2020-05-10 10:45:29')::timestamp);

-- Comparing greater values  without using to_timestamp


--Testcase 27:
SELECT * FROM dates1
WHERE date_as_text > (('2020-05-10 10:45:29.000')::timestamp);

--Testcase 28:
explain (verbose, costs off)
SELECT * FROM dates1
WHERE date_as_text > (('2020-05-10 10:45:29.000')::timestamp);

--Testcase 29:
SELECT * FROM dates1
WHERE date_as_number > (('2020-05-10 10:45:29.000')::timestamp);

--Testcase 30:
explain (verbose, costs off)
SELECT * FROM dates1
WHERE date_as_number > (('2020-05-10 10:45:29.000')::timestamp);

--Testcase 31:
SELECT * FROM dates1
WHERE date_as_text > (('2020-05-10 10:45:29')::timestamp);

--Testcase 32:
explain (verbose, costs off)
SELECT * FROM dates1
WHERE date_as_text > (('2020-05-10 10:45:29')::timestamp);

--Testcase 33:
SELECT * FROM dates1
WHERE date_as_number > (('2020-05-10 10:45:29')::timestamp);

--Testcase 34:
explain (verbose, costs off)
SELECT * FROM dates1
WHERE date_as_number > (('2020-05-10 10:45:29')::timestamp);

-- test arithmetic with infinite timestamps
--Testcase 39:
CREATE FOREIGN TABLE inf_timestamp (
	t1	TIMESTAMP ,
	t2	TIMESTAMP,
	id 	int OPTIONS (key 'true'))
SERVER sqlite_svr OPTIONS (table 'infinite_timestamp');;

--Testcase 40:
INSERT INTO inf_timestamp VALUES ('infinity'::timestamp, 'infinity'::timestamp);
--Testcase 41:
SELECT t1 - t2 FROM inf_timestamp;

--Testcase 42:
DELETE FROM inf_timestamp;
--Testcase 43:
INSERT INTO inf_timestamp VALUES ('infinity'::timestamp, '-infinity'::timestamp);
--Testcase 44:
SELECT t1 - t2 FROM inf_timestamp;

--Testcase 45:
DELETE FROM inf_timestamp;
--Testcase 46:
INSERT INTO inf_timestamp VALUES ('-infinity'::timestamp, 'infinity'::timestamp);
--Testcase 47:
SELECT t1 - t2 FROM inf_timestamp;

--Testcase 48:
DELETE FROM inf_timestamp;
--Testcase 49:
INSERT INTO inf_timestamp VALUES ('-infinity'::timestamp, '-infinity'::timestamp);
--Testcase 50:
SELECT t1 - t2 FROM inf_timestamp;

--Testcase 51:
DELETE FROM inf_timestamp;
--Testcase 52:
INSERT INTO inf_timestamp VALUES ('infinity'::timestamp, '1995-08-06 12:12:12'::timestamp);
--Testcase 53:
SELECT t1 - t2 FROM inf_timestamp;

--Testcase 54:
DELETE FROM inf_timestamp;
--Testcase 55:
INSERT INTO inf_timestamp VALUES ('-infinity'::timestamp, '1995-08-06 12:12:12'::timestamp);
--Testcase 56:
SELECT t1 - t2 FROM inf_timestamp;

-- test age() with infinite timestamps
--Testcase 58:
DELETE FROM inf_timestamp;
--Testcase 59:
INSERT INTO inf_timestamp(t1) VALUES ('infinity'::timestamp);
--Testcase 60:
SELECT age(t1) FROM inf_timestamp;

--Testcase 61:
DELETE FROM inf_timestamp;
--Testcase 62:
INSERT INTO inf_timestamp(t1) VALUES ('-infinity'::timestamp);
--Testcase 63:
SELECT age(t1) FROM inf_timestamp;

--Testcase 64:
DELETE FROM inf_timestamp;
--Testcase 65:
INSERT INTO inf_timestamp VALUES ('infinity'::timestamp, 'infinity':: timestamp);
--Testcase 66:
SELECT age(t1, t2) FROM inf_timestamp;

--Testcase 67:
DELETE FROM inf_timestamp;
--Testcase 68:
INSERT INTO inf_timestamp VALUES ('infinity'::timestamp, '-infinity':: timestamp);
--Testcase 69:
SELECT age(t1, t2) FROM inf_timestamp;

--Testcase 70:
DELETE FROM inf_timestamp;
--Testcase 71:
INSERT INTO inf_timestamp VALUES ('-infinity'::timestamp, 'infinity':: timestamp);
--Testcase 72:
SELECT age(t1, t2) FROM inf_timestamp;

--Testcase 73:
DELETE FROM inf_timestamp;
--Testcase 74:
INSERT INTO inf_timestamp VALUES ('-infinity'::timestamp, '-infinity':: timestamp);
--Testcase 75:
SELECT age(t1, t2) FROM inf_timestamp;

--Testcase 35:
DROP FOREIGN TABLE dates1;
--Testcase 36:
DROP FOREIGN TABLE dates2;

--Testcase 57:
DROP FOREIGN TABLE inf_timestamp;
--Testcase 37:
DROP SERVER sqlite_svr;
--Testcase 38:
DROP EXTENSION sqlite_fdw CASCADE;
