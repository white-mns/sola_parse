#===================================================================
#        設定スキル取得パッケージ
#-------------------------------------------------------------------
#            (C) 2019 @white_mns
#===================================================================


# パッケージの使用宣言    ---------------#   
use strict;
use warnings;
require "./source/lib/Store_Data.pm";
require "./source/lib/Store_HashData.pm";
require "./source/new/NewSkill.pm";
use ConstData;        #定数呼び出し
use source::lib::GetNode;


#------------------------------------------------------------------#
#    パッケージの定義
#------------------------------------------------------------------#     
package Skill;

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
sub Init{
    my $self = shift;
    ($self->{Date}, $self->{DateTime}, $self->{CommonDatas}) = @_;
    
    #初期化
    $self->{Datas}{Data}  = StoreData->new();
    $self->{Datas}{New}   = NewSkill->new();
    my $header_list = "";
   
    $header_list = [
                "e_no",
                "battle_type",
                "set_no",
                "skill_id",
                "name",
                "created_at",
    ];

    $self->{Datas}{Data}->Init($header_list);
    $self->{Datas}{New}->Init($self->{Date}, $self->{CommonDatas});
    
    #出力ファイル設定
    $self->{Datas}{Data}->SetOutputName( "./output/chara/skill_" . $self->{Date} . ".csv" );
    return;
}

#-----------------------------------#
#    データ取得
#------------------------------------
#    引数｜e_no,サブキャラ番号,スキルテーブルノード
#-----------------------------------#
sub GetData{
    my $self    = shift;
    my $e_no    = shift;
    my $div_pve_node = shift;
    my $div_pvp_node = shift;
    
    $self->{ENo} = $e_no;

    $self->GetSkillData($div_pve_node, 0);
    $self->GetSkillData($div_pvp_node, 1);
    
    return;
}

#-----------------------------------#
#    スキルデータ取得
#------------------------------------
#    引数｜スキル設定番号ノード
#-----------------------------------#
sub GetSkillData{
    my $self  = shift;
    my $div_node = shift;
    my $battle_type = shift;

    my ($set_no, $skill_id, $name) = (0, 0, "");

    my $tr_nodes = &GetNode::GetNode_Tag("tr",  \$div_node);

    foreach my $tr_node (@$tr_nodes) {
        my $th_nodes = &GetNode::GetNode_Tag("th",  \$tr_node);

        $set_no = $$th_nodes[0]->as_text;
        if ($set_no !~ /^[0-9]+$/) { next; }


        my @skill_name_nodes = $$th_nodes[1]->content_list;
        my $skill_name = "";

        if (scalar(@skill_name_nodes) > 1) {
            $name = $skill_name_nodes[0];
            $skill_name = $skill_name_nodes[2]->as_text;
            $skill_name =~ s/[\(]//;
            $skill_name =~ s/[\)]//;

        } elsif (scalar(@skill_name_nodes) == 1) {
            $name = $skill_name_nodes[0];
            $skill_name = $skill_name_nodes[0];

        }

        if ($skill_name eq "") { next; }

        my $is_artifact = ($skill_name =~ /★/) ? 1 : 0;

        my $range = $$th_nodes[2]->as_text;
        $range = ($range eq "-") ? -1 : $range;
        $range = ($range eq "?") ? -2 : $range;

        my $effect_text = $$th_nodes[3]->as_text;

        my ($timing_text, $cost_text, $text, $sp) = ("", "", "", 0);
        if ($effect_text =~ /【(.+)】(.+)/) {
            $timing_text = $1;
            $text = $2;
        }

        if ($timing_text =~ /(.+):(.+)/) {
            $cost_text = $1;
            $timing_text = $2;
        }

        if ($cost_text =~ /SP(\d+)/) {
            $sp = $1;
        }

        my $timing_id = ($timing_text ne "") ? $self->{CommonDatas}{ProperName}->GetOrAddId($timing_text) : 0;
        my $cost_id   = ($cost_text   ne "") ? $self->{CommonDatas}{ProperName}->GetOrAddId($cost_text)   : 0;

        $skill_id = $self->{CommonDatas}{SkillData}->GetOrAddId(1, [$skill_name, $range, $cost_id, $sp, $timing_id, $text, $is_artifact]);
        $self->{Datas}{Data}->AddData(join(ConstData::SPLIT, ($self->{ENo}, $battle_type, $set_no, $skill_id, $name, $self->{Date}) ));
        
        $self->{Datas}{New}->RecordNewSkillData($self->{Date}, $skill_id);
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
