#!/bin/bash

# ファイルの概要  
#sqliteのインストールまでを行うファイルです。  

# 使い方
#sqliteのインストールに必要な、バージョン、年を引数で指定する必要があります。
#例 $ ./install_sqlite.sh 3420000 2023

# 前提条件  
#sqliteの配布URLが利用可能であることが必要です。
#作業ディレクトリの　workdir　が存在する必要があります
#これはディレクトリの存在を確認して、その後無ければ作成するように変更したいです。

VERSION=$1
YEAR=$2
cd ~/workdir
wget https://www.sqlite.org/${YEAR}/sqlite-src-${VERSION}.zip
unzip sqlite-src-${VERSION}.zip
cd sqlite-src-${VERSION}
./configure --enable-fts5
make
sudo make install
