#===================================================================
#        装備アーティファクト取得パッケージ
#-------------------------------------------------------------------
#            (C) 2019 @white_mns
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
package Equip;

#-----------------------------------#
#    コンストラクタ
#-----------------------------------#
sub new {
  my $equip = shift;
  
  bless {
        Datas => {},
  }, $equip;
}

#-----------------------------------#
#    初期化
#-----------------------------------#
sub Init{
    my $self = shift;
    ($self->{Date}, $self->{DateTime}, $self->{CommonDatas}) = @_;
    
    #初期化
    $self->{Datas}{Data}  = StoreData->new();
    my $header_list = "";
   
    $header_list = [
                "e_no",
                "battle_type",
                "artifact_id",
                "equip_num",
                "created_at",
    ];

    $self->{Datas}{Data}->Init($header_list);
    
    #出力ファイル設定
    $self->{Datas}{Data}->SetOutputName( "./output/chara/equip_" . $self->{Date} . ".csv" );
    return;
}

#-----------------------------------#
#    データ取得
#------------------------------------
#    引数｜e_no,テーブル一覧ノード
#-----------------------------------#
sub GetData{
    my $self    = shift;
    my $e_no    = shift;
    my $table_nodes = shift;
    
    $self->{ENo} = $e_no;

    my $equip_pve_node   = $self->GetEquipNode($table_nodes, "装備1");
    my $equip_pvp_node   = $self->GetEquipNode($table_nodes, "PvP装備1");
    my $equip_tale_node   = $self->GetEquipNode($table_nodes, "物語戦1");
    my $equip_challenge_node   = $self->GetEquipNode($table_nodes, "チャレ1");
    $self->GetEquipData($equip_pve_node);
    $self->GetEquipData($equip_pvp_node);
    $self->GetEquipData($equip_tale_node);
    $self->GetEquipData($equip_challenge_node);
    
    return;
}

#-----------------------------------#
#    装備アーティファクトデータテーブル取得
#------------------------------------
#    引数｜テーブルノードリスト
#-----------------------------------#
sub GetEquipNode{
    my $self  = shift;
    my $table_nodes = shift;
    my $first_text = shift;
    
    foreach my $table_node (@$table_nodes) {
        my $th_nodes = &GetNode::GetNode_Tag("th", \$table_node);
        my $th0_text =  $$th_nodes[0]->as_text;

        if ($th0_text eq $first_text) { return $table_node; }
    }
    return;
}

#-----------------------------------#
#    装備アーティファクトデータ取得
#------------------------------------
#    引数｜装備テーブルノード
#-----------------------------------#
sub GetEquipData{
    my $self  = shift;
    my $equip_node = shift;

    my $equip_th_nodes = &GetNode::GetNode_Tag("th", \$equip_node);

    foreach my $node (@$equip_th_nodes) {
        my ($equip_id, $equip_num, $battle_type) = (0, 0, -1);
        my $item =  $node->as_text;

        if ($item =~ /^装備(\d)/) {
            $battle_type = 0;
            $equip_num = $1;

        } elsif ($item =~ /^PvP装備(\d)/) {
            $battle_type = 1;
            $equip_num = $1;

        } elsif ($item =~ /物語戦(\d)/) {
            $battle_type = 2;
            $equip_num = $1;

        } elsif ($item =~ /チャレ(\d)/) {
            $battle_type = 3;
            $equip_num = $1;

        }

        if ($equip_num > 0) {
            $equip_id = $self->{CommonDatas}{ProperName}->GetOrAddId($node->right->as_text);
            $self->{Datas}{Data}->AddData(join(ConstData::SPLIT, ($self->{ENo}, $battle_type, $equip_id, $equip_num, $self->{Date}) ));
        }
    }

    return;
}

#-----------------------------------#
#    出力
#------------------------------------
#    引数｜
#-----------------------------------#
sub Output{
    my $self = shift;
    
    foreach my $object( values %{ $self->{Datas} } ) {
        $object->Output();
    }
    return;
}
1;
