#===================================================================
#        クラス取得パッケージ
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
package Class;

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
    ($self->{Date}, $self->{CommonDatas}) = @_;
    
    #初期化
    $self->{Datas}{Data}  = StoreData->new();
    my $header_list = "";
   
    $header_list = [
                "e_no",
                "class_id",
                "class_num",
                "lv",
                "created_at",
    ];

    $self->{Datas}{Data}->Init($header_list);
    
    #出力ファイル設定
    $self->{Datas}{Data}->SetOutputName( "./output/chara/class_" . $self->{Date} . ".csv" );
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

    my $class_node   = $self->GetClassNode($table_nodes);
    $self->GetClassData($class_node);
    
    return;
}

#-----------------------------------#
#    クラスデータテーブル取得
#------------------------------------
#    引数｜テーブルノードリスト
#-----------------------------------#
sub GetClassNode{
    my $self  = shift;
    my $table_nodes = shift;
    
    foreach my $table_node (@$table_nodes) {
        my $th_nodes = &GetNode::GetNode_Tag("th", \$table_node);
        my $th0_text =  $$th_nodes[0]->as_text;

        if ($th0_text eq "クラス1") { return $table_node; }
    }
    return;
}

#-----------------------------------#
#    クラスデータ取得
#------------------------------------
#    引数｜クラステーブルノード
#-----------------------------------#
sub GetClassData{
    my $self  = shift;
    my $class_node = shift;
    my ($class_id, $class_num, $lv) = (0, 0, 0);

    my $class_th_nodes = &GetNode::GetNode_Tag("th", \$class_node);

    foreach my $node (@$class_th_nodes) {
        my $item =  $node->as_text;

        if ($item =~ /クラス(\d)/) {
            $class_num = $1;
            $class_id = $self->{CommonDatas}{ProperName}->GetOrAddId($node->right->as_text);
            $lv = $node->right->right->as_text;
            $lv =~ s/Lv //;

            $self->{Datas}{Data}->AddData(join(ConstData::SPLIT, ($self->{ENo}, $class_id, $class_num, $lv, $self->{Date}) ));
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
