#!/bin/bash

# ファイルの概要  
#ubuntuの言語ファイル、ロケールファイルをインストールするファイルです。  

# 使い方
#テストをする際に必要になるロケールファイルを自動的に指定しています。  
#特に引数などの指定をする必要なく、ただ実行するだけで処理が完了します。  

# 前提条件  
#GitHubActionsで用いる仮想マシンがUbuntuであること  

sudo apt-get update
sudo apt-get install locales language-pack-ja
sudo locale-gen ja_JP.EUC-JP
sudo apt-get install language-pack-ko-base language-pack-ko
sudo locale-gen ko_KR.EUC-KR
sudo apt-get install language-pack-bg-base language-pack-bg
sudo locale-gen bg_BG
