Name:           sqlite_fdw
Version:        1.3.1
Release:        1%{?dist}
Summary:        SQLite Foreign Data Wrapper for PostgreSQL

# Group:
License:        https://github.com/pgspider/sqlite_fdw/blob/master/License
URL:            https://github.com/pgspider/sqlite_fdw
Source0:        https://github.com/pgspider/sqlite_fdw/archive/v%{version}.tar.gz

BuildRequires:  sqlite-devel libpq-devel make postgresql-server-devel
Requires:       postgresql

%description
SQLite Foreign Data Wrapper for PostgreSQL

%prep
%setup -q


%build
make %{?_smp_mflags} USE_PGXS=1


%install
%make_install USE_PGXS=1


%files
%doc README.md
%license License
## /usr/lib/debug/usr/lib64/pgsql/sqlite_fdw.so-%{version}-1%{?dist}.x86_64.debug
%{_libdir}/pgsql/sqlite_fdw.so
%{_datadir}/pgsql/extension/sqlite_fdw--1.0.sql
%{_datadir}/pgsql/extension/sqlite_fdw.control





%changelog
* Thu Jan 14 2021 hrkuma - 1.3.1
- Support function pushdown in the target list (for PGSpider)
- Support Windows build using Visual Studio project
- Fix FETCH ... WITH TIES issue
- Fix sqlite_fdw does not bind the correct numeric value when it is sub-query
