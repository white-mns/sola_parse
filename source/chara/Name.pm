#===================================================================
#        PC名取得パッケージ
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
package Name;

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
                "name",
    ];

    $self->{Datas}{Data}->Init($header_list);
    
    #出力ファイル設定
    $self->{Datas}{Data}->SetOutputName( "./output/chara/name.csv" );

    $self->ReadLastData();

    return;
}

#-----------------------------------#
#    既存データを読み込む
#-----------------------------------#
sub ReadLastData(){
    my $self      = shift;
    
    my $file_name = "";
    $file_name = "./output/chara/name.csv" ;
    
    #既存データの読み込み
    my $content = &IO::FileRead ( $file_name );
    
    my @file_data = split(/\n/, $content);
    shift (@file_data);
    
    foreach my  $data_set(@file_data){
        my $all_name_datas = []; 
        @$all_name_datas   = split(ConstData::SPLIT, $data_set);
        my $e_no = $$all_name_datas[0];
        my $name = $$all_name_datas[1];
        if(!exists($self->{AllName}{$e_no})){
            $self->{AllName}{$e_no} = [$e_no, $name];
        }
    }

    return;
}


#-----------------------------------#
#    データ取得
#------------------------------------
#    引数｜e_no,サブキャラ番号,ステータステーブルノード
#-----------------------------------#
sub GetData{
    my $self    = shift;
    my $e_no    = shift;
    my $title_span_node = shift;
    
    $self->{ENo} = $e_no;

    $self->GetNameData($title_span_node);
    
    return;
}
#-----------------------------------#
#    名前データ取得
#------------------------------------
#    引数｜ステータステーブルノード
#-----------------------------------#
sub GetNameData{
    my $self  = shift;
    my $title_span_node = shift;
    my $name = "";

    my @lefts =  $title_span_node->left;
    @lefts = reverse(@lefts);

    $name = $lefts[1]->as_text;
    if ($name !~ /No.\d+ /) { # 開始初期レイアウト
        $name = $lefts[0]->as_text;
    }

    $name =~ s/No.\d+ //g;
    @lefts = reverse(@lefts);

    $self->{AllName}{$self->{ENo}} = [$self->{ENo}, $name];

    return;
}

#-----------------------------------#
#    出力
#------------------------------------
#    引数｜
#-----------------------------------#
sub Output{
    my $self = shift;
    
    # 全キャラクター名情報の書き出し
    foreach my $e_no (sort{$a cmp $b} keys %{ $self->{AllName} } ) {
        $self->{Datas}{Data}->AddData(join(ConstData::SPLIT, @{ $self->{AllName}{$e_no} }));
    }

    foreach my $object( values %{ $self->{Datas} } ) {
        $object->Output();
    }
    return;
}
1;
