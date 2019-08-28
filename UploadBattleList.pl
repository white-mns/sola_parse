#===================================================================
#    データベースへのアップロード
#-------------------------------------------------------------------
#        (C) 2019 @white_mns
#===================================================================

# モジュール呼び出し    ---------------#
require "./source/Upload.pm";
require "./source/lib/time.pm";

# パッケージの使用宣言    ---------------#
use strict;
use warnings;
require LWP::UserAgent;
use HTTP::Request;
use HTTP::Response;

# 変数の初期化    ---------------#
use ConstData_Upload;        #定数呼び出し

my $timeChecker = TimeChecker->new();

# 実行部    ---------------------------#
$timeChecker->CheckTime("start  \t");

&Main;

$timeChecker->CheckTime("end    \t");
$timeChecker->OutputTime();
$timeChecker = undef;

# 宣言部    ---------------------------#

sub Main {
    my $input_date = $ARGV[0];

    my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime;
    my $date = ($year+1900) . "-" . sprintf("%02d", $mon + 1) . "-" . sprintf("%02d",$mday);

    if ($input_date) {
        $date = substr($input_date, 0, 4)."-".substr($input_date, 4, 2)."-".substr($input_date, 6, 2);
    }

    my $upload = Upload->new();

    $upload->DBConnect();
    
    $upload->DeleteSameDate("uploaded_checks", $date);

    if (ConstData::EXE_DATA) {
        &UploadData($upload, ConstData::EXE_DATA_PROPER_NAME, "proper_names", "./output/data/proper_name.csv");
    }
    if (ConstData::EXE_BATTLE_LIST) {
        &UploadResult($upload, ConstData::EXE_BATTLE_LIST_AP,    "aps",       "./output/battle_list/ap.csv",    "ap_no");
        &UploadResult($upload, ConstData::EXE_BATTLE_LIST_PARTY, "parties",   "./output/battle_list/party.csv", "ap_no");
    }
        &UploadEnd($upload, $date, 1,                           "uploaded_checks", "./output/etc/uploaded_check_");
    print "date:$date\n";
    return;
}

#-----------------------------------#
#       結果番号に依らないデータをアップロード
#-----------------------------------#
#    引数｜アップロードオブジェクト
#    　　　アップロード定義
#          テーブル名
#          ファイル名
##-----------------------------------#
sub UploadData {
    my ($upload, $is_upload, $table_name, $file_name) = @_;

    if ($is_upload) {
        $upload->DeleteAll($table_name);
        $upload->Upload($file_name, $table_name);
    }
}

#-----------------------------------#
#       更新結果データをアップロード
#-----------------------------------#
#    引数｜アップロードオブジェクト
#    　　　更新番号
#    　　　再更新番号
#    　　　アップロード定義
#          テーブル名
#          ファイル名
#          範囲指定カラム
##-----------------------------------#
sub UploadResult {
    my ($upload, $is_upload, $table_name, $file_name, $where_column) = @_;

    my ($start_no, $end_no) = &GetColumnRange($file_name, 0);

    if($is_upload) {
        $upload->DeleteRangeWhere($table_name, $where_column, $start_no, $end_no);
        $upload->Upload($file_name, $table_name);
    }
}

#-----------------------------------#
#       更新状況をアップロード
#-----------------------------------#
#    引数｜アップロードオブジェクト
#    　　　更新番号
#    　　　再更新番号
#    　　　アップロード定義
#          テーブル名
#          ファイル名
##-----------------------------------#
sub UploadEnd {
    my ($upload, $date, $is_upload, $table_name, $file_name) = @_;

    if($is_upload) {
        $upload->Upload($file_name . $date . ".csv", $table_name);
    }
}
#-----------------------------------#
#       中間ファイルの指定の項目の最小値・最大値を取得する
#-----------------------------------#
#    引数｜ファイル名
#          カラム番号
##-----------------------------------#
sub GetColumnRange {
    my ($file_name, $column_num) = @_;

    my ($start_no, $end_no) = (99999999,0);

    my $content = &IO::FileRead ($file_name);

    my @file_data = split(/\n/, $content);
    
    shift(@file_data);

    foreach my $lineData(@file_data){
       #行ごとのデータを展開
       my @one_file_data = split(ConstData::SPLIT, $lineData);
       my $comparison_data = $one_file_data[$column_num];

       if($start_no > $comparison_data) {$start_no = $comparison_data;}
       if($end_no   < $comparison_data) {$end_no   = $comparison_data;}
    }

    return ($start_no, $end_no);
}
