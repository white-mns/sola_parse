#===================================================================
#        戦闘結果データ抽出スクリプト本体
#-------------------------------------------------------------------
#            (C) 2019 @white_mns
#===================================================================

# モジュール呼び出し    ---------------#
require "./source/lib/IO.pm";
require "./source/lib/time.pm";
require "./source/ProperName.pm";
require "./source/Battle.pm";

# パッケージの使用宣言    ---------------#
use strict;
use warnings;
use HTML::TreeBuilder;
use FindBin qw($Bin);
use lib "$Bin";
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
    my $start_no   = $ARGV[0];
    my $end_no = $ARGV[1];

    my @objects;        #探索するデータ項目の登録
    my %common_datas;
    
    push(@objects, ProperName->new()); # 固有名詞読み込み・保持
    if (ConstData::EXE_BATTLE) {push(@objects, Battle->new());}        # 戦闘ページ読み込み

    &Init(\@objects, $start_no, $end_no, \%common_datas);
    &Execute(\@objects);
    &Output(\@objects);
}

#-----------------------------------#
#    解析実行
#------------------------------------
#    引数｜更新番号、再更新番号
#-----------------------------------#
sub Init{
    my ($objects, $start_no, $end_no, $common_datas)    = @_;
    
    foreach my $object( @$objects) {
        $object->Init($start_no, $end_no, $common_datas);
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
