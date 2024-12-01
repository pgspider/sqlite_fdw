%global localdir /usr/local

Name:           sqlite
Version:        %{?sqlite_version}
Release:        %{?package_release_version}.%{?dist}
Summary:        Development sqlite files for SQLite
License:        TOSHIBA CORPORATION
URL:            https://www.sqlite.org/%{?sqlite_year}/sqlite-autoconf-%{?sqlite_download_version}.tar.gz
Source0:        sqlite-autoconf-%{?sqlite_download_version}.tar.gz

BuildRequires:  gcc
BuildRequires:  libtool

%description
This is SQLite for Rocky Linux 8

%prep
%autosetup -n sqlite-autoconf-%{?sqlite_download_version}

%build
./configure --prefix=/usr/local --enable-fts5

make %{?_smp_mflags}

%install
%{__rm} -rf %{buildroot}
PATH=/bin/:$PATH %{__make} %{?_smp_mflags} install DESTDIR=%{buildroot}
libtool --finish %{localdir}/lib64

%clean
%{__rm} -rf %{buildroot}

%post -p /sbin/ldconfig

%postun -p /sbin/ldconfig

%files
%defattr(755,root,root,755)
%doc README.txt

%{localdir}/bin/sqlite3
%{localdir}/include/sqlite3ext.h
%{localdir}/include/sqlite3.h

%{localdir}/lib/libsqlite3.so
%{localdir}/lib/pkgconfig/sqlite3.pc

%{localdir}/lib/libsqlite3.a
%{localdir}/lib/libsqlite3.la
%{localdir}/lib/libsqlite3.so.0
%{localdir}/lib/libsqlite3.so.0.8.6
%{localdir}/share/man/man1/sqlite3.1

%changelog
* Fri Feb 2 2024 - 3.42.0
- Initial spec