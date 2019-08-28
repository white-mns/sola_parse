#===================================================================
#        AP行動取得パッケージ
#-------------------------------------------------------------------
#            (C) 2018 @white_mns
#===================================================================


# パッケージの使用宣言    ---------------#   
use strict;
use warnings;
require "./source/lib/Store_Data.pm";
require "./source/lib/Store_HashData.pm";
use ConstData;        #定数呼び出し
use source::lib::GetNode;


#------------------------------------------------------------------#
#    パッケージの定義
#------------------------------------------------------------------#     
package Ap;

#-----------------------------------#
#    コンストラクタ
#-----------------------------------#
sub new {
  my $class = shift;
  
  bless {
        Datas => {},
  }, $class;
}

#-----------------------------------#
#    初期化
#-----------------------------------#
sub Init(){
    my $self = shift;
    ($self->{CommonDatas}) = @_;

    #初期化
    $self->{Datas}{Ap}  = StoreData->new();
    my $header_list = "";
   
    $header_list = [
                "ap_no",
                "battle_type_id",
                "party_num",
                "quest_id",
                "difficulty_id",
                "battle_result",
                "created_at",
    ];

    $self->{Datas}{Ap}->Init($header_list);
    
    #出力ファイル設定
    $self->{Datas}{Ap}->SetOutputName( "./output/battle_list/ap.csv" );
    return;
}

#-----------------------------------#
#    データ取得
#------------------------------------
#    引数｜結果番号
#          ターン別参加者一覧ノード
#          タイトルデータノード
#-----------------------------------#
sub GetData{
    my $self = shift;
    my $ap_no  = shift;
    my $th_nodes = shift;
    
    $self->{ApNo} = $ap_no;

    $self->GetApData($th_nodes);

    return;
}

#-----------------------------------#
#    サブタイトル、進行度取得
#------------------------------------
#    引数｜サブタイトルノード
#-----------------------------------#
sub GetApData{
    my $self  = shift;
    my $th_nodes  = shift;


    if (!scalar(@$th_nodes)) { return; }

    if ($$th_nodes[0]->as_text ne "LINK") { return; }

    my ($battle_type_id, $party_num, $quest_id, $difficulty_id, $battle_result, $created_at) = (0, 0, 0, 0, -99, 0);

    my $battle_type_text = $$th_nodes[1]->as_text;

    $battle_type_id = $self->{CommonDatas}{ProperName}->GetOrAddId($battle_type_text);


    $party_num = $self->GetPartyNum($$th_nodes[2]);
    my $right_party_num = $self->GetPartyNum($$th_nodes[3]);
    
    if ($right_party_num == 0) {
        my $quest_all_text = $$th_nodes[3]->as_text;
        if ($quest_all_text =~ /(.+) \((.+)\)/) {
            my $quest_text = $1;
            my $difficulty_text = $2;

            $quest_id = $self->{CommonDatas}{ProperName}->GetOrAddId($quest_text);
            $difficulty_id = $self->{CommonDatas}{ProperName}->GetOrAddId($difficulty_text);
        }
    }
    $created_at = $$th_nodes[4]->as_text;

    my $battle_result_text = $$th_nodes[5]->as_text;

    if    ($battle_result_text eq "勝利") { $battle_result = 1}
    elsif ($battle_result_text eq "左側") { $battle_result = 2}
    elsif ($battle_result_text eq "引分") { $battle_result = 0}
    elsif ($battle_result_text eq "敗北") { $battle_result = -1}
    elsif ($battle_result_text eq "右側") { $battle_result = -2}

    $self->{Datas}{Ap}->AddData(join(ConstData::SPLIT, ($self->{ApNo}, $battle_type_id, $party_num, $quest_id, $difficulty_id, $battle_result, $created_at)));

    return;
}

#-----------------------------------#
#    味方人数取得
#------------------------------------
#    引数｜メンバーノード
#-----------------------------------#
sub GetPartyNum{
    my $self  = shift;
    my $th_node = shift;

    if (!$th_node) {return 0;}

    my $party_num = 0;

    my $a_nodes = &GetNode::GetNode_Tag("a", \$th_node);

    return scalar(@$a_nodes);
}

#-----------------------------------#
#    出力
#------------------------------------
#    引数｜ファイルアドレス
#-----------------------------------#
sub Output(){
    my $self = shift;
    
    foreach my $object( values %{ $self->{Datas} } ) {
        $object->Output();
    }
    return;
}
1;
