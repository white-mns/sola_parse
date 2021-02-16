#===================================================================
#        称号取得パッケージ
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
package Title;

#-----------------------------------#
#    コンストラクタ
#-----------------------------------#
sub new {
  my $title = shift;
  
  bless {
        Datas => {},
  }, $title;
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
                "title",
                "created_at",
    ];

    $self->{Datas}{Data}->Init($header_list);
    
    #出力ファイル設定
    $self->{Datas}{Data}->SetOutputName( "./output/chara/title_" . $self->{Date} . ".csv" );
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
    my $title_span_node = shift;
    
    $self->{ENo} = $e_no;

    $self->GetTitleData($title_span_node);
    
    return;
}

#-----------------------------------#
#    称号データ取得
#------------------------------------
#    引数｜装備テーブルノード
#-----------------------------------#
sub GetTitleData{
    my $self  = shift;
    my $title_span_node = shift;
    my $title = "";

    $title =  $title_span_node->as_text;

    $self->{Datas}{Data}->AddData(join(ConstData::SPLIT, ($self->{ENo}, $title, $self->{Date}) ));

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
