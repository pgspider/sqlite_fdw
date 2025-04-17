
DROP TABLE IF EXISTS department;
DROP TABLE IF EXISTS employee;
DROP TABLE IF EXISTS empdata;
DROP TABLE IF EXISTS numbers;
DROP TABLE IF EXISTS limittest;
DROP TABLE IF EXISTS grem1_1;
DROP TABLE IF EXISTS grem1_2;
DROP TABLE IF EXISTS case_exp;

CREATE TABLE department(department_id int primary key, department_name text);
CREATE TABLE employee(emp_id int primary key, emp_name text, emp_dept_id int);
CREATE TABLE empdata(emp_id int primary key, emp_dat bytea);
CREATE TABLE numbers(a int primary key, b varchar(255) unique);
CREATE TABLE t(a integer primary key, b integer);
CREATE TABLE multiprimary(a integer, b integer, c integer, primary key(b,c));
CREATE TABLE columntest("a a" integer, "b b" integer,"c c" integer, primary key("a a","b b") );
CREATE TABLE noprimary(a integer, b text);
CREATE TABLE limittest(id int primary key, x integer, y text);
create table grem1_1 (a int primary key, b int generated always as (a * 2) stored);
create table grem1_2 (a int primary key, b int generated always as (a * 2) stored, c int generated always as (a * 3) stored, d int generated always as (a * 4) stored);
CREATE TABLE case_exp(c1 int primary key, c3 text, c6 varchar(10));

CREATE TABLE "type_STRING" (col text primary key);
CREATE TABLE "type_BOOLEANpk" (col boolean primary key);
CREATE TABLE "type_BOOLEAN" (i int primary key, b boolean);
CREATE VIEW  "type_BOOLEAN+" AS SELECT *, typeof("b") t, length("b") l FROM "type_BOOLEAN";
CREATE TABLE "type_BYTE" (col char(1) primary key);
CREATE TABLE "type_SINT" (col smallint primary key);
CREATE TABLE "type_BINT" (col bigint primary key);
CREATE TABLE "type_INTEGER" (col integer primary key); -- convert to bigint
CREATE TABLE "type_FLOAT" (col float primary key);
CREATE TABLE "type_DOUBLE" (col double primary key);
CREATE TABLE "type_TIMESTAMP" (col timestamp primary key, b timestamp);--, c date);
CREATE TABLE "type_BLOB" (col blob primary key);
CREATE TABLE "type_DATE" (col date primary key);
CREATE TABLE "type_TIME" (col time primary key);
CREATE TABLE "type_BIT" (i int, b bit);
CREATE VIEW  "type_BIT+" AS SELECT *, typeof(b) t, length(b) l FROM "type_BIT";
CREATE TABLE "type_VARBIT" (i int, b bit);
CREATE VIEW  "type_VARBIT+" AS SELECT *, typeof(b) t, length(b) l FROM "type_VARBIT";
CREATE TABLE "type_UUIDpk" (col uuid primary key);
CREATE TABLE "type_UUID" (i int, u uuid);
CREATE VIEW  "type_UUID+" AS SELECT
	*,
	typeof(u) t,
	length(u) l
	-- blob affinity normalization form for "type_UUID+" view for better visual comparing during uuid test output, will be used later
	-- case when typeof(u) = 'blob' then substr(lower(hex(u)),1,8) || '-' || substr(lower(hex(u)),9,4) || '-' || substr(lower(hex(u)),13,4) || '-' || substr(lower(hex(u)),17,4) || '-' || substr(lower(hex(u)),21,12) else null end uuid_blob_canon
FROM "type_UUID";
CREATE TABLE "type_MACADDRpk" (col macaddr primary key);
CREATE TABLE "type_MACADDR" (i int, m macaddr);
CREATE VIEW  "type_MACADDR+" AS SELECT *, typeof("m") t, length("m") l, cast("m" as text) tx FROM "type_macaddr";
CREATE TABLE "type_MACADDR8pk" (col macaddr8 primary key);
CREATE TABLE "type_MACADDR8" (i int, m macaddr8);
CREATE VIEW  "type_MACADDR8+" AS SELECT *, typeof("m") t, length("m") l, cast("m" as text) tx FROM "type_macaddr8";
CREATE TABLE "types_PostGIS" (i int, gm geometry, gg geography, r raster, t text, gm1 geometry, gg1 geography);
CREATE TABLE "type_JSON" (i int, j json, ot varchar(8), oi int, q text[], j1 json, ot1 text, oi1 int2);
CREATE TABLE "type_JSONB" (i int, j jsonb, ot varchar(8), oi int, q text[], j1 jsonb, ot1 text, oi1 int2);
CREATE VIEW  "type_JSONB+" AS SELECT
	*,
	typeof("j") t,
	length("j") l,
	substr(hex(cast("j" as text)), 1, 16) || '...' tx
FROM "type_JSONB";
CREATE TABLE BitT (p integer primary key, a BIT(3), b BIT VARYING(5));
CREATE TABLE notype (a);
CREATE TABLE typetest (i integer, v varchar(10), c char(10), t text, d datetime, ti timestamp);
CREATE TABLE type_TEXT (col text primary key);
CREATE TABLE alltypetest (
	c1 int,
	c2 tinyint,
	c3 smallint,
	c4 mediumint,
	c5 bigint,
	c6 unsign big int,
	c7 int8,
	c8 character(10),
	c9 varchar(255),
	c10 character varying(255),
	c11 nchar(55),
	c12 native character(70),
	c13 nvarchar(100),
	c14 text,
	c15 clob,
	c16 blob,
	c17 real,
	c18 double,
	c19 double precision,
	c20 float,
	c21 numeric,
	c22 decimal(10,5),
	c23 date,
	c24 datetime);
INSERT INTO  alltypetest VALUES (583647,   127,        12767,       388607,      2036854775807,          573709551615,      2036854775807,             'abcdefghij',       'abcdefghijjhgfjfuafh',       'Côte dIvoire Fijifoxju',        'Hôm nay tôi rất vui',                 'I am happy today',              '今日はとても幸せです 今日はとても幸せです',            'The quick brown fox jumps o'       ,  'ABCDEFGHIJKLMNOPQRSTUVWX',          x'4142434445',                       3.40E+18,          1.79769E+108,          1.79769E+88,          1.79E+108,          1234,        99999.99999,        '9999-12-31',         '9999-12-31 23:59:59');

CREATE TABLE json_osm_test (
	wkt text NULL,
	osm_type varchar(8) NULL,
	osm_id int8 NULL,
	tags json NULL,
	way_nodes int8[] NULL
);

-- a table that is missing some fields
CREATE TABLE shorty (
   id  integer primary key,
   c   character(10)
);

CREATE TABLE "A a" (col int primary key);

-- test for issue #44 github
CREATE VIRTUAL TABLE fts_table USING fts5(name, description, tokenize = porter);

-- updatable + force_readonly options test
CREATE TABLE RO_RW_test (
    i   int primary key not null,
    a   text,
    b   float,
    c   int
);

INSERT INTO RO_RW_test (i, a, b, c) VALUES (1, 'A',1.001, 0);

-- test for PR #76 github
CREATE TABLE "Unicode data" (i text primary key, t text);

INSERT INTO "Unicode data" (i, t) VALUES ('jap', 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす.');
INSERT INTO "Unicode data" (i, t) VALUES ('bul', 'Ах, чудна българска земьо, полюшвай цъфтящи жита.');
INSERT INTO "Unicode data" (i, t) VALUES ('rus', 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства.');
INSERT INTO "Unicode data" (i, t) VALUES ('aze', 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq.');
INSERT INTO "Unicode data" (i, t) VALUES ('arm', 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։');
INSERT INTO "Unicode data" (i, t) VALUES ('ukr', 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком.');
INSERT INTO "Unicode data" (i, t) VALUES ('eus', 'Permin gox dabiltzu yoskiñ.');
INSERT INTO "Unicode data" (i, t) VALUES ('bel', 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі.');
INSERT INTO "Unicode data" (i, t) VALUES ('gre', 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός');
INSERT INTO "Unicode data" (i, t) VALUES ('gle', 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig.');
INSERT INTO "Unicode data" (i, t) VALUES ('spa', 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón.');
INSERT INTO "Unicode data" (i, t) VALUES ('kor', '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다.');
INSERT INTO "Unicode data" (i, t) VALUES ('lav', 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm.');
INSERT INTO "Unicode data" (i, t) VALUES ('pol', 'Pchnąć w tę łódź jeża lub ośm skrzyń fig.');
INSERT INTO "Unicode data" (i, t) VALUES ('fra', 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !');
INSERT INTO "Unicode data" (i, t) VALUES ('srp', 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca.');
INSERT INTO "Unicode data" (i, t) VALUES ('epo', 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj.');
INSERT INTO "Unicode data" (i, t) VALUES ('cze', 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů.');
INSERT INTO "Unicode data" (i, t) VALUES ('ara', 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ');
INSERT INTO "Unicode data" (i, t) VALUES ('heb', 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם');


CREATE TABLE "type_BOOLEAN_oper" AS
WITH booldata AS (
	SELECT row_number() over () i, column1 AS b
	  FROM ( VALUES
	('Yes'), ('YeS'), ('yes'), ('on'),  ('ON'),  ('t'), ('T'), ('Y'), ('y'), (1), ('1'), ('true'),  ('tRuE'),
	('no'),  ('No'),  ('nO'),  ('off'), ('oFf'), ('f'), ('F'), ('N'), ('n'), (0), ('0'), ('false'), ('fALsE'),
	(NULL) )
				 )
SELECT ROW_NUMBER() OVER () i, t1.i i1, t1.b b1, t2.i i2, t2.b b2 FROM booldata t1 INNER JOIN booldata t2 ON 1;

-- RETURNING for UPDATE/DELETE ... FROM ret_base JOIN ret_j1t JOIN ret_j2t
CREATE TABLE ret_base (c1 int primary key, c2 int, c3 text);
CREATE TABLE ret_j1t  (c1 int primary key, c2 int, c3 float);
CREATE TABLE ret_j2t  (c1 int primary key, c2 int, c3 float);

-- SpatiaLite/PostGIS test
-- This table name also tests SpatiaLite and PostGIS metadata functions. Made as analog of the next "martian" table.
CREATE TABLE "♁" (
	geom geometry NOT NULL,
	osm_type varchar(16) NOT NULL,
	osm_id int NOT NULL,
	ver int NOT NULL,
	arr text,
	t jsonb
);

-- SpatiaLite/PostGIS test
-- This table and column names also tests SpatiaLite and PostGIS metadata functions. Any geometry or geography column declaration cause some actions inside of spatial metadata storage or journals of SpatiaLite and PostGIS.
-- This is real table and column names from one of DBs of Union Astronomique International.
CREATE TABLE "♂" (
	id int4,
	"UAI" varchar(254),
	"⌖" geometry,
	geom geometry,
	"t₀" date,
	"class" text,
	"URL" varchar(80)
);

analyze;
