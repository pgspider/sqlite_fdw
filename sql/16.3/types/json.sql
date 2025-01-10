--SET log_min_messages  TO DEBUG1;
--SET client_min_messages  TO DEBUG1;
--Testcase 001:
CREATE EXTENSION sqlite_fdw;
--Testcase 002:
CREATE SERVER sqlite_svr FOREIGN DATA WRAPPER sqlite_fdw
OPTIONS (database '/tmp/sqlite_fdw_test/common.db');

--Testcase 003:
CREATE SERVER sqlite2 FOREIGN DATA WRAPPER sqlite_fdw;

--Testcase 009:
CREATE FOREIGN TABLE "type_JSON" ( "i" int OPTIONS (key 'true'), "j" json, ot text, oi int) SERVER sqlite_svr OPTIONS (table 'type_JSON');
--Testcase 010:
CREATE FOREIGN TABLE "type_JSONB" ( "i" int OPTIONS (key 'true'), "j" jsonb, ot text, oi int) SERVER sqlite_svr OPTIONS (table 'type_JSONB');
--Testcase 011:
CREATE FOREIGN TABLE "JSON_query" ( "i" int OPTIONS (key 'true'), "q" text) SERVER sqlite_svr OPTIONS (table 'JSON_query');

--Testcase 012:
INSERT INTO "JSON_query" ("i", "q") VALUES
(1, '$'), (2, '$.c'), (3, 'c'), (4, '$.c[2]'), (5, '$.c[2].f'), (6, '$.c[#-1]'), (7, '$.x'), (8, '$.a'), (9, 'c[2]'), (10, 'c[2].f'), (11, 'c[#-1]'), (12, 'a');
--Testcase 013:
INSERT INTO "type_JSON" ("i", "j", ot, oi) VALUES
(1, '{"a":2,"c":[4,5,{"f":7}]}', 'c', 2), (2, '[11,22,33,44]', '2', 3), (3, '{"a":"xyz"}', 'a', 1), (4, '{"a":null}', 'a', 4);
--Testcase 014:
INSERT INTO "type_JSONB" ("i", "j", ot, oi) VALUES
(1, '{"a":2,"c":[4,5,{"f":7}]}'::json, 'c', 2), (2, '[11,22,33,44]'::json, '2', 3), (3, '{"a":"xyz"}'::json, 'a', 1), (4, '{"a":null}'::json, 'a', 4);

--Testcase 015:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", j."j"->'c' res FROM "type_JSON" j;
--Testcase 016:
SELECT "i", "j", j."j"->'c' res FROM "type_JSON" j;
--Testcase 017:
SELECT "i", "j", j."j"->'a' res FROM "type_JSON" j;
--Testcase 018:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", j."j"->'c' res FROM "type_JSONB" j;
--Testcase 019:
SELECT "i", "j", j."j"->'c' res FROM "type_JSONB" j;
--Testcase 020:
SELECT "i", "j", j."j"->'a' res FROM "type_JSONB" j;

--Testcase 021:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", j."j"->>'c' res FROM "type_JSON" j;
--Testcase 022:
SELECT "i", "j", j."j"->>'c' res FROM "type_JSON" j;
--Testcase 023:
SELECT "i", "j", j."j"->>'a' res FROM "type_JSON" j;
--Testcase 024:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", j."j"->>'c' res FROM "type_JSONB" j;
--Testcase 025:
SELECT "i", "j", j."j"->>'c' res FROM "type_JSONB" j;
--Testcase 026:
SELECT "i", "j", j."j"->>'a' res FROM "type_JSONB" j;

--Testcase 027:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j" FROM "type_JSON" j WHERE j."j"->'c' IS NOT NULL;
--Testcase 028:
SELECT "i", "j" FROM "type_JSON" j WHERE j."j"->'c' IS NOT NULL;
--Testcase 029:
SELECT "i", "j" FROM "type_JSON" j WHERE j."j"->'a' IS NOT NULL;
--Testcase 030:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j" FROM "type_JSONB" j WHERE j."j"->'c' IS NOT NULL;
--Testcase 031:
SELECT "i", "j" FROM "type_JSONB" j WHERE j."j"->'c' IS NOT NULL;
--Testcase 032:
SELECT "i", "j" FROM "type_JSONB" j WHERE j."j"->'a' IS NOT NULL;

--Testcase 033:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j" FROM "type_JSON" j WHERE j."j"->>'c' IS NOT NULL;
--Testcase 034:
SELECT "i", "j" FROM "type_JSON" j WHERE j."j"->>'c' IS NOT NULL;
--Testcase 035:
SELECT "i", "j" FROM "type_JSON" j WHERE j."j"->>'a' IS NOT NULL;
--Testcase 036:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j" FROM "type_JSONB" j WHERE j."j"->>'c' IS NOT NULL;
--Testcase 037:
SELECT "i", "j" FROM "type_JSONB" j WHERE j."j"->>'c' IS NOT NULL;
--Testcase 038:
SELECT "i", "j" FROM "type_JSONB" j WHERE j."j"->>'a' IS NOT NULL;

--Testcase 039:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", j."j" -> 1 res FROM "type_JSON" j;
--Testcase 040:
SELECT "i", "j", j."j" -> 1 res FROM "type_JSON" j;
--Testcase 041:
SELECT "i", "j", j."j" -> 3 res FROM "type_JSON" j;
--Testcase 042:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", j."j" -> 1 res FROM "type_JSONB" j;
--Testcase 043:
SELECT "i", "j", j."j" -> 1 res FROM "type_JSONB" j;
--Testcase 044:
SELECT "i", "j", j."j" -> 3 res FROM "type_JSONB" j;

--Testcase 045:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", j."j" ->> 1 res FROM "type_JSON" j;
--Testcase 046:
SELECT "i", "j", j."j" ->> 1 res FROM "type_JSON" j;
--Testcase 047:
SELECT "i", "j", j."j" ->> 3 res FROM "type_JSON" j;
--Testcase 048:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", j."j" ->> 1 res FROM "type_JSONB" j;
--Testcase 049:
SELECT "i", "j", j."j" ->> 1 res FROM "type_JSONB" j;
--Testcase 050:
SELECT "i", "j", j."j" ->> 3 res FROM "type_JSONB" j;

--Testcase 051:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j" FROM "type_JSON" j WHERE j."j" -> 1 IS NOT NULL;
--Testcase 052:
SELECT "i", "j" FROM "type_JSON" j WHERE j."j" -> 1 IS NOT NULL;
--Testcase 053:
SELECT "i", "j" FROM "type_JSON" j WHERE j."j" -> 3 IS NOT NULL;
--Testcase 054:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j" FROM "type_JSONB" j WHERE j."j" -> 1 IS NOT NULL;
--Testcase 055:
SELECT "i", "j" FROM "type_JSONB" j WHERE j."j" -> 1 IS NOT NULL;
--Testcase 056:
SELECT "i", "j" FROM "type_JSONB" j WHERE j."j" -> 3 IS NOT NULL;

--Testcase 057:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j" FROM "type_JSON" j WHERE j."j" ->> 1 IS NOT NULL;
--Testcase 058:
SELECT "i", "j" FROM "type_JSON" j WHERE j."j" ->> 1 IS NOT NULL;
--Testcase 059:
SELECT "i", "j" FROM "type_JSON" j WHERE j."j" ->> 3 IS NOT NULL;
--Testcase 060:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j" FROM "type_JSONB" j WHERE j."j" ->> 1 IS NOT NULL;
--Testcase 061:
SELECT "i", "j" FROM "type_JSONB" j WHERE j."j" ->> 1 IS NOT NULL;
--Testcase 062:
SELECT "i", "j" FROM "type_JSONB" j WHERE j."j" ->> 3 IS NOT NULL;

--Testcase 063:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", ot, j."j"->ot res FROM "type_JSON" j;
--Testcase 064:
SELECT "i", "j", ot, j."j"->ot res FROM "type_JSON" j;
--Testcase 065:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", ot, j."j"->>ot res FROM "type_JSON" j;
--Testcase 066:
SELECT "i", "j", ot, j."j"->>ot res FROM "type_JSON" j;
--Testcase 067:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", ot, j."j"->>ot res FROM "type_JSONB" j;
--Testcase 068:
SELECT "i", "j", ot, j."j"->>ot res FROM "type_JSONB" j;

--Testcase 069:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", ot FROM "type_JSON" j WHERE j."j"->ot IS NOT NULL;
--Testcase 070:
SELECT "i", "j", ot FROM "type_JSON" j WHERE j."j"->ot IS NOT NULL;
--Testcase 071:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", ot FROM "type_JSONB" j WHERE j."j"->ot IS NOT NULL;
--Testcase 072:
SELECT "i", "j", ot FROM "type_JSONB" j WHERE j."j"->ot IS NOT NULL;

--Testcase 073:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", ot FROM "type_JSON" j WHERE j."j"->>ot IS NOT NULL;
--Testcase 074:
SELECT "i", "j", ot FROM "type_JSON" j WHERE j."j"->>ot IS NOT NULL;
--Testcase 075:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", ot FROM "type_JSONB" j WHERE j."j"->>ot IS NOT NULL;
--Testcase 076:
SELECT "i", "j", ot FROM "type_JSONB" j WHERE j."j"->>ot IS NOT NULL;

--Testcase 077:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", oi, j."j" -> oi res FROM "type_JSON" j;
--Testcase 078:
SELECT "i", "j", oi, j."j" -> oi res FROM "type_JSON" j;
--Testcase 079:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", oi, j."j" -> oi res FROM "type_JSONB" j;
--Testcase 080:
SELECT "i", "j", oi, j."j" -> oi res FROM "type_JSONB" j;

--Testcase 081:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", oi, j."j" ->> oi res FROM "type_JSON" j;
--Testcase 082:
SELECT "i", "j", oi, j."j" ->> oi res FROM "type_JSON" j;
--Testcase 083:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", oi, j."j" ->> oi res FROM "type_JSONB" j;
--Testcase 084:
SELECT "i", "j", oi, j."j" ->> oi res FROM "type_JSONB" j;

--Testcase 085:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", oi FROM "type_JSON" j WHERE j."j" -> oi IS NOT NULL;
--Testcase 086:
SELECT "i", "j", oi FROM "type_JSON" j WHERE j."j" -> oi IS NOT NULL;
--Testcase 087:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", oi FROM "type_JSONB" j WHERE j."j" -> oi IS NOT NULL;
--Testcase 088:
SELECT "i", "j", oi FROM "type_JSONB" j WHERE j."j" -> oi IS NOT NULL;

--Testcase 089:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", oi FROM "type_JSON" j WHERE j."j" ->> oi IS NOT NULL;
--Testcase 090:
SELECT "i", "j", oi FROM "type_JSON" j WHERE j."j" ->> oi IS NOT NULL;
--Testcase 091:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", oi FROM "type_JSONB" j WHERE j."j" ->> oi IS NOT NULL;
--Testcase 092:
SELECT "i", "j", oi FROM "type_JSONB" j WHERE j."j" ->> oi IS NOT NULL;


--Testcase 093:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", j."j"-> 'c' -> 2 ->> 'f' res FROM "type_JSON" j;
--Testcase 094:
SELECT "i", "j", j."j"-> 'c' -> 2 ->> 'f' res FROM "type_JSON" j;
--Testcase 095:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", j."j"-> 'c' -> 2 ->> 'f' res FROM "type_JSONB" j;
--Testcase 096:
SELECT "i", "j", j."j"-> 'c' -> 2 ->> 'f' res FROM "type_JSONB" j;


--Testcase 200:
DROP EXTENSION sqlite_fdw CASCADE;
