#!/bin/bash
#ファイルの概要
#postgresをビルドするファイルです。

#使い方
#引数として、postgresqlのバージョン番号を指定してください 例えば、 16.0 など

#前提条件
#postgresqlのソースコードが配布URLからダウンロードできる必要があります。

VERSION=$1
mkdir ~/workdir
cd ~/workdir
curl -O https://ftp.postgresql.org/pub/source/v${VERSION}/postgresql-${VERSION}.tar.bz2
tar xjf postgresql-${VERSION}.tar.bz2
cd postgresql-${VERSION}
./configure --prefix ~/workdir/db
make
