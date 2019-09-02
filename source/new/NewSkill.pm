#===================================================================
#        新規設定スキル情報取得パッケージ
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
use Time::Piece; 
use Time::Seconds;

#------------------------------------------------------------------#
#    パッケージの定義
#------------------------------------------------------------------#     
package NewSkill;

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
    $self->{Datas}{NewSkill} = StoreData->new();
    $self->{Datas}{AllSkill} = StoreData->new();
    my $header_list = "";
   
    $header_list = [
                "created_at",
                "skill_id",
    ];

    $self->{Datas}{NewSkill}->Init($header_list);
    $self->{Datas}{AllSkill}->Init($header_list);
    
    #出力ファイル設定
    $self->{Datas}{NewSkill}->SetOutputName( "./output/new/skill_" . $self->{Date} . ".csv" );
    $self->{Datas}{AllSkill}->SetOutputName( "./output/new/all_skill_" . $self->{Date} . ".csv" );
    
    $self->ReadLastNewData();

    return;
}

#-----------------------------------#
#    既存データを読み込む
#-----------------------------------#
sub ReadLastNewData(){
    my $self      = shift;
   
    my $today = Time::Piece->strptime($self->{Date}, '%Y-%m-%d');
    my $yesterday = $today - Time::Seconds->new(86400);

    my $file_name = "./output/new/all_skill_" . $yesterday->year . "-" . sprintf("%02d", $yesterday->mon) . "-" . sprintf("%02d", $yesterday->mday) . ".csv" ;
    
    #既存データの読み込み
    my $content = &IO::FileRead ( $file_name );
    
    my @file_data = split(/\n/, $content);
    shift (@file_data);
    
    foreach my  $data_set(@file_data){
        my $new_skill_datas = []; 
        @$new_skill_datas   = split(ConstData::SPLIT, $data_set);
        my $date = $$new_skill_datas[0];
        my $skill_id = $$new_skill_datas[1];
        if(!exists($self->{AllSkill}{$skill_id})){
            $self->{AllSkill}{$skill_id} = [$date, $skill_id];
        }
    }

    return;
}

#-----------------------------------#
#    新規設定スキルの判定と記録
#------------------------------------
#    引数｜アイテム名
#-----------------------------------#
sub RecordNewSkillData{
    my $self    = shift;
    my $date = shift;
    my $skill_id = shift;

    if (exists($self->{AllSkill}{$skill_id})) {return;}

    $self->{Datas}{NewSkill}->AddData(join(ConstData::SPLIT, ($date, $skill_id) ));

    $self->{AllSkill}{$skill_id} = [$date, $skill_id];

    return;
}
#-----------------------------------#
#    出力
#------------------------------------
#    引数｜
#-----------------------------------#
sub Output{
    my $self = shift;

    # 新出データ判定用の既出情報の書き出し
    foreach my $id (sort{$a cmp $b} keys %{ $self->{AllSkill} } ) {
        $self->{Datas}{AllSkill}->AddData(join(ConstData::SPLIT, @{ $self->{AllSkill}{$id} }));
    }
    
    foreach my $object( values %{ $self->{Datas} } ) {
        $object->Output();
    }
    return;
}
1;
