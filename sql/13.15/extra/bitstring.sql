--SET log_min_messages  TO DEBUG1;
--SET client_min_messages  TO DEBUG1;
--Testcase 001:
CREATE EXTENSION sqlite_fdw;
--Testcase 002:
CREATE SERVER sqlite_svr FOREIGN DATA WRAPPER sqlite_fdw
OPTIONS (database '/tmp/sqlite_fdw_test/common.db');

--Testcase 003:
CREATE SERVER sqlite2 FOREIGN DATA WRAPPER sqlite_fdw;

--Testcase 02:
CREATE FOREIGN TABLE "type_BIT"( "i" int OPTIONS (key 'true'), "b" bit(6)) SERVER sqlite_svr OPTIONS (table 'type_BIT');
--Testcase 03:
DROP FOREIGN TABLE IF EXISTS "type_BIT+";
--Testcase 04:
CREATE FOREIGN TABLE "type_BIT+"( "i" int OPTIONS (key 'true'), "b" bit(6), "t" text, "l" smallint, "bi" bigint OPTIONS (column_name 'b')) SERVER sqlite_svr OPTIONS (table 'type_BIT+');
--Testcase 05: type mismatch
INSERT INTO "type_BIT" ("i", "b") VALUES (1, 1);
--Testcase 06: type mismatch
INSERT INTO "type_BIT" ("i", "b") VALUES (2, 2);
--Testcase 07: improper data length
INSERT INTO "type_BIT" ("i", "b") VALUES (3, '1');
--Testcase 08: improper data length
INSERT INTO "type_BIT" ("i", "b") VALUES (4, '10');
--Testcase 09: improper data length
INSERT INTO "type_BIT" ("i", "b") VALUES (5, '101');
--Testcase 10:
INSERT INTO "type_BIT" ("i", "b") VALUES (6, '110110');
--Testcase 11:
INSERT INTO "type_BIT" ("i", "b") VALUES (7, '111001');
--Testcase 12:
INSERT INTO "type_BIT" ("i", "b") VALUES (8, '110000');
--Testcase 13:
INSERT INTO "type_BIT" ("i", "b") VALUES (9, '100001');
--Testcase 14: type mismatch with proper data length
INSERT INTO "type_BIT" ("i", "b") VALUES (10, 53);
--Testcase 15:
SELECT * FROM "type_BIT+";
--Testcase 16:
SELECT * FROM "type_BIT" WHERE b < '110110';
--Testcase 17:
SELECT * FROM "type_BIT" WHERE b > '110110';
--Testcase 18:
SELECT * FROM "type_BIT" WHERE b = '110110';

--Testcase 20:
CREATE FOREIGN TABLE "type_VARBIT"( "i" int OPTIONS (key 'true'), "b" varbit(70)) SERVER sqlite_svr OPTIONS (table 'type_VARBIT');
--Testcase 21:
DROP FOREIGN TABLE IF EXISTS "type_VARBIT+";
--Testcase 22:
CREATE FOREIGN TABLE "type_VARBIT+"( "i" int OPTIONS (key 'true'), "b" varbit(70), "t" text, "l" smallint) SERVER sqlite_svr OPTIONS (table 'type_VARBIT+');
--Testcase 23:
INSERT INTO "type_VARBIT" ("i", "b") VALUES (1, '1');
--Testcase 24:
INSERT INTO "type_VARBIT" ("i", "b") VALUES (2, '10');
--Testcase 25:
INSERT INTO "type_VARBIT" ("i", "b") VALUES (3, '11');
--Testcase 26:
INSERT INTO "type_VARBIT" ("i", "b") VALUES (4, '100');
--Testcase 27:
INSERT INTO "type_VARBIT" ("i", "b") VALUES (5, '101');
--Testcase 28:
INSERT INTO "type_VARBIT" ("i", "b") VALUES (6, '110110');
--Testcase 29:
INSERT INTO "type_VARBIT" ("i", "b") VALUES (7, '111001');
--Testcase 30:
INSERT INTO "type_VARBIT" ("i", "b") VALUES (8, '110000');
--Testcase 31:
INSERT INTO "type_VARBIT" ("i", "b") VALUES (9, '100001');
--Testcase 32:
INSERT INTO "type_VARBIT" ("i", "b") VALUES (10, '0100100101011001010010101000111110110101101101111011000101010');
--Testcase 33:
INSERT INTO "type_VARBIT" ("i", "b") VALUES (11, '01001001010110010100101010001111101101011011011110110001010101');

--Testcase 34:
SELECT * FROM "type_VARBIT+";
--Testcase 35:
SELECT * FROM "type_VARBIT+" WHERE b < '110110';
--Testcase 36:
SELECT * FROM "type_VARBIT+" WHERE b > '110110';
--Testcase 37:
SELECT * FROM "type_VARBIT+" WHERE b = '110110';

--Testcase 38:
INSERT INTO "type_VARBIT" ("i", "b") VALUES (12, '010010010101100101001010100011111011010110110111101100010101010');
--Testcase 39:
INSERT INTO "type_VARBIT" ("i", "b") VALUES (13, '0100100101011001010010101000111110110101101101111011000101010101');
--Testcase 40: very long bit string, expected ERROR, 65 bits
INSERT INTO "type_VARBIT" ("i", "b") VALUES (14, '01001001010110010100101010001111101101011011011110110001010101010');
--Testcase 41:
SELECT * FROM "type_VARBIT+" WHERE "i" > 10;

--Testcase 42:
SELECT b1."i" "i₁", b1."b" "b₁", b2."i" "i₂", b2."b" "b₂", b1."b" | b2."b" "res" FROM "type_BIT" b1 INNER JOIN "type_BIT" b2 ON true;
--Testcase 43:
SELECT b1."i" "i₁", b1."b" "b₁", b2."i" "i₂", b2."b" "b₂", b1."b" & b2."b" "res" FROM "type_BIT" b1 INNER JOIN "type_BIT" b2 ON true;
--Testcase 44:
SELECT b1."i" "i₁", b1."b" "b₁", b2."i" "i₂", b2."b" "b₂", b1."b" # b2."b" "res" FROM "type_BIT" b1 INNER JOIN "type_BIT" b2 ON true;
--Testcase 45:
SELECT "i", "b", "b" >> 2 "res" FROM "type_BIT";
--Testcase 46:
SELECT "i", "b", "b" << 3 "res" FROM "type_BIT";
--Testcase 47:
SELECT "i", "b", ~ "b" "res" FROM "type_BIT";
--Testcase 48:
EXPLAIN VERBOSE
SELECT b1."i" "i₁", b1."b" "b₁", b2."i" "i₂", b2."b" "b₂", b1."b" | b2."b" "res" FROM "type_BIT" b1 INNER JOIN "type_BIT" b2 ON true;
--Testcase 49:
EXPLAIN VERBOSE
SELECT b1."i" "i₁", b1."b" "b₁", b2."i" "i₂", b2."b" "b₂", b1."b" & b2."b" "res" FROM "type_BIT" b1 INNER JOIN "type_BIT" b2 ON true;
--Testcase 50:
EXPLAIN VERBOSE
SELECT b1."i" "i₁", b1."b" "b₁", b2."i" "i₂", b2."b" "b₂", b1."b" # b2."b" "res" FROM "type_BIT" b1 INNER JOIN "type_BIT" b2 ON true;
--Testcase 51:
EXPLAIN VERBOSE
SELECT "i", "b", "b" >> 2 "res" FROM "type_BIT";
--Testcase 52:
EXPLAIN VERBOSE
SELECT "i", "b", "b" << 3 "res" FROM "type_BIT";
--Testcase 53:
EXPLAIN VERBOSE
SELECT "i", "b", ~ "b" "res" FROM "type_BIT";

--Testcase 54:
SELECT b1."i" "i₁", b1."b" "b₁", b2."i" "i₂", b2."b" "b₂", b1."b" | b2."b" "res" FROM "type_VARBIT" b1 INNER JOIN "type_VARBIT" b2 ON true;
--Testcase 55:
SELECT b1."i" "i₁", b1."b" "b₁", b2."i" "i₂", b2."b" "b₂", b1."b" & b2."b" "res" FROM "type_VARBIT" b1 INNER JOIN "type_VARBIT" b2 ON true;
--Testcase 56:
SELECT b1."i" "i₁", b1."b" "b₁", b2."i" "i₂", b2."b" "b₂", b1."b" # b2."b" "res" FROM "type_VARBIT" b1 INNER JOIN "type_VARBIT" b2 ON true;
--Testcase 57:
SELECT "i", "b", "b" >> 2 "res" FROM "type_VARBIT";
--Testcase 58:
SELECT "i", "b", "b" << 3 "res" FROM "type_VARBIT";
--Testcase 59:
SELECT "i", "b", ~ "b" "res" FROM "type_VARBIT";
--Testcase 60:
EXPLAIN VERBOSE
SELECT b1."i" "i₁", b1."b" "b₁", b2."i" "i₂", b2."b" "b₂", b1."b" | b2."b" "res" FROM "type_VARBIT" b1 INNER JOIN "type_VARBIT" b2 ON true;
--Testcase 61:
EXPLAIN VERBOSE
SELECT b1."i" "i₁", b1."b" "b₁", b2."i" "i₂", b2."b" "b₂", b1."b" & b2."b" "res" FROM "type_VARBIT" b1 INNER JOIN "type_VARBIT" b2 ON true;
--Testcase 62:
EXPLAIN VERBOSE
SELECT b1."i" "i₁", b1."b" "b₁", b2."i" "i₂", b2."b" "b₂", b1."b" # b2."b" "res" FROM "type_VARBIT" b1 INNER JOIN "type_VARBIT" b2 ON true;
--Testcase 63:
EXPLAIN VERBOSE
SELECT "i", "b", "b" >> 2 "res" FROM "type_VARBIT";
--Testcase 64:
EXPLAIN VERBOSE
SELECT "i", "b", "b" << 3 "res" FROM "type_VARBIT";
--Testcase 65:
EXPLAIN VERBOSE
SELECT "i", "b", ~ "b" "res" FROM "type_VARBIT";

--Testcase 66:
SELECT "i", "b", "b" & B'101011' "res" FROM "type_BIT";
--Testcase 67:
SELECT "i", "b", "b" | B'101011' "res" FROM "type_BIT";
--Testcase 68:
SELECT "i", "b", "b" # B'101011' "res" FROM "type_BIT";
--Testcase 69:
SELECT "i", "b" FROM "type_BIT" WHERE ("b" & B'101011') IS NOT NULL;
--Testcase 70:
SELECT "i", "b" FROM "type_BIT" WHERE ("b" | B'101011') IS NOT NULL;
--Testcase 71:
SELECT "i", "b" FROM "type_BIT" WHERE ("b" # B'101011') IS NOT NULL;
--Testcase 72:
SELECT "i", "b" FROM "type_BIT" WHERE ("b" >> 1) IS NOT NULL;
--Testcase 73:
SELECT "i", "b" FROM "type_BIT" WHERE ("b" << 2) IS NOT NULL;
--Testcase 74:
SELECT "i", "b" FROM "type_BIT" WHERE (~ "b") IS NOT NULL;
--Testcase 75:
EXPLAIN VERBOSE
SELECT "i", "b" FROM "type_BIT" WHERE ("b" & B'101011') IS NOT NULL;
--Testcase 76:
EXPLAIN VERBOSE
SELECT "i", "b" FROM "type_BIT" WHERE ("b" | B'101011') IS NOT NULL;
--Testcase 77:
EXPLAIN VERBOSE
SELECT "i", "b" FROM "type_BIT" WHERE ("b" # B'101011') IS NOT NULL;
--Testcase 78:
EXPLAIN VERBOSE
SELECT "i", "b" FROM "type_BIT" WHERE ("b" >> 1) IS NOT NULL;
--Testcase 79:
EXPLAIN VERBOSE
SELECT "i", "b" FROM "type_BIT" WHERE ("b" << 2) IS NOT NULL;
--Testcase 80:
EXPLAIN VERBOSE
SELECT "i", "b" FROM "type_BIT" WHERE (~ "b") IS NOT NULL;

--Testcase 81:
SELECT "i", "b", "b" & B'101011' "res" FROM "type_BIT";
--Testcase 82:
SELECT "i", "b", "b" | B'101011' "res" FROM "type_BIT";
--Testcase 83:
SELECT "i", "b", "b" # B'101011' "res" FROM "type_BIT";
--Testcase 84:
SELECT "i", "b" FROM "type_BIT" WHERE ("b" & B'101011') IS NOT NULL;
--Testcase 85:
SELECT "i", "b" FROM "type_BIT" WHERE ("b" | B'101011') IS NOT NULL;
--Testcase 86:
SELECT "i", "b" FROM "type_BIT" WHERE ("b" # B'101011') IS NOT NULL;
--Testcase 87:
SELECT "i", "b" FROM "type_BIT" WHERE ("b" >> 1) IS NOT NULL;
--Testcase 88:
SELECT "i", "b" FROM "type_BIT" WHERE ("b" << 2) IS NOT NULL;
--Testcase 89:
SELECT "i", "b" FROM "type_BIT" WHERE (~ "b") IS NOT NULL;
--Testcase 90:
EXPLAIN VERBOSE
SELECT "i", "b" FROM "type_BIT" WHERE ("b" & B'101011') IS NOT NULL;
--Testcase 91:
EXPLAIN VERBOSE
SELECT "i", "b" FROM "type_BIT" WHERE ("b" | B'101011') IS NOT NULL;
--Testcase 92:
EXPLAIN VERBOSE
SELECT "i", "b" FROM "type_BIT" WHERE ("b" # B'101011') IS NOT NULL;
--Testcase 93:
EXPLAIN VERBOSE
SELECT "i", "b" FROM "type_BIT" WHERE ("b" >> 1) IS NOT NULL;
--Testcase 94:
EXPLAIN VERBOSE
SELECT "i", "b" FROM "type_BIT" WHERE ("b" << 2) IS NOT NULL;
--Testcase 95:
EXPLAIN VERBOSE
SELECT "i", "b" FROM "type_BIT" WHERE (~ "b") IS NOT NULL;

--Testcase 005:
DROP EXTENSION sqlite_fdw CASCADE;
