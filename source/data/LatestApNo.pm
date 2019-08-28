#===================================================================
#        最終取得結果番号取得パッケージ
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
package LatestApNo;

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
    ($self->{CommonDatas}, my $file_name) = @_;

    #初期化
    $self->{LatestApNo} = 1;
    $self->{Datas}{LatestApNo}  = StoreData->new();
    my $header_list = "";
   
    $header_list = [
                "latest_ap_no",
    ];

    $self->{Datas}{LatestApNo}->Init($header_list);
    
    #出力ファイル設定
    $self->{Datas}{LatestApNo}->SetOutputName( $file_name );

    $self->ReadLatestData();
    return;
}

#-----------------------------------#
#    最終データを読み込む
#-----------------------------------#
sub ReadLatestData(){
    my $self      = shift;
    
    my $file_name = "./output/battle/latest_ap_no.csv";
    
    #既存データの読み込み
    my $content = &IO::FileRead ( $file_name );
    
    my @file_data = split(/\n/, $content);
    shift (@file_data);
    
    foreach my  $data_set(@file_data){
        my $latest_datas = []; 
        @$latest_datas   = split(ConstData::SPLIT, $data_set);

        $self->{LatestApNo} = $$latest_datas[0] + 1;

    }

    return;
}

#-----------------------------------#
#    データ入力
#------------------------------------
#    引数｜結果番号
#          ターン別参加者一覧ノード
#          タイトルデータノード
#-----------------------------------#
sub SetLatestApNo{
    my $self = shift;
    my $latest_ap_no  = shift;
    
    $self->{LatestApNo} = $latest_ap_no;
    
    $self->{Datas}{LatestApNo}->AddData(join(ConstData::SPLIT, ($self->{LatestApNo})));
    
    return;
}

#-----------------------------------#
#    データ取得
#------------------------------------
#    引数｜結果番号
#          ターン別参加者一覧ノード
#          タイトルデータノード
#-----------------------------------#
sub GetLatestApNo{
    my $self = shift;

    return $self->{LatestApNo};
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
