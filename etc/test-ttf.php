<?php
//error_reporting(E_ERROR | E_PARSE);
switch ($_POST['type']) {
  case 'kochi-gothic':
    $fontfile = "./kochi-gothic-subst.ttf";
    break;
  case 'kochi-mincho':
    $fontfile = "./kochi-mincho-subst.ttf";
    break;
  case 'mikachan':
    $fontfile = "./mikachan.ttf";
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
    $fontfile = "./kochi-gothic-subst.ttf";
}

$text = $_POST['text'];
$size = is_numeric($_POST['size']) ? $_POST['size'] : 40;

if (strlen($text) > 0) {
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
<link rev="made" href="mailto:masao@ulis.ac.jp">
<title>TrueTypeフォントのテスト</title>
</head>
<body>
<div class="last-update">公開日: 2003年06月24日</div>
<!-- hhmts start -->
<div class="last-update">最終更新日: 2003年06月24日</div>
<!-- hhmts end -->
<h1>TrueTypeフォントのテスト</h1>
<p>
PHPに同梱されているGDライブラリの機能を使って、
各種TrueTypeフォントの文字をPNG画像として表示します。
</p>
<form action="./test-ttf.php" method="POST">
<div>
<textarea name="text" rows="5" cols="80">Hello, World!
ここに文章を書いてください。</textarea><br>
フォント: <select name="type">
  <option value="kochi-gothic">東風ゴチック</option>
  <option value="kochi-mincho">東風明朝</option>
  <option value="mikachan">みかちゃんフォント</option>
  <option value="batang">Baekmuk明朝（batang）</option>
  <option value="dotum">Baekmukゴチック（dotum）</option>
  <option value="gulim">Baekmuk丸ゴチック（gulim）</option>
  <option value="hline">Baekmuk極太ゴチック（hline）</option>
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
<p>
使っているフォントとそのバージョンを以下に示します。
</p>
<ul>
  <li><a href="http://sourceforge.jp/projects/efont/">東風フォント</a>: kochi-substitute-20030623.tar.bz2
  <li><a href="http://mikachan-font.com">みかちゃんフォント</a>: mikachanfont-8.8.tar.bz2
  <li><a href="ftp://ftp.mizi.com/pub/baekmuk">Baekmuk</a>（※ 韓国語用です）: baekmuk-ttf-2.1.tar.gz
</ul>
<hr>
<address>
高久雅生 (Takaku Masao)<br>
<a href="http://nile.ulis.ac.jp/~masao/">http://nile.ulis.ac.jp/~masao/</a>, 
<a href="mailto:masao@ulis.ac.jp">masao@ulis.ac.jp</a>
</address>
<div class="id">$Id$</div>
</body>
</html>
<?php } ?>
