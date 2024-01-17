#!/bin/bash
#ファイルの概要
#test.shを実行しリグレッションテストを行うファイルです。
#全て合格していたら正常終了し、全て合格でなければ異常終了します。

#使い方
#引数として、postgresqlのバージョン番号を指定してください。ex. 16.0 など

#前提条件
#前段階として、postgresqlのビルドと、sqliteのインストール、sqlite_fdwのビルドが必要です
#sqlite_fdwが提供するtest.shスクリプト内の処理が以下である必要があります。
#テストが全部成功したとき、"ALL 20 tests passed"という文字列をmake_check.outというファイルの末尾の行か、末尾から数えて3行目に出力する

VERSION=$1
cd ~/workdir/postgresql-${VERSION}/contrib/sqlite_fdw
./test.sh

last_line=$(tail -n 1 make_check.out)
third_line_from_the_last=$(tail -n 3 make_check.out | head -n 1)
string_test_passed="All 20 tests passed"

if [[ "$last_line" == *$string_test_passed* ]]; then
        echo "The last line of make_check.out contains '$string_test_passed'"

elif [[ "$third_line_from_the_last" == *$string_test_passed* ]]; then
        echo "The third line from the last of make_check.out contains '$string_test_passed'"
else
        echo "Error : not All the tests passed"
        echo "last line : '$last_line'"
        echo "thierd_line_from_the_last : '$third_line_from_the_last'"
        exit 1
fi
