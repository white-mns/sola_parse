#!/bin/bash

CURENT=`pwd`	#実行ディレクトリの保存
cd `dirname $0`	#解析コードのあるディレクトリで作業をする

#------------------------------------------------------------------
# 更新回数、再更新番号の定義確認、設定

START_NO=$1
END_NO=$2

# ファイル解析・アップロード

perl ./GetBattleListData.pl      $START_NO $END_NO
perl ./UploadBattleList.pl

cd $CURENT  #元のディレクトリに戻る
