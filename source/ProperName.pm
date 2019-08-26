#===================================================================
#        固有名詞管理パッケージ
#-------------------------------------------------------------------
#            (C) 2019 @white_mns
#===================================================================


# パッケージの使用宣言    ---------------#
use strict;
use warnings;

use ConstData;
use HTML::TreeBuilder;
use source::lib::GetNode;

require "./source/data/StoreProperName.pm";
require "./source/data/StoreProperData.pm";

use ConstData;        #定数呼び出し

#------------------------------------------------------------------#
#    パッケージの定義
#------------------------------------------------------------------#
package ProperName;

#-----------------------------------#
#    コンストラクタ
#-----------------------------------#
sub new {
  my $class        = shift;

  bless {
    Datas         => {},
    DataHandlers  => {},
    Methods       => {},
  }, $class;
}

#-----------------------------------#
#    初期化
#-----------------------------------#
sub Init{
    my $self = shift;
    ($self->{Date}, $self->{Dummy}, $self->{CommonDatas}) = @_;

    #インスタンス作成
    $self->{DataHandlers}{ProperName} = StoreProperName->new();
    $self->{DataHandlers}{SkillData}  = StoreProperData->new();
    $self->{DataHandlers}{TypeName}   = StoreProperName->new();
    $self->{DataHandlers}{GardenName} = StoreProperName->new();
    $self->{DataHandlers}{EnemyData}  = StoreProperData->new();

    #他パッケージへの引き渡し用インスタンス
    $self->{CommonDatas}{ProperName} = $self->{DataHandlers}{ProperName};
    $self->{CommonDatas}{SkillData}  = $self->{DataHandlers}{SkillData};
    $self->{CommonDatas}{TypeName}   = $self->{DataHandlers}{TypeName};
    $self->{CommonDatas}{GardenName} = $self->{DataHandlers}{GardenName};
    $self->{CommonDatas}{EnemyData}  = $self->{DataHandlers}{EnemyData};

    my $header_list = "";
    my $output_file = "";

    # 固有名詞の初期化
    $header_list = [
                "proper_id",
                "name",
    ];
    $output_file = "./output/data/". "proper_name" . ".csv";
    $self->{DataHandlers}{ProperName}->Init($header_list, $output_file," ");

    # タイプ情報の初期化
    $header_list = [
                "type_id",
                "name",
    ];
    $output_file = "./output/data/". "type_name" . ".csv";
    $self->{DataHandlers}{TypeName}->Init($header_list, $output_file, " ");

    # 庭園名の初期化
    $header_list = [
                "garden_id",
                "name",
    ];
    $output_file = "./output/data/". "garden_name" . ".csv";
    $self->{DataHandlers}{GardenName}->Init($header_list, $output_file, " ");
    $self->{CommonDatas}{GardenName}->SetId(10000, "花壇の作業レポート");

    # スキル情報の初期化
    $header_list = [
                "skill_id",
                "name",
                "cost_id",
                "text",
    ];
    $output_file = "./output/data/". "skill_data" . ".csv";
    $self->{DataHandlers}{SkillData}->Init($header_list, $output_file, [" ", 0, ""]);

    # 敵情報の初期化
    $header_list = [
                "enemy_id",
                "name",
                "line_id",
                "type_id",
    ];
    $output_file = "./output/data/". "enemy_data" . ".csv";
    $self->{DataHandlers}{EnemyData}->Init($header_list, $output_file, [" ", 0, 0]);

    return;
}

#-----------------------------------#
#   このパッケージでデータ解析はしない
#-----------------------------------#
#    
#-----------------------------------#
sub Execute{
    my $self        = shift;
    return ;
}

#-----------------------------------#
#    出力
#-----------------------------------#
#    引数｜ファイルアドレス
#-----------------------------------#
sub Output{
    my $self = shift;
    foreach my $object( values %{ $self->{Datas} } ) {
        $object->Output();
    }
    foreach my $object( values %{ $self->{DataHandlers} } ) {
        $object->Output();
    }
    return;
}

1;
