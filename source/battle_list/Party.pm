#===================================================================
#        パーティ情報取得パッケージ
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
package Party;

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
    $self->{Datas}{Data}  = StoreData->new();
    my $header_list = "";
   
    $header_list = [
                "ap_no",
                "e_no",
                "party_side",
                "party_order",
    ];

    $self->{Datas}{Data}->Init($header_list);
    
    #出力ファイル設定
    $self->{Datas}{Data}->SetOutputName( "./output/battle_list/party.csv" );
    return;
}

#-----------------------------------#
#    データ取得
#------------------------------------
#    引数｜結果番号,ターン別参加者一覧ノード
#-----------------------------------#
sub GetData{
    my $self = shift;
    my $ap_no = shift;
    my $th_nodes = shift;
    
    $self->{ApNo} = $ap_no;

    $self->GetPartyData($$th_nodes[2], 0);
    $self->GetPartyData($$th_nodes[3], 1);
    
    return;
}

#-----------------------------------#
#    メンバーデータ取得
#------------------------------------
#    引数｜ターン別参加者一覧ノード
#-----------------------------------#
sub GetPartyData{
    my $self  = shift;
    my $th_node = shift;
    my $party_side = shift;

    if (!$th_node) {return;}

    my $party_order = 0;
    my $a_nodes = &GetNode::GetNode_Tag("a", \$th_node);

    foreach my $a_node (@$a_nodes) {
        if ($a_node->attr("href") =~ /id=(\d+)/) {
            my $e_no = $1;

            $self->{Datas}{Data}->AddData(join(ConstData::SPLIT, ($self->{ApNo}, $e_no, $party_side, $party_order) ));

            $party_order += 1;
        }

    }

    return;
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
