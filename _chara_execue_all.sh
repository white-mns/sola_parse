#!/bin/bash

CURENT=`pwd`	#実行ディレクトリの保存
cd `dirname $0`	#解析コードのあるディレクトリで作業をする
START_DATE=$1
END_DATE=$2

for (( DATE=${START_DATE} ; ${DATE} <= ${END_DATE} ; DATE=`date -d "${DATE} 1 day" '+%Y%m%d'` )) ; do
      ./chara_execute.sh $DATE
done

cd $CURENT  #元のディレクトリに戻る
