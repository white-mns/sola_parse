#===================================================================
#        キャラステータス解析パッケージ
#-------------------------------------------------------------------
#            (C) 2019 @white_mns
#===================================================================


# パッケージの使用宣言    ---------------#
use strict;
use warnings;

use ConstData;
use HTML::TreeBuilder;
use source::lib::GetNode;


require "./source/lib/IO.pm";
require "./source/lib/time.pm";

require "./source/chara/Name.pm";
require "./source/chara/Status.pm";
require "./source/chara/Class.pm";
require "./source/chara/Equip.pm";
require "./source/chara/Skill.pm";
require "./source/chara/Title.pm";

use ConstData;        #定数呼び出し

#------------------------------------------------------------------#
#    パッケージの定義
#------------------------------------------------------------------#
package Character;

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
    ($self->{Date}, $self->{DateTime}, $self->{CommonDatas}) = @_;

    #インスタンス作成
    if (ConstData::EXE_CHARA_NAME)   { $self->{DataHandlers}{Name}   = Name->new();}
    if (ConstData::EXE_CHARA_STATUS) { $self->{DataHandlers}{Status} = Status->new();}
    if (ConstData::EXE_CHARA_CLASS)  { $self->{DataHandlers}{Class}  = Class->new();}
    if (ConstData::EXE_CHARA_EQUIP)  { $self->{DataHandlers}{Equip}  = Equip->new();}
    if (ConstData::EXE_CHARA_SKILL)  { $self->{DataHandlers}{Skill}  = Skill->new();}
    if (ConstData::EXE_CHARA_TITLE)  { $self->{DataHandlers}{Title}  = Title->new();}

    #初期化処理
    foreach my $object( values %{ $self->{DataHandlers} } ) {
        $object->Init($self->{Date}, $self->{DateTime}, $self->{CommonDatas});
    }
    
    return;
}

#-----------------------------------#
#    圧縮結果から詳細データファイルを抽出
#-----------------------------------#
#    
#-----------------------------------#
sub Execute{
    my $self        = shift;

    print "read files...\n";

    my ($yyyy, $mm, $dd) = ($self->{Date} =~ /(\d+)-(\d+)-(\d+)/);
    my $directory = './data/orig/chara/' . "$yyyy/$mm/$yyyy$mm$dd";

    my $start = 1;
    my $end   = 0;
    print $directory."\n";
    if (ConstData::EXE_ALLRESULT) {
        #結果全解析
        $end = GetMaxFileNo($directory,"");

    } else {
        #指定範囲解析
        $start = ConstData::FLAGMENT_START;
        $end   = ConstData::FLAGMENT_END;
    }

    print "$start to $end\n";

    for (my $e_no=$start; $e_no<=$end; $e_no++) {
        if ($e_no % 10 == 0) {print $e_no . "\n"};

        $self->ParsePage($directory."/".$e_no.".html.gz",$e_no ,0);
    }
    
    return ;
}
#-----------------------------------#
#       ファイルを解析
#-----------------------------------#
#    引数｜ファイル名
#    　　　ENo
##-----------------------------------#
sub ParsePage{
    my $self        = shift;
    my $file_name   = shift;
    my $e_no        = shift;
    my $f_no        = shift;

    #結果の読み込み
    my $content = "";
    $content = &IO::GzipRead($file_name);

    if (!$content) { return;}

    #スクレイピング準備
    my $tree = HTML::TreeBuilder->new;
    $tree->parse($content);

    my $title_span_nodes    = &GetNode::GetNode_Tag_Attr("span",  "class", "title",        \$tree);
    my $table_nodes         = &GetNode::GetNode_Tag     ("table",                          \$tree);
    my $div_pve_nodes       = &GetNode::GetNode_Tag_Attr("div", "id", "pve_content",       \$tree);
    my $div_pvp_nodes       = &GetNode::GetNode_Tag_Attr("div", "id", "pvp_content",       \$tree);
    my $div_tale_nodes      = &GetNode::GetNode_Tag_Attr("div", "id", "tale_content",      \$tree);
    my $div_challenge_nodes = &GetNode::GetNode_Tag_Attr("div", "id", "challenge_content", \$tree);
    
    if (!scalar(@$title_span_nodes)) {return;}
    
    # データリスト取得
    if (exists($self->{DataHandlers}{Name}))   {$self->{DataHandlers}{Name}->GetData  ($e_no, $$title_span_nodes[0])};
    if (exists($self->{DataHandlers}{Status})) {$self->{DataHandlers}{Status}->GetData($e_no, $table_nodes)};
    if (exists($self->{DataHandlers}{Class}))  {$self->{DataHandlers}{Class}->GetData ($e_no, $table_nodes)};
    if (exists($self->{DataHandlers}{Equip}))  {$self->{DataHandlers}{Equip}->GetData ($e_no, $table_nodes)};
    if (exists($self->{DataHandlers}{Skill}))  {$self->{DataHandlers}{Skill}->GetData ($e_no, $$div_pve_nodes[0], $$div_pvp_nodes[0], $$div_tale_nodes[0], $$div_challenge_nodes[0])};
    if (exists($self->{DataHandlers}{Title}))  {$self->{DataHandlers}{Title}->GetData ($e_no, $$title_span_nodes[0])};

    $tree = $tree->delete;
}

#-----------------------------------#
#       最大ファイル番号を取得
#-----------------------------------#
#    引数｜ディレクトリ名
#    　　　ファイル接頭辞
##-----------------------------------#
sub GetMaxFileNo{
    my $directory   = shift;
    my $prefix    = shift;

    #ファイル名リストを取得
    my @fileList = grep { -f } glob("$directory/$prefix*.html.gz");

    my $max= 0;
    foreach (@fileList) {
        if ($_ =~ /$prefix(\d+).html/ && $max < $1) {$max = $1;}
    }
    return $max
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
