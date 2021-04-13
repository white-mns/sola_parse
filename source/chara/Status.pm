#===================================================================
#        ステータス取得パッケージ
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
package Status;

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
    $self->{Datas}{Dummy} = StoreData->new();
    my $header_list = "";
   
    $header_list = [
                "e_no",
                "str",
                "vit",
                "sense",
                "agi",
                "mag",
                "int",
                "will",
                "charm",
                "line",
                "role_id",
                "used_ap",
                "used_stp",
                "goodness",
                "mel",
                "medal",
                "kudos",
                "created_at",
                "updated_at",
    ];

    $self->{Datas}{Data}->Init($header_list);

    $header_list = [
                "e_no",
                "created_at",
    ];

    $self->{Datas}{Dummy}->Init($header_list);
    
    #出力ファイル設定
    $self->{Datas}{Data}-> SetOutputName( "./output/chara/status_" .      $self->{Date} . ".csv" );
    $self->{Datas}{Dummy}->SetOutputName( "./output/chara/status_dummy_" . $self->{Date} . ".csv" );
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

    my $used_node   = $self->GetTableNodeFromFristTh($table_nodes, "消費済AP");
    my $mel_node   = $self->GetTableNodeFromFristTh($table_nodes, "メル");
    my $status_node = $self->GetTableNodeFromFristTh($table_nodes, "隊列");
    $self->GetStatusData($used_node, $mel_node, $status_node);
    
    return;
}

#-----------------------------------#
#    最初のセルの文字列を元にテーブル取得
#------------------------------------
#    引数｜テーブルノードリスト
#-----------------------------------#
sub GetTableNodeFromFristTh{
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
#    ステータスデータ取得
#------------------------------------
#    引数｜消費済テーブルノード
#          ステータステーブルノード
#-----------------------------------#
sub GetStatusData{
    my $self  = shift;
    my $used_node = shift;
    my $mel_node = shift;
    my $status_node = shift;
    my ($str, $vit, $sense, $agi, $mag, $int, $will, $charm, $line, $role_id) = (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
    my ($used_ap, $used_stp, $goodness) = (0, 0, 0);
    my ($mel, $medal, $kudos) = (0, 0, 0);

    my $used_th_nodes   = &GetNode::GetNode_Tag("th", \$used_node);
    my $mel_th_nodes   = &GetNode::GetNode_Tag("th", \$mel_node);
    my $status_th_nodes = &GetNode::GetNode_Tag("th", \$status_node);
    
    foreach my $node (@$used_th_nodes) {
        my $item =  $node->as_text;
        if ($item eq "消費済AP") {
            $used_ap = $node->right->as_text;

        } elsif ($item eq "消費済ステータスポイント") {
            $used_stp = $node->right->as_text;

        } elsif ($item eq "善行値") {
            $goodness = $node->right->as_text;
        }
    }

    foreach my $node (@$mel_th_nodes) {
        my $item =  $node->as_text;
        if ($item eq "メル") {
            $mel = $node->right->as_text;
            $mel =~ s/mel//;
            $mel =~ s/,//g;

        } elsif ($item eq "ギルドメダル") {
            $medal = $node->right->as_text;
            $medal =~ s/枚//;

        } elsif ($item eq "名声") {
            $kudos = $node->right->as_text;
            $kudos =~ s/点//;
        }
    }

    foreach my $node (@$status_th_nodes) {
        my $item =  $node->as_text;
        if ($item eq "筋力") {
            $str = $node->right->as_text;

        } elsif ($item eq "体力") {
            $vit = $node->right->as_text;

        } elsif ($item eq "感覚") {
            $sense = $node->right->as_text;

        } elsif ($item eq "敏捷") {
            $agi = $node->right->as_text;

        } elsif ($item eq "魔力") {
            $mag = $node->right->as_text;

        } elsif ($item eq "知力") {
            $int = $node->right->as_text;

        } elsif ($item eq "意志") {
            $will = $node->right->as_text;

        } elsif ($item eq "魅力") {
            $charm = $node->right->as_text;

        } elsif ($item eq "隊列") {
            $line = $node->right->as_text;

        } elsif ($item eq "ロール") {
            $role_id = $self->{CommonDatas}{ProperName}->GetOrAddId($node->right->as_text);
        }
    }

    $self->{Datas}{Data}->AddData(join(ConstData::SPLIT, ($self->{ENo}, $str, $vit, $sense, $agi, $mag, $int, $will, $charm, $line, $role_id, $used_ap, $used_stp, $goodness, $mel, $medal, $kudos, $self->{Date}, $self->{DateTime}) ));
    $self->{Datas}{Dummy}->AddData(join(ConstData::SPLIT, ($self->{ENo}, $self->{Date}) ));

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
