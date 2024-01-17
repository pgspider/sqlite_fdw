#!/bin/bash

# ファイルの概要  
#sqlite_fdwをビルドするファイルです。

# 使い方
#引数として、テストを行いたいpostgresqlのバージョン番号を指定してください ex. 16.0

# 前提条件
#githubのURLが利用可能であることが必要です。

VERSION=$1
cd ~/workdir/postgresql-${VERSION}/contrib
git clone https://github.com/pgspider/sqlite_fdw.git
cd sqlite_fdw
export LD_LIBRARY_PATH=/usr/local/lib/:$LD_LIBRARY_PATH
make
