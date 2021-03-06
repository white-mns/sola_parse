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
use FindBin qw($Bin);
use lib "$Bin";
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

    print "delete_uploaded:$date\n";
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
##-----------------------------------#
sub UploadResult {
    my ($upload, $date, $is_upload, $table_name, $file_name) = @_;

    if($is_upload) {
        $upload->DeleteSameDate($table_name, $date);
        $upload->Upload($file_name . $date . ".csv", $table_name);
    }
}
