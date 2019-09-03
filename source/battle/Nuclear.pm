#===================================================================
#        核爆発取得パッケージ
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
package Nuclear;

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
    $self->{Datas}{Nuclear}  = StoreData->new();
    my $header_list = "";
   
    $header_list = [
                "ap_no",
                "e_no",
                "skill_id",
                "user_name",
                "turn",
                "max_damage",
                "total_damage",
    ];

    $self->{Datas}{Nuclear}->Init($header_list);
    
    #出力ファイル設定
    $self->{Datas}{Nuclear}->SetOutputName( "./output/battle/nuclear.csv" );
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
    my $div_status_box_nodes = shift;
    
    $self->{ApNo} = $ap_no;

    $self->ParseTurnNode($div_status_box_nodes);

    return;
}

#-----------------------------------#
#    核爆発取得
#------------------------------------
#    引数｜サブタイトルノード
#-----------------------------------#
sub ParseTurnNode{
    my $self  = shift;
    my $div_status_box_nodes = shift;


    if (!scalar(@$div_status_box_nodes)) { return; }

    foreach my $turn_node (@$div_status_box_nodes) {
        my @children = $turn_node->content_list;
        if (scalar(@children) && $children[0] =~ /HASH/ && $children[0]->tag eq "p" &&$children[0]->as_text =~ /▼ターン(\d+)/) {
            my $turn = $1;
            $self->GetTurnData($turn_node, $turn)
        }
    }
}

#-----------------------------------#
#    核爆発取得
#------------------------------------
#    引数｜サブタイトルノード
#-----------------------------------#
sub GetTurnData{
    my $self  = shift;
    my $turn_node  = shift;
    my $turn = shift;

    my @right_nodes = $turn_node->right->right;
    my $right_index = 0;

    foreach my $action_node (@right_nodes) {
        if ($action_node =~ /HASH/ && $action_node->attr("class") && $action_node->attr("class") eq "status_box") {
            last;
        }

        if ($action_node =~ /HASH/ && $action_node->tag("b")) {
            $self->GetNuclearData(\@right_nodes, $right_index,$turn);
        }

        $right_index += 1;

    }
}


#-----------------------------------#
#    核爆発取得
#------------------------------------
#    引数｜サブタイトルノード
#-----------------------------------#
sub GetNuclearData{
    my $self  = shift;
    my $nodes  = shift;
    my $skill_name_index = shift;
    my $turn = shift;

    my $left = $$nodes[$skill_name_index - 1];
    my $right = $$nodes[$skill_name_index + 1];

    if ($left ne "の" || $right ne "！") { return; }

    my $skill_name = $$nodes[$skill_name_index]->as_text;

    if ($$nodes[$skill_name_index + 2] =~ /HASH/ && $$nodes[$skill_name_index + 2]->tag eq "font") {
        my $orig_name = $$nodes[$skill_name_index + 2]->as_text;
        if ($orig_name =~ /（/ && $orig_name !~ /消費SP/) {
            $orig_name =~ s/（//;
            $orig_name =~ s/）//;

            $skill_name = $orig_name;
        }
    }

    if ($skill_name ne "★デスニューク") {return;}

    my ($skill_id, $user_name, $max_damage, $total_damage) = ("", 0, 0, 0);

    $user_name = $$nodes[$skill_name_index - 2]->as_text;
    $skill_id = $self->{CommonDatas}{SkillData}->GetOrAddId(0, [$skill_name, 0, 0, 0, 0, "", 1]);

    my $nodes_size = scalar(@$nodes);
    for(my $i=$skill_name_index; $i<$nodes_size; $i++) {
        my $after_node = $$nodes[$i];
        if ($after_node =~ /HASH/ && $after_node->attr("class") && $after_node->attr("class") eq "status_box") {
            last;
        }
        if ($after_node =~ /HASH/ && $after_node->attr("tag") && $after_node->attr("tag") eq "b") {
            last;
        }

        if ($after_node =~ /HASH/ && $after_node->attr("class") && $after_node->attr("class") eq "damagecut") {
            my @damage_data = $after_node->content_list;
            my $damage = $damage_data[0];

            $total_damage += $damage;

            if ($max_damage < $damage) {
                $max_damage = $damage;
            }
        }
    }

    $self->{Datas}{Nuclear}->AddData(join(ConstData::SPLIT, ($self->{ApNo}, 0, $skill_id, $user_name, $turn, $max_damage, $total_damage)));

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
