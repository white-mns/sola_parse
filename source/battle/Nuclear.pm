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

    foreach my $action_node (@right_nodes) {
        if ($action_node =~ /HASH/ && $action_node->attr("class") && $action_node->attr("class") eq "status_box") {
            last;
        }

        if ($action_node =~ /HASH/ && $action_node->tag("b")) {
            $self->GetNuclearData($action_node, $turn);
        }

    }
}


#-----------------------------------#
#    核爆発取得
#------------------------------------
#    引数｜サブタイトルノード
#-----------------------------------#
sub GetNuclearData{
    my $self  = shift;
    my $b_node  = shift;
    my $turn = shift;

    my $left = $b_node->left;
    my $right = $b_node->right;

    if ($left ne "の" || $right ne "！") { return; }
    $left = "";
    $right = "";

    my @right_nodes = $b_node->right;

    my $skill_name = $b_node->as_text;

    if ($right_nodes[1] =~ /HASH/ && $right_nodes[1]->tag eq "font") {
        my $orig_name = $right_nodes[1]->as_text;
        if ($orig_name =~ /（/ && $orig_name !~ /消費SP/) {
            $orig_name =~ s/（//;
            $orig_name =~ s/）//;

            $skill_name = $orig_name;
        }
    }

    if ($skill_name ne "★デスニューク") {return;}

    my ($skill_id, $user_name, $max_damage, $total_damage) = ("", 0, 0);

    my @left_nodes = $b_node->left;
    my $left_size = scalar(@left_nodes);
    $user_name = $left_nodes[$left_size - 2]->as_text;
    @left_nodes = ();
    $skill_id = $self->{CommonDatas}{SkillData}->GetOrAddId(0, [$skill_name, 0, 0, 0, 0, "", 1]);

    foreach my $right_node (@right_nodes) {
        if ($right_node =~ /HASH/ && $right_node->attr("class") && $right_node->attr("class") eq "status_box") {
            last;
        }
        if ($right_node =~ /HASH/ && $right_node->attr("tag") && $right_node->attr("tag") eq "b") {
            last;
        }

        if ($right_node =~ /HASH/ && $right_node->attr("class") && $right_node->attr("class") eq "damagecut") {
            my @damage_data = $right_node->content_list;
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
