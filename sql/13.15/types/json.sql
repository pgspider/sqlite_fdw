-- SET log_min_messages TO DEBUG3;
-- SET client_min_messages TO DEBUG3;
--Testcase 001:
CREATE EXTENSION sqlite_fdw;
--Testcase 002:
CREATE SERVER sqlite_svr FOREIGN DATA WRAPPER sqlite_fdw
OPTIONS (database '/tmp/sqlite_fdw_test/common.db');

--Testcase 010:
CREATE FOREIGN TABLE "type_JSON" (
	"i" int OPTIONS (key 'true'),
	"j" json,
	ot text,
	ot1 text,
	oi int,
	oi1 int2,
	q text[],
	"j1" json
) SERVER sqlite_svr OPTIONS (table 'type_JSON');
--Testcase 011:
CREATE FOREIGN TABLE "type_JSONB" (
	"i" int OPTIONS (key 'true'),
	"j" jsonb,
	ot text,
	ot1 text,
	oi int,
	oi1 int2,
	q text[],
	"j1" jsonb
) SERVER sqlite_svr OPTIONS (table 'type_JSONB');
--Testcase 012:
CREATE FOREIGN TABLE "type_JSONB+" (
	"i" int OPTIONS (key 'true'),
	"j" jsonb,
	l int, t varchar(16), tx text,	
	ot text,
	ot1 text,
	oi int,
	oi1 int2,
	q text[],
	"j1" jsonb
) SERVER sqlite_svr OPTIONS (table 'type_JSONB+');

--Testcase 013:
INSERT INTO "type_JSON" ("i", "j", ot, ot1, oi, oi1) VALUES
(1, '{"a":2,"c":[4,5,{"f":7}],"a+u":47,"5":true,"cc3":["a", "b", "c"], "c3":[true, false]}',
'c', 'c3', 2, 1),
(2, '[11,22,33,44,55,66,77,88,99,10,11,12,13,14]',
'1', '29', 3, 1),
(3, '{"a":"xyz", "π":3.1415926535, "aπ":false }',
'a', 'π', 1, NULL),
(4, '{"a":null, "a22":22.0, "a2":2 }',
'a', '22', 4, NULL),
(5, '[9,null,7,6,5,4,3,2,1,0]',
'1', '5', -4, 5),
(6, '[0.0,1.1,2.2,3.3,4.4,5.5,6.6,7.7,8.8,9.9,null,true]',
'1', '21', -2, 5);

--Testcase 014:
INSERT INTO "type_JSONB" SELECT * FROM "type_JSON";
--Testcase 015: check some SQLite JSONb initial bytes
SELECT i, tx FROM "type_JSONB+";

--Testcase 020:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", j."j"->'c' res FROM "type_JSON" j;
--Testcase 021: SQLite queries to type_JSON will be without normalization for j column
ALTER FOREIGN TABLE "type_JSON" ALTER COLUMN j OPTIONS (ADD column_type 'text');
--Testcase 022:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", j."j"->'c' res FROM "type_JSON" j;

--Testcase 023:
SELECT "i", "j", j."j"->'c' res FROM "type_JSON" j;
--Testcase 024:
SELECT "i", "j", j."j"->'a' res FROM "type_JSON" j;
--Testcase 025:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", j."j"->'c' res, l, t, tx FROM "type_JSONB+" j;
--Testcase 026:
SELECT "i", "j", j."j"->'c' res, l, t, tx FROM "type_JSONB+" j;
--Testcase 027:
SELECT "i", "j", j."j"->'a' res, l, t, tx FROM "type_JSONB+" j;

--Testcase 028:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", j."j"->>'c' res FROM "type_JSON" j;
--Testcase 029:
SELECT "i", "j", j."j"->>'c' res FROM "type_JSON" j;
--Testcase 030:
SELECT "i", "j", j."j"->>'a' res FROM "type_JSON" j;
--Testcase 031:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", j."j"->>'c' res, l, t, tx FROM "type_JSONB+" j;
--Testcase 032:
SELECT "i", "j", j."j"->>'c' res, l, t, tx FROM "type_JSONB+" j;
--Testcase 033:
SELECT "i", "j", j."j"->>'a' res, l, t, tx FROM "type_JSONB+" j;

--Testcase 034:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j" FROM "type_JSON" j WHERE j."j"->'c' IS NOT NULL;
--Testcase 035:
SELECT "i", "j" FROM "type_JSON" j WHERE j."j"->'c' IS NOT NULL;
--Testcase 036:
SELECT "i", "j" FROM "type_JSON" j WHERE j."j"->'a' IS NOT NULL;
--Testcase 037:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j" FROM "type_JSONB" j WHERE j."j"->'c' IS NOT NULL;
--Testcase 038:
SELECT "i", "j" FROM "type_JSONB" j WHERE j."j"->'c' IS NOT NULL;
--Testcase 039:
SELECT "i", "j" FROM "type_JSONB" j WHERE j."j"->'a' IS NOT NULL;

--Testcase 040:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j" FROM "type_JSON" j WHERE j."j"->>'c' IS NOT NULL;
--Testcase 041:
SELECT "i", "j" FROM "type_JSON" j WHERE j."j"->>'c' IS NOT NULL;
--Testcase 042:
SELECT "i", "j" FROM "type_JSON" j WHERE j."j"->>'a' IS NOT NULL;
--Testcase 043:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j" FROM "type_JSONB" j WHERE j."j"->>'c' IS NOT NULL;
--Testcase 044:
SELECT "i", "j" FROM "type_JSONB" j WHERE j."j"->>'c' IS NOT NULL;
--Testcase 045:
SELECT "i", "j" FROM "type_JSONB" j WHERE j."j"->>'a' IS NOT NULL;

--Testcase 046:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", j."j" -> 1 res FROM "type_JSON" j;
--Testcase 047:
SELECT "i", "j", j."j" -> 1 res FROM "type_JSON" j;
--Testcase 048:
SELECT "i", "j", j."j" -> 10 res FROM "type_JSON" j;
--Testcase 049:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", j."j" -> 1 res FROM "type_JSONB" j;
--Testcase 050:
SELECT "i", "j", j."j" -> 1 res FROM "type_JSONB" j;
--Testcase 051:
SELECT "i", "j", j."j" -> 10 res FROM "type_JSONB" j;

--Testcase 052:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", j."j" ->> 1 res FROM "type_JSON" j;
--Testcase 053:
SELECT "i", "j", j."j" ->> 1 res FROM "type_JSON" j;
--Testcase 054:
SELECT "i", "j", j."j" ->> 10 res FROM "type_JSON" j;
--Testcase 055:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", j."j" ->> 1 res FROM "type_JSONB" j;
--Testcase 056:
SELECT "i", "j", j."j" ->> 1 res FROM "type_JSONB" j;
--Testcase 057:
SELECT "i", "j", j."j" ->> 10 res FROM "type_JSONB" j;

--Testcase 058:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j" FROM "type_JSON" j WHERE j."j" -> 1 IS NOT NULL;
--Testcase 059:
SELECT "i", "j" FROM "type_JSON" j WHERE j."j" -> 1 IS NOT NULL;
--Testcase 060:
SELECT "i", "j" FROM "type_JSON" j WHERE j."j" -> 10 IS NOT NULL;
--Testcase 061:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j" FROM "type_JSONB" j WHERE j."j" -> 1 IS NOT NULL;
--Testcase 062:
SELECT "i", "j" FROM "type_JSONB" j WHERE j."j" -> 1 IS NOT NULL;
--Testcase 063:
SELECT "i", "j" FROM "type_JSONB" j WHERE j."j" -> 10 IS NOT NULL;

--Testcase 064:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j" FROM "type_JSON" j WHERE j."j" ->> 1 IS NOT NULL;
--Testcase 065:
SELECT "i", "j" FROM "type_JSON" j WHERE j."j" ->> 1 IS NOT NULL;
--Testcase 066:
SELECT "i", "j" FROM "type_JSON" j WHERE j."j" ->> 10 IS NOT NULL;
--Testcase 067:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j" FROM "type_JSONB" j WHERE j."j" ->> 1 IS NOT NULL;
--Testcase 068:
SELECT "i", "j" FROM "type_JSONB" j WHERE j."j" ->> 1 IS NOT NULL;
--Testcase 069:
SELECT "i", "j" FROM "type_JSONB" j WHERE j."j" ->> 10 IS NOT NULL;

--Testcase 070:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", ot, j."j"->ot res FROM "type_JSON" j;
--Testcase 071:
SELECT "i", "j", ot, j."j"->ot res FROM "type_JSON" j;
--Testcase 072:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", ot, j."j"->>ot res FROM "type_JSON" j;
--Testcase 073:
SELECT "i", "j", ot, j."j"->>ot res FROM "type_JSON" j;
--Testcase 074:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", ot, j."j"->>ot res FROM "type_JSONB" j;
--Testcase 075:
SELECT "i", "j", ot, j."j"->>ot res FROM "type_JSONB" j;

--Testcase 076:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", ot FROM "type_JSON" j WHERE j."j"->ot IS NOT NULL;
--Testcase 077:
SELECT "i", "j", ot FROM "type_JSON" j WHERE j."j"->ot IS NOT NULL;
--Testcase 078:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", ot FROM "type_JSONB" j WHERE j."j"->ot IS NOT NULL;
--Testcase 079:
SELECT "i", "j", ot FROM "type_JSONB" j WHERE j."j"->ot IS NOT NULL;

--Testcase 080:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", ot FROM "type_JSON" j WHERE j."j"->>ot IS NOT NULL;
--Testcase 081:
SELECT "i", "j", ot FROM "type_JSON" j WHERE j."j"->>ot IS NOT NULL;
--Testcase 082:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", ot FROM "type_JSONB" j WHERE j."j"->>ot IS NOT NULL;
--Testcase 083:
SELECT "i", "j", ot FROM "type_JSONB" j WHERE j."j"->>ot IS NOT NULL;

--Testcase 084:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", oi, j."j" -> oi res FROM "type_JSON" j;
--Testcase 085:
SELECT "i", "j", oi, j."j" -> oi res FROM "type_JSON" j;
--Testcase 086:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", oi, j."j" -> oi res FROM "type_JSONB" j;
--Testcase 087:
SELECT "i", "j", oi, j."j" -> oi res FROM "type_JSONB" j;

--Testcase 088:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", oi, j."j" ->> oi res FROM "type_JSON" j;
--Testcase 089:
SELECT "i", "j", oi, j."j" ->> oi res FROM "type_JSON" j;
--Testcase 090:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", oi, j."j" ->> oi res FROM "type_JSONB" j;
--Testcase 091:
SELECT "i", "j", oi, j."j" ->> oi res FROM "type_JSONB" j;

--Testcase 092:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", oi FROM "type_JSON" j WHERE j."j" -> oi IS NOT NULL;
--Testcase 093:
SELECT "i", "j", oi FROM "type_JSON" j WHERE j."j" -> oi IS NOT NULL;
--Testcase 094:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", oi FROM "type_JSONB" j WHERE j."j" -> oi IS NOT NULL;
--Testcase 095:
SELECT "i", "j", oi FROM "type_JSONB" j WHERE j."j" -> oi IS NOT NULL;

--Testcase 096:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", oi FROM "type_JSON" j WHERE j."j" ->> oi IS NOT NULL;
--Testcase 097:
SELECT "i", "j", oi FROM "type_JSON" j WHERE j."j" ->> oi IS NOT NULL;
--Testcase 098:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", oi FROM "type_JSONB" j WHERE j."j" ->> oi IS NOT NULL;
--Testcase 099:
SELECT "i", "j", oi FROM "type_JSONB" j WHERE j."j" ->> oi IS NOT NULL;

-- extraction with arithmetical an other expressions
--Testcase 100:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", j."j" -> (oi + oi1) res, oi + oi1 expr FROM "type_JSON" j WHERE j."j" -> (oi + oi1) IS NOT NULL;
--Testcase 101:
SELECT "i", "j", j."j" -> (oi + oi1) res, oi + oi1 expr FROM "type_JSON" j WHERE j."j" -> (oi + oi1) IS NOT NULL;
--Testcase 102:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", j."j" -> (oi + oi1) res, oi + oi1 expr FROM "type_JSON" j WHERE j."j" -> (oi + oi1) IS NULL;
--Testcase 103:
SELECT "i", "j", j."j" -> (oi + oi1) res, oi + oi1 expr FROM "type_JSON" j WHERE j."j" -> (oi + oi1) IS NULL;
--Testcase 104:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", j."j" ->> (oi + oi1) res, oi + oi1 expr FROM "type_JSON" j WHERE j."j" ->> (oi + oi1) IS NOT NULL;
--Testcase 105:
SELECT "i", "j", j."j" ->> (oi + oi1) res, oi + oi1 expr FROM "type_JSON" j WHERE j."j" ->> (oi + oi1) IS NOT NULL;
--Testcase 106:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", j."j" ->> (oi + oi1) res, oi + oi1 expr FROM "type_JSON" j WHERE j."j" ->> (oi + oi1) IS NULL;
--Testcase 107:
SELECT "i", "j", j."j" ->> (oi + oi1) res, oi + oi1 expr FROM "type_JSON" j WHERE j."j" ->> (oi + oi1) IS NULL;
--Testcase 108:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", j."j" -> (oi + oi1) res, oi + oi1 expr FROM "type_JSONB" j WHERE j."j" -> (oi + oi1) IS NOT NULL;
--Testcase 109:
SELECT "i", "j", j."j" -> (oi + oi1) res, oi + oi1 expr FROM "type_JSONB" j WHERE j."j" -> (oi + oi1) IS NOT NULL;
--Testcase 110:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", j."j" -> (oi + oi1) res, oi + oi1 expr FROM "type_JSONB" j WHERE j."j" -> (oi + oi1) IS NULL;
--Testcase 111:
SELECT "i", "j", j."j" -> (oi + oi1) res, oi + oi1 expr FROM "type_JSONB" j WHERE j."j" -> (oi + oi1) IS NULL;
--Testcase 112:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", j."j" ->> (oi + oi1) res, oi + oi1 expr FROM "type_JSONB" j WHERE j."j" ->> (oi + oi1) IS NOT NULL;
--Testcase 113:
SELECT "i", "j", j."j" ->> (oi + oi1) res, oi + oi1 expr FROM "type_JSONB" j WHERE j."j" ->> (oi + oi1) IS NOT NULL;
--Testcase 114:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", j."j" ->> (oi + oi1) res, oi + oi1 expr FROM "type_JSONB" j WHERE j."j" ->> (oi + oi1) IS NULL;
--Testcase 115:
SELECT "i", "j", j."j" ->> (oi + oi1) res, oi + oi1 expr FROM "type_JSONB" j WHERE j."j" ->> (oi + oi1) IS NULL;

--Testcase 116:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", j."j" -> (oi - oi1) res, oi - oi1 expr FROM "type_JSON" j WHERE j."j" -> (oi - oi1) IS NOT NULL;
--Testcase 117:
SELECT "i", "j", j."j" -> (oi - oi1) res, oi - oi1 expr FROM "type_JSON" j WHERE j."j" -> (oi - oi1) IS NOT NULL;
--Testcase 118:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", j."j" -> (oi - oi1) res, oi - oi1 expr FROM "type_JSON" j WHERE j."j" -> (oi - oi1) IS NULL;
--Testcase 119:
SELECT "i", "j", j."j" -> (oi - oi1) res, oi - oi1 expr FROM "type_JSON" j WHERE j."j" -> (oi - oi1) IS NULL;
--Testcase 120:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", j."j" ->> (oi - oi1) res, oi - oi1 expr FROM "type_JSON" j WHERE j."j" ->> (oi - oi1) IS NOT NULL;
--Testcase 121:
SELECT "i", "j", j."j" ->> (oi - oi1) res, oi - oi1 expr FROM "type_JSON" j WHERE j."j" ->> (oi - oi1) IS NOT NULL;
--Testcase 122:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", j."j" ->> (oi - oi1) res, oi - oi1 expr FROM "type_JSON" j WHERE j."j" ->> (oi - oi1) IS NULL;
--Testcase 123:
SELECT "i", "j", j."j" ->> (oi - oi1) res, oi - oi1 expr FROM "type_JSON" j WHERE j."j" ->> (oi - oi1) IS NULL;
--Testcase 124:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", j."j" -> (oi - oi1) res, oi - oi1 expr FROM "type_JSONB" j WHERE j."j" -> (oi - oi1) IS NOT NULL;
--Testcase 125:
SELECT "i", "j", j."j" -> (oi - oi1) res, oi - oi1 expr FROM "type_JSONB" j WHERE j."j" -> (oi - oi1) IS NOT NULL;
--Testcase 126:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", j."j" -> (oi - oi1) res, oi - oi1 expr FROM "type_JSONB" j WHERE j."j" -> (oi - oi1) IS NULL;
--Testcase 127:
SELECT "i", "j", j."j" -> (oi - oi1) res, oi - oi1 expr FROM "type_JSONB" j WHERE j."j" -> (oi - oi1) IS NULL;
--Testcase 128:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", j."j" ->> (oi - oi1) res, oi - oi1 expr FROM "type_JSONB" j WHERE j."j" ->> (oi - oi1) IS NOT NULL;
--Testcase 129:
SELECT "i", "j", j."j" ->> (oi - oi1) res, oi - oi1 expr FROM "type_JSONB" j WHERE j."j" ->> (oi - oi1) IS NOT NULL;
--Testcase 130:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", j."j" ->> (oi - oi1) res, oi - oi1 expr FROM "type_JSONB" j WHERE j."j" ->> (oi - oi1) IS NULL;
--Testcase 131:
SELECT "i", "j", j."j" ->> (oi - oi1) res, oi - oi1 expr FROM "type_JSONB" j WHERE j."j" ->> (oi - oi1) IS NULL;

--Testcase 132:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", j."j" -> (oi + 2) res, oi + 2 expr FROM "type_JSON" j WHERE j."j" -> (oi + 2) IS NOT NULL;
--Testcase 133:
SELECT "i", "j", j."j" -> (oi + 2) res, oi + 2 expr FROM "type_JSON" j WHERE j."j" -> (oi + 2) IS NOT NULL;
--Testcase 134:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", j."j" -> (oi + 2) res, oi + 2 expr FROM "type_JSON" j WHERE j."j" -> (oi + 2) IS NULL;
--Testcase 135:
SELECT "i", "j", j."j" -> (oi + 2) res, oi + 2 expr FROM "type_JSON" j WHERE j."j" -> (oi + 2) IS NULL;
--Testcase 136:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", j."j" ->> (oi + 2) res, oi + 2 expr FROM "type_JSON" j WHERE j."j" ->> (oi + 2) IS NOT NULL;
--Testcase 137:
SELECT "i", "j", j."j" ->> (oi + 2) res, oi + 2 expr FROM "type_JSON" j WHERE j."j" ->> (oi + 2) IS NOT NULL;
--Testcase 138:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", j."j" ->> (oi + 2) res, oi + 2 expr FROM "type_JSON" j WHERE j."j" ->> (oi + 2) IS NULL;
--Testcase 139:
SELECT "i", "j", j."j" ->> (oi + 2) res, oi + 2 expr FROM "type_JSON" j WHERE j."j" ->> (oi + 2) IS NULL;
--Testcase 140:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", j."j" -> (oi + 2) res, oi + 2 expr FROM "type_JSONB" j WHERE j."j" -> (oi + 2) IS NOT NULL;
--Testcase 141:
SELECT "i", "j", j."j" -> (oi + 2) res, oi + 2 expr FROM "type_JSONB" j WHERE j."j" -> (oi + 2) IS NOT NULL;
--Testcase 142:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", j."j" -> (oi + 2) res, oi + 2 expr FROM "type_JSONB" j WHERE j."j" -> (oi + 2) IS NULL;
--Testcase 143:
SELECT "i", "j", j."j" -> (oi + 2) res, oi + 2 expr FROM "type_JSONB" j WHERE j."j" -> (oi + 2) IS NULL;
--Testcase 144:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", j."j" ->> (oi + 2) res, oi + 2 expr FROM "type_JSONB" j WHERE j."j" ->> (oi + 2) IS NOT NULL;
--Testcase 145:
SELECT "i", "j", j."j" ->> (oi + 2) res, oi + 2 expr FROM "type_JSONB" j WHERE j."j" ->> (oi + 2) IS NOT NULL;
--Testcase 146:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", j."j" ->> (oi + 2) res, oi + 2 expr FROM "type_JSONB" j WHERE j."j" ->> (oi + 2) IS NULL;
--Testcase 147:
SELECT "i", "j", j."j" ->> (oi + 2) res, oi + 2 expr FROM "type_JSONB" j WHERE j."j" ->> (oi + 2) IS NULL;

--Testcase 148:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", j."j" -> (ot || ot1) res, ot || ot1 expr FROM "type_JSON" j WHERE j."j" -> (ot || ot1) IS NOT NULL;
--Testcase 149:
SELECT "i", "j", j."j" -> (ot || ot1) res, ot || ot1 expr FROM "type_JSON" j WHERE j."j" -> (ot || ot1) IS NOT NULL;
--Testcase 150:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", j."j" -> (ot || ot1) res, ot || ot1 expr FROM "type_JSON" j WHERE j."j" -> (ot || ot1) IS NULL;
--Testcase 151:
SELECT "i", "j", j."j" -> (ot || ot1) res, ot || ot1 expr FROM "type_JSON" j WHERE j."j" -> (ot || ot1) IS NULL;
--Testcase 152:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", j."j" ->> (ot || ot1) res, ot || ot1 expr FROM "type_JSON" j WHERE j."j" ->> (ot || ot1) IS NOT NULL;
--Testcase 153:
SELECT "i", "j", j."j" ->> (ot || ot1) res, ot || ot1 expr FROM "type_JSON" j WHERE j."j" ->> (ot || ot1) IS NOT NULL;
--Testcase 154:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", j."j" ->> (ot || ot1) res, ot || ot1 expr FROM "type_JSON" j WHERE j."j" ->> (ot || ot1) IS NULL;
--Testcase 155:
SELECT "i", "j", j."j" ->> (ot || ot1) res, ot || ot1 expr FROM "type_JSON" j WHERE j."j" ->> (ot || ot1) IS NULL;
--Testcase 156:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", j."j" -> (ot || ot1) res, ot || ot1 expr FROM "type_JSONB" j WHERE j."j" -> (ot || ot1) IS NOT NULL;
--Testcase 157:
SELECT "i", "j", j."j" -> (ot || ot1) res, ot || ot1 expr FROM "type_JSONB" j WHERE j."j" -> (ot || ot1) IS NOT NULL;
--Testcase 158:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", j."j" -> (ot || ot1) res, ot || ot1 expr FROM "type_JSONB" j WHERE j."j" -> (ot || ot1) IS NULL;
--Testcase 159:
SELECT "i", "j", j."j" -> (ot || ot1) res, ot || ot1 expr FROM "type_JSONB" j WHERE j."j" -> (ot || ot1) IS NULL;
--Testcase 160:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", j."j" ->> (ot || ot1) res, ot || ot1 expr FROM "type_JSONB" j WHERE j."j" ->> (ot || ot1) IS NOT NULL;
--Testcase 161:
SELECT "i", "j", j."j" ->> (ot || ot1) res, ot || ot1 expr FROM "type_JSONB" j WHERE j."j" ->> (ot || ot1) IS NOT NULL;
--Testcase 162:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", j."j" ->> (ot || ot1) res, ot || ot1 expr FROM "type_JSONB" j WHERE j."j" ->> (ot || ot1) IS NULL;
--Testcase 163:
SELECT "i", "j", j."j" ->> (ot || ot1) res, ot || ot1 expr FROM "type_JSONB" j WHERE j."j" ->> (ot || ot1) IS NULL;

--Testcase 164:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", j."j" -> (ot || substr(ot1, 2, 1)) res, ot || substr(ot1, 2, 1) expr FROM "type_JSON" j WHERE j."j" -> (ot || substr(ot1, 2, 1)) IS NOT NULL;
--Testcase 165:
SELECT "i", "j", j."j" -> (ot || substr(ot1, 2, 1)) res, ot || substr(ot1, 2, 1) expr FROM "type_JSON" j WHERE j."j" -> (ot || substr(ot1, 2, 1)) IS NOT NULL;
--Testcase 166:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", j."j" -> (ot || substr(ot1, 2, 1)) res, ot || substr(ot1, 2, 1) expr FROM "type_JSON" j WHERE j."j" -> (ot || substr(ot1, 2, 1)) IS NULL;
--Testcase 167:
SELECT "i", "j", j."j" -> (ot || substr(ot1, 2, 1)) res, ot || substr(ot1, 2, 1) expr FROM "type_JSON" j WHERE j."j" -> (ot || substr(ot1, 2, 1)) IS NULL;
--Testcase 168:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", j."j" ->> (ot || substr(ot1, 2, 1)) res, ot || substr(ot1, 2, 1) expr FROM "type_JSON" j WHERE j."j" ->> (ot || substr(ot1, 2, 1)) IS NOT NULL;
--Testcase 169:
SELECT "i", "j", j."j" ->> (ot || substr(ot1, 2, 1)) res, ot || substr(ot1, 2, 1) expr FROM "type_JSON" j WHERE j."j" ->> (ot || substr(ot1, 2, 1)) IS NOT NULL;
--Testcase 170:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", j."j" ->> (ot || substr(ot1, 2, 1)) res, ot || substr(ot1, 2, 1) expr FROM "type_JSON" j WHERE j."j" ->> (ot || substr(ot1, 2, 1)) IS NULL;
--Testcase 171:
SELECT "i", "j", j."j" ->> (ot || substr(ot1, 2, 1)) res, ot || substr(ot1, 2, 1) expr FROM "type_JSON" j WHERE j."j" ->> (ot || substr(ot1, 2, 1)) IS NULL;
--Testcase 172:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", j."j" -> (ot || substr(ot1, 2, 1)) res, ot || substr(ot1, 2, 1) expr FROM "type_JSONB" j WHERE j."j" -> (ot || substr(ot1, 2, 1)) IS NOT NULL;
--Testcase 173:
SELECT "i", "j", j."j" -> (ot || substr(ot1, 2, 1)) res, ot || substr(ot1, 2, 1) expr FROM "type_JSONB" j WHERE j."j" -> (ot || substr(ot1, 2, 1)) IS NOT NULL;
--Testcase 174:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", j."j" -> (ot || substr(ot1, 2, 1)) res, ot || substr(ot1, 2, 1) expr FROM "type_JSONB" j WHERE j."j" -> (ot || substr(ot1, 2, 1)) IS NULL;
--Testcase 175:
SELECT "i", "j", j."j" -> (ot || substr(ot1, 2, 1)) res, ot || substr(ot1, 2, 1) expr FROM "type_JSONB" j WHERE j."j" -> (ot || substr(ot1, 2, 1)) IS NULL;
--Testcase 176:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", j."j" ->> (ot || substr(ot1, 2, 1)) res, ot || substr(ot1, 2, 1) expr FROM "type_JSONB" j WHERE j."j" ->> (ot || substr(ot1, 2, 1)) IS NOT NULL;
--Testcase 177:
SELECT "i", "j", j."j" ->> (ot || substr(ot1, 2, 1)) res, ot || substr(ot1, 2, 1) expr FROM "type_JSONB" j WHERE j."j" ->> (ot || substr(ot1, 2, 1)) IS NOT NULL;
--Testcase 178:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", j."j" ->> (ot || substr(ot1, 2, 1)) res, ot || substr(ot1, 2, 1) expr FROM "type_JSONB" j WHERE j."j" ->> (ot || substr(ot1, 2, 1)) IS NULL;
--Testcase 179:
SELECT "i", "j", j."j" ->> (ot || substr(ot1, 2, 1)) res, ot || substr(ot1, 2, 1) expr FROM "type_JSONB" j WHERE j."j" ->> (ot || substr(ot1, 2, 1)) IS NULL;


--TCs for SQLite JSON -> format, no sense in PostgreSQL itself
--Testcase 200:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j" FROM "type_JSON" j WHERE j."j"->>'$.c[2].f' IS NOT NULL;
--Testcase 201:
SELECT "i", "j" FROM "type_JSON" j WHERE j."j"->>'$.c[2].f' IS NOT NULL;

--Testcase 202:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j" FROM "type_JSON" j WHERE j."j"->>'$.c[2].f' IS NULL;
--Testcase 203:
SELECT "i", "j" FROM "type_JSON" j WHERE j."j"->>'$.c[2].f' IS NULL;

--Testcase 204:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j" FROM "type_JSONB" j WHERE j."j"->>'$.c[2].f' IS NOT NULL;
--Testcase 205:
SELECT "i", "j" FROM "type_JSONB" j WHERE j."j"->>'$.c[2].f' IS NOT NULL;

--Testcase 206:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j" FROM "type_JSONB" j WHERE j."j"->>'$.c[2].f' IS NULL;
--Testcase 207:
SELECT "i", "j" FROM "type_JSONB" j WHERE j."j"->>'$.c[2].f' IS NULL;

--Testcase 208:
DELETE FROM "type_JSON"; 
--Testcase 209:
DELETE FROM "type_JSONB";
--Testcase 210:
INSERT INTO "type_JSON" ("i", "j", ot, oi) VALUES
(1, '{"a":2,"c":[4,5,{"f":7}]}', '$', NULL),
(2, '{"a":2,"c":[4,5,{"f":7}]}', '$.c', NULL),
(3, '{"a":2,"c":[4,5,{"f":7}]}', 'c', NULL),
(4, '{"a":2,"c":[4,5,{"f":7}]}', '$.c[2]', NULL),
(5, '{"a":2,"c":[4,5,{"f":7}]}', '$.c[2].f', NULL),
(6, '{"a":2,"c":[4,5],"f":7}', '$.c[#-1]', NULL),
(7, '{"a":2,"c":[4,5],"f":7}', '$.e', NULL);
--Testcase 211:
INSERT INTO "type_JSONB" ("i", "j", ot, oi) VALUES
(1, '{"a":2,"c":[4,5,{"f":7}]}', '$', NULL),
(2, '{"a":2,"c":[4,5,{"f":7}]}', '$.c', NULL),
(3, '{"a":2,"c":[4,5,{"f":7}]}', 'c', NULL),
(4, '{"a":2,"c":[4,5,{"f":7}]}', '$.c[2]', NULL),
(5, '{"a":2,"c":[4,5,{"f":7}]}', '$.c[2].f', NULL),
(6, '{"a":2,"c":[4,5],"f":7}', '$.c[#-1]', NULL),
(7, '{"a":2,"c":[4,5],"f":7}', '$.e', NULL);
--Testcase 212:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", ot, "j" ->> ot res FROM "type_JSON" j WHERE j."j"->>ot IS NOT NULL;
--Testcase 213:
SELECT "i", "j", ot, "j" ->> ot res FROM "type_JSON" j WHERE j."j"->>ot IS NOT NULL;
--Testcase 214:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", ot, "j" ->> ot res FROM "type_JSON" j WHERE j."j"->>ot IS NULL;
--Testcase 215:
SELECT "i", "j", ot, "j" ->> ot res FROM "type_JSON" j WHERE j."j"->>ot IS NULL;

--Testcase 216:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", ot, "j" ->> ot res FROM "type_JSONB" j WHERE j."j"->>ot IS NOT NULL;
--Testcase 217:
SELECT "i", "j", ot, "j" ->> ot res FROM "type_JSONB" j WHERE j."j"->>ot IS NOT NULL;
--Testcase 218:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", ot, "j" ->> ot res FROM "type_JSONB" j WHERE j."j"->>ot IS NULL;
--Testcase 219:
SELECT "i", "j", ot, "j" ->> ot res FROM "type_JSONB" j WHERE j."j"->>ot IS NULL;

--Testcase 220:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", ot, "j" -> ot res FROM "type_JSON" j WHERE j."j"->ot IS NOT NULL;
--Testcase 221:
SELECT "i", "j", ot, "j" -> ot res FROM "type_JSON" j WHERE j."j"->ot IS NOT NULL;
--Testcase 222:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", ot, "j" -> ot res FROM "type_JSON" j WHERE j."j"->ot IS NULL;
--Testcase 223:
SELECT "i", "j", ot, "j" -> ot res FROM "type_JSON" j WHERE j."j"->ot IS NULL;
--Testcase 224:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", ot, "j" -> ot res FROM "type_JSONB" j WHERE j."j"->ot IS NOT NULL;
--Testcase 225:
SELECT "i", "j", ot, "j" -> ot res FROM "type_JSONB" j WHERE j."j"->ot IS NOT NULL;
--Testcase 226:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", ot, "j" -> ot res FROM "type_JSONB" j WHERE j."j"->ot IS NULL;
--Testcase 227:
SELECT "i", "j", ot, "j" -> ot res FROM "type_JSONB" j WHERE j."j"->ot IS NULL;
-- end of SQLite right -> ->> operand test

-- Operators -> ->> in SELECT context
--Testcase 230:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j"->>ot "r" FROM "type_JSON" j;
--Testcase 231:
SELECT "i", "j"->>ot "r" FROM "type_JSON" j;

--Testcase 232:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j"->>ot "r" FROM "type_JSONB" j;
--Testcase 233:
SELECT "i", "j"->>ot "r" FROM "type_JSONB" j;

--Testcase 234:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j"->ot "r" FROM "type_JSON" j;
--Testcase 235:
SELECT "i", "j"->ot "r" FROM "type_JSON" j;

--Testcase 236:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j"->ot "r" FROM "type_JSONB" j;
--Testcase 237:
SELECT "i", "j"->ot "r" FROM "type_JSONB" j;

--Testcase 238:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", j."j" #> q "r" FROM "type_JSON" j;
--Testcase 239:
SELECT "i", j."j" #> q "r" FROM "type_JSON" j;

--Testcase 240:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", j."j" #> q "r" FROM "type_JSONB" j;
--Testcase 241:
SELECT "i", j."j" #> q "r" FROM "type_JSONB" j;

--Testcase 250:
DELETE FROM "type_JSON"; 
--Testcase 251:
DELETE FROM "type_JSONB";
--Testcase 252:
ALTER FOREIGN TABLE "type_JSON" ALTER COLUMN "q" TYPE text;
--Testcase 253:
INSERT INTO "type_JSON" ("i", "j", q, ot) VALUES
(1, '{"a":2,"c":[4,5,{"f":7}]}', '{a}', NULL),
(2, '{"a":2,"c":[4,5,{"f":7}]}', '{c}', NULL),
(3, '{"a":2,"c":[4,5,{"f":7}]}', '{c,2}', NULL),
(4, '{"a":2,"c":[4,5,{"f":7}]}', '{c,2,f}', NULL),
(5, '{"a":2,"c":[4,5],"f":7}', '{c,-1}', NULL),
(6, '{"a":2,"c":[4,5],"f":7}', '{u,8,i}', NULL),
(7, '{"a":2}', '{a}', NULL);
--Testcase 254:
ALTER FOREIGN TABLE "type_JSON" ALTER COLUMN "q" TYPE text[];

--Testcase 255:
ALTER FOREIGN TABLE "type_JSONB" ALTER COLUMN "q" TYPE text;
--Testcase 256:
INSERT INTO "type_JSONB" ("i", "j", q, ot) VALUES
(1, '{"a":2,"c":[4,5,{"f":7}]}', '{a}', NULL),
(2, '{"a":2,"c":[4,5,{"f":7}]}', '{c}', NULL),
(3, '{"a":2,"c":[4,5,{"f":7}]}', '{c,2}', NULL),
(4, '{"a":2,"c":[4,5,{"f":7}]}', '{c,2,f}', NULL),
(5, '{"a":2,"c":[4,5],"f":7}', '{c,-1}', NULL),
(6, '{"a":2,"c":[4,5],"f":7}', '{u,8,i}', NULL),
(7, '{"a":2}', '{a}', NULL);
--Testcase 257:
ALTER FOREIGN TABLE "type_JSONB" ALTER COLUMN "q" TYPE text[];

--Testcase 260:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", j."j" #> q "r" FROM "type_JSON" j WHERE j."j" #> q IS NULL;
--Testcase 261:
SELECT "i", j."j" #> q "r" FROM "type_JSON" j WHERE j."j" #> q IS NULL;

--Testcase 262:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", j."j" #> q "r" FROM "type_JSON" j WHERE j."j" #> q IS NOT NULL;
--Testcase 263:
SELECT "i", j."j" #> q "r" FROM "type_JSON" j WHERE j."j" #> q IS NOT NULL;

--Testcase 264:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", j."j" #> q "r" FROM "type_JSONB" j WHERE j."j" #> q IS NULL;
--Testcase 265
SELECT "i", j."j" #> q "r" FROM "type_JSONB" j WHERE j."j" #> q IS NULL;

--Testcase 266:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", j."j" #> q "r" FROM "type_JSONB" j WHERE j."j" #> q IS NOT NULL;
--Testcase 267:
SELECT "i", j."j" #> q "r" FROM "type_JSONB" j WHERE j."j" #> q IS NOT NULL;

--Testcase 268:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", j."j" #>> q "r" FROM "type_JSON" j WHERE j."j" #>> q IS NULL;
--Testcase 269:
SELECT "i", j."j" #>> q "r" FROM "type_JSON" j WHERE j."j" #>> q IS NULL;

--Testcase 270:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", j."j" #>> q "r" FROM "type_JSON" j WHERE j."j" #>> q IS NOT NULL;
--Testcase 271:
SELECT "i", j."j" #>> q "r" FROM "type_JSON" j WHERE j."j" #>> q IS NOT NULL;

--Testcase 272:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", j."j" #>> q "r" FROM "type_JSONB" j WHERE j."j" #>> q IS NULL;
--Testcase 273
SELECT "i", j."j" #>> q "r" FROM "type_JSONB" j WHERE j."j" #>> q IS NULL;

--Testcase 274:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", j."j" #>> q "r" FROM "type_JSONB" j WHERE j."j" #>> q IS NOT NULL;
--Testcase 275:
SELECT "i", j."j" #>> q "r" FROM "type_JSONB" j WHERE j."j" #>> q IS NOT NULL;

--Testcase 276:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", j."j" ?| q "r" FROM "type_JSONB" j WHERE j."j" ?| q IS NULL;
--Testcase 277: no such - even wrong JSON gives false
SELECT "i", j."j" ?| q "r" FROM "type_JSONB" j WHERE j."j" ?| q IS NULL;

--Testcase 278:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", j."j" ?| q "r" FROM "type_JSONB" j WHERE j."j" ?| q IS NOT NULL;
--Testcase 279:
SELECT "i", j."j" ?| q "r" FROM "type_JSONB" j WHERE j."j" ?| q IS NOT NULL;

--Testcase 280:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", j."j" ?& q "r" FROM "type_JSONB" j WHERE j."j" ?& q IS NULL;
--Testcase 281: no such - even wrong JSON gives false
SELECT "i", j."j" ?& q "r" FROM "type_JSONB" j WHERE j."j" ?& q IS NULL;

--Testcase 282:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", j."j" ?& q "r" FROM "type_JSONB" j WHERE j."j" ?& q IS NOT NULL;
--Testcase 283:
SELECT "i", j."j" ?& q "r" FROM "type_JSONB" j WHERE j."j" ?& q IS NOT NULL;

--Testcase 284:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", j."j" - q "r" FROM "type_JSONB" j WHERE j."j" - q IS NULL;
--Testcase 285: no such
SELECT "i", j."j" - q "r" FROM "type_JSONB" j WHERE j."j" - q IS NULL;

--Testcase 286:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", j."j" - q "r" FROM "type_JSONB" j WHERE j."j" #- q IS NOT NULL;
--Testcase 287:
SELECT "i", j."j" - q "r" FROM "type_JSONB" j WHERE j."j" #- q IS NOT NULL;

--Testcase 288:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", j."j" #- q "r" FROM "type_JSONB" j WHERE j."j" #- q IS NULL;
--Testcase 289: no such
SELECT "i", j."j" #- q "r" FROM "type_JSONB" j WHERE j."j" #- q IS NULL;

--Testcase 290:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", j."j" #- q "r" FROM "type_JSONB" j WHERE j."j" #- q IS NOT NULL;
--Testcase 291:
SELECT "i", j."j" #- q "r" FROM "type_JSONB" j WHERE j."j" #- q IS NOT NULL;

--Testcase 292:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", j."j" #- q "r" FROM "type_JSONB" j WHERE j."j" #- q IS NOT NULL;
--Testcase 293:
SELECT "i", j."j" #- q "r" FROM "type_JSONB" j WHERE j."j" #- q IS NOT NULL;

--Testcase 294:
EXPLAIN (VERBOSE, COSTS OFF)
UPDATE "type_JSONB" SET j1 = '{"c":[4,5,{"f":7}]}'::json;
--Testcase 295:
UPDATE "type_JSONB" SET j1 = '{"c":[4,5,{"f":7}]}'::json;
--Testcase 296:
SELECT * FROM "type_JSONB+";

--Testcase 297:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j" @> "j1" "r" FROM "type_JSONB" WHERE "j" @> "j1";
--Testcase 298:
SELECT "i", "j" @> "j1" "r" FROM "type_JSONB" WHERE "j" @> "j1";
--Testcase 299:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j1" <@ "j" "r" FROM "type_JSONB" WHERE "j" <@ "j1";
--Testcase 300: no such
SELECT "i", "j1" <@ "j" "r" FROM "type_JSONB" WHERE "j" <@ "j1";

--Multievel extraction chains
--Testcase 301:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", j."j"-> 'c' -> 2 ->> 'f' res FROM "type_JSON" j;
--Testcase 302:
SELECT "i", "j", j."j"-> 'c' -> 2 ->> 'f' res FROM "type_JSON" j;
--Testcase 303:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT "i", "j", j."j"-> 'c' -> 2 ->> 'f' res FROM "type_JSONB" j;
--Testcase 304:
SELECT "i", "j", j."j"-> 'c' -> 2 ->> 'f' res FROM "type_JSONB" j;
--Testcase 305:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT *, "j" -> 'c' -> 2 ->> 'f' res FROM "type_JSON" WHERE i = 1 AND "j" -> 'c' -> 2 ->> 'f' IS NOT NULL;
--Testcase 306:
SELECT *, "j" -> 'c' -> 2 ->> 'f' res FROM "type_JSON" WHERE i = 1 AND "j" -> 'c' -> 2 ->> 'f' IS NOT NULL;
--Testcase 307:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT *, "j" -> 'q' -> 2 ->> 'r' res FROM "type_JSONB" WHERE i = 1 AND "j" -> 'q' -> 2 ->> 'r' IS NOT NULL;
--Testcase 308:
SELECT *, "j" -> 'q' -> 2 ->> 'r' res FROM "type_JSONB" WHERE i = 1 AND "j" -> 'q' -> 2 ->> 'r' IS NOT NULL;


-- UPDATE tests
--Testcase 309:
EXPLAIN (VERBOSE, COSTS OFF)
UPDATE "type_JSON" SET j = '{"q":[4,5,{"r":7}]}' WHERE "i" = 1;
--Testcase 310:
UPDATE "type_JSON" SET j = '{"q":[4,5,{"r":7}]}' WHERE "i" = 1;
--Testcase 311:
SELECT * FROM "type_JSON" WHERE "i" = 1;
--Testcase 312:
EXPLAIN (VERBOSE, COSTS OFF)
UPDATE "type_JSONB" SET j = '{"q":[4,5,{"r":7}]}'::json WHERE "i" = 1;
--Testcase 313:
UPDATE "type_JSONB" SET j = '{"q":[4,5,{"r":7}]}'::json WHERE "i" = 1;
--Testcase 314:
SELECT * FROM "type_JSONB+" WHERE "i" = 1;


-- Real GIS data test, data from https://www.wikidata.org/wiki/Q118122043
-- https://commons.wikimedia.org/wiki/Category:Private_Garden_(Pavlovsk)
-- License of testing data in json_osm_test table: ODbL, © OpenStreetMap contributors
--Testcase 400:
CREATE FOREIGN TABLE json_osm_test (
	wkt text NOT NULL,
	osm_type varchar(8) OPTIONS (key 'true') NOT NULL,
	osm_id int8 OPTIONS (key 'true') NOT NULL,
	t json OPTIONS (column_name 'tags') NULL,
	way_nodes text NULL
) SERVER sqlite_svr;

--Testcase 401:
INSERT INTO json_osm_test VALUES ('SRID=4326;POINT(30.4536193 59.6847624)', 'node', 1198356775, '{"access": "private", "locked": "yes", "barrier": "gate"}', NULL),
 ('SRID=4326;POINT(30.4522474 59.6851858)', 'node', 1198357028, '{"access": "private", "locked": "yes", "barrier": "gate"}', NULL),
 ('SRID=4326;POINT(30.4532025 59.6850113)', 'node', 1738381537, '{"height": "1.5", "tourism": "artwork", "historic": "yes", "material": "marble", "start_date": "C18", "description": "Ваза в дендрарии Собственного садика", "artwork_type": "vase"}', NULL),
 ('SRID=4326;POINT(30.4529584 59.6849417)', 'node', 3968068680, '{"genus": "Quercus", "taxon": "Quercus robur", "natural": "tree", "genus:ru": "Дуб", "taxon:ru": "Дуб черешчатый", "leaf_type": "broadleaved", "denotation": "landmark", "leaf_cycle": "deciduous"}', NULL),
 ('SRID=4326;POINT(30.4526407 59.68497)', 'node', 4487385447, '{"height": "1.5", "tourism": "artwork", "historic": "yes", "material": "marble", "start_date": "late C18", "artwork_type": "vase"}', NULL),
 ('SRID=4326;POINT(30.4524943 59.6854502)', 'node', 4912270255, '{"fee": "yes", "access": "customers", "barrier": "gate", "vehicle": "no", "opening_hours": "Mo-Su 09:00-21:00; May 08 - Aug 31", "barrier:personnel": "additional"}', NULL),
 ('SRID=4326;POINT(30.452977 59.6847621)', 'node', 7484858507, '{"name": "Неизвестный мужчина", "ref:okn": "781610399040516", "tourism": "artwork", "alt_name": "Спутник Одиссея", "heritage": "2", "historic": "yes", "start_date": "late C18..early C19", "artwork_type": "bust", "heritage:website": "https://kgiop.gov.spb.ru/deyatelnost/uchet/list_objects/6522/"}', NULL),
 ('SRID=4326;POINT(30.452909 59.6847573)', 'node', 7484858508, '{"name": "Антиной", "ref:okn": "781610399040526", "tourism": "artwork", "alt_name": "Дионис", "heritage": "2", "historic": "yes", "material": "stone", "start_date": "late C18..early C19", "artwork_type": "bust", "heritage:website": "https://kgiop.gov.spb.ru/deyatelnost/uchet/list_objects/6521/"}', NULL),
 ('SRID=4326;POINT(30.4529561 59.6848095)', 'node', 8114975053, '{"name": "Ваза", "height": "1.5", "name:en": "Vase", "ref:okn": "781620399040936", "tourism": "artwork", "historic": "yes", "material": "marble", "wikidata": "Q118122044", "start_date": "C18", "artwork_type": "vase"}', NULL),
 ('SRID=4326;POINT(30.4528946 59.6848042)', 'node', 8114975054, '{"name": "Ваза", "height": "1.5", "name:en": "Vase", "ref:okn": "781620399040936", "tourism": "artwork", "historic": "yes", "material": "marble", "wikidata": "Q118122044", "start_date": "C18", "artwork_type": "vase"}', NULL),
 ('SRID=4326;POINT(30.4528732 59.6848762)', 'node', 8114975055, '{"name": "Ваза", "height": "1.5", "name:en": "Vase", "ref:okn": "781620399040936", "tourism": "artwork", "historic": "yes", "material": "marble", "wikidata": "Q118122044", "start_date": "C18", "artwork_type": "vase"}', NULL),
 ('SRID=4326;POINT(30.4529364 59.6848802)', 'node', 8114975056, '{"name": "Ваза", "height": "1.5", "name:en": "Vase", "ref:okn": "781620399040936", "tourism": "artwork", "historic": "yes", "material": "marble", "wikidata": "Q118122044", "start_date": "C18", "artwork_type": "vase"}', NULL),
 ('SRID=4326;POINT(30.4528444 59.6851765)', 'node', 8289295956, '{"name": "Ваза", "height": "1.5", "name:en": "Vase", "ref:okn": "781620399040936", "tourism": "artwork", "historic": "yes", "material": "marble", "wikidata": "Q118122044", "start_date": "C18", "artwork_type": "vase"}', NULL),
 ('SRID=4326;POINT(30.4527798 59.6851726)', 'node', 8289295957, '{"name": "Ваза", "height": "1.5", "name:en": "Vase", "ref:okn": "781620399040936", "tourism": "artwork", "historic": "yes", "material": "marble", "wikidata": "Q118122044", "start_date": "C18", "artwork_type": "vase"}', NULL),
 ('SRID=4326;POINT(30.4528665 59.6850957)', 'node', 8289295958, '{"name": "Ваза", "height": "1.5", "name:en": "Vase", "ref:okn": "781620399040936", "tourism": "artwork", "historic": "yes", "material": "marble", "wikidata": "Q118122044", "start_date": "C18", "artwork_type": "vase"}', NULL),
 ('SRID=4326;POINT(30.4528046 59.685091)', 'node', 8289295959, '{"name": "Ваза", "height": "1.5", "name:en": "Vase", "ref:okn": "781620399040936", "tourism": "artwork", "historic": "yes", "material": "marble", "wikidata": "Q118122044", "start_date": "C18", "artwork_type": "vase"}', NULL),
 ('SRID=4326;POINT(30.4528947 59.6850172)', 'node', 8289295960, '{"name": "Ваза", "height": "1.5", "name:en": "Vase", "ref:okn": "781620399040936", "tourism": "artwork", "historic": "yes", "material": "marble", "wikidata": "Q118122044", "start_date": "C18", "artwork_type": "vase"}', NULL),
 ('SRID=4326;POINT(30.4528301 59.6850118)', 'node', 8289295961, '{"name": "Ваза", "height": "1.5", "name:en": "Vase", "ref:okn": "781620399040936", "tourism": "artwork", "historic": "yes", "material": "marble", "wikidata": "Q118122044", "start_date": "C18", "artwork_type": "vase"}', NULL),
 ('SRID=4326;POINT(30.4529101 59.6849636)', 'node', 8289295962, '{"name": "Ваза", "height": "1.5", "name:en": "Vase", "ref:okn": "781620399040936", "tourism": "artwork", "historic": "yes", "material": "marble", "wikidata": "Q118122044", "start_date": "C18", "artwork_type": "vase"}', NULL),
 ('SRID=4326;POINT(30.4528496 59.684959)', 'node', 8289295963, '{"name": "Ваза", "height": "1.5", "name:en": "Vase", "ref:okn": "781620399040936", "tourism": "artwork", "historic": "yes", "material": "marble", "wikidata": "Q118122044", "start_date": "C18", "artwork_type": "vase"}', NULL),
 ('SRID=4326;POINT(30.4528359 59.6852187)', 'node', 8331430659, '{"height": "2", "ref:okn": "781620399040936", "tourism": "artwork", "historic": "yes", "material": "marble", "start_date": "C18", "artwork_type": "vase"}', NULL),
 ('SRID=4326;POINT(30.4527605 59.685213)', 'node', 8331430660, '{"height": "2", "ref:okn": "781620399040936", "tourism": "artwork", "historic": "yes", "material": "marble", "start_date": "C18", "artwork_type": "vase"}', NULL),
 ('SRID=4326;POINT(30.4523414 59.6851726)', 'node', 8331430663, '{"name": "Сатир", "height": "1.5", "tourism": "artwork", "historic": "yes", "wikidata": "Q118122105", "start_date": "~1779..1801", "artwork_type": "statue", "artwork:start_date": "C18"}', NULL),
 ('SRID=4326;POINT(30.4523561 59.685141)', 'node', 8331430664, '{"name": "Сатиресса", "height": "1.5", "tourism": "artwork", "historic": "yes", "wikidata": "Q118122105", "start_date": "~1779..1801", "artwork_type": "statue", "artwork:start_date": "C18"}', NULL),
 ('SRID=4326;POINT(30.4527994 59.6847007)', 'node', 8566916332, '{"height": "8", "natural": "tree", "leaf_type": "broadleaved", "leaf_cycle": "deciduous"}', NULL),
 ('SRID=4326;POINT(30.4528945 59.6847497)', 'node', 8566916333, '{"height": "8", "natural": "tree", "leaf_type": "broadleaved", "leaf_cycle": "deciduous"}', NULL),
 ('SRID=4326;POINT(30.4529784 59.6853519)', 'node', 8895996426, '{"genus": "Thuja", "height": "1", "natural": "tree", "genus:ru": "Туя", "leaf_type": "needleleaved", "leaf_cycle": "evergreen"}', NULL),
 ('SRID=4326;POINT(30.4529255 59.6853861)', 'node', 8895996427, '{"genus": "Thuja", "height": "1", "natural": "tree", "genus:ru": "Туя", "leaf_type": "needleleaved", "leaf_cycle": "evergreen"}', NULL),
 ('SRID=4326;POINT(30.4525278 59.685471)', 'node', 8895996643, '{"genus": "Tilia", "height": "6", "natural": "tree", "genus:ru": "Липа", "leaf_type": "broadleaved", "leaf_cycle": "deciduous"}', NULL),
 ('SRID=4326;POINT(30.4534153 59.6851412)', 'node', 8899249758, '{"genus": "Elaeagnus", "taxon": "Elaeagnus commutata", "natural": "shrub", "genus:ru": "Лох", "taxon:ru": "Лох серебристый", "source:taxon": "board"}', NULL),
 ('SRID=4326;POINT(30.4535524 59.6848638)', 'node', 8899249764, '{"height": "0.8", "highway": "street_lamp", "material": "metal", "lamp_type": "electric"}', NULL),
 ('SRID=4326;POINT(30.4535202 59.6849613)', 'node', 8899249765, '{"height": "0.8", "highway": "street_lamp", "material": "metal", "lamp_type": "electric"}', NULL),
 ('SRID=4326;POINT(30.4534934 59.6850486)', 'node', 8899249766, '{"height": "0.8", "highway": "street_lamp", "material": "metal", "lamp_type": "electric"}', NULL),
 ('SRID=4326;POINT(30.4534679 59.685136)', 'node', 8899249767, '{"height": "0.8", "highway": "street_lamp", "material": "metal", "lamp_type": "electric"}', NULL),
 ('SRID=4326;POINT(30.4528899 59.6851725)', 'node', 8899249768, '{"height": "0.8", "highway": "street_lamp", "material": "metal", "lamp_type": "electric"}', NULL),
 ('SRID=4326;POINT(30.4530448 59.6850046)', 'node', 8899249769, '{"colour": "green", "amenity": "bench", "backrest": "yes", "material": "wood"}', NULL),
 ('SRID=4326;POINT(30.4533465 59.6850216)', 'node', 8899249770, '{"colour": "green", "amenity": "bench", "backrest": "yes", "material": "wood"}', NULL),
 ('SRID=4326;POINT(30.4532205 59.6849417)', 'node', 8899249771, '{"colour": "green", "amenity": "bench", "backrest": "yes", "material": "wood"}', NULL),
 ('SRID=4326;POINT(30.4531776 59.6850839)', 'node', 8899249772, '{"colour": "green", "amenity": "bench", "backrest": "yes", "material": "wood"}', NULL),
 ('SRID=4326;POINT(30.4534136 59.6851265)', 'node', 8899249773, '{"genus": "Malus", "taxon": "Malus niedzwetzkyana", "height": "5", "natural": "tree", "genus:ru": "Яблоня", "taxon:ru": "Яблоня Недзвецкого", "leaf_type": "broadleaved", "leaf_cycle": "deciduous", "source:taxon": "board"}', NULL),
 ('SRID=4326;POINT(30.4533043 59.6851928)', 'node', 8899249779, '{"height": "4", "natural": "tree", "leaf_type": "broadleaved", "leaf_cycle": "deciduous", "source:taxon": "board"}', NULL),
 ('SRID=4326;POINT(30.452916 59.6849894)', 'node', 8899249796, '{"colour": "green", "amenity": "bench", "ref:okn": "781620399040946", "backrest": "yes", "material": "wood"}', NULL),
 ('SRID=4326;POINT(30.4528248 59.684983)', 'node', 8899249797, '{"colour": "green", "amenity": "bench", "ref:okn": "781620399040946", "backrest": "yes", "material": "wood"}', NULL),
 ('SRID=4326;POINT(30.4531527 59.685139)', 'node', 8899299127, '{"height": "3", "natural": "tree", "leaf_type": "broadleaved", "leaf_cycle": "deciduous"}', NULL),
 ('SRID=4326;POINT(30.4529549 59.6850382)', 'node', 8902082041, '{"genus": "Syrínga", "taxon": "Syringa vulgaris", "natural": "shrub", "genus:ru": "Сирень", "taxon:ru": "Сирень обыкновенная", "source:taxon": "board"}', NULL),
 ('SRID=4326;POINT(30.4530139 59.6850101)', 'node', 8902082042, '{"genus": "Amelanchier", "taxon": "Amelanchier canadensis", "natural": "shrub", "genus:ru": "Ирга", "taxon:ru": "Ирга канадская", "source:taxon": "board"}', NULL),
 ('SRID=4326;POINT(30.4530089 59.6850564)', 'node', 8902082048, '{"genus": "Picea", "taxon": "Picea glauca", "height": "1.5", "natural": "tree", "genus:ru": "Ель", "taxon:ru": "Ель сизая", "leaf_type": "needleleaved", "leaf_cycle": "evergreen", "source:taxon": "board"}', NULL),
 ('SRID=4326;POINT(30.4529982 59.685072)', 'node', 8902082055, '{"genus": "Picea", "taxon": "Picea glauca", "height": "1.5", "natural": "tree", "genus:ru": "Ель", "taxon:ru": "Ель сизая", "leaf_type": "needleleaved", "leaf_cycle": "evergreen", "source:taxon": "board"}', NULL),
 ('SRID=4326;POINT(30.4530213 59.6850872)', 'node', 8902082060, '{"genus": "Picea", "taxon": "Picea glauca", "height": "1.5", "natural": "tree", "genus:ru": "Ель", "taxon:ru": "Ель сизая", "leaf_type": "needleleaved", "leaf_cycle": "evergreen", "source:taxon": "board"}', NULL),
 ('SRID=4326;POINT(30.4529918 59.6851617)', 'node', 8902082061, '{"genus": "Berberis", "taxon": "Berberis vulgaris", "natural": "shrub", "genus:ru": "Барбарис", "taxon:ru": "Барбарис обыкновенный", "source:taxon": "board"}', NULL),
 ('SRID=4326;POINT(30.4530615 59.685137)', 'node', 8902082071, '{"genus": "Paeonia", "taxon": "Paeonia suffruticosa", "natural": "shrub", "genus:ru": "Пион", "taxon:ru": "Пион древовидный", "source:taxon": "board"}', NULL),
 ('SRID=4326;POINT(30.4531031 59.6851282)', 'node', 8902082072, '{"genus": "Caragana", "taxon": "Caragana arborescens", "natural": "shrub", "genus:ru": "Карагана", "taxon:ru": "Карагана древовидная", "description": "Акация желтая", "source:taxon": "board"}', NULL),
 ('SRID=4326;POINT(30.4530991 59.6851451)', 'node', 8902082073, '{"genus": "Caragana", "taxon": "Caragana arborescens", "natural": "shrub", "genus:ru": "Карагана", "taxon:ru": "Карагана древовидная", "description": "Акация желтая", "source:taxon": "board"}', NULL),
 ('SRID=4326;POINT(30.4531977 59.6851532)', 'node', 8902082074, '{"genus": "Thuja", "taxon": "Thuja occidentalis", "height": "1", "natural": "tree", "genus:ru": "Туя", "taxon:ru": "Туя западная", "leaf_type": "needleleaved", "leaf_cycle": "evergreen", "source:taxon": "board"}', NULL),
 ('SRID=4326;POINT(30.453207 59.6851336)', 'node', 8902082075, '{"genus": "Thuja", "taxon": "Thuja occidentalis", "height": "1", "natural": "tree", "genus:ru": "Туя", "taxon:ru": "Туя западная", "leaf_type": "needleleaved", "leaf_cycle": "evergreen", "source:taxon": "board"}', NULL),
 ('SRID=4326;POINT(30.4532426 59.6850926)', 'node', 8902082171, '{"height": "3", "natural": "tree", "leaf_type": "broadleaved", "leaf_cycle": "deciduous", "source:taxon": "board"}', NULL),
 ('SRID=4326;POINT(30.4532694 59.6851157)', 'node', 8902082172, '{"height": "3", "natural": "tree", "leaf_type": "broadleaved", "leaf_cycle": "deciduous", "source:taxon": "board"}', NULL),
 ('SRID=4326;POINT(30.4533707 59.6851035)', 'node', 8902082173, '{"genus": "Hydrangea", "taxon": "Hydrangea paniculata", "natural": "shrub", "genus:ru": "Гортензия", "taxon:ru": "Гортензия метельчатая"}', NULL),
 ('SRID=4326;POINT(30.4528986 59.6851502)', 'node', 8902082174, '{"genus": "Quercus", "taxon": "Quercus robur", "natural": "tree", "genus:ru": "Дуб", "taxon:ru": "Дуб черешчатый", "leaf_type": "broadleaved", "denotation": "landmark", "leaf_cycle": "deciduous"}', NULL),
 ('SRID=4326;POINT(30.4530486 59.6848994)', 'node', 8904992674, '{"genus": "Viburnum", "taxon": "Viburnum opulus", "natural": "shrub", "genus:ru": "Калина", "taxon:ru": "Калина обыкновенная", "source:taxon": "board"}', NULL),
 ('SRID=4326;POINT(30.4532396 59.6848373)', 'node', 8905335421, '{"genus": "Corylus", "taxon": "Corylus avellana", "natural": "shrub", "genus:ru": "Лещина", "taxon:ru": "Лещина обыкновенная", "source:taxon": "board"}', NULL),
 ('SRID=4326;POINT(30.4532946 59.684841)', 'node', 8905335422, '{"genus": "Spiraea", "taxon": "Spiraea chamaedryfolia", "natural": "shrub", "genus:ru": "Спирея", "taxon:ru": "Спирея дубравколистная", "source:taxon": "board"}', NULL),
 ('SRID=4326;POINT(30.4533857 59.6849271)', 'node', 8905335423, '{"genus": "Euonymus", "taxon": "Euonymus europaeus", "natural": "shrub", "genus:ru": "Бересклет", "taxon:ru": "Бересклет европейский", "source:taxon": "board"}', NULL),
 ('SRID=4326;POINT(30.4534136 59.6849004)', 'node', 8905335424, '{"genus": "Prunus", "taxon": "Prunus sachalinensis", "height": "5", "natural": "tree", "genus:ru": "Вишня", "taxon:ru": "Вишня сахалинская", "leaf_type": "broadleaved", "leaf_cycle": "deciduous", "source:taxon": "board"}', NULL),
 ('SRID=4326;POINT(30.4533998 59.6848611)', 'node', 8905335425, '{"genus": "Buxus", "taxon": "Buxus sempervirens", "height": "1", "natural": "shrub", "genus:ru": "Самшит", "taxon:ru": "Самшит вечнозелёный", "leaf_type": "needleleaved", "leaf_cycle": "evergreen"}', NULL),
 ('SRID=4326;POINT(30.4534776 59.6848679)', 'node', 8905335426, '{"genus": "Rhamnus", "taxon": "Rhamnus cathartica", "height": "4", "natural": "tree", "genus:ru": "Жостер", "taxon:ru": "Жостер слабительный", "leaf_type": "broadleaved", "leaf_cycle": "deciduous", "source:taxon": "board"}', NULL),
 ('SRID=4326;POINT(30.4534324 59.6849515)', 'node', 8905335427, '{"genus": "Lonicera", "taxon": "Lonicera caerulea", "natural": "shrub", "genus:ru": "Жимолость", "taxon:ru": "Жимолость синяя", "source:taxon": "board"}', NULL),
 ('SRID=4326;POINT(30.453365 59.684981)', 'node', 8905335428, '{"genus": "Philadelphus", "taxon": "Philadelphus coronarius", "natural": "shrub", "genus:ru": "Чубушник", "taxon:ru": "Чубушник венечный"}', NULL),
 ('SRID=4326;POINT(30.4533874 59.6849671)', 'node', 8905335429, '{"genus": "Juniperus", "taxon": "Juniperus sabina", "height": "0.5", "natural": "shrub", "genus:ru": "Можжевельник", "taxon:ru": "Можжевельник казацкий", "leaf_type": "needleleaved", "leaf_cycle": "evergreen"}', NULL),
 ('SRID=4326;POINT(30.4531319 59.6849356)', 'node', 8905335430, '{"genus": "Picea", "taxon": "Picea abies", "height": "0.5", "natural": "tree", "genus:ru": "Ель", "taxon:ru": "Ель европейская", "leaf_type": "needleleaved", "leaf_cycle": "evergreen", "source:taxon": "board"}', NULL),
 ('SRID=4326;POINT(30.4532466 59.6848527)', 'node', 8905335431, '{"genus": "Ginkgo", "taxon": "Ginkgo biloba", "height": "2.5", "natural": "tree", "genus:ru": "Гингко", "taxon:ru": "Гинкго двулопастный", "leaf_type": "broadleaved", "leaf_cycle": "deciduous", "source:taxon": "label"}', NULL),
 ('SRID=4326;POINT(30.4532184 59.6848635)', 'node', 8905335468, '{"genus": "Daphne", "taxon": "Daphne mezereum", "natural": "shrub", "genus:ru": "Волчеягодник", "taxon:ru": "Волчеягодник обыкновенный", "source:taxon": "board"}', NULL),
 ('SRID=4326;POINT(30.4532392 59.6848902)', 'node', 8905335469, '{"height": "3", "natural": "tree", "leaf_type": "broadleaved", "leaf_cycle": "deciduous"}', NULL),
 ('SRID=4326;POINT(30.4526679 59.6846912)', 'node', 8905558225, '{"height": "3", "highway": "street_lamp", "man_made": "surveillance", "material": "metal", "lamp_type": "electric"}', NULL),
 ('SRID=4326;POINT(30.4530347 59.6849253)', 'node', 8906857477, '{"genus": "Philadelphus lemoinei", "taxon": "Philadelphus lemoinei", "natural": "shrub", "genus:ru": "Чубушник", "taxon:ru": "Чубушник Лемуана", "source:taxon": "board"}', NULL),
 ('SRID=4326;POINT(30.4530224 59.6849455)', 'node', 8906857478, '{"genus": "Rhododendron", "taxon": "Rhododendron ledebourii", "natural": "shrub", "genus:ru": "Рододендрон", "taxon:ru": "Рододендрон Ледебура", "source:taxon": "board"}', NULL),
 ('SRID=4326;POINT(30.4530015 59.6847554)', 'node', 8906857479, '{"natural": "tree_stump"}', NULL),
 ('SRID=4326;LINESTRING(30.4522584 59.6851734,30.4522474 59.6851858)', 'way', 103807093, '{"highway": "footway", "surface": "compacted"}', '{3968068679,1198357028}'),
 ('SRID=4326;LINESTRING(30.4525184 59.6846577,30.4525041 59.6846527,30.4522364 59.6845601,30.4516531 59.6843525,30.4513385 59.6842533,30.4513511 59.6841667)', 'way', 103807103, '{"height": "1.5", "barrier": "fence", "material": "metal", "fence_type": "bars"}', '{8566824024,12023699867,8114975022,1195141497,4014269128,3186425168}'),
 ('SRID=4326;LINESTRING(30.4530859 59.6846667,30.4535555 59.6847085,30.4535698 59.6847103,30.4535807 59.6847121,30.4535886 59.6847164,30.4535925 59.6847224,30.4535923 59.6847296,30.4535863 59.6847456)', 'way', 103807114, '{"height": "2", "barrier": "fence", "ref:okn": "781610399040356", "historic": "yes", "man_made": "embankment"}', '{1198357004,303515662,8566916345,1198356771,8566916346,1198356889,1198357009,8906857470}'),
 ('SRID=4326;LINESTRING(30.4529536 59.6847313,30.4529382 59.6847803,30.4528051 59.6851927,30.4527793 59.6852746,30.4527609 59.6853349,30.4527422 59.6853961,30.4527263 59.6854482,30.4527224 59.6854618)', 'way', 153761053, '{"highway": "footway", "surface": "fine_gravel", "historic": "yes"}', '{3968068681,8114975050,8114975107,8895975844,8895975845,8895975847,4912270253,1664064412}'),
 ('SRID=4326;LINESTRING(30.4532657 59.6852057,30.4532459 59.6852254,30.45322 59.6852491)', 'way', 153761054, '{"highway": "footway", "surface": "fine_gravel"}', '{1665582248,8114975105,3968068669}'),
 ('SRID=4326;LINESTRING(30.452898 59.6850578,30.4528762 59.6851274,30.4530118 59.6851874)', 'way', 153947121, '{"highway": "footway", "surface": "fine_gravel"}', '{1665582241,1738381541,1665582246}'),
 ('SRID=4326;LINESTRING(30.4529389 59.6849276,30.4529574 59.6848702,30.4531238 59.6848204)', 'way', 153947122, '{"highway": "footway", "surface": "fine_gravel"}', '{1665582237,1738381532,1665582234}'),
 ('SRID=4326;LINESTRING(30.4533888 59.6848413,30.4535109 59.6849058,30.4534919 59.684967)', 'way', 153947123, '{"highway": "footway", "surface": "fine_gravel"}', '{1665582235,1738381534,1665582240}'),
 ('SRID=4326;LINESTRING(30.4532657 59.6852057,30.4533267 59.6852228,30.4533391 59.6851996,30.4533483 59.6851876,30.4533556 59.6851828,30.4533653 59.6851769,30.4533784 59.6851717,30.4533901 59.6851678,30.4534147 59.6851629,30.4534315 59.6851615,30.4534524 59.6850941)', 'way', 153947124, '{"highway": "footway", "surface": "fine_gravel"}', '{1665582248,8114975034,8899249793,8114975035,8902027910,8899249794,8902027909,8899249795,1738381544,8114975036,1665582244}'),
 ('SRID=4326;LINESTRING(30.4531795 59.685129,30.4533062 59.6850846,30.4534722 59.6850303,30.4534919 59.684967)', 'way', 153947125, '{"highway": "footway", "surface": "fine_gravel"}', '{8114975075,1665582243,1738381539,1665582240}'),
 ('SRID=4326;LINESTRING(30.4531325 59.6851257,30.4530483 59.6850678,30.4529356 59.6849912)', 'way', 153947126, '{"highway": "footway", "surface": "fine_gravel"}', '{8114975078,1665582242,8902082170}'),
 ('SRID=4326;LINESTRING(30.4529356 59.6849912,30.4530873 59.6849398,30.453213 59.6848988)', 'way', 153947127, '{"highway": "footway", "surface": "fine_gravel"}', '{8902082170,1665582238,8904992643}'),
 ('SRID=4326;LINESTRING(30.4532598 59.6849025,30.4533508 59.6849575,30.4534722 59.6850303,30.4534524 59.6850941)', 'way', 153947128, '{"highway": "footway", "surface": "fine_gravel"}', '{8904992648,1665582239,1738381539,1665582244}'),
 ('SRID=4326;LINESTRING(30.4529775 59.684808,30.4531238 59.6848204,30.4533888 59.6848413,30.4535282 59.6848524)', 'way', 153947130, '{"highway": "footway", "surface": "fine_gravel"}', '{1664064416,1665582234,1665582235,1665582236}'),
 ('SRID=4326;LINESTRING(30.4529389 59.6849276,30.4530873 59.6849398,30.4532201 59.6849487,30.4533508 59.6849575,30.4534919 59.684967)', 'way', 153947131, '{"highway": "footway", "surface": "fine_gravel"}', '{1665582237,1665582238,8902082149,1665582239,1665582240}'),
 ('SRID=4326;LINESTRING(30.4532657 59.6852057,30.4533062 59.6850846,30.4533306 59.6850189,30.4533508 59.6849575,30.4533888 59.6848413)', 'way', 153947132, '{"highway": "footway", "surface": "fine_gravel"}', '{1665582248,1665582243,8902082150,1665582239,1665582235}'),
 ('SRID=4326;LINESTRING(30.4534524 59.6850941,30.4533062 59.6850846,30.4531801 59.6850762,30.4530483 59.6850678,30.452898 59.6850578)', 'way', 153947133, '{"highway": "footway", "surface": "fine_gravel"}', '{1665582244,1665582243,8902082168,1665582242,1665582241}'),
 ('SRID=4326;LINESTRING(30.4532234 59.6850226,30.4533062 59.6850846,30.4534147 59.6851629)', 'way', 153947134, '{"highway": "footway", "surface": "fine_gravel"}', '{8114975088,1665582243,1738381544}'),
 ('SRID=4326;LINESTRING(30.4530118 59.6851874,30.4530483 59.6850678,30.4530675 59.6850048,30.4530873 59.6849398,30.4531238 59.6848204)', 'way', 153947135, '{"highway": "footway", "surface": "fine_gravel"}', '{1665582246,1665582242,8902082151,1665582238,1665582234}'),
 ('SRID=4326;LINESTRING(30.452497 59.6854882,30.4524943 59.6854502,30.4524845 59.6854195,30.4524735 59.685401,30.4524616 59.6853789,30.4524395 59.6853504,30.4524088 59.6853175,30.4523836 59.685295,30.4523534 59.6852701,30.4523333 59.6852571,30.452307 59.6852409,30.4522692 59.6852184,30.4522695 59.6851929,30.4522474 59.6851858)', 'way', 312745383, '{"barrier": "fence"}', '{1439053672,4912270255,4438910482,8895996664,4438910480,3234125031,4438910477,8893386635,4438910475,8895996665,4438910473,8114975112,8114975111,1198357028}'),
 ('SRID=4326;LINESTRING(30.4529349 59.6853856,30.4529284 59.6853815,30.4529266 59.6853774,30.4529297 59.6853727,30.452955 59.6853567,30.4529621 59.6853543,30.4529707 59.6853538,30.4529809 59.6853554)', 'way', 315626926, '{"height": "2", "barrier": "fence", "material": "stone", "fence_type": "bars", "min_height": "1"}', '{1439053649,8895996432,8895996430,1439053648,1439053645,8895996431,1439053641,1439053639}'),
 ('SRID=4326;LINESTRING(30.4522278 59.6851794,30.4526025 59.6847092,30.4524973 59.6846698,30.4525184 59.6846577)', 'way', 317173782, '{"height": "1.5", "barrier": "fence", "material": "metal", "fence_type": "bars"}', '{1653641713,8114975028,8114975027,8566824024}'),
 ('SRID=4326;LINESTRING(30.4526262 59.684701,30.4526304 59.6847065,30.4529536 59.6847313,30.453482 59.6847765,30.4535921 59.6847856,30.4535778 59.6848316,30.4534654 59.685163)', 'way', 393601662, '{"highway": "footway", "surface": "fine_gravel"}', '{7927774427,8905543616,3968068681,7927774426,3968068674,8114975049,3968068687}'),
 ('SRID=4326;LINESTRING(30.4528624 59.685176,30.4530118 59.6851874,30.4532501 59.6852048,30.4532657 59.6852057)', 'way', 393601664, '{"highway": "footway", "surface": "fine_gravel"}', '{3968068670,1665582246,8899299159,1665582248}'),
 ('SRID=4326;LINESTRING(30.4528624 59.685176,30.4528762 59.6851274,30.4530483 59.6850678,30.4531752 59.6850205)', 'way', 393601667, '{"highway": "footway", "surface": "fine_gravel"}', '{3968068670,1738381541,1665582242,8114975100}'),
 ('SRID=4326;LINESTRING(30.452545 59.6854429,30.4525305 59.6854105,30.4525224 59.6853929,30.4525133 59.6853758,30.4525036 59.6853597,30.4524909 59.6853438,30.4524775 59.6853279,30.4524583 59.6853083,30.4524437 59.6852938,30.4524165 59.6852717,30.4523957 59.6852568,30.452375 59.6852427,30.4523461 59.6852243,30.4523179 59.6852068)', 'way', 393620818, '{"highway": "footway", "surface": "fine_gravel"}', '{8114975116,8895996660,8895996640,4438927787,8895996641,8895996659,8895996642,4438927782,8114975115,8895996661,8895996639,4438927777,8895996638,8114975114}'),
 ('SRID=4326;LINESTRING(30.45322 59.6852491,30.4530263 59.6852336,30.4529402 59.6852275,30.4528645 59.6852217)', 'way', 393620820, '{"access": "private", "highway": "footway", "surface": "fine_gravel", "historic": "yes"}', '{3968068669,8895975857,8895975877,8895975841}'),
 ('SRID=4326;LINESTRING(30.4527686 59.6854977,30.4528746 59.6855048)', 'way', 446650486, '{"height": "2", "barrier": "fence", "material": "stone", "fence_type": "bars", "min_height": "1"}', '{1439053671,1439053674}'),
 ('SRID=4326;LINESTRING(30.4530377 59.6853204,30.4530373 59.6853168,30.4530377 59.6853132,30.4530389 59.6853097,30.4530408 59.6853062,30.4530436 59.6853029,30.453047 59.6852998,30.4530511 59.6852969,30.4530559 59.6852942,30.4530612 59.6852918,30.4530685 59.6852893,30.4530765 59.6852873,30.4530849 59.6852859,30.4530936 59.6852852,30.4531024 59.685285,30.4531113 59.6852855,30.4531198 59.6852866,30.453128 59.6852882,30.4531357 59.6852905)', 'way', 446650506, '{"height": "7", "barrier": "fence", "fence_type": "bars", "min_height": "6"}', '{1439053619,8914843795,8895996424,8914843796,1439053616,8914843797,8895996423,8914843798,1439053613,8914843799,8895996422,8895996441,8914843802,8895996421,8914843801,1439053611,8914843800,8895996420,1439053614}'),
 ('SRID=4326;LINESTRING(30.4522474 59.6851858,30.4522278 59.6851794)', 'way', 446651403, '{"barrier": "fence"}', '{1198357028,1653641713}'),
 ('SRID=4326;LINESTRING(30.4524943 59.6854502,30.452545 59.6854429,30.4525879 59.6854383,30.4527263 59.6854482,30.4528729 59.6854587)', 'way', 500077282, '{"highway": "footway", "surface": "fine_gravel"}', '{4912270255,8114975116,4438928092,4912270253,4438928093}'),
 ('SRID=4326;LINESTRING(30.4522474 59.6851858,30.4522167 59.6853009)', 'way', 758868053, '{"highway": "footway"}', '{1198357028,1406921754}'),
 ('SRID=4326;LINESTRING(30.4529536 59.6847313,30.4529562 59.6847243)', 'way', 849729200, '{"highway": "footway", "surface": "fine_gravel"}', '{3968068681,8905543615}'),
 ('SRID=4326;LINESTRING(30.453482 59.6847765,30.4534851 59.684767)', 'way', 849729201, '{"highway": "footway", "surface": "fine_gravel"}', '{7927774426,8905543614}'),
 ('SRID=4326;LINESTRING(30.452599 59.6846895,30.4525675 59.6846756,30.45256 59.6846723,30.452568 59.6846486,30.4535014 59.6847265,30.4534976 59.6847368)', 'way', 849729202, '{"highway": "footway", "surface": "fine_gravel"}', '{3968068677,12023732269,8566916344,8566916343,8566916342,7927774425}'),
 ('SRID=4326;LINESTRING(30.4528543 59.6851747,30.4529071 59.6850026,30.4529249 59.685004,30.4529333 59.6849769,30.452917 59.6849756,30.4529721 59.6847963)', 'way', 871154683, '{"genus": "Cotoneaster", "taxon": "Cotoneaster lucidus", "height": "0.5", "barrier": "hedge", "genus:ru": "Кизильник", "taxon:ru": "Кизильник блестящий", "leaf_type": "broadleaved", "leaf_cycle": "deciduous", "source:taxon": "board", "species:wikidata": "Q162750"}', '{8114975041,8899249805,8899249804,8899249803,8899249802,8114975042}'),
 ('SRID=4326;LINESTRING(30.4526587 59.6847165,30.4528767 59.6847343,30.4528732 59.6847452,30.4526552 59.6847274,30.4526587 59.6847165)', 'way', 871154684, '{"genus": "Cotoneaster", "taxon": "Cotoneaster lucidus", "height": "0.5", "barrier": "hedge", "landuse": "grass", "genus:ru": "Кизильник", "taxon:ru": "Кизильник блестящий", "leaf_type": "broadleaved", "leaf_cycle": "deciduous", "species:ru": "Кизильник блестящий", "species:wikidata": "Q162750"}', '{8114975046,8114975047,8906857474,8906857473,8114975046}'),
 ('SRID=4326;LINESTRING(30.4530118 59.6851874,30.4531264 59.6851489)', 'way', 871154687, '{"highway": "footway", "surface": "fine_gravel"}', '{1665582246,8114975076}'),
 ('SRID=4326;LINESTRING(30.4531325 59.6851257,30.4531378 59.6851238,30.4531466 59.6851223,30.4531559 59.6851221,30.453165 59.6851233,30.453173 59.6851256,30.4531795 59.685129,30.4531835 59.6851328,30.4531855 59.685137,30.4531853 59.6851413,30.4531829 59.6851454,30.4531786 59.6851491,30.4531713 59.6851525,30.4531634 59.6851545,30.4531533 59.6851554,30.4531431 59.6851547,30.4531339 59.6851525,30.4531264 59.6851489,30.4531217 59.6851446,30.4531197 59.6851398,30.4531205 59.6851349,30.4531241 59.6851304,30.4531325 59.6851257)', 'way', 871154688, '{"highway": "footway", "surface": "fine_gravel"}', '{8114975078,8114975073,8114975074,8114975057,8114975058,8114975059,8114975075,8114975060,8114975061,8114975067,8114975068,8114975069,8114975077,8114975070,8114975062,8114975063,8114975064,8114975076,8114975065,8114975066,8114975071,8114975072,8114975078}'),
 ('SRID=4326;LINESTRING(30.4532501 59.6852048,30.4531713 59.6851525)', 'way', 871154689, '{"highway": "footway", "surface": "fine_gravel"}', '{8899299159,8114975077}'),
 ('SRID=4326;LINESTRING(30.4531787 59.684998,30.4531868 59.6849952,30.4531962 59.6849937,30.453206 59.6849937,30.4532145 59.684995,30.453222 59.6849973,30.4532281 59.6850005,30.4532323 59.6850046,30.4532341 59.6850091,30.4532335 59.6850137,30.4532298 59.6850185,30.4532234 59.6850226,30.4532151 59.6850253,30.4532056 59.6850267,30.4531956 59.6850267,30.4531843 59.6850246,30.4531752 59.6850205,30.45317 59.6850157,30.4531682 59.6850102,30.4531694 59.6850057,30.453173 59.6850015,30.4531787 59.684998)', 'way', 871154691, '{"highway": "footway"}', '{8114975097,8114975079,8114975080,8114975081,8114975082,8114975083,8114975099,8114975084,8114975085,8114975086,8114975087,8114975088,8114975089,8114975090,8114975091,8114975092,8114975100,8114975093,8114975094,8114975095,8114975096,8114975097}'),
 ('SRID=4326;LINESTRING(30.4529775 59.684808,30.4529574 59.6848702,30.4530873 59.6849398,30.4531787 59.684998)', 'way', 871154694, '{"highway": "footway", "surface": "fine_gravel"}', '{1664064416,1738381532,1665582238,8114975097}'),
 ('SRID=4326;LINESTRING(30.4532281 59.6850005,30.4533508 59.6849575,30.4535109 59.6849058,30.4535282 59.6848524)', 'way', 871154695, '{"highway": "footway", "surface": "fine_gravel"}', '{8114975099,1665582239,1738381534,1665582236}'),
 ('SRID=4326;LINESTRING(30.4532459 59.6852254,30.4528051 59.6851927,30.4522785 59.6851511)', 'way', 871154698, '{"highway": "footway", "surface": "fine_gravel", "historic": "yes"}', '{8114975105,8114975107,8114975109}'),
 ('SRID=4326;LINESTRING(30.4526095 59.6853751,30.4526201 59.6853832,30.4527025 59.6853899,30.4527175 59.6853841,30.4527302 59.6853414,30.4527195 59.685334,30.4526348 59.6853281,30.4526225 59.6853328,30.4526095 59.6853751)', 'way', 871154699, '{"landuse": "flowerbed"}', '{8114975123,8114975124,8114975125,8895996607,8895996606,8114975126,8114975127,8114975181,8114975123}'),
 ('SRID=4326;LINESTRING(30.4526535 59.6852686,30.4527368 59.6852749,30.4527467 59.6852817,30.4527358 59.6853225,30.4527215 59.6853281,30.4526382 59.6853213,30.4526283 59.6853139,30.4526398 59.6852734,30.4526535 59.6852686)', 'way', 871154701, '{"landuse": "flowerbed"}', '{8114975136,8114975137,8114975138,8114975139,8114975140,8114975141,8114975142,8114975143,8114975136}'),
 ('SRID=4326;LINESTRING(30.4525419 59.6853075,30.4525505 59.6853142,30.4526031 59.6853185,30.4526157 59.6853129,30.4526268 59.6852724,30.4526177 59.6852659,30.4525671 59.6852621,30.452555 59.6852672,30.4525419 59.6853075)', 'way', 871154702, '{"landuse": "flowerbed"}', '{8114975144,8114975145,8114975146,8114975147,8114975148,8114975149,8114975150,8114975151,8114975144}'),
 ('SRID=4326;LINESTRING(30.4526478 59.6852554,30.4526557 59.6852612,30.452739 59.6852678,30.4527533 59.685262,30.452765 59.685222,30.4527443 59.68522,30.4527459 59.685216,30.452673 59.6852102,30.4526587 59.6852148,30.4526478 59.6852554)', 'way', 871154706, '{"landuse": "flowerbed"}', '{8114975172,8114975173,8114975174,8114975175,8114975176,8114975177,8114975178,8114975179,8114975180,8114975172}'),
 ('SRID=4326;LINESTRING(30.4525308 59.6853272,30.4525479 59.6853207,30.452602 59.6853253,30.4526097 59.6853317,30.4525977 59.6853735,30.4525857 59.6853804,30.4525671 59.6853795,30.452562 59.6853695,30.4525568 59.6853608,30.4525449 59.685344,30.4525308 59.6853272)', 'way', 872998899, '{"landuse": "flowerbed"}', '{8129422266,8129422267,8129422268,8129422269,8129422270,8129422271,8129422272,8895996472,8129422273,8895996471,8129422266}'),
 ('SRID=4326;LINESTRING(30.4536402 59.684764,30.4536193 59.6847624,30.4536067 59.6847614)', 'way', 891865282, '{"height": "1.5", "barrier": "fence", "fence_type": "bars"}', '{1635198216,1198356775,8289295975}'),
 ('SRID=4326;LINESTRING(30.4525184 59.6846577,30.4525251 59.684634,30.4525331 59.6846279,30.4525466 59.6846232)', 'way', 922841960, '{"height": "2", "barrier": "fence", "ref:okn": "781610399040356", "historic": "yes", "man_made": "embankment"}', '{8566824024,1653641402,8566824025,8566824026}'),
 ('SRID=4326;LINESTRING(30.453531 59.6847593,30.4531199 59.6847256)', 'way', 922854851, '{"height": "8", "natural": "tree_row", "leaf_type": "broadleaved", "leaf_cycle": "deciduous"}', '{5002059748,5002059751}'),
 ('SRID=4326;LINESTRING(30.4526262 59.684701,30.452599 59.6846895)', 'way', 922854852, '{"highway": "steps"}', '{7927774427,3968068677}'),
 ('SRID=4326;LINESTRING(30.4536067 59.6847614,30.4535894 59.6847601)', 'way', 922854853, '{"height": "1.5", "barrier": "fence", "fence_type": "bars"}', '{8289295975,12023732332}'),
 ('SRID=4326;MULTIPOLYGON(((30.4526552 59.6847274,30.4526587 59.6847165,30.4528767 59.6847343,30.4528732 59.6847452,30.4526552 59.6847274)))', 'way', 871154684, '{"genus": "Cotoneaster", "taxon": "Cotoneaster lucidus", "height": "0.5", "barrier": "hedge", "landuse": "grass", "genus:ru": "Кизильник", "taxon:ru": "Кизильник блестящий", "leaf_type": "broadleaved", "leaf_cycle": "deciduous", "species:ru": "Кизильник блестящий", "species:wikidata": "Q162750"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4531197 59.6851398,30.4531205 59.6851349,30.4531241 59.6851304,30.4531325 59.6851257,30.4531378 59.6851238,30.4531466 59.6851223,30.4531559 59.6851221,30.453165 59.6851233,30.453173 59.6851256,30.4531795 59.685129,30.4531835 59.6851328,30.4531855 59.685137,30.4531853 59.6851413,30.4531829 59.6851454,30.4531786 59.6851491,30.4531713 59.6851525,30.4531634 59.6851545,30.4531533 59.6851554,30.4531431 59.6851547,30.4531339 59.6851525,30.4531264 59.6851489,30.4531217 59.6851446,30.4531197 59.6851398)))', 'way', 871154688, '{"highway": "footway", "surface": "fine_gravel"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4531682 59.6850102,30.4531694 59.6850057,30.453173 59.6850015,30.4531787 59.684998,30.4531868 59.6849952,30.4531962 59.6849937,30.453206 59.6849937,30.4532145 59.684995,30.453222 59.6849973,30.4532281 59.6850005,30.4532323 59.6850046,30.4532341 59.6850091,30.4532335 59.6850137,30.4532298 59.6850185,30.4532234 59.6850226,30.4532151 59.6850253,30.4532056 59.6850267,30.4531956 59.6850267,30.4531843 59.6850246,30.4531752 59.6850205,30.45317 59.6850157,30.4531682 59.6850102)))', 'way', 871154691, '{"highway": "footway"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4526095 59.6853751,30.4526225 59.6853328,30.4526348 59.6853281,30.4527195 59.685334,30.4527302 59.6853414,30.4527175 59.6853841,30.4527025 59.6853899,30.4526201 59.6853832,30.4526095 59.6853751)))', 'way', 871154699, '{"landuse": "flowerbed"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4526283 59.6853139,30.4526398 59.6852734,30.4526535 59.6852686,30.4527368 59.6852749,30.4527467 59.6852817,30.4527358 59.6853225,30.4527215 59.6853281,30.4526382 59.6853213,30.4526283 59.6853139)))', 'way', 871154701, '{"landuse": "flowerbed"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4525419 59.6853075,30.452555 59.6852672,30.4525671 59.6852621,30.4526177 59.6852659,30.4526268 59.6852724,30.4526157 59.6853129,30.4526031 59.6853185,30.4525505 59.6853142,30.4525419 59.6853075)))', 'way', 871154702, '{"landuse": "flowerbed"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4526478 59.6852554,30.4526587 59.6852148,30.452673 59.6852102,30.4527459 59.685216,30.4527443 59.68522,30.452765 59.685222,30.4527533 59.685262,30.452739 59.6852678,30.4526557 59.6852612,30.4526478 59.6852554)))', 'way', 871154706, '{"landuse": "flowerbed"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4525308 59.6853272,30.4525479 59.6853207,30.452602 59.6853253,30.4526097 59.6853317,30.4525977 59.6853735,30.4525857 59.6853804,30.4525671 59.6853795,30.452562 59.6853695,30.4525568 59.6853608,30.4525449 59.685344,30.4525308 59.6853272)))', 'way', 872998899, '{"landuse": "flowerbed"}', NULL),
 ('SRID=4326;LINESTRING(30.4521596 59.6854203,30.4524943 59.6854502)', 'way', 961421780, '{"highway": "footway", "surface": "fine_gravel"}', '{8893386627,4912270255}'),
 ('SRID=4326;LINESTRING(30.4533818 59.6852214,30.4533763 59.68521)', 'way', 961717566, '{"height": "7", "barrier": "fence", "fence_type": "bars", "min_height": "6"}', '{1439053598,1439053596}'),
 ('SRID=4326;LINESTRING(30.4534979 59.6851951,30.4535038 59.6852069)', 'way', 961717567, '{"height": "7", "barrier": "fence", "fence_type": "bars", "min_height": "6"}', '{1439053589,1439053591}'),
 ('SRID=4326;LINESTRING(30.4533763 59.68521,30.4534979 59.6851951)', 'way', 961717568, '{"height": "7", "barrier": "fence", "fence_type": "bars", "min_height": "6"}', '{1439053596,1439053589}'),
 ('SRID=4326;LINESTRING(30.4527378 59.6852117,30.4526559 59.6852052,30.4525684 59.6851982,30.4524641 59.6851898,30.4522584 59.6851734)', 'way', 961717569, '{"access": "private", "highway": "footway", "surface": "fine_gravel", "historic": "yes"}', '{8895975842,8895975876,8895975873,8895975858,3968068679}'),
 ('SRID=4326;LINESTRING(30.4530032 59.685292,30.453022 59.6852839,30.4530407 59.6852758,30.4530635 59.68527,30.4530877 59.685267,30.4531091 59.6852663,30.4531333 59.6852683,30.4531547 59.6852744,30.45322 59.6852491)', 'way', 961717570, '{"access": "private", "highway": "footway", "surface": "fine_gravel", "historic": "yes"}', '{8895975875,8895975856,8895975855,8895975850,8895975854,8895975853,8895975852,8895975851,3968068669}'),
 ('SRID=4326;LINESTRING(30.4524419 59.6852441,30.452456 59.6851977,30.4524483 59.6851915,30.4523702 59.6851856,30.4523568 59.6851898,30.4523826 59.6852055,30.4524088 59.6852218,30.4524248 59.6852328,30.4524419 59.6852441)', 'way', 961717571, '{"landuse": "flowerbed"}', '{8895975865,8895975864,8895975863,8895975862,8895975859,8895975861,8895975860,8895975838,8895975865}'),
 ('SRID=4326;LINESTRING(30.4524824 59.6851946,30.4525509 59.6852001,30.4525595 59.685207,30.4525499 59.6852458,30.4525356 59.685252,30.4524524 59.6852459,30.4524673 59.6851987,30.4524824 59.6851946)', 'way', 961717572, '{"landuse": "flowerbed"}', '{8895975872,8895975871,8895975870,8895975869,8895975868,8895975867,8895975866,8895975872}'),
 ('SRID=4326;LINESTRING(30.4530263 59.6852336,30.4530032 59.685292,30.4529231 59.6852858,30.4527793 59.6852746,30.452638 59.6852636,30.4525513 59.6852568,30.4524466 59.6852487,30.4524641 59.6851898)', 'way', 961717573, '{"access": "private", "highway": "footway", "surface": "fine_gravel", "historic": "yes"}', '{8895975857,8895975875,8895975843,8895975844,8895975848,8895975846,8895975874,8895975858}'),
 ('SRID=4326;LINESTRING(30.4529402 59.6852275,30.4529231 59.6852858,30.4529053 59.6853463,30.4528865 59.6854078)', 'way', 961717574, '{"access": "private", "highway": "footway", "surface": "fine_gravel", "historic": "yes"}', '{8895975877,8895975843,8895975880,8895975878}'),
 ('SRID=4326;LINESTRING(30.4526559 59.6852052,30.452638 59.6852636,30.4526195 59.6853238,30.4526009 59.6853847,30.4527422 59.6853961,30.4528865 59.6854078)', 'way', 961717575, '{"access": "private", "highway": "footway", "surface": "fine_gravel", "historic": "yes"}', '{8895975876,8895975848,8895975849,8895975879,8895975847,8895975878}'),
 ('SRID=4326;LINESTRING(30.4525684 59.6851982,30.4525513 59.6852568,30.4525338 59.685317,30.4526195 59.6853238,30.4527609 59.6853349,30.4529053 59.6853463)', 'way', 961717576, '{"access": "private", "highway": "footway", "surface": "fine_gravel", "historic": "yes"}', '{8895975873,8895975846,8895975881,8895975849,8895975845,8895975880}'),
 ('SRID=4326;LINESTRING(30.4527487 59.6852082,30.4523303 59.6851757,30.452333 59.6851663,30.4527521 59.6851991,30.4527487 59.6852082)', 'way', 961717577, '{"landuse": "flowerbed"}', '{8895975885,8895975884,8895975883,8895975882,8895975885}'),
 ('SRID=4326;LINESTRING(30.4532064 59.6852443,30.4528543 59.6852169,30.452857 59.6852074,30.4532097 59.6852351,30.4532064 59.6852443)', 'way', 961717578, '{"landuse": "flowerbed"}', '{8895975889,8895975888,8895975887,8895975886,8895975889}'),
 ('SRID=4326;LINESTRING(30.4531538 59.6852696,30.4531388 59.6852648,30.4531262 59.6852629,30.4531109 59.6852622,30.4531259 59.6852456,30.4532017 59.6852514,30.4531538 59.6852696)', 'way', 961717579, '{"landuse": "flowerbed"}', '{8895975901,8895975902,8895975900,8895975903,8895975891,8895975890,8895975901}'),
 ('SRID=4326;LINESTRING(30.4530554 59.6852658,30.4530414 59.6852392,30.453028 59.6852429,30.4530143 59.6852802,30.4530288 59.6852733,30.453041 59.6852693,30.4530554 59.6852658)', 'way', 961717580, '{"landuse": "flowerbed"}', '{8895975898,8895975895,8895975896,8895975907,8895975897,8895975906,8895975898}'),
 ('SRID=4326;LINESTRING(30.4530632 59.6852641,30.4530782 59.6852621,30.4530921 59.6852616,30.4531031 59.6852618,30.4531172 59.6852446,30.4530501 59.6852392,30.4530632 59.6852641)', 'way', 961717581, '{"landuse": "flowerbed"}', '{8895975905,8895975899,8895975904,8895975892,8895975893,8895975894,8895975905}'),
 ('SRID=4326;LINESTRING(30.4530456 59.6853334,30.4530424 59.6853304,30.4530402 59.6853274,30.4530387 59.6853245,30.4530377 59.6853204)', 'way', 961717582, '{"height": "7", "barrier": "fence", "fence_type": "bars", "min_height": "6"}', '{1439053627,8914843793,8895996425,8914843794,1439053619}'),
 ('SRID=4326;LINESTRING(30.4525812 59.6854845,30.4526564 59.6854895)', 'way', 961717593, '{"height": "2", "barrier": "fence", "material": "stone", "fence_type": "bars", "min_height": "1"}', '{8895996555,1439053669}'),
 ('SRID=4326;LINESTRING(30.4527747 59.6854387,30.4528506 59.685445,30.4528681 59.6854402,30.4528755 59.6854172,30.4528654 59.6854091,30.4527852 59.6854026,30.4527687 59.6854078,30.4527618 59.6854305,30.4527747 59.6854387)', 'way', 961717594, '{"landuse": "flowerbed"}', '{8895996465,8895996464,8895996463,8895996462,8895996461,8895996460,8895996459,8895996458,8895996465}'),
 ('SRID=4326;LINESTRING(30.4525201 59.6853123,30.4525328 59.6853069,30.4525442 59.6852666,30.4525351 59.6852597,30.4524557 59.6852538,30.4524775 59.6852724,30.4524969 59.6852906,30.4525201 59.6853123)', 'way', 961717595, '{"landuse": "flowerbed"}', '{8895996470,8895996469,8895996468,8895996467,8895996466,8895996428,8895996429,8895996470}'),
 ('SRID=4326;LINESTRING(30.4523418 59.6851889,30.4523598 59.6851989,30.4523808 59.6852109,30.4524103 59.6852297,30.4524317 59.6852443,30.4524536 59.68526,30.4524825 59.6852834,30.4524981 59.6852989,30.4525179 59.6853192,30.452532 59.6853359,30.4525456 59.6853529,30.4525561 59.6853703,30.4525656 59.6853881,30.4525739 59.6854062,30.4525791 59.6854198,30.4525811 59.6854262,30.452574 59.6854304,30.4525626 59.6854314,30.4525546 59.6854286,30.4525509 59.6854228,30.4525457 59.6854094,30.4525376 59.6853916,30.4525283 59.6853742,30.4525181 59.6853572,30.4525048 59.6853406,30.452491 59.6853243,30.4524715 59.6853042,30.4524562 59.6852892,30.452428 59.6852663,30.4524066 59.6852509,30.4523855 59.6852365,30.4523561 59.6852179,30.4523226 59.6851969,30.4523418 59.6851889)', 'way', 961717596, '{"landuse": "grass"}', '{8895996495,8895975839,8895996483,8895996484,8895996485,8895996486,8895996487,8895996488,8895996489,8895996490,8895996491,8895996492,8895996493,8895996494,8895996496,8895996473,8895996479,8895996480,8895996474,8895996509,8895996508,8895996507,8895996506,8895996505,8895996504,8895996503,8895996502,8895996501,8895996500,8895996499,8895996498,8895996497,8895996478,8895996495}'),
 ('SRID=4326;LINESTRING(30.4523081 59.6852118,30.4522803 59.6851945,30.4522795 59.6852157,30.4523143 59.6852356,30.4523427 59.6852536,30.4523628 59.6852673,30.4523827 59.6852816,30.4524087 59.6853027,30.4524225 59.6853163,30.4524411 59.6853354,30.452454 59.6853507,30.452466 59.6853657,30.4524751 59.6853808,30.4524839 59.6853973,30.4524918 59.6854125,30.4524982 59.6854272,30.452501 59.6854325,30.4525097 59.6854362,30.4525224 59.6854348,30.4525257 59.6854303,30.4525231 59.6854242,30.4525171 59.6854097,30.4525091 59.6853943,30.4525002 59.6853776,30.4524909 59.685362,30.4524785 59.6853465,30.4524653 59.6853309,30.4524465 59.6853116,30.4524322 59.6852976,30.4524056 59.685276,30.4523853 59.6852614,30.4523649 59.6852475,30.4523362 59.6852293,30.4523081 59.6852118)', 'way', 961717597, '{"landuse": "grass"}', '{8895996522,8895996477,8895996536,8895996524,8895996525,8895996526,8895996527,8895996528,8895996529,8895996530,8895996531,8895996532,8895996533,8895996534,8895996535,8895996537,8895996482,8895996476,8895996481,8895996523,8895996475,8895996521,8895996520,8895996519,8895996518,8895996517,8895996516,8895996515,8895996514,8895996513,8895996512,8895996511,8895996510,8895996522}'),
 ('SRID=4326;LINESTRING(30.4526076 59.685425,30.4526842 59.6854313,30.4527032 59.6854269,30.4527112 59.6854034,30.4527003 59.6853955,30.4526196 59.6853891,30.4526042 59.6853942,30.4525975 59.6854176,30.4526076 59.685425)', 'way', 961717598, '{"landuse": "flowerbed"}', '{8895996545,8895996544,8895996543,8895996542,8895996541,8895996540,8895996539,8895996538,8895996545}'),
 ('SRID=4326;LINESTRING(30.4528639 59.685494,30.4528702 59.6854731,30.4527911 59.6854671,30.4527849 59.685488,30.4528639 59.685494)', 'way', 961717599, '{"genus": "Syrínga", "taxon": "Syringa meyeri", "natural": "scrub", "genus:ru": "Сирень", "taxon:ru": "Сирень Мейера", "leaf_type": "broadleaved", "leaf_cycle": "deciduous"}', '{8895996549,8895996548,8895996547,8895996546,8895996549}'),
 ('SRID=4326;LINESTRING(30.4526433 59.6854773,30.4526495 59.6854564,30.4525705 59.6854504,30.4525642 59.6854713,30.4526433 59.6854773)', 'way', 961717600, '{"genus": "Syrínga", "taxon": "Syringa meyeri", "natural": "scrub", "genus:ru": "Сирень", "taxon:ru": "Сирень Мейера", "leaf_type": "broadleaved", "leaf_cycle": "deciduous"}', '{8895996553,8895996552,8895996551,8895996550,8895996553}'),
 ('SRID=4326;LINESTRING(30.4528746 59.6855048,30.4528709 59.6855164)', 'way', 961717601, '{"height": "8", "barrier": "fence", "fence_type": "bars", "min_height": "6.65"}', '{1439053674,8895996554}'),
 ('SRID=4326;LINESTRING(30.4529138 59.6853368,30.4529235 59.6853445,30.4529678 59.6853472,30.4529853 59.6853413,30.4529963 59.6853005,30.4529866 59.6852936,30.4529427 59.6852903,30.4529263 59.6852951,30.4529138 59.6853368)', 'way', 961717602, '{"landuse": "flowerbed"}', '{8895996564,8895996563,8895996562,8895996561,8895996560,8895996559,8895996558,8895996557,8895996564}'),
 ('SRID=4326;LINESTRING(30.452933 59.6852753,30.4529441 59.6852838,30.4529886 59.6852873,30.453002 59.6852821,30.4530171 59.6852433,30.4530088 59.6852371,30.4529582 59.685233,30.4529444 59.6852374,30.452933 59.6852753)', 'way', 961717603, '{"landuse": "flowerbed"}', '{8895996572,8895996571,8895996570,8895996569,8895996568,8895996567,8895996566,8895996565,8895996572}'),
 ('SRID=4326;LINESTRING(30.4525595 59.6852465,30.4525692 59.6852544,30.4526207 59.6852585,30.4526333 59.6852538,30.452645 59.6852146,30.4526353 59.6852076,30.4525847 59.6852036,30.4525709 59.685208,30.4525595 59.6852465)', 'way', 961717604, '{"landuse": "flowerbed"}', '{8895996580,8895996579,8895996578,8895996577,8895996576,8895996575,8895996574,8895996573,8895996580}'),
 ('SRID=4326;LINESTRING(30.452817 59.6852667,30.4528288 59.6852748,30.4529066 59.6852809,30.45292 59.6852751,30.4529319 59.6852358,30.4529216 59.6852291,30.452851 59.685224,30.4528493 59.6852281,30.452831 59.6852267,30.452817 59.6852667)', 'way', 961717605, '{"landuse": "flowerbed"}', '{8895996589,8895996588,8895996587,8895996586,8895996585,8895996584,8895996581,8895996583,8895996582,8895996589}'),
 ('SRID=4326;LINESTRING(30.4527946 59.6853272,30.4528053 59.6853349,30.4528878 59.6853416,30.4529031 59.6853359,30.4529154 59.6852941,30.4529042 59.6852874,30.4528247 59.6852816,30.4528087 59.6852864,30.4527946 59.6853272)', 'way', 961717606, '{"landuse": "flowerbed"}', '{8895996597,8895996596,8895996595,8895996594,8895996593,8895996592,8895996591,8895996590,8895996597}'),
 ('SRID=4326;LINESTRING(30.4527745 59.6853889,30.4527865 59.6853969,30.4528677 59.6854032,30.4528839 59.6853982,30.4528953 59.6853552,30.4528845 59.6853477,30.4528052 59.6853419,30.4527899 59.6853454,30.4527745 59.6853889)', 'way', 961717607, '{"landuse": "flowerbed"}', '{8895996605,8895996604,8895996603,8895996602,8895996601,8895996600,8895996599,8895996598,8895996605}'),
 ('SRID=4326;LINESTRING(30.452565 59.6854206,30.4525598 59.6854071,30.4525516 59.6853892,30.4525422 59.6853716,30.4525319 59.6853544,30.4525184 59.6853376,30.4525045 59.6853211,30.4524848 59.6853009,30.4524693 59.6852857,30.4524408 59.6852624,30.4524192 59.685247,30.4523979 59.6852324,30.4523685 59.6852137,30.4523402 59.6851962)', 'way', 961717608, '{"genus": "Tilia", "height": "6", "natural": "tree_row", "genus:ru": "Липа", "leaf_type": "broadleaved", "leaf_cycle": "deciduous"}', '{8895996623,8895996621,8895996620,8895996619,8895996618,8895996617,8895996616,8895996615,8895996614,8895996613,8895996612,8895996611,8895996610,8895996622}'),
 ('SRID=4326;LINESTRING(30.4525109 59.6854262,30.4525044 59.6854114,30.4524965 59.6853961,30.4524877 59.6853796,30.4524784 59.6853642,30.4524662 59.6853489,30.4524532 59.6853335,30.4524345 59.6853143,30.4524204 59.6853005,30.4523942 59.6852791,30.452374 59.6852647,30.4523538 59.6852509,30.4523252 59.6852327,30.4522972 59.6852153)', 'way', 961717609, '{"genus": "Tilia", "height": "6", "natural": "tree_row", "genus:ru": "Липа", "leaf_type": "broadleaved", "leaf_cycle": "deciduous"}', '{8895996637,8895996635,8895996634,8895996633,8895996632,8895996631,8895996630,8895996629,8895996628,8895996627,8895996626,8895996625,8895996624,8895996636}'),
 ('SRID=4326;LINESTRING(30.4523179 59.6852068,30.4522881 59.6851891,30.4522584 59.6851734,30.4522785 59.6851511,30.4525958 59.6847532,30.4529382 59.6847803,30.4535778 59.6848316)', 'way', 961717610, '{"highway": "footway", "surface": "fine_gravel"}', '{8114975114,8895996608,3968068679,8114975109,8114975051,8114975050,8114975049}'),
 ('SRID=4326;LINESTRING(30.4527224 59.6854618,30.4527166 59.6854798)', 'way', 961717612, '{"highway": "steps", "incline": "up", "surface": "paving_stones"}', '{1664064412,8895996662}'),
 ('SRID=4326;LINESTRING(30.4534116 59.6851536,30.4533349 59.6850974,30.4533424 59.6850906,30.4534424 59.6850974,30.453427 59.6851532,30.4534116 59.6851536)', 'way', 962062985, '{"natural": "scrub", "leaf_type": "broadleaved", "leaf_cycle": "deciduous"}', '{8899249763,8899249762,8899249761,8899249760,8899249759,8899249763}'),
 ('SRID=4326;LINESTRING(30.4535137 59.6851734,30.4534909 59.6851715,30.4535 59.6851418,30.4535229 59.6851437)', 'way', 962062988, '{"source:taxon": "board"}', '{8899249777,8899249776,8899249775,8899249774}'),
 ('SRID=4326;LINESTRING(30.4534505 59.6851512,30.4535484 59.6848425)', 'way', 962062989, '{"genus": "Prunus", "taxon": "Prunus virginiana", "height": "1.5", "barrier": "hedge", "genus:ru": "Черёмуха", "taxon:ru": "Черёмуха виргинская", "leaf_type": "broadleaved", "leaf_cycle": "deciduous", "source:taxon": "board"}', '{8899249781,8899249780}'),
 ('SRID=4326;LINESTRING(30.4532761 59.6852013,30.4533137 59.6852128,30.453319 59.6851999,30.4533257 59.6851898,30.4533338 59.6851796,30.4533458 59.6851715,30.4533606 59.6851647,30.453378 59.6851586,30.4533941 59.6851559,30.4533211 59.6851024,30.4533083 59.6851038,30.4532761 59.6852013)', 'way', 962062990, '{"natural": "scrub", "leaf_type": "broadleaved", "leaf_cycle": "deciduous"}', '{8899249792,8899249791,8899249790,8899249789,8899249788,8899249787,8899249786,8899249785,8899249784,8899249783,8899249782,8899249792}'),
 ('SRID=4326;LINESTRING(30.4534315 59.6851615,30.4534654 59.685163)', 'way', 962062991, '{"highway": "footway", "surface": "fine_gravel"}', '{8114975036,3968068687}'),
 ('SRID=4326;LINESTRING(30.45277 59.6851675,30.4528221 59.6849965,30.4528061 59.6849952,30.4528148 59.6849678,30.4528309 59.6849691,30.4528877 59.684789)', 'way', 962062992, '{"genus": "Cotoneaster", "taxon": "Cotoneaster lucidus", "height": "0.5", "barrier": "hedge", "genus:ru": "Кизильник", "taxon:ru": "Кизильник блестящий", "leaf_type": "broadleaved", "leaf_cycle": "deciduous", "species:ru": "Кизильник блестящий", "source:taxon": "board", "species:wikidata": "Q162750"}', '{8899249807,8899249801,8899249800,8899249799,8899249798,8899249806}'),
 ('SRID=4326;LINESTRING(30.4530825 59.6850727,30.4530768 59.6850789,30.4531357 59.6851196,30.4531475 59.6851179,30.4531599 59.6851179,30.4531731 59.6851201,30.4531813 59.685123,30.4532721 59.6850914,30.45327 59.6850856,30.4530825 59.6850727)', 'way', 962062993, '{"natural": "scrub", "leaf_type": "broadleaved", "leaf_cycle": "deciduous"}', '{8899249816,8899249815,8899249814,8899249813,8899249812,8899249811,8899249810,8899249809,8899249808,8899249816}'),
 ('SRID=4326;LINESTRING(30.4531159 59.685148,30.4530357 59.6851757,30.4530252 59.6851728,30.4530493 59.6850863,30.4530634 59.6850845,30.4531219 59.6851249,30.4531169 59.6851285,30.4531133 59.6851328,30.4531117 59.6851378,30.4531125 59.6851429,30.4531159 59.685148)', 'way', 962062994, '{"natural": "scrub", "leaf_type": "broadleaved", "leaf_cycle": "deciduous"}', '{8899299126,8899299125,8899299124,8899299123,8899299122,8899299121,8899299120,8899299119,8899299118,8899299117,8899299126}'),
 ('SRID=4326;LINESTRING(30.4531566 59.6851458,30.4531627 59.6851441,30.4531665 59.6851411,30.4531672 59.6851376,30.4531645 59.6851343,30.4531591 59.685132,30.4531523 59.6851313,30.4531455 59.6851322,30.4531404 59.6851346,30.4531381 59.685138,30.4531391 59.6851415,30.4531433 59.6851444,30.4531496 59.6851459,30.4531566 59.6851458)', 'way', 962062995, '{"landuse": "grass"}', '{8899299139,8899299138,8899299137,8899299136,8899299135,8899299134,8899299133,8899299132,8899299131,8899299130,8899299129,8899299128,8899299140,8899299139}'),
 ('SRID=4326;LINESTRING(30.4531836 59.6851532,30.45325 59.6851972,30.4532587 59.6851977,30.4532923 59.6851023,30.4532804 59.6850981,30.4531914 59.68513,30.4531946 59.6851353,30.453195 59.6851401,30.4531936 59.6851444,30.45319 59.6851488,30.4531836 59.6851532)', 'way', 962062996, '{"natural": "scrub", "leaf_type": "broadleaved", "leaf_cycle": "deciduous"}', '{8899299150,8899299149,8899299141,8899299148,8899299142,8899299147,8899299146,8899299145,8899299144,8899299143,8899299150}'),
 ('SRID=4326;LINESTRING(30.4530454 59.6851813,30.4531256 59.6851544,30.4531347 59.6851575,30.4531466 59.6851595,30.4531581 59.6851596,30.4531699 59.6851581,30.4532258 59.6851962,30.4532198 59.6852006,30.4530501 59.6851877,30.4530454 59.6851813)', 'way', 962062997, '{"natural": "scrub", "leaf_type": "broadleaved", "leaf_cycle": "deciduous"}', '{8899299158,8899299157,8899299156,8899299155,8899299154,8899299153,8899299152,8899299151,8899249778,8899299158}'),
 ('SRID=4326;LINESTRING(30.4532162 59.6852145,30.4528382 59.6851861,30.4528402 59.6851794,30.452846 59.6851798,30.4528466 59.6851777,30.4532188 59.6852056,30.4532162 59.6852145)', 'way', 962062998, '{"landuse": "grass"}', '{8899299165,8899299164,8899299163,8899299161,8899299160,8899299162,8899299165}'),
 ('SRID=4326;LINESTRING(30.4532627 59.6852077,30.4528577 59.6851769,30.4529093 59.6850046,30.4529281 59.685006,30.4529375 59.6849752,30.4529207 59.6849738,30.4529724 59.6848063,30.4535349 59.6848517,30.4534357 59.6851637,30.4534213 59.6851644,30.4534075 59.6851668,30.4533894 59.6851708,30.4533747 59.6851759,30.4533579 59.6851844,30.4533479 59.6851932,30.4533405 59.6852038,30.4533345 59.6852155,30.4533291 59.6852257,30.4532627 59.6852077)', 'way', 962382760, '{"ref": "6", "name": "Ботанический сад", "leisure": "garden", "name:en": "The Botanical Garden", "wikidata": "Q118122045", "garden:type": "botanical"}', '{8902082028,8902082027,8902082026,8902082025,8902082024,8902082023,8902082022,8902082021,8902082020,8902027911,8902082019,8902082018,8902082017,8902027912,8902027916,8902027913,8902027915,8902027914,8902082028}'),
 ('SRID=4326;LINESTRING(30.4533751 59.6849668,30.453381 59.6849616,30.4534833 59.6849698,30.4534679 59.6850219,30.4533751 59.6849668)', 'way', 962382761, '{"natural": "scrub", "leaf_type": "broadleaved", "leaf_cycle": "deciduous"}', '{8902082032,8902082031,8902082030,8902082029,8902082032}'),
 ('SRID=4326;LINESTRING(30.4529465 59.6849826,30.4530583 59.6849454,30.4530566 59.6849397,30.4529452 59.6849315,30.4529338 59.6849691,30.4529492 59.6849698,30.4529465 59.6849826)', 'way', 962382762, '{"natural": "scrub", "leaf_type": "broadleaved", "leaf_cycle": "deciduous"}', '{8902082038,8902082037,8902082036,8902082035,8902082034,8902082033,8902082038}'),
 ('SRID=4326;LINESTRING(30.4530344 59.685052,30.4530456 59.6850508,30.4530757 59.684955,30.4530662 59.6849507,30.4529465 59.6849918,30.4530344 59.685052)', 'way', 962382763, '{"natural": "scrub", "leaf_type": "broadleaved", "leaf_cycle": "deciduous"}', '{8902082047,8902082046,8902082045,8902082044,8902082043,8902082047}'),
 ('SRID=4326;LINESTRING(30.4529083 59.6850544,30.4530153 59.6850613,30.4530221 59.685056,30.4529398 59.6850009,30.4529378 59.6850121,30.4529184 59.6850114,30.4529083 59.6850544)', 'way', 962382764, '{"natural": "scrub", "leaf_type": "broadleaved", "leaf_cycle": "deciduous"}', '{8902082054,8902082053,8902082052,8902082051,8902082050,8902082049,8902082054}'),
 ('SRID=4326;LINESTRING(30.4528875 59.6851184,30.4530138 59.6850731,30.4530125 59.6850679,30.4529043 59.6850625,30.4528875 59.6851184)', 'way', 962382765, '{"natural": "scrub", "leaf_type": "broadleaved", "leaf_cycle": "deciduous"}', '{8902082059,8902082058,8902082057,8902082056,8902082059}'),
 ('SRID=4326;LINESTRING(30.4529823 59.6851789,30.4529779 59.6851826,30.4528698 59.6851739,30.4528812 59.685135,30.4529823 59.6851789)', 'way', 962382766, '{"landuse": "grass"}', '{8902082065,8902082064,8902082063,8902082062,8902082065}'),
 ('SRID=4326;LINESTRING(30.4529896 59.6851748,30.4530072 59.6851719,30.4530311 59.6850841,30.4530206 59.6850798,30.4528885 59.6851275,30.4529896 59.6851748)', 'way', 962382767, '{"natural": "scrub", "leaf_type": "broadleaved", "leaf_cycle": "deciduous"}', '{8902082070,8902082069,8902082068,8902082067,8902082066,8902082070}'),
 ('SRID=4326;LINESTRING(30.4533332 59.6850719,30.4534612 59.68503,30.4533655 59.6849715,30.4533546 59.6849733,30.4533227 59.6850682,30.4533332 59.6850719)', 'way', 962382768, '{"natural": "scrub", "leaf_type": "broadleaved", "leaf_cycle": "deciduous"}', '{8902082080,8902082079,8902082078,8902082077,8902082076,8902082080}'),
 ('SRID=4326;LINESTRING(30.4533437 59.685083,30.4534444 59.6850899,30.4534619 59.6850382,30.4533411 59.685078,30.4533437 59.685083)', 'way', 962382769, '{"natural": "scrub", "leaf_type": "broadleaved", "leaf_cycle": "deciduous"}', '{8902082084,8902082083,8902082082,8902082081,8902082084}'),
 ('SRID=4326;LINESTRING(30.4532392 59.6850173,30.4533204 59.6850217,30.4533057 59.6850665,30.4532939 59.6850677,30.4532321 59.6850233,30.4532368 59.6850199,30.4532392 59.6850173)', 'way', 962382770, '{"genus": "Rosa", "taxon": "Rosa spinosissima", "natural": "scrub", "genus:ru": "Роза", "taxon:ru": "Роза колючейшая", "leaf_type": "broadleaved", "leaf_cycle": "deciduous", "source:taxon": "board"}', '{8902082090,8902082089,8902082088,8902082087,8902082086,8902082085,8902082090}'),
 ('SRID=4326;LINESTRING(30.4532419 59.6850113,30.4532411 59.6850057,30.4532374 59.6850005,30.4533289 59.6849694,30.4533388 59.6849721,30.4533251 59.6850146,30.4532419 59.6850113)', 'way', 962382771, '{"genus": "Rosa", "taxon": "Rosa spinosissima", "natural": "scrub", "genus:ru": "Роза", "taxon:ru": "Роза колючейшая", "leaf_type": "broadleaved", "leaf_cycle": "deciduous", "source:taxon": "board"}', '{8902082096,8902082095,8902082094,8902082093,8902082092,8902082091,8902082096}'),
 ('SRID=4326;LINESTRING(30.4532258 59.6849527,30.4532116 59.6849902,30.4532207 59.684992,30.4532298 59.6849953,30.4533219 59.6849634,30.4533191 59.6849588,30.4532258 59.6849527)', 'way', 962382772, '{"genus": "Rosa", "taxon": "Rosa spinosissima", "natural": "scrub", "genus:ru": "Роза", "taxon:ru": "Роза колючейшая", "leaf_type": "broadleaved", "leaf_cycle": "deciduous", "source:taxon": "board"}', '{8902082102,8902082101,8902082100,8902082099,8902082098,8902082097,8902082102}'),
 ('SRID=4326;LINESTRING(30.453114 59.6849505,30.4531198 59.684945,30.4532124 59.6849517,30.4532004 59.6849896,30.4531904 59.6849904,30.45318 59.6849928,30.453114 59.6849505)', 'way', 962382773, '{"genus": "Rosa", "taxon": "Rosa spinosissima", "natural": "scrub", "genus:ru": "Роза", "taxon:ru": "Роза колючейшая", "leaf_type": "broadleaved", "leaf_cycle": "deciduous", "source:taxon": "board"}', '{8902082108,8902082107,8902082106,8902082105,8902082104,8902082103,8902082108}'),
 ('SRID=4326;LINESTRING(30.4530763 59.6850024,30.4531619 59.6850065,30.4531647 59.6850018,30.4531695 59.6849976,30.4531032 59.6849548,30.453091 59.6849565,30.4530763 59.6850024)', 'way', 962382774, '{"genus": "Rosa", "taxon": "Rosa spinosissima", "natural": "scrub", "genus:ru": "Роза", "taxon:ru": "Роза колючейшая", "leaf_type": "broadleaved", "leaf_cycle": "deciduous", "source:taxon": "board"}', '{8902082109,8902082114,8902082113,8902082112,8902082111,8902082110,8902082109}'),
 ('SRID=4326;LINESTRING(30.4530716 59.6850547,30.4530603 59.6850515,30.4530743 59.6850085,30.4531615 59.6850116,30.4531626 59.685015,30.4531656 59.685019,30.4530716 59.6850547)', 'way', 962382775, '{"genus": "Rosa", "taxon": "Rosa spinosissima", "natural": "scrub", "genus:ru": "Роза", "taxon:ru": "Роза колючейшая", "leaf_type": "broadleaved", "leaf_cycle": "deciduous", "source:taxon": "board"}', '{8902082120,8902082119,8902082118,8902082117,8902082116,8902082115,8902082120}'),
 ('SRID=4326;LINESTRING(30.4531735 59.6850722,30.4531863 59.6850287,30.4531799 59.6850271,30.4531749 59.6850252,30.4530791 59.6850599,30.453083 59.685065,30.4531735 59.6850722)', 'way', 962382776, '{"genus": "Rosa", "taxon": "Rosa spinosissima", "natural": "scrub", "genus:ru": "Роза", "taxon:ru": "Роза колючейшая", "leaf_type": "broadleaved", "leaf_cycle": "deciduous", "source:taxon": "board"}', '{8902082126,8902082125,8902082124,8902082123,8902082122,8902082121,8902082126}'),
 ('SRID=4326;LINESTRING(30.4531903 59.6850727,30.4532727 59.6850781,30.4532816 59.6850715,30.4532223 59.6850274,30.453211 59.6850297,30.453201 59.6850303,30.4531903 59.6850727)', 'way', 962382777, '{"genus": "Rosa", "taxon": "Rosa spinosissima", "natural": "scrub", "genus:ru": "Роза", "taxon:ru": "Роза колючейшая", "leaf_type": "broadleaved", "leaf_cycle": "deciduous", "source:taxon": "board"}', '{8902082132,8902082131,8902082130,8902082129,8902082128,8902082127,8902082132}'),
 ('SRID=4326;LINESTRING(30.453206 59.6849937,30.4532201 59.6849487)', 'way', 962382778, '{"highway": "footway", "surface": "fine_gravel"}', '{8114975081,8902082149}'),
 ('SRID=4326;LINESTRING(30.4532335 59.6850137,30.4533306 59.6850189)', 'way', 962382779, '{"highway": "footway", "surface": "fine_gravel"}', '{8114975086,8902082150}'),
 ('SRID=4326;LINESTRING(30.4531682 59.6850102,30.4530675 59.6850048)', 'way', 962382780, '{"highway": "footway", "surface": "fine_gravel"}', '{8114975094,8902082151}'),
 ('SRID=4326;LINESTRING(30.4531253 59.6850083,30.4531256 59.6850158,30.4531288 59.6850232,30.4531349 59.6850302,30.4531434 59.6850364,30.4531543 59.6850416,30.4531669 59.6850457,30.4531809 59.6850485,30.4531957 59.6850498,30.4532107 59.6850496,30.4532253 59.685048,30.4532391 59.685045,30.4532514 59.6850406,30.4532618 59.6850352,30.4532699 59.6850288,30.4532753 59.6850217,30.4532779 59.6850143,30.4532776 59.6850067,30.4532744 59.6849993,30.4532684 59.6849924,30.4532598 59.6849862,30.453249 59.6849809,30.4532363 59.6849768,30.4532224 59.6849741,30.4532076 59.6849728,30.4531926 59.6849729,30.4531779 59.6849745,30.4531642 59.6849776,30.4531519 59.6849819,30.4531415 59.6849874,30.4531334 59.6849938,30.4531279 59.6850008,30.4531253 59.6850083)', 'way', 962382781, '{"genus": "Tilia", "height": "6", "natural": "tree_row", "genus:ru": "Липа", "leaf_type": "broadleaved", "leaf_cycle": "deciduous"}', '{8902082167,8902082134,8902082166,8902082133,8902082165,8902082148,8902082164,8902082147,8902082163,8902082146,8902082162,8902082145,8902082161,8902082144,8902082160,8902082143,8902082159,8902082142,8902082158,8902082141,8902082157,8902082140,8902082156,8902082139,8902082155,8902082138,8902082154,8902082137,8902082153,8902082136,8902082152,8902082135,8902082167}'),
 ('SRID=4326;LINESTRING(30.4531956 59.6850267,30.4531801 59.6850762)', 'way', 962382782, '{"highway": "footway", "surface": "fine_gravel"}', '{8114975091,8902082168}'),
 ('SRID=4326;LINESTRING(30.452898 59.6850578,30.4529124 59.6850066,30.4529307 59.6850078,30.4529356 59.6849912,30.4529412 59.6849735,30.4529245 59.6849722,30.4529389 59.6849276)', 'way', 962382783, '{"highway": "footway", "surface": "fine_gravel"}', '{1665582241,1738381535,8902082040,8902082170,8902082039,8902082169,1665582237}'),
 ('SRID=4326;LINESTRING(30.4532177 59.684877,30.4532251 59.6848743,30.4532339 59.6848728,30.4532432 59.6848726,30.4532523 59.6848737,30.4532603 59.6848761,30.4532684 59.6848807,30.4532708 59.6848832,30.4532728 59.6848874,30.4532726 59.6848917,30.4532702 59.6848959,30.4532659 59.6848995,30.4532598 59.6849025,30.4532507 59.684905,30.4532406 59.6849059,30.4532304 59.6849052,30.4532212 59.6849029,30.453213 59.6848988,30.453209 59.6848951,30.453207 59.6848903,30.4532078 59.6848854,30.4532114 59.6848808,30.4532177 59.684877)', 'way', 962678725, '{"highway": "footway", "surface": "fine_gravel"}', '{8904992660,8904992659,8904992658,8904992657,8904992656,8904992655,8904992654,8904992653,8904992652,8904992651,8904992650,8904992649,8904992648,8904992647,8904992646,8904992645,8904992644,8904992643,8904992642,8904992641,8904992640,8904992639,8904992660}'),
 ('SRID=4326;LINESTRING(30.4532432 59.6848971,30.4532493 59.6848954,30.4532531 59.6848924,30.4532538 59.6848889,30.4532511 59.6848856,30.4532457 59.6848833,30.4532389 59.6848826,30.4532321 59.6848835,30.453227 59.684886,30.4532247 59.6848893,30.4532257 59.6848928,30.4532299 59.6848957,30.4532362 59.6848972,30.4532432 59.6848971)', 'way', 962678726, '{"landuse": "grass"}', '{8904992673,8904992672,8904992671,8904992670,8904992669,8904992668,8904992667,8904992666,8904992665,8904992664,8904992663,8904992662,8904992661,8904992673}'),
 ('SRID=4326;LINESTRING(30.4530998 59.6849248,30.4531105 59.684928,30.4532056 59.6848974,30.4532029 59.6848932,30.4532023 59.6848877,30.4532043 59.6848829,30.4532098 59.6848776,30.4531384 59.6848341,30.4531253 59.6848349,30.4530998 59.6849248)', 'way', 962678727, '{"natural": "scrub", "leaf_type": "broadleaved", "leaf_cycle": "deciduous"}', '{8904992682,8904992681,8904992680,8904992679,8904992637,8904992678,8904992677,8904992676,8904992675,8904992682}'),
 ('SRID=4326;LINESTRING(30.4530724 59.6849262,30.4530868 59.6849239,30.4531127 59.6848333,30.4531034 59.6848301,30.4529683 59.6848711,30.4530724 59.6849262)', 'way', 962678728, '{"natural": "scrub", "leaf_type": "broadleaved", "leaf_cycle": "deciduous"}', '{8904992687,8904992686,8904992685,8904992684,8904992683,8904992687}'),
 ('SRID=4326;LINESTRING(30.4530589 59.6849341,30.4530633 59.6849302,30.452961 59.6848772,30.4529482 59.6849246,30.4530589 59.6849341)', 'way', 962678729, '{"natural": "scrub", "leaf_type": "broadleaved", "leaf_cycle": "deciduous"}', '{8904992691,8904992690,8904992689,8904992688,8904992691}'),
 ('SRID=4326;LINESTRING(30.4531212 59.684939,30.4533222 59.6849516,30.4533269 59.6849477,30.4532581 59.6849071,30.4532455 59.6849087,30.4532339 59.6849085,30.4532243 59.684907,30.4532133 59.6849034,30.4531185 59.6849335,30.4531212 59.684939)', 'way', 962678730, '{"natural": "scrub", "leaf_type": "broadleaved", "leaf_cycle": "deciduous"}', '{8904992699,8904992698,8904992697,8904992696,8904992692,8904992638,8904992695,8904992694,8904992693,8904992699}'),
 ('SRID=4326;LINESTRING(30.453536 59.6848401,30.4529797 59.6847958,30.452977 59.6848046,30.4535329 59.6848493,30.453536 59.6848401)', 'way', 962714214, '{"landuse": "flowerbed"}', '{8905335420,8905335419,8905335418,8905335417,8905335420}'),
 ('SRID=4326;LINESTRING(30.4534135 59.68485,30.4534175 59.684847,30.4535189 59.6848554,30.4535068 59.684899,30.4534135 59.68485)', 'way', 962714215, '{"natural": "scrub", "leaf_type": "broadleaved", "leaf_cycle": "deciduous"}', '{8905335435,8905335434,8905335433,8905335432,8905335435}'),
 ('SRID=4326;LINESTRING(30.4533819 59.6849565,30.4533809 59.6849511,30.4535014 59.6849122,30.4534847 59.684964,30.4533819 59.6849565)', 'way', 962714216, '{"natural": "scrub", "leaf_type": "broadleaved", "leaf_cycle": "deciduous"}', '{8905335439,8905335438,8905335437,8905335436,8905335439}'),
 ('SRID=4326;LINESTRING(30.4533623 59.6849431,30.4533739 59.6849464,30.4534994 59.6849065,30.4534038 59.6848537,30.4533921 59.6848545,30.4533623 59.6849431)', 'way', 962714217, '{"natural": "scrub", "leaf_type": "broadleaved", "leaf_cycle": "deciduous"}', '{8905335444,8905335443,8905335442,8905335441,8905335440,8905335444}'),
 ('SRID=4326;LINESTRING(30.4532695 59.6849025,30.4532754 59.6848982,30.4532786 59.6848938,30.4532796 59.6848892,30.4532772 59.6848818,30.4533702 59.6848509,30.4533788 59.6848538,30.4533512 59.6849423,30.4533368 59.6849437,30.4532695 59.6849025)', 'way', 962714218, '{"natural": "scrub", "leaf_type": "broadleaved", "leaf_cycle": "deciduous"}', '{8905335454,8905335453,8905335452,8905335451,8905335450,8905335449,8905335448,8905335447,8905335446,8905335454}'),
 ('SRID=4326;LINESTRING(30.4529663 59.6848632,30.4530962 59.6848253,30.4530928 59.6848201,30.4529831 59.6848107,30.4529663 59.6848632)', 'way', 962714219, '{"natural": "scrub", "leaf_type": "broadleaved", "leaf_cycle": "deciduous"}', '{8905335458,8905335457,8905335456,8905335455,8905335458}'),
 ('SRID=4326;LINESTRING(30.4532195 59.6848732,30.4532263 59.6848712,30.4532379 59.6848698,30.4532504 59.6848704,30.4532619 59.6848729,30.4532706 59.684876,30.4533642 59.6848467,30.4533614 59.6848416,30.453158 59.6848262,30.4531503 59.6848308,30.4532195 59.6848732)', 'way', 962714220, '{"natural": "scrub", "leaf_type": "broadleaved", "leaf_cycle": "deciduous"}', '{8905335467,8905335466,8905335465,8905335464,8905335463,8905335462,8905335461,8905335445,8905335460,8905335459,8905335467}'),
 ('SRID=4326;LINESTRING(30.4532684 59.6848807,30.4533888 59.6848413)', 'way', 962714221, '{"highway": "footway", "surface": "fine_gravel"}', '{8904992654,1665582235}'),
 ('SRID=4326;LINESTRING(30.4531238 59.6848204,30.4532177 59.684877)', 'way', 962714222, '{"highway": "footway", "surface": "fine_gravel"}', '{1665582234,8904992660}'),
 ('SRID=4326;LINESTRING(30.4527677 59.6846399,30.4528579 59.6846477)', 'way', 962735606, '{"height": "2", "barrier": "fence", "ref:okn": "781610399040356", "historic": "yes", "man_made": "embankment"}', '{8905543613,1198356896}'),
 ('SRID=4326;LINESTRING(30.4525466 59.6846232,30.4525626 59.6846222,30.4525841 59.6846239,30.4527677 59.6846399)', 'way', 962735608, '{"height": "2", "barrier": "fence", "ref:okn": "781610399040356", "historic": "yes", "man_made": "embankment"}', '{8566824026,1198356935,8566824027,8905543613}'),
 ('SRID=4326;LINESTRING(30.4534851 59.684767,30.4534913 59.6847521,30.4534976 59.6847368)', 'way', 962735609, '{"highway": "steps"}', '{8905543614,12023732271,7927774425}'),
 ('SRID=4326;LINESTRING(30.4529562 59.6847243,30.4529615 59.6847082,30.4529628 59.6847041)', 'way', 962735610, '{"highway": "steps"}', '{8905543615,12023732270,3968068678}'),
 ('SRID=4326;LINESTRING(30.4526304 59.6847065,30.4525958 59.6847532)', 'way', 962735611, '{"highway": "footway", "surface": "fine_gravel"}', '{8905543616,8114975051}'),
 ('SRID=4326;LINESTRING(30.4528676 59.6847547,30.4526341 59.6847357,30.452631 59.6847454,30.4528645 59.6847644,30.4528676 59.6847547)', 'way', 962735612, '{"landuse": "grass"}', '{8905558220,8905558219,8905558218,8905558217,8905558220}'),
 ('SRID=4326;LINESTRING(30.4535589 59.6848104,30.4530176 59.6847681,30.4530149 59.6847769,30.4535559 59.6848195,30.4535589 59.6848104)', 'way', 962735613, '{"landuse": "grass"}', '{8905558224,8905558223,8905558222,8905558221,8905558224}'),
 ('SRID=4326;LINESTRING(30.4530182 59.6847465,30.4535658 59.6847921,30.4535618 59.6848022,30.4530143 59.6847573,30.4530182 59.6847465)', 'way', 962735614, '{"genus": "Cotoneaster", "taxon": "Cotoneaster lucidus", "height": "0.5", "barrier": "hedge", "landuse": "grass", "genus:ru": "Кизильник", "taxon:ru": "Кизильник блестящий", "leaf_type": "broadleaved", "leaf_cycle": "deciduous", "species:ru": "Кизильник блестящий", "species:wikidata": "Q162750"}', '{8905558227,8905558226,8906857476,8906857475,8905558227}'),
 ('SRID=4326;LINESTRING(30.4523152 59.6851448,30.4526116 59.6847664)', 'way', 962869359, '{"genus": "Prunus", "taxon": "Prunus virginiana", "height": "1.7", "barrier": "hedge", "genus:ru": "Черёмуха", "taxon:ru": "Черёмуха виргинская", "leaf_type": "broadleaved", "leaf_cycle": "deciduous"}', '{8906857452,8906857451}'),
 ('SRID=4326;LINESTRING(30.4526277 59.6846803,30.4526365 59.6846782,30.4526406 59.6846738,30.4526381 59.684669,30.4526302 59.6846662,30.4526205 59.6846666,30.4526137 59.6846701,30.4526128 59.684675,30.4526184 59.684679,30.4526277 59.6846803)', 'way', 962869361, '{"natural": "scrub", "leaf_type": "broadleaved", "leaf_cycle": "deciduous"}', '{8906857461,8906857453,8906857460,8906857459,8906857458,8906857457,8906857456,8906857455,8906857454,8906857461}'),
 ('SRID=4326;LINESTRING(30.4535863 59.6847456,30.4535811 59.6847595)', 'way', 962869365, '{"height": "2", "barrier": "fence", "ref:okn": "781610399040356", "historic": "yes", "man_made": "embankment"}', '{8906857470,8289295976}'),
 ('SRID=4326;MULTIPOLYGON(((30.4513 59.6845239,30.4513105 59.6845148,30.4513253 59.6844972,30.4513336 59.6844848,30.4513473 59.6844699,30.4513568 59.6844555,30.4513653 59.6844381,30.4513738 59.6844262,30.4513936 59.6844093,30.4514013 59.6843976,30.4514225 59.6843888,30.4514444 59.6843812,30.4514614 59.6843629,30.4514704 59.6843445,30.4514736 59.6843262,30.4514828 59.6842988,30.4514912 59.6842865,30.4514975 59.6842799,30.4515117 59.6842705,30.4515428 59.6842625,30.4516031 59.6842549,30.4518408 59.6843394,30.4519523 59.6843794,30.4520216 59.6844035,30.4520874 59.6844268,30.4521402 59.684444,30.4521943 59.6844606,30.452244 59.6844736,30.4522939 59.6844865,30.4523452 59.6844991,30.4524113 59.6845149,30.4524654 59.6845284,30.4525244 59.6845406,30.4525539 59.6845467,30.452566 59.6845558,30.452571 59.6845656,30.4525675 59.6845745,30.4525615 59.68459,30.4525618 59.6845988,30.4525613 59.6846073,30.4525568 59.6846156,30.4525466 59.6846232,30.4525331 59.6846279,30.4525251 59.684634,30.4525184 59.6846577,30.4524973 59.6846698,30.4526025 59.6847092,30.4522278 59.6851794,30.4521768 59.6852884,30.4521573 59.685297,30.4521207 59.6853099,30.4520859 59.6853167,30.4520483 59.6853214,30.4520121 59.6853235,30.4519679 59.6853228,30.4519209 59.685316,30.4518731 59.6853033,30.4518364 59.6852869,30.4518016 59.6852646,30.4517747 59.6852436,30.4517546 59.685224,30.4517399 59.685205,30.4517278 59.6851773,30.4517104 59.6851603,30.4516916 59.6851468,30.4516857 59.6851285,30.4516903 59.6851123,30.4517117 59.6851023,30.4517426 59.685094,30.4517784 59.6850892,30.4518103 59.6850908,30.4518403 59.6851005,30.4518731 59.6850949,30.4518771 59.6850809,30.4518692 59.685051,30.4518777 59.6850294,30.4519043 59.6850131,30.4519376 59.6850028,30.4519737 59.684999,30.4520079 59.6849997,30.4520477 59.685012,30.4520887 59.6850223,30.4521435 59.6850216,30.4521948 59.6850093,30.4522112 59.6849969,30.4522301 59.6849727,30.45222 59.6849586,30.4521979 59.6849496,30.4521524 59.6849328,30.452119 59.6849135,30.452105 59.6848849,30.4521099 59.684868,30.4520932 59.684849,30.4520658 59.6848372,30.4520255 59.6848223,30.4520099 59.6848104,30.4519866 59.6847939,30.4519651 59.6847718,30.4519517 59.6847501,30.4519518 59.6847258,30.4519545 59.6847041,30.4519786 59.6846635,30.4520121 59.6846479,30.452051 59.6846256,30.4520604 59.6846161,30.4520537 59.6846046,30.4520175 59.6845829,30.4519692 59.6845613,30.451933 59.684566,30.4519102 59.6845748,30.4518928 59.6845917,30.4518772 59.6846127,30.4518697 59.684638,30.4518561 59.6846587,30.4518347 59.6846794,30.4518136 59.6846859,30.451785 59.6846963,30.4517612 59.6847117,30.4517363 59.6847257,30.4517004 59.6847328,30.4516678 59.6847376,30.4516243 59.6847395,30.4515783 59.6847426,30.4515624 59.6847383,30.451536 59.6847319,30.4515265 59.6847207,30.4515128 59.6847092,30.4515012 59.6846991,30.4514963 59.6846932,30.4515039 59.6846846,30.4515091 59.6846707,30.4515006 59.6846638,30.4514837 59.6846584,30.4514488 59.6846536,30.4514298 59.6846424,30.4514235 59.6846339,30.451434 59.6846216,30.451452 59.6846104,30.4514721 59.684604,30.4514816 59.6845934,30.4514827 59.6845827,30.4514763 59.6845715,30.4514427 59.6845604,30.4514004 59.6845719,30.4513792 59.6845708,30.451356 59.684566,30.4513317 59.6845601,30.4513137 59.6845489,30.4513042 59.6845393,30.4513 59.6845239)))', 'relation', 12444790, '{"natural": "wood", "leaf_type": "mixed", "leaf_cycle": "mixed"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4523568 59.6851898,30.4523702 59.6851856,30.4524483 59.6851915,30.452456 59.6851977,30.4524419 59.6852441,30.4524248 59.6852328,30.4524088 59.6852218,30.4523826 59.6852055,30.4523568 59.6851898)))', 'way', 961717571, '{"landuse": "flowerbed"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4524524 59.6852459,30.4524673 59.6851987,30.4524824 59.6851946,30.4525509 59.6852001,30.4525595 59.685207,30.4525499 59.6852458,30.4525356 59.685252,30.4524524 59.6852459)))', 'way', 961717572, '{"landuse": "flowerbed"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4523303 59.6851757,30.452333 59.6851663,30.4527521 59.6851991,30.4527487 59.6852082,30.4523303 59.6851757)))', 'way', 961717577, '{"landuse": "flowerbed"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4528543 59.6852169,30.452857 59.6852074,30.4532097 59.6852351,30.4532064 59.6852443,30.4528543 59.6852169)))', 'way', 961717578, '{"landuse": "flowerbed"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4531109 59.6852622,30.4531259 59.6852456,30.4532017 59.6852514,30.4531538 59.6852696,30.4531388 59.6852648,30.4531262 59.6852629,30.4531109 59.6852622)))', 'way', 961717579, '{"landuse": "flowerbed"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4530143 59.6852802,30.453028 59.6852429,30.4530414 59.6852392,30.4530554 59.6852658,30.453041 59.6852693,30.4530288 59.6852733,30.4530143 59.6852802)))', 'way', 961717580, '{"landuse": "flowerbed"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4530501 59.6852392,30.4531172 59.6852446,30.4531031 59.6852618,30.4530921 59.6852616,30.4530782 59.6852621,30.4530632 59.6852641,30.4530501 59.6852392)))', 'way', 961717581, '{"landuse": "flowerbed"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4530373 59.6853168,30.4530377 59.6853132,30.4530389 59.6853097,30.4530408 59.6853062,30.4530436 59.6853029,30.453047 59.6852998,30.4530511 59.6852969,30.4530559 59.6852942,30.4530612 59.6852918,30.4530685 59.6852893,30.4530765 59.6852873,30.4530849 59.6852859,30.4530936 59.6852852,30.4531024 59.685285,30.4531113 59.6852855,30.4531198 59.6852866,30.453128 59.6852882,30.4531357 59.6852905,30.4531138 59.6852988,30.4530897 59.6853096,30.4530682 59.6853211,30.4530456 59.6853334,30.4530424 59.6853304,30.4530402 59.6853274,30.4530387 59.6853245,30.4530377 59.6853204,30.4530373 59.6853168)))', 'relation', 12935642, '{"height": "6", "roof:shape": "flat", "roof:colour": "grey", "building:part": "yes", "building:colour": "#FFE19C"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4530106 59.6853114,30.4530161 59.6853019,30.4530244 59.6852922,30.4530375 59.685285,30.4530534 59.685278,30.4530732 59.685274,30.4530931 59.6852723,30.4531124 59.685272,30.4531329 59.6852751,30.4531443 59.685278,30.453156 59.6852825,30.4531357 59.6852905,30.453128 59.6852882,30.4531198 59.6852866,30.4531113 59.6852855,30.4531024 59.685285,30.4530936 59.6852852,30.4530849 59.6852859,30.4530765 59.6852873,30.4530685 59.6852893,30.4530612 59.6852918,30.4530559 59.6852942,30.4530511 59.6852969,30.453047 59.6852998,30.4530436 59.6853029,30.4530408 59.6853062,30.4530389 59.6853097,30.4530377 59.6853132,30.4530373 59.6853168,30.4530377 59.6853204,30.4530111 59.6853217,30.4530106 59.6853114)))', 'relation', 12922491, '{"natural": "scrub", "leaf_type": "broadleaved", "leaf_cycle": "deciduous"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4529136 59.685403,30.4529349 59.6853856,30.4529284 59.6853815,30.4529266 59.6853774,30.4529297 59.6853727,30.452955 59.6853567,30.4529621 59.6853543,30.4529707 59.6853538,30.4529809 59.6853554,30.4530053 59.6853403,30.4530217 59.6853466,30.4530012 59.685359,30.4529724 59.685378,30.4529542 59.6853912,30.4529312 59.685409,30.4529136 59.685403)))', 'relation', 12935641, '{"height": "1", "roof:shape": "flat", "roof:colour": "grey", "building:part": "yes", "building:colour": "#E4C78F"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4527618 59.6854305,30.4527687 59.6854078,30.4527852 59.6854026,30.4528654 59.6854091,30.4528755 59.6854172,30.4528681 59.6854402,30.4528506 59.685445,30.4527747 59.6854387,30.4527618 59.6854305)))', 'way', 961717594, '{"landuse": "flowerbed"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4524557 59.6852538,30.4525351 59.6852597,30.4525442 59.6852666,30.4525328 59.6853069,30.4525201 59.6853123,30.4524969 59.6852906,30.4524775 59.6852724,30.4524557 59.6852538)))', 'way', 961717595, '{"landuse": "flowerbed"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4523226 59.6851969,30.4523418 59.6851889,30.4523598 59.6851989,30.4523808 59.6852109,30.4524103 59.6852297,30.4524317 59.6852443,30.4524536 59.68526,30.4524825 59.6852834,30.4524981 59.6852989,30.4525179 59.6853192,30.452532 59.6853359,30.4525456 59.6853529,30.4525561 59.6853703,30.4525656 59.6853881,30.4525739 59.6854062,30.4525791 59.6854198,30.4525811 59.6854262,30.452574 59.6854304,30.4525626 59.6854314,30.4525546 59.6854286,30.4525509 59.6854228,30.4525457 59.6854094,30.4525376 59.6853916,30.4525283 59.6853742,30.4525181 59.6853572,30.4525048 59.6853406,30.452491 59.6853243,30.4524715 59.6853042,30.4524562 59.6852892,30.452428 59.6852663,30.4524066 59.6852509,30.4523855 59.6852365,30.4523561 59.6852179,30.4523226 59.6851969)))', 'way', 961717596, '{"landuse": "grass"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4522795 59.6852157,30.4522803 59.6851945,30.4523081 59.6852118,30.4523362 59.6852293,30.4523649 59.6852475,30.4523853 59.6852614,30.4524056 59.685276,30.4524322 59.6852976,30.4524465 59.6853116,30.4524653 59.6853309,30.4524785 59.6853465,30.4524909 59.685362,30.4525002 59.6853776,30.4525091 59.6853943,30.4525171 59.6854097,30.4525231 59.6854242,30.4525257 59.6854303,30.4525224 59.6854348,30.4525097 59.6854362,30.452501 59.6854325,30.4524982 59.6854272,30.4524918 59.6854125,30.4524839 59.6853973,30.4524751 59.6853808,30.452466 59.6853657,30.452454 59.6853507,30.4524411 59.6853354,30.4524225 59.6853163,30.4524087 59.6853027,30.4523827 59.6852816,30.4523628 59.6852673,30.4523427 59.6852536,30.4523143 59.6852356,30.4522795 59.6852157)))', 'way', 961717597, '{"landuse": "grass"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4525975 59.6854176,30.4526042 59.6853942,30.4526196 59.6853891,30.4527003 59.6853955,30.4527112 59.6854034,30.4527032 59.6854269,30.4526842 59.6854313,30.4526076 59.685425,30.4525975 59.6854176)))', 'way', 961717598, '{"landuse": "flowerbed"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4527849 59.685488,30.4527911 59.6854671,30.4528702 59.6854731,30.4528639 59.685494,30.4527849 59.685488)))', 'way', 961717599, '{"genus": "Syrínga", "taxon": "Syringa meyeri", "natural": "scrub", "genus:ru": "Сирень", "taxon:ru": "Сирень Мейера", "leaf_type": "broadleaved", "leaf_cycle": "deciduous"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4525642 59.6854713,30.4525705 59.6854504,30.4526495 59.6854564,30.4526433 59.6854773,30.4525642 59.6854713)))', 'way', 961717600, '{"genus": "Syrínga", "taxon": "Syringa meyeri", "natural": "scrub", "genus:ru": "Сирень", "taxon:ru": "Сирень Мейера", "leaf_type": "broadleaved", "leaf_cycle": "deciduous"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4529138 59.6853368,30.4529263 59.6852951,30.4529427 59.6852903,30.4529866 59.6852936,30.4529963 59.6853005,30.4529853 59.6853413,30.4529678 59.6853472,30.4529235 59.6853445,30.4529138 59.6853368)))', 'way', 961717602, '{"landuse": "flowerbed"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.452933 59.6852753,30.4529444 59.6852374,30.4529582 59.685233,30.4530088 59.6852371,30.4530171 59.6852433,30.453002 59.6852821,30.4529886 59.6852873,30.4529441 59.6852838,30.452933 59.6852753)))', 'way', 961717603, '{"landuse": "flowerbed"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4525595 59.6852465,30.4525709 59.685208,30.4525847 59.6852036,30.4526353 59.6852076,30.452645 59.6852146,30.4526333 59.6852538,30.4526207 59.6852585,30.4525692 59.6852544,30.4525595 59.6852465)))', 'way', 961717604, '{"landuse": "flowerbed"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.452817 59.6852667,30.452831 59.6852267,30.4528493 59.6852281,30.452851 59.685224,30.4529216 59.6852291,30.4529319 59.6852358,30.45292 59.6852751,30.4529066 59.6852809,30.4528288 59.6852748,30.452817 59.6852667)))', 'way', 961717605, '{"landuse": "flowerbed"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4527946 59.6853272,30.4528087 59.6852864,30.4528247 59.6852816,30.4529042 59.6852874,30.4529154 59.6852941,30.4529031 59.6853359,30.4528878 59.6853416,30.4528053 59.6853349,30.4527946 59.6853272)))', 'way', 961717606, '{"landuse": "flowerbed"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4527745 59.6853889,30.4527899 59.6853454,30.4528052 59.6853419,30.4528845 59.6853477,30.4528953 59.6853552,30.4528839 59.6853982,30.4528677 59.6854032,30.4527865 59.6853969,30.4527745 59.6853889)))', 'way', 961717607, '{"landuse": "flowerbed"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4533349 59.6850974,30.4533424 59.6850906,30.4534424 59.6850974,30.453427 59.6851532,30.4534116 59.6851536,30.4533349 59.6850974)))', 'way', 962062985, '{"natural": "scrub", "leaf_type": "broadleaved", "leaf_cycle": "deciduous"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4534909 59.6851715,30.4535 59.6851418,30.4535229 59.6851437,30.4535137 59.6851734,30.4534909 59.6851715)))', 'relation', 12925809, '{"crop": "grape", "genus": "Vitis", "taxon": "Vitis amurensis", "landuse": "vineyard", "genus:ru": "Виноград", "taxon:ru": "Виноград амурский"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4532761 59.6852013,30.4533083 59.6851038,30.4533211 59.6851024,30.4533941 59.6851559,30.453378 59.6851586,30.4533606 59.6851647,30.4533458 59.6851715,30.4533338 59.6851796,30.4533257 59.6851898,30.453319 59.6851999,30.4533137 59.6852128,30.4532761 59.6852013)))', 'way', 962062990, '{"natural": "scrub", "leaf_type": "broadleaved", "leaf_cycle": "deciduous"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4530768 59.6850789,30.4530825 59.6850727,30.45327 59.6850856,30.4532721 59.6850914,30.4531813 59.685123,30.4531731 59.6851201,30.4531599 59.6851179,30.4531475 59.6851179,30.4531357 59.6851196,30.4530768 59.6850789)))', 'way', 962062993, '{"natural": "scrub", "leaf_type": "broadleaved", "leaf_cycle": "deciduous"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4530252 59.6851728,30.4530493 59.6850863,30.4530634 59.6850845,30.4531219 59.6851249,30.4531169 59.6851285,30.4531133 59.6851328,30.4531117 59.6851378,30.4531125 59.6851429,30.4531159 59.685148,30.4530357 59.6851757,30.4530252 59.6851728)))', 'way', 962062994, '{"natural": "scrub", "leaf_type": "broadleaved", "leaf_cycle": "deciduous"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4531381 59.685138,30.4531404 59.6851346,30.4531455 59.6851322,30.4531523 59.6851313,30.4531591 59.685132,30.4531645 59.6851343,30.4531672 59.6851376,30.4531665 59.6851411,30.4531627 59.6851441,30.4531566 59.6851458,30.4531496 59.6851459,30.4531433 59.6851444,30.4531391 59.6851415,30.4531381 59.685138)))', 'way', 962062995, '{"landuse": "grass"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4531836 59.6851532,30.45319 59.6851488,30.4531936 59.6851444,30.453195 59.6851401,30.4531946 59.6851353,30.4531914 59.68513,30.4532804 59.6850981,30.4532923 59.6851023,30.4532587 59.6851977,30.45325 59.6851972,30.4531836 59.6851532)))', 'way', 962062996, '{"natural": "scrub", "leaf_type": "broadleaved", "leaf_cycle": "deciduous"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4530454 59.6851813,30.4531256 59.6851544,30.4531347 59.6851575,30.4531466 59.6851595,30.4531581 59.6851596,30.4531699 59.6851581,30.4532258 59.6851962,30.4532198 59.6852006,30.4530501 59.6851877,30.4530454 59.6851813)))', 'way', 962062997, '{"natural": "scrub", "leaf_type": "broadleaved", "leaf_cycle": "deciduous"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4528382 59.6851861,30.4528402 59.6851794,30.452846 59.6851798,30.4528466 59.6851777,30.4532188 59.6852056,30.4532162 59.6852145,30.4528382 59.6851861)))', 'way', 962062998, '{"landuse": "grass"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4528577 59.6851769,30.4529093 59.6850046,30.4529281 59.685006,30.4529375 59.6849752,30.4529207 59.6849738,30.4529724 59.6848063,30.4535349 59.6848517,30.4534357 59.6851637,30.4534213 59.6851644,30.4534075 59.6851668,30.4533894 59.6851708,30.4533747 59.6851759,30.4533579 59.6851844,30.4533479 59.6851932,30.4533405 59.6852038,30.4533345 59.6852155,30.4533291 59.6852257,30.4532627 59.6852077,30.4528577 59.6851769)))', 'way', 962382760, '{"ref": "6", "name": "Ботанический сад", "leisure": "garden", "name:en": "The Botanical Garden", "wikidata": "Q118122045", "garden:type": "botanical"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4533751 59.6849668,30.453381 59.6849616,30.4534833 59.6849698,30.4534679 59.6850219,30.4533751 59.6849668)))', 'way', 962382761, '{"natural": "scrub", "leaf_type": "broadleaved", "leaf_cycle": "deciduous"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4529338 59.6849691,30.4529452 59.6849315,30.4530566 59.6849397,30.4530583 59.6849454,30.4529465 59.6849826,30.4529492 59.6849698,30.4529338 59.6849691)))', 'way', 962382762, '{"natural": "scrub", "leaf_type": "broadleaved", "leaf_cycle": "deciduous"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4529465 59.6849918,30.4530662 59.6849507,30.4530757 59.684955,30.4530456 59.6850508,30.4530344 59.685052,30.4529465 59.6849918)))', 'way', 962382763, '{"natural": "scrub", "leaf_type": "broadleaved", "leaf_cycle": "deciduous"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4529083 59.6850544,30.4529184 59.6850114,30.4529378 59.6850121,30.4529398 59.6850009,30.4530221 59.685056,30.4530153 59.6850613,30.4529083 59.6850544)))', 'way', 962382764, '{"natural": "scrub", "leaf_type": "broadleaved", "leaf_cycle": "deciduous"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4528875 59.6851184,30.4529043 59.6850625,30.4530125 59.6850679,30.4530138 59.6850731,30.4528875 59.6851184)))', 'way', 962382765, '{"natural": "scrub", "leaf_type": "broadleaved", "leaf_cycle": "deciduous"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4528698 59.6851739,30.4528812 59.685135,30.4529823 59.6851789,30.4529779 59.6851826,30.4528698 59.6851739)))', 'way', 962382766, '{"landuse": "grass"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4528885 59.6851275,30.4530206 59.6850798,30.4530311 59.6850841,30.4530072 59.6851719,30.4529896 59.6851748,30.4528885 59.6851275)))', 'way', 962382767, '{"natural": "scrub", "leaf_type": "broadleaved", "leaf_cycle": "deciduous"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4533227 59.6850682,30.4533546 59.6849733,30.4533655 59.6849715,30.4534612 59.68503,30.4533332 59.6850719,30.4533227 59.6850682)))', 'way', 962382768, '{"natural": "scrub", "leaf_type": "broadleaved", "leaf_cycle": "deciduous"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4533411 59.685078,30.4534619 59.6850382,30.4534444 59.6850899,30.4533437 59.685083,30.4533411 59.685078)))', 'way', 962382769, '{"natural": "scrub", "leaf_type": "broadleaved", "leaf_cycle": "deciduous"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4532321 59.6850233,30.4532368 59.6850199,30.4532392 59.6850173,30.4533204 59.6850217,30.4533057 59.6850665,30.4532939 59.6850677,30.4532321 59.6850233)))', 'way', 962382770, '{"genus": "Rosa", "taxon": "Rosa spinosissima", "natural": "scrub", "genus:ru": "Роза", "taxon:ru": "Роза колючейшая", "leaf_type": "broadleaved", "leaf_cycle": "deciduous", "source:taxon": "board"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4532374 59.6850005,30.4533289 59.6849694,30.4533388 59.6849721,30.4533251 59.6850146,30.4532419 59.6850113,30.4532411 59.6850057,30.4532374 59.6850005)))', 'way', 962382771, '{"genus": "Rosa", "taxon": "Rosa spinosissima", "natural": "scrub", "genus:ru": "Роза", "taxon:ru": "Роза колючейшая", "leaf_type": "broadleaved", "leaf_cycle": "deciduous", "source:taxon": "board"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4532116 59.6849902,30.4532258 59.6849527,30.4533191 59.6849588,30.4533219 59.6849634,30.4532298 59.6849953,30.4532207 59.684992,30.4532116 59.6849902)))', 'way', 962382772, '{"genus": "Rosa", "taxon": "Rosa spinosissima", "natural": "scrub", "genus:ru": "Роза", "taxon:ru": "Роза колючейшая", "leaf_type": "broadleaved", "leaf_cycle": "deciduous", "source:taxon": "board"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.453114 59.6849505,30.4531198 59.684945,30.4532124 59.6849517,30.4532004 59.6849896,30.4531904 59.6849904,30.45318 59.6849928,30.453114 59.6849505)))', 'way', 962382773, '{"genus": "Rosa", "taxon": "Rosa spinosissima", "natural": "scrub", "genus:ru": "Роза", "taxon:ru": "Роза колючейшая", "leaf_type": "broadleaved", "leaf_cycle": "deciduous", "source:taxon": "board"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4530763 59.6850024,30.453091 59.6849565,30.4531032 59.6849548,30.4531695 59.6849976,30.4531647 59.6850018,30.4531619 59.6850065,30.4530763 59.6850024)))', 'way', 962382774, '{"genus": "Rosa", "taxon": "Rosa spinosissima", "natural": "scrub", "genus:ru": "Роза", "taxon:ru": "Роза колючейшая", "leaf_type": "broadleaved", "leaf_cycle": "deciduous", "source:taxon": "board"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4530603 59.6850515,30.4530743 59.6850085,30.4531615 59.6850116,30.4531626 59.685015,30.4531656 59.685019,30.4530716 59.6850547,30.4530603 59.6850515)))', 'way', 962382775, '{"genus": "Rosa", "taxon": "Rosa spinosissima", "natural": "scrub", "genus:ru": "Роза", "taxon:ru": "Роза колючейшая", "leaf_type": "broadleaved", "leaf_cycle": "deciduous", "source:taxon": "board"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4530791 59.6850599,30.4531749 59.6850252,30.4531799 59.6850271,30.4531863 59.6850287,30.4531735 59.6850722,30.453083 59.685065,30.4530791 59.6850599)))', 'way', 962382776, '{"genus": "Rosa", "taxon": "Rosa spinosissima", "natural": "scrub", "genus:ru": "Роза", "taxon:ru": "Роза колючейшая", "leaf_type": "broadleaved", "leaf_cycle": "deciduous", "source:taxon": "board"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4531903 59.6850727,30.453201 59.6850303,30.453211 59.6850297,30.4532223 59.6850274,30.4532816 59.6850715,30.4532727 59.6850781,30.4531903 59.6850727)))', 'way', 962382777, '{"genus": "Rosa", "taxon": "Rosa spinosissima", "natural": "scrub", "genus:ru": "Роза", "taxon:ru": "Роза колючейшая", "leaf_type": "broadleaved", "leaf_cycle": "deciduous", "source:taxon": "board"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4531253 59.6850083,30.4531279 59.6850008,30.4531334 59.6849938,30.4531415 59.6849874,30.4531519 59.6849819,30.4531642 59.6849776,30.4531779 59.6849745,30.4531926 59.6849729,30.4532076 59.6849728,30.4532224 59.6849741,30.4532363 59.6849768,30.453249 59.6849809,30.4532598 59.6849862,30.4532684 59.6849924,30.4532744 59.6849993,30.4532776 59.6850067,30.4532779 59.6850143,30.4532753 59.6850217,30.4532699 59.6850288,30.4532618 59.6850352,30.4532514 59.6850406,30.4532391 59.685045,30.4532253 59.685048,30.4532107 59.6850496,30.4531957 59.6850498,30.4531809 59.6850485,30.4531669 59.6850457,30.4531543 59.6850416,30.4531434 59.6850364,30.4531349 59.6850302,30.4531288 59.6850232,30.4531256 59.6850158,30.4531253 59.6850083)))', 'way', 962382781, '{"genus": "Tilia", "height": "6", "natural": "tree_row", "genus:ru": "Липа", "leaf_type": "broadleaved", "leaf_cycle": "deciduous"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.453207 59.6848903,30.4532078 59.6848854,30.4532114 59.6848808,30.4532177 59.684877,30.4532251 59.6848743,30.4532339 59.6848728,30.4532432 59.6848726,30.4532523 59.6848737,30.4532603 59.6848761,30.4532684 59.6848807,30.4532708 59.6848832,30.4532728 59.6848874,30.4532726 59.6848917,30.4532702 59.6848959,30.4532659 59.6848995,30.4532598 59.6849025,30.4532507 59.684905,30.4532406 59.6849059,30.4532304 59.6849052,30.4532212 59.6849029,30.453213 59.6848988,30.453209 59.6848951,30.453207 59.6848903)))', 'way', 962678725, '{"highway": "footway", "surface": "fine_gravel"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4532247 59.6848893,30.453227 59.684886,30.4532321 59.6848835,30.4532389 59.6848826,30.4532457 59.6848833,30.4532511 59.6848856,30.4532538 59.6848889,30.4532531 59.6848924,30.4532493 59.6848954,30.4532432 59.6848971,30.4532362 59.6848972,30.4532299 59.6848957,30.4532257 59.6848928,30.4532247 59.6848893)))', 'way', 962678726, '{"landuse": "grass"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4530998 59.6849248,30.4531253 59.6848349,30.4531384 59.6848341,30.4532098 59.6848776,30.4532043 59.6848829,30.4532023 59.6848877,30.4532029 59.6848932,30.4532056 59.6848974,30.4531105 59.684928,30.4530998 59.6849248)))', 'way', 962678727, '{"natural": "scrub", "leaf_type": "broadleaved", "leaf_cycle": "deciduous"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4529683 59.6848711,30.4531034 59.6848301,30.4531127 59.6848333,30.4530868 59.6849239,30.4530724 59.6849262,30.4529683 59.6848711)))', 'way', 962678728, '{"natural": "scrub", "leaf_type": "broadleaved", "leaf_cycle": "deciduous"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4529482 59.6849246,30.452961 59.6848772,30.4530633 59.6849302,30.4530589 59.6849341,30.4529482 59.6849246)))', 'way', 962678729, '{"natural": "scrub", "leaf_type": "broadleaved", "leaf_cycle": "deciduous"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4531185 59.6849335,30.4532133 59.6849034,30.4532243 59.684907,30.4532339 59.6849085,30.4532455 59.6849087,30.4532581 59.6849071,30.4533269 59.6849477,30.4533222 59.6849516,30.4531212 59.684939,30.4531185 59.6849335)))', 'way', 962678730, '{"natural": "scrub", "leaf_type": "broadleaved", "leaf_cycle": "deciduous"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.452977 59.6848046,30.4529797 59.6847958,30.453536 59.6848401,30.4535329 59.6848493,30.452977 59.6848046)))', 'way', 962714214, '{"landuse": "flowerbed"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4534135 59.68485,30.4534175 59.684847,30.4535189 59.6848554,30.4535068 59.684899,30.4534135 59.68485)))', 'way', 962714215, '{"natural": "scrub", "leaf_type": "broadleaved", "leaf_cycle": "deciduous"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4533809 59.6849511,30.4535014 59.6849122,30.4534847 59.684964,30.4533819 59.6849565,30.4533809 59.6849511)))', 'way', 962714216, '{"natural": "scrub", "leaf_type": "broadleaved", "leaf_cycle": "deciduous"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4533623 59.6849431,30.4533921 59.6848545,30.4534038 59.6848537,30.4534994 59.6849065,30.4533739 59.6849464,30.4533623 59.6849431)))', 'way', 962714217, '{"natural": "scrub", "leaf_type": "broadleaved", "leaf_cycle": "deciduous"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4532695 59.6849025,30.4532754 59.6848982,30.4532786 59.6848938,30.4532796 59.6848892,30.4532772 59.6848818,30.4533702 59.6848509,30.4533788 59.6848538,30.4533512 59.6849423,30.4533368 59.6849437,30.4532695 59.6849025)))', 'way', 962714218, '{"natural": "scrub", "leaf_type": "broadleaved", "leaf_cycle": "deciduous"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4529663 59.6848632,30.4529831 59.6848107,30.4530928 59.6848201,30.4530962 59.6848253,30.4529663 59.6848632)))', 'way', 962714219, '{"natural": "scrub", "leaf_type": "broadleaved", "leaf_cycle": "deciduous"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4531503 59.6848308,30.453158 59.6848262,30.4533614 59.6848416,30.4533642 59.6848467,30.4532706 59.684876,30.4532619 59.6848729,30.4532504 59.6848704,30.4532379 59.6848698,30.4532263 59.6848712,30.4532195 59.6848732,30.4531503 59.6848308)))', 'way', 962714220, '{"natural": "scrub", "leaf_type": "broadleaved", "leaf_cycle": "deciduous"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.452631 59.6847454,30.4526341 59.6847357,30.4528676 59.6847547,30.4528645 59.6847644,30.452631 59.6847454)))', 'way', 962735612, '{"landuse": "grass"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4530149 59.6847769,30.4530176 59.6847681,30.4535589 59.6848104,30.4535559 59.6848195,30.4530149 59.6847769)))', 'way', 962735613, '{"landuse": "grass"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4530143 59.6847573,30.4530182 59.6847465,30.4535658 59.6847921,30.4535618 59.6848022,30.4530143 59.6847573)))', 'way', 962735614, '{"genus": "Cotoneaster", "taxon": "Cotoneaster lucidus", "height": "0.5", "barrier": "hedge", "landuse": "grass", "genus:ru": "Кизильник", "taxon:ru": "Кизильник блестящий", "leaf_type": "broadleaved", "leaf_cycle": "deciduous", "species:ru": "Кизильник блестящий", "species:wikidata": "Q162750"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4523152 59.6851448,30.4526116 59.6847664,30.4528877 59.684789,30.4528309 59.6849691,30.4528148 59.6849678,30.4528061 59.6849952,30.4528221 59.6849965,30.45277 59.6851675,30.4527658 59.68518,30.4523152 59.6851448)))', 'relation', 12933782, '{"ref": "5", "name": "Кенконс", "genus": "Tilia", "name:en": "The Quincunx", "natural": "wood", "genus:ru": "Липа", "leaf_type": "broadleaved", "leaf_cycle": "deciduous"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4526128 59.684675,30.4526137 59.6846701,30.4526205 59.6846666,30.4526302 59.6846662,30.4526381 59.684669,30.4526406 59.6846738,30.4526365 59.6846782,30.4526277 59.6846803,30.4526184 59.684679,30.4526128 59.684675)))', 'way', 962869361, '{"natural": "scrub", "leaf_type": "broadleaved", "leaf_cycle": "deciduous"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4526042 59.6846709,30.4526082 59.6846655,30.452617 59.6846635,30.4528469 59.6846817,30.452843 59.684694,30.4528376 59.6847122,30.4526498 59.6846973,30.4526123 59.6846817,30.4526042 59.6846709)))', 'relation', 12933783, '{"landuse": "grass"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4530629 59.6847308,30.4530706 59.6847131,30.4530752 59.684699,30.4535863 59.6847456,30.4535811 59.6847595,30.4535752 59.6847748,30.4530629 59.6847308)))', 'relation', 12933784, '{"landuse": "grass"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4533752 59.6852006,30.4533796 59.6851915,30.4533891 59.6851835,30.4534028 59.6851772,30.4534196 59.6851732,30.453436 59.6851719,30.4534524 59.6851728,30.4534678 59.6851758,30.4534811 59.6851808,30.4534914 59.6851874,30.4534979 59.6851951,30.4534977 59.6852035,30.4534967 59.6852111,30.453492 59.6852191,30.4534813 59.6852261,30.4534692 59.6852309,30.4534524 59.6852342,30.453435 59.6852355,30.4534193 59.6852337,30.4534045 59.6852307,30.4533914 59.6852248,30.4533831 59.6852182,30.4533763 59.68521,30.4533752 59.6852006)))', 'relation', 12935640, '{"height": "5.5", "roof:shape": "pyramidal", "roof:colour": "#DADDE2", "roof:height": "0.5", "building:part": "yes", "building:colour": "#FFE19C"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4526773 59.6854805,30.4526841 59.6854592,30.4527224 59.6854618,30.4527565 59.685464,30.4527511 59.6854859,30.4526773 59.6854805)))', 'relation', 12987950, '{"height": "1", "roof:shape": "skillion", "roof:colour": "grey", "roof:height": "1", "building:part": "yes", "roof:direction": "170", "building:colour": "#E4C78F", "roof:orientation": "along"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4525787 59.6854944,30.4525812 59.6854845,30.4526564 59.6854895,30.4526646 59.6854579,30.4526841 59.6854592,30.4526773 59.6854805,30.4527511 59.6854859,30.4527565 59.685464,30.452777 59.6854654,30.4527686 59.6854977,30.4528746 59.6855048,30.4528709 59.6855164,30.4527091 59.6855042,30.4525787 59.6854944)))', 'relation', 12935639, '{"height": "1", "roof:shape": "flat", "roof:colour": "grey", "building:part": "yes", "building:colour": "#E4C78F"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4444865 59.6867017,30.4444952 59.6866905,30.4445375 59.6866638,30.444687 59.6865741,30.4448347 59.6864855,30.445096 59.6863422,30.4452308 59.6862691,30.4453607 59.6861984,30.4456533 59.6860464,30.4458048 59.6859713,30.4459528 59.6859038,30.4463406 59.6857168,30.446723 59.6855342,30.447509 59.6851751,30.4477152 59.6850805,30.4478346 59.6850209,30.447946 59.6849604,30.4480438 59.684899,30.4481859 59.6848002,30.4483241 59.6846939,30.4484287 59.68461,30.4484662 59.6845826,30.4485046 59.6845589,30.4486084 59.6844949,30.4486791 59.6844562,30.4488525 59.6843737,30.4490602 59.6842836,30.449236 59.6842106,30.4493951 59.6841491,30.4494519 59.6841382,30.4495136 59.6841273,30.4496558 59.6841097,30.4498549 59.6840882,30.4498949 59.6840845,30.450264 59.6840506,30.4503834 59.6840449,30.4504672 59.684042,30.4505671 59.6840395,30.4506691 59.6840402,30.4507093 59.6840439,30.4507582 59.6840576,30.4508011 59.6840678,30.4508456 59.6840745,30.4510132 59.6840377,30.4511147 59.6840765,30.4511813 59.6841019,30.4512523 59.684129,30.4513511 59.6841667,30.4513385 59.6842533,30.4516531 59.6843525,30.4522364 59.6845601,30.4525041 59.6846527,30.4525184 59.6846577,30.4524973 59.6846698,30.4526025 59.6847092,30.4522278 59.6851794,30.4522474 59.6851858,30.4522167 59.6853009,30.4522119 59.6853269,30.4521905 59.6853763,30.4521596 59.6854203,30.4521293 59.6854701,30.4520946 59.6855262,30.4520624 59.6855804,30.4520524 59.6856064,30.452047 59.6856386,30.452047 59.6856666,30.4520551 59.685713,30.4520778 59.685798,30.4520997 59.6858613,30.4521127 59.6859046,30.4521047 59.6859432,30.4520825 59.6859825,30.4520478 59.686026,30.4520492 59.6860479,30.4520658 59.6860755,30.4520819 59.6860924,30.4521387 59.6861383,30.4521581 59.6861556,30.4521822 59.6861782,30.45222 59.6862149,30.4522535 59.6862461,30.4522676 59.6862668,30.4522828 59.6862897,30.4522911 59.6863104,30.4522992 59.6863312,30.4523018 59.6863618,30.4522989 59.6863961,30.4522911 59.6864255,30.452286 59.6864496,30.4522787 59.6864747,30.4522743 59.6864925,30.452274 59.6865148,30.4522776 59.6865312,30.4522888 59.6865538,30.4523045 59.686573,30.4523226 59.6865862,30.4523413 59.6865954,30.4523836 59.686613,30.4524214 59.6866244,30.4524614 59.686634,30.4524912 59.6866392,30.4525264 59.6866438,30.4525641 59.6866457,30.4526585 59.6866455,30.4527524 59.6866414,30.4528825 59.6866353,30.4530173 59.6866255,30.4531259 59.6866181,30.4531936 59.6866133,30.453271 59.6866114,30.4533083 59.686614,30.4534028 59.6866228,30.4535229 59.6866363,30.4536201 59.6866455,30.453691 59.6866508,30.4536976 59.6866508,30.4539823 59.6866673,30.4539778 59.6866919,30.4544217 59.6867427,30.4544227 59.6867377,30.4544646 59.686742,30.4544638 59.6867472,30.4545508 59.6867576,30.4545534 59.6867525,30.4545963 59.6867573,30.4546214 59.6867604,30.4546788 59.6867553,30.4548168 59.686752,30.4551163 59.6867835,30.4552388 59.6868093,30.4553945 59.6868602,30.455491 59.6869022,30.4555769 59.68694,30.4556466 59.6869672,30.4557807 59.6870023,30.4558987 59.6870186,30.4559816 59.68702,30.4560875 59.6870601,30.4561508 59.6871091,30.4561831 59.6871675,30.456183 59.687235,30.4561616 59.6872894,30.4561159 59.6873352,30.4560824 59.6873697,30.4560436 59.6874139,30.4560113 59.687453,30.4559765 59.6875127,30.4559804 59.6875356,30.4559953 59.6875601,30.4560395 59.6875816,30.4560838 59.6875938,30.4561467 59.6876019,30.4561991 59.6876021,30.4563573 59.6875979,30.4565289 59.6875961,30.4566782 59.6875933,30.4567611 59.687592,30.4568899 59.687586,30.4570005 59.6875828,30.4570995 59.6875755,30.4572099 59.6875697,30.4573214 59.6875781,30.4574243 59.6875895,30.4575564 59.6876086,30.4576489 59.6876236,30.4577906 59.6876357,30.4578929 59.687656,30.4579737 59.6876911,30.4580413 59.6877282,30.4581225 59.6877678,30.4581817 59.6878027,30.4582341 59.6878291,30.4583152 59.6878863,30.4583478 59.6879193,30.4583877 59.6879673,30.458411 59.6880122,30.4584387 59.6880452,30.4584657 59.6880811,30.4585427 59.6881373,30.4585748 59.6881735,30.4586375 59.6882236,30.4586938 59.6882576,30.4587833 59.6883125,30.45884 59.6883434,30.4588959 59.6883741,30.4589723 59.6884163,30.4590175 59.6884495,30.4590717 59.6884887,30.4591366 59.6885238,30.4591908 59.6885653,30.4592104 59.6886013,30.4592312 59.6886474,30.4592494 59.6886943,30.4592859 59.6887303,30.4593172 59.688773,30.4593556 59.6888131,30.459429 59.6888677,30.459467 59.6889042,30.4594979 59.688929,30.4595172 59.6889694,30.4595266 59.6890044,30.4595285 59.689042,30.4595248 59.6890919,30.4595255 59.6891719,30.4595317 59.6892178,30.4595442 59.6893129,30.4595387 59.689363,30.4595118 59.6894235,30.4594761 59.689469,30.4594014 59.6895068,30.4593069 59.6895588,30.4592476 59.6895966,30.4591945 59.6896312,30.4591511 59.6896562,30.4591092 59.6896944,30.4590843 59.6897378,30.4590826 59.689771,30.4590853 59.6898069,30.4591078 59.6898435,30.4592007 59.6898882,30.4592339 59.6899293,30.4592628 59.6899874,30.4592762 59.6900429,30.45928 59.6901025,30.4592809 59.6901575,30.4592798 59.6902243,30.4593042 59.6902777,30.4593662 59.6903178,30.4594544 59.6903409,30.4595249 59.6903674,30.4595807 59.6903944,30.4596268 59.6904316,30.4596583 59.6904756,30.4596087 59.690551,30.4596006 59.6905905,30.4595977 59.6906403,30.4595904 59.6906903,30.4595826 59.6907418,30.4595821 59.6908019,30.459583 59.6908375,30.459529 59.6908703,30.4594074 59.6909353,30.4592831 59.6909939,30.459213 59.6910431,30.4591817 59.691066,30.4591361 59.6911201,30.4591012 59.6911675,30.4591012 59.691223,30.4591406 59.6912486,30.4592295 59.6912875,30.4592895 59.6913173,30.4593728 59.6913444,30.4594455 59.6913593,30.459517 59.6913682,30.4596037 59.6913935,30.4596491 59.6914211,30.4596908 59.6914522,30.4597319 59.6914924,30.4597559 59.6915361,30.4597745 59.6915821,30.459787 59.6916313,30.4597852 59.6916643,30.4597718 59.6917238,30.4597396 59.6917861,30.4596859 59.6918429,30.4596685 59.6918693,30.4596383 59.6919054,30.4596009 59.6919405,30.4595315 59.6919991,30.4594652 59.6920502,30.4594082 59.6920946,30.4593773 59.6921151,30.4593545 59.6921348,30.4593366 59.6921529,30.4593399 59.6921734,30.4593659 59.6921939,30.4596045 59.6923272,30.4596496 59.6923362,30.4596901 59.6923377,30.4597398 59.6923315,30.4597933 59.6923156,30.4598526 59.6922792,30.4599141 59.692234,30.4600168 59.6921771,30.4600862 59.6921317,30.4601606 59.6921103,30.4602526 59.6920827,30.460323 59.6920633,30.4603814 59.6920333,30.4604812 59.6919715,30.4605362 59.6919506,30.4606073 59.6919499,30.4606743 59.6919675,30.4607467 59.6920081,30.4608017 59.6920284,30.4608728 59.6920473,30.4609935 59.6920595,30.4610726 59.692067,30.4611517 59.6920866,30.4612403 59.6921299,30.4612939 59.6921759,30.4613569 59.6922104,30.4614227 59.6922341,30.4614964 59.6922659,30.4615568 59.6923059,30.4616211 59.6923729,30.4616748 59.6924466,30.4617579 59.6925197,30.4618368 59.6925614,30.461948 59.6926074,30.4620442 59.6926525,30.4621643 59.6927115,30.4622732 59.6927583,30.4623906 59.6927971,30.4625398 59.6928238,30.4626554 59.6928355,30.4627278 59.6928346,30.4627807 59.6928331,30.4629009 59.6928193,30.4629797 59.6928093,30.4630314 59.6928086,30.4630815 59.6928162,30.4631241 59.6928309,30.4631433 59.692849,30.4631354 59.6928782,30.4630918 59.6929178,30.4629933 59.692982,30.4628509 59.6930395,30.4627989 59.693076,30.4627775 59.6931068,30.4627715 59.6931374,30.4627782 59.6931678,30.4628 59.6931938,30.462816 59.6932161,30.4628201 59.6932352,30.4628276 59.6932642,30.4628055 59.6932947,30.462749 59.6933555,30.4627356 59.6934076,30.4627544 59.6934638,30.4627866 59.6935491,30.4628348 59.6936025,30.4628814 59.6936516,30.4629464 59.6936976,30.4630181 59.6937555,30.4631033 59.6938351,30.463194 59.693908,30.4632997 59.6939707,30.4633997 59.6940315,30.4634563 59.6940722,30.4634978 59.6941112,30.4635448 59.6941433,30.4635995 59.6941633,30.4636618 59.6941785,30.4637065 59.6941778,30.4637604 59.694169,30.4638165 59.6941725,30.4638941 59.6941882,30.463945 59.6941973,30.4639826 59.6942136,30.4640155 59.6942304,30.4640341 59.6942422,30.4640539 59.694259,30.4640781 59.6942943,30.4641097 59.6943536,30.4641054 59.6943849,30.4640955 59.6944214,30.4640677 59.6944543,30.4640278 59.694509,30.4639684 59.6945921,30.4639761 59.694632,30.4640196 59.6946691,30.4640928 59.6947215,30.4641504 59.6947644,30.4642414 59.694848,30.4643013 59.6949614,30.4643265 59.6950347,30.4643629 59.6950927,30.464383 59.6951471,30.4644155 59.6951914,30.4644503 59.6952616,30.464467 59.6953187,30.4644779 59.6953885,30.4644493 59.6954307,30.4644137 59.6954645,30.4643477 59.6955048,30.4642827 59.6955528,30.4641331 59.6956106,30.4640324 59.6956546,30.4639589 59.6956973,30.4639054 59.6957548,30.4638826 59.6958068,30.4638917 59.6958626,30.4638959 59.695908,30.4638913 59.6959452,30.4638761 59.6959807,30.4638581 59.6960266,30.4638387 59.6960774,30.4638353 59.6961315,30.4638514 59.6962235,30.4639031 59.6963079,30.4639806 59.6963837,30.4640641 59.696435,30.4641563 59.6964993,30.4642492 59.6965314,30.464353 59.6965624,30.4645112 59.6966079,30.4646909 59.6966431,30.4648519 59.6966796,30.4649082 59.6966992,30.4649645 59.6967256,30.4650316 59.6967635,30.465104 59.6968014,30.4651737 59.6968352,30.4652724 59.696889,30.4653398 59.6969338,30.4653714 59.6969637,30.4653977 59.6970024,30.4654124 59.6970396,30.4654285 59.6970924,30.4654299 59.6971357,30.4654285 59.6971912,30.4654178 59.6972534,30.4654178 59.6973103,30.4654268 59.6973472,30.465443 59.6973849,30.4654739 59.6974306,30.465535 59.6974889,30.4655776 59.6975263,30.4655998 59.6975497,30.4656249 59.6975948,30.4656281 59.6976305,30.4656291 59.6976586,30.465636 59.697698,30.4656478 59.6977439,30.4656559 59.6977839,30.4656639 59.6978247,30.4656741 59.697865,30.4656808 59.6978977,30.4656931 59.6979479,30.4657242 59.6979888,30.4657651 59.6980369,30.4658049 59.6980618,30.4658569 59.6980859,30.4659085 59.6981101,30.4659691 59.6981356,30.4659934 59.6981619,30.4660187 59.6982125,30.4660434 59.6982506,30.4660765 59.6982913,30.46612 59.6983229,30.46618 59.6983645,30.4662324 59.6983954,30.466279 59.6984245,30.4663222 59.6984585,30.4663422 59.6984839,30.4663508 59.6985161,30.466347 59.6985389,30.4663297 59.6985658,30.4662984 59.6986043,30.4662667 59.6986353,30.4662287 59.6986639,30.4662098 59.6986996,30.4662023 59.698738,30.4662177 59.6987814,30.4662476 59.6988217,30.4662941 59.6988595,30.4663218 59.6988897,30.4663703 59.6989336,30.4664066 59.698983,30.4664342 59.6990318,30.46626 59.699006,30.4662245 59.6990009,30.4661986 59.6989985,30.465736 59.6989731,30.465674 59.6989864,30.4656438 59.6989955,30.4656194 59.6990058,30.4655995 59.6990178,30.4655881 59.6990296,30.4655669 59.6990522,30.4655425 59.6990838,30.4655077 59.6991223,30.4654429 59.6991855,30.4653481 59.6992218,30.4652461 59.6992516,30.4651852 59.6992621,30.4651339 59.6992648,30.4650235 59.6992651,30.4649339 59.6992741,30.4648662 59.6992863,30.4647744 59.6993078,30.4647108 59.6993347,30.4646409 59.6993755,30.4645943 59.6994397,30.4645313 59.6994729,30.464447 59.6994976,30.4643342 59.6995189,30.4641272 59.6995513,30.4601 59.6956121,30.4590933 59.6945995,30.4585195 59.6940453,30.4565283 59.6920253,30.4559963 59.6915691,30.455779 59.6913562,30.4555191 59.6911016,30.4536132 59.6892318,30.4533114 59.6893232,30.4532486 59.6892981,30.453085 59.689221,30.4529871 59.689177,30.4528879 59.6891357,30.4528128 59.6891072,30.4524488 59.6889751,30.4524008 59.688958,30.4523038 59.6889045,30.4522723 59.6888961,30.4522552 59.6888858,30.4522361 59.6888724,30.452216 59.68885,30.4521838 59.6888324,30.4521207 59.6887986,30.4520511 59.6887644,30.4518909 59.6886967,30.4517882 59.6886551,30.4516822 59.6886098,30.4515358 59.6885556,30.4514019 59.6885123,30.4513037 59.6884778,30.4512571 59.6884636,30.4512056 59.6884428,30.4511404 59.6884196,30.4510778 59.6883871,30.4510264 59.6883553,30.4509783 59.6883239,30.4508749 59.6882578,30.4508266 59.688226,30.4507678 59.6881981,30.4505943 59.6881208,30.4501869 59.6879433,30.4499736 59.6878632,30.4499334 59.6878503,30.4498881 59.687841,30.4497871 59.6878092,30.4494924 59.6876814,30.4490926 59.6875099,30.4490362 59.6874936,30.4489854 59.6874759,30.4489383 59.6874638,30.448876 59.687449,30.4487626 59.6874338,30.4486346 59.6874221,30.4485214 59.6874142,30.4483648 59.6874032,30.4474691 59.687337,30.4468361 59.6872873,30.4467403 59.6872722,30.446684 59.6872669,30.4463496 59.6872017,30.4463085 59.6871943,30.4462561 59.6871833,30.4462179 59.6871721,30.446187 59.6871613,30.4461557 59.68715,30.4461253 59.6871366,30.4461066 59.6871274,30.4460918 59.6871135,30.4460273 59.6870454,30.4459552 59.6870078,30.4459436 59.6870073,30.4459073 59.6869902,30.4458766 59.6869748,30.445846 59.6869616,30.4458216 59.6869518,30.4457961 59.6869433,30.4457578 59.6869309,30.4457123 59.6869183,30.4456647 59.6869057,30.4455949 59.6868892,30.4455514 59.68688,30.4455232 59.6868726,30.4455129 59.6868665,30.4453868 59.6868434,30.44531 59.6868381,30.4452457 59.6868322,30.44506 59.686812,30.4450028 59.6868076,30.4449557 59.6868041,30.4449237 59.6868029,30.4448943 59.6868019,30.4448734 59.6868039,30.4448512 59.6868054,30.4448212 59.6868026,30.4446945 59.6868462,30.4446194 59.686801,30.4446175 59.6867999,30.4445818 59.68678,30.4445803 59.686779,30.4445518 59.6867606,30.4445169 59.686738,30.4444952 59.6867243,30.4444865 59.6867138,30.4444865 59.6867017)))', 'relation', 4187886, '{"ref": "II", "name": "Долина реки Славянки", "place": "quarter", "name:az": "Slavyanka çayının vadisi", "name:fr": "Vallée de la rivière Slavianka", "name:hy": "Սլավյանկա գետի հովիտ", "name:uk": "Долина річки Слов''янки", "name:zh": "谷斯拉维亚卡河", "boundary": "protected_area", "int_name": "Vallée de la rivière Slavianka", "wikidata": "Q121809341", "wikipedia": "ru:Павловский парк#Долина реки Славянки", "description": "Район Павловского парка"}', NULL),
 ('SRID=4326;LINESTRING(30.4535811 59.6847595,30.4534913 59.6847521,30.4529615 59.6847082,30.4525675 59.6846756,30.4524973 59.6846698,30.4525041 59.6846527,30.4525156 59.684624,30.4525454 59.684611,30.4525859 59.6846153,30.45286 59.6846392)', 'way', 1297781094, '{"height": "2", "barrier": "fence", "fence_type": "metal"}', '{8289295976,12023732271,12023732270,12023732269,8114975027,12023699867,12023732331,12023732330,12023732337,12023732336}'),
 ('SRID=4326;LINESTRING(30.4528746 59.6855048,30.4528788 59.6854915)', 'way', 1093902027, '{"height": "8", "barrier": "fence", "fence_type": "bars", "min_height": "6.65"}', '{1439053674,1439053668}'),
 ('SRID=4326;LINESTRING(30.4535894 59.6847601,30.4535811 59.6847595)', 'way', 1297781085, '{"height": "1.5", "barrier": "fence", "fence_type": "bars"}', '{12023732332,8289295976}'),
 ('SRID=4326;LINESTRING(30.4530887 59.6846582,30.4535793 59.6847014,30.4536048 59.6847154,30.4535894 59.6847601)', 'way', 1297781086, '{"height": "2", "barrier": "fence", "fence_type": "metal"}', '{12023732335,12023732334,12023732333,12023732332}'),
 ('SRID=4326;MULTIPOLYGON(((30.4519927 59.6856654,30.451993 59.6856352,30.4519974 59.6856085,30.4520057 59.6855861,30.452033 59.685533,30.4520717 59.6854725,30.4521073 59.6854196,30.4521538 59.6853554,30.4521646 59.6853419,30.4521729 59.6853289,30.4521751 59.685321,30.4521778 59.6853033,30.4521768 59.6852884,30.4522278 59.6851794,30.4522474 59.6851858,30.4522695 59.6851929,30.4522692 59.6852184,30.452307 59.6852409,30.4523333 59.6852571,30.4523534 59.6852701,30.4523836 59.685295,30.4524088 59.6853175,30.4524395 59.6853504,30.4524616 59.6853789,30.4524735 59.685401,30.4524845 59.6854195,30.4524943 59.6854502,30.452497 59.6854882,30.452346 59.6854768,30.4523217 59.6855588,30.4522802 59.6855556,30.4522258 59.6855515,30.4522191 59.6855742,30.4522002 59.685638,30.4521808 59.6857036,30.4521745 59.6857248,30.4522289 59.6857289,30.4522705 59.6857319,30.4522477 59.6858088,30.4522804 59.6858113,30.4525803 59.6858339,30.4526091 59.6858361,30.4526832 59.6858416,30.4528205 59.685852,30.4528174 59.6858982,30.4527279 59.6859036,30.4527314 59.6859191,30.4527383 59.6859422,30.4527472 59.6859643,30.4527643 59.6859927,30.4527791 59.6860133,30.4527956 59.6860336,30.4528174 59.6860572,30.4528406 59.6860793,30.4528659 59.6861008,30.4528879 59.6861175,30.4529175 59.6861373,30.4529497 59.6861561,30.4529804 59.6861727,30.4530167 59.6861897,30.4530418 59.6861992,30.4530963 59.6861616,30.4531534 59.686184,30.4531278 59.6862023,30.453137 59.6862056,30.4531608 59.6862141,30.4531704 59.6862175,30.453196 59.6861992,30.4531795 59.686249,30.4531642 59.6862975,30.453138 59.686381,30.4531363 59.6863866,30.4532826 59.6863983,30.4532725 59.6864305,30.4532916 59.686432,30.4532869 59.6864462,30.4532998 59.6864473,30.4533248 59.6864494,30.4533485 59.6864515,30.4533611 59.6864525,30.4533659 59.6864383,30.4534768 59.6864467,30.453575 59.6864544,30.4535812 59.6864636,30.4536188 59.68646,30.4536556 59.6864553,30.4536952 59.6864492,30.4537376 59.6864434,30.4537814 59.6864354,30.4538212 59.6864281,30.453863 59.6864194,30.4538817 59.6864353,30.4539287 59.6864214,30.4539454 59.6864356,30.4539576 59.686432,30.4540057 59.6864176,30.4540172 59.6864141,30.4540005 59.6863999,30.4540399 59.6863883,30.4540219 59.6863729,30.4540549 59.6863624,30.4540887 59.6863495,30.4541297 59.6863344,30.4541407 59.6863296,30.4541607 59.6863411,30.4541696 59.6863371,30.4542 59.6863235,30.4542091 59.6863195,30.4541887 59.6863078,30.4541965 59.6863041,30.4542363 59.6862844,30.4542705 59.6862654,30.4542999 59.6862773,30.4544137 59.6862059,30.4543849 59.6861942,30.4544059 59.686181,30.4544395 59.686154,30.4544728 59.6861239,30.4544964 59.6860973,30.4545494 59.6861117,30.4546053 59.6861282,30.4545922 59.6861427,30.4545784 59.6861572,30.4545449 59.6861862,30.4545138 59.6862131,30.4544576 59.6862495,30.4543906 59.6862854,30.4543294 59.6863147,30.4542746 59.6863415,30.454221 59.6863683,30.454115 59.6864133,30.454039 59.6864407,30.4539464 59.6864693,30.4539252 59.6864763,30.4538233 59.6865047,30.4536724 59.6865094,30.4536724 59.6865223,30.4536503 59.6865223,30.4535973 59.686521,30.4535465 59.6865208,30.4535021 59.6865209,30.4534712 59.6865222,30.4534473 59.6865255,30.453429 59.6865331,30.4534215 59.6865438,30.4534132 59.686574,30.4534136 59.6865866,30.453423 59.6865971,30.4534445 59.6866075,30.4534686 59.686613,30.4534579 59.6866461,30.4534073 59.6866421,30.4533332 59.6866345,30.4532837 59.6866305,30.453254 59.6866292,30.4532071 59.6866305,30.4531615 59.686632,30.4531191 59.6866347,30.4531041 59.6865988,30.4531448 59.6865925,30.4531695 59.6865869,30.4531966 59.6865772,30.4532138 59.6865676,30.4532231 59.6865589,30.453199 59.6865568,30.4531811 59.6865532,30.4531596 59.6865468,30.4531373 59.6865396,30.4531219 59.6865326,30.4530964 59.6865196,30.4530733 59.6865042,30.4530555 59.6864887,30.4530367 59.6864681,30.4530227 59.6864499,30.4530105 59.6864274,30.4530012 59.6864103,30.4529945 59.6863933,30.4529919 59.6863759,30.4529905 59.686347,30.4529907 59.6863231,30.4529911 59.6862911,30.4529891 59.686281,30.4529827 59.6862715,30.4529634 59.6862545,30.4529402 59.6862373,30.4529067 59.6862141,30.4528563 59.6861801,30.4528201 59.6861533,30.4527906 59.6861317,30.4527578 59.6861047,30.452731 59.6860823,30.4527092 59.6860609,30.4526947 59.6860457,30.4526816 59.6860278,30.4526652 59.6860011,30.4526541 59.6859782,30.4526337 59.6859283,30.4526256 59.6859159,30.4526103 59.685908,30.4525905 59.6859034,30.4525603 59.6859009,30.452391 59.6858965,30.4523675 59.6858999,30.4523504 59.685904,30.4523333 59.6859114,30.452312 59.685923,30.4522313 59.6859637,30.4521811 59.6859882,30.452085 59.686032,30.4520765 59.6860386,30.4520753 59.6860476,30.4520797 59.6860577,30.4520264 59.6860652,30.4520201 59.6860504,30.4520162 59.6860346,30.4520143 59.6860207,30.4520168 59.6860051,30.4520203 59.685989,30.4520274 59.6859769,30.4520341 59.6859612,30.4520405 59.6859506,30.452047 59.6859415,30.4520537 59.6859259,30.4520544 59.6859134,30.4520523 59.6858956,30.4520465 59.6858708,30.4520254 59.6858069,30.4519995 59.68571,30.4519927 59.6856654),(30.4521704 59.6857398,30.4521704 59.6857513,30.4521744 59.6857635,30.4521811 59.6857763,30.4521945 59.6857899,30.4522187 59.6858021,30.4522414 59.6858088,30.4522629 59.685735,30.4521731 59.6857289,30.4521704 59.6857398),(30.452226 59.6855475,30.4523159 59.6855543,30.4523387 59.6854798,30.4523212 59.6854826,30.4523011 59.6854866,30.452277 59.6854941,30.4522596 59.6855015,30.4522448 59.6855117,30.4522354 59.6855225,30.4522301 59.6855347,30.452226 59.6855475),(30.4522508 59.6858359,30.4525647 59.6858582,30.4525714 59.6858373,30.4522575 59.6858142,30.4522508 59.6858359),(30.4523249 59.685462,30.4523727 59.6854667,30.4523804 59.6854465,30.4523327 59.6854418,30.4523249 59.685462)))', 'relation', 6636677, '{"surface": "fine_gravel", "area:highway": "footway"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4533763 59.68521,30.4534979 59.6851951,30.4535038 59.6852069,30.4534995 59.6852209,30.4533878 59.6852355,30.4533818 59.6852214,30.4533763 59.68521)))', 'relation', 12947389, '{"height": "6", "roof:shape": "flat", "roof:colour": "gray", "building:part": "yes", "building:colour": "#FFE19C"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4523253 59.6851768,30.4523286 59.6851637,30.453297 59.6852393,30.4532684 59.6852465,30.4532391 59.6852543,30.4531809 59.6852727,30.453156 59.6852825,30.4531357 59.6852905,30.453128 59.6852882,30.4531198 59.6852866,30.4531113 59.6852855,30.4531024 59.685285,30.4530936 59.6852852,30.4530849 59.6852859,30.4530765 59.6852873,30.4530685 59.6852893,30.4530612 59.6852918,30.4530559 59.6852942,30.4530511 59.6852969,30.453047 59.6852998,30.4530436 59.6853029,30.4530408 59.6853062,30.4530389 59.6853097,30.4530377 59.6853132,30.4530373 59.6853168,30.4530377 59.6853204,30.4530387 59.6853245,30.4530402 59.6853274,30.4530424 59.6853304,30.4530456 59.6853334,30.4530217 59.6853466,30.4530053 59.6853403,30.4529809 59.6853554,30.4529707 59.6853538,30.4529621 59.6853543,30.452955 59.6853567,30.4529297 59.6853727,30.4529266 59.6853774,30.4529284 59.6853815,30.4529349 59.6853856,30.4529136 59.685403,30.4529312 59.685409,30.4529147 59.685423,30.4529045 59.6854337,30.4529242 59.6854401,30.452909 59.6854545,30.4525881 59.6854311,30.452574 59.6853959,30.4525486 59.6853522,30.4525291 59.6853286,30.4525137 59.6853106,30.452501 59.6852981,30.4524755 59.6852751,30.452455 59.6852592,30.4524366 59.6852453,30.4524178 59.6852321,30.4523994 59.6852201,30.4523706 59.6852014,30.452339 59.6851839,30.4523253 59.6851768)))', 'relation', 5906400, '{"ref": "2", "name": "Цветочный партер", "leisure": "garden", "name:en": "The Flower Parterre", "ref:okn": "781620399040956", "alt_name": "Цветники Марии Фёдоровны", "wikidata": "Q118122045", "garden:type": "flowerbed", "garden:style": "french"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.453156 59.6852825,30.4531809 59.6852727,30.4532391 59.6852543,30.4532684 59.6852465,30.4533268 59.6853074,30.4533609 59.6853429,30.4533196 59.6853548,30.4532989 59.6853612,30.4532797 59.6853674,30.4532343 59.6853363,30.453156 59.6852825)))', 'relation', 17755883, '{"height": "13", "min_height": "10", "roof:shape": "gabled", "roof:colour": "#DADDE2", "roof:height": "2", "building:part": "yes", "roof:material": "metal", "building:colour": "#FFE19C", "roof:orientation": "across"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4529045 59.6854337,30.4529147 59.685423,30.4529312 59.685409,30.4529542 59.6853912,30.4529724 59.685378,30.4530012 59.685359,30.4530217 59.6853466,30.4531158 59.6853933,30.4531719 59.6854212,30.4531582 59.6854285,30.453148 59.6854347,30.4531265 59.6854489,30.4531071 59.6854639,30.4530899 59.6854797,30.4530216 59.6854636,30.4529242 59.6854401,30.4529045 59.6854337)))', 'relation', 17755885, '{"height": "13", "min_height": "10", "roof:shape": "gabled", "roof:colour": "#DADDE2", "roof:height": "2", "building:part": "yes", "roof:material": "metal", "building:colour": "#FFE19C", "roof:orientation": "across"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4530217 59.6853466,30.4530456 59.6853334,30.4530682 59.6853211,30.4530897 59.6853096,30.4531138 59.6852988,30.4531357 59.6852905,30.453156 59.6852825,30.4532343 59.6853363,30.4532797 59.6853674,30.4532663 59.6853726,30.4532524 59.6853786,30.453238 59.6853862,30.453207 59.6854026,30.4531719 59.6854212,30.4531158 59.6853933,30.4530217 59.6853466)))', 'relation', 17755884, '{"height": "13", "min_height": "10", "roof:shape": "gabled", "roof:colour": "#DADDE2", "roof:height": "2", "building:part": "yes", "roof:material": "metal", "building:colour": "#FFE19C", "roof:orientation": "across"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4527677 59.6846399,30.4527719 59.6846286,30.4527799 59.6846212,30.4527933 59.6846157,30.4528134 59.6846137,30.4528403 59.6846144,30.4528537 59.6846178,30.4528639 59.6846231,30.45286 59.6846392,30.4528579 59.6846477,30.4527677 59.6846399)))', 'relation', 12932608, '{"natural": "scrub", "leaf_type": "broadleaved", "leaf_cycle": "deciduous"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.452843 59.684694,30.4528469 59.6846817,30.4528579 59.6846477,30.45286 59.6846392,30.4528639 59.6846231,30.4530942 59.6846416,30.4530887 59.6846582,30.4530859 59.6846667,30.4530752 59.684699,30.4530706 59.6847131,30.4529628 59.6847041,30.452843 59.684694)))', 'relation', 1721132, '{"ref": "3", "name": "Павильон Трёх граций", "note": "Геометрические теги крыши павильона размещены отдельно", "name:es": "Pabellón de las tres gracias", "name:fr": "Pavillon des Trois Grâces", "name:pt": "Pavilhão das Três Graças", "name:zh": "三美人亭", "ref:okn": "781610399040356", "tourism": "attraction", "building": "yes", "heritage": "2", "historic": "yes", "wikidata": "Q112716431", "addr:city": "Павловск", "architect": "Чарльз Камерон", "start_date": "1800", "addr:street": "Садовая улица", "architect:en": "Charles Cameron", "addr:housenumber": "20 литЧ", "heritage:website": "https://kgiop.gov.spb.ru/deyatelnost/uchet/list_objects/6514/"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.452843 59.684694,30.4528469 59.6846817,30.4528579 59.6846477,30.45286 59.6846392,30.4528639 59.6846231,30.4530942 59.6846416,30.4530887 59.6846582,30.4530859 59.6846667,30.4530752 59.684699,30.4530706 59.6847131,30.4529628 59.6847041,30.452843 59.684694)))', 'relation', 12202573, '{"height": "7", "min_height": "5.5", "roof:shape": "gabled", "roof:colour": "#DADDE2", "roof:height": "1", "building:part": "yes", "building:colour": "#FFE19C", "roof:orientation": "across"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.452843 59.684694,30.4528469 59.6846817,30.4528579 59.6846477,30.45286 59.6846392,30.4528639 59.6846231,30.4530942 59.6846416,30.4530887 59.6846582,30.4530859 59.6846667,30.4530752 59.684699,30.4530706 59.6847131,30.4529628 59.6847041,30.452843 59.684694)))', 'relation', 12497925, '{"height": "1.5", "roof:shape": "flat", "roof:colour": "gray", "building:part": "yes"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4525466 59.6846232,30.4525568 59.6846156,30.4525613 59.6846073,30.4525618 59.6845988,30.4525615 59.68459,30.4525675 59.6845745,30.452571 59.6845656,30.452566 59.6845558,30.4525539 59.6845467,30.4526659 59.6845694,30.4527826 59.6845897,30.4528946 59.6846069,30.4530012 59.6846212,30.4535732 59.6846878,30.4535916 59.6846905,30.453606 59.6846946,30.4536164 59.684701,30.4536208 59.6847085,30.4536214 59.684718,30.4536181 59.6847274,30.4536067 59.6847614,30.4535894 59.6847601,30.4535811 59.6847595,30.4535863 59.6847456,30.4535923 59.6847296,30.4535925 59.6847224,30.4535886 59.6847164,30.4535807 59.6847121,30.4535698 59.6847103,30.4535555 59.6847085,30.4530859 59.6846667,30.4530887 59.6846582,30.4530942 59.6846416,30.4528639 59.6846231,30.45286 59.6846392,30.4528579 59.6846477,30.4527677 59.6846399,30.4525841 59.6846239,30.4525626 59.6846222,30.4525466 59.6846232)))', 'relation', 12131779, '{"landuse": "grass"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.452047 59.6856386,30.4520524 59.6856064,30.4520624 59.6855804,30.4520946 59.6855262,30.4521293 59.6854701,30.4521596 59.6854203,30.4521905 59.6853763,30.4522119 59.6853269,30.4522167 59.6853009,30.4522474 59.6851858,30.4522278 59.6851794,30.4526025 59.6847092,30.4524973 59.6846698,30.4525184 59.6846577,30.4525251 59.684634,30.4525331 59.6846279,30.4525466 59.6846232,30.4525626 59.6846222,30.4525841 59.6846239,30.4527677 59.6846399,30.4528579 59.6846477,30.45286 59.6846392,30.4528639 59.6846231,30.4530942 59.6846416,30.4530887 59.6846582,30.4530859 59.6846667,30.4535555 59.6847085,30.4535698 59.6847103,30.4535807 59.6847121,30.4535886 59.6847164,30.4535925 59.6847224,30.4535923 59.6847296,30.4535863 59.6847456,30.4535811 59.6847595,30.4535894 59.6847601,30.4536067 59.6847614,30.4536193 59.6847624,30.4536402 59.684764,30.4536417 59.6847593,30.4536451 59.6847596,30.4538117 59.6847727,30.4538368 59.6847747,30.4538611 59.6847766,30.4540318 59.6847901,30.4540295 59.6847972,30.4540811 59.684801,30.454116 59.6848031,30.4541545 59.6848057,30.4541808 59.6848075,30.4542309 59.6848107,30.4542641 59.6848127,30.4548047 59.6848466,30.4554062 59.6848883,30.4554276 59.6847972,30.4555787 59.6847942,30.4556183 59.6848013,30.45566 59.6848082,30.4556602 59.6848033,30.4557245 59.6848039,30.4557241 59.6848115,30.4558924 59.6848132,30.4558927 59.6848058,30.4559591 59.6848066,30.455968 59.6848067,30.456132 59.6848104,30.4563276 59.6848162,30.4565276 59.684828,30.4567174 59.6848433,30.4568173 59.684855,30.4569112 59.6848679,30.4569916 59.6848814,30.4570788 59.684897,30.4572191 59.6849255,30.4573068 59.6849471,30.4574034 59.6849722,30.4575415 59.6850067,30.4576796 59.6850473,30.4580243 59.6851495,30.458385 59.6852544,30.4585262 59.6852893,30.4586586 59.685316,30.4588062 59.6853451,30.4589376 59.6853682,30.4590725 59.6853866,30.4592621 59.685404,30.4596014 59.6854347,30.4597372 59.6854816,30.4597703 59.6854795,30.4598067 59.6854769,30.4598237 59.6854755,30.4598214 59.6854687,30.4598497 59.6854668,30.4598516 59.685473,30.4598851 59.6854707,30.4599237 59.6854678,30.4599217 59.6854614,30.4599499 59.6854595,30.4599522 59.6854659,30.4599714 59.6854643,30.4600087 59.6854612,30.4600147 59.6854607,30.4600534 59.6854572,30.4601985 59.6854128,30.4601554 59.6854805,30.4601767 59.6856005,30.4601793 59.6857568,30.4601468 59.6858374,30.4600081 59.6860973,30.459853 59.68614,30.459704 59.6863415,30.4596832 59.6864086,30.4596712 59.686482,30.4596638 59.6865545,30.459666 59.6866369,30.4596929 59.6867933,30.4597047 59.6868418,30.4597409 59.6869365,30.4598403 59.6871335,30.4599111 59.6872432,30.4599552 59.6873116,30.4600453 59.6874469,30.460134 59.687572,30.4600858 59.6875668,30.4600427 59.6875593,30.4599863 59.6875559,30.4598958 59.6875545,30.4597744 59.6875619,30.4597289 59.6875627,30.4596698 59.687583,30.4596323 59.6876026,30.4595974 59.6876371,30.4595625 59.6876658,30.4595236 59.6876852,30.459478 59.6876967,30.459407 59.6877062,30.4593453 59.6877028,30.4592849 59.6876838,30.4592367 59.6876553,30.4591509 59.6875883,30.4590905 59.6875599,30.4590355 59.6875424,30.4589524 59.6875261,30.4588343 59.6875105,30.4586868 59.6875038,30.4585474 59.6875038,30.4584333 59.6875086,30.4583274 59.6875126,30.4582348 59.6875193,30.4581437 59.6875301,30.4580095 59.6875505,30.4579371 59.6875654,30.4579009 59.6875782,30.4578312 59.6876019,30.4577386 59.6876249,30.4576489 59.6876236,30.4575564 59.6876086,30.4574243 59.6875895,30.4573214 59.6875781,30.4572099 59.6875697,30.4570995 59.6875755,30.4570005 59.6875828,30.4568899 59.687586,30.4567611 59.687592,30.4566782 59.6875933,30.4565289 59.6875961,30.4563573 59.6875979,30.4561991 59.6876021,30.4561467 59.6876019,30.4560838 59.6875938,30.4560395 59.6875816,30.4559953 59.6875601,30.4559804 59.6875356,30.4559765 59.6875127,30.4560113 59.687453,30.4560436 59.6874139,30.4560824 59.6873697,30.4561159 59.6873352,30.4561616 59.6872894,30.456183 59.687235,30.4561831 59.6871675,30.4561508 59.6871091,30.4560875 59.6870601,30.4559816 59.68702,30.4558987 59.6870186,30.4557807 59.6870023,30.4556466 59.6869672,30.4555769 59.68694,30.455491 59.6869022,30.4553945 59.6868602,30.4552388 59.6868093,30.4551163 59.6867835,30.4548168 59.686752,30.4546788 59.6867553,30.4546214 59.6867604,30.4545963 59.6867573,30.4545534 59.6867525,30.4545508 59.6867576,30.4544638 59.6867472,30.4544646 59.686742,30.4544227 59.6867377,30.4544217 59.6867427,30.4539778 59.6866919,30.4539823 59.6866673,30.4536976 59.6866508,30.453691 59.6866508,30.4536201 59.6866455,30.4535229 59.6866363,30.4534028 59.6866228,30.4533083 59.686614,30.453271 59.6866114,30.4531936 59.6866133,30.4531259 59.6866181,30.4530173 59.6866255,30.4528825 59.6866353,30.4527524 59.6866414,30.4526585 59.6866455,30.4525641 59.6866457,30.4525264 59.6866438,30.4524912 59.6866392,30.4524614 59.686634,30.4524214 59.6866244,30.4523836 59.686613,30.4523413 59.6865954,30.4523226 59.6865862,30.4523045 59.686573,30.4522888 59.6865538,30.4522776 59.6865312,30.452274 59.6865148,30.4522743 59.6864925,30.4522787 59.6864747,30.452286 59.6864496,30.4522911 59.6864255,30.4522989 59.6863961,30.4523018 59.6863618,30.4522992 59.6863312,30.4522911 59.6863104,30.4522828 59.6862897,30.4522676 59.6862668,30.4522535 59.6862461,30.45222 59.6862149,30.4521822 59.6861782,30.4521581 59.6861556,30.4521387 59.6861383,30.4520819 59.6860924,30.4520658 59.6860755,30.4520492 59.6860479,30.4520478 59.686026,30.4520825 59.6859825,30.4521047 59.6859432,30.4521127 59.6859046,30.4520997 59.6858613,30.4520778 59.685798,30.4520551 59.685713,30.452047 59.6856666,30.452047 59.6856386)))', 'relation', 4194432, '{"ref": "III", "name": "Придворцовый район", "place": "quarter", "name:fr": "Secteur central", "website": "https://pavlovskmuseum.ru/about/park/layout/36/", "boundary": "protected_area", "wikidata": "Q121809724", "wikipedia": "ru:Павловский парк#Центральный (Придворцовый) район", "description": "Район исторического Павловского парка"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4324568 59.6916037,30.4324575 59.6915749,30.4324621 59.6915482,30.4324682 59.6915286,30.4324753 59.6915093,30.4324823 59.6914899,30.4324944 59.6914662,30.4325151 59.6914382,30.4329919 59.6909939,30.43335 59.690647,30.4334536 59.6905408,30.4339347 59.6900298,30.4339655 59.689999,30.4340158 59.6899496,30.4340708 59.6898981,30.4341325 59.6898423,30.4342103 59.6897817,30.4348634 59.6892971,30.4350304 59.6891847,30.4350941 59.6891512,30.4351437 59.6891282,30.4352121 59.6891005,30.4352859 59.6890795,30.4353489 59.6890653,30.4354555 59.6890493,30.4355219 59.6890436,30.4355801 59.6890388,30.4357297 59.689028,30.4358183 59.6890226,30.4358639 59.6890281,30.4359047 59.6890265,30.4359108 59.689045,30.4366128 59.6889954,30.4366882 59.6889898,30.4370373 59.6889668,30.4370736 59.6889644,30.4371138 59.6889367,30.4374634 59.6889115,30.4375002 59.6889088,30.4375427 59.6889059,30.4380171 59.6888738,30.438182 59.6888616,30.4383254 59.6888487,30.4384589 59.6888338,30.4385849 59.6888182,30.4388652 59.6887778,30.4389016 59.6887728,30.4389356 59.688768,30.4394909 59.6886943,30.4398543 59.6886325,30.4400071 59.6886046,30.4406955 59.688479,30.4408104 59.688458,30.4414068 59.6883491,30.4414241 59.6883739,30.4414406 59.6883714,30.4414646 59.6883674,30.4414905 59.688363,30.4417352 59.6883072,30.4417808 59.6882913,30.4418344 59.6882694,30.4418821 59.6882476,30.4419664 59.6882073,30.4431861 59.6875688,30.443383 59.6874657,30.4433566 59.6874537,30.4434022 59.6874298,30.4434203 59.6874209,30.4434378 59.6874131,30.4434606 59.6874073,30.4434998 59.6874019,30.4435553 59.6873939,30.4435961 59.6873824,30.4436284 59.6873671,30.4436444 59.6873558,30.4436589 59.687339,30.4436667 59.6873247,30.4436715 59.6873005,30.4436661 59.68728,30.4436564 59.6872675,30.4436464 59.687259,30.4438843 59.6871016,30.4441866 59.6869058,30.4442598 59.6869111,30.4442951 59.6869136,30.4443323 59.6869292,30.4443347 59.6869302,30.4443923 59.6869614,30.4444065 59.6869691,30.444438 59.6869552,30.4445489 59.6869077,30.444645 59.6868671,30.4446626 59.6868597,30.4446945 59.6868462,30.4446194 59.686801,30.4446175 59.6867999,30.4445818 59.68678,30.4445803 59.686779,30.4445518 59.6867606,30.4445169 59.686738,30.4444952 59.6867243,30.4444865 59.6867138,30.4444865 59.6867017,30.4444952 59.6866905,30.4445375 59.6866638,30.444687 59.6865741,30.4448347 59.6864855,30.445096 59.6863422,30.4452308 59.6862691,30.4453607 59.6861984,30.4456533 59.6860464,30.4458048 59.6859713,30.4459528 59.6859038,30.4463406 59.6857168,30.446723 59.6855342,30.447509 59.6851751,30.4477152 59.6850805,30.4478346 59.6850209,30.447946 59.6849604,30.4480438 59.684899,30.4481859 59.6848002,30.4483241 59.6846939,30.4484287 59.68461,30.4484662 59.6845826,30.4485046 59.6845589,30.4486084 59.6844949,30.4486791 59.6844562,30.4488525 59.6843737,30.4490602 59.6842836,30.449236 59.6842106,30.4493951 59.6841491,30.4494519 59.6841382,30.4495136 59.6841273,30.4496558 59.6841097,30.4498549 59.6840882,30.4498949 59.6840845,30.450264 59.6840506,30.4503834 59.6840449,30.4504672 59.684042,30.4505671 59.6840395,30.4506691 59.6840402,30.4507093 59.6840439,30.4507582 59.6840576,30.4508011 59.6840678,30.4508456 59.6840745,30.4510132 59.6840377,30.4511147 59.6840765,30.4511813 59.6841019,30.4512523 59.684129,30.4513511 59.6841667,30.4513385 59.6842533,30.4516531 59.6843525,30.4522364 59.6845601,30.4525041 59.6846527,30.4525184 59.6846577,30.4525251 59.684634,30.4525331 59.6846279,30.4525466 59.6846232,30.4525626 59.6846222,30.4525841 59.6846239,30.4527677 59.6846399,30.4528579 59.6846477,30.45286 59.6846392,30.4528639 59.6846231,30.4530942 59.6846416,30.4530887 59.6846582,30.4530859 59.6846667,30.4535555 59.6847085,30.4535698 59.6847103,30.4535807 59.6847121,30.4535886 59.6847164,30.4535925 59.6847224,30.4535923 59.6847296,30.4535863 59.6847456,30.4535811 59.6847595,30.4535894 59.6847601,30.4536067 59.6847614,30.4536193 59.6847624,30.4536402 59.684764,30.4536417 59.6847593,30.4536451 59.6847596,30.4538117 59.6847727,30.4538368 59.6847747,30.4538611 59.6847766,30.4540318 59.6847901,30.4540295 59.6847972,30.4540811 59.684801,30.454116 59.6848031,30.4541545 59.6848057,30.4541808 59.6848075,30.4542309 59.6848107,30.4542641 59.6848127,30.4548047 59.6848466,30.4554062 59.6848883,30.4554276 59.6847972,30.4555787 59.6847942,30.4556183 59.6848013,30.45566 59.6848082,30.4556602 59.6848033,30.4557245 59.6848039,30.4557241 59.6848115,30.4558924 59.6848132,30.4558927 59.6848058,30.4559591 59.6848066,30.455968 59.6848067,30.456132 59.6848104,30.4563276 59.6848162,30.4565276 59.684828,30.4567174 59.6848433,30.4568173 59.684855,30.4569112 59.6848679,30.4569916 59.6848814,30.4570788 59.684897,30.4572191 59.6849255,30.4573068 59.6849471,30.4574034 59.6849722,30.4575415 59.6850067,30.4576796 59.6850473,30.4580243 59.6851495,30.458385 59.6852544,30.4585262 59.6852893,30.4586586 59.685316,30.4588062 59.6853451,30.4589376 59.6853682,30.4590725 59.6853866,30.4592621 59.685404,30.4596014 59.6854347,30.4597372 59.6854816,30.4597703 59.6854795,30.4598067 59.6854769,30.4598237 59.6854755,30.4598214 59.6854687,30.4598497 59.6854668,30.4598516 59.685473,30.4598851 59.6854707,30.4599237 59.6854678,30.4599217 59.6854614,30.4599499 59.6854595,30.4599522 59.6854659,30.4599714 59.6854643,30.4600087 59.6854612,30.4600147 59.6854607,30.4600534 59.6854572,30.4601985 59.6854128,30.4638062 59.6851903,30.4654915 59.6850838,30.4656498 59.6850784,30.4657732 59.6850771,30.4659129 59.6850764,30.4672032 59.6851174,30.4675083 59.6851283,30.4688128 59.6851701,30.4688678 59.6851408,30.4688852 59.6851413,30.4688871 59.6851311,30.4689262 59.6851323,30.4689682 59.6851335,30.468967 59.6851443,30.4689863 59.685145,30.4690455 59.6851751,30.4692529 59.685186,30.4712661 59.6852555,30.4717998 59.6852713,30.4721192 59.6852787,30.4728281 59.6852957,30.4729388 59.6852984,30.4730017 59.6852996,30.4730645 59.6853009,30.4731491 59.685303,30.4731729 59.6853036,30.4731946 59.6853042,30.4732094 59.6853046,30.473248 59.6853064,30.4732627 59.685307,30.4733131 59.6853083,30.4735532 59.6853155,30.4738186 59.6853234,30.4747194 59.6853502,30.4760058 59.6853884,30.4760711 59.6853899,30.4767032 59.6854063,30.4769946 59.6854145,30.4770841 59.685417,30.4772286 59.6854211,30.477324 59.6854237,30.4775836 59.6854311,30.4776272 59.6854323,30.4777058 59.6854345,30.477722 59.6854131,30.4778064 59.6854131,30.4778267 59.6854376,30.4782629 59.6854511,30.4803314 59.6855148,30.4804972 59.6855157,30.4806957 59.6855035,30.4809866 59.6854778,30.4813563 59.6854413,30.4816887 59.6854084,30.4829592 59.6852829,30.484201 59.6851595,30.4851027 59.68507,30.4856157 59.685019,30.4859321 59.6849876,30.4860003 59.6849808,30.4860486 59.6850662,30.4861646 59.6852711,30.4863078 59.6855173,30.4864369 59.6857523,30.4864761 59.6858216,30.4866222 59.6860742,30.486646 59.6861155,30.4870343 59.686796,30.4871407 59.6869901,30.4872588 59.6872054,30.4877195 59.6880454,30.487808 59.688202,30.4878204 59.6882235,30.4878635 59.6883002,30.48787 59.6883117,30.4878916 59.6883487,30.4879075 59.6883812,30.4879153 59.6883977,30.4879246 59.6884174,30.4879765 59.6885128,30.4880116 59.6885763,30.4880581 59.6885694,30.4881086 59.6885618,30.4881355 59.6885578,30.4882292 59.6885456,30.4888791 59.6896373,30.489701 59.6924953,30.4896786 59.6925163,30.4908925 59.6968416,30.4908907 59.6969219,30.4908693 59.696978,30.4908278 59.6970308,30.488341 59.6991065,30.4878952 59.6994664,30.4876552 59.6996701,30.4838245 59.7028735,30.4794807 59.706361,30.479376 59.7064476,30.4793425 59.7064936,30.479321 59.7065348,30.4793143 59.7065707,30.479136 59.7066397,30.4791105 59.7067926,30.4790216 59.7067947,30.478967 59.7068115,30.4789214 59.706846,30.4788959 59.7068683,30.4788395 59.706903,30.4787806 59.7069259,30.4787363 59.7069386,30.4786216 59.7069479,30.4779183 59.7069596,30.4736783 59.7070303,30.473675 59.7069867,30.4736739 59.7069694,30.4736706 59.7069389,30.4732464 59.7069452,30.4729689 59.7069493,30.4697965 59.7069962,30.4687773 59.7070136,30.4663413 59.7070601,30.4662337 59.7070622,30.4660736 59.7070633,30.4660557 59.707042,30.4660408 59.7070243,30.4659974 59.7069726,30.4659835 59.7069561,30.4659791 59.7069508,30.4659686 59.7069384,30.4659531 59.70692,30.4658816 59.7068348,30.4656818 59.7065821,30.4655355 59.7065546,30.4652621 59.7065033,30.4651239 59.7064784,30.4650726 59.706474,30.4650016 59.7064692,30.4645828 59.706441,30.4644927 59.7064349,30.4640497 59.7064008,30.4639779 59.7064033,30.4639163 59.7064329,30.4638698 59.7064308,30.4638303 59.7064291,30.4637599 59.7064255,30.4637148 59.7064233,30.4636972 59.706296,30.463669 59.7061547,30.4636421 59.7061131,30.4636191 59.7060776,30.4635652 59.7060291,30.4635492 59.7060147,30.4633455 59.7058911,30.4631782 59.7058035,30.4630326 59.7057228,30.4628485 59.7056506,30.4625988 59.7055749,30.4623338 59.7055117,30.462411 59.7054206,30.4625908 59.7051744,30.4627383 59.705012,30.4627387 59.7049841,30.4628295 59.7048848,30.4629347 59.7048106,30.4631495 59.7046592,30.4632413 59.7045664,30.4632815 59.7037822,30.4635147 59.7033885,30.4635704 59.7031913,30.4635837 59.7031547,30.4637313 59.7028432,30.4638334 59.7024501,30.4638456 59.7023972,30.463836 59.7023848,30.4637361 59.7022574,30.4636905 59.7022019,30.4635064 59.7019706,30.4635161 59.7019493,30.4636111 59.701924,30.463635 59.7019182,30.4637511 59.70189,30.4637308 59.7018637,30.4637092 59.7018342,30.4636851 59.701795,30.4636516 59.7017429,30.4636207 59.7016942,30.4635699 59.7016225,30.4635353 59.7015738,30.4635222 59.7014983,30.4635136 59.701428,30.4635319 59.7013361,30.463663 59.7011745,30.4636393 59.7011294,30.4635985 59.701113,30.4635901 59.7011096,30.4634909 59.7010692,30.4633415 59.7009065,30.4632475 59.7008008,30.4633339 59.7007478,30.463267 59.7007226,30.4631688 59.7006856,30.462726 59.7005187,30.4627839 59.700477,30.4629277 59.700364,30.4628712 59.7003463,30.4628406 59.7003375,30.4628018 59.700329,30.4627324 59.7003133,30.4625437 59.700281,30.4624003 59.7002577,30.4623277 59.7002393,30.4622533 59.7002132,30.462183 59.7001817,30.4620452 59.7000972,30.4619642 59.7000527,30.4618883 59.7000085,30.4617881 59.6999591,30.4616936 59.6999188,30.4615834 59.6998886,30.4615415 59.6998816,30.4614913 59.6998733,30.4614085 59.6998641,30.4612464 59.6998574,30.4611217 59.6998541,30.4608263 59.6998478,30.4607558 59.6996967,30.4607155 59.6996206,30.46063 59.6994896,30.4606032 59.6994485,30.4605319 59.6993425,30.4604507 59.6993266,30.4602215 59.6992772,30.4595558 59.699131,30.4592776 59.699072,30.4575016 59.6986865,30.4562393 59.6984033,30.4559187 59.6983348,30.4558203 59.6983605,30.4557987 59.6983662,30.4557686 59.6983735,30.4549679 59.6985899,30.4541981 59.6988205,30.453899 59.6989058,30.4537918 59.6989356,30.4536794 59.6989629,30.4535557 59.6989856,30.4534511 59.6989991,30.4533251 59.6990121,30.4532188 59.6990257,30.4531097 59.6990384,30.4530898 59.6990411,30.4530456 59.6990471,30.4529483 59.6990428,30.452721 59.6990256,30.4526039 59.6990156,30.4523895 59.6989984,30.4522106 59.6989843,30.4520626 59.698971,30.4518814 59.6989585,30.4516574 59.6989473,30.4515079 59.6989512,30.4513576 59.6989647,30.4511257 59.6989833,30.4507033 59.6990189,30.4498045 59.699093,30.4495902 59.6991095,30.449288 59.6991349,30.4489705 59.699163,30.4487787 59.6991832,30.4486594 59.6992042,30.4485816 59.6992218,30.4483804 59.6992665,30.4483134 59.6992807,30.4482261 59.6992991,30.4480734 59.6993207,30.4478922 59.6993369,30.4476348 59.6993534,30.4474175 59.6993579,30.4472213 59.6993549,30.4470849 59.6993484,30.4469099 59.6993315,30.4465807 59.6992943,30.4463005 59.699266,30.4460455 59.6992334,30.445784 59.6991949,30.4455453 59.6991481,30.4453367 59.6991061,30.4450934 59.6990399,30.4448113 59.6989579,30.4445865 59.6988843,30.4443921 59.6988221,30.4441572 59.6987421,30.4439038 59.6986557,30.4434519 59.6984884,30.4429811 59.6983056,30.4420431 59.6979399,30.4418559 59.6978726,30.4416695 59.6977994,30.441534 59.6977474,30.4414482 59.6977149,30.4413649 59.6976776,30.4412699 59.6976303,30.4411831 59.6975862,30.4411089 59.6975484,30.4410289 59.697504,30.4409815 59.6974727,30.4409212 59.6974328,30.4408374 59.6973571,30.4405993 59.6971268,30.4404411 59.6969686,30.4402828 59.6968116,30.4397464 59.6962404,30.4395909 59.6960983,30.439434 59.6959641,30.4393118 59.695876,30.4392419 59.6958321,30.439177 59.6957928,30.4390738 59.6957339,30.4388879 59.6956351,30.4385161 59.6954393,30.4384468 59.695404,30.438361 59.6953709,30.4382459 59.6953424,30.4380981 59.695312,30.4379144 59.6952822,30.4375067 59.6952213,30.4372801 59.6951739,30.4371808 59.695153,30.4370661 59.695126,30.4369099 59.6950805,30.4367611 59.6950291,30.4366176 59.6949682,30.4364949 59.6948934,30.4362637 59.6947112,30.4359055 59.6944268,30.4355501 59.6941622,30.4351531 59.6938841,30.4347532 59.6936305,30.4346998 59.6935975,30.4346849 59.693577,30.4346802 59.6935317,30.4346817 59.6935045,30.4346729 59.6934955,30.4346017 59.6934439,30.4344133 59.6933106,30.4344523 59.6932882,30.4344971 59.6932601,30.4345233 59.6932407,30.4345424 59.6932254,30.4345634 59.6932027,30.4345863 59.693171,30.4345979 59.6931498,30.4346066 59.6931248,30.4346128 59.6930889,30.434612 59.693054,30.4346077 59.6930245,30.4346019 59.6930124,30.4345969 59.693,30.4345757 59.6929702,30.4345621 59.6929518,30.434542 59.6929299,30.4345091 59.6928998,30.4344756 59.6928775,30.4344413 59.6928581,30.4343883 59.6928337,30.4343603 59.6928224,30.4343198 59.692809,30.4342705 59.6927958,30.4342429 59.6927909,30.4341796 59.6927811,30.4341217 59.6927737,30.4340777 59.6927708,30.4340075 59.6927673,30.4339293 59.6927692,30.4338474 59.6927768,30.433767 59.6927902,30.4337225 59.6928016,30.4335043 59.6926756,30.4333366 59.6926751,30.4332748 59.6926368,30.4332052 59.6925918,30.4331186 59.6925354,30.4330442 59.6924832,30.4329739 59.6924321,30.432891 59.6923692,30.4328383 59.6923262,30.432786 59.6922862,30.4327464 59.6922518,30.4327224 59.6922281,30.4327002 59.692202,30.4326801 59.6921654,30.4326563 59.6921265,30.4326325 59.6920866,30.4326077 59.6920372,30.4325876 59.6920054,30.4325715 59.6919759,30.4325473 59.691936,30.4325252 59.6918893,30.4325105 59.6918548,30.4324944 59.6918145,30.4324776 59.6917472,30.4324681 59.6916959,30.4324608 59.6916494,30.4324568 59.6916037)))', 'relation', 1721131, '{"name": "Павловский парк", "note": "https://wiki.openstreetmap.org/wiki/RU:Павловск/Павловский_парк", "leisure": "park", "name:be": "Паўлаўскі парк", "name:bg": "Павловски парк", "name:ca": "Parc Pàvlovsk", "name:en": "Pavlovsk Park", "name:es": "Parque Pávlovsk", "name:fr": "Parc de Pavlovsk", "name:he": "פארק פבלובסק", "name:hy": "Պավլովսկ պարկը", "name:nl": "Pavlovskpark", "name:ru": "Павловский парк", "name:zh": "巴甫洛夫斯克公园", "ref:okn": "781720399040986", "website": "https://pavlovskmuseum.ru/about/park/", "boundary": "protected_area", "heritage": "2", "historic": "yes", "int_name": "Parc de Pavlovsk", "operator": "Государственный музей-заповедник «Павловск»", "wikidata": "Q2506336", "wikipedia": "ru:Павловский парк", "fee:amount": "100", "start_date": "1777", "opening_hours": "07:00-19:00", "protect_class": "22", "operator:phone": "+7 (812) 452-15-36", "fee:conditional": "yes @ 9:00-17:00", "heritage:website": "https://kgiop.gov.spb.ru/deyatelnost/uchet/list_objects/6407/", "operator:tourism": "museum", "operator:website": "http://www.pavlovskmuseum.ru", "protection_title": "Государственный музей-заповедник"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4324568 59.6916037,30.4324575 59.6915749,30.4324621 59.6915482,30.4324682 59.6915286,30.4324753 59.6915093,30.4324823 59.6914899,30.4324944 59.6914662,30.4325151 59.6914382,30.4329919 59.6909939,30.43335 59.690647,30.4334536 59.6905408,30.4339347 59.6900298,30.4339655 59.689999,30.4340158 59.6899496,30.4340708 59.6898981,30.4341325 59.6898423,30.4342103 59.6897817,30.4348634 59.6892971,30.4350304 59.6891847,30.4350941 59.6891512,30.4351437 59.6891282,30.4352121 59.6891005,30.4352859 59.6890795,30.4353489 59.6890653,30.4354555 59.6890493,30.4355219 59.6890436,30.4355801 59.6890388,30.4357297 59.689028,30.4358183 59.6890226,30.4358639 59.6890281,30.4359047 59.6890265,30.4359108 59.689045,30.4366128 59.6889954,30.4368674 59.6896812,30.4373083 59.6896203,30.4383622 59.6894747,30.4383925 59.6894699,30.4387768 59.6894091,30.4389533 59.6893793,30.4395631 59.6892765,30.4395975 59.6896826,30.43963 59.6897841,30.4411104 59.6895883,30.4411759 59.6892872,30.4412059 59.6891298,30.4412229 59.6890714,30.4402547 59.6891154,30.4398722 59.6891396,30.4395358 59.6891608,30.4394903 59.6891472,30.4392717 59.6889536,30.4391469 59.6889286,30.4391174 59.6889211,30.4390705 59.6889062,30.4390316 59.6888852,30.4390007 59.6888636,30.4389819 59.6888446,30.4389356 59.688768,30.4394909 59.6886943,30.4398543 59.6886325,30.4400071 59.6886046,30.4406955 59.688479,30.4408104 59.688458,30.4414068 59.6883491,30.4414241 59.6883739,30.4414406 59.6883714,30.4414646 59.6883674,30.4414905 59.688363,30.4417352 59.6883072,30.4417808 59.6882913,30.4418344 59.6882694,30.4418821 59.6882476,30.4419664 59.6882073,30.4431861 59.6875688,30.443383 59.6874657,30.4433566 59.6874537,30.4434022 59.6874298,30.4434203 59.6874209,30.4434378 59.6874131,30.4434606 59.6874073,30.4434998 59.6874019,30.4435553 59.6873939,30.4435961 59.6873824,30.4436284 59.6873671,30.4436444 59.6873558,30.4436589 59.687339,30.4436667 59.6873247,30.4436715 59.6873005,30.4436661 59.68728,30.4436564 59.6872675,30.4436464 59.687259,30.4438843 59.6871016,30.4441866 59.6869058,30.4442598 59.6869111,30.4442951 59.6869136,30.4443323 59.6869292,30.4443347 59.6869302,30.4443923 59.6869614,30.4444065 59.6869691,30.444438 59.6869552,30.4445489 59.6869077,30.444645 59.6868671,30.4446626 59.6868597,30.4446945 59.6868462,30.4446194 59.686801,30.4446175 59.6867999,30.4445818 59.68678,30.4445803 59.686779,30.4445518 59.6867606,30.4445169 59.686738,30.4444952 59.6867243,30.4444865 59.6867138,30.4444865 59.6867017,30.4444952 59.6866905,30.4445375 59.6866638,30.444687 59.6865741,30.4448347 59.6864855,30.445096 59.6863422,30.4452308 59.6862691,30.4453607 59.6861984,30.4456533 59.6860464,30.4458048 59.6859713,30.4459528 59.6859038,30.4463406 59.6857168,30.446723 59.6855342,30.447509 59.6851751,30.4477152 59.6850805,30.4478346 59.6850209,30.447946 59.6849604,30.4480438 59.684899,30.4481859 59.6848002,30.4483241 59.6846939,30.4484287 59.68461,30.4484662 59.6845826,30.4485046 59.6845589,30.4486084 59.6844949,30.4486791 59.6844562,30.4488525 59.6843737,30.4490602 59.6842836,30.449236 59.6842106,30.4493951 59.6841491,30.4494519 59.6841382,30.4495136 59.6841273,30.4496558 59.6841097,30.4498549 59.6840882,30.4498949 59.6840845,30.450264 59.6840506,30.4503834 59.6840449,30.4504672 59.684042,30.4505671 59.6840395,30.4506691 59.6840402,30.4507093 59.6840439,30.4507582 59.6840576,30.4508011 59.6840678,30.4508456 59.6840745,30.4510132 59.6840377,30.4511147 59.6840765,30.4511813 59.6841019,30.4512523 59.684129,30.4513511 59.6841667,30.4513385 59.6842533,30.4516531 59.6843525,30.4522364 59.6845601,30.4525041 59.6846527,30.4525184 59.6846577,30.4525251 59.684634,30.4525331 59.6846279,30.4525466 59.6846232,30.4525626 59.6846222,30.4525841 59.6846239,30.4527677 59.6846399,30.4528579 59.6846477,30.45286 59.6846392,30.4528639 59.6846231,30.4530942 59.6846416,30.4530887 59.6846582,30.4530859 59.6846667,30.4535555 59.6847085,30.4535698 59.6847103,30.4535807 59.6847121,30.4535886 59.6847164,30.4535925 59.6847224,30.4535923 59.6847296,30.4535863 59.6847456,30.4535811 59.6847595,30.4535894 59.6847601,30.4536067 59.6847614,30.4536193 59.6847624,30.4536402 59.684764,30.4536417 59.6847593,30.4536451 59.6847596,30.4538117 59.6847727,30.4538368 59.6847747,30.4538611 59.6847766,30.4540318 59.6847901,30.4540295 59.6847972,30.4540811 59.684801,30.454116 59.6848031,30.4541545 59.6848057,30.4541808 59.6848075,30.4542309 59.6848107,30.4542641 59.6848127,30.4548047 59.6848466,30.4554062 59.6848883,30.4554276 59.6847972,30.4555787 59.6847942,30.4556183 59.6848013,30.45566 59.6848082,30.4556602 59.6848033,30.4557245 59.6848039,30.4557241 59.6848115,30.4558924 59.6848132,30.4558927 59.6848058,30.4559591 59.6848066,30.455968 59.6848067,30.456132 59.6848104,30.4563276 59.6848162,30.4565276 59.684828,30.4567174 59.6848433,30.4568173 59.684855,30.4569112 59.6848679,30.4569916 59.6848814,30.4570788 59.684897,30.4572191 59.6849255,30.4573068 59.6849471,30.4574034 59.6849722,30.4575415 59.6850067,30.4576796 59.6850473,30.4580243 59.6851495,30.458385 59.6852544,30.4585262 59.6852893,30.4586586 59.685316,30.4588062 59.6853451,30.4589376 59.6853682,30.4590725 59.6853866,30.4592621 59.685404,30.4596014 59.6854347,30.4597372 59.6854816,30.4597703 59.6854795,30.4598067 59.6854769,30.4598237 59.6854755,30.4598214 59.6854687,30.4598497 59.6854668,30.4598516 59.685473,30.4598851 59.6854707,30.4599237 59.6854678,30.4599217 59.6854614,30.4599499 59.6854595,30.4599522 59.6854659,30.4599714 59.6854643,30.4600087 59.6854612,30.4600147 59.6854607,30.4600534 59.6854572,30.4601985 59.6854128,30.4638062 59.6851903,30.4654915 59.6850838,30.4656498 59.6850784,30.4657732 59.6850771,30.4659129 59.6850764,30.4672032 59.6851174,30.4675083 59.6851283,30.4688128 59.6851701,30.4688678 59.6851408,30.4688852 59.6851413,30.4688871 59.6851311,30.4689262 59.6851323,30.4689682 59.6851335,30.468967 59.6851443,30.4689863 59.685145,30.4690455 59.6851751,30.4692529 59.685186,30.4712661 59.6852555,30.4717998 59.6852713,30.4721192 59.6852787,30.4728281 59.6852957,30.4729388 59.6852984,30.4730017 59.6852996,30.4730645 59.6853009,30.4731491 59.685303,30.4731729 59.6853036,30.4731946 59.6853042,30.4732094 59.6853046,30.473248 59.6853064,30.4732627 59.685307,30.4733131 59.6853083,30.4735532 59.6853155,30.4738186 59.6853234,30.4747194 59.6853502,30.4760058 59.6853884,30.4760711 59.6853899,30.4767032 59.6854063,30.4769946 59.6854145,30.4770841 59.685417,30.4772286 59.6854211,30.477324 59.6854237,30.4775836 59.6854311,30.4776272 59.6854323,30.4777058 59.6854345,30.477722 59.6854131,30.4778064 59.6854131,30.4778267 59.6854376,30.4782629 59.6854511,30.4803314 59.6855148,30.4804972 59.6855157,30.4806957 59.6855035,30.4809866 59.6854778,30.4813563 59.6854413,30.4816887 59.6854084,30.4829592 59.6852829,30.484201 59.6851595,30.4851027 59.68507,30.4856157 59.685019,30.4859321 59.6849876,30.4860003 59.6849808,30.4860486 59.6850662,30.4861646 59.6852711,30.4863078 59.6855173,30.4864369 59.6857523,30.4864761 59.6858216,30.4866222 59.6860742,30.486646 59.6861155,30.4870343 59.686796,30.4871407 59.6869901,30.4872588 59.6872054,30.4877195 59.6880454,30.487808 59.688202,30.4878204 59.6882235,30.4878635 59.6883002,30.48787 59.6883117,30.4878916 59.6883487,30.4879075 59.6883812,30.4879153 59.6883977,30.4879246 59.6884174,30.4879765 59.6885128,30.4880116 59.6885763,30.4880581 59.6885694,30.4881086 59.6885618,30.4881355 59.6885578,30.4882292 59.6885456,30.4888791 59.6896373,30.489701 59.6924953,30.4896786 59.6925163,30.4908925 59.6968416,30.4908907 59.6969219,30.4908693 59.696978,30.4908278 59.6970308,30.488341 59.6991065,30.4878952 59.6994664,30.4876552 59.6996701,30.4838245 59.7028735,30.4794807 59.706361,30.479376 59.7064476,30.4793425 59.7064936,30.479321 59.7065348,30.4793143 59.7065707,30.479136 59.7066397,30.4791105 59.7067926,30.4790216 59.7067947,30.478967 59.7068115,30.4789214 59.706846,30.4788959 59.7068683,30.4788395 59.706903,30.4787806 59.7069259,30.4787363 59.7069386,30.4786216 59.7069479,30.4779183 59.7069596,30.4736783 59.7070303,30.473675 59.7069867,30.4736739 59.7069694,30.4736706 59.7069389,30.4732464 59.7069452,30.4729689 59.7069493,30.4697965 59.7069962,30.4687773 59.7070136,30.4663413 59.7070601,30.4662337 59.7070622,30.4660736 59.7070633,30.4660557 59.707042,30.4660408 59.7070243,30.4659974 59.7069726,30.4659835 59.7069561,30.4659791 59.7069508,30.4659686 59.7069384,30.4659531 59.70692,30.4658816 59.7068348,30.4656818 59.7065821,30.4655355 59.7065546,30.4652621 59.7065033,30.4651239 59.7064784,30.4650726 59.706474,30.4650016 59.7064692,30.4645828 59.706441,30.4644927 59.7064349,30.4640497 59.7064008,30.4639779 59.7064033,30.4639163 59.7064329,30.4638698 59.7064308,30.4638303 59.7064291,30.4637599 59.7064255,30.4637148 59.7064233,30.4636972 59.706296,30.463669 59.7061547,30.4636421 59.7061131,30.4636191 59.7060776,30.4635652 59.7060291,30.4635492 59.7060147,30.4633455 59.7058911,30.4631782 59.7058035,30.4630326 59.7057228,30.4628485 59.7056506,30.4625988 59.7055749,30.4623338 59.7055117,30.462411 59.7054206,30.4625908 59.7051744,30.4627383 59.705012,30.4627387 59.7049841,30.4628295 59.7048848,30.4629347 59.7048106,30.4631495 59.7046592,30.4632413 59.7045664,30.4632815 59.7037822,30.4635147 59.7033885,30.4635704 59.7031913,30.4635837 59.7031547,30.4637313 59.7028432,30.4638334 59.7024501,30.4638456 59.7023972,30.463836 59.7023848,30.4637361 59.7022574,30.4636905 59.7022019,30.4635064 59.7019706,30.4635161 59.7019493,30.4636111 59.701924,30.463635 59.7019182,30.4637511 59.70189,30.4637308 59.7018637,30.4637092 59.7018342,30.4636851 59.701795,30.4636516 59.7017429,30.4636207 59.7016942,30.4635699 59.7016225,30.4635353 59.7015738,30.4635222 59.7014983,30.4635136 59.701428,30.4635319 59.7013361,30.463663 59.7011745,30.4636393 59.7011294,30.4635985 59.701113,30.4635901 59.7011096,30.4634909 59.7010692,30.4633415 59.7009065,30.4632475 59.7008008,30.4633339 59.7007478,30.463267 59.7007226,30.4631688 59.7006856,30.462726 59.7005187,30.4627839 59.700477,30.4629277 59.700364,30.4628712 59.7003463,30.4628406 59.7003375,30.4628018 59.700329,30.4627324 59.7003133,30.4625437 59.700281,30.4624003 59.7002577,30.4623277 59.7002393,30.4622533 59.7002132,30.462183 59.7001817,30.4620452 59.7000972,30.4619642 59.7000527,30.4618883 59.7000085,30.4617881 59.6999591,30.4616936 59.6999188,30.4615834 59.6998886,30.4615415 59.6998816,30.4614913 59.6998733,30.4614085 59.6998641,30.4612464 59.6998574,30.4611217 59.6998541,30.4608263 59.6998478,30.4607558 59.6996967,30.4607155 59.6996206,30.46063 59.6994896,30.4606032 59.6994485,30.4605319 59.6993425,30.4604507 59.6993266,30.4602215 59.6992772,30.4595558 59.699131,30.4592776 59.699072,30.4575016 59.6986865,30.4562393 59.6984033,30.4559187 59.6983348,30.4558203 59.6983605,30.4557987 59.6983662,30.4557686 59.6983735,30.4549679 59.6985899,30.4541981 59.6988205,30.453899 59.6989058,30.4537918 59.6989356,30.4536794 59.6989629,30.4535557 59.6989856,30.4534511 59.6989991,30.4533251 59.6990121,30.4532188 59.6990257,30.4531097 59.6990384,30.4530898 59.6990411,30.4530456 59.6990471,30.4529483 59.6990428,30.452721 59.6990256,30.4526039 59.6990156,30.4523895 59.6989984,30.4522106 59.6989843,30.4520626 59.698971,30.4518814 59.6989585,30.4516574 59.6989473,30.4515079 59.6989512,30.4513576 59.6989647,30.4511257 59.6989833,30.4507033 59.6990189,30.4498045 59.699093,30.4495902 59.6991095,30.449288 59.6991349,30.4489705 59.699163,30.4487787 59.6991832,30.4486594 59.6992042,30.4485816 59.6992218,30.4483804 59.6992665,30.4483134 59.6992807,30.4482261 59.6992991,30.4480734 59.6993207,30.4478922 59.6993369,30.4476348 59.6993534,30.4474175 59.6993579,30.4472213 59.6993549,30.4470849 59.6993484,30.4469099 59.6993315,30.4465807 59.6992943,30.4463005 59.699266,30.4460455 59.6992334,30.445784 59.6991949,30.4455453 59.6991481,30.4453367 59.6991061,30.4450934 59.6990399,30.4448113 59.6989579,30.4445865 59.6988843,30.4443921 59.6988221,30.4441572 59.6987421,30.4439038 59.6986557,30.4434519 59.6984884,30.4429811 59.6983056,30.4420431 59.6979399,30.4418559 59.6978726,30.4416695 59.6977994,30.441534 59.6977474,30.4414482 59.6977149,30.4413649 59.6976776,30.4412699 59.6976303,30.4411831 59.6975862,30.4411089 59.6975484,30.4410289 59.697504,30.4409815 59.6974727,30.4409212 59.6974328,30.4408374 59.6973571,30.4405993 59.6971268,30.4404411 59.6969686,30.4402828 59.6968116,30.4397464 59.6962404,30.4395909 59.6960983,30.439434 59.6959641,30.4393118 59.695876,30.4392419 59.6958321,30.439177 59.6957928,30.4390738 59.6957339,30.4388879 59.6956351,30.4385161 59.6954393,30.4384468 59.695404,30.438361 59.6953709,30.4382459 59.6953424,30.4380981 59.695312,30.4379144 59.6952822,30.4375067 59.6952213,30.4372801 59.6951739,30.4371808 59.695153,30.4370661 59.695126,30.4369099 59.6950805,30.4367611 59.6950291,30.4366176 59.6949682,30.4364949 59.6948934,30.4362637 59.6947112,30.4359055 59.6944268,30.4355501 59.6941622,30.4351531 59.6938841,30.4347532 59.6936305,30.4346998 59.6935975,30.4346849 59.693577,30.4346174 59.6935301,30.4346147 59.6935224,30.4346086 59.6935129,30.4345932 59.6935014,30.4344744 59.6934215,30.4344752 59.6934118,30.4344684 59.6934032,30.4343048 59.693294,30.4335858 59.6928433,30.4335672 59.6928378,30.4335491 59.692831,30.4335344 59.6928246,30.4335169 59.6928158,30.4334908 59.6928019,30.4334747 59.6927935,30.4334378 59.6927735,30.4334063 59.6927569,30.4333486 59.6927221,30.4332896 59.6926848,30.4333366 59.6926751,30.4332748 59.6926368,30.4332052 59.6925918,30.4331186 59.6925354,30.4330442 59.6924832,30.4329739 59.6924321,30.432891 59.6923692,30.4328383 59.6923262,30.432786 59.6922862,30.4327464 59.6922518,30.4327224 59.6922281,30.4327002 59.692202,30.4326801 59.6921654,30.4326563 59.6921265,30.4326325 59.6920866,30.4326077 59.6920372,30.4325876 59.6920054,30.4325715 59.6919759,30.4325473 59.691936,30.4325252 59.6918893,30.4325105 59.6918548,30.4324944 59.6918145,30.4324776 59.6917472,30.4324681 59.6916959,30.4324608 59.6916494,30.4324568 59.6916037)),((30.4459925 59.6840515,30.4465029 59.6838166,30.4469327 59.6836721,30.4472874 59.6834226,30.4479163 59.6832392,30.4483415 59.6832476,30.4484247 59.6832514,30.4484595 59.6832547,30.4484884 59.6832585,30.4485108 59.6832641,30.4489705 59.6834352,30.4489993 59.6834563,30.4490069 59.6834636,30.4492468 59.6836887,30.4491255 59.6840718,30.4490543 59.6840686,30.4483928 59.684035,30.4478277 59.6840459,30.4469355 59.6841321,30.4462744 59.6842068,30.4459925 59.6840515)))', 'relation', 17990902, '{"name": "Государственный музей-заповедник «Павловск»", "note": "граница имущественного комплекса организации, не граница парка", "boundary": "protected_area", "operator": "Государственный музей-заповедник «Павловск»", "wikidata": "Q405637"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4524973 59.6846698,30.4525041 59.6846527,30.4525156 59.684624,30.4525454 59.684611,30.4525859 59.6846153,30.45286 59.6846392,30.4528639 59.6846231,30.4530942 59.6846416,30.4530887 59.6846582,30.4535793 59.6847014,30.4536048 59.6847154,30.4535894 59.6847601,30.4535811 59.6847595,30.4534913 59.6847521,30.4529615 59.6847082,30.4525675 59.6846756,30.4524973 59.6846698)))', 'relation', 17786995, '{"landuse": "construction", "start_date": "06.204", "description": "реставрация Павильона Трех граций"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4522477 59.6858088,30.4522705 59.6857319,30.4523217 59.6855588,30.452346 59.6854768,30.452497 59.6854882,30.4525787 59.6854944,30.4527091 59.6855042,30.4528709 59.6855164,30.4529043 59.6855189,30.4529835 59.685525,30.4530542 59.6855302,30.4530286 59.6856166,30.4529796 59.6857822,30.4529559 59.6858622,30.4528897 59.6858572,30.4528205 59.685852,30.4526832 59.6858416,30.4526091 59.6858361,30.4525803 59.6858339,30.4522804 59.6858113,30.4522477 59.6858088)))', 'relation', 6636658, '{"height": "19.650", "architect": "Чарльз Камерон", "roof:shape": "pyramidal", "start_date": "1782", "roof:colour": "#DADDE2", "roof:height": "2.45", "building:part": "yes", "building:colour": "#FFE19C", "source:building:part": "http://pancer.ru/images/project/012/2.jpg"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4528788 59.6854915,30.4528865 59.6854815,30.4528993 59.6854656,30.452909 59.6854545,30.4529242 59.6854401,30.4530216 59.6854636,30.4530899 59.6854797,30.4530765 59.6854926,30.4530668 59.6855046,30.453064 59.6855044,30.4529942 59.6854993,30.4529122 59.6854936,30.4528788 59.6854915)))', 'relation', 6636659, '{"height": "13", "min_height": "10", "roof:shape": "gabled", "roof:colour": "#DADDE2", "roof:height": "2", "building:part": "yes", "roof:material": "metal", "building:colour": "#FFE19C", "roof:orientation": "across"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4528709 59.6855164,30.4528746 59.6855048,30.4528788 59.6854915,30.4529122 59.6854936,30.4529942 59.6854993,30.4529881 59.6855114,30.4529835 59.685525,30.4529043 59.6855189,30.4528709 59.6855164)))', 'relation', 14572596, '{"height": "6.65", "roof:shape": "flat", "roof:colour": "gray", "building:part": "yes", "building:colour": "#FFE19C"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4533818 59.6852214,30.453417 59.6852162,30.4534578 59.6852115,30.4535038 59.6852069,30.4535289 59.6853164,30.4535075 59.6853177,30.4534847 59.6853198,30.4534688 59.6853212,30.4534368 59.6853262,30.453436 59.6853248,30.4534146 59.6852887,30.4533878 59.6852355,30.4533818 59.6852214)))', 'relation', 17755881, '{"height": "13", "roof:shape": "gabled", "roof:colour": "#DADDE2", "roof:height": "2", "building:part": "yes", "roof:material": "metal", "building:colour": "#FFE19C", "roof:orientation": "across"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4532684 59.6852465,30.453297 59.6852393,30.4533302 59.6852316,30.4533524 59.685227,30.4533818 59.6852214,30.4533878 59.6852355,30.4534146 59.6852887,30.453436 59.6853248,30.4534368 59.6853262,30.4533983 59.6853338,30.4533609 59.6853429,30.4533268 59.6853074,30.4532684 59.6852465)))', 'relation', 17755882, '{"height": "13", "min_height": "10", "roof:shape": "gabled", "roof:colour": "#DADDE2", "roof:height": "2", "building:part": "yes", "roof:material": "metal", "building:colour": "#FFE19C", "roof:orientation": "across"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4528788 59.6854915,30.4528865 59.6854815,30.4528993 59.6854656,30.452909 59.6854545,30.4529242 59.6854401,30.4529045 59.6854337,30.4529147 59.685423,30.4529312 59.685409,30.4529542 59.6853912,30.4529724 59.685378,30.4530012 59.685359,30.4530217 59.6853466,30.4530456 59.6853334,30.4530682 59.6853211,30.4530897 59.6853096,30.4531138 59.6852988,30.4531357 59.6852905,30.453156 59.6852825,30.4531809 59.6852727,30.4532391 59.6852543,30.4532684 59.6852465,30.453297 59.6852393,30.4533302 59.6852316,30.4533524 59.685227,30.4533818 59.6852214,30.4533878 59.6852355,30.4534146 59.6852887,30.4533836 59.6852944,30.4533532 59.6853009,30.4533268 59.6853074,30.4532946 59.6853162,30.4532665 59.6853249,30.4532343 59.6853363,30.4532132 59.6853445,30.4531881 59.6853553,30.453164 59.6853668,30.4531411 59.6853788,30.4531158 59.6853933,30.4530954 59.6854062,30.4530746 59.6854199,30.4530552 59.6854344,30.4530382 59.6854491,30.4530216 59.6854636,30.4530079 59.6854761,30.4530004 59.6854886,30.4529942 59.6854993,30.4529122 59.6854936,30.4528788 59.6854915)))', 'relation', 17904735, '{"height": "10", "roof:shape": "flat", "building:part": "yes", "building:colour": "#FFE19C"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4522278 59.6851794,30.4526025 59.6847092,30.4524973 59.6846698,30.4525184 59.6846577,30.4525251 59.684634,30.4525331 59.6846279,30.4525466 59.6846232,30.4525626 59.6846222,30.4525841 59.6846239,30.4527677 59.6846399,30.4528579 59.6846477,30.4528469 59.6846817,30.452843 59.684694,30.4529628 59.6847041,30.4530706 59.6847131,30.4530752 59.684699,30.4530859 59.6846667,30.4535555 59.6847085,30.4535698 59.6847103,30.4535807 59.6847121,30.4535886 59.6847164,30.4535925 59.6847224,30.4535923 59.6847296,30.4535863 59.6847456,30.4535811 59.6847595,30.4535894 59.6847601,30.4536067 59.6847614,30.4536193 59.6847624,30.4536402 59.684764,30.4535302 59.6851198,30.4535229 59.6851437,30.4535137 59.6851734,30.4535124 59.6851786,30.4535038 59.6852069,30.4534979 59.6851951,30.4534914 59.6851874,30.4534811 59.6851808,30.4534678 59.6851758,30.4534524 59.6851728,30.453436 59.6851719,30.4534196 59.6851732,30.4534028 59.6851772,30.4533891 59.6851835,30.4533796 59.6851915,30.4533752 59.6852006,30.4533763 59.68521,30.4533818 59.6852214,30.4533524 59.685227,30.4533302 59.6852316,30.453297 59.6852393,30.4532684 59.6852465,30.4532391 59.6852543,30.4531809 59.6852727,30.453156 59.6852825,30.4531357 59.6852905,30.453128 59.6852882,30.4531198 59.6852866,30.4531113 59.6852855,30.4531024 59.685285,30.4530936 59.6852852,30.4530849 59.6852859,30.4530765 59.6852873,30.4530685 59.6852893,30.4530612 59.6852918,30.4530559 59.6852942,30.4530511 59.6852969,30.453047 59.6852998,30.4530436 59.6853029,30.4530408 59.6853062,30.4530389 59.6853097,30.4530377 59.6853132,30.4530373 59.6853168,30.4530377 59.6853204,30.4530387 59.6853245,30.4530402 59.6853274,30.4530424 59.6853304,30.4530456 59.6853334,30.4530217 59.6853466,30.4530053 59.6853403,30.4529809 59.6853554,30.4529707 59.6853538,30.4529621 59.6853543,30.452955 59.6853567,30.4529297 59.6853727,30.4529266 59.6853774,30.4529284 59.6853815,30.4529349 59.6853856,30.4529136 59.685403,30.4529312 59.685409,30.4529147 59.685423,30.4529045 59.6854337,30.4529242 59.6854401,30.452909 59.6854545,30.4528993 59.6854656,30.4528865 59.6854815,30.4528788 59.6854915,30.4528746 59.6855048,30.4527686 59.6854977,30.452777 59.6854654,30.4527565 59.685464,30.4527224 59.6854618,30.4526841 59.6854592,30.4526646 59.6854579,30.4526564 59.6854895,30.4525812 59.6854845,30.4525787 59.6854944,30.452497 59.6854882,30.4524943 59.6854502,30.4524845 59.6854195,30.4524735 59.685401,30.4524616 59.6853789,30.4524395 59.6853504,30.4524088 59.6853175,30.4523836 59.685295,30.4523534 59.6852701,30.4523333 59.6852571,30.452307 59.6852409,30.4522692 59.6852184,30.4522695 59.6851929,30.4522474 59.6851858,30.4522278 59.6851794)))', 'relation', 4274530, '{"fee": "yes", "ref": "IIIа", "name": "Собственный сад", "leisure": "garden", "name:fr": "Jardin privé", "ref:okn": "781620399040366", "tourism": "attraction", "alt_name": "Собственный садик", "boundary": "protected_area", "heritage": "2", "wikidata": "Q118122043", "start_date": "1803", "garden:style": "french", "opening_hours": "Mo-Su 09:00-21:00; May 08 - Aug 31", "heritage:website": "https://kgiop.gov.spb.ru/deyatelnost/uchet/list_objects/6518/"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4521745 59.6857248,30.4521808 59.6857036,30.4522002 59.685638,30.4522191 59.6855742,30.4522258 59.6855515,30.4522802 59.6855556,30.4523217 59.6855588,30.452346 59.6854768,30.452497 59.6854882,30.4525787 59.6854944,30.4525812 59.6854845,30.4526564 59.6854895,30.4526646 59.6854579,30.4526841 59.6854592,30.4527224 59.6854618,30.4527565 59.685464,30.452777 59.6854654,30.4527686 59.6854977,30.4528746 59.6855048,30.4528788 59.6854915,30.4528865 59.6854815,30.4528993 59.6854656,30.452909 59.6854545,30.4529242 59.6854401,30.4529045 59.6854337,30.4529147 59.685423,30.4529312 59.685409,30.4529136 59.685403,30.4529349 59.6853856,30.4529284 59.6853815,30.4529266 59.6853774,30.4529297 59.6853727,30.452955 59.6853567,30.4529621 59.6853543,30.4529707 59.6853538,30.4529809 59.6853554,30.4530053 59.6853403,30.4530217 59.6853466,30.4530456 59.6853334,30.4530424 59.6853304,30.4530402 59.6853274,30.4530387 59.6853245,30.4530377 59.6853204,30.4530373 59.6853168,30.4530377 59.6853132,30.4530389 59.6853097,30.4530408 59.6853062,30.4530436 59.6853029,30.453047 59.6852998,30.4530511 59.6852969,30.4530559 59.6852942,30.4530612 59.6852918,30.4530685 59.6852893,30.4530765 59.6852873,30.4530849 59.6852859,30.4530936 59.6852852,30.4531024 59.685285,30.4531113 59.6852855,30.4531198 59.6852866,30.453128 59.6852882,30.4531357 59.6852905,30.453156 59.6852825,30.4531809 59.6852727,30.4532391 59.6852543,30.4532684 59.6852465,30.453297 59.6852393,30.4533302 59.6852316,30.4533524 59.685227,30.4533818 59.6852214,30.4533763 59.68521,30.4533752 59.6852006,30.4533796 59.6851915,30.4533891 59.6851835,30.4534028 59.6851772,30.4534196 59.6851732,30.453436 59.6851719,30.4534524 59.6851728,30.4534678 59.6851758,30.4534811 59.6851808,30.4534914 59.6851874,30.4534979 59.6851951,30.4535038 59.6852069,30.4535124 59.6851786,30.4535137 59.6851734,30.4535229 59.6851437,30.4535302 59.6851198,30.4536402 59.684764,30.4536417 59.6847593,30.4536451 59.6847596,30.4538117 59.6847727,30.4538368 59.6847747,30.4538611 59.6847766,30.4540318 59.6847901,30.4540295 59.6847972,30.4540145 59.684846,30.4540088 59.6848638,30.4540229 59.6848667,30.4540358 59.6848708,30.454047 59.6848759,30.4540561 59.6848821,30.454063 59.6848889,30.4540674 59.6848962,30.4540691 59.6849039,30.454068 59.6849115,30.4540643 59.6849189,30.454058 59.6849259,30.4540493 59.6849322,30.4540386 59.6849376,30.4540261 59.684942,30.4540122 59.6849452,30.4539975 59.684947,30.4539823 59.6849475,30.4539763 59.6849646,30.453965 59.6849637,30.4539277 59.6849606,30.4538688 59.6849558,30.4538059 59.6849506,30.4537818 59.6849487,30.4537579 59.6849467,30.4537377 59.6850123,30.4537178 59.6850766,30.4537483 59.6850789,30.4538612 59.6850876,30.4539247 59.6850925,30.4539406 59.6850424,30.4539786 59.6850519,30.4540221 59.685063,30.4540417 59.6850686,30.4540646 59.6850751,30.4541059 59.6850881,30.4541472 59.6851025,30.4541871 59.685118,30.4542254 59.6851343,30.4542622 59.6851516,30.4542942 59.6851377,30.4544115 59.6852076,30.4543838 59.6852203,30.4544141 59.6852392,30.4544426 59.6852588,30.4544691 59.6852791,30.4544972 59.6853031,30.4545225 59.6853279,30.4545451 59.6853534,30.4545829 59.6853462,30.4546442 59.6854282,30.4546081 59.6854351,30.4546263 59.6854611,30.4546407 59.6854917,30.4546513 59.6855211,30.4546577 59.6855509,30.4545667 59.6855569,30.4545695 59.6855677,30.4545502 59.6855689,30.4545521 59.6855762,30.454475 59.6855814,30.454473 59.685574,30.4544524 59.6855754,30.4544496 59.6855646,30.4544349 59.6855656,30.4543687 59.68557,30.4543619 59.6855441,30.4543522 59.6855184,30.4543439 59.6854971,30.4543247 59.685468,30.454307 59.6854434,30.4542866 59.6854194,30.4542636 59.6853959,30.4542381 59.6853732,30.4542062 59.685347,30.4541753 59.6853248,30.4541426 59.6853062,30.4541083 59.6852876,30.4540689 59.6852681,30.4540273 59.6852498,30.4539837 59.6852328,30.4539382 59.685217,30.4538908 59.6852026,30.4538877 59.6852126,30.4539316 59.6852158,30.4539299 59.6852218,30.4539248 59.68524,30.453923 59.6852463,30.4538783 59.6852431,30.4538761 59.6852503,30.4538454 59.6853506,30.4536997 59.6853392,30.4536921 59.6853643,30.4536766 59.6853631,30.453626 59.6853592,30.4536111 59.6853581,30.4536187 59.6853329,30.4534688 59.6853212,30.4534368 59.6853262,30.4533983 59.6853338,30.4533609 59.6853429,30.4533196 59.6853548,30.4532989 59.6853612,30.4532797 59.6853674,30.4532663 59.6853726,30.4532524 59.6853786,30.4532824 59.685393,30.4532679 59.6854007,30.4532019 59.6854356,30.4531881 59.6854429,30.4531582 59.6854285,30.453148 59.6854347,30.4531265 59.6854489,30.4531071 59.6854639,30.4530899 59.6854797,30.4530765 59.6854926,30.4530668 59.6855046,30.45306 59.6855156,30.4530542 59.6855302,30.4530286 59.6856166,30.4530752 59.6856201,30.4531272 59.685624,30.4531226 59.6856395,30.4531 59.6857159,30.4530826 59.6857747,30.4530781 59.6857896,30.4530261 59.6857857,30.4529796 59.6857822,30.4529559 59.6858622,30.4529512 59.6858765,30.4529486 59.6858896,30.4529478 59.6859011,30.4529482 59.6859112,30.452952 59.685926,30.4529569 59.6859385,30.4529638 59.6859523,30.4529718 59.6859649,30.4529791 59.6859757,30.4529856 59.6859841,30.4530246 59.6859742,30.4530338 59.6859834,30.4530767 59.6860278,30.4530861 59.6860371,30.4530482 59.6860471,30.4530568 59.6860536,30.4530663 59.6860602,30.4530779 59.6860674,30.4530898 59.6860742,30.4531018 59.6860809,30.4531136 59.6860871,30.4531293 59.6860946,30.453148 59.6861029,30.4531695 59.6861116,30.4532167 59.6861306,30.4533686 59.6861421,30.453376 59.6861189,30.4533898 59.68612,30.4534436 59.6861244,30.453457 59.6861255,30.4534496 59.6861487,30.4536027 59.6861615,30.4535556 59.6863114,30.4535958 59.6863065,30.4536563 59.6862959,30.4537014 59.6862868,30.4537731 59.6862682,30.4538342 59.6862493,30.453879 59.6862345,30.4539364 59.686214,30.4539768 59.686198,30.45402 59.6861768,30.4540703 59.686148,30.4541119 59.6861223,30.4541469 59.6860952,30.4541742 59.6860729,30.4541995 59.6860505,30.4542215 59.6860272,30.4542918 59.6860451,30.4543031 59.6860479,30.4543127 59.6860386,30.45433 59.6860429,30.4543365 59.6860363,30.4544062 59.6860538,30.4543997 59.6860604,30.4544185 59.6860651,30.4544086 59.6860746,30.4544964 59.6860973,30.4544728 59.6861239,30.4544395 59.686154,30.4544059 59.686181,30.4543849 59.6861942,30.4544137 59.6862059,30.4542999 59.6862773,30.4542705 59.6862654,30.4542363 59.6862844,30.4541965 59.6863041,30.4541887 59.6863078,30.4542091 59.6863195,30.4542 59.6863235,30.4541696 59.6863371,30.4541607 59.6863411,30.4541407 59.6863296,30.4541297 59.6863344,30.4540887 59.6863495,30.4540549 59.6863624,30.4540219 59.6863729,30.4540399 59.6863883,30.4540005 59.6863999,30.4540172 59.6864141,30.4540057 59.6864176,30.4539576 59.686432,30.4539454 59.6864356,30.4539287 59.6864214,30.4538817 59.6864353,30.453863 59.6864194,30.4538212 59.6864281,30.4537814 59.6864354,30.4537376 59.6864434,30.4536952 59.6864492,30.4536556 59.6864553,30.4536188 59.68646,30.4535812 59.6864636,30.453575 59.6864544,30.4534768 59.6864467,30.4533659 59.6864383,30.4533611 59.6864525,30.4533485 59.6864515,30.4533248 59.6864494,30.4532998 59.6864473,30.4532869 59.6864462,30.4532916 59.686432,30.4532725 59.6864305,30.4532826 59.6863983,30.4531363 59.6863866,30.453138 59.686381,30.4531642 59.6862975,30.4531215 59.686294,30.4531372 59.6862455,30.4531795 59.686249,30.453196 59.6861992,30.4531704 59.6862175,30.4531608 59.6862141,30.453137 59.6862056,30.4531278 59.6862023,30.4531534 59.686184,30.4530963 59.6861616,30.4530418 59.6861992,30.4530167 59.6861897,30.4529804 59.6861727,30.4529497 59.6861561,30.4529175 59.6861373,30.4528879 59.6861175,30.4528659 59.6861008,30.4528406 59.6860793,30.4528174 59.6860572,30.4527956 59.6860336,30.4527791 59.6860133,30.4527643 59.6859927,30.4527472 59.6859643,30.4527383 59.6859422,30.4527314 59.6859191,30.4527279 59.6859036,30.4528174 59.6858982,30.4528205 59.685852,30.4526832 59.6858416,30.4526091 59.6858361,30.4525803 59.6858339,30.4522804 59.6858113,30.4522477 59.6858088,30.4522705 59.6857319,30.4522289 59.6857289,30.4521745 59.6857248)))', 'relation', 1759666, '{"name": "Павловский дворец", "name:ca": "Palau Pàvlovsk", "name:en": "Pavlovsk Palace", "name:fi": "Pavlovskin_palatsi", "name:fr": "Palais de Pavlovsk", "name:pt": "Palácio de Pavlovsk", "name:uz": "Pavlovsk saroyi", "name:zh": "巴甫洛夫斯克的宫殿", "ref:okn": "781610399040316", "tourism": "museum", "building": "palace", "historic": "yes", "int_name": "Palais de Pavlovsk", "wikidata": "Q118121947", "wikipedia": "ru:Павловский дворец", "start_date": "1782", "addr:street": "Садовая улица", "roof:colour": "#DADDE2", "building:colour": "#FFE19C", "addr:housenumber": "20 литА"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4534688 59.6853212,30.4534995 59.6852209,30.4535038 59.6852069,30.4535124 59.6851786,30.4535137 59.6851734,30.4535229 59.6851437,30.4535302 59.6851198,30.4536141 59.6851263,30.4537003 59.685133,30.4539076 59.685149,30.4538908 59.6852026,30.4538877 59.6852126,30.4538783 59.6852431,30.4538761 59.6852503,30.4538454 59.6853506,30.4536997 59.6853392,30.4536666 59.6853366,30.4536187 59.6853329,30.4534688 59.6853212)))', 'relation', 6636665, '{"name": "Южный корпус", "height": "15", "roof:shape": "pyramidal", "start_date": "1782", "roof:colour": "#DADDE2", "roof:height": "2", "building:part": "yes", "roof:material": "metal", "building:colour": "#FFE19C"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4534995 59.6852209,30.4535038 59.6852069,30.4535124 59.6851786,30.4535137 59.6851734,30.4535229 59.6851437,30.4535302 59.6851198,30.4536141 59.6851263,30.4537003 59.685133,30.4539076 59.685149,30.4538908 59.6852026,30.4538877 59.6852126,30.4538783 59.6852431,30.4538761 59.6852503,30.4534995 59.6852209)))', 'relation', 14572597, '{"height": "15", "roof:shape": "gabled", "start_date": "1782", "roof:colour": "#DADDE2", "roof:height": "2", "building:part": "yes", "roof:material": "metal", "building:colour": "#FFE19C", "roof:orientation": "across"}', NULL),
 ('SRID=4326;MULTIPOLYGON(((30.4535124 59.6851786,30.4535137 59.6851734,30.4535229 59.6851437,30.4535302 59.6851198,30.4536402 59.684764,30.4536417 59.6847593,30.4536451 59.6847596,30.4538117 59.6847727,30.4538368 59.6847747,30.4538611 59.6847766,30.4540318 59.6847901,30.4540295 59.6847972,30.4540145 59.684846,30.4540088 59.6848638,30.4540054 59.6848752,30.4537854 59.6848579,30.4537579 59.6849467,30.4537377 59.6850123,30.4537178 59.6850766,30.4537003 59.685133,30.453682 59.6851921,30.4535124 59.6851786)))', 'relation', 18019154, '{"height": "13", "roof:shape": "hipped", "roof:colour": "#DADDE2", "roof:height": "2", "building:part": "yes", "roof:material": "metal", "building:colour": "#FFE19C"}', NULL);
--Testcase 402:
SELECT count(*) FROM json_osm_test;
--Testcase 403:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT * FROM json_osm_test WHERE t->>'genus' = 'Quercus';
--Testcase 404: オーク / Sồi
SELECT * FROM json_osm_test WHERE t->>'genus' = 'Quercus';
--Testcase 405:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT * FROM json_osm_test WHERE (t->>'height')::float = 15;
--Testcase 406:
SELECT * FROM json_osm_test WHERE (t->>'height')::float = 15;
--Testcase 407:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT * FROM json_osm_test WHERE t->>'leaf_cycle' = 'deciduous';
--Testcase 408: 落葉性 / Cây rụng lá
SELECT * FROM json_osm_test WHERE t->>'leaf_cycle' = 'deciduous';
--Testcase 409:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT * FROM json_osm_test WHERE t->>'leaf_cycle' = 'evergreen';
--Testcase 410: 常緑植物 / Cây thường xanh
SELECT * FROM json_osm_test WHERE t->>'leaf_cycle' = 'evergreen';

--Testcase 411:
EXPLAIN (VERBOSE, COSTS OFF)
SELECT * FROM json_osm_test WHERE t->>'start_date' = 'C18';
--Testcase 412: XVIII cent.
SELECT * FROM json_osm_test WHERE t->>'start_date' = 'C18';

--Testcase 413:
DELETE FROM json_osm_test;

--Testcase 500:
DROP EXTENSION sqlite_fdw CASCADE;
