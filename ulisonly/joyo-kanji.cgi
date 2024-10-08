#!/usr/local/bin/ruby -wT
# -*- Ruby -*-
# $Id$

$KCODE = 'euc'

require 'cgi'
require 'net/http'
require 'uri'
require 'nkf'

cgi = CGI.new

# 漢字全てにマッチする正規表現
ALL_KANJI_REGEXP = /[亜-��]/

# 常用漢字表にマッチ
JOYO_KANJI = '亜哀愛悪握圧扱安暗案以位依偉囲委威尉意慰易為異移維緯胃衣違遺医井域育一壱逸稲芋印員因姻引飲院陰隠韻右宇羽雨渦浦運雲営影映栄永泳英衛詠鋭液疫益駅悦謁越閲円園宴延援沿演炎煙猿縁遠鉛塩汚凹央奥往応押横欧殴王翁黄沖億屋憶乙卸恩温穏音下化仮何価佳加可夏嫁家寡科暇果架歌河火禍稼箇花荷華菓課貨過蚊我画芽賀雅餓介会解回塊壊快怪悔懐戒拐改械海灰界皆絵開階貝劾外害慨概涯街該垣嚇各拡格核殻獲確穫覚角較郭閣隔革学岳楽額掛潟割喝括活渇滑褐轄且株刈乾冠寒刊勘勧巻喚堪完官寛干幹患感慣憾換敢棺款歓汗漢環甘監看管簡緩缶肝艦観貫還鑑間閑関陥館丸含岸眼岩頑顔願企危喜器基奇寄岐希幾忌揮机旗既期棋棄機帰気汽祈季紀規記貴起軌輝飢騎鬼偽儀宜戯技擬欺犠疑義議菊吉喫詰却客脚虐逆丘久休及吸宮弓急救朽求泣球究窮級糾給旧牛去居巨拒拠挙虚許距漁魚享京供競共凶協叫境峡強恐恭挟教橋況狂狭矯胸脅興郷鏡響驚仰凝暁業局曲極玉勤均斤琴禁筋緊菌襟謹近金吟銀九句区苦駆具愚虞空偶遇隅屈掘靴繰桑勲君薫訓群軍郡係傾刑兄啓型契形径恵慶憩掲携敬景渓系経継茎蛍計警軽鶏芸迎鯨劇撃激傑欠決潔穴結血月件倹健兼券剣圏堅嫌建憲懸検権犬献研絹県肩見謙賢軒遣険顕験元原厳幻弦減源玄現言限個古呼固孤己庫弧戸故枯湖誇雇顧鼓五互午呉娯後御悟碁語誤護交侯候光公功効厚口向后坑好孔孝工巧幸広康恒慌抗拘控攻更校構江洪港溝甲皇硬稿紅絞綱耕考肯航荒行衡講貢購郊酵鉱鋼降項香高剛号合拷豪克刻告国穀酷黒獄腰骨込今困墾婚恨懇昆根混紺魂佐唆左差査砂詐鎖座債催再最妻宰彩才採栽歳済災砕祭斎細菜裁載際剤在材罪財坂咲崎作削搾昨策索錯桜冊刷察撮擦札殺雑皿三傘参山惨散桟産算蚕賛酸暫残仕伺使刺司史嗣四士始姉姿子市師志思指支施旨枝止死氏祉私糸紙紫肢脂至視詞詩試誌諮資賜雌飼歯事似侍児字寺慈持時次滋治璽磁示耳自辞式識軸七執失室湿漆疾質実芝舎写射捨赦斜煮社者謝車遮蛇邪借勺尺爵酌釈若寂弱主取守手朱殊狩珠種趣酒首儒受寿授樹需囚収周宗就州修愁拾秀秋終習臭舟衆襲週酬集醜住充十従柔汁渋獣縦重銃叔宿淑祝縮粛塾熟出術述俊春瞬准循旬殉準潤盾純巡遵順処初所暑庶緒署書諸助叙女序徐除傷償勝匠升召商唱奨宵将小少尚床彰承抄招掌昇昭晶松沼消渉焼焦照症省硝礁祥称章笑粧紹肖衝訟証詔詳象賞鐘障上丈乗冗剰城場壌嬢常情条浄状畳蒸譲醸錠嘱飾植殖織職色触食辱伸信侵唇娠寝審心慎振新森浸深申真神紳臣薪親診身辛進針震人仁刃尋甚尽迅陣酢図吹垂帥推水炊睡粋衰遂酔錘随髄崇数枢据杉澄寸世瀬畝是制勢姓征性成政整星晴正清牲生盛精聖声製西誠誓請逝青静斉税隻席惜斥昔析石積籍績責赤跡切拙接摂折設窃節説雪絶舌仙先千占宣専川戦扇栓泉浅洗染潜旋線繊船薦践選遷銭銑鮮前善漸然全禅繕塑措疎礎祖租粗素組訴阻僧創双倉喪壮奏層想捜掃挿操早曹巣槽燥争相窓総草荘葬藻装走送遭霜騒像増憎臓蔵贈造促側則即息束測足速俗属賊族続卒存孫尊損村他多太堕妥惰打駄体対耐帯待怠態替泰滞胎袋貸退逮隊代台大第題滝卓宅択拓沢濯託濁諾但達奪脱棚谷丹単嘆担探淡炭短端胆誕鍛団壇弾断暖段男談値知地恥池痴稚置致遅築畜竹蓄逐秩窒茶嫡着中仲宙忠抽昼柱注虫衷鋳駐著貯丁兆帳庁弔張彫徴懲挑朝潮町眺聴脹腸調超跳長頂鳥勅直朕沈珍賃鎮陳津墜追痛通塚漬坪釣亭低停偵貞呈堤定帝底庭廷弟抵提程締艇訂逓邸泥摘敵滴的笛適哲徹撤迭鉄典天展店添転点伝殿田電吐塗徒斗渡登途都努度土奴怒倒党冬凍刀唐塔島悼投搭東桃棟盗湯灯当痘等答筒糖統到討謄豆踏逃透陶頭騰闘働動同堂導洞童胴道銅峠匿得徳特督篤毒独読凸突届屯豚曇鈍内縄南軟難二尼弐肉日乳入如尿任妊忍認寧猫熱年念燃粘悩濃納能脳農把覇波派破婆馬俳廃拝排敗杯背肺輩配倍培媒梅買売賠陪伯博拍泊白舶薄迫漠爆縛麦箱肌畑八鉢発髪伐罰抜閥伴判半反帆搬板版犯班畔繁般藩販範煩頒飯晩番盤蛮卑否妃彼悲扉批披比泌疲皮碑秘罷肥被費避非飛備尾微美鼻匹必筆姫百俵標氷漂票表評描病秒苗品浜貧賓頻敏瓶不付夫婦富布府怖扶敷普浮父符腐膚譜負賦赴附侮武舞部封風伏副復幅服福腹複覆払沸仏物分噴墳憤奮粉紛雰文聞丙併兵塀幣平弊柄並閉陛米壁癖別偏変片編辺返遍便勉弁保舗捕歩補穂募墓慕暮母簿倣俸包報奉宝峰崩抱放方法泡砲縫胞芳褒訪豊邦飽乏亡傍剖坊妨帽忘忙房暴望某棒冒紡肪膨謀貿防北僕墨撲朴牧没堀奔本翻凡盆摩磨魔麻埋妹枚毎幕膜又抹末繭万慢満漫味未魅岬密脈妙民眠務夢無矛霧婿娘名命明盟迷銘鳴滅免綿面模茂妄毛猛盲網耗木黙目戻問紋門匁夜野矢厄役約薬訳躍柳愉油癒諭輸唯優勇友幽悠憂有猶由裕誘遊郵雄融夕予余与誉預幼容庸揚揺擁曜様洋溶用窯羊葉要謡踊陽養抑欲浴翌翼羅裸来頼雷絡落酪乱卵欄濫覧利吏履理痢裏里離陸律率立略流留硫粒隆竜慮旅虜了僚両寮料涼猟療糧良量陵領力緑倫厘林臨輪隣塁涙累類令例冷励礼鈴隷零霊麗齢暦歴列劣烈裂廉恋練連錬炉路露労廊朗楼浪漏老郎六録論和話賄惑枠湾腕'

# 人名漢字にマッチ
JINMEI_KANJI = '丑丞乃之也亘亥亦亨亮伊伍伎伶伽佑侃侑倖倭偲允冴冶凌凛凪凱勁匡卯叡只叶吾呂哉唄啄喬嘉圭尭奈奎媛嬉孟宏宥寅峻崚嵐嵩嵯嶺巌巳巴巽庄弘弥彗彦彪彬怜恕悌惇惟惣慧憧拳捷捺敦斐於旦旭旺昂昌昴晃晋晏晟晨智暉暢曙朋朔李杏杜柊柚柾栗栞桂桐梓梢梧梨椋椎椰椿楊楓楠榛槙槻樺橘檀欣欽毅毬汀汐汰沙洲洵洸浩淳渚渥湧滉漱澪熙熊燎燦燿爽爾猪玖玲琉琢琳瑚瑛瑞瑠瑶瑳璃甫皐皓眉眸睦瞭瞳矩碧碩磯祐禄禎秦稀稔稜穣竣笙笹紗紘紬絃絢綜綸綺綾緋翔翠耀耶聡肇胡胤脩舜艶芙芹苑茉茄茅茜莉莞菖菫萌萩葵蒔蒼蓉蓮蔦蕉蕗藍藤蘭虎虹蝶衿袈裟詢誼諄諒赳輔辰迪遥遼邑那郁酉醇采錦鎌阿隼雛霞靖鞠須頌颯馨駒駿魁鮎鯉鯛鳩鳳鴻鵬鶴鷹鹿麟麿黎黛亀'

HTML_FOOTER = <<EOF
<p>
<strong>注意</strong>: EUC-JP, ISO-2022-JP, Shift_JIS 以外の文字コードには対応していません。
</p>
<hr>
<address>
高久雅生 (Takaku Masao)<br>
<a href="http://masao.jpn.org/">http://masao.jpn.org/</a>, 
<a href="mailto:masao@nii.ac.jp">masao@nii.ac.jp</a>
</address>
<div class="id">$Id$</div>
</body>
</html>
EOF

# str 文字列中の漢字のうち、dict に含まれないものを適宜変換する
# 2003-01-31: HTML タグ内は変換しないように修正した。
def kanji_convert (str, dict)
   retstr = ""
   str.split(/(<.+?>)/).each do |tmp|
      if tmp =~ /^</
	 retstr += NKF.nkf("-eX", tmp).gsub(ALL_KANJI_REGEXP) {|kanji|
	    dict.index(kanji) ? kanji : "〓"
	 }
      else
	 retstr += NKF.nkf("-eX", tmp).gsub(ALL_KANJI_REGEXP) {|kanji|
	    dict.index(kanji) ? kanji : "<span title=\"#{kanji}\">〓</span>"
	 }
      end
   end
   return retstr
end

# HTML の先頭部分
def html_header (cgi)
   uri = CGI.escapeHTML(cgi['uri'][0] || 'http://')
   data = CGI.escapeHTML(cgi['textarea'][0] || '')
   html = <<EOF
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN"
"http://www.w3.org/TR/html4/strict.dtd">
<html lang="ja">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=EUC-JP">
<link rel="stylesheet" href="../default.css" type="text/css">
<link rev="made" href="mailto:masao@nii.ac.jp">
<title>常用漢字フィルタ</title>
</head>
<body>
<h1>常用漢字フィルタ</h1>
<p>
常用漢字／人名漢字でない漢字を使っているかを簡単に判定できます。
</p>
<p>
常用漢字表などのデータは、<a href="http://www.aozora.gr.jp/kanji_table/">http://www.aozora.gr.jp/kanji_table/</a>（青空文庫）にあるモノを利用させていただきました。
</p>
<hr>
<table border="0">
<form action="#{cgi.script_name}" method="POST">
<tr>
<td><input type="radio" name="target" value="uri"
EOF
   html += "checked" if cgi['target'][0] == 'uri'
   html += <<EOF
>URL:</td>
<td><input type="text" name="uri" value="#{uri}" size="70"></td>
</tr>
<tr>
<td valign="top"><input type="radio" name="target" value="text"
EOF
   html += "checked" if cgi['target'][0] == 'text'
   html += <<EOF
>データ:</td>
<td><textarea name="textarea" rows="10" cols="70">#{data}</textarea></td>
</tr>
<td align="right">対象:</td>
<td><select name="use_jinmei">
<option value="on"
EOF
   html += "selected" if cgi['use_jinmei'][0] == 'on'
   html += <<EOF
>常用＋人名漢字
<option value="off"
EOF
   html += "selected" if cgi['use_jinmei'][0] == 'off'
   html += <<EOF
>常用漢字のみ
</select></td></tr>
<tr><td colspan="2" align="center"><input type="submit" value=" チェックする "></td></tr>
</form>
</table>
EOF
   return html
end

print cgi.header("charset" => 'EUC-JP')
if cgi.has_key?('target') then
   kanji_dict = JOYO_KANJI
   kanji_dict += JINMEI_KANJI if cgi['use_jinmei'][0] == 'on'
   if cgi['target'][0] == 'uri' then
      uri = URI.parse cgi['uri'][0].untaint
      content = Net::HTTP.get(uri.host, uri.request_uri)
      print "<base href=\"#{uri}\">"
      print kanji_convert(content, kanji_dict)
   else
      content = CGI.escapeHTML(cgi['textarea'][0])
      print html_header(cgi)
      print "<hr><pre style=\"border: solid 1px; padding: 4px; margin: 1em;\">"
      print kanji_convert(content, kanji_dict)
      print "</pre>" + HTML_FOOTER
   end
else
   print html_header(cgi)
   print HTML_FOOTER
end
