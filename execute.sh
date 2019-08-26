#!/bin/bash

CURENT=`pwd`	#実行ディレクトリの保存
cd `dirname $0`	#解析コードのあるディレクトリで作業をする
START_CURRENT=`pwd`

#------------------------------------------------------------------
# 更新回数、再更新番号の定義確認、設定

./chara_execute.sh

cd $START_CURRENT  #実行ディレクトリに戻る

./result_execute.sh

cd $START_CURRENT  #実行ディレクトリに戻る

cd $CURENT  #元のディレクトリに戻る
