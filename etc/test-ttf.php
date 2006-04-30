<?php // -*- html-helper -*-
//error_reporting(E_ERROR | E_PARSE);
switch ($_POST['type']) {
  case 'sazanami-gothic':
    $fontfile = "./sazanami-gothic.ttf";
    break;
  case 'sazanami-mincho':
    $fontfile = "./sazanami-mincho.ttf";
    break;
  case 'mikachan':
    $fontfile = "./mikachan.ttf";
    break;
  case 'cyberbit':
    $fontfile = "./Cyberbit.ttf";
    break;
  case 'code2002':
    $fontfile = "./CODE2002.TTF";
    break;
  case 'vera':
    $fontfile = "./Vera.ttf";
    break;
  case 'caslon':
    $fontfile = "./CASLR___.TTF";
    break;
  case 'batang':
    $fontfile = "./batang.ttf";
    break;
  case 'dotum':
    $fontfile = "./dotum.ttf";
    break;
  case 'gulim':
    $fontfile = "./gulim.ttf";
    break;
  case 'hline':
    $fontfile = "./hline.ttf";
    break;
  default:
    $fontfile = "./sazanami-gothic-subst.ttf";
}

$text = $_POST['text'];
$size = is_numeric($_POST['size']) ? $_POST['size'] : 40;

if (strlen($text) > 0) {
  if (get_magic_quotes_gpc()) {
    $text = stripslashes($text);
  }

  header("Content-type: image/jpeg");
//    ImageFtText($im, 10, 0, 0, 0, $black, $fontfile, $text);
  $bbox = ImageTtfBbox($size, 0, $fontfile, $text);
  $width  = abs($bbox[2] - $bbox[0]) + 20; //image width
  $height = abs($bbox[5] - $bbox[3]) + 20; //image height

  $im     = ImageCreate($width, $height);
  $white = imagecolorallocate($im, 255, 255, 255);
  ImageFill($im, 0, 0, $white);

  $black = imagecolorallocate($im, 0, 0, 0);
  ImageTtfText($im, $size, 0, 0, $size+10, $black, $fontfile, $text);
//    ImageString($im, 6, 0, 0, $text, $black);

  ImageJpeg($im);
  ImageDestroy($im);
} else {
  header("Content-type: text/html; charset=utf-8");
?>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">
<html lang="ja">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link rel="stylesheet" href="../default.css" type="text/css">
<link rev="made" href="mailto:masao@nii.ac.jp">
<title>TrueTypeフォントの表示テスト</title>
</head>
<body>
<div class="last-update">公開日: 2003年06月24日</div>
<!-- hhmts start -->
<div class="last-update">最終更新日: 2006年04月30日</div>
<!-- hhmts end -->
<h1>TrueTypeフォントの表示テスト</h1>
<form action="./test-ttf.php" method="POST">
<div>
<textarea name="text" rows="5" cols="80">Hello, World!
ここに文章を書いてください。</textarea><br>
フォント: <select name="type">
  <option value="sazanami-gothic">さざなみゴチック</option>
  <option value="sazanami-mincho">さざなみ明朝</option>
  <option value="mikachan">みかちゃんフォント</option>
  <option value="cyberbit">Bitstream Cyberbit</option>
  <option value="vera">Bitstream Vera</option>
  <option value="code2002">Code2002</option>
<!--
  <option value="caslon">Caslon</option>
  <option value="batang">Baekmuk明朝（batang）</option>
  <option value="dotum">Baekmukゴチック（dotum）</option>
  <option value="gulim">Baekmuk丸ゴチック（gulim）</option>
  <option value="hline">Baekmuk極太ゴチック（hline）</option>
-->
</select>
サイズ: <select name="size">
  <option>10</option>
  <option>20</option>
  <option>30</option>
  <option>40</option>
  <option>50</option>
  <option>100</option>
</select>
<br>
<input type="submit" value="変換">
</div>
</form>
<h2>概要</h2>
<p>
PHPに同梱されているGDライブラリの機能を使って、
各種TrueTypeフォントの文字をPNG画像として表示します。
</p>
<p>
<a href="http://wiki.fdiary.net/font/">書体関係Wiki</a>の議論を見ていて、
作成を思い立ちました。
フォントについては素人なので、何も分かっていませんが、
いろんなフォントを簡単に閲覧できると嬉しいと思ったので…。
</p>
<p>
一応、使っているフォントとそのバージョンを以下に示します。
</p>
<ul>
  <li><a href="http://sourceforge.jp/projects/efont/">さざなみフォント</a>: sazanami-20040629.tar.bz2
  <li><a href="http://mikachan-font.com">みかちゃんフォント</a>: ver9.1.lzh
  <li><a href="ftp://ftp.netscape.com/pub/communicator/extras/fonts/windows/">Cyberbit</a>: Cyberbit Version 2.0
  <li><a href="http://home.att.net/~jameskass/">Code2002</a>: CODE2002.ZIP
  <li><a href="http://www.gnome.org/fonts/">Bitstream Vera Fonts</a>: ttf-bitstream-vera-1.10.tar.bz2
<!--
  <li><a href="http://bibliofile.mc.duke.edu/gww/fonts/Caslon/Caslon.html#Unicode">Caslon</a>: CasUni.zip
  <li><a href="ftp://ftp.mizi.com/pub/baekmuk">Baekmuk</a>（※ 韓国語用です）: baekmuk-ttf-2.1.tar.gz
-->
</ul>
<h2>制限事項</h2>
<p>
単純にPHPのGDライブラリの機能を使っているだけなので、合成文字など使えない機能は多いと思いますので、期待しないでください。
</p>
<p>
念のため、以下にソースを置いておきます。
<a href="http://nais.to/~yto/doc/zb/0002.html">無償・無保証・著作権放棄</a>の扱いでご自由にどうぞ。
</p>
<ul>
  <li><a href="test-ttf.php.txt">test-ttf.php.txt</a>
</ul>
<h2>関連リンク</h2>
<ul>
  <li><a href="http://openlab.jp/efont/">/efont/</a>
  <li><a href="http://unifont.org/fontguide/">Unicode Font Guide</a>
  <li><a href="http://www.nongnu.org/freefont/">Free UCS Outline Fonts</a>
</ul>
<hr>
<address>
高久雅生 (Takaku Masao)<br>
<a href="http://masao.jpn.org/">http://masao.jpn.org/</a>, 
<a href="mailto:masao@nii.ac.jp">masao@nii.ac.jp</a>
</address>
<div class="id">$Id$</div>
</body>
</html>
<?php } ?>
