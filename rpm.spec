%global sname	sqlite_fdw

Summary:	SQLite Foreign Data Wrapper for PostgreSQL
Name:		%{sname}_%{pgmajorversion}
Version:	2.5.0
Release:	1%{?dist}
License:	PostgreSQL https://github.com/pgspider/sqlite_fdw/blob/master/License
URL:		https://github.com/pgspider/%{sname}
Source0:	${HOME}/rpmbuild/SOURCES 
# https://github.com/pgspider/%{sname}/archive/v%{version}.tar.gz
BuildRequires:	sqlite-devel postgresql%{pgmajorversion}-devel libpq-devel make postgresql%{pgmajorversion}-server 
Requires:	postgresql%{pgmajorversion}-server
%if 0%{?fedora} >= 27
Requires:	sqlite-libs
%endif
%if 0%{?rhel} <= 7
Requires:	sqlite
%endif

Obsoletes:	%{sname}%{pgmajorversion} < 1.3.0-2

%description
SQLite Foreign Data Wrapper for PostgreSQL

%prep
%setup -q -n %{sname}-%{version}

%build
USE_PGXS=1 PATH=%{pginstdir}/bin/:$PATH %{__make} %{?_smp_mflags}

%install
%{__rm} -rf %{buildroot}
USE_PGXS=1 PATH=%{pginstdir}/bin/:$PATH %{__make} %{?_smp_mflags} install DESTDIR=%{buildroot}
# Install README and howto file under PostgreSQL installation directory:
%{__install} -d %{buildroot}%{pginstdir}/doc/extension
%{__install} -m 644 README.md %{buildroot}%{pginstdir}/doc/extension/README-%{sname}.md
%{__rm} -f %{buildroot}%{pginstdir}/doc/extension/README.md

%clean
%{__rm} -rf %{buildroot}

%files
%defattr(-,root,root,-)
%{pginstdir}/lib/*.so
%{pginstdir}/share/extension/*.sql
%{pginstdir}/share/extension/*.control
%{pginstdir}/doc/extension/README-%{sname}.md

%license License
%doc README.md

%if %llvm
%files llvmjit
   %{pginstdir}/lib/bitcode/%{sname}*.bc
   %{pginstdir}/lib/bitcode/%{sname}/*.bc
%endif

%changelog

* 10 Dec 2024 t-kataym - 2.5.0
  * Support PostgreSQL 17.0
  * Add CI environment using GitHub Actions
  * Add force_readonly option (#78), readonly mode for SQLite database
  * Support uuid (#82,#95)
  * Support bit and varbit (#83)
  * Support bool as mixed affinity column (#88)
  * NaN detecting (#100)
  * Support ∞ values for numeric context (#97)
  * Support mixed (selected) affinity for UPDATE (#95)
  
 * 27Sep 2023 t-kataym - 2.4.0
  * Support PosgreSQL 16.0
  * Add text transformations for pg DB encoding, encodings support
  * Add updatable option on different levels
  * Improve error message
  * Fix bugs

* 17 Jan 2023 t-kataym - 2.3.0
- Support PostgreSQL 15.0
- Bug fix of error handling in case of sqlite busy

* 26 Sep 2022 t-kataym - 2.2.0
- Support PostgreSQL 15beta4
- Support push down CASE expressions

* 22 Dec 2021 t-kataym - 2.1.1
- Support Insert/Update with generated column
- Support check invalid options
- Bug fixings:
        - Fix issue #44 on GitHub (FTS Virtual Table crash)
        - Fix memory leak

* 24 Sep 2021 hrkuma - 2.1.0
- Support version 14 related features
-  Support TRUNCATE
-  Support Bulk Insert
-  Support keep connection control and connection cache information
- Refactored tests

* 26 May 2021 hrkuma - 2.0.0
- Support JOIN pushdown (LEFT,RIGHT,INNER)
- Support direct modification (UPDATE/DELETE)
- Support pushdown nest functions
- Support pushdown scalar operator ANY/ALL (ARRAY)
- Support pushdown ON CONFLICT DO NOTHING
- Refactored tests
- Bug fixings
-  Don't push down lower/upper function
-  Fix processing for DATE data type
-  Do not prepare SQL statement during EXPLAIN

* Thu Jan 14 2021 hrkuma - 1.3.1
- Support function pushdown in the target list (for PGSpider)
- Support Windows build using Visual Studio project
- Fix FETCH ... WITH TIES issue
- Fix sqlite_fdw does not bind the correct numeric value when it is sub-query
