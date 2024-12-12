-- tests for PR #76 github
-- see https://www.postgresql.org/docs/current/multibyte.html
-- EUC_CN, not tested
-- EUC_JP
-- EUC_JIS_2004, not tested
-- EUC_KR
-- EUC_TW, not tested
-- ISO_8859_5
-- ISO_8859_6
-- ISO_8859_7
-- ISO_8859_8
-- KOI8R, not tested
-- KOI8U, not tested
-- LATIN1
-- LATIN2
-- LATIN3
-- LATIN4
-- LATIN5
-- LATIN6
-- LATIN7
-- LATIN8
-- LATIN9
-- LATIN10
-- MULE_INTERNAL, not tested
-- SQL_ASCII
-- WIN866, not tested
-- WIN874, not tested
-- WIN1250
-- WIN1251
-- WIN1252
-- WIN1253
-- WIN1254
-- WIN1255
-- WIN1256
-- WIN1257
-- WIN1258, not tested

-- ================
-- check all data in UTF8
-- ================
CREATE EXTENSION sqlite_fdw;
CREATE SERVER sqlite_svr FOREIGN DATA WRAPPER sqlite_fdw
OPTIONS (database '/tmp/sqlite_fdw_test/common.db');
CREATE FOREIGN TABLE "Unicode data"(i text OPTIONS (key 'true'), t text) SERVER sqlite_svr;
SELECT * FROM "Unicode data";
DROP FOREIGN TABLE "Unicode data";
DROP SERVER sqlite_svr;
DROP EXTENSION sqlite_fdw;

-- euc_jp
CREATE DATABASE "contrib_regression_EUC_JP" ENCODING EUC_JP LC_CTYPE='ja_JP.eucjp' LC_COLLATE='ja_JP.eucjp' template template0;
\connect "contrib_regression_EUC_JP"
CREATE EXTENSION sqlite_fdw;
CREATE SERVER sqlite_svr FOREIGN DATA WRAPPER sqlite_fdw
OPTIONS (database '/tmp/sqlite_fdw_test/common.db');
CREATE FOREIGN TABLE "Unicode data"(i text OPTIONS (key 'true'), t text) SERVER sqlite_svr; 
-- EUC_JP
SELECT * FROM "Unicode data" WHERE i = 'jap';
SELECT * FROM "Unicode data" WHERE t LIKE 'いろはにほ%';
INSERT INTO "Unicode data" (i, t) VALUES ('jap+', 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._');
DELETE FROM "Unicode data" WHERE t = 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'jap+';
-- 1251, ISO_8859_5
SELECT * FROM "Unicode data" WHERE i = 'bel';
SELECT * FROM "Unicode data" WHERE i = 'bul';
SELECT * FROM "Unicode data" WHERE i = 'rus';
SELECT * FROM "Unicode data" WHERE i = 'ukr';
SELECT * FROM "Unicode data" WHERE t LIKE 'У руд%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ах, ч%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Широк%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Гей, %';
INSERT INTO "Unicode data" (i, t) VALUES ('bel+', 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._');
SELECT * FROM "Unicode data" WHERE i = 'bel+';
DELETE FROM "Unicode data" WHERE t = 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bel+';
INSERT INTO "Unicode data" (i, t) VALUES ('bul+', 'Ах, чудна българска земьо, полюшвай цъфтящи жита._');
SELECT * FROM "Unicode data" WHERE i = 'bul+';
DELETE FROM "Unicode data" WHERE t = 'Ах, чудна българска земьо, полюшвай цъфтящи жита._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bul+';
INSERT INTO "Unicode data" (i, t) VALUES ('rus+', 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._');
SELECT * FROM "Unicode data" WHERE i = 'rus+';
DELETE FROM "Unicode data" WHERE t = 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'rus+';
INSERT INTO "Unicode data" (i, t) VALUES ('ukr+', 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._');
SELECT * FROM "Unicode data" WHERE i = 'ukr+';
DELETE FROM "Unicode data" WHERE t = 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ukr+';
-- 1256, ISO_8859_6
SELECT * FROM "Unicode data" WHERE i = 'ara';
SELECT * FROM "Unicode data" WHERE t LIKE '%ضَظَغ%';
INSERT INTO "Unicode data" (i, t) VALUES ('ara+', 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_');
SELECT * FROM "Unicode data" WHERE i = 'ara+';
DELETE FROM "Unicode data" WHERE t = 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ara+';
-- 1253, ISO_8859_7
SELECT * FROM "Unicode data" WHERE i = 'gre';
SELECT * FROM "Unicode data" WHERE t LIKE 'Τάχισ%';
INSERT INTO "Unicode data" (i, t) VALUES ('gre+', 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_');
SELECT * FROM "Unicode data" WHERE i = 'gre+';
DELETE FROM "Unicode data" WHERE t = 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_';
-- 1255, ISO_8859_8
SELECT * FROM "Unicode data" WHERE i = 'heb';
SELECT * FROM "Unicode data" WHERE t LIKE '%כי ח%';
INSERT INTO "Unicode data" (i, t) VALUES ('heb+', 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_');
SELECT * FROM "Unicode data" WHERE i = 'heb+';
DELETE FROM "Unicode data" WHERE t = 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'heb+';
-- 1252, LATIN1
SELECT * FROM "Unicode data" WHERE i = 'eus';
SELECT * FROM "Unicode data" WHERE i = 'fra';
SELECT * FROM "Unicode data" WHERE i = 'spa';
SELECT * FROM "Unicode data" WHERE t LIKE 'Permi%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Dès N%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Quier%';
INSERT INTO "Unicode data" (i, t) VALUES ('eus+', 'Permin gox dabiltzu yoskiñ._');
SELECT * FROM "Unicode data" WHERE i = 'eus+';
DELETE FROM "Unicode data" WHERE t = 'Permin gox dabiltzu yoskiñ._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'eus+';
INSERT INTO "Unicode data" (i, t) VALUES ('fra+', 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_');
SELECT * FROM "Unicode data" WHERE i = 'fra+';
DELETE FROM "Unicode data" WHERE t = 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'fra+';
INSERT INTO "Unicode data" (i, t) VALUES ('spa+', 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._');
SELECT * FROM "Unicode data" WHERE i = 'spa+';
DELETE FROM "Unicode data" WHERE t = 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'spa+';
-- 1250, LATIN2
SELECT * FROM "Unicode data" WHERE i = 'cze';
SELECT * FROM "Unicode data" WHERE i = 'pol';
SELECT * FROM "Unicode data" WHERE i = 'srp';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zvláš%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Pchną%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ljuba%';
INSERT INTO "Unicode data" (i, t) VALUES ('cze+', 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._');
SELECT * FROM "Unicode data" WHERE i = 'cze+';
DELETE FROM "Unicode data" WHERE t = 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'cze+';
INSERT INTO "Unicode data" (i, t) VALUES ('pol+', 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._');
SELECT * FROM "Unicode data" WHERE i = 'pol+';
DELETE FROM "Unicode data" WHERE t = 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'pol+';
INSERT INTO "Unicode data" (i, t) VALUES ('srp+', 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._');
SELECT * FROM "Unicode data" WHERE i = 'srp+';
DELETE FROM "Unicode data" WHERE t = 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'srp+';
-- 1257, LATIN7
SELECT * FROM "Unicode data" WHERE i = 'lav';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ķieģeļu%';
INSERT INTO "Unicode data" (i, t) VALUES ('lav+', 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._');
SELECT * FROM "Unicode data" WHERE i = 'lav+';
DELETE FROM "Unicode data" WHERE t = 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'lav+';
-- EUC_KR
SELECT * FROM "Unicode data" WHERE i = 'kor';
SELECT * FROM "Unicode data" WHERE t LIKE '키스의 고%';
INSERT INTO "Unicode data" (i, t) VALUES ('kor+', '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._');
SELECT * FROM "Unicode data" WHERE i = 'kor+';
DELETE FROM "Unicode data" WHERE t = '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'kor+';
-- 1254, LATIN5
SELECT * FROM "Unicode data" WHERE i = 'aze';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zəfər%';
INSERT INTO "Unicode data" (i, t) VALUES ('aze+', 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._');
SELECT * FROM "Unicode data" WHERE i = 'aze+';
DELETE FROM "Unicode data" WHERE t = 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'aze+';
-- etc
INSERT INTO "Unicode data" (i, t) VALUES ('arm+', 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_');
SELECT * FROM "Unicode data" WHERE i = 'arm+';
DELETE FROM "Unicode data" WHERE t = 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'arm+';
INSERT INTO "Unicode data" (i, t) VALUES ('gle+', 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._');
SELECT * FROM "Unicode data" WHERE i = 'gle+';
DELETE FROM "Unicode data" WHERE t = 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'gle+';
INSERT INTO "Unicode data" (i, t) VALUES ('epo+', 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._');
SELECT * FROM "Unicode data" WHERE i = 'epo+';
DELETE FROM "Unicode data" WHERE t = 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'epo+';

DROP FOREIGN TABLE "Unicode data";
DROP SERVER sqlite_svr;
DROP EXTENSION sqlite_fdw;
\connect contrib_regression;
DROP DATABASE "contrib_regression_EUC_JP";

-- ko_KR.euckr
CREATE DATABASE "contrib_regression_EUC_KR" ENCODING EUC_KR LC_CTYPE='ko_KR.euckr' LC_COLLATE='ko_KR.euckr' template template0;
\connect "contrib_regression_EUC_KR"
CREATE EXTENSION sqlite_fdw;
CREATE SERVER sqlite_svr FOREIGN DATA WRAPPER sqlite_fdw
OPTIONS (database '/tmp/sqlite_fdw_test/common.db');
CREATE FOREIGN TABLE "Unicode data"(i text OPTIONS (key 'true'), t text) SERVER sqlite_svr; 
-- EUC_JP
SELECT * FROM "Unicode data" WHERE i = 'jap';
SELECT * FROM "Unicode data" WHERE t LIKE 'いろはにほ%';
INSERT INTO "Unicode data" (i, t) VALUES ('jap+', 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._');
DELETE FROM "Unicode data" WHERE t = 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'jap+';
-- 1251, ISO_8859_5
SELECT * FROM "Unicode data" WHERE i = 'bel';
SELECT * FROM "Unicode data" WHERE i = 'bul';
SELECT * FROM "Unicode data" WHERE i = 'rus';
SELECT * FROM "Unicode data" WHERE i = 'ukr';
SELECT * FROM "Unicode data" WHERE t LIKE 'У руд%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ах, ч%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Широк%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Гей, %';
INSERT INTO "Unicode data" (i, t) VALUES ('bel+', 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._');
SELECT * FROM "Unicode data" WHERE i = 'bel+';
DELETE FROM "Unicode data" WHERE t = 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bel+';
INSERT INTO "Unicode data" (i, t) VALUES ('bul+', 'Ах, чудна българска земьо, полюшвай цъфтящи жита._');
SELECT * FROM "Unicode data" WHERE i = 'bul+';
DELETE FROM "Unicode data" WHERE t = 'Ах, чудна българска земьо, полюшвай цъфтящи жита._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bul+';
INSERT INTO "Unicode data" (i, t) VALUES ('rus+', 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._');
SELECT * FROM "Unicode data" WHERE i = 'rus+';
DELETE FROM "Unicode data" WHERE t = 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'rus+';
INSERT INTO "Unicode data" (i, t) VALUES ('ukr+', 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._');
SELECT * FROM "Unicode data" WHERE i = 'ukr+';
DELETE FROM "Unicode data" WHERE t = 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ukr+';
-- 1256, ISO_8859_6
SELECT * FROM "Unicode data" WHERE i = 'ara';
SELECT * FROM "Unicode data" WHERE t LIKE '%ضَظَغ%';
INSERT INTO "Unicode data" (i, t) VALUES ('ara+', 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_');
SELECT * FROM "Unicode data" WHERE i = 'ara+';
DELETE FROM "Unicode data" WHERE t = 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ara+';
-- 1253, ISO_8859_7
SELECT * FROM "Unicode data" WHERE i = 'gre';
SELECT * FROM "Unicode data" WHERE t LIKE 'Τάχισ%';
INSERT INTO "Unicode data" (i, t) VALUES ('gre+', 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_');
SELECT * FROM "Unicode data" WHERE i = 'gre+';
DELETE FROM "Unicode data" WHERE t = 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_';
-- 1255, ISO_8859_8
SELECT * FROM "Unicode data" WHERE i = 'heb';
SELECT * FROM "Unicode data" WHERE t LIKE '%כי ח%';
INSERT INTO "Unicode data" (i, t) VALUES ('heb+', 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_');
SELECT * FROM "Unicode data" WHERE i = 'heb+';
DELETE FROM "Unicode data" WHERE t = 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'heb+';
-- 1252, LATIN1
SELECT * FROM "Unicode data" WHERE i = 'eus';
SELECT * FROM "Unicode data" WHERE i = 'fra';
SELECT * FROM "Unicode data" WHERE i = 'spa';
SELECT * FROM "Unicode data" WHERE t LIKE 'Permi%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Dès N%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Quier%';
INSERT INTO "Unicode data" (i, t) VALUES ('eus+', 'Permin gox dabiltzu yoskiñ._');
SELECT * FROM "Unicode data" WHERE i = 'eus+';
DELETE FROM "Unicode data" WHERE t = 'Permin gox dabiltzu yoskiñ._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'eus+';
INSERT INTO "Unicode data" (i, t) VALUES ('fra+', 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_');
SELECT * FROM "Unicode data" WHERE i = 'fra+';
DELETE FROM "Unicode data" WHERE t = 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'fra+';
INSERT INTO "Unicode data" (i, t) VALUES ('spa+', 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._');
SELECT * FROM "Unicode data" WHERE i = 'spa+';
DELETE FROM "Unicode data" WHERE t = 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'spa+';
-- 1250, LATIN2
SELECT * FROM "Unicode data" WHERE i = 'cze';
SELECT * FROM "Unicode data" WHERE i = 'pol';
SELECT * FROM "Unicode data" WHERE i = 'srp';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zvláš%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Pchną%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ljuba%';
INSERT INTO "Unicode data" (i, t) VALUES ('cze+', 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._');
SELECT * FROM "Unicode data" WHERE i = 'cze+';
DELETE FROM "Unicode data" WHERE t = 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'cze+';
INSERT INTO "Unicode data" (i, t) VALUES ('pol+', 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._');
SELECT * FROM "Unicode data" WHERE i = 'pol+';
DELETE FROM "Unicode data" WHERE t = 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'pol+';
INSERT INTO "Unicode data" (i, t) VALUES ('srp+', 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._');
SELECT * FROM "Unicode data" WHERE i = 'srp+';
DELETE FROM "Unicode data" WHERE t = 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'srp+';
-- 1257, LATIN7
SELECT * FROM "Unicode data" WHERE i = 'lav';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ķieģeļu%';
INSERT INTO "Unicode data" (i, t) VALUES ('lav+', 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._');
SELECT * FROM "Unicode data" WHERE i = 'lav+';
DELETE FROM "Unicode data" WHERE t = 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'lav+';
-- EUC_KR
SELECT * FROM "Unicode data" WHERE i = 'kor';
SELECT * FROM "Unicode data" WHERE t LIKE '키스의 고%';
INSERT INTO "Unicode data" (i, t) VALUES ('kor+', '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._');
SELECT * FROM "Unicode data" WHERE i = 'kor+';
DELETE FROM "Unicode data" WHERE t = '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'kor+';
-- 1254, LATIN5
SELECT * FROM "Unicode data" WHERE i = 'aze';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zəfər%';
INSERT INTO "Unicode data" (i, t) VALUES ('aze+', 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._');
SELECT * FROM "Unicode data" WHERE i = 'aze+';
DELETE FROM "Unicode data" WHERE t = 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'aze+';
-- etc
INSERT INTO "Unicode data" (i, t) VALUES ('arm+', 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_');
SELECT * FROM "Unicode data" WHERE i = 'arm+';
DELETE FROM "Unicode data" WHERE t = 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'arm+';
INSERT INTO "Unicode data" (i, t) VALUES ('gle+', 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._');
SELECT * FROM "Unicode data" WHERE i = 'gle+';
DELETE FROM "Unicode data" WHERE t = 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'gle+';
INSERT INTO "Unicode data" (i, t) VALUES ('epo+', 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._');
SELECT * FROM "Unicode data" WHERE i = 'epo+';
DELETE FROM "Unicode data" WHERE t = 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'epo+';

DROP FOREIGN TABLE "Unicode data";
DROP SERVER sqlite_svr;
DROP EXTENSION sqlite_fdw;
\connect contrib_regression;
DROP DATABASE "contrib_regression_EUC_KR";

-- ISO_8859_5
CREATE DATABASE "contrib_regression_ISO_8859_5" ENCODING ISO_8859_5 LC_CTYPE='POSIX' LC_COLLATE='POSIX' template template0;
\connect "contrib_regression_ISO_8859_5"
CREATE EXTENSION sqlite_fdw;
CREATE SERVER sqlite_svr FOREIGN DATA WRAPPER sqlite_fdw
OPTIONS (database '/tmp/sqlite_fdw_test/common.db');
CREATE FOREIGN TABLE "Unicode data"(i text OPTIONS (key 'true'), t text) SERVER sqlite_svr; 
-- EUC_JP
SELECT * FROM "Unicode data" WHERE i = 'jap';
SELECT * FROM "Unicode data" WHERE t LIKE 'いろはにほ%';
INSERT INTO "Unicode data" (i, t) VALUES ('jap+', 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._');
DELETE FROM "Unicode data" WHERE t = 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'jap+';
-- 1251, ISO_8859_5
SELECT * FROM "Unicode data" WHERE i = 'bel';
SELECT * FROM "Unicode data" WHERE i = 'bul';
SELECT * FROM "Unicode data" WHERE i = 'rus';
SELECT * FROM "Unicode data" WHERE i = 'ukr';
SELECT * FROM "Unicode data" WHERE t LIKE 'У руд%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ах, ч%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Широк%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Гей, %';
INSERT INTO "Unicode data" (i, t) VALUES ('bel+', 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._');
SELECT * FROM "Unicode data" WHERE i = 'bel+';
DELETE FROM "Unicode data" WHERE t = 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bel+';
INSERT INTO "Unicode data" (i, t) VALUES ('bul+', 'Ах, чудна българска земьо, полюшвай цъфтящи жита._');
SELECT * FROM "Unicode data" WHERE i = 'bul+';
DELETE FROM "Unicode data" WHERE t = 'Ах, чудна българска земьо, полюшвай цъфтящи жита._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bul+';
INSERT INTO "Unicode data" (i, t) VALUES ('rus+', 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._');
SELECT * FROM "Unicode data" WHERE i = 'rus+';
DELETE FROM "Unicode data" WHERE t = 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'rus+';
INSERT INTO "Unicode data" (i, t) VALUES ('ukr+', 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._');
SELECT * FROM "Unicode data" WHERE i = 'ukr+';
DELETE FROM "Unicode data" WHERE t = 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ukr+';
-- 1256, ISO_8859_6
SELECT * FROM "Unicode data" WHERE i = 'ara';
SELECT * FROM "Unicode data" WHERE t LIKE '%ضَظَغ%';
INSERT INTO "Unicode data" (i, t) VALUES ('ara+', 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_');
SELECT * FROM "Unicode data" WHERE i = 'ara+';
DELETE FROM "Unicode data" WHERE t = 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ara+';
-- 1253, ISO_8859_7
SELECT * FROM "Unicode data" WHERE i = 'gre';
SELECT * FROM "Unicode data" WHERE t LIKE 'Τάχισ%';
INSERT INTO "Unicode data" (i, t) VALUES ('gre+', 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_');
SELECT * FROM "Unicode data" WHERE i = 'gre+';
DELETE FROM "Unicode data" WHERE t = 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_';
-- 1255, ISO_8859_8
SELECT * FROM "Unicode data" WHERE i = 'heb';
SELECT * FROM "Unicode data" WHERE t LIKE '%כי ח%';
INSERT INTO "Unicode data" (i, t) VALUES ('heb+', 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_');
SELECT * FROM "Unicode data" WHERE i = 'heb+';
DELETE FROM "Unicode data" WHERE t = 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'heb+';
-- 1252, LATIN1
SELECT * FROM "Unicode data" WHERE i = 'eus';
SELECT * FROM "Unicode data" WHERE i = 'fra';
SELECT * FROM "Unicode data" WHERE i = 'spa';
SELECT * FROM "Unicode data" WHERE t LIKE 'Permi%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Dès N%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Quier%';
INSERT INTO "Unicode data" (i, t) VALUES ('eus+', 'Permin gox dabiltzu yoskiñ._');
SELECT * FROM "Unicode data" WHERE i = 'eus+';
DELETE FROM "Unicode data" WHERE t = 'Permin gox dabiltzu yoskiñ._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'eus+';
INSERT INTO "Unicode data" (i, t) VALUES ('fra+', 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_');
SELECT * FROM "Unicode data" WHERE i = 'fra+';
DELETE FROM "Unicode data" WHERE t = 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'fra+';
INSERT INTO "Unicode data" (i, t) VALUES ('spa+', 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._');
SELECT * FROM "Unicode data" WHERE i = 'spa+';
DELETE FROM "Unicode data" WHERE t = 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'spa+';
-- 1250, LATIN2
SELECT * FROM "Unicode data" WHERE i = 'cze';
SELECT * FROM "Unicode data" WHERE i = 'pol';
SELECT * FROM "Unicode data" WHERE i = 'srp';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zvláš%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Pchną%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ljuba%';
INSERT INTO "Unicode data" (i, t) VALUES ('cze+', 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._');
SELECT * FROM "Unicode data" WHERE i = 'cze+';
DELETE FROM "Unicode data" WHERE t = 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'cze+';
INSERT INTO "Unicode data" (i, t) VALUES ('pol+', 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._');
SELECT * FROM "Unicode data" WHERE i = 'pol+';
DELETE FROM "Unicode data" WHERE t = 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'pol+';
INSERT INTO "Unicode data" (i, t) VALUES ('srp+', 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._');
SELECT * FROM "Unicode data" WHERE i = 'srp+';
DELETE FROM "Unicode data" WHERE t = 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'srp+';
-- 1257, LATIN7
SELECT * FROM "Unicode data" WHERE i = 'lav';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ķieģeļu%';
INSERT INTO "Unicode data" (i, t) VALUES ('lav+', 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._');
SELECT * FROM "Unicode data" WHERE i = 'lav+';
DELETE FROM "Unicode data" WHERE t = 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'lav+';
-- EUC_KR
SELECT * FROM "Unicode data" WHERE i = 'kor';
SELECT * FROM "Unicode data" WHERE t LIKE '키스의 고%';
INSERT INTO "Unicode data" (i, t) VALUES ('kor+', '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._');
SELECT * FROM "Unicode data" WHERE i = 'kor+';
DELETE FROM "Unicode data" WHERE t = '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'kor+';
-- 1254, LATIN5
SELECT * FROM "Unicode data" WHERE i = 'aze';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zəfər%';
INSERT INTO "Unicode data" (i, t) VALUES ('aze+', 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._');
SELECT * FROM "Unicode data" WHERE i = 'aze+';
DELETE FROM "Unicode data" WHERE t = 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'aze+';
-- etc
INSERT INTO "Unicode data" (i, t) VALUES ('arm+', 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_');
SELECT * FROM "Unicode data" WHERE i = 'arm+';
DELETE FROM "Unicode data" WHERE t = 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'arm+';
INSERT INTO "Unicode data" (i, t) VALUES ('gle+', 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._');
SELECT * FROM "Unicode data" WHERE i = 'gle+';
DELETE FROM "Unicode data" WHERE t = 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'gle+';
INSERT INTO "Unicode data" (i, t) VALUES ('epo+', 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._');
SELECT * FROM "Unicode data" WHERE i = 'epo+';
DELETE FROM "Unicode data" WHERE t = 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'epo+';

DROP FOREIGN TABLE "Unicode data";
DROP SERVER sqlite_svr;
DROP EXTENSION sqlite_fdw;
\connect contrib_regression;
DROP DATABASE "contrib_regression_ISO_8859_5";

-- ISO_8859_6
CREATE DATABASE "contrib_regression_ISO_8859_6" ENCODING ISO_8859_6 LC_CTYPE='POSIX' LC_COLLATE='POSIX' template template0;
\connect "contrib_regression_ISO_8859_6"
CREATE EXTENSION sqlite_fdw;
CREATE SERVER sqlite_svr FOREIGN DATA WRAPPER sqlite_fdw
OPTIONS (database '/tmp/sqlite_fdw_test/common.db');
CREATE FOREIGN TABLE "Unicode data"(i text OPTIONS (key 'true'), t text) SERVER sqlite_svr; 
-- EUC_JP
SELECT * FROM "Unicode data" WHERE i = 'jap';
SELECT * FROM "Unicode data" WHERE t LIKE 'いろはにほ%';
INSERT INTO "Unicode data" (i, t) VALUES ('jap+', 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._');
DELETE FROM "Unicode data" WHERE t = 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'jap+';
-- 1251, ISO_8859_5
SELECT * FROM "Unicode data" WHERE i = 'bel';
SELECT * FROM "Unicode data" WHERE i = 'bul';
SELECT * FROM "Unicode data" WHERE i = 'rus';
SELECT * FROM "Unicode data" WHERE i = 'ukr';
SELECT * FROM "Unicode data" WHERE t LIKE 'У руд%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ах, ч%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Широк%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Гей, %';
INSERT INTO "Unicode data" (i, t) VALUES ('bel+', 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._');
SELECT * FROM "Unicode data" WHERE i = 'bel+';
DELETE FROM "Unicode data" WHERE t = 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bel+';
INSERT INTO "Unicode data" (i, t) VALUES ('bul+', 'Ах, чудна българска земьо, полюшвай цъфтящи жита._');
SELECT * FROM "Unicode data" WHERE i = 'bul+';
DELETE FROM "Unicode data" WHERE t = 'Ах, чудна българска земьо, полюшвай цъфтящи жита._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bul+';
INSERT INTO "Unicode data" (i, t) VALUES ('rus+', 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._');
SELECT * FROM "Unicode data" WHERE i = 'rus+';
DELETE FROM "Unicode data" WHERE t = 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'rus+';
INSERT INTO "Unicode data" (i, t) VALUES ('ukr+', 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._');
SELECT * FROM "Unicode data" WHERE i = 'ukr+';
DELETE FROM "Unicode data" WHERE t = 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ukr+';
-- 1256, ISO_8859_6
SELECT * FROM "Unicode data" WHERE i = 'ara';
SELECT * FROM "Unicode data" WHERE t LIKE '%ضَظَغ%';
INSERT INTO "Unicode data" (i, t) VALUES ('ara+', 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_');
SELECT * FROM "Unicode data" WHERE i = 'ara+';
DELETE FROM "Unicode data" WHERE t = 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ara+';
-- 1253, ISO_8859_7
SELECT * FROM "Unicode data" WHERE i = 'gre';
SELECT * FROM "Unicode data" WHERE t LIKE 'Τάχισ%';
INSERT INTO "Unicode data" (i, t) VALUES ('gre+', 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_');
SELECT * FROM "Unicode data" WHERE i = 'gre+';
DELETE FROM "Unicode data" WHERE t = 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_';
-- 1255, ISO_8859_8
SELECT * FROM "Unicode data" WHERE i = 'heb';
SELECT * FROM "Unicode data" WHERE t LIKE '%כי ח%';
INSERT INTO "Unicode data" (i, t) VALUES ('heb+', 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_');
SELECT * FROM "Unicode data" WHERE i = 'heb+';
DELETE FROM "Unicode data" WHERE t = 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'heb+';
-- 1252, LATIN1
SELECT * FROM "Unicode data" WHERE i = 'eus';
SELECT * FROM "Unicode data" WHERE i = 'fra';
SELECT * FROM "Unicode data" WHERE i = 'spa';
SELECT * FROM "Unicode data" WHERE t LIKE 'Permi%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Dès N%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Quier%';
INSERT INTO "Unicode data" (i, t) VALUES ('eus+', 'Permin gox dabiltzu yoskiñ._');
SELECT * FROM "Unicode data" WHERE i = 'eus+';
DELETE FROM "Unicode data" WHERE t = 'Permin gox dabiltzu yoskiñ._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'eus+';
INSERT INTO "Unicode data" (i, t) VALUES ('fra+', 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_');
SELECT * FROM "Unicode data" WHERE i = 'fra+';
DELETE FROM "Unicode data" WHERE t = 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'fra+';
INSERT INTO "Unicode data" (i, t) VALUES ('spa+', 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._');
SELECT * FROM "Unicode data" WHERE i = 'spa+';
DELETE FROM "Unicode data" WHERE t = 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'spa+';
-- 1250, LATIN2
SELECT * FROM "Unicode data" WHERE i = 'cze';
SELECT * FROM "Unicode data" WHERE i = 'pol';
SELECT * FROM "Unicode data" WHERE i = 'srp';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zvláš%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Pchną%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ljuba%';
INSERT INTO "Unicode data" (i, t) VALUES ('cze+', 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._');
SELECT * FROM "Unicode data" WHERE i = 'cze+';
DELETE FROM "Unicode data" WHERE t = 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'cze+';
INSERT INTO "Unicode data" (i, t) VALUES ('pol+', 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._');
SELECT * FROM "Unicode data" WHERE i = 'pol+';
DELETE FROM "Unicode data" WHERE t = 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'pol+';
INSERT INTO "Unicode data" (i, t) VALUES ('srp+', 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._');
SELECT * FROM "Unicode data" WHERE i = 'srp+';
DELETE FROM "Unicode data" WHERE t = 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'srp+';
-- 1257, LATIN7
SELECT * FROM "Unicode data" WHERE i = 'lav';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ķieģeļu%';
INSERT INTO "Unicode data" (i, t) VALUES ('lav+', 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._');
SELECT * FROM "Unicode data" WHERE i = 'lav+';
DELETE FROM "Unicode data" WHERE t = 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'lav+';
-- EUC_KR
SELECT * FROM "Unicode data" WHERE i = 'kor';
SELECT * FROM "Unicode data" WHERE t LIKE '키스의 고%';
INSERT INTO "Unicode data" (i, t) VALUES ('kor+', '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._');
SELECT * FROM "Unicode data" WHERE i = 'kor+';
DELETE FROM "Unicode data" WHERE t = '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'kor+';
-- 1254, LATIN5
SELECT * FROM "Unicode data" WHERE i = 'aze';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zəfər%';
INSERT INTO "Unicode data" (i, t) VALUES ('aze+', 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._');
SELECT * FROM "Unicode data" WHERE i = 'aze+';
DELETE FROM "Unicode data" WHERE t = 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'aze+';
-- etc
INSERT INTO "Unicode data" (i, t) VALUES ('arm+', 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_');
SELECT * FROM "Unicode data" WHERE i = 'arm+';
DELETE FROM "Unicode data" WHERE t = 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'arm+';
INSERT INTO "Unicode data" (i, t) VALUES ('gle+', 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._');
SELECT * FROM "Unicode data" WHERE i = 'gle+';
DELETE FROM "Unicode data" WHERE t = 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'gle+';
INSERT INTO "Unicode data" (i, t) VALUES ('epo+', 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._');
SELECT * FROM "Unicode data" WHERE i = 'epo+';
DELETE FROM "Unicode data" WHERE t = 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'epo+';

DROP FOREIGN TABLE "Unicode data";
DROP SERVER sqlite_svr;
DROP EXTENSION sqlite_fdw;
\connect contrib_regression;
DROP DATABASE "contrib_regression_ISO_8859_6";

-- ISO_8859_7
CREATE DATABASE "contrib_regression_ISO_8859_7" ENCODING ISO_8859_7 LC_CTYPE='POSIX' LC_COLLATE='POSIX' template template0;
\connect "contrib_regression_ISO_8859_7"
CREATE EXTENSION sqlite_fdw;
CREATE SERVER sqlite_svr FOREIGN DATA WRAPPER sqlite_fdw
OPTIONS (database '/tmp/sqlite_fdw_test/common.db');
CREATE FOREIGN TABLE "Unicode data"(i text OPTIONS (key 'true'), t text) SERVER sqlite_svr; 
-- EUC_JP
SELECT * FROM "Unicode data" WHERE i = 'jap';
SELECT * FROM "Unicode data" WHERE t LIKE 'いろはにほ%';
INSERT INTO "Unicode data" (i, t) VALUES ('jap+', 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._');
DELETE FROM "Unicode data" WHERE t = 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'jap+';
-- 1251, ISO_8859_5
SELECT * FROM "Unicode data" WHERE i = 'bel';
SELECT * FROM "Unicode data" WHERE i = 'bul';
SELECT * FROM "Unicode data" WHERE i = 'rus';
SELECT * FROM "Unicode data" WHERE i = 'ukr';
SELECT * FROM "Unicode data" WHERE t LIKE 'У руд%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ах, ч%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Широк%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Гей, %';
INSERT INTO "Unicode data" (i, t) VALUES ('bel+', 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._');
SELECT * FROM "Unicode data" WHERE i = 'bel+';
DELETE FROM "Unicode data" WHERE t = 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bel+';
INSERT INTO "Unicode data" (i, t) VALUES ('bul+', 'Ах, чудна българска земьо, полюшвай цъфтящи жита._');
SELECT * FROM "Unicode data" WHERE i = 'bul+';
DELETE FROM "Unicode data" WHERE t = 'Ах, чудна българска земьо, полюшвай цъфтящи жита._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bul+';
INSERT INTO "Unicode data" (i, t) VALUES ('rus+', 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._');
SELECT * FROM "Unicode data" WHERE i = 'rus+';
DELETE FROM "Unicode data" WHERE t = 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'rus+';
INSERT INTO "Unicode data" (i, t) VALUES ('ukr+', 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._');
SELECT * FROM "Unicode data" WHERE i = 'ukr+';
DELETE FROM "Unicode data" WHERE t = 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ukr+';
-- 1256, ISO_8859_6
SELECT * FROM "Unicode data" WHERE i = 'ara';
SELECT * FROM "Unicode data" WHERE t LIKE '%ضَظَغ%';
INSERT INTO "Unicode data" (i, t) VALUES ('ara+', 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_');
SELECT * FROM "Unicode data" WHERE i = 'ara+';
DELETE FROM "Unicode data" WHERE t = 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ara+';
-- 1253, ISO_8859_7
SELECT * FROM "Unicode data" WHERE i = 'gre';
SELECT * FROM "Unicode data" WHERE t LIKE 'Τάχισ%';
INSERT INTO "Unicode data" (i, t) VALUES ('gre+', 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_');
SELECT * FROM "Unicode data" WHERE i = 'gre+';
DELETE FROM "Unicode data" WHERE t = 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_';
-- 1255, ISO_8859_8
SELECT * FROM "Unicode data" WHERE i = 'heb';
SELECT * FROM "Unicode data" WHERE t LIKE '%כי ח%';
INSERT INTO "Unicode data" (i, t) VALUES ('heb+', 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_');
SELECT * FROM "Unicode data" WHERE i = 'heb+';
DELETE FROM "Unicode data" WHERE t = 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'heb+';
-- 1252, LATIN1
SELECT * FROM "Unicode data" WHERE i = 'eus';
SELECT * FROM "Unicode data" WHERE i = 'fra';
SELECT * FROM "Unicode data" WHERE i = 'spa';
SELECT * FROM "Unicode data" WHERE t LIKE 'Permi%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Dès N%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Quier%';
INSERT INTO "Unicode data" (i, t) VALUES ('eus+', 'Permin gox dabiltzu yoskiñ._');
SELECT * FROM "Unicode data" WHERE i = 'eus+';
DELETE FROM "Unicode data" WHERE t = 'Permin gox dabiltzu yoskiñ._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'eus+';
INSERT INTO "Unicode data" (i, t) VALUES ('fra+', 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_');
SELECT * FROM "Unicode data" WHERE i = 'fra+';
DELETE FROM "Unicode data" WHERE t = 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'fra+';
INSERT INTO "Unicode data" (i, t) VALUES ('spa+', 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._');
SELECT * FROM "Unicode data" WHERE i = 'spa+';
DELETE FROM "Unicode data" WHERE t = 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'spa+';
-- 1250, LATIN2
SELECT * FROM "Unicode data" WHERE i = 'cze';
SELECT * FROM "Unicode data" WHERE i = 'pol';
SELECT * FROM "Unicode data" WHERE i = 'srp';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zvláš%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Pchną%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ljuba%';
INSERT INTO "Unicode data" (i, t) VALUES ('cze+', 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._');
SELECT * FROM "Unicode data" WHERE i = 'cze+';
DELETE FROM "Unicode data" WHERE t = 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'cze+';
INSERT INTO "Unicode data" (i, t) VALUES ('pol+', 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._');
SELECT * FROM "Unicode data" WHERE i = 'pol+';
DELETE FROM "Unicode data" WHERE t = 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'pol+';
INSERT INTO "Unicode data" (i, t) VALUES ('srp+', 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._');
SELECT * FROM "Unicode data" WHERE i = 'srp+';
DELETE FROM "Unicode data" WHERE t = 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'srp+';
-- 1257, LATIN7
SELECT * FROM "Unicode data" WHERE i = 'lav';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ķieģeļu%';
INSERT INTO "Unicode data" (i, t) VALUES ('lav+', 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._');
SELECT * FROM "Unicode data" WHERE i = 'lav+';
DELETE FROM "Unicode data" WHERE t = 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'lav+';
-- EUC_KR
SELECT * FROM "Unicode data" WHERE i = 'kor';
SELECT * FROM "Unicode data" WHERE t LIKE '키스의 고%';
INSERT INTO "Unicode data" (i, t) VALUES ('kor+', '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._');
SELECT * FROM "Unicode data" WHERE i = 'kor+';
DELETE FROM "Unicode data" WHERE t = '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'kor+';
-- 1254, LATIN5
SELECT * FROM "Unicode data" WHERE i = 'aze';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zəfər%';
INSERT INTO "Unicode data" (i, t) VALUES ('aze+', 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._');
SELECT * FROM "Unicode data" WHERE i = 'aze+';
DELETE FROM "Unicode data" WHERE t = 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'aze+';
-- etc
INSERT INTO "Unicode data" (i, t) VALUES ('arm+', 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_');
SELECT * FROM "Unicode data" WHERE i = 'arm+';
DELETE FROM "Unicode data" WHERE t = 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'arm+';
INSERT INTO "Unicode data" (i, t) VALUES ('gle+', 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._');
SELECT * FROM "Unicode data" WHERE i = 'gle+';
DELETE FROM "Unicode data" WHERE t = 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'gle+';
INSERT INTO "Unicode data" (i, t) VALUES ('epo+', 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._');
SELECT * FROM "Unicode data" WHERE i = 'epo+';
DELETE FROM "Unicode data" WHERE t = 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'epo+';

DROP FOREIGN TABLE "Unicode data";
DROP SERVER sqlite_svr;
DROP EXTENSION sqlite_fdw;
\connect contrib_regression;
DROP DATABASE "contrib_regression_ISO_8859_7";

-- ISO_8859_8
CREATE DATABASE "contrib_regression_ISO_8859_8" ENCODING ISO_8859_8 LC_CTYPE='POSIX' LC_COLLATE='POSIX' template template0;
\connect "contrib_regression_ISO_8859_8"
CREATE EXTENSION sqlite_fdw;
CREATE SERVER sqlite_svr FOREIGN DATA WRAPPER sqlite_fdw
OPTIONS (database '/tmp/sqlite_fdw_test/common.db');
CREATE FOREIGN TABLE "Unicode data"(i text OPTIONS (key 'true'), t text) SERVER sqlite_svr; 
-- EUC_JP
SELECT * FROM "Unicode data" WHERE i = 'jap';
SELECT * FROM "Unicode data" WHERE t LIKE 'いろはにほ%';
INSERT INTO "Unicode data" (i, t) VALUES ('jap+', 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._');
DELETE FROM "Unicode data" WHERE t = 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'jap+';
-- 1251, ISO_8859_5
SELECT * FROM "Unicode data" WHERE i = 'bel';
SELECT * FROM "Unicode data" WHERE i = 'bul';
SELECT * FROM "Unicode data" WHERE i = 'rus';
SELECT * FROM "Unicode data" WHERE i = 'ukr';
SELECT * FROM "Unicode data" WHERE t LIKE 'У руд%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ах, ч%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Широк%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Гей, %';
INSERT INTO "Unicode data" (i, t) VALUES ('bel+', 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._');
SELECT * FROM "Unicode data" WHERE i = 'bel+';
DELETE FROM "Unicode data" WHERE t = 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bel+';
INSERT INTO "Unicode data" (i, t) VALUES ('bul+', 'Ах, чудна българска земьо, полюшвай цъфтящи жита._');
SELECT * FROM "Unicode data" WHERE i = 'bul+';
DELETE FROM "Unicode data" WHERE t = 'Ах, чудна българска земьо, полюшвай цъфтящи жита._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bul+';
INSERT INTO "Unicode data" (i, t) VALUES ('rus+', 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._');
SELECT * FROM "Unicode data" WHERE i = 'rus+';
DELETE FROM "Unicode data" WHERE t = 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'rus+';
INSERT INTO "Unicode data" (i, t) VALUES ('ukr+', 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._');
SELECT * FROM "Unicode data" WHERE i = 'ukr+';
DELETE FROM "Unicode data" WHERE t = 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ukr+';
-- 1256, ISO_8859_6
SELECT * FROM "Unicode data" WHERE i = 'ara';
SELECT * FROM "Unicode data" WHERE t LIKE '%ضَظَغ%';
INSERT INTO "Unicode data" (i, t) VALUES ('ara+', 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_');
SELECT * FROM "Unicode data" WHERE i = 'ara+';
DELETE FROM "Unicode data" WHERE t = 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ara+';
-- 1253, ISO_8859_7
SELECT * FROM "Unicode data" WHERE i = 'gre';
SELECT * FROM "Unicode data" WHERE t LIKE 'Τάχισ%';
INSERT INTO "Unicode data" (i, t) VALUES ('gre+', 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_');
SELECT * FROM "Unicode data" WHERE i = 'gre+';
DELETE FROM "Unicode data" WHERE t = 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_';
-- 1255, ISO_8859_8
SELECT * FROM "Unicode data" WHERE i = 'heb';
SELECT * FROM "Unicode data" WHERE t LIKE '%כי ח%';
INSERT INTO "Unicode data" (i, t) VALUES ('heb+', 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_');
SELECT * FROM "Unicode data" WHERE i = 'heb+';
DELETE FROM "Unicode data" WHERE t = 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'heb+';
-- 1252, LATIN1
SELECT * FROM "Unicode data" WHERE i = 'eus';
SELECT * FROM "Unicode data" WHERE i = 'fra';
SELECT * FROM "Unicode data" WHERE i = 'spa';
SELECT * FROM "Unicode data" WHERE t LIKE 'Permi%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Dès N%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Quier%';
INSERT INTO "Unicode data" (i, t) VALUES ('eus+', 'Permin gox dabiltzu yoskiñ._');
SELECT * FROM "Unicode data" WHERE i = 'eus+';
DELETE FROM "Unicode data" WHERE t = 'Permin gox dabiltzu yoskiñ._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'eus+';
INSERT INTO "Unicode data" (i, t) VALUES ('fra+', 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_');
SELECT * FROM "Unicode data" WHERE i = 'fra+';
DELETE FROM "Unicode data" WHERE t = 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'fra+';
INSERT INTO "Unicode data" (i, t) VALUES ('spa+', 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._');
SELECT * FROM "Unicode data" WHERE i = 'spa+';
DELETE FROM "Unicode data" WHERE t = 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'spa+';
-- 1250, LATIN2
SELECT * FROM "Unicode data" WHERE i = 'cze';
SELECT * FROM "Unicode data" WHERE i = 'pol';
SELECT * FROM "Unicode data" WHERE i = 'srp';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zvláš%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Pchną%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ljuba%';
INSERT INTO "Unicode data" (i, t) VALUES ('cze+', 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._');
SELECT * FROM "Unicode data" WHERE i = 'cze+';
DELETE FROM "Unicode data" WHERE t = 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'cze+';
INSERT INTO "Unicode data" (i, t) VALUES ('pol+', 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._');
SELECT * FROM "Unicode data" WHERE i = 'pol+';
DELETE FROM "Unicode data" WHERE t = 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'pol+';
INSERT INTO "Unicode data" (i, t) VALUES ('srp+', 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._');
SELECT * FROM "Unicode data" WHERE i = 'srp+';
DELETE FROM "Unicode data" WHERE t = 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'srp+';
-- 1257, LATIN7
SELECT * FROM "Unicode data" WHERE i = 'lav';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ķieģeļu%';
INSERT INTO "Unicode data" (i, t) VALUES ('lav+', 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._');
SELECT * FROM "Unicode data" WHERE i = 'lav+';
DELETE FROM "Unicode data" WHERE t = 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'lav+';
-- EUC_KR
SELECT * FROM "Unicode data" WHERE i = 'kor';
SELECT * FROM "Unicode data" WHERE t LIKE '키스의 고%';
INSERT INTO "Unicode data" (i, t) VALUES ('kor+', '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._');
SELECT * FROM "Unicode data" WHERE i = 'kor+';
DELETE FROM "Unicode data" WHERE t = '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'kor+';
-- 1254, LATIN5
SELECT * FROM "Unicode data" WHERE i = 'aze';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zəfər%';
INSERT INTO "Unicode data" (i, t) VALUES ('aze+', 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._');
SELECT * FROM "Unicode data" WHERE i = 'aze+';
DELETE FROM "Unicode data" WHERE t = 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'aze+';
-- etc
INSERT INTO "Unicode data" (i, t) VALUES ('arm+', 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_');
SELECT * FROM "Unicode data" WHERE i = 'arm+';
DELETE FROM "Unicode data" WHERE t = 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'arm+';
INSERT INTO "Unicode data" (i, t) VALUES ('gle+', 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._');
SELECT * FROM "Unicode data" WHERE i = 'gle+';
DELETE FROM "Unicode data" WHERE t = 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'gle+';
INSERT INTO "Unicode data" (i, t) VALUES ('epo+', 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._');
SELECT * FROM "Unicode data" WHERE i = 'epo+';
DELETE FROM "Unicode data" WHERE t = 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'epo+';

DROP FOREIGN TABLE "Unicode data";
DROP SERVER sqlite_svr;
DROP EXTENSION sqlite_fdw;
\connect contrib_regression;
DROP DATABASE "contrib_regression_ISO_8859_8";

-- ISO_8859_9
CREATE DATABASE "contrib_regression_ISO_8859_9" ENCODING ISO_8859_9 LC_CTYPE='POSIX' LC_COLLATE='POSIX' template template0;
\connect "contrib_regression_ISO_8859_9"
CREATE EXTENSION sqlite_fdw;
CREATE SERVER sqlite_svr FOREIGN DATA WRAPPER sqlite_fdw
OPTIONS (database '/tmp/sqlite_fdw_test/common.db');
CREATE FOREIGN TABLE "Unicode data"(i text OPTIONS (key 'true'), t text) SERVER sqlite_svr; 
-- EUC_JP
SELECT * FROM "Unicode data" WHERE i = 'jap';
SELECT * FROM "Unicode data" WHERE t LIKE 'いろはにほ%';
INSERT INTO "Unicode data" (i, t) VALUES ('jap+', 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._');
DELETE FROM "Unicode data" WHERE t = 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'jap+';
-- 1251, ISO_8859_5
SELECT * FROM "Unicode data" WHERE i = 'bel';
SELECT * FROM "Unicode data" WHERE i = 'bul';
SELECT * FROM "Unicode data" WHERE i = 'rus';
SELECT * FROM "Unicode data" WHERE i = 'ukr';
SELECT * FROM "Unicode data" WHERE t LIKE 'У руд%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ах, ч%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Широк%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Гей, %';
INSERT INTO "Unicode data" (i, t) VALUES ('bel+', 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._');
SELECT * FROM "Unicode data" WHERE i = 'bel+';
DELETE FROM "Unicode data" WHERE t = 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bel+';
INSERT INTO "Unicode data" (i, t) VALUES ('bul+', 'Ах, чудна българска земьо, полюшвай цъфтящи жита._');
SELECT * FROM "Unicode data" WHERE i = 'bul+';
DELETE FROM "Unicode data" WHERE t = 'Ах, чудна българска земьо, полюшвай цъфтящи жита._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bul+';
INSERT INTO "Unicode data" (i, t) VALUES ('rus+', 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._');
SELECT * FROM "Unicode data" WHERE i = 'rus+';
DELETE FROM "Unicode data" WHERE t = 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'rus+';
INSERT INTO "Unicode data" (i, t) VALUES ('ukr+', 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._');
SELECT * FROM "Unicode data" WHERE i = 'ukr+';
DELETE FROM "Unicode data" WHERE t = 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ukr+';
-- 1256, ISO_8859_6
SELECT * FROM "Unicode data" WHERE i = 'ara';
SELECT * FROM "Unicode data" WHERE t LIKE '%ضَظَغ%';
INSERT INTO "Unicode data" (i, t) VALUES ('ara+', 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_');
SELECT * FROM "Unicode data" WHERE i = 'ara+';
DELETE FROM "Unicode data" WHERE t = 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ara+';
-- 1253, ISO_8859_7
SELECT * FROM "Unicode data" WHERE i = 'gre';
SELECT * FROM "Unicode data" WHERE t LIKE 'Τάχισ%';
INSERT INTO "Unicode data" (i, t) VALUES ('gre+', 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_');
SELECT * FROM "Unicode data" WHERE i = 'gre+';
DELETE FROM "Unicode data" WHERE t = 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_';
-- 1255, ISO_8859_8
SELECT * FROM "Unicode data" WHERE i = 'heb';
SELECT * FROM "Unicode data" WHERE t LIKE '%כי ח%';
INSERT INTO "Unicode data" (i, t) VALUES ('heb+', 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_');
SELECT * FROM "Unicode data" WHERE i = 'heb+';
DELETE FROM "Unicode data" WHERE t = 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'heb+';
-- 1252, LATIN1
SELECT * FROM "Unicode data" WHERE i = 'eus';
SELECT * FROM "Unicode data" WHERE i = 'fra';
SELECT * FROM "Unicode data" WHERE i = 'spa';
SELECT * FROM "Unicode data" WHERE t LIKE 'Permi%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Dès N%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Quier%';
INSERT INTO "Unicode data" (i, t) VALUES ('eus+', 'Permin gox dabiltzu yoskiñ._');
SELECT * FROM "Unicode data" WHERE i = 'eus+';
DELETE FROM "Unicode data" WHERE t = 'Permin gox dabiltzu yoskiñ._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'eus+';
INSERT INTO "Unicode data" (i, t) VALUES ('fra+', 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_');
SELECT * FROM "Unicode data" WHERE i = 'fra+';
DELETE FROM "Unicode data" WHERE t = 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'fra+';
INSERT INTO "Unicode data" (i, t) VALUES ('spa+', 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._');
SELECT * FROM "Unicode data" WHERE i = 'spa+';
DELETE FROM "Unicode data" WHERE t = 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'spa+';
-- 1250, LATIN2
SELECT * FROM "Unicode data" WHERE i = 'cze';
SELECT * FROM "Unicode data" WHERE i = 'pol';
SELECT * FROM "Unicode data" WHERE i = 'srp';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zvláš%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Pchną%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ljuba%';
INSERT INTO "Unicode data" (i, t) VALUES ('cze+', 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._');
SELECT * FROM "Unicode data" WHERE i = 'cze+';
DELETE FROM "Unicode data" WHERE t = 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'cze+';
INSERT INTO "Unicode data" (i, t) VALUES ('pol+', 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._');
SELECT * FROM "Unicode data" WHERE i = 'pol+';
DELETE FROM "Unicode data" WHERE t = 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'pol+';
INSERT INTO "Unicode data" (i, t) VALUES ('srp+', 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._');
SELECT * FROM "Unicode data" WHERE i = 'srp+';
DELETE FROM "Unicode data" WHERE t = 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'srp+';
-- 1257, LATIN7
SELECT * FROM "Unicode data" WHERE i = 'lav';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ķieģeļu%';
INSERT INTO "Unicode data" (i, t) VALUES ('lav+', 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._');
SELECT * FROM "Unicode data" WHERE i = 'lav+';
DELETE FROM "Unicode data" WHERE t = 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'lav+';
-- EUC_KR
SELECT * FROM "Unicode data" WHERE i = 'kor';
SELECT * FROM "Unicode data" WHERE t LIKE '키스의 고%';
INSERT INTO "Unicode data" (i, t) VALUES ('kor+', '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._');
SELECT * FROM "Unicode data" WHERE i = 'kor+';
DELETE FROM "Unicode data" WHERE t = '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'kor+';
-- 1254, LATIN5
SELECT * FROM "Unicode data" WHERE i = 'aze';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zəfər%';
INSERT INTO "Unicode data" (i, t) VALUES ('aze+', 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._');
SELECT * FROM "Unicode data" WHERE i = 'aze+';
DELETE FROM "Unicode data" WHERE t = 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'aze+';
-- etc
INSERT INTO "Unicode data" (i, t) VALUES ('arm+', 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_');
SELECT * FROM "Unicode data" WHERE i = 'arm+';
DELETE FROM "Unicode data" WHERE t = 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'arm+';
INSERT INTO "Unicode data" (i, t) VALUES ('gle+', 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._');
SELECT * FROM "Unicode data" WHERE i = 'gle+';
DELETE FROM "Unicode data" WHERE t = 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'gle+';
INSERT INTO "Unicode data" (i, t) VALUES ('epo+', 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._');
SELECT * FROM "Unicode data" WHERE i = 'epo+';
DELETE FROM "Unicode data" WHERE t = 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'epo+';

DROP FOREIGN TABLE "Unicode data";
DROP SERVER sqlite_svr;
DROP EXTENSION sqlite_fdw;
\connect contrib_regression;
DROP DATABASE "contrib_regression_ISO_8859_9";

-- LATIN1
CREATE DATABASE "contrib_regression_LATIN1" ENCODING LATIN1 LC_CTYPE='POSIX' LC_COLLATE='POSIX' template template0;
\connect "contrib_regression_LATIN1"
CREATE EXTENSION sqlite_fdw;
CREATE SERVER sqlite_svr FOREIGN DATA WRAPPER sqlite_fdw
OPTIONS (database '/tmp/sqlite_fdw_test/common.db');
CREATE FOREIGN TABLE "Unicode data"(i text OPTIONS (key 'true'), t text) SERVER sqlite_svr; 
-- EUC_JP
SELECT * FROM "Unicode data" WHERE i = 'jap';
SELECT * FROM "Unicode data" WHERE t LIKE 'いろはにほ%';
INSERT INTO "Unicode data" (i, t) VALUES ('jap+', 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._');
DELETE FROM "Unicode data" WHERE t = 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'jap+';
-- 1251, ISO_8859_5
SELECT * FROM "Unicode data" WHERE i = 'bel';
SELECT * FROM "Unicode data" WHERE i = 'bul';
SELECT * FROM "Unicode data" WHERE i = 'rus';
SELECT * FROM "Unicode data" WHERE i = 'ukr';
SELECT * FROM "Unicode data" WHERE t LIKE 'У руд%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ах, ч%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Широк%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Гей, %';
INSERT INTO "Unicode data" (i, t) VALUES ('bel+', 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._');
SELECT * FROM "Unicode data" WHERE i = 'bel+';
DELETE FROM "Unicode data" WHERE t = 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bel+';
INSERT INTO "Unicode data" (i, t) VALUES ('bul+', 'Ах, чудна българска земьо, полюшвай цъфтящи жита._');
SELECT * FROM "Unicode data" WHERE i = 'bul+';
DELETE FROM "Unicode data" WHERE t = 'Ах, чудна българска земьо, полюшвай цъфтящи жита._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bul+';
INSERT INTO "Unicode data" (i, t) VALUES ('rus+', 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._');
SELECT * FROM "Unicode data" WHERE i = 'rus+';
DELETE FROM "Unicode data" WHERE t = 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'rus+';
INSERT INTO "Unicode data" (i, t) VALUES ('ukr+', 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._');
SELECT * FROM "Unicode data" WHERE i = 'ukr+';
DELETE FROM "Unicode data" WHERE t = 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ukr+';
-- 1256, ISO_8859_6
SELECT * FROM "Unicode data" WHERE i = 'ara';
SELECT * FROM "Unicode data" WHERE t LIKE '%ضَظَغ%';
INSERT INTO "Unicode data" (i, t) VALUES ('ara+', 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_');
SELECT * FROM "Unicode data" WHERE i = 'ara+';
DELETE FROM "Unicode data" WHERE t = 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ara+';
-- 1253, ISO_8859_7
SELECT * FROM "Unicode data" WHERE i = 'gre';
SELECT * FROM "Unicode data" WHERE t LIKE 'Τάχισ%';
INSERT INTO "Unicode data" (i, t) VALUES ('gre+', 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_');
SELECT * FROM "Unicode data" WHERE i = 'gre+';
DELETE FROM "Unicode data" WHERE t = 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_';
-- 1255, ISO_8859_8
SELECT * FROM "Unicode data" WHERE i = 'heb';
SELECT * FROM "Unicode data" WHERE t LIKE '%כי ח%';
INSERT INTO "Unicode data" (i, t) VALUES ('heb+', 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_');
SELECT * FROM "Unicode data" WHERE i = 'heb+';
DELETE FROM "Unicode data" WHERE t = 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'heb+';
-- 1252, LATIN1
SELECT * FROM "Unicode data" WHERE i = 'eus';
SELECT * FROM "Unicode data" WHERE i = 'fra';
SELECT * FROM "Unicode data" WHERE i = 'spa';
SELECT * FROM "Unicode data" WHERE t LIKE 'Permi%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Dès N%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Quier%';
INSERT INTO "Unicode data" (i, t) VALUES ('eus+', 'Permin gox dabiltzu yoskiñ._');
SELECT * FROM "Unicode data" WHERE i = 'eus+';
DELETE FROM "Unicode data" WHERE t = 'Permin gox dabiltzu yoskiñ._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'eus+';
INSERT INTO "Unicode data" (i, t) VALUES ('fra+', 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_');
SELECT * FROM "Unicode data" WHERE i = 'fra+';
DELETE FROM "Unicode data" WHERE t = 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'fra+';
INSERT INTO "Unicode data" (i, t) VALUES ('spa+', 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._');
SELECT * FROM "Unicode data" WHERE i = 'spa+';
DELETE FROM "Unicode data" WHERE t = 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'spa+';
-- 1250, LATIN2
SELECT * FROM "Unicode data" WHERE i = 'cze';
SELECT * FROM "Unicode data" WHERE i = 'pol';
SELECT * FROM "Unicode data" WHERE i = 'srp';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zvláš%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Pchną%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ljuba%';
INSERT INTO "Unicode data" (i, t) VALUES ('cze+', 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._');
SELECT * FROM "Unicode data" WHERE i = 'cze+';
DELETE FROM "Unicode data" WHERE t = 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'cze+';
INSERT INTO "Unicode data" (i, t) VALUES ('pol+', 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._');
SELECT * FROM "Unicode data" WHERE i = 'pol+';
DELETE FROM "Unicode data" WHERE t = 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'pol+';
INSERT INTO "Unicode data" (i, t) VALUES ('srp+', 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._');
SELECT * FROM "Unicode data" WHERE i = 'srp+';
DELETE FROM "Unicode data" WHERE t = 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'srp+';
-- 1257, LATIN7
SELECT * FROM "Unicode data" WHERE i = 'lav';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ķieģeļu%';
INSERT INTO "Unicode data" (i, t) VALUES ('lav+', 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._');
SELECT * FROM "Unicode data" WHERE i = 'lav+';
DELETE FROM "Unicode data" WHERE t = 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'lav+';
-- EUC_KR
SELECT * FROM "Unicode data" WHERE i = 'kor';
SELECT * FROM "Unicode data" WHERE t LIKE '키스의 고%';
INSERT INTO "Unicode data" (i, t) VALUES ('kor+', '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._');
SELECT * FROM "Unicode data" WHERE i = 'kor+';
DELETE FROM "Unicode data" WHERE t = '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'kor+';
-- 1254, LATIN5
SELECT * FROM "Unicode data" WHERE i = 'aze';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zəfər%';
INSERT INTO "Unicode data" (i, t) VALUES ('aze+', 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._');
SELECT * FROM "Unicode data" WHERE i = 'aze+';
DELETE FROM "Unicode data" WHERE t = 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'aze+';
-- etc
INSERT INTO "Unicode data" (i, t) VALUES ('arm+', 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_');
SELECT * FROM "Unicode data" WHERE i = 'arm+';
DELETE FROM "Unicode data" WHERE t = 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'arm+';
INSERT INTO "Unicode data" (i, t) VALUES ('gle+', 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._');
SELECT * FROM "Unicode data" WHERE i = 'gle+';
DELETE FROM "Unicode data" WHERE t = 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'gle+';
INSERT INTO "Unicode data" (i, t) VALUES ('epo+', 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._');
SELECT * FROM "Unicode data" WHERE i = 'epo+';
DELETE FROM "Unicode data" WHERE t = 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'epo+';

DROP FOREIGN TABLE "Unicode data";
DROP SERVER sqlite_svr;
DROP EXTENSION sqlite_fdw;
\connect contrib_regression;
DROP DATABASE "contrib_regression_LATIN1";

-- LATIN2
CREATE DATABASE "contrib_regression_LATIN2" ENCODING LATIN2 LC_CTYPE='POSIX' LC_COLLATE='POSIX' template template0;
\connect "contrib_regression_LATIN2"
CREATE EXTENSION sqlite_fdw;
CREATE SERVER sqlite_svr FOREIGN DATA WRAPPER sqlite_fdw
OPTIONS (database '/tmp/sqlite_fdw_test/common.db');
CREATE FOREIGN TABLE "Unicode data"(i text OPTIONS (key 'true'), t text) SERVER sqlite_svr; 
-- EUC_JP
SELECT * FROM "Unicode data" WHERE i = 'jap';
SELECT * FROM "Unicode data" WHERE t LIKE 'いろはにほ%';
INSERT INTO "Unicode data" (i, t) VALUES ('jap+', 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._');
DELETE FROM "Unicode data" WHERE t = 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'jap+';
-- 1251, ISO_8859_5
SELECT * FROM "Unicode data" WHERE i = 'bel';
SELECT * FROM "Unicode data" WHERE i = 'bul';
SELECT * FROM "Unicode data" WHERE i = 'rus';
SELECT * FROM "Unicode data" WHERE i = 'ukr';
SELECT * FROM "Unicode data" WHERE t LIKE 'У руд%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ах, ч%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Широк%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Гей, %';
INSERT INTO "Unicode data" (i, t) VALUES ('bel+', 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._');
SELECT * FROM "Unicode data" WHERE i = 'bel+';
DELETE FROM "Unicode data" WHERE t = 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bel+';
INSERT INTO "Unicode data" (i, t) VALUES ('bul+', 'Ах, чудна българска земьо, полюшвай цъфтящи жита._');
SELECT * FROM "Unicode data" WHERE i = 'bul+';
DELETE FROM "Unicode data" WHERE t = 'Ах, чудна българска земьо, полюшвай цъфтящи жита._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bul+';
INSERT INTO "Unicode data" (i, t) VALUES ('rus+', 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._');
SELECT * FROM "Unicode data" WHERE i = 'rus+';
DELETE FROM "Unicode data" WHERE t = 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'rus+';
INSERT INTO "Unicode data" (i, t) VALUES ('ukr+', 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._');
SELECT * FROM "Unicode data" WHERE i = 'ukr+';
DELETE FROM "Unicode data" WHERE t = 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ukr+';
-- 1256, ISO_8859_6
SELECT * FROM "Unicode data" WHERE i = 'ara';
SELECT * FROM "Unicode data" WHERE t LIKE '%ضَظَغ%';
INSERT INTO "Unicode data" (i, t) VALUES ('ara+', 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_');
SELECT * FROM "Unicode data" WHERE i = 'ara+';
DELETE FROM "Unicode data" WHERE t = 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ara+';
-- 1253, ISO_8859_7
SELECT * FROM "Unicode data" WHERE i = 'gre';
SELECT * FROM "Unicode data" WHERE t LIKE 'Τάχισ%';
INSERT INTO "Unicode data" (i, t) VALUES ('gre+', 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_');
SELECT * FROM "Unicode data" WHERE i = 'gre+';
DELETE FROM "Unicode data" WHERE t = 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_';
-- 1255, ISO_8859_8
SELECT * FROM "Unicode data" WHERE i = 'heb';
SELECT * FROM "Unicode data" WHERE t LIKE '%כי ח%';
INSERT INTO "Unicode data" (i, t) VALUES ('heb+', 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_');
SELECT * FROM "Unicode data" WHERE i = 'heb+';
DELETE FROM "Unicode data" WHERE t = 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'heb+';
-- 1252, LATIN1
SELECT * FROM "Unicode data" WHERE i = 'eus';
SELECT * FROM "Unicode data" WHERE i = 'fra';
SELECT * FROM "Unicode data" WHERE i = 'spa';
SELECT * FROM "Unicode data" WHERE t LIKE 'Permi%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Dès N%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Quier%';
INSERT INTO "Unicode data" (i, t) VALUES ('eus+', 'Permin gox dabiltzu yoskiñ._');
SELECT * FROM "Unicode data" WHERE i = 'eus+';
DELETE FROM "Unicode data" WHERE t = 'Permin gox dabiltzu yoskiñ._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'eus+';
INSERT INTO "Unicode data" (i, t) VALUES ('fra+', 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_');
SELECT * FROM "Unicode data" WHERE i = 'fra+';
DELETE FROM "Unicode data" WHERE t = 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'fra+';
INSERT INTO "Unicode data" (i, t) VALUES ('spa+', 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._');
SELECT * FROM "Unicode data" WHERE i = 'spa+';
DELETE FROM "Unicode data" WHERE t = 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'spa+';
-- 1250, LATIN2
SELECT * FROM "Unicode data" WHERE i = 'cze';
SELECT * FROM "Unicode data" WHERE i = 'pol';
SELECT * FROM "Unicode data" WHERE i = 'srp';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zvláš%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Pchną%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ljuba%';
INSERT INTO "Unicode data" (i, t) VALUES ('cze+', 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._');
SELECT * FROM "Unicode data" WHERE i = 'cze+';
DELETE FROM "Unicode data" WHERE t = 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'cze+';
INSERT INTO "Unicode data" (i, t) VALUES ('pol+', 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._');
SELECT * FROM "Unicode data" WHERE i = 'pol+';
DELETE FROM "Unicode data" WHERE t = 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'pol+';
INSERT INTO "Unicode data" (i, t) VALUES ('srp+', 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._');
SELECT * FROM "Unicode data" WHERE i = 'srp+';
DELETE FROM "Unicode data" WHERE t = 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'srp+';
-- 1257, LATIN7
SELECT * FROM "Unicode data" WHERE i = 'lav';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ķieģeļu%';
INSERT INTO "Unicode data" (i, t) VALUES ('lav+', 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._');
SELECT * FROM "Unicode data" WHERE i = 'lav+';
DELETE FROM "Unicode data" WHERE t = 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'lav+';
-- EUC_KR
SELECT * FROM "Unicode data" WHERE i = 'kor';
SELECT * FROM "Unicode data" WHERE t LIKE '키스의 고%';
INSERT INTO "Unicode data" (i, t) VALUES ('kor+', '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._');
SELECT * FROM "Unicode data" WHERE i = 'kor+';
DELETE FROM "Unicode data" WHERE t = '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'kor+';
-- 1254, LATIN5
SELECT * FROM "Unicode data" WHERE i = 'aze';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zəfər%';
INSERT INTO "Unicode data" (i, t) VALUES ('aze+', 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._');
SELECT * FROM "Unicode data" WHERE i = 'aze+';
DELETE FROM "Unicode data" WHERE t = 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'aze+';
-- etc
INSERT INTO "Unicode data" (i, t) VALUES ('arm+', 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_');
SELECT * FROM "Unicode data" WHERE i = 'arm+';
DELETE FROM "Unicode data" WHERE t = 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'arm+';
INSERT INTO "Unicode data" (i, t) VALUES ('gle+', 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._');
SELECT * FROM "Unicode data" WHERE i = 'gle+';
DELETE FROM "Unicode data" WHERE t = 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'gle+';
INSERT INTO "Unicode data" (i, t) VALUES ('epo+', 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._');
SELECT * FROM "Unicode data" WHERE i = 'epo+';
DELETE FROM "Unicode data" WHERE t = 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'epo+';

DROP FOREIGN TABLE "Unicode data";
DROP SERVER sqlite_svr;
DROP EXTENSION sqlite_fdw;
\connect contrib_regression;
DROP DATABASE "contrib_regression_LATIN2";

-- LATIN3
CREATE DATABASE "contrib_regression_LATIN3" ENCODING LATIN3 LC_CTYPE='POSIX' LC_COLLATE='POSIX' template template0;
\connect "contrib_regression_LATIN3"
CREATE EXTENSION sqlite_fdw;
CREATE SERVER sqlite_svr FOREIGN DATA WRAPPER sqlite_fdw
OPTIONS (database '/tmp/sqlite_fdw_test/common.db');
CREATE FOREIGN TABLE "Unicode data"(i text OPTIONS (key 'true'), t text) SERVER sqlite_svr; 
-- EUC_JP
SELECT * FROM "Unicode data" WHERE i = 'jap';
SELECT * FROM "Unicode data" WHERE t LIKE 'いろはにほ%';
INSERT INTO "Unicode data" (i, t) VALUES ('jap+', 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._');
DELETE FROM "Unicode data" WHERE t = 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'jap+';
-- 1251, ISO_8859_5
SELECT * FROM "Unicode data" WHERE i = 'bel';
SELECT * FROM "Unicode data" WHERE i = 'bul';
SELECT * FROM "Unicode data" WHERE i = 'rus';
SELECT * FROM "Unicode data" WHERE i = 'ukr';
SELECT * FROM "Unicode data" WHERE t LIKE 'У руд%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ах, ч%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Широк%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Гей, %';
INSERT INTO "Unicode data" (i, t) VALUES ('bel+', 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._');
SELECT * FROM "Unicode data" WHERE i = 'bel+';
DELETE FROM "Unicode data" WHERE t = 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bel+';
INSERT INTO "Unicode data" (i, t) VALUES ('bul+', 'Ах, чудна българска земьо, полюшвай цъфтящи жита._');
SELECT * FROM "Unicode data" WHERE i = 'bul+';
DELETE FROM "Unicode data" WHERE t = 'Ах, чудна българска земьо, полюшвай цъфтящи жита._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bul+';
INSERT INTO "Unicode data" (i, t) VALUES ('rus+', 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._');
SELECT * FROM "Unicode data" WHERE i = 'rus+';
DELETE FROM "Unicode data" WHERE t = 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'rus+';
INSERT INTO "Unicode data" (i, t) VALUES ('ukr+', 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._');
SELECT * FROM "Unicode data" WHERE i = 'ukr+';
DELETE FROM "Unicode data" WHERE t = 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ukr+';
-- 1256, ISO_8859_6
SELECT * FROM "Unicode data" WHERE i = 'ara';
SELECT * FROM "Unicode data" WHERE t LIKE '%ضَظَغ%';
INSERT INTO "Unicode data" (i, t) VALUES ('ara+', 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_');
SELECT * FROM "Unicode data" WHERE i = 'ara+';
DELETE FROM "Unicode data" WHERE t = 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ara+';
-- 1253, ISO_8859_7
SELECT * FROM "Unicode data" WHERE i = 'gre';
SELECT * FROM "Unicode data" WHERE t LIKE 'Τάχισ%';
INSERT INTO "Unicode data" (i, t) VALUES ('gre+', 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_');
SELECT * FROM "Unicode data" WHERE i = 'gre+';
DELETE FROM "Unicode data" WHERE t = 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_';
-- 1255, ISO_8859_8
SELECT * FROM "Unicode data" WHERE i = 'heb';
SELECT * FROM "Unicode data" WHERE t LIKE '%כי ח%';
INSERT INTO "Unicode data" (i, t) VALUES ('heb+', 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_');
SELECT * FROM "Unicode data" WHERE i = 'heb+';
DELETE FROM "Unicode data" WHERE t = 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'heb+';
-- 1252, LATIN1
SELECT * FROM "Unicode data" WHERE i = 'eus';
SELECT * FROM "Unicode data" WHERE i = 'fra';
SELECT * FROM "Unicode data" WHERE i = 'spa';
SELECT * FROM "Unicode data" WHERE t LIKE 'Permi%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Dès N%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Quier%';
INSERT INTO "Unicode data" (i, t) VALUES ('eus+', 'Permin gox dabiltzu yoskiñ._');
SELECT * FROM "Unicode data" WHERE i = 'eus+';
DELETE FROM "Unicode data" WHERE t = 'Permin gox dabiltzu yoskiñ._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'eus+';
INSERT INTO "Unicode data" (i, t) VALUES ('fra+', 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_');
SELECT * FROM "Unicode data" WHERE i = 'fra+';
DELETE FROM "Unicode data" WHERE t = 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'fra+';
INSERT INTO "Unicode data" (i, t) VALUES ('spa+', 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._');
SELECT * FROM "Unicode data" WHERE i = 'spa+';
DELETE FROM "Unicode data" WHERE t = 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'spa+';
-- 1250, LATIN2
SELECT * FROM "Unicode data" WHERE i = 'cze';
SELECT * FROM "Unicode data" WHERE i = 'pol';
SELECT * FROM "Unicode data" WHERE i = 'srp';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zvláš%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Pchną%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ljuba%';
INSERT INTO "Unicode data" (i, t) VALUES ('cze+', 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._');
SELECT * FROM "Unicode data" WHERE i = 'cze+';
DELETE FROM "Unicode data" WHERE t = 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'cze+';
INSERT INTO "Unicode data" (i, t) VALUES ('pol+', 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._');
SELECT * FROM "Unicode data" WHERE i = 'pol+';
DELETE FROM "Unicode data" WHERE t = 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'pol+';
INSERT INTO "Unicode data" (i, t) VALUES ('srp+', 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._');
SELECT * FROM "Unicode data" WHERE i = 'srp+';
DELETE FROM "Unicode data" WHERE t = 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'srp+';
-- 1257, LATIN7
SELECT * FROM "Unicode data" WHERE i = 'lav';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ķieģeļu%';
INSERT INTO "Unicode data" (i, t) VALUES ('lav+', 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._');
SELECT * FROM "Unicode data" WHERE i = 'lav+';
DELETE FROM "Unicode data" WHERE t = 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'lav+';
-- EUC_KR
SELECT * FROM "Unicode data" WHERE i = 'kor';
SELECT * FROM "Unicode data" WHERE t LIKE '키스의 고%';
INSERT INTO "Unicode data" (i, t) VALUES ('kor+', '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._');
SELECT * FROM "Unicode data" WHERE i = 'kor+';
DELETE FROM "Unicode data" WHERE t = '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'kor+';
-- 1254, LATIN5
SELECT * FROM "Unicode data" WHERE i = 'aze';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zəfər%';
INSERT INTO "Unicode data" (i, t) VALUES ('aze+', 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._');
SELECT * FROM "Unicode data" WHERE i = 'aze+';
DELETE FROM "Unicode data" WHERE t = 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'aze+';
-- etc
INSERT INTO "Unicode data" (i, t) VALUES ('arm+', 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_');
SELECT * FROM "Unicode data" WHERE i = 'arm+';
DELETE FROM "Unicode data" WHERE t = 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'arm+';
INSERT INTO "Unicode data" (i, t) VALUES ('gle+', 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._');
SELECT * FROM "Unicode data" WHERE i = 'gle+';
DELETE FROM "Unicode data" WHERE t = 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'gle+';
INSERT INTO "Unicode data" (i, t) VALUES ('epo+', 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._');
SELECT * FROM "Unicode data" WHERE i = 'epo+';
DELETE FROM "Unicode data" WHERE t = 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'epo+';

DROP FOREIGN TABLE "Unicode data";
DROP SERVER sqlite_svr;
DROP EXTENSION sqlite_fdw;
\connect contrib_regression;
DROP DATABASE "contrib_regression_LATIN3";

-- LATIN4
CREATE DATABASE "contrib_regression_LATIN4" ENCODING LATIN4 LC_CTYPE='POSIX' LC_COLLATE='POSIX' template template0;
\connect "contrib_regression_LATIN4"
CREATE EXTENSION sqlite_fdw;
CREATE SERVER sqlite_svr FOREIGN DATA WRAPPER sqlite_fdw
OPTIONS (database '/tmp/sqlite_fdw_test/common.db');
CREATE FOREIGN TABLE "Unicode data"(i text OPTIONS (key 'true'), t text) SERVER sqlite_svr; 
-- EUC_JP
SELECT * FROM "Unicode data" WHERE i = 'jap';
SELECT * FROM "Unicode data" WHERE t LIKE 'いろはにほ%';
INSERT INTO "Unicode data" (i, t) VALUES ('jap+', 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._');
DELETE FROM "Unicode data" WHERE t = 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'jap+';
-- 1251, ISO_8859_5
SELECT * FROM "Unicode data" WHERE i = 'bel';
SELECT * FROM "Unicode data" WHERE i = 'bul';
SELECT * FROM "Unicode data" WHERE i = 'rus';
SELECT * FROM "Unicode data" WHERE i = 'ukr';
SELECT * FROM "Unicode data" WHERE t LIKE 'У руд%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ах, ч%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Широк%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Гей, %';
INSERT INTO "Unicode data" (i, t) VALUES ('bel+', 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._');
SELECT * FROM "Unicode data" WHERE i = 'bel+';
DELETE FROM "Unicode data" WHERE t = 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bel+';
INSERT INTO "Unicode data" (i, t) VALUES ('bul+', 'Ах, чудна българска земьо, полюшвай цъфтящи жита._');
SELECT * FROM "Unicode data" WHERE i = 'bul+';
DELETE FROM "Unicode data" WHERE t = 'Ах, чудна българска земьо, полюшвай цъфтящи жита._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bul+';
INSERT INTO "Unicode data" (i, t) VALUES ('rus+', 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._');
SELECT * FROM "Unicode data" WHERE i = 'rus+';
DELETE FROM "Unicode data" WHERE t = 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'rus+';
INSERT INTO "Unicode data" (i, t) VALUES ('ukr+', 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._');
SELECT * FROM "Unicode data" WHERE i = 'ukr+';
DELETE FROM "Unicode data" WHERE t = 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ukr+';
-- 1256, ISO_8859_6
SELECT * FROM "Unicode data" WHERE i = 'ara';
SELECT * FROM "Unicode data" WHERE t LIKE '%ضَظَغ%';
INSERT INTO "Unicode data" (i, t) VALUES ('ara+', 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_');
SELECT * FROM "Unicode data" WHERE i = 'ara+';
DELETE FROM "Unicode data" WHERE t = 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ara+';
-- 1253, ISO_8859_7
SELECT * FROM "Unicode data" WHERE i = 'gre';
SELECT * FROM "Unicode data" WHERE t LIKE 'Τάχισ%';
INSERT INTO "Unicode data" (i, t) VALUES ('gre+', 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_');
SELECT * FROM "Unicode data" WHERE i = 'gre+';
DELETE FROM "Unicode data" WHERE t = 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_';
-- 1255, ISO_8859_8
SELECT * FROM "Unicode data" WHERE i = 'heb';
SELECT * FROM "Unicode data" WHERE t LIKE '%כי ח%';
INSERT INTO "Unicode data" (i, t) VALUES ('heb+', 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_');
SELECT * FROM "Unicode data" WHERE i = 'heb+';
DELETE FROM "Unicode data" WHERE t = 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'heb+';
-- 1252, LATIN1
SELECT * FROM "Unicode data" WHERE i = 'eus';
SELECT * FROM "Unicode data" WHERE i = 'fra';
SELECT * FROM "Unicode data" WHERE i = 'spa';
SELECT * FROM "Unicode data" WHERE t LIKE 'Permi%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Dès N%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Quier%';
INSERT INTO "Unicode data" (i, t) VALUES ('eus+', 'Permin gox dabiltzu yoskiñ._');
SELECT * FROM "Unicode data" WHERE i = 'eus+';
DELETE FROM "Unicode data" WHERE t = 'Permin gox dabiltzu yoskiñ._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'eus+';
INSERT INTO "Unicode data" (i, t) VALUES ('fra+', 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_');
SELECT * FROM "Unicode data" WHERE i = 'fra+';
DELETE FROM "Unicode data" WHERE t = 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'fra+';
INSERT INTO "Unicode data" (i, t) VALUES ('spa+', 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._');
SELECT * FROM "Unicode data" WHERE i = 'spa+';
DELETE FROM "Unicode data" WHERE t = 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'spa+';
-- 1250, LATIN2
SELECT * FROM "Unicode data" WHERE i = 'cze';
SELECT * FROM "Unicode data" WHERE i = 'pol';
SELECT * FROM "Unicode data" WHERE i = 'srp';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zvláš%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Pchną%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ljuba%';
INSERT INTO "Unicode data" (i, t) VALUES ('cze+', 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._');
SELECT * FROM "Unicode data" WHERE i = 'cze+';
DELETE FROM "Unicode data" WHERE t = 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'cze+';
INSERT INTO "Unicode data" (i, t) VALUES ('pol+', 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._');
SELECT * FROM "Unicode data" WHERE i = 'pol+';
DELETE FROM "Unicode data" WHERE t = 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'pol+';
INSERT INTO "Unicode data" (i, t) VALUES ('srp+', 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._');
SELECT * FROM "Unicode data" WHERE i = 'srp+';
DELETE FROM "Unicode data" WHERE t = 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'srp+';
-- 1257, LATIN7
SELECT * FROM "Unicode data" WHERE i = 'lav';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ķieģeļu%';
INSERT INTO "Unicode data" (i, t) VALUES ('lav+', 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._');
SELECT * FROM "Unicode data" WHERE i = 'lav+';
DELETE FROM "Unicode data" WHERE t = 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'lav+';
-- EUC_KR
SELECT * FROM "Unicode data" WHERE i = 'kor';
SELECT * FROM "Unicode data" WHERE t LIKE '키스의 고%';
INSERT INTO "Unicode data" (i, t) VALUES ('kor+', '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._');
SELECT * FROM "Unicode data" WHERE i = 'kor+';
DELETE FROM "Unicode data" WHERE t = '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'kor+';
-- 1254, LATIN5
SELECT * FROM "Unicode data" WHERE i = 'aze';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zəfər%';
INSERT INTO "Unicode data" (i, t) VALUES ('aze+', 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._');
SELECT * FROM "Unicode data" WHERE i = 'aze+';
DELETE FROM "Unicode data" WHERE t = 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'aze+';
-- etc
INSERT INTO "Unicode data" (i, t) VALUES ('arm+', 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_');
SELECT * FROM "Unicode data" WHERE i = 'arm+';
DELETE FROM "Unicode data" WHERE t = 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'arm+';
INSERT INTO "Unicode data" (i, t) VALUES ('gle+', 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._');
SELECT * FROM "Unicode data" WHERE i = 'gle+';
DELETE FROM "Unicode data" WHERE t = 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'gle+';
INSERT INTO "Unicode data" (i, t) VALUES ('epo+', 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._');
SELECT * FROM "Unicode data" WHERE i = 'epo+';
DELETE FROM "Unicode data" WHERE t = 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'epo+';

DROP FOREIGN TABLE "Unicode data";
DROP SERVER sqlite_svr;
DROP EXTENSION sqlite_fdw;
\connect contrib_regression;
DROP DATABASE "contrib_regression_LATIN4";

-- LATIN5
CREATE DATABASE "contrib_regression_LATIN5" ENCODING LATIN5 LC_CTYPE='POSIX' LC_COLLATE='POSIX' template template0;
\connect "contrib_regression_LATIN5"
CREATE EXTENSION sqlite_fdw;
CREATE SERVER sqlite_svr FOREIGN DATA WRAPPER sqlite_fdw
OPTIONS (database '/tmp/sqlite_fdw_test/common.db');
CREATE FOREIGN TABLE "Unicode data"(i text OPTIONS (key 'true'), t text) SERVER sqlite_svr; 
-- EUC_JP
SELECT * FROM "Unicode data" WHERE i = 'jap';
SELECT * FROM "Unicode data" WHERE t LIKE 'いろはにほ%';
INSERT INTO "Unicode data" (i, t) VALUES ('jap+', 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._');
DELETE FROM "Unicode data" WHERE t = 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'jap+';
-- 1251, ISO_8859_5
SELECT * FROM "Unicode data" WHERE i = 'bel';
SELECT * FROM "Unicode data" WHERE i = 'bul';
SELECT * FROM "Unicode data" WHERE i = 'rus';
SELECT * FROM "Unicode data" WHERE i = 'ukr';
SELECT * FROM "Unicode data" WHERE t LIKE 'У руд%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ах, ч%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Широк%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Гей, %';
INSERT INTO "Unicode data" (i, t) VALUES ('bel+', 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._');
SELECT * FROM "Unicode data" WHERE i = 'bel+';
DELETE FROM "Unicode data" WHERE t = 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bel+';
INSERT INTO "Unicode data" (i, t) VALUES ('bul+', 'Ах, чудна българска земьо, полюшвай цъфтящи жита._');
SELECT * FROM "Unicode data" WHERE i = 'bul+';
DELETE FROM "Unicode data" WHERE t = 'Ах, чудна българска земьо, полюшвай цъфтящи жита._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bul+';
INSERT INTO "Unicode data" (i, t) VALUES ('rus+', 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._');
SELECT * FROM "Unicode data" WHERE i = 'rus+';
DELETE FROM "Unicode data" WHERE t = 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'rus+';
INSERT INTO "Unicode data" (i, t) VALUES ('ukr+', 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._');
SELECT * FROM "Unicode data" WHERE i = 'ukr+';
DELETE FROM "Unicode data" WHERE t = 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ukr+';
-- 1256, ISO_8859_6
SELECT * FROM "Unicode data" WHERE i = 'ara';
SELECT * FROM "Unicode data" WHERE t LIKE '%ضَظَغ%';
INSERT INTO "Unicode data" (i, t) VALUES ('ara+', 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_');
SELECT * FROM "Unicode data" WHERE i = 'ara+';
DELETE FROM "Unicode data" WHERE t = 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ara+';
-- 1253, ISO_8859_7
SELECT * FROM "Unicode data" WHERE i = 'gre';
SELECT * FROM "Unicode data" WHERE t LIKE 'Τάχισ%';
INSERT INTO "Unicode data" (i, t) VALUES ('gre+', 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_');
SELECT * FROM "Unicode data" WHERE i = 'gre+';
DELETE FROM "Unicode data" WHERE t = 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_';
-- 1255, ISO_8859_8
SELECT * FROM "Unicode data" WHERE i = 'heb';
SELECT * FROM "Unicode data" WHERE t LIKE '%כי ח%';
INSERT INTO "Unicode data" (i, t) VALUES ('heb+', 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_');
SELECT * FROM "Unicode data" WHERE i = 'heb+';
DELETE FROM "Unicode data" WHERE t = 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'heb+';
-- 1252, LATIN1
SELECT * FROM "Unicode data" WHERE i = 'eus';
SELECT * FROM "Unicode data" WHERE i = 'fra';
SELECT * FROM "Unicode data" WHERE i = 'spa';
SELECT * FROM "Unicode data" WHERE t LIKE 'Permi%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Dès N%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Quier%';
INSERT INTO "Unicode data" (i, t) VALUES ('eus+', 'Permin gox dabiltzu yoskiñ._');
SELECT * FROM "Unicode data" WHERE i = 'eus+';
DELETE FROM "Unicode data" WHERE t = 'Permin gox dabiltzu yoskiñ._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'eus+';
INSERT INTO "Unicode data" (i, t) VALUES ('fra+', 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_');
SELECT * FROM "Unicode data" WHERE i = 'fra+';
DELETE FROM "Unicode data" WHERE t = 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'fra+';
INSERT INTO "Unicode data" (i, t) VALUES ('spa+', 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._');
SELECT * FROM "Unicode data" WHERE i = 'spa+';
DELETE FROM "Unicode data" WHERE t = 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'spa+';
-- 1250, LATIN2
SELECT * FROM "Unicode data" WHERE i = 'cze';
SELECT * FROM "Unicode data" WHERE i = 'pol';
SELECT * FROM "Unicode data" WHERE i = 'srp';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zvláš%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Pchną%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ljuba%';
INSERT INTO "Unicode data" (i, t) VALUES ('cze+', 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._');
SELECT * FROM "Unicode data" WHERE i = 'cze+';
DELETE FROM "Unicode data" WHERE t = 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'cze+';
INSERT INTO "Unicode data" (i, t) VALUES ('pol+', 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._');
SELECT * FROM "Unicode data" WHERE i = 'pol+';
DELETE FROM "Unicode data" WHERE t = 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'pol+';
INSERT INTO "Unicode data" (i, t) VALUES ('srp+', 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._');
SELECT * FROM "Unicode data" WHERE i = 'srp+';
DELETE FROM "Unicode data" WHERE t = 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'srp+';
-- 1257, LATIN7
SELECT * FROM "Unicode data" WHERE i = 'lav';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ķieģeļu%';
INSERT INTO "Unicode data" (i, t) VALUES ('lav+', 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._');
SELECT * FROM "Unicode data" WHERE i = 'lav+';
DELETE FROM "Unicode data" WHERE t = 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'lav+';
-- EUC_KR
SELECT * FROM "Unicode data" WHERE i = 'kor';
SELECT * FROM "Unicode data" WHERE t LIKE '키스의 고%';
INSERT INTO "Unicode data" (i, t) VALUES ('kor+', '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._');
SELECT * FROM "Unicode data" WHERE i = 'kor+';
DELETE FROM "Unicode data" WHERE t = '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'kor+';
-- 1254, LATIN5
SELECT * FROM "Unicode data" WHERE i = 'aze';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zəfər%';
INSERT INTO "Unicode data" (i, t) VALUES ('aze+', 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._');
SELECT * FROM "Unicode data" WHERE i = 'aze+';
DELETE FROM "Unicode data" WHERE t = 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'aze+';
-- etc
INSERT INTO "Unicode data" (i, t) VALUES ('arm+', 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_');
SELECT * FROM "Unicode data" WHERE i = 'arm+';
DELETE FROM "Unicode data" WHERE t = 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'arm+';
INSERT INTO "Unicode data" (i, t) VALUES ('gle+', 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._');
SELECT * FROM "Unicode data" WHERE i = 'gle+';
DELETE FROM "Unicode data" WHERE t = 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'gle+';
INSERT INTO "Unicode data" (i, t) VALUES ('epo+', 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._');
SELECT * FROM "Unicode data" WHERE i = 'epo+';
DELETE FROM "Unicode data" WHERE t = 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'epo+';

DROP FOREIGN TABLE "Unicode data";
DROP SERVER sqlite_svr;
DROP EXTENSION sqlite_fdw;
\connect contrib_regression;
DROP DATABASE "contrib_regression_LATIN5";

-- LATIN6
CREATE DATABASE "contrib_regression_LATIN6" ENCODING LATIN6 LC_CTYPE='POSIX' LC_COLLATE='POSIX' template template0;
\connect "contrib_regression_LATIN6"
CREATE EXTENSION sqlite_fdw;
CREATE SERVER sqlite_svr FOREIGN DATA WRAPPER sqlite_fdw
OPTIONS (database '/tmp/sqlite_fdw_test/common.db');
CREATE FOREIGN TABLE "Unicode data"(i text OPTIONS (key 'true'), t text) SERVER sqlite_svr; 
-- EUC_JP
SELECT * FROM "Unicode data" WHERE i = 'jap';
SELECT * FROM "Unicode data" WHERE t LIKE 'いろはにほ%';
INSERT INTO "Unicode data" (i, t) VALUES ('jap+', 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._');
DELETE FROM "Unicode data" WHERE t = 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'jap+';
-- 1251, ISO_8859_5
SELECT * FROM "Unicode data" WHERE i = 'bel';
SELECT * FROM "Unicode data" WHERE i = 'bul';
SELECT * FROM "Unicode data" WHERE i = 'rus';
SELECT * FROM "Unicode data" WHERE i = 'ukr';
SELECT * FROM "Unicode data" WHERE t LIKE 'У руд%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ах, ч%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Широк%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Гей, %';
INSERT INTO "Unicode data" (i, t) VALUES ('bel+', 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._');
SELECT * FROM "Unicode data" WHERE i = 'bel+';
DELETE FROM "Unicode data" WHERE t = 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bel+';
INSERT INTO "Unicode data" (i, t) VALUES ('bul+', 'Ах, чудна българска земьо, полюшвай цъфтящи жита._');
SELECT * FROM "Unicode data" WHERE i = 'bul+';
DELETE FROM "Unicode data" WHERE t = 'Ах, чудна българска земьо, полюшвай цъфтящи жита._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bul+';
INSERT INTO "Unicode data" (i, t) VALUES ('rus+', 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._');
SELECT * FROM "Unicode data" WHERE i = 'rus+';
DELETE FROM "Unicode data" WHERE t = 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'rus+';
INSERT INTO "Unicode data" (i, t) VALUES ('ukr+', 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._');
SELECT * FROM "Unicode data" WHERE i = 'ukr+';
DELETE FROM "Unicode data" WHERE t = 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ukr+';
-- 1256, ISO_8859_6
SELECT * FROM "Unicode data" WHERE i = 'ara';
SELECT * FROM "Unicode data" WHERE t LIKE '%ضَظَغ%';
INSERT INTO "Unicode data" (i, t) VALUES ('ara+', 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_');
SELECT * FROM "Unicode data" WHERE i = 'ara+';
DELETE FROM "Unicode data" WHERE t = 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ara+';
-- 1253, ISO_8859_7
SELECT * FROM "Unicode data" WHERE i = 'gre';
SELECT * FROM "Unicode data" WHERE t LIKE 'Τάχισ%';
INSERT INTO "Unicode data" (i, t) VALUES ('gre+', 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_');
SELECT * FROM "Unicode data" WHERE i = 'gre+';
DELETE FROM "Unicode data" WHERE t = 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_';
-- 1255, ISO_8859_8
SELECT * FROM "Unicode data" WHERE i = 'heb';
SELECT * FROM "Unicode data" WHERE t LIKE '%כי ח%';
INSERT INTO "Unicode data" (i, t) VALUES ('heb+', 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_');
SELECT * FROM "Unicode data" WHERE i = 'heb+';
DELETE FROM "Unicode data" WHERE t = 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'heb+';
-- 1252, LATIN1
SELECT * FROM "Unicode data" WHERE i = 'eus';
SELECT * FROM "Unicode data" WHERE i = 'fra';
SELECT * FROM "Unicode data" WHERE i = 'spa';
SELECT * FROM "Unicode data" WHERE t LIKE 'Permi%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Dès N%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Quier%';
INSERT INTO "Unicode data" (i, t) VALUES ('eus+', 'Permin gox dabiltzu yoskiñ._');
SELECT * FROM "Unicode data" WHERE i = 'eus+';
DELETE FROM "Unicode data" WHERE t = 'Permin gox dabiltzu yoskiñ._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'eus+';
INSERT INTO "Unicode data" (i, t) VALUES ('fra+', 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_');
SELECT * FROM "Unicode data" WHERE i = 'fra+';
DELETE FROM "Unicode data" WHERE t = 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'fra+';
INSERT INTO "Unicode data" (i, t) VALUES ('spa+', 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._');
SELECT * FROM "Unicode data" WHERE i = 'spa+';
DELETE FROM "Unicode data" WHERE t = 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'spa+';
-- 1250, LATIN2
SELECT * FROM "Unicode data" WHERE i = 'cze';
SELECT * FROM "Unicode data" WHERE i = 'pol';
SELECT * FROM "Unicode data" WHERE i = 'srp';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zvláš%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Pchną%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ljuba%';
INSERT INTO "Unicode data" (i, t) VALUES ('cze+', 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._');
SELECT * FROM "Unicode data" WHERE i = 'cze+';
DELETE FROM "Unicode data" WHERE t = 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'cze+';
INSERT INTO "Unicode data" (i, t) VALUES ('pol+', 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._');
SELECT * FROM "Unicode data" WHERE i = 'pol+';
DELETE FROM "Unicode data" WHERE t = 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'pol+';
INSERT INTO "Unicode data" (i, t) VALUES ('srp+', 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._');
SELECT * FROM "Unicode data" WHERE i = 'srp+';
DELETE FROM "Unicode data" WHERE t = 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'srp+';
-- 1257, LATIN7
SELECT * FROM "Unicode data" WHERE i = 'lav';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ķieģeļu%';
INSERT INTO "Unicode data" (i, t) VALUES ('lav+', 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._');
SELECT * FROM "Unicode data" WHERE i = 'lav+';
DELETE FROM "Unicode data" WHERE t = 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'lav+';
-- EUC_KR
SELECT * FROM "Unicode data" WHERE i = 'kor';
SELECT * FROM "Unicode data" WHERE t LIKE '키스의 고%';
INSERT INTO "Unicode data" (i, t) VALUES ('kor+', '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._');
SELECT * FROM "Unicode data" WHERE i = 'kor+';
DELETE FROM "Unicode data" WHERE t = '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'kor+';
-- 1254, LATIN5
SELECT * FROM "Unicode data" WHERE i = 'aze';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zəfər%';
INSERT INTO "Unicode data" (i, t) VALUES ('aze+', 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._');
SELECT * FROM "Unicode data" WHERE i = 'aze+';
DELETE FROM "Unicode data" WHERE t = 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'aze+';
-- etc
INSERT INTO "Unicode data" (i, t) VALUES ('arm+', 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_');
SELECT * FROM "Unicode data" WHERE i = 'arm+';
DELETE FROM "Unicode data" WHERE t = 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'arm+';
INSERT INTO "Unicode data" (i, t) VALUES ('gle+', 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._');
SELECT * FROM "Unicode data" WHERE i = 'gle+';
DELETE FROM "Unicode data" WHERE t = 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'gle+';
INSERT INTO "Unicode data" (i, t) VALUES ('epo+', 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._');
SELECT * FROM "Unicode data" WHERE i = 'epo+';
DELETE FROM "Unicode data" WHERE t = 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'epo+';

DROP FOREIGN TABLE "Unicode data";
DROP SERVER sqlite_svr;
DROP EXTENSION sqlite_fdw;
\connect contrib_regression;
DROP DATABASE "contrib_regression_LATIN6";

-- LATIN7
CREATE DATABASE "contrib_regression_LATIN7" ENCODING LATIN7 LC_CTYPE='POSIX' LC_COLLATE='POSIX' template template0;
\connect "contrib_regression_LATIN7"
CREATE EXTENSION sqlite_fdw;
CREATE SERVER sqlite_svr FOREIGN DATA WRAPPER sqlite_fdw
OPTIONS (database '/tmp/sqlite_fdw_test/common.db');
CREATE FOREIGN TABLE "Unicode data"(i text OPTIONS (key 'true'), t text) SERVER sqlite_svr; 
-- EUC_JP
SELECT * FROM "Unicode data" WHERE i = 'jap';
SELECT * FROM "Unicode data" WHERE t LIKE 'いろはにほ%';
INSERT INTO "Unicode data" (i, t) VALUES ('jap+', 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._');
DELETE FROM "Unicode data" WHERE t = 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'jap+';
-- 1251, ISO_8859_5
SELECT * FROM "Unicode data" WHERE i = 'bel';
SELECT * FROM "Unicode data" WHERE i = 'bul';
SELECT * FROM "Unicode data" WHERE i = 'rus';
SELECT * FROM "Unicode data" WHERE i = 'ukr';
SELECT * FROM "Unicode data" WHERE t LIKE 'У руд%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ах, ч%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Широк%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Гей, %';
INSERT INTO "Unicode data" (i, t) VALUES ('bel+', 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._');
SELECT * FROM "Unicode data" WHERE i = 'bel+';
DELETE FROM "Unicode data" WHERE t = 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bel+';
INSERT INTO "Unicode data" (i, t) VALUES ('bul+', 'Ах, чудна българска земьо, полюшвай цъфтящи жита._');
SELECT * FROM "Unicode data" WHERE i = 'bul+';
DELETE FROM "Unicode data" WHERE t = 'Ах, чудна българска земьо, полюшвай цъфтящи жита._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bul+';
INSERT INTO "Unicode data" (i, t) VALUES ('rus+', 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._');
SELECT * FROM "Unicode data" WHERE i = 'rus+';
DELETE FROM "Unicode data" WHERE t = 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'rus+';
INSERT INTO "Unicode data" (i, t) VALUES ('ukr+', 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._');
SELECT * FROM "Unicode data" WHERE i = 'ukr+';
DELETE FROM "Unicode data" WHERE t = 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ukr+';
-- 1256, ISO_8859_6
SELECT * FROM "Unicode data" WHERE i = 'ara';
SELECT * FROM "Unicode data" WHERE t LIKE '%ضَظَغ%';
INSERT INTO "Unicode data" (i, t) VALUES ('ara+', 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_');
SELECT * FROM "Unicode data" WHERE i = 'ara+';
DELETE FROM "Unicode data" WHERE t = 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ara+';
-- 1253, ISO_8859_7
SELECT * FROM "Unicode data" WHERE i = 'gre';
SELECT * FROM "Unicode data" WHERE t LIKE 'Τάχισ%';
INSERT INTO "Unicode data" (i, t) VALUES ('gre+', 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_');
SELECT * FROM "Unicode data" WHERE i = 'gre+';
DELETE FROM "Unicode data" WHERE t = 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_';
-- 1255, ISO_8859_8
SELECT * FROM "Unicode data" WHERE i = 'heb';
SELECT * FROM "Unicode data" WHERE t LIKE '%כי ח%';
INSERT INTO "Unicode data" (i, t) VALUES ('heb+', 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_');
SELECT * FROM "Unicode data" WHERE i = 'heb+';
DELETE FROM "Unicode data" WHERE t = 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'heb+';
-- 1252, LATIN1
SELECT * FROM "Unicode data" WHERE i = 'eus';
SELECT * FROM "Unicode data" WHERE i = 'fra';
SELECT * FROM "Unicode data" WHERE i = 'spa';
SELECT * FROM "Unicode data" WHERE t LIKE 'Permi%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Dès N%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Quier%';
INSERT INTO "Unicode data" (i, t) VALUES ('eus+', 'Permin gox dabiltzu yoskiñ._');
SELECT * FROM "Unicode data" WHERE i = 'eus+';
DELETE FROM "Unicode data" WHERE t = 'Permin gox dabiltzu yoskiñ._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'eus+';
INSERT INTO "Unicode data" (i, t) VALUES ('fra+', 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_');
SELECT * FROM "Unicode data" WHERE i = 'fra+';
DELETE FROM "Unicode data" WHERE t = 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'fra+';
INSERT INTO "Unicode data" (i, t) VALUES ('spa+', 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._');
SELECT * FROM "Unicode data" WHERE i = 'spa+';
DELETE FROM "Unicode data" WHERE t = 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'spa+';
-- 1250, LATIN2
SELECT * FROM "Unicode data" WHERE i = 'cze';
SELECT * FROM "Unicode data" WHERE i = 'pol';
SELECT * FROM "Unicode data" WHERE i = 'srp';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zvláš%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Pchną%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ljuba%';
INSERT INTO "Unicode data" (i, t) VALUES ('cze+', 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._');
SELECT * FROM "Unicode data" WHERE i = 'cze+';
DELETE FROM "Unicode data" WHERE t = 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'cze+';
INSERT INTO "Unicode data" (i, t) VALUES ('pol+', 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._');
SELECT * FROM "Unicode data" WHERE i = 'pol+';
DELETE FROM "Unicode data" WHERE t = 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'pol+';
INSERT INTO "Unicode data" (i, t) VALUES ('srp+', 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._');
SELECT * FROM "Unicode data" WHERE i = 'srp+';
DELETE FROM "Unicode data" WHERE t = 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'srp+';
-- 1257, LATIN7
SELECT * FROM "Unicode data" WHERE i = 'lav';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ķieģeļu%';
INSERT INTO "Unicode data" (i, t) VALUES ('lav+', 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._');
SELECT * FROM "Unicode data" WHERE i = 'lav+';
DELETE FROM "Unicode data" WHERE t = 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'lav+';
-- EUC_KR
SELECT * FROM "Unicode data" WHERE i = 'kor';
SELECT * FROM "Unicode data" WHERE t LIKE '키스의 고%';
INSERT INTO "Unicode data" (i, t) VALUES ('kor+', '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._');
SELECT * FROM "Unicode data" WHERE i = 'kor+';
DELETE FROM "Unicode data" WHERE t = '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'kor+';
-- 1254, LATIN5
SELECT * FROM "Unicode data" WHERE i = 'aze';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zəfər%';
INSERT INTO "Unicode data" (i, t) VALUES ('aze+', 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._');
SELECT * FROM "Unicode data" WHERE i = 'aze+';
DELETE FROM "Unicode data" WHERE t = 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'aze+';
-- etc
INSERT INTO "Unicode data" (i, t) VALUES ('arm+', 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_');
SELECT * FROM "Unicode data" WHERE i = 'arm+';
DELETE FROM "Unicode data" WHERE t = 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'arm+';
INSERT INTO "Unicode data" (i, t) VALUES ('gle+', 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._');
SELECT * FROM "Unicode data" WHERE i = 'gle+';
DELETE FROM "Unicode data" WHERE t = 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'gle+';
INSERT INTO "Unicode data" (i, t) VALUES ('epo+', 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._');
SELECT * FROM "Unicode data" WHERE i = 'epo+';
DELETE FROM "Unicode data" WHERE t = 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'epo+';

DROP FOREIGN TABLE "Unicode data";
DROP SERVER sqlite_svr;
DROP EXTENSION sqlite_fdw;
\connect contrib_regression;
DROP DATABASE "contrib_regression_LATIN7";

-- LATIN8
CREATE DATABASE "contrib_regression_LATIN8" ENCODING LATIN8 LC_CTYPE='POSIX' LC_COLLATE='POSIX' template template0;
\connect "contrib_regression_LATIN8"
CREATE EXTENSION sqlite_fdw;
CREATE SERVER sqlite_svr FOREIGN DATA WRAPPER sqlite_fdw
OPTIONS (database '/tmp/sqlite_fdw_test/common.db');
CREATE FOREIGN TABLE "Unicode data"(i text OPTIONS (key 'true'), t text) SERVER sqlite_svr; 
-- EUC_JP
SELECT * FROM "Unicode data" WHERE i = 'jap';
SELECT * FROM "Unicode data" WHERE t LIKE 'いろはにほ%';
INSERT INTO "Unicode data" (i, t) VALUES ('jap+', 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._');
DELETE FROM "Unicode data" WHERE t = 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'jap+';
-- 1251, ISO_8859_5
SELECT * FROM "Unicode data" WHERE i = 'bel';
SELECT * FROM "Unicode data" WHERE i = 'bul';
SELECT * FROM "Unicode data" WHERE i = 'rus';
SELECT * FROM "Unicode data" WHERE i = 'ukr';
SELECT * FROM "Unicode data" WHERE t LIKE 'У руд%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ах, ч%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Широк%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Гей, %';
INSERT INTO "Unicode data" (i, t) VALUES ('bel+', 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._');
SELECT * FROM "Unicode data" WHERE i = 'bel+';
DELETE FROM "Unicode data" WHERE t = 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bel+';
INSERT INTO "Unicode data" (i, t) VALUES ('bul+', 'Ах, чудна българска земьо, полюшвай цъфтящи жита._');
SELECT * FROM "Unicode data" WHERE i = 'bul+';
DELETE FROM "Unicode data" WHERE t = 'Ах, чудна българска земьо, полюшвай цъфтящи жита._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bul+';
INSERT INTO "Unicode data" (i, t) VALUES ('rus+', 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._');
SELECT * FROM "Unicode data" WHERE i = 'rus+';
DELETE FROM "Unicode data" WHERE t = 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'rus+';
INSERT INTO "Unicode data" (i, t) VALUES ('ukr+', 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._');
SELECT * FROM "Unicode data" WHERE i = 'ukr+';
DELETE FROM "Unicode data" WHERE t = 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ukr+';
-- 1256, ISO_8859_6
SELECT * FROM "Unicode data" WHERE i = 'ara';
SELECT * FROM "Unicode data" WHERE t LIKE '%ضَظَغ%';
INSERT INTO "Unicode data" (i, t) VALUES ('ara+', 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_');
SELECT * FROM "Unicode data" WHERE i = 'ara+';
DELETE FROM "Unicode data" WHERE t = 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ara+';
-- 1253, ISO_8859_7
SELECT * FROM "Unicode data" WHERE i = 'gre';
SELECT * FROM "Unicode data" WHERE t LIKE 'Τάχισ%';
INSERT INTO "Unicode data" (i, t) VALUES ('gre+', 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_');
SELECT * FROM "Unicode data" WHERE i = 'gre+';
DELETE FROM "Unicode data" WHERE t = 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_';
-- 1255, ISO_8859_8
SELECT * FROM "Unicode data" WHERE i = 'heb';
SELECT * FROM "Unicode data" WHERE t LIKE '%כי ח%';
INSERT INTO "Unicode data" (i, t) VALUES ('heb+', 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_');
SELECT * FROM "Unicode data" WHERE i = 'heb+';
DELETE FROM "Unicode data" WHERE t = 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'heb+';
-- 1252, LATIN1
SELECT * FROM "Unicode data" WHERE i = 'eus';
SELECT * FROM "Unicode data" WHERE i = 'fra';
SELECT * FROM "Unicode data" WHERE i = 'spa';
SELECT * FROM "Unicode data" WHERE t LIKE 'Permi%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Dès N%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Quier%';
INSERT INTO "Unicode data" (i, t) VALUES ('eus+', 'Permin gox dabiltzu yoskiñ._');
SELECT * FROM "Unicode data" WHERE i = 'eus+';
DELETE FROM "Unicode data" WHERE t = 'Permin gox dabiltzu yoskiñ._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'eus+';
INSERT INTO "Unicode data" (i, t) VALUES ('fra+', 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_');
SELECT * FROM "Unicode data" WHERE i = 'fra+';
DELETE FROM "Unicode data" WHERE t = 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'fra+';
INSERT INTO "Unicode data" (i, t) VALUES ('spa+', 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._');
SELECT * FROM "Unicode data" WHERE i = 'spa+';
DELETE FROM "Unicode data" WHERE t = 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'spa+';
-- 1250, LATIN2
SELECT * FROM "Unicode data" WHERE i = 'cze';
SELECT * FROM "Unicode data" WHERE i = 'pol';
SELECT * FROM "Unicode data" WHERE i = 'srp';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zvláš%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Pchną%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ljuba%';
INSERT INTO "Unicode data" (i, t) VALUES ('cze+', 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._');
SELECT * FROM "Unicode data" WHERE i = 'cze+';
DELETE FROM "Unicode data" WHERE t = 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'cze+';
INSERT INTO "Unicode data" (i, t) VALUES ('pol+', 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._');
SELECT * FROM "Unicode data" WHERE i = 'pol+';
DELETE FROM "Unicode data" WHERE t = 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'pol+';
INSERT INTO "Unicode data" (i, t) VALUES ('srp+', 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._');
SELECT * FROM "Unicode data" WHERE i = 'srp+';
DELETE FROM "Unicode data" WHERE t = 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'srp+';
-- 1257, LATIN7
SELECT * FROM "Unicode data" WHERE i = 'lav';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ķieģeļu%';
INSERT INTO "Unicode data" (i, t) VALUES ('lav+', 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._');
SELECT * FROM "Unicode data" WHERE i = 'lav+';
DELETE FROM "Unicode data" WHERE t = 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'lav+';
-- EUC_KR
SELECT * FROM "Unicode data" WHERE i = 'kor';
SELECT * FROM "Unicode data" WHERE t LIKE '키스의 고%';
INSERT INTO "Unicode data" (i, t) VALUES ('kor+', '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._');
SELECT * FROM "Unicode data" WHERE i = 'kor+';
DELETE FROM "Unicode data" WHERE t = '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'kor+';
-- 1254, LATIN5
SELECT * FROM "Unicode data" WHERE i = 'aze';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zəfər%';
INSERT INTO "Unicode data" (i, t) VALUES ('aze+', 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._');
SELECT * FROM "Unicode data" WHERE i = 'aze+';
DELETE FROM "Unicode data" WHERE t = 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'aze+';
-- etc
INSERT INTO "Unicode data" (i, t) VALUES ('arm+', 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_');
SELECT * FROM "Unicode data" WHERE i = 'arm+';
DELETE FROM "Unicode data" WHERE t = 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'arm+';
INSERT INTO "Unicode data" (i, t) VALUES ('gle+', 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._');
SELECT * FROM "Unicode data" WHERE i = 'gle+';
DELETE FROM "Unicode data" WHERE t = 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'gle+';
INSERT INTO "Unicode data" (i, t) VALUES ('epo+', 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._');
SELECT * FROM "Unicode data" WHERE i = 'epo+';
DELETE FROM "Unicode data" WHERE t = 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'epo+';

DROP FOREIGN TABLE "Unicode data";
DROP SERVER sqlite_svr;
DROP EXTENSION sqlite_fdw;
\connect contrib_regression;
DROP DATABASE "contrib_regression_LATIN8";

-- LATIN9
CREATE DATABASE "contrib_regression_LATIN9" ENCODING LATIN9 LC_CTYPE='POSIX' LC_COLLATE='POSIX' template template0;
\connect "contrib_regression_LATIN9"
CREATE EXTENSION sqlite_fdw;
CREATE SERVER sqlite_svr FOREIGN DATA WRAPPER sqlite_fdw
OPTIONS (database '/tmp/sqlite_fdw_test/common.db');
CREATE FOREIGN TABLE "Unicode data"(i text OPTIONS (key 'true'), t text) SERVER sqlite_svr; 
-- EUC_JP
SELECT * FROM "Unicode data" WHERE i = 'jap';
SELECT * FROM "Unicode data" WHERE t LIKE 'いろはにほ%';
INSERT INTO "Unicode data" (i, t) VALUES ('jap+', 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._');
DELETE FROM "Unicode data" WHERE t = 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'jap+';
-- 1251, ISO_8859_5
SELECT * FROM "Unicode data" WHERE i = 'bel';
SELECT * FROM "Unicode data" WHERE i = 'bul';
SELECT * FROM "Unicode data" WHERE i = 'rus';
SELECT * FROM "Unicode data" WHERE i = 'ukr';
SELECT * FROM "Unicode data" WHERE t LIKE 'У руд%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ах, ч%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Широк%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Гей, %';
INSERT INTO "Unicode data" (i, t) VALUES ('bel+', 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._');
SELECT * FROM "Unicode data" WHERE i = 'bel+';
DELETE FROM "Unicode data" WHERE t = 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bel+';
INSERT INTO "Unicode data" (i, t) VALUES ('bul+', 'Ах, чудна българска земьо, полюшвай цъфтящи жита._');
SELECT * FROM "Unicode data" WHERE i = 'bul+';
DELETE FROM "Unicode data" WHERE t = 'Ах, чудна българска земьо, полюшвай цъфтящи жита._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bul+';
INSERT INTO "Unicode data" (i, t) VALUES ('rus+', 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._');
SELECT * FROM "Unicode data" WHERE i = 'rus+';
DELETE FROM "Unicode data" WHERE t = 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'rus+';
INSERT INTO "Unicode data" (i, t) VALUES ('ukr+', 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._');
SELECT * FROM "Unicode data" WHERE i = 'ukr+';
DELETE FROM "Unicode data" WHERE t = 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ukr+';
-- 1256, ISO_8859_6
SELECT * FROM "Unicode data" WHERE i = 'ara';
SELECT * FROM "Unicode data" WHERE t LIKE '%ضَظَغ%';
INSERT INTO "Unicode data" (i, t) VALUES ('ara+', 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_');
SELECT * FROM "Unicode data" WHERE i = 'ara+';
DELETE FROM "Unicode data" WHERE t = 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ara+';
-- 1253, ISO_8859_7
SELECT * FROM "Unicode data" WHERE i = 'gre';
SELECT * FROM "Unicode data" WHERE t LIKE 'Τάχισ%';
INSERT INTO "Unicode data" (i, t) VALUES ('gre+', 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_');
SELECT * FROM "Unicode data" WHERE i = 'gre+';
DELETE FROM "Unicode data" WHERE t = 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_';
-- 1255, ISO_8859_8
SELECT * FROM "Unicode data" WHERE i = 'heb';
SELECT * FROM "Unicode data" WHERE t LIKE '%כי ח%';
INSERT INTO "Unicode data" (i, t) VALUES ('heb+', 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_');
SELECT * FROM "Unicode data" WHERE i = 'heb+';
DELETE FROM "Unicode data" WHERE t = 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'heb+';
-- 1252, LATIN1
SELECT * FROM "Unicode data" WHERE i = 'eus';
SELECT * FROM "Unicode data" WHERE i = 'fra';
SELECT * FROM "Unicode data" WHERE i = 'spa';
SELECT * FROM "Unicode data" WHERE t LIKE 'Permi%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Dès N%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Quier%';
INSERT INTO "Unicode data" (i, t) VALUES ('eus+', 'Permin gox dabiltzu yoskiñ._');
SELECT * FROM "Unicode data" WHERE i = 'eus+';
DELETE FROM "Unicode data" WHERE t = 'Permin gox dabiltzu yoskiñ._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'eus+';
INSERT INTO "Unicode data" (i, t) VALUES ('fra+', 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_');
SELECT * FROM "Unicode data" WHERE i = 'fra+';
DELETE FROM "Unicode data" WHERE t = 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'fra+';
INSERT INTO "Unicode data" (i, t) VALUES ('spa+', 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._');
SELECT * FROM "Unicode data" WHERE i = 'spa+';
DELETE FROM "Unicode data" WHERE t = 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'spa+';
-- 1250, LATIN2
SELECT * FROM "Unicode data" WHERE i = 'cze';
SELECT * FROM "Unicode data" WHERE i = 'pol';
SELECT * FROM "Unicode data" WHERE i = 'srp';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zvláš%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Pchną%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ljuba%';
INSERT INTO "Unicode data" (i, t) VALUES ('cze+', 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._');
SELECT * FROM "Unicode data" WHERE i = 'cze+';
DELETE FROM "Unicode data" WHERE t = 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'cze+';
INSERT INTO "Unicode data" (i, t) VALUES ('pol+', 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._');
SELECT * FROM "Unicode data" WHERE i = 'pol+';
DELETE FROM "Unicode data" WHERE t = 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'pol+';
INSERT INTO "Unicode data" (i, t) VALUES ('srp+', 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._');
SELECT * FROM "Unicode data" WHERE i = 'srp+';
DELETE FROM "Unicode data" WHERE t = 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'srp+';
-- 1257, LATIN7
SELECT * FROM "Unicode data" WHERE i = 'lav';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ķieģeļu%';
INSERT INTO "Unicode data" (i, t) VALUES ('lav+', 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._');
SELECT * FROM "Unicode data" WHERE i = 'lav+';
DELETE FROM "Unicode data" WHERE t = 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'lav+';
-- EUC_KR
SELECT * FROM "Unicode data" WHERE i = 'kor';
SELECT * FROM "Unicode data" WHERE t LIKE '키스의 고%';
INSERT INTO "Unicode data" (i, t) VALUES ('kor+', '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._');
SELECT * FROM "Unicode data" WHERE i = 'kor+';
DELETE FROM "Unicode data" WHERE t = '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'kor+';
-- 1254, LATIN5
SELECT * FROM "Unicode data" WHERE i = 'aze';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zəfər%';
INSERT INTO "Unicode data" (i, t) VALUES ('aze+', 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._');
SELECT * FROM "Unicode data" WHERE i = 'aze+';
DELETE FROM "Unicode data" WHERE t = 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'aze+';
-- etc
INSERT INTO "Unicode data" (i, t) VALUES ('arm+', 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_');
SELECT * FROM "Unicode data" WHERE i = 'arm+';
DELETE FROM "Unicode data" WHERE t = 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'arm+';
INSERT INTO "Unicode data" (i, t) VALUES ('gle+', 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._');
SELECT * FROM "Unicode data" WHERE i = 'gle+';
DELETE FROM "Unicode data" WHERE t = 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'gle+';
INSERT INTO "Unicode data" (i, t) VALUES ('epo+', 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._');
SELECT * FROM "Unicode data" WHERE i = 'epo+';
DELETE FROM "Unicode data" WHERE t = 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'epo+';

DROP FOREIGN TABLE "Unicode data";
DROP SERVER sqlite_svr;
DROP EXTENSION sqlite_fdw;
\connect contrib_regression;
DROP DATABASE "contrib_regression_LATIN9";

-- LATIN10
CREATE DATABASE "contrib_regression_LATIN10" ENCODING LATIN10 LC_CTYPE='POSIX' LC_COLLATE='POSIX' template template0;
\connect "contrib_regression_LATIN10"
CREATE EXTENSION sqlite_fdw;
CREATE SERVER sqlite_svr FOREIGN DATA WRAPPER sqlite_fdw
OPTIONS (database '/tmp/sqlite_fdw_test/common.db');
CREATE FOREIGN TABLE "Unicode data"(i text OPTIONS (key 'true'), t text) SERVER sqlite_svr; 
-- EUC_JP
SELECT * FROM "Unicode data" WHERE i = 'jap';
SELECT * FROM "Unicode data" WHERE t LIKE 'いろはにほ%';
INSERT INTO "Unicode data" (i, t) VALUES ('jap+', 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._');
DELETE FROM "Unicode data" WHERE t = 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'jap+';
-- 1251, ISO_8859_5
SELECT * FROM "Unicode data" WHERE i = 'bel';
SELECT * FROM "Unicode data" WHERE i = 'bul';
SELECT * FROM "Unicode data" WHERE i = 'rus';
SELECT * FROM "Unicode data" WHERE i = 'ukr';
SELECT * FROM "Unicode data" WHERE t LIKE 'У руд%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ах, ч%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Широк%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Гей, %';
INSERT INTO "Unicode data" (i, t) VALUES ('bel+', 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._');
SELECT * FROM "Unicode data" WHERE i = 'bel+';
DELETE FROM "Unicode data" WHERE t = 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bel+';
INSERT INTO "Unicode data" (i, t) VALUES ('bul+', 'Ах, чудна българска земьо, полюшвай цъфтящи жита._');
SELECT * FROM "Unicode data" WHERE i = 'bul+';
DELETE FROM "Unicode data" WHERE t = 'Ах, чудна българска земьо, полюшвай цъфтящи жита._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bul+';
INSERT INTO "Unicode data" (i, t) VALUES ('rus+', 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._');
SELECT * FROM "Unicode data" WHERE i = 'rus+';
DELETE FROM "Unicode data" WHERE t = 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'rus+';
INSERT INTO "Unicode data" (i, t) VALUES ('ukr+', 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._');
SELECT * FROM "Unicode data" WHERE i = 'ukr+';
DELETE FROM "Unicode data" WHERE t = 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ukr+';
-- 1256, ISO_8859_6
SELECT * FROM "Unicode data" WHERE i = 'ara';
SELECT * FROM "Unicode data" WHERE t LIKE '%ضَظَغ%';
INSERT INTO "Unicode data" (i, t) VALUES ('ara+', 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_');
SELECT * FROM "Unicode data" WHERE i = 'ara+';
DELETE FROM "Unicode data" WHERE t = 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ara+';
-- 1253, ISO_8859_7
SELECT * FROM "Unicode data" WHERE i = 'gre';
SELECT * FROM "Unicode data" WHERE t LIKE 'Τάχισ%';
INSERT INTO "Unicode data" (i, t) VALUES ('gre+', 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_');
SELECT * FROM "Unicode data" WHERE i = 'gre+';
DELETE FROM "Unicode data" WHERE t = 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_';
-- 1255, ISO_8859_8
SELECT * FROM "Unicode data" WHERE i = 'heb';
SELECT * FROM "Unicode data" WHERE t LIKE '%כי ח%';
INSERT INTO "Unicode data" (i, t) VALUES ('heb+', 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_');
SELECT * FROM "Unicode data" WHERE i = 'heb+';
DELETE FROM "Unicode data" WHERE t = 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'heb+';
-- 1252, LATIN1
SELECT * FROM "Unicode data" WHERE i = 'eus';
SELECT * FROM "Unicode data" WHERE i = 'fra';
SELECT * FROM "Unicode data" WHERE i = 'spa';
SELECT * FROM "Unicode data" WHERE t LIKE 'Permi%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Dès N%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Quier%';
INSERT INTO "Unicode data" (i, t) VALUES ('eus+', 'Permin gox dabiltzu yoskiñ._');
SELECT * FROM "Unicode data" WHERE i = 'eus+';
DELETE FROM "Unicode data" WHERE t = 'Permin gox dabiltzu yoskiñ._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'eus+';
INSERT INTO "Unicode data" (i, t) VALUES ('fra+', 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_');
SELECT * FROM "Unicode data" WHERE i = 'fra+';
DELETE FROM "Unicode data" WHERE t = 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'fra+';
INSERT INTO "Unicode data" (i, t) VALUES ('spa+', 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._');
SELECT * FROM "Unicode data" WHERE i = 'spa+';
DELETE FROM "Unicode data" WHERE t = 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'spa+';
-- 1250, LATIN2
SELECT * FROM "Unicode data" WHERE i = 'cze';
SELECT * FROM "Unicode data" WHERE i = 'pol';
SELECT * FROM "Unicode data" WHERE i = 'srp';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zvláš%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Pchną%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ljuba%';
INSERT INTO "Unicode data" (i, t) VALUES ('cze+', 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._');
SELECT * FROM "Unicode data" WHERE i = 'cze+';
DELETE FROM "Unicode data" WHERE t = 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'cze+';
INSERT INTO "Unicode data" (i, t) VALUES ('pol+', 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._');
SELECT * FROM "Unicode data" WHERE i = 'pol+';
DELETE FROM "Unicode data" WHERE t = 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'pol+';
INSERT INTO "Unicode data" (i, t) VALUES ('srp+', 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._');
SELECT * FROM "Unicode data" WHERE i = 'srp+';
DELETE FROM "Unicode data" WHERE t = 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'srp+';
-- 1257, LATIN7
SELECT * FROM "Unicode data" WHERE i = 'lav';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ķieģeļu%';
INSERT INTO "Unicode data" (i, t) VALUES ('lav+', 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._');
SELECT * FROM "Unicode data" WHERE i = 'lav+';
DELETE FROM "Unicode data" WHERE t = 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'lav+';
-- EUC_KR
SELECT * FROM "Unicode data" WHERE i = 'kor';
SELECT * FROM "Unicode data" WHERE t LIKE '키스의 고%';
INSERT INTO "Unicode data" (i, t) VALUES ('kor+', '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._');
SELECT * FROM "Unicode data" WHERE i = 'kor+';
DELETE FROM "Unicode data" WHERE t = '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'kor+';
-- 1254, LATIN5
SELECT * FROM "Unicode data" WHERE i = 'aze';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zəfər%';
INSERT INTO "Unicode data" (i, t) VALUES ('aze+', 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._');
SELECT * FROM "Unicode data" WHERE i = 'aze+';
DELETE FROM "Unicode data" WHERE t = 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'aze+';
-- etc
INSERT INTO "Unicode data" (i, t) VALUES ('arm+', 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_');
SELECT * FROM "Unicode data" WHERE i = 'arm+';
DELETE FROM "Unicode data" WHERE t = 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'arm+';
INSERT INTO "Unicode data" (i, t) VALUES ('gle+', 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._');
SELECT * FROM "Unicode data" WHERE i = 'gle+';
DELETE FROM "Unicode data" WHERE t = 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'gle+';
INSERT INTO "Unicode data" (i, t) VALUES ('epo+', 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._');
SELECT * FROM "Unicode data" WHERE i = 'epo+';
DELETE FROM "Unicode data" WHERE t = 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'epo+';

DROP FOREIGN TABLE "Unicode data";
DROP SERVER sqlite_svr;
DROP EXTENSION sqlite_fdw;
\connect contrib_regression;
DROP DATABASE "contrib_regression_LATIN10";

-- cp1250
CREATE DATABASE "contrib_regression_WIN1250" ENCODING WIN1250 LC_CTYPE='POSIX' LC_COLLATE='POSIX' template template0;
\connect "contrib_regression_WIN1250"
CREATE EXTENSION sqlite_fdw;
CREATE SERVER sqlite_svr FOREIGN DATA WRAPPER sqlite_fdw
OPTIONS (database '/tmp/sqlite_fdw_test/common.db');
CREATE FOREIGN TABLE "Unicode data"(i text OPTIONS (key 'true'), t text) SERVER sqlite_svr; 
-- EUC_JP
SELECT * FROM "Unicode data" WHERE i = 'jap';
SELECT * FROM "Unicode data" WHERE t LIKE 'いろはにほ%';
INSERT INTO "Unicode data" (i, t) VALUES ('jap+', 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._');
DELETE FROM "Unicode data" WHERE t = 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'jap+';
-- 1251, ISO_8859_5
SELECT * FROM "Unicode data" WHERE i = 'bel';
SELECT * FROM "Unicode data" WHERE i = 'bul';
SELECT * FROM "Unicode data" WHERE i = 'rus';
SELECT * FROM "Unicode data" WHERE i = 'ukr';
SELECT * FROM "Unicode data" WHERE t LIKE 'У руд%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ах, ч%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Широк%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Гей, %';
INSERT INTO "Unicode data" (i, t) VALUES ('bel+', 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._');
SELECT * FROM "Unicode data" WHERE i = 'bel+';
DELETE FROM "Unicode data" WHERE t = 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bel+';
INSERT INTO "Unicode data" (i, t) VALUES ('bul+', 'Ах, чудна българска земьо, полюшвай цъфтящи жита._');
SELECT * FROM "Unicode data" WHERE i = 'bul+';
DELETE FROM "Unicode data" WHERE t = 'Ах, чудна българска земьо, полюшвай цъфтящи жита._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bul+';
INSERT INTO "Unicode data" (i, t) VALUES ('rus+', 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._');
SELECT * FROM "Unicode data" WHERE i = 'rus+';
DELETE FROM "Unicode data" WHERE t = 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'rus+';
INSERT INTO "Unicode data" (i, t) VALUES ('ukr+', 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._');
SELECT * FROM "Unicode data" WHERE i = 'ukr+';
DELETE FROM "Unicode data" WHERE t = 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ukr+';
-- 1256, ISO_8859_6
SELECT * FROM "Unicode data" WHERE i = 'ara';
SELECT * FROM "Unicode data" WHERE t LIKE '%ضَظَغ%';
INSERT INTO "Unicode data" (i, t) VALUES ('ara+', 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_');
SELECT * FROM "Unicode data" WHERE i = 'ara+';
DELETE FROM "Unicode data" WHERE t = 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ara+';
-- 1253, ISO_8859_7
SELECT * FROM "Unicode data" WHERE i = 'gre';
SELECT * FROM "Unicode data" WHERE t LIKE 'Τάχισ%';
INSERT INTO "Unicode data" (i, t) VALUES ('gre+', 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_');
SELECT * FROM "Unicode data" WHERE i = 'gre+';
DELETE FROM "Unicode data" WHERE t = 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_';
-- 1255, ISO_8859_8
SELECT * FROM "Unicode data" WHERE i = 'heb';
SELECT * FROM "Unicode data" WHERE t LIKE '%כי ח%';
INSERT INTO "Unicode data" (i, t) VALUES ('heb+', 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_');
SELECT * FROM "Unicode data" WHERE i = 'heb+';
DELETE FROM "Unicode data" WHERE t = 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'heb+';
-- 1252, LATIN1
SELECT * FROM "Unicode data" WHERE i = 'eus';
SELECT * FROM "Unicode data" WHERE i = 'fra';
SELECT * FROM "Unicode data" WHERE i = 'spa';
SELECT * FROM "Unicode data" WHERE t LIKE 'Permi%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Dès N%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Quier%';
INSERT INTO "Unicode data" (i, t) VALUES ('eus+', 'Permin gox dabiltzu yoskiñ._');
SELECT * FROM "Unicode data" WHERE i = 'eus+';
DELETE FROM "Unicode data" WHERE t = 'Permin gox dabiltzu yoskiñ._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'eus+';
INSERT INTO "Unicode data" (i, t) VALUES ('fra+', 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_');
SELECT * FROM "Unicode data" WHERE i = 'fra+';
DELETE FROM "Unicode data" WHERE t = 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'fra+';
INSERT INTO "Unicode data" (i, t) VALUES ('spa+', 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._');
SELECT * FROM "Unicode data" WHERE i = 'spa+';
DELETE FROM "Unicode data" WHERE t = 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'spa+';
-- 1250, LATIN2
SELECT * FROM "Unicode data" WHERE i = 'cze';
SELECT * FROM "Unicode data" WHERE i = 'pol';
SELECT * FROM "Unicode data" WHERE i = 'srp';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zvláš%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Pchną%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ljuba%';
INSERT INTO "Unicode data" (i, t) VALUES ('cze+', 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._');
SELECT * FROM "Unicode data" WHERE i = 'cze+';
DELETE FROM "Unicode data" WHERE t = 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'cze+';
INSERT INTO "Unicode data" (i, t) VALUES ('pol+', 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._');
SELECT * FROM "Unicode data" WHERE i = 'pol+';
DELETE FROM "Unicode data" WHERE t = 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'pol+';
INSERT INTO "Unicode data" (i, t) VALUES ('srp+', 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._');
SELECT * FROM "Unicode data" WHERE i = 'srp+';
DELETE FROM "Unicode data" WHERE t = 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'srp+';
-- 1257, LATIN7
SELECT * FROM "Unicode data" WHERE i = 'lav';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ķieģeļu%';
INSERT INTO "Unicode data" (i, t) VALUES ('lav+', 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._');
SELECT * FROM "Unicode data" WHERE i = 'lav+';
DELETE FROM "Unicode data" WHERE t = 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'lav+';
-- EUC_KR
SELECT * FROM "Unicode data" WHERE i = 'kor';
SELECT * FROM "Unicode data" WHERE t LIKE '키스의 고%';
INSERT INTO "Unicode data" (i, t) VALUES ('kor+', '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._');
SELECT * FROM "Unicode data" WHERE i = 'kor+';
DELETE FROM "Unicode data" WHERE t = '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'kor+';
-- 1254, LATIN5
SELECT * FROM "Unicode data" WHERE i = 'aze';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zəfər%';
INSERT INTO "Unicode data" (i, t) VALUES ('aze+', 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._');
SELECT * FROM "Unicode data" WHERE i = 'aze+';
DELETE FROM "Unicode data" WHERE t = 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'aze+';
-- etc
INSERT INTO "Unicode data" (i, t) VALUES ('arm+', 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_');
SELECT * FROM "Unicode data" WHERE i = 'arm+';
DELETE FROM "Unicode data" WHERE t = 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'arm+';
INSERT INTO "Unicode data" (i, t) VALUES ('gle+', 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._');
SELECT * FROM "Unicode data" WHERE i = 'gle+';
DELETE FROM "Unicode data" WHERE t = 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'gle+';
INSERT INTO "Unicode data" (i, t) VALUES ('epo+', 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._');
SELECT * FROM "Unicode data" WHERE i = 'epo+';
DELETE FROM "Unicode data" WHERE t = 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'epo+';

DROP FOREIGN TABLE "Unicode data";
DROP SERVER sqlite_svr;
DROP EXTENSION sqlite_fdw;
\connect contrib_regression;
DROP DATABASE "contrib_regression_WIN1250";

-- cp1251
CREATE DATABASE "contrib_regression_WIN1251" ENCODING WIN1251 LC_CTYPE='bg_BG' LC_COLLATE='bg_BG' template template0;
\connect "contrib_regression_WIN1251"
CREATE EXTENSION sqlite_fdw;
CREATE SERVER sqlite_svr FOREIGN DATA WRAPPER sqlite_fdw
OPTIONS (database '/tmp/sqlite_fdw_test/common.db');
CREATE FOREIGN TABLE "Unicode data"(i text OPTIONS (key 'true'), t text) SERVER sqlite_svr; 
-- EUC_JP
SELECT * FROM "Unicode data" WHERE i = 'jap';
SELECT * FROM "Unicode data" WHERE t LIKE 'いろはにほ%';
INSERT INTO "Unicode data" (i, t) VALUES ('jap+', 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._');
DELETE FROM "Unicode data" WHERE t = 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'jap+';
-- 1251, ISO_8859_5
SELECT * FROM "Unicode data" WHERE i = 'bel';
SELECT * FROM "Unicode data" WHERE i = 'bul';
SELECT * FROM "Unicode data" WHERE i = 'rus';
SELECT * FROM "Unicode data" WHERE i = 'ukr';
SELECT * FROM "Unicode data" WHERE t LIKE 'У руд%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ах, ч%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Широк%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Гей, %';
INSERT INTO "Unicode data" (i, t) VALUES ('bel+', 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._');
SELECT * FROM "Unicode data" WHERE i = 'bel+';
DELETE FROM "Unicode data" WHERE t = 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bel+';
INSERT INTO "Unicode data" (i, t) VALUES ('bul+', 'Ах, чудна българска земьо, полюшвай цъфтящи жита._');
SELECT * FROM "Unicode data" WHERE i = 'bul+';
DELETE FROM "Unicode data" WHERE t = 'Ах, чудна българска земьо, полюшвай цъфтящи жита._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bul+';
INSERT INTO "Unicode data" (i, t) VALUES ('rus+', 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._');
SELECT * FROM "Unicode data" WHERE i = 'rus+';
DELETE FROM "Unicode data" WHERE t = 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'rus+';
INSERT INTO "Unicode data" (i, t) VALUES ('ukr+', 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._');
SELECT * FROM "Unicode data" WHERE i = 'ukr+';
DELETE FROM "Unicode data" WHERE t = 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ukr+';
-- 1256, ISO_8859_6
SELECT * FROM "Unicode data" WHERE i = 'ara';
SELECT * FROM "Unicode data" WHERE t LIKE '%ضَظَغ%';
INSERT INTO "Unicode data" (i, t) VALUES ('ara+', 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_');
SELECT * FROM "Unicode data" WHERE i = 'ara+';
DELETE FROM "Unicode data" WHERE t = 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ara+';
-- 1253, ISO_8859_7
SELECT * FROM "Unicode data" WHERE i = 'gre';
SELECT * FROM "Unicode data" WHERE t LIKE 'Τάχισ%';
INSERT INTO "Unicode data" (i, t) VALUES ('gre+', 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_');
SELECT * FROM "Unicode data" WHERE i = 'gre+';
DELETE FROM "Unicode data" WHERE t = 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_';
-- 1255, ISO_8859_8
SELECT * FROM "Unicode data" WHERE i = 'heb';
SELECT * FROM "Unicode data" WHERE t LIKE '%כי ח%';
INSERT INTO "Unicode data" (i, t) VALUES ('heb+', 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_');
SELECT * FROM "Unicode data" WHERE i = 'heb+';
DELETE FROM "Unicode data" WHERE t = 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'heb+';
-- 1252, LATIN1
SELECT * FROM "Unicode data" WHERE i = 'eus';
SELECT * FROM "Unicode data" WHERE i = 'fra';
SELECT * FROM "Unicode data" WHERE i = 'spa';
SELECT * FROM "Unicode data" WHERE t LIKE 'Permi%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Dès N%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Quier%';
INSERT INTO "Unicode data" (i, t) VALUES ('eus+', 'Permin gox dabiltzu yoskiñ._');
SELECT * FROM "Unicode data" WHERE i = 'eus+';
DELETE FROM "Unicode data" WHERE t = 'Permin gox dabiltzu yoskiñ._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'eus+';
INSERT INTO "Unicode data" (i, t) VALUES ('fra+', 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_');
SELECT * FROM "Unicode data" WHERE i = 'fra+';
DELETE FROM "Unicode data" WHERE t = 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'fra+';
INSERT INTO "Unicode data" (i, t) VALUES ('spa+', 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._');
SELECT * FROM "Unicode data" WHERE i = 'spa+';
DELETE FROM "Unicode data" WHERE t = 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'spa+';
-- 1250, LATIN2
SELECT * FROM "Unicode data" WHERE i = 'cze';
SELECT * FROM "Unicode data" WHERE i = 'pol';
SELECT * FROM "Unicode data" WHERE i = 'srp';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zvláš%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Pchną%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ljuba%';
INSERT INTO "Unicode data" (i, t) VALUES ('cze+', 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._');
SELECT * FROM "Unicode data" WHERE i = 'cze+';
DELETE FROM "Unicode data" WHERE t = 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'cze+';
INSERT INTO "Unicode data" (i, t) VALUES ('pol+', 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._');
SELECT * FROM "Unicode data" WHERE i = 'pol+';
DELETE FROM "Unicode data" WHERE t = 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'pol+';
INSERT INTO "Unicode data" (i, t) VALUES ('srp+', 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._');
SELECT * FROM "Unicode data" WHERE i = 'srp+';
DELETE FROM "Unicode data" WHERE t = 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'srp+';
-- 1257, LATIN7
SELECT * FROM "Unicode data" WHERE i = 'lav';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ķieģeļu%';
INSERT INTO "Unicode data" (i, t) VALUES ('lav+', 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._');
SELECT * FROM "Unicode data" WHERE i = 'lav+';
DELETE FROM "Unicode data" WHERE t = 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'lav+';
-- EUC_KR
SELECT * FROM "Unicode data" WHERE i = 'kor';
SELECT * FROM "Unicode data" WHERE t LIKE '키스의 고%';
INSERT INTO "Unicode data" (i, t) VALUES ('kor+', '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._');
SELECT * FROM "Unicode data" WHERE i = 'kor+';
DELETE FROM "Unicode data" WHERE t = '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'kor+';
-- 1254, LATIN5
SELECT * FROM "Unicode data" WHERE i = 'aze';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zəfər%';
INSERT INTO "Unicode data" (i, t) VALUES ('aze+', 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._');
SELECT * FROM "Unicode data" WHERE i = 'aze+';
DELETE FROM "Unicode data" WHERE t = 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'aze+';
-- etc
INSERT INTO "Unicode data" (i, t) VALUES ('arm+', 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_');
SELECT * FROM "Unicode data" WHERE i = 'arm+';
DELETE FROM "Unicode data" WHERE t = 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'arm+';
INSERT INTO "Unicode data" (i, t) VALUES ('gle+', 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._');
SELECT * FROM "Unicode data" WHERE i = 'gle+';
DELETE FROM "Unicode data" WHERE t = 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'gle+';
INSERT INTO "Unicode data" (i, t) VALUES ('epo+', 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._');
SELECT * FROM "Unicode data" WHERE i = 'epo+';
DELETE FROM "Unicode data" WHERE t = 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'epo+';

DROP FOREIGN TABLE "Unicode data";
DROP SERVER sqlite_svr;
DROP EXTENSION sqlite_fdw;
\connect contrib_regression;
DROP DATABASE "contrib_regression_WIN1251";

-- cp1252
CREATE DATABASE "contrib_regression_WIN1252" ENCODING WIN1252 LC_CTYPE='POSIX' LC_COLLATE='POSIX' template template0;
\connect "contrib_regression_WIN1252"
CREATE EXTENSION sqlite_fdw;
CREATE SERVER sqlite_svr FOREIGN DATA WRAPPER sqlite_fdw
OPTIONS (database '/tmp/sqlite_fdw_test/common.db');
CREATE FOREIGN TABLE "Unicode data"(i text OPTIONS (key 'true'), t text) SERVER sqlite_svr; 
-- EUC_JP
SELECT * FROM "Unicode data" WHERE i = 'jap';
SELECT * FROM "Unicode data" WHERE t LIKE 'いろはにほ%';
INSERT INTO "Unicode data" (i, t) VALUES ('jap+', 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._');
DELETE FROM "Unicode data" WHERE t = 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'jap+';
-- 1251, ISO_8859_5
SELECT * FROM "Unicode data" WHERE i = 'bel';
SELECT * FROM "Unicode data" WHERE i = 'bul';
SELECT * FROM "Unicode data" WHERE i = 'rus';
SELECT * FROM "Unicode data" WHERE i = 'ukr';
SELECT * FROM "Unicode data" WHERE t LIKE 'У руд%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ах, ч%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Широк%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Гей, %';
INSERT INTO "Unicode data" (i, t) VALUES ('bel+', 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._');
SELECT * FROM "Unicode data" WHERE i = 'bel+';
DELETE FROM "Unicode data" WHERE t = 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bel+';
INSERT INTO "Unicode data" (i, t) VALUES ('bul+', 'Ах, чудна българска земьо, полюшвай цъфтящи жита._');
SELECT * FROM "Unicode data" WHERE i = 'bul+';
DELETE FROM "Unicode data" WHERE t = 'Ах, чудна българска земьо, полюшвай цъфтящи жита._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bul+';
INSERT INTO "Unicode data" (i, t) VALUES ('rus+', 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._');
SELECT * FROM "Unicode data" WHERE i = 'rus+';
DELETE FROM "Unicode data" WHERE t = 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'rus+';
INSERT INTO "Unicode data" (i, t) VALUES ('ukr+', 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._');
SELECT * FROM "Unicode data" WHERE i = 'ukr+';
DELETE FROM "Unicode data" WHERE t = 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ukr+';
-- 1256, ISO_8859_6
SELECT * FROM "Unicode data" WHERE i = 'ara';
SELECT * FROM "Unicode data" WHERE t LIKE '%ضَظَغ%';
INSERT INTO "Unicode data" (i, t) VALUES ('ara+', 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_');
SELECT * FROM "Unicode data" WHERE i = 'ara+';
DELETE FROM "Unicode data" WHERE t = 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ara+';
-- 1253, ISO_8859_7
SELECT * FROM "Unicode data" WHERE i = 'gre';
SELECT * FROM "Unicode data" WHERE t LIKE 'Τάχισ%';
INSERT INTO "Unicode data" (i, t) VALUES ('gre+', 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_');
SELECT * FROM "Unicode data" WHERE i = 'gre+';
DELETE FROM "Unicode data" WHERE t = 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_';
-- 1255, ISO_8859_8
SELECT * FROM "Unicode data" WHERE i = 'heb';
SELECT * FROM "Unicode data" WHERE t LIKE '%כי ח%';
INSERT INTO "Unicode data" (i, t) VALUES ('heb+', 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_');
SELECT * FROM "Unicode data" WHERE i = 'heb+';
DELETE FROM "Unicode data" WHERE t = 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'heb+';
-- 1252, LATIN1
SELECT * FROM "Unicode data" WHERE i = 'eus';
SELECT * FROM "Unicode data" WHERE i = 'fra';
SELECT * FROM "Unicode data" WHERE i = 'spa';
SELECT * FROM "Unicode data" WHERE t LIKE 'Permi%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Dès N%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Quier%';
INSERT INTO "Unicode data" (i, t) VALUES ('eus+', 'Permin gox dabiltzu yoskiñ._');
SELECT * FROM "Unicode data" WHERE i = 'eus+';
DELETE FROM "Unicode data" WHERE t = 'Permin gox dabiltzu yoskiñ._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'eus+';
INSERT INTO "Unicode data" (i, t) VALUES ('fra+', 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_');
SELECT * FROM "Unicode data" WHERE i = 'fra+';
DELETE FROM "Unicode data" WHERE t = 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'fra+';
INSERT INTO "Unicode data" (i, t) VALUES ('spa+', 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._');
SELECT * FROM "Unicode data" WHERE i = 'spa+';
DELETE FROM "Unicode data" WHERE t = 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'spa+';
-- 1250, LATIN2
SELECT * FROM "Unicode data" WHERE i = 'cze';
SELECT * FROM "Unicode data" WHERE i = 'pol';
SELECT * FROM "Unicode data" WHERE i = 'srp';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zvláš%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Pchną%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ljuba%';
INSERT INTO "Unicode data" (i, t) VALUES ('cze+', 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._');
SELECT * FROM "Unicode data" WHERE i = 'cze+';
DELETE FROM "Unicode data" WHERE t = 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'cze+';
INSERT INTO "Unicode data" (i, t) VALUES ('pol+', 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._');
SELECT * FROM "Unicode data" WHERE i = 'pol+';
DELETE FROM "Unicode data" WHERE t = 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'pol+';
INSERT INTO "Unicode data" (i, t) VALUES ('srp+', 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._');
SELECT * FROM "Unicode data" WHERE i = 'srp+';
DELETE FROM "Unicode data" WHERE t = 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'srp+';
-- 1257, LATIN7
SELECT * FROM "Unicode data" WHERE i = 'lav';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ķieģeļu%';
INSERT INTO "Unicode data" (i, t) VALUES ('lav+', 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._');
SELECT * FROM "Unicode data" WHERE i = 'lav+';
DELETE FROM "Unicode data" WHERE t = 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'lav+';
-- EUC_KR
SELECT * FROM "Unicode data" WHERE i = 'kor';
SELECT * FROM "Unicode data" WHERE t LIKE '키스의 고%';
INSERT INTO "Unicode data" (i, t) VALUES ('kor+', '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._');
SELECT * FROM "Unicode data" WHERE i = 'kor+';
DELETE FROM "Unicode data" WHERE t = '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'kor+';
-- 1254, LATIN5
SELECT * FROM "Unicode data" WHERE i = 'aze';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zəfər%';
INSERT INTO "Unicode data" (i, t) VALUES ('aze+', 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._');
SELECT * FROM "Unicode data" WHERE i = 'aze+';
DELETE FROM "Unicode data" WHERE t = 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'aze+';
-- etc
INSERT INTO "Unicode data" (i, t) VALUES ('arm+', 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_');
SELECT * FROM "Unicode data" WHERE i = 'arm+';
DELETE FROM "Unicode data" WHERE t = 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'arm+';
INSERT INTO "Unicode data" (i, t) VALUES ('gle+', 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._');
SELECT * FROM "Unicode data" WHERE i = 'gle+';
DELETE FROM "Unicode data" WHERE t = 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'gle+';
INSERT INTO "Unicode data" (i, t) VALUES ('epo+', 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._');
SELECT * FROM "Unicode data" WHERE i = 'epo+';
DELETE FROM "Unicode data" WHERE t = 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'epo+';

DROP FOREIGN TABLE "Unicode data";
DROP SERVER sqlite_svr;
DROP EXTENSION sqlite_fdw;
\connect contrib_regression;
DROP DATABASE "contrib_regression_WIN1252";

-- cp1253
CREATE DATABASE "contrib_regression_WIN1253" ENCODING WIN1253 LC_CTYPE='POSIX' LC_COLLATE='POSIX' template template0;
\connect "contrib_regression_WIN1253"
CREATE EXTENSION sqlite_fdw;
CREATE SERVER sqlite_svr FOREIGN DATA WRAPPER sqlite_fdw
OPTIONS (database '/tmp/sqlite_fdw_test/common.db');
CREATE FOREIGN TABLE "Unicode data"(i text OPTIONS (key 'true'), t text) SERVER sqlite_svr; 
-- EUC_JP
SELECT * FROM "Unicode data" WHERE i = 'jap';
SELECT * FROM "Unicode data" WHERE t LIKE 'いろはにほ%';
INSERT INTO "Unicode data" (i, t) VALUES ('jap+', 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._');
DELETE FROM "Unicode data" WHERE t = 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'jap+';
-- 1251, ISO_8859_5
SELECT * FROM "Unicode data" WHERE i = 'bel';
SELECT * FROM "Unicode data" WHERE i = 'bul';
SELECT * FROM "Unicode data" WHERE i = 'rus';
SELECT * FROM "Unicode data" WHERE i = 'ukr';
SELECT * FROM "Unicode data" WHERE t LIKE 'У руд%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ах, ч%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Широк%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Гей, %';
INSERT INTO "Unicode data" (i, t) VALUES ('bel+', 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._');
SELECT * FROM "Unicode data" WHERE i = 'bel+';
DELETE FROM "Unicode data" WHERE t = 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bel+';
INSERT INTO "Unicode data" (i, t) VALUES ('bul+', 'Ах, чудна българска земьо, полюшвай цъфтящи жита._');
SELECT * FROM "Unicode data" WHERE i = 'bul+';
DELETE FROM "Unicode data" WHERE t = 'Ах, чудна българска земьо, полюшвай цъфтящи жита._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bul+';
INSERT INTO "Unicode data" (i, t) VALUES ('rus+', 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._');
SELECT * FROM "Unicode data" WHERE i = 'rus+';
DELETE FROM "Unicode data" WHERE t = 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'rus+';
INSERT INTO "Unicode data" (i, t) VALUES ('ukr+', 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._');
SELECT * FROM "Unicode data" WHERE i = 'ukr+';
DELETE FROM "Unicode data" WHERE t = 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ukr+';
-- 1256, ISO_8859_6
SELECT * FROM "Unicode data" WHERE i = 'ara';
SELECT * FROM "Unicode data" WHERE t LIKE '%ضَظَغ%';
INSERT INTO "Unicode data" (i, t) VALUES ('ara+', 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_');
SELECT * FROM "Unicode data" WHERE i = 'ara+';
DELETE FROM "Unicode data" WHERE t = 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ara+';
-- 1253, ISO_8859_7
SELECT * FROM "Unicode data" WHERE i = 'gre';
SELECT * FROM "Unicode data" WHERE t LIKE 'Τάχισ%';
INSERT INTO "Unicode data" (i, t) VALUES ('gre+', 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_');
SELECT * FROM "Unicode data" WHERE i = 'gre+';
DELETE FROM "Unicode data" WHERE t = 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_';
-- 1255, ISO_8859_8
SELECT * FROM "Unicode data" WHERE i = 'heb';
SELECT * FROM "Unicode data" WHERE t LIKE '%כי ח%';
INSERT INTO "Unicode data" (i, t) VALUES ('heb+', 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_');
SELECT * FROM "Unicode data" WHERE i = 'heb+';
DELETE FROM "Unicode data" WHERE t = 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'heb+';
-- 1252, LATIN1
SELECT * FROM "Unicode data" WHERE i = 'eus';
SELECT * FROM "Unicode data" WHERE i = 'fra';
SELECT * FROM "Unicode data" WHERE i = 'spa';
SELECT * FROM "Unicode data" WHERE t LIKE 'Permi%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Dès N%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Quier%';
INSERT INTO "Unicode data" (i, t) VALUES ('eus+', 'Permin gox dabiltzu yoskiñ._');
SELECT * FROM "Unicode data" WHERE i = 'eus+';
DELETE FROM "Unicode data" WHERE t = 'Permin gox dabiltzu yoskiñ._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'eus+';
INSERT INTO "Unicode data" (i, t) VALUES ('fra+', 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_');
SELECT * FROM "Unicode data" WHERE i = 'fra+';
DELETE FROM "Unicode data" WHERE t = 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'fra+';
INSERT INTO "Unicode data" (i, t) VALUES ('spa+', 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._');
SELECT * FROM "Unicode data" WHERE i = 'spa+';
DELETE FROM "Unicode data" WHERE t = 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'spa+';
-- 1250, LATIN2
SELECT * FROM "Unicode data" WHERE i = 'cze';
SELECT * FROM "Unicode data" WHERE i = 'pol';
SELECT * FROM "Unicode data" WHERE i = 'srp';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zvláš%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Pchną%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ljuba%';
INSERT INTO "Unicode data" (i, t) VALUES ('cze+', 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._');
SELECT * FROM "Unicode data" WHERE i = 'cze+';
DELETE FROM "Unicode data" WHERE t = 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'cze+';
INSERT INTO "Unicode data" (i, t) VALUES ('pol+', 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._');
SELECT * FROM "Unicode data" WHERE i = 'pol+';
DELETE FROM "Unicode data" WHERE t = 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'pol+';
INSERT INTO "Unicode data" (i, t) VALUES ('srp+', 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._');
SELECT * FROM "Unicode data" WHERE i = 'srp+';
DELETE FROM "Unicode data" WHERE t = 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'srp+';
-- 1257, LATIN7
SELECT * FROM "Unicode data" WHERE i = 'lav';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ķieģeļu%';
INSERT INTO "Unicode data" (i, t) VALUES ('lav+', 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._');
SELECT * FROM "Unicode data" WHERE i = 'lav+';
DELETE FROM "Unicode data" WHERE t = 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'lav+';
-- EUC_KR
SELECT * FROM "Unicode data" WHERE i = 'kor';
SELECT * FROM "Unicode data" WHERE t LIKE '키스의 고%';
INSERT INTO "Unicode data" (i, t) VALUES ('kor+', '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._');
SELECT * FROM "Unicode data" WHERE i = 'kor+';
DELETE FROM "Unicode data" WHERE t = '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'kor+';
-- 1254, LATIN5
SELECT * FROM "Unicode data" WHERE i = 'aze';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zəfər%';
INSERT INTO "Unicode data" (i, t) VALUES ('aze+', 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._');
SELECT * FROM "Unicode data" WHERE i = 'aze+';
DELETE FROM "Unicode data" WHERE t = 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'aze+';
-- etc
INSERT INTO "Unicode data" (i, t) VALUES ('arm+', 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_');
SELECT * FROM "Unicode data" WHERE i = 'arm+';
DELETE FROM "Unicode data" WHERE t = 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'arm+';
INSERT INTO "Unicode data" (i, t) VALUES ('gle+', 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._');
SELECT * FROM "Unicode data" WHERE i = 'gle+';
DELETE FROM "Unicode data" WHERE t = 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'gle+';
INSERT INTO "Unicode data" (i, t) VALUES ('epo+', 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._');
SELECT * FROM "Unicode data" WHERE i = 'epo+';
DELETE FROM "Unicode data" WHERE t = 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'epo+';

DROP FOREIGN TABLE "Unicode data";
DROP SERVER sqlite_svr;
DROP EXTENSION sqlite_fdw;
\connect contrib_regression;
DROP DATABASE "contrib_regression_WIN1253";

-- cp1254
CREATE DATABASE "contrib_regression_WIN1254" ENCODING WIN1254 LC_CTYPE='POSIX' LC_COLLATE='POSIX' template template0;
\connect "contrib_regression_WIN1254"
CREATE EXTENSION sqlite_fdw;
CREATE SERVER sqlite_svr FOREIGN DATA WRAPPER sqlite_fdw
OPTIONS (database '/tmp/sqlite_fdw_test/common.db');
CREATE FOREIGN TABLE "Unicode data"(i text OPTIONS (key 'true'), t text) SERVER sqlite_svr; 
-- EUC_JP
SELECT * FROM "Unicode data" WHERE i = 'jap';
SELECT * FROM "Unicode data" WHERE t LIKE 'いろはにほ%';
INSERT INTO "Unicode data" (i, t) VALUES ('jap+', 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._');
DELETE FROM "Unicode data" WHERE t = 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'jap+';
-- 1251, ISO_8859_5
SELECT * FROM "Unicode data" WHERE i = 'bel';
SELECT * FROM "Unicode data" WHERE i = 'bul';
SELECT * FROM "Unicode data" WHERE i = 'rus';
SELECT * FROM "Unicode data" WHERE i = 'ukr';
SELECT * FROM "Unicode data" WHERE t LIKE 'У руд%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ах, ч%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Широк%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Гей, %';
INSERT INTO "Unicode data" (i, t) VALUES ('bel+', 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._');
SELECT * FROM "Unicode data" WHERE i = 'bel+';
DELETE FROM "Unicode data" WHERE t = 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bel+';
INSERT INTO "Unicode data" (i, t) VALUES ('bul+', 'Ах, чудна българска земьо, полюшвай цъфтящи жита._');
SELECT * FROM "Unicode data" WHERE i = 'bul+';
DELETE FROM "Unicode data" WHERE t = 'Ах, чудна българска земьо, полюшвай цъфтящи жита._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bul+';
INSERT INTO "Unicode data" (i, t) VALUES ('rus+', 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._');
SELECT * FROM "Unicode data" WHERE i = 'rus+';
DELETE FROM "Unicode data" WHERE t = 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'rus+';
INSERT INTO "Unicode data" (i, t) VALUES ('ukr+', 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._');
SELECT * FROM "Unicode data" WHERE i = 'ukr+';
DELETE FROM "Unicode data" WHERE t = 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ukr+';
-- 1256, ISO_8859_6
SELECT * FROM "Unicode data" WHERE i = 'ara';
SELECT * FROM "Unicode data" WHERE t LIKE '%ضَظَغ%';
INSERT INTO "Unicode data" (i, t) VALUES ('ara+', 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_');
SELECT * FROM "Unicode data" WHERE i = 'ara+';
DELETE FROM "Unicode data" WHERE t = 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ara+';
-- 1253, ISO_8859_7
SELECT * FROM "Unicode data" WHERE i = 'gre';
SELECT * FROM "Unicode data" WHERE t LIKE 'Τάχισ%';
INSERT INTO "Unicode data" (i, t) VALUES ('gre+', 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_');
SELECT * FROM "Unicode data" WHERE i = 'gre+';
DELETE FROM "Unicode data" WHERE t = 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_';
-- 1255, ISO_8859_8
SELECT * FROM "Unicode data" WHERE i = 'heb';
SELECT * FROM "Unicode data" WHERE t LIKE '%כי ח%';
INSERT INTO "Unicode data" (i, t) VALUES ('heb+', 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_');
SELECT * FROM "Unicode data" WHERE i = 'heb+';
DELETE FROM "Unicode data" WHERE t = 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'heb+';
-- 1252, LATIN1
SELECT * FROM "Unicode data" WHERE i = 'eus';
SELECT * FROM "Unicode data" WHERE i = 'fra';
SELECT * FROM "Unicode data" WHERE i = 'spa';
SELECT * FROM "Unicode data" WHERE t LIKE 'Permi%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Dès N%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Quier%';
INSERT INTO "Unicode data" (i, t) VALUES ('eus+', 'Permin gox dabiltzu yoskiñ._');
SELECT * FROM "Unicode data" WHERE i = 'eus+';
DELETE FROM "Unicode data" WHERE t = 'Permin gox dabiltzu yoskiñ._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'eus+';
INSERT INTO "Unicode data" (i, t) VALUES ('fra+', 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_');
SELECT * FROM "Unicode data" WHERE i = 'fra+';
DELETE FROM "Unicode data" WHERE t = 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'fra+';
INSERT INTO "Unicode data" (i, t) VALUES ('spa+', 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._');
SELECT * FROM "Unicode data" WHERE i = 'spa+';
DELETE FROM "Unicode data" WHERE t = 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'spa+';
-- 1250, LATIN2
SELECT * FROM "Unicode data" WHERE i = 'cze';
SELECT * FROM "Unicode data" WHERE i = 'pol';
SELECT * FROM "Unicode data" WHERE i = 'srp';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zvláš%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Pchną%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ljuba%';
INSERT INTO "Unicode data" (i, t) VALUES ('cze+', 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._');
SELECT * FROM "Unicode data" WHERE i = 'cze+';
DELETE FROM "Unicode data" WHERE t = 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'cze+';
INSERT INTO "Unicode data" (i, t) VALUES ('pol+', 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._');
SELECT * FROM "Unicode data" WHERE i = 'pol+';
DELETE FROM "Unicode data" WHERE t = 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'pol+';
INSERT INTO "Unicode data" (i, t) VALUES ('srp+', 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._');
SELECT * FROM "Unicode data" WHERE i = 'srp+';
DELETE FROM "Unicode data" WHERE t = 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'srp+';
-- 1257, LATIN7
SELECT * FROM "Unicode data" WHERE i = 'lav';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ķieģeļu%';
INSERT INTO "Unicode data" (i, t) VALUES ('lav+', 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._');
SELECT * FROM "Unicode data" WHERE i = 'lav+';
DELETE FROM "Unicode data" WHERE t = 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'lav+';
-- EUC_KR
SELECT * FROM "Unicode data" WHERE i = 'kor';
SELECT * FROM "Unicode data" WHERE t LIKE '키스의 고%';
INSERT INTO "Unicode data" (i, t) VALUES ('kor+', '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._');
SELECT * FROM "Unicode data" WHERE i = 'kor+';
DELETE FROM "Unicode data" WHERE t = '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'kor+';
-- 1254, LATIN5
SELECT * FROM "Unicode data" WHERE i = 'aze';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zəfər%';
INSERT INTO "Unicode data" (i, t) VALUES ('aze+', 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._');
SELECT * FROM "Unicode data" WHERE i = 'aze+';
DELETE FROM "Unicode data" WHERE t = 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'aze+';
-- etc
INSERT INTO "Unicode data" (i, t) VALUES ('arm+', 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_');
SELECT * FROM "Unicode data" WHERE i = 'arm+';
DELETE FROM "Unicode data" WHERE t = 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'arm+';
INSERT INTO "Unicode data" (i, t) VALUES ('gle+', 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._');
SELECT * FROM "Unicode data" WHERE i = 'gle+';
DELETE FROM "Unicode data" WHERE t = 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'gle+';
INSERT INTO "Unicode data" (i, t) VALUES ('epo+', 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._');
SELECT * FROM "Unicode data" WHERE i = 'epo+';
DELETE FROM "Unicode data" WHERE t = 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'epo+';

DROP FOREIGN TABLE "Unicode data";
DROP SERVER sqlite_svr;
DROP EXTENSION sqlite_fdw;
\connect contrib_regression;
DROP DATABASE "contrib_regression_WIN1254";

-- cp1255
CREATE DATABASE "contrib_regression_WIN1255" ENCODING WIN1255 LC_CTYPE='POSIX' LC_COLLATE='POSIX' template template0;
\connect "contrib_regression_WIN1255"
CREATE EXTENSION sqlite_fdw;
CREATE SERVER sqlite_svr FOREIGN DATA WRAPPER sqlite_fdw
OPTIONS (database '/tmp/sqlite_fdw_test/common.db');
CREATE FOREIGN TABLE "Unicode data"(i text OPTIONS (key 'true'), t text) SERVER sqlite_svr; 
-- EUC_JP
SELECT * FROM "Unicode data" WHERE i = 'jap';
SELECT * FROM "Unicode data" WHERE t LIKE 'いろはにほ%';
INSERT INTO "Unicode data" (i, t) VALUES ('jap+', 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._');
DELETE FROM "Unicode data" WHERE t = 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'jap+';
-- 1251, ISO_8859_5
SELECT * FROM "Unicode data" WHERE i = 'bel';
SELECT * FROM "Unicode data" WHERE i = 'bul';
SELECT * FROM "Unicode data" WHERE i = 'rus';
SELECT * FROM "Unicode data" WHERE i = 'ukr';
SELECT * FROM "Unicode data" WHERE t LIKE 'У руд%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ах, ч%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Широк%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Гей, %';
INSERT INTO "Unicode data" (i, t) VALUES ('bel+', 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._');
SELECT * FROM "Unicode data" WHERE i = 'bel+';
DELETE FROM "Unicode data" WHERE t = 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bel+';
INSERT INTO "Unicode data" (i, t) VALUES ('bul+', 'Ах, чудна българска земьо, полюшвай цъфтящи жита._');
SELECT * FROM "Unicode data" WHERE i = 'bul+';
DELETE FROM "Unicode data" WHERE t = 'Ах, чудна българска земьо, полюшвай цъфтящи жита._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bul+';
INSERT INTO "Unicode data" (i, t) VALUES ('rus+', 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._');
SELECT * FROM "Unicode data" WHERE i = 'rus+';
DELETE FROM "Unicode data" WHERE t = 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'rus+';
INSERT INTO "Unicode data" (i, t) VALUES ('ukr+', 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._');
SELECT * FROM "Unicode data" WHERE i = 'ukr+';
DELETE FROM "Unicode data" WHERE t = 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ukr+';
-- 1256, ISO_8859_6
SELECT * FROM "Unicode data" WHERE i = 'ara';
SELECT * FROM "Unicode data" WHERE t LIKE '%ضَظَغ%';
INSERT INTO "Unicode data" (i, t) VALUES ('ara+', 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_');
SELECT * FROM "Unicode data" WHERE i = 'ara+';
DELETE FROM "Unicode data" WHERE t = 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ara+';
-- 1253, ISO_8859_7
SELECT * FROM "Unicode data" WHERE i = 'gre';
SELECT * FROM "Unicode data" WHERE t LIKE 'Τάχισ%';
INSERT INTO "Unicode data" (i, t) VALUES ('gre+', 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_');
SELECT * FROM "Unicode data" WHERE i = 'gre+';
DELETE FROM "Unicode data" WHERE t = 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_';
-- 1255, ISO_8859_8
SELECT * FROM "Unicode data" WHERE i = 'heb';
SELECT * FROM "Unicode data" WHERE t LIKE '%כי ח%';
INSERT INTO "Unicode data" (i, t) VALUES ('heb+', 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_');
SELECT * FROM "Unicode data" WHERE i = 'heb+';
DELETE FROM "Unicode data" WHERE t = 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'heb+';
-- 1252, LATIN1
SELECT * FROM "Unicode data" WHERE i = 'eus';
SELECT * FROM "Unicode data" WHERE i = 'fra';
SELECT * FROM "Unicode data" WHERE i = 'spa';
SELECT * FROM "Unicode data" WHERE t LIKE 'Permi%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Dès N%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Quier%';
INSERT INTO "Unicode data" (i, t) VALUES ('eus+', 'Permin gox dabiltzu yoskiñ._');
SELECT * FROM "Unicode data" WHERE i = 'eus+';
DELETE FROM "Unicode data" WHERE t = 'Permin gox dabiltzu yoskiñ._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'eus+';
INSERT INTO "Unicode data" (i, t) VALUES ('fra+', 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_');
SELECT * FROM "Unicode data" WHERE i = 'fra+';
DELETE FROM "Unicode data" WHERE t = 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'fra+';
INSERT INTO "Unicode data" (i, t) VALUES ('spa+', 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._');
SELECT * FROM "Unicode data" WHERE i = 'spa+';
DELETE FROM "Unicode data" WHERE t = 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'spa+';
-- 1250, LATIN2
SELECT * FROM "Unicode data" WHERE i = 'cze';
SELECT * FROM "Unicode data" WHERE i = 'pol';
SELECT * FROM "Unicode data" WHERE i = 'srp';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zvláš%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Pchną%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ljuba%';
INSERT INTO "Unicode data" (i, t) VALUES ('cze+', 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._');
SELECT * FROM "Unicode data" WHERE i = 'cze+';
DELETE FROM "Unicode data" WHERE t = 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'cze+';
INSERT INTO "Unicode data" (i, t) VALUES ('pol+', 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._');
SELECT * FROM "Unicode data" WHERE i = 'pol+';
DELETE FROM "Unicode data" WHERE t = 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'pol+';
INSERT INTO "Unicode data" (i, t) VALUES ('srp+', 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._');
SELECT * FROM "Unicode data" WHERE i = 'srp+';
DELETE FROM "Unicode data" WHERE t = 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'srp+';
-- 1257, LATIN7
SELECT * FROM "Unicode data" WHERE i = 'lav';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ķieģeļu%';
INSERT INTO "Unicode data" (i, t) VALUES ('lav+', 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._');
SELECT * FROM "Unicode data" WHERE i = 'lav+';
DELETE FROM "Unicode data" WHERE t = 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'lav+';
-- EUC_KR
SELECT * FROM "Unicode data" WHERE i = 'kor';
SELECT * FROM "Unicode data" WHERE t LIKE '키스의 고%';
INSERT INTO "Unicode data" (i, t) VALUES ('kor+', '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._');
SELECT * FROM "Unicode data" WHERE i = 'kor+';
DELETE FROM "Unicode data" WHERE t = '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'kor+';
-- 1254, LATIN5
SELECT * FROM "Unicode data" WHERE i = 'aze';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zəfər%';
INSERT INTO "Unicode data" (i, t) VALUES ('aze+', 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._');
SELECT * FROM "Unicode data" WHERE i = 'aze+';
DELETE FROM "Unicode data" WHERE t = 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'aze+';
-- etc
INSERT INTO "Unicode data" (i, t) VALUES ('arm+', 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_');
SELECT * FROM "Unicode data" WHERE i = 'arm+';
DELETE FROM "Unicode data" WHERE t = 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'arm+';
INSERT INTO "Unicode data" (i, t) VALUES ('gle+', 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._');
SELECT * FROM "Unicode data" WHERE i = 'gle+';
DELETE FROM "Unicode data" WHERE t = 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'gle+';
INSERT INTO "Unicode data" (i, t) VALUES ('epo+', 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._');
SELECT * FROM "Unicode data" WHERE i = 'epo+';
DELETE FROM "Unicode data" WHERE t = 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'epo+';

DROP FOREIGN TABLE "Unicode data";
DROP SERVER sqlite_svr;
DROP EXTENSION sqlite_fdw;
\connect contrib_regression;
DROP DATABASE "contrib_regression_WIN1255";

-- cp1256
CREATE DATABASE "contrib_regression_WIN1256" ENCODING WIN1256 LC_CTYPE='POSIX' LC_COLLATE='POSIX' template template0;
\connect "contrib_regression_WIN1256"
CREATE EXTENSION sqlite_fdw;
CREATE SERVER sqlite_svr FOREIGN DATA WRAPPER sqlite_fdw
OPTIONS (database '/tmp/sqlite_fdw_test/common.db');
CREATE FOREIGN TABLE "Unicode data"(i text OPTIONS (key 'true'), t text) SERVER sqlite_svr; 
-- EUC_JP
SELECT * FROM "Unicode data" WHERE i = 'jap';
SELECT * FROM "Unicode data" WHERE t LIKE 'いろはにほ%';
INSERT INTO "Unicode data" (i, t) VALUES ('jap+', 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._');
DELETE FROM "Unicode data" WHERE t = 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'jap+';
SELECT count(*) n FROM "Unicode data" WHERE i = 'jap+';
-- 1251, ISO_8859_5
SELECT * FROM "Unicode data" WHERE i = 'bel';
SELECT * FROM "Unicode data" WHERE i = 'bul';
SELECT * FROM "Unicode data" WHERE i = 'rus';
SELECT * FROM "Unicode data" WHERE i = 'ukr';
SELECT * FROM "Unicode data" WHERE t LIKE 'У руд%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ах, ч%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Широк%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Гей, %';
INSERT INTO "Unicode data" (i, t) VALUES ('bel+', 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._');
SELECT * FROM "Unicode data" WHERE i = 'bel+';
DELETE FROM "Unicode data" WHERE t = 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bel+';
INSERT INTO "Unicode data" (i, t) VALUES ('bul+', 'Ах, чудна българска земьо, полюшвай цъфтящи жита._');
SELECT * FROM "Unicode data" WHERE i = 'bul+';
DELETE FROM "Unicode data" WHERE t = 'Ах, чудна българска земьо, полюшвай цъфтящи жита._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bul+';
INSERT INTO "Unicode data" (i, t) VALUES ('rus+', 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._');
SELECT * FROM "Unicode data" WHERE i = 'rus+';
DELETE FROM "Unicode data" WHERE t = 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'rus+';
INSERT INTO "Unicode data" (i, t) VALUES ('ukr+', 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._');
SELECT * FROM "Unicode data" WHERE i = 'ukr+';
DELETE FROM "Unicode data" WHERE t = 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ukr+';
-- 1256, ISO_8859_6
SELECT * FROM "Unicode data" WHERE i = 'ara';
SELECT * FROM "Unicode data" WHERE t LIKE '%ضَظَغ%';
INSERT INTO "Unicode data" (i, t) VALUES ('ara+', 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_');
SELECT * FROM "Unicode data" WHERE i = 'ara+';
DELETE FROM "Unicode data" WHERE t = 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ara+';
-- 1253, ISO_8859_7
SELECT * FROM "Unicode data" WHERE i = 'gre';
SELECT * FROM "Unicode data" WHERE t LIKE 'Τάχισ%';
INSERT INTO "Unicode data" (i, t) VALUES ('gre+', 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_');
SELECT * FROM "Unicode data" WHERE i = 'gre+';
DELETE FROM "Unicode data" WHERE t = 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_';
-- 1255, ISO_8859_8
SELECT * FROM "Unicode data" WHERE i = 'heb';
SELECT * FROM "Unicode data" WHERE t LIKE '%כי ח%';
INSERT INTO "Unicode data" (i, t) VALUES ('heb+', 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_');
SELECT * FROM "Unicode data" WHERE i = 'heb+';
DELETE FROM "Unicode data" WHERE t = 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'heb+';
-- 1252, LATIN1
SELECT * FROM "Unicode data" WHERE i = 'eus';
SELECT * FROM "Unicode data" WHERE i = 'fra';
SELECT * FROM "Unicode data" WHERE i = 'spa';
SELECT * FROM "Unicode data" WHERE t LIKE 'Permi%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Dès N%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Quier%';
INSERT INTO "Unicode data" (i, t) VALUES ('eus+', 'Permin gox dabiltzu yoskiñ._');
SELECT * FROM "Unicode data" WHERE i = 'eus+';
DELETE FROM "Unicode data" WHERE t = 'Permin gox dabiltzu yoskiñ._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'eus+';
INSERT INTO "Unicode data" (i, t) VALUES ('fra+', 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_');
SELECT * FROM "Unicode data" WHERE i = 'fra+';
DELETE FROM "Unicode data" WHERE t = 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'fra+';
INSERT INTO "Unicode data" (i, t) VALUES ('spa+', 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._');
SELECT * FROM "Unicode data" WHERE i = 'spa+';
DELETE FROM "Unicode data" WHERE t = 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'spa+';
-- 1250, LATIN2
SELECT * FROM "Unicode data" WHERE i = 'cze';
SELECT * FROM "Unicode data" WHERE i = 'pol';
SELECT * FROM "Unicode data" WHERE i = 'srp';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zvláš%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Pchną%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ljuba%';
INSERT INTO "Unicode data" (i, t) VALUES ('cze+', 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._');
SELECT * FROM "Unicode data" WHERE i = 'cze+';
DELETE FROM "Unicode data" WHERE t = 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'cze+';
INSERT INTO "Unicode data" (i, t) VALUES ('pol+', 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._');
SELECT * FROM "Unicode data" WHERE i = 'pol+';
DELETE FROM "Unicode data" WHERE t = 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'pol+';
INSERT INTO "Unicode data" (i, t) VALUES ('srp+', 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._');
SELECT * FROM "Unicode data" WHERE i = 'srp+';
DELETE FROM "Unicode data" WHERE t = 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'srp+';
-- 1257, LATIN7
SELECT * FROM "Unicode data" WHERE i = 'lav';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ķieģeļu%';
INSERT INTO "Unicode data" (i, t) VALUES ('lav+', 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._');
SELECT * FROM "Unicode data" WHERE i = 'lav+';
DELETE FROM "Unicode data" WHERE t = 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'lav+';
-- EUC_KR
SELECT * FROM "Unicode data" WHERE i = 'kor';
SELECT * FROM "Unicode data" WHERE t LIKE '키스의 고%';
INSERT INTO "Unicode data" (i, t) VALUES ('kor+', '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._');
SELECT * FROM "Unicode data" WHERE i = 'kor+';
DELETE FROM "Unicode data" WHERE t = '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'kor+';
-- 1254, LATIN5
SELECT * FROM "Unicode data" WHERE i = 'aze';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zəfər%';
INSERT INTO "Unicode data" (i, t) VALUES ('aze+', 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._');
SELECT * FROM "Unicode data" WHERE i = 'aze+';
DELETE FROM "Unicode data" WHERE t = 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'aze+';
-- etc
INSERT INTO "Unicode data" (i, t) VALUES ('arm+', 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_');
SELECT * FROM "Unicode data" WHERE i = 'arm+';
DELETE FROM "Unicode data" WHERE t = 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'arm+';
INSERT INTO "Unicode data" (i, t) VALUES ('gle+', 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._');
SELECT * FROM "Unicode data" WHERE i = 'gle+';
DELETE FROM "Unicode data" WHERE t = 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'gle+';
INSERT INTO "Unicode data" (i, t) VALUES ('epo+', 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._');
SELECT * FROM "Unicode data" WHERE i = 'epo+';
DELETE FROM "Unicode data" WHERE t = 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'epo+';

DROP FOREIGN TABLE "Unicode data";
DROP SERVER sqlite_svr;
DROP EXTENSION sqlite_fdw;
\connect contrib_regression;
DROP DATABASE "contrib_regression_WIN1256";

-- cp1257
CREATE DATABASE "contrib_regression_WIN1257" ENCODING WIN1257 LC_CTYPE='POSIX' LC_COLLATE='POSIX' template template0;
\connect "contrib_regression_WIN1257"
CREATE EXTENSION sqlite_fdw;
CREATE SERVER sqlite_svr FOREIGN DATA WRAPPER sqlite_fdw
OPTIONS (database '/tmp/sqlite_fdw_test/common.db');
CREATE FOREIGN TABLE "Unicode data"(i text OPTIONS (key 'true'), t text) SERVER sqlite_svr; 
-- EUC_JP
SELECT * FROM "Unicode data" WHERE i = 'jap';
SELECT * FROM "Unicode data" WHERE t LIKE 'いろはにほ%';
INSERT INTO "Unicode data" (i, t) VALUES ('jap+', 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._');
DELETE FROM "Unicode data" WHERE t = 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'jap+';
-- 1251, ISO_8859_5
SELECT * FROM "Unicode data" WHERE i = 'bel';
SELECT * FROM "Unicode data" WHERE i = 'bul';
SELECT * FROM "Unicode data" WHERE i = 'rus';
SELECT * FROM "Unicode data" WHERE i = 'ukr';
SELECT * FROM "Unicode data" WHERE t LIKE 'У руд%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ах, ч%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Широк%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Гей, %';
INSERT INTO "Unicode data" (i, t) VALUES ('bel+', 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._');
SELECT * FROM "Unicode data" WHERE i = 'bel+';
DELETE FROM "Unicode data" WHERE t = 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bel+';
INSERT INTO "Unicode data" (i, t) VALUES ('bul+', 'Ах, чудна българска земьо, полюшвай цъфтящи жита._');
SELECT * FROM "Unicode data" WHERE i = 'bul+';
DELETE FROM "Unicode data" WHERE t = 'Ах, чудна българска земьо, полюшвай цъфтящи жита._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bul+';
INSERT INTO "Unicode data" (i, t) VALUES ('rus+', 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._');
SELECT * FROM "Unicode data" WHERE i = 'rus+';
DELETE FROM "Unicode data" WHERE t = 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'rus+';
INSERT INTO "Unicode data" (i, t) VALUES ('ukr+', 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._');
SELECT * FROM "Unicode data" WHERE i = 'ukr+';
DELETE FROM "Unicode data" WHERE t = 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ukr+';
-- 1256, ISO_8859_6
SELECT * FROM "Unicode data" WHERE i = 'ara';
SELECT * FROM "Unicode data" WHERE t LIKE '%ضَظَغ%';
INSERT INTO "Unicode data" (i, t) VALUES ('ara+', 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_');
SELECT * FROM "Unicode data" WHERE i = 'ara+';
DELETE FROM "Unicode data" WHERE t = 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ara+';
-- 1253, ISO_8859_7
SELECT * FROM "Unicode data" WHERE i = 'gre';
SELECT * FROM "Unicode data" WHERE t LIKE 'Τάχισ%';
INSERT INTO "Unicode data" (i, t) VALUES ('gre+', 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_');
SELECT * FROM "Unicode data" WHERE i = 'gre+';
DELETE FROM "Unicode data" WHERE t = 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_';
-- 1255, ISO_8859_8
SELECT * FROM "Unicode data" WHERE i = 'heb';
SELECT * FROM "Unicode data" WHERE t LIKE '%כי ח%';
INSERT INTO "Unicode data" (i, t) VALUES ('heb+', 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_');
SELECT * FROM "Unicode data" WHERE i = 'heb+';
DELETE FROM "Unicode data" WHERE t = 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'heb+';
-- 1252, LATIN1
SELECT * FROM "Unicode data" WHERE i = 'eus';
SELECT * FROM "Unicode data" WHERE i = 'fra';
SELECT * FROM "Unicode data" WHERE i = 'spa';
SELECT * FROM "Unicode data" WHERE t LIKE 'Permi%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Dès N%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Quier%';
INSERT INTO "Unicode data" (i, t) VALUES ('eus+', 'Permin gox dabiltzu yoskiñ._');
SELECT * FROM "Unicode data" WHERE i = 'eus+';
DELETE FROM "Unicode data" WHERE t = 'Permin gox dabiltzu yoskiñ._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'eus+';
INSERT INTO "Unicode data" (i, t) VALUES ('fra+', 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_');
SELECT * FROM "Unicode data" WHERE i = 'fra+';
DELETE FROM "Unicode data" WHERE t = 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'fra+';
INSERT INTO "Unicode data" (i, t) VALUES ('spa+', 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._');
SELECT * FROM "Unicode data" WHERE i = 'spa+';
DELETE FROM "Unicode data" WHERE t = 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'spa+';
-- 1250, LATIN2
SELECT * FROM "Unicode data" WHERE i = 'cze';
SELECT * FROM "Unicode data" WHERE i = 'pol';
SELECT * FROM "Unicode data" WHERE i = 'srp';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zvláš%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Pchną%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ljuba%';
INSERT INTO "Unicode data" (i, t) VALUES ('cze+', 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._');
SELECT * FROM "Unicode data" WHERE i = 'cze+';
DELETE FROM "Unicode data" WHERE t = 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'cze+';
INSERT INTO "Unicode data" (i, t) VALUES ('pol+', 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._');
SELECT * FROM "Unicode data" WHERE i = 'pol+';
DELETE FROM "Unicode data" WHERE t = 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'pol+';
INSERT INTO "Unicode data" (i, t) VALUES ('srp+', 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._');
SELECT * FROM "Unicode data" WHERE i = 'srp+';
DELETE FROM "Unicode data" WHERE t = 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'srp+';
-- 1257, LATIN7
SELECT * FROM "Unicode data" WHERE i = 'lav';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ķieģeļu%';
INSERT INTO "Unicode data" (i, t) VALUES ('lav+', 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._');
SELECT * FROM "Unicode data" WHERE i = 'lav+';
DELETE FROM "Unicode data" WHERE t = 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'lav+';
-- EUC_KR
SELECT * FROM "Unicode data" WHERE i = 'kor';
SELECT * FROM "Unicode data" WHERE t LIKE '키스의 고%';
INSERT INTO "Unicode data" (i, t) VALUES ('kor+', '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._');
SELECT * FROM "Unicode data" WHERE i = 'kor+';
DELETE FROM "Unicode data" WHERE t = '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'kor+';
-- 1254, LATIN5
SELECT * FROM "Unicode data" WHERE i = 'aze';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zəfər%';
INSERT INTO "Unicode data" (i, t) VALUES ('aze+', 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._');
SELECT * FROM "Unicode data" WHERE i = 'aze+';
DELETE FROM "Unicode data" WHERE t = 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'aze+';
-- etc
INSERT INTO "Unicode data" (i, t) VALUES ('arm+', 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_');
SELECT * FROM "Unicode data" WHERE i = 'arm+';
DELETE FROM "Unicode data" WHERE t = 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'arm+';
INSERT INTO "Unicode data" (i, t) VALUES ('gle+', 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._');
SELECT * FROM "Unicode data" WHERE i = 'gle+';
DELETE FROM "Unicode data" WHERE t = 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'gle+';
INSERT INTO "Unicode data" (i, t) VALUES ('epo+', 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._');
SELECT * FROM "Unicode data" WHERE i = 'epo+';
DELETE FROM "Unicode data" WHERE t = 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'epo+';

DROP FOREIGN TABLE "Unicode data";
DROP SERVER sqlite_svr;
DROP EXTENSION sqlite_fdw;
\connect contrib_regression;
DROP DATABASE "contrib_regression_WIN1257";

-- SQL_ASCII
CREATE DATABASE "contrib_regression_SQL_ASCII" ENCODING SQL_ASCII LC_CTYPE='POSIX' LC_COLLATE='POSIX' template template0;
\connect "contrib_regression_SQL_ASCII"
CREATE EXTENSION sqlite_fdw;
CREATE SERVER sqlite_svr FOREIGN DATA WRAPPER sqlite_fdw
OPTIONS (database '/tmp/sqlite_fdw_test/common.db');
CREATE FOREIGN TABLE "Unicode data"(i text OPTIONS (key 'true'), t text) SERVER sqlite_svr; 
-- EUC_JP
SELECT * FROM "Unicode data" WHERE i = 'jap';
SELECT * FROM "Unicode data" WHERE t LIKE 'いろはにほ%';
INSERT INTO "Unicode data" (i, t) VALUES ('jap+', 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._');
DELETE FROM "Unicode data" WHERE t = 'いろはにほへと ちりぬるを わかよたれそ つねならむ うゐのおくやま けふこえて あさきゆめみし ゑひもせす._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'jap+';
-- 1251, ISO_8859_5
SELECT * FROM "Unicode data" WHERE i = 'bel';
SELECT * FROM "Unicode data" WHERE i = 'bul';
SELECT * FROM "Unicode data" WHERE i = 'rus';
SELECT * FROM "Unicode data" WHERE i = 'ukr';
SELECT * FROM "Unicode data" WHERE t LIKE 'У руд%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ах, ч%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Широк%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Гей, %';
INSERT INTO "Unicode data" (i, t) VALUES ('bel+', 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._');
SELECT * FROM "Unicode data" WHERE i = 'bel+';
DELETE FROM "Unicode data" WHERE t = 'У рудога вераб’я ў сховішчы пад фатэлем ляжаць нейкія гаючыя зёлкі._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bel+';
INSERT INTO "Unicode data" (i, t) VALUES ('bul+', 'Ах, чудна българска земьо, полюшвай цъфтящи жита._');
SELECT * FROM "Unicode data" WHERE i = 'bul+';
DELETE FROM "Unicode data" WHERE t = 'Ах, чудна българска земьо, полюшвай цъфтящи жита._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'bul+';
INSERT INTO "Unicode data" (i, t) VALUES ('rus+', 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._');
SELECT * FROM "Unicode data" WHERE i = 'rus+';
DELETE FROM "Unicode data" WHERE t = 'Широкая электрификация южных губерний даст мощный толчок подъёму сельского хозяйства._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'rus+';
INSERT INTO "Unicode data" (i, t) VALUES ('ukr+', 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._');
SELECT * FROM "Unicode data" WHERE i = 'ukr+';
DELETE FROM "Unicode data" WHERE t = 'Гей, хлопці, не вспію — на ґанку ваша файна їжа знищується бурундучком._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ukr+';
-- 1256, ISO_8859_6
SELECT * FROM "Unicode data" WHERE i = 'ara';
SELECT * FROM "Unicode data" WHERE t LIKE '%ضَظَغ%';
INSERT INTO "Unicode data" (i, t) VALUES ('ara+', 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_');
SELECT * FROM "Unicode data" WHERE i = 'ara+';
DELETE FROM "Unicode data" WHERE t = 'أبجد هوَّز حُطّي كلَمُن سَعْفَص قُرِشَت ثَخَدٌ ضَظَغ_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'ara+';
-- 1253, ISO_8859_7
SELECT * FROM "Unicode data" WHERE i = 'gre';
SELECT * FROM "Unicode data" WHERE t LIKE 'Τάχισ%';
INSERT INTO "Unicode data" (i, t) VALUES ('gre+', 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_');
SELECT * FROM "Unicode data" WHERE i = 'gre+';
DELETE FROM "Unicode data" WHERE t = 'Τάχιστη αλώπηξ βαφής ψημένη γη, δρασκελίζει υπέρ νωθρού κυνός_';
-- 1255, ISO_8859_8
SELECT * FROM "Unicode data" WHERE i = 'heb';
SELECT * FROM "Unicode data" WHERE t LIKE '%כי ח%';
INSERT INTO "Unicode data" (i, t) VALUES ('heb+', 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_');
SELECT * FROM "Unicode data" WHERE i = 'heb+';
DELETE FROM "Unicode data" WHERE t = 'עטלף אבק נס דרך מזגן שהתפוצץ כי חם_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'heb+';
-- 1252, LATIN1
SELECT * FROM "Unicode data" WHERE i = 'eus';
SELECT * FROM "Unicode data" WHERE i = 'fra';
SELECT * FROM "Unicode data" WHERE i = 'spa';
SELECT * FROM "Unicode data" WHERE t LIKE 'Permi%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Dès N%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Quier%';
INSERT INTO "Unicode data" (i, t) VALUES ('eus+', 'Permin gox dabiltzu yoskiñ._');
SELECT * FROM "Unicode data" WHERE i = 'eus+';
DELETE FROM "Unicode data" WHERE t = 'Permin gox dabiltzu yoskiñ._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'eus+';
INSERT INTO "Unicode data" (i, t) VALUES ('fra+', 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_');
SELECT * FROM "Unicode data" WHERE i = 'fra+';
DELETE FROM "Unicode data" WHERE t = 'Dès Noël où un zéphyr haï me vêt de glaçons würmiens je dîne d’exquis rôtis de bœuf au kir à l’aÿ d’âge mûr & cætera !_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'fra+';
INSERT INTO "Unicode data" (i, t) VALUES ('spa+', 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._');
SELECT * FROM "Unicode data" WHERE i = 'spa+';
DELETE FROM "Unicode data" WHERE t = 'Quiere la boca exhausta vid, kiwi, piña y fugaz jamón._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'spa+';
-- 1250, LATIN2
SELECT * FROM "Unicode data" WHERE i = 'cze';
SELECT * FROM "Unicode data" WHERE i = 'pol';
SELECT * FROM "Unicode data" WHERE i = 'srp';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zvláš%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Pchną%';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ljuba%';
INSERT INTO "Unicode data" (i, t) VALUES ('cze+', 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._');
SELECT * FROM "Unicode data" WHERE i = 'cze+';
DELETE FROM "Unicode data" WHERE t = 'Zvlášť zákeřný učeň s ďolíčky běží podél zóny úlů._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'cze+';
INSERT INTO "Unicode data" (i, t) VALUES ('pol+', 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._');
SELECT * FROM "Unicode data" WHERE i = 'pol+';
DELETE FROM "Unicode data" WHERE t = 'Pchnąć w tę łódź jeża lub ośm skrzyń fig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'pol+';
INSERT INTO "Unicode data" (i, t) VALUES ('srp+', 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._');
SELECT * FROM "Unicode data" WHERE i = 'srp+';
DELETE FROM "Unicode data" WHERE t = 'Ljubavi, Olga, hajde pođi u Fudži i čut ćeš nježnu muziku srca._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'srp+';
-- 1257, LATIN7
SELECT * FROM "Unicode data" WHERE i = 'lav';
SELECT * FROM "Unicode data" WHERE t LIKE 'Ķieģeļu%';
INSERT INTO "Unicode data" (i, t) VALUES ('lav+', 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._');
SELECT * FROM "Unicode data" WHERE i = 'lav+';
DELETE FROM "Unicode data" WHERE t = 'Ķieģeļu cepējs Edgars Buls fraku un hūti žāvē uz čīkstošām eņģēm._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'lav+';
-- EUC_KR
SELECT * FROM "Unicode data" WHERE i = 'kor';
SELECT * FROM "Unicode data" WHERE t LIKE '키스의 고%';
INSERT INTO "Unicode data" (i, t) VALUES ('kor+', '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._');
SELECT * FROM "Unicode data" WHERE i = 'kor+';
DELETE FROM "Unicode data" WHERE t = '키스의 고유조건은 입술끼리 만나야 하고 특별한 기술은 필요치 않다._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'kor+';
-- 1254, LATIN5
SELECT * FROM "Unicode data" WHERE i = 'aze';
SELECT * FROM "Unicode data" WHERE t LIKE 'Zəfər%';
INSERT INTO "Unicode data" (i, t) VALUES ('aze+', 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._');
SELECT * FROM "Unicode data" WHERE i = 'aze+';
DELETE FROM "Unicode data" WHERE t = 'Zəfər, jaketini də, papağını da götür, bu axşam hava çox soyuq olacaq._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'aze+';
-- etc
INSERT INTO "Unicode data" (i, t) VALUES ('arm+', 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_');
SELECT * FROM "Unicode data" WHERE i = 'arm+';
DELETE FROM "Unicode data" WHERE t = 'Բել դղյակի ձախ ժամն օֆ ազգությանը ցպահանջ չճշտած վնաս էր եւ փառք։_';
SELECT count(*) n FROM "Unicode data" WHERE i = 'arm+';
INSERT INTO "Unicode data" (i, t) VALUES ('gle+', 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._');
SELECT * FROM "Unicode data" WHERE i = 'gle+';
DELETE FROM "Unicode data" WHERE t = 'Chuaigh bé mhórshách le dlúthspád fíorfhinn trí hata mo dhea-phorcáin bhig._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'gle+';
INSERT INTO "Unicode data" (i, t) VALUES ('epo+', 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._');
SELECT * FROM "Unicode data" WHERE i = 'epo+';
DELETE FROM "Unicode data" WHERE t = 'Laŭ Ludoviko Zamenhof bongustas freŝa ĉeĥa manĝaĵo kun spicoj._';
SELECT count(*) n FROM "Unicode data" WHERE i = 'epo+';

DROP FOREIGN TABLE "Unicode data";
DROP SERVER sqlite_svr;
DROP EXTENSION sqlite_fdw;
\connect contrib_regression;
DROP DATABASE "contrib_regression_SQL_ASCII";
