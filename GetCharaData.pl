#===================================================================
#        キャラクターデータ抽出スクリプト本体
#-------------------------------------------------------------------
#            (C) 2019 @white_mns
#===================================================================

# モジュール呼び出し    ---------------#
require "./source/lib/IO.pm";
require "./source/lib/time.pm";
require "./source/ProperName.pm";
require "./source/Character.pm";
require "./source/UploadedCheck.pm";

# パッケージの使用宣言    ---------------#
use strict;
use warnings;
use HTML::TreeBuilder;
use ConstData;        #定数呼び出し

# 変数の初期化    ---------------#

my $timeChecker = TimeChecker->new();


# 実行部    ---------------------------#

$timeChecker->CheckTime("Start  ");

&Main;

$timeChecker->CheckTime("End    ");
$timeChecker->OutputTime();
$timeChecker = undef;

# 宣言部    ---------------------------#

sub Main{
    my $input_date = $ARGV[0];
    my $date = substr($input_date, 0, 4)."-".substr($input_date, 4, 2)."-".substr($input_date, 6, 2);

    my @objects;        #探索するデータ項目の登録
    my %common_datas;
    
    push(@objects, ProperName->new()); # 固有名詞読み込み・保持
                               {push(@objects, UploadedCheck->new());} #データ更新状況チェック用データ作成
    if (ConstData::EXE_CHARA)  {push(@objects, Character->new());}     #キャラページ読み込み

    &Init(\@objects, $date, \%common_datas);
    &Execute(\@objects);
    &Output(\@objects);
}

#-----------------------------------#
#    解析実行
#------------------------------------
#    引数｜更新番号、再更新番号
#-----------------------------------#
sub Init{
    my ($objects, $date, $common_datas)    = @_;
    
    foreach my $object( @$objects) {
        $object->Init($date, "", $common_datas);
    }
    return;
}

#-----------------------------------#
#    解析実行
#------------------------------------
#    引数｜
#-----------------------------------#
sub Execute{
    my $objects    = shift;
    
    foreach my $object( @$objects) {
        $object->Execute();
    }
    return;
}
#-----------------------------------#
#    出力
#------------------------------------
#    引数｜
#-----------------------------------#
sub Output{
    my $objects    = shift;
    foreach my $object( @$objects) {
        $object->Output();
    }
    return;
}
