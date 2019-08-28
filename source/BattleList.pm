#===================================================================
#        戦闘ログ解析パッケージ
#        　別プログラムで取得しJSON形式に保存した戦闘ログ一覧の情報を解析する
#-------------------------------------------------------------------
#            (C) 2019 @white_mns
#===================================================================


# パッケージの使用宣言    ---------------#
use strict;
use warnings;

use HTML::TreeBuilder;
use source::lib::GetNode;

require "./source/lib/IO.pm";
require "./source/lib/time.pm";

require "./source/data/LatestApNo.pm";
require "./source/battle_list/Ap.pm";
require "./source/battle_list/Party.pm";

use ConstData;        #定数呼び出し

#------------------------------------------------------------------#
#    パッケージの定義
#------------------------------------------------------------------#
package BattleList;

#-----------------------------------#
#    コンストラクタ
#-----------------------------------#
sub new {
  my $class = shift;

  bless {
    Datas         => {},
    DataHandlers  => {},
    Methods       => {},
  }, $class;
}

#-----------------------------------#
#    初期化
#-----------------------------------#
sub Init() {
    my $self = shift;
    ($self->{StartNo}, $self->{EndNo}, $self->{CommonDatas}) = @_;

    #インスタンス作成
    if (ConstData::EXE_BATTLE_LIST_AP)      { $self->{DataHandlers}{Ap}    = Ap->new();}
    if (ConstData::EXE_BATTLE_LIST_PARTY)   { $self->{DataHandlers}{Party} = Party->new();}

    #初期化処理
    foreach my $object( values %{ $self->{DataHandlers} } ) {
        $object->Init($self->{CommonDatas});
    }

    $self->{DataHandlers}{LatestApNo} = LatestApNo->new();
    $self->{DataHandlers}{LatestApNo}->Init($self->{CommonDatas}, "./output/battle_list/latest_ap_no.csv");
    
    return;
}

#-----------------------------------#
#    圧縮結果から戦闘結果ファイルを抽出
#-----------------------------------#
#    
#-----------------------------------#
sub Execute{
    my $self        = shift;

    print "read battle list JSONs...\n";

    my $start = 1;
    my $end   = 0;
    my $directory = './casper/output/';

    $self->{JSON} = $self->ParseJSON($directory."battle_list.json");

    if (defined($self->{StartNo}) && $self->{StartNo} =~ /^[0-9]+$/) {
        #指定範囲解析
        $start = $self->{StartNo}

    } else {
        $start = $self->{DataHandlers}{LatestApNo}->GetLatestApNo($end);
    }

    if (defined($self->{EndNo}) && $self->{EndNo} =~ /^[0-9]+$/) {
        #指定範囲解析
        $end = $self->{EndNo}

    } else {
        $end   = $self->{JSON}->{"maxNo"};
        $self->{DataHandlers}{LatestApNo}->SetLatestApNo($end);
    }

    print "$start to $end\n";

    for (my $ap_no=$start; $ap_no<=$end; $ap_no++) {
        if ($ap_no % 10 == 0) {print $ap_no . "\n"};

        $self->ParseAp($ap_no);
    }
    
    return ;
}

#-----------------------------------#
#       JSONファイルを解析
#-----------------------------------#
#    引数｜ファイル名
#    　　　ENo
##-----------------------------------#
sub ParseJSON{
    my $self       = shift;
    my $file_name  = shift;

    #結果の読み込み
    my $json = "";
    $json = &IO::JSONRead($file_name);

    if (!$json) { return;}

    my $list = $json->{"list"};
    return $json;
}

#-----------------------------------#
#       JSON保存データを解析
#-----------------------------------#
#    引数｜ファイル名
#    　　　ENo
##-----------------------------------#
sub ParseAp{
    my $self       = shift;
    my $ap_no  = shift;

    #結果の読み込み
    my $content = "";
    $content = $self->{JSON}->{"list"}{$ap_no};

    if (!$content) { return;}

    Encode::_utf8_off($content);

    #スクレイピング準備
    my $tree = HTML::TreeBuilder->new;
    $tree->parse($content);

    my $th_nodes = &GetNode::GetNode_Tag("th", \$tree);

    # データリスト取得
    if (exists($self->{DataHandlers}{Ap}))    {$self->{DataHandlers}{Ap}->GetData   ($ap_no, $th_nodes)};
    if (exists($self->{DataHandlers}{Party})) {$self->{DataHandlers}{Party}->GetData($ap_no, $th_nodes)};

    $tree = $tree->delete;
}

#-----------------------------------#
#    出力
#-----------------------------------#
#    引数｜ファイルアドレス
#-----------------------------------#
sub Output(){
    my $self = shift;
    foreach my $object( values %{ $self->{Datas} } ) {
        $object->Output();
    }
    foreach my $object( values %{ $self->{DataHandlers} } ) {
        $object->Output();
    }
    return;
}

1;
