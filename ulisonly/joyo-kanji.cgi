#!/usr/local/bin/ruby
# -*- Ruby -*-
# $Id$

$KCODE = 'euc'

require 'cgi'
require 'net/http'
require 'uri'
require 'kconv'

cgi = CGI.new

#  THIS_URI = 'http://' + cgi.server_name + cgi.script_name
#  if cgi.has_key?('uri') then
#    THIS_URI += '?' + cgi.query_string
#  end

# ´Á»úÁ´ÈÌ¤Ë¥Þ¥Ã¥Á¤¹¤ë
KANJI_REGEXP = '[°¡-üî]'

# ¾ïÍÑ´Á»úÉ½¤Ë¥Þ¥Ã¥Á
JOYO_KANJI_REGEXP = '[°¡°¥°¦°­°®°µ°·°Â°Å°Æ°Ê°Ì°Í°Î°Ï°Ñ°Ò°Ó°Õ°Ö°×°Ù°Û°Ü°Ý°Þ°ß°á°ã°ä°å°æ°è°é°ì°í°ï°ð°ò°õ°÷°ø°ù°ú°û±¡±¢±£±¤±¦±§±©±«±²±º±¿±À±Ä±Æ±Ç±É±Ê±Ë±Ñ±Ò±Ó±Ô±Õ±Ö±×±Ø±Ù±Ú±Û±Ü±ß±à±ã±ä±ç±è±é±ê±ì±î±ï±ó±ô±ö±ø±ú±û±ü±ý±þ²¡²£²¤²¥²¦²§²«²­²¯²°²±²µ²·²¸²¹²º²»²¼²½²¾²¿²Á²Â²Ã²Ä²Æ²Ç²È²É²Ê²Ë²Ì²Í²Î²Ï²Ð²Ò²Ô²Õ²Ö²Ù²Ú²Û²Ý²ß²á²ã²æ²è²ê²ì²í²î²ð²ñ²ò²ó²ô²õ²÷²ø²ù²û²ü²ý²þ³£³¤³¥³¦³§³¨³«³¬³­³¯³°³²³´³µ³¶³¹³º³À³Å³Æ³È³Ê³Ë³Ì³Í³Î³Ï³Ð³Ñ³Ó³Ô³Õ³Ö³×³Ø³Ù³Ú³Û³Ý³ã³ä³å³ç³è³é³ê³ì³í³î³ô´¢´¥´§´¨´©´ª´«´¬´­´®´°´±´²´³´´´µ´¶´·´¸´¹´º´½´¾´¿´À´Á´Ä´Å´Æ´Ç´É´Ê´Ë´Ì´Î´Ï´Ñ´Ó´Ô´Õ´Ö´×´Ø´Ù´Û´Ý´Þ´ß´ã´ä´è´é´ê´ë´í´î´ï´ð´ñ´ó´ô´õ´ö´÷´ø´ù´ú´û´ü´ý´þµ¡µ¢µ¤µ¥µ§µ¨µªµ¬µ­µ®µ¯µ°µ±µ²µ³µ´µ¶µ·µ¹µºµ»µ¼µ½µ¾µ¿µÁµÄµÆµÈµÊµÍµÑµÒµÓµÔµÕµÖµ×µÙµÚµÛµÜµÝµÞµßµàµáµãµåµæµçµéµêµëµìµíµîµïµðµñµòµóµõµöµ÷µùµûµýµþ¶¡¶¥¶¦¶§¶¨¶«¶­¶®¶¯¶²¶³¶´¶µ¶¶¶·¶¸¶¹¶º¶»¶¼¶½¶¿¶À¶Á¶Ã¶Ä¶Å¶Ç¶È¶É¶Ê¶Ë¶Ì¶Ð¶Ñ¶Ô¶×¶Ø¶Ú¶Û¶Ý¶ß¶à¶á¶â¶ã¶ä¶å¶ç¶è¶ì¶î¶ñ¶ò¶ó¶õ¶ö¶ø¶ù¶þ·¡·¤·«·¬·®·¯·°·±·²·³·´·¸·¹·º·»·¼·¿·À·Á·Â·Ã·Ä·Æ·Ç·È·É·Ê·Ì·Ï·Ð·Ñ·Ô·Ö·×·Ù·Ú·Ü·Ý·Þ·ß·à·â·ã·æ·ç·è·é·ê·ë·ì·î·ï·ð·ò·ó·ô·õ·÷·ø·ù·ú·û·ü¸¡¸¢¸¤¸¥¸¦¸¨¸©¸ª¸«¸¬¸­¸®¸¯¸±¸²¸³¸µ¸¶¸·¸¸¸¹¸º¸»¸¼¸½¸À¸Â¸Ä¸Å¸Æ¸Ç¸É¸Ê¸Ë¸Ì¸Í¸Î¸Ï¸Ð¸Ø¸Û¸Ü¸Ý¸Þ¸ß¸á¸â¸ä¸å¸æ¸ç¸ë¸ì¸í¸î¸ò¸ô¸õ¸÷¸ø¸ù¸ú¸ü¸ý¸þ¹¡¹£¹¥¹¦¹§¹©¹ª¹¬¹­¹¯¹±¹²¹³¹´¹µ¹¶¹¹¹»¹½¹¾¹¿¹Á¹Â¹Ã¹Ä¹Å¹Æ¹È¹Ê¹Ë¹Ì¹Í¹Î¹Ò¹Ó¹Ô¹Õ¹Ö¹×¹Ø¹Ù¹Ú¹Û¹Ý¹ß¹à¹á¹â¹ä¹æ¹ç¹é¹ë¹î¹ï¹ð¹ñ¹ò¹ó¹õ¹ö¹ø¹ü¹þº£º¤º¦º§º¨º©º«º¬º®º°º²º´º¶º¸º¹ººº½º¾º¿ºÂºÄºÅºÆºÇºÊºËºÌºÍºÎºÏºÐºÑºÒºÕº×ºØºÙºÚºÛºÜºÝºÞºßºàºáºâºäºéºêºîºïºñºòºöº÷ºøºùºýºþ»¡»£»¤»¥»¦»¨»®»°»±»²»³»´»¶»·»º»»»½»¿»À»Ã»Ä»Å»Ç»È»É»Ê»Ë»Ì»Í»Î»Ï»Ð»Ñ»Ò»Ô»Õ»Ö»×»Ø»Ù»Ü»Ý»Þ»ß»à»á»ã»ä»å»æ»ç»è»é»ê»ë»ì»í»î»ï»ð»ñ»ò»ó»ô»õ»ö»÷»ø»ù»ú»û»ü»ý»þ¼¡¼¢¼£¼¥¼§¼¨¼ª¼«¼­¼°¼±¼´¼·¼¹¼º¼¼¼¾¼¿¼À¼Á¼Â¼Ç¼Ë¼Ì¼Í¼Î¼Ï¼Ð¼Ñ¼Ò¼Ô¼Õ¼Ö¼×¼Ø¼Ù¼Ú¼Û¼Ü¼ß¼à¼á¼ã¼ä¼å¼ç¼è¼é¼ê¼ë¼ì¼í¼î¼ï¼ñ¼ò¼ó¼ô¼õ¼÷¼ø¼ù¼û¼ü¼ý¼þ½¡½¢½£½¤½¥½¦½¨½©½ª½¬½­½®½°½±½µ½·½¸½¹½»½¼½½½¾½À½Á½Â½Ã½Ä½Å½Æ½Ç½É½Ê½Ë½Ì½Í½Î½Ï½Ð½Ñ½Ò½Ó½Õ½Ö½Ú½Û½Ü½Þ½à½á½â½ã½ä½å½ç½è½é½ê½ë½î½ï½ð½ñ½ô½õ½ö½÷½ø½ù½ü½ý½þ¾¡¾¢¾£¾¤¾¦¾§¾©¾¬¾­¾®¾¯¾°¾²¾´¾µ¾¶¾·¾¸¾º¾¼¾½¾¾¾Â¾Ã¾Ä¾Æ¾Ç¾È¾É¾Ê¾Ë¾Ì¾Í¾Î¾Ï¾Ð¾Ñ¾Ò¾Ó¾×¾Ù¾Ú¾Û¾Ü¾Ý¾Þ¾â¾ã¾å¾æ¾è¾é¾ê¾ë¾ì¾í¾î¾ï¾ð¾ò¾ô¾õ¾ö¾ø¾ù¾ú¾û¾ü¾þ¿¢¿£¿¥¿¦¿§¿¨¿©¿«¿­¿®¿¯¿°¿±¿²¿³¿´¿µ¿¶¿·¿¹¿»¿¼¿½¿¿¿À¿Â¿Ã¿Å¿Æ¿Ç¿È¿É¿Ê¿Ë¿Ì¿Í¿Î¿Ï¿Ò¿Ó¿Ô¿×¿Ø¿Ý¿Þ¿á¿â¿ã¿ä¿å¿æ¿ç¿è¿ê¿ë¿ì¿î¿ï¿ñ¿ò¿ô¿õ¿ø¿ùÀ¡À£À¤À¥À¦À§À©ÀªÀ«À¬À­À®À¯À°À±À²ÀµÀ¶À·À¸À¹ÀºÀ»À¼À½À¾À¿ÀÀÀÁÀÂÀÄÀÅÀÆÀÇÀÉÀÊÀËÀÍÀÎÀÏÀÐÀÑÀÒÀÓÀÕÀÖÀ×ÀÚÀÛÀÜÀÝÀÞÀßÀàÀáÀâÀãÀäÀåÀçÀèÀéÀêÀëÀìÀîÀïÀðÀòÀôÀõÀöÀ÷ÀøÀûÀþÁ¡Á¥Á¦Á©ÁªÁ«Á¬Á­Á¯Á°Á±Á²Á³Á´ÁµÁ¶ÁºÁ¼ÁÂÁÃÁÄÁÅÁÆÁÇÁÈÁÊÁËÁÎÁÏÁÐÁÒÁÓÁÔÁÕÁØÁÛÁÜÁÝÁÞÁàÁáÁâÁãÁåÁçÁèÁêÁëÁíÁðÁñÁòÁôÁõÁöÁ÷ÁøÁúÁûÁüÁýÁþÂ¡Â¢Â£Â¤Â¥Â¦Â§Â¨Â©Â«Â¬Â­Â®Â¯Â°Â±Â²Â³Â´Â¸Â¹ÂºÂ»Â¼Â¾Â¿ÂÀÂÄÂÅÂÆÂÇÂÌÂÎÂÐÂÑÂÓÂÔÂÕÂÖÂØÂÙÂÚÂÛÂÞÂßÂàÂáÂâÂåÂæÂçÂèÂêÂìÂîÂðÂòÂóÂôÂõÂ÷ÂùÂúÃ¢Ã£Ã¥Ã¦ÃªÃ«Ã°Ã±Ã²Ã´ÃµÃ¸ÃºÃ»Ã¼ÃÀÃÂÃÃÃÄÃÅÃÆÃÇÃÈÃÊÃËÃÌÃÍÃÎÃÏÃÑÃÓÃÔÃÕÃÖÃ×ÃÙÃÛÃÜÃÝÃßÃàÃáÃâÃãÃäÃåÃæÃçÃèÃéÃêÃëÃìÃíÃîÃïÃòÃóÃøÃùÃúÃûÄ¢Ä£Ä¤Ä¥Ä¦Ä§Ä¨Ä©Ä«Ä¬Ä®Ä¯Ä°Ä±Ä²Ä´Ä¶Ä·Ä¹ÄºÄ»Ä¼Ä¾Ä¿ÄÀÄÁÄÂÄÃÄÄÄÅÄÆÄÉÄËÄÌÄÍÄÒÄÚÄàÄâÄãÄäÄåÄçÄèÄéÄêÄëÄìÄíÄîÄïÄñÄóÄøÄùÄúÄûÄþÅ¡Å¥Å¦Å¨Å©ÅªÅ«Å¬Å¯Å°Å±Å³Å´ÅµÅ·Å¸Å¹ÅºÅ¾ÅÀÅÁÅÂÅÄÅÅÅÇÅÉÅÌÅÍÅÏÅÐÅÓÅÔÅØÅÙÅÚÅÛÅÜÅÝÅÞÅßÅàÅáÅâÅãÅçÅéÅêÅëÅìÅíÅïÅðÅòÅôÅöÅ÷ÅùÅúÅûÅüÅýÅþÆ¤Æ¥Æ¦Æ§Æ¨Æ©Æ«Æ¬Æ­Æ®Æ¯Æ°Æ±Æ²Æ³Æ¶Æ¸Æ¹Æ»Æ¼Æ½Æ¿ÆÀÆÁÆÃÆÄÆÆÆÇÆÈÆÉÆÌÆÍÆÏÆÖÆÚÆÞÆßÆâÆìÆîÆðÆñÆóÆôÆõÆùÆüÆýÆþÇ¡Ç¢Ç¤Ç¥Ç¦Ç§Ç«Ç­Ç®Ç¯Ç°Ç³Ç´ÇºÇ»Ç¼Ç½Ç¾ÇÀÇÄÇÆÇÈÇÉÇËÇÌÇÏÇÐÇÑÇÒÇÓÇÔÇÕÇØÇÙÇÚÇÛÇÜÇÝÇÞÇßÇãÇäÇåÇæÇìÇîÇïÇñÇòÇõÇöÇ÷ÇùÇúÇûÇþÈ¢È©ÈªÈ¬È­È¯È±È²È³È´È¶È¼È½È¾È¿ÈÁÈÂÈÄÈÇÈÈÈÉÈÊÈËÈÌÈÍÈÎÈÏÈÑÈÒÈÓÈÕÈÖÈ×ÈÚÈÜÈÝÈÞÈàÈáÈâÈãÈäÈæÈçÈèÈéÈêÈëÈíÈîÈïÈñÈòÈóÈôÈ÷ÈøÈùÈþÉ¡É¤É¬É®É±É´É¶É¸É¹ÉºÉ¼É½É¾ÉÁÉÂÉÃÉÄÉÊÉÍÉÏÉÐÉÑÉÒÉÓÉÔÉÕÉ×ÉØÉÙÉÛÉÜÉÝÉÞÉßÉáÉâÉãÉäÉåÉæÉèÉéÉêÉëÉíÉîÉðÉñÉôÉõÉ÷ÉúÉûÉüÉýÉþÊ¡Ê¢Ê£Ê¤Ê§Ê¨Ê©ÊªÊ¬Ê®Ê¯Ê°Ê³Ê´Ê¶Ê·Ê¸Ê¹ÊºÊ»Ê¼Ê½Ê¾Ê¿ÊÀÊÁÊÂÊÄÊÅÊÆÊÉÊÊÊÌÊÐÊÑÊÒÊÔÊÕÊÖÊ×ÊØÊÙÊÛÊÝÊÞÊáÊâÊäÊæÊçÊèÊéÊëÊìÊíÊïÊðÊñÊóÊôÊõÊöÊøÊúÊüÊýË¡Ë¢Ë¤Ë¥Ë¦Ë§Ë«Ë¬Ë­Ë®Ë°Ë³Ë´ËµË¶Ë·Ë¸Ë¹ËºË»Ë¼Ë½Ë¾Ë¿ËÀËÁËÂËÃËÄËÅËÇËÉËÌËÍËÏËÐËÑËÒË×ËÙËÛËÜËÝËÞËßËàËáËâËãËäËåËçËèËëËìËôËõËöËúËüËýËþÌ¡Ì£Ì¤Ì¥Ì¨Ì©Ì®Ì¯Ì±Ì²Ì³Ì´ÌµÌ·Ì¸Ì»Ì¼Ì¾Ì¿ÌÀÌÁÌÂÌÃÌÄÌÇÌÈÌÊÌÌÌÏÌÐÌÑÌÓÌÔÌÕÌÖÌ×ÌÚÌÛÌÜÌáÌäÌæÌçÌèÌëÌîÌðÌñÌòÌóÌôÌõÌöÌøÌûÌýÌþÍ¡Í¢Í£Í¥Í¦Í§Í©ÍªÍ«Í­Í±Í³ÍµÍ¶Í·Í¹ÍºÍ»Í¼Í½Í¾Í¿ÍÀÍÂÍÄÍÆÍÇÍÈÍÉÍÊÍËÍÍÍÎÍÏÍÑÍÒÍÓÍÕÍ×ÍØÍÙÍÛÍÜÍÞÍßÍáÍâÍãÍåÍçÍèÍêÍëÍíÍîÍïÍðÍñÍóÍôÍ÷ÍøÍùÍúÍýÎ¡Î¢Î¤Î¥Î¦Î§Î¨Î©Î¬Î®Î±Î²Î³Î´ÎµÎ¸Î¹ÎºÎ»Î½Î¾ÎÀÎÁÎÃÎÄÎÅÎÈÎÉÎÌÎÍÎÎÎÏÎÐÎÑÎÒÎÓÎ×ÎØÎÙÎÝÎÞÎßÎàÎáÎãÎäÎåÎéÎëÎìÎíÎîÎïÎðÎñÎòÎóÎôÎõÎöÎ÷ÎøÎýÏ¢Ï£Ï§Ï©ÏªÏ«Ï­Ï¯Ï°Ï²Ï³Ï·ÏºÏ»Ï¿ÏÀÏÂÏÃÏÅÏÇÏÈÏÑÏÓ]'

# ¿ÍÌ¾´Á»ú¤Ë¥Þ¥Ã¥Á
JINMEI_KANJI_REGEXP = '[±¯¾çÇµÇ·ÌéÏË°çËòµüÎ¼°Ë¸à´ìÎâ²ÀÍ¤´¦ÐÒ¸öÏÁ¼Å°ôºãÌêÎ¿ÑÛÆä³®Ò¦¶©±¬±ÃÂþ³ð¸ãÏ¤ºÈ±´Âï¶¬²Å·½¶ÆÆàÔ÷É²´òÌÒ¹¨Í¨ÆÒ½ÔÖÅÍò¿óº·Îæ´àÌ¦ÇÃÃ§¾±¹°Ìï×ÂÉ§É·ÉËÎç½úÄðÆ×°ÔÁÚ·ÅÆ´·ý¾¹ÆèÆØÈå±÷Ã¶°°²¢¹·¾»Úå¹¸¿¸ÚçÚðÚïÃÒÚöÄª½ìÊþºóÍû°ÉÅÎÉ¢Í®Ëï·ªÛÙ·Ë¶Í°´¾¿¸èÍüÌºÄÇÜ¿ÄØÍÌÉöÆï¿ºËêÄÐ³òµÌÃÉ¶Õ¶Öµ£ÝÜÄõ¼®ÂÁº»½§Þ­Þ«¹À½ß½í°¯Í¯ÞæÞûßºô¦·§ßù»¸à¢ÁÖ¼¤Ãö¶êÎèÎ°ÂöÎÖ¸ê±Í¿ðÎÜàöº¼ÍþÊã»©â«ÈýâÈËÓÎÆÆ·¶ëÊËÀÙ°ëÍ´Ï½Ä÷¿Áµ©Ì­ÎÇ¾÷½×ãùºû¼Ó¹ÉÄÝ¸¾°¼ÁîåÅåº°½ÈìæÆ¿éÍÔÌíÁïÈ¥¸Õ°ýæû½Ø±ðÉç¶Ü±ñçý²Ø³ý°«è½´Ð¾ÔèÁË¨Çë°ª¼¬ÁóÍÖÏ¡ÄÕ¾ÖÉùÍõÆ£Íö¸×ÆúÄ³¶Þ·¶ºÀëÎµÃëÙÎÊìâÊåÃ¤íìÍÚÎËÍ¸Æá°êÆÓ½æºÓ¶Ó³ù°¤È»¿÷²âÌ÷µÇ¿Üðóñ¥³¾¶ð½Ù³¡°¾¸ñÂäÈ·Ë±¹ãË²ÄáÂë¼¯ÎÛËûóÕÂãµµ]'

# HTMLÉôÊ¬
HTML_HEADER = <<EOF
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN"
	"http://www.w3.org/TR/html4/strict.dtd">
<html lang="ja">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=EUC-JP">
<link rel="stylesheet" href="../default.css" type="text/css">
<link rev="made" href="mailto:masao@ulis.ac.jp">
<title>¾ïÍÑ´Á»ú¥Õ¥£¥ë¥¿</title>
</head>
<body>
<h1>¾ïÍÑ´Á»ú¥Õ¥£¥ë¥¿</h1>
<p>
¾ïÍÑ´Á»ú¡¿¿ÍÌ¾´Á»ú¤Ç¤Ê¤¤´Á»ú¤ò»È¤Ã¤Æ¤¤¤ë¤«¤ò´ÊÃ±¤ËÈ½Äê¤Ç¤­¤Þ¤¹¡£
</p>
<p>
¾ïÍÑ´Á»úÉ½¤Ê¤É¤Î¥Ç¡¼¥¿¤Ï¡¢<a href="http://www.aozora.gr.jp/kanji_table/">http://www.aozora.gr.jp/kanji_table/</a>¡ÊÀÄ¶õÊ¸¸Ë¡Ë¤Ë¤¢¤ë¥â¥Î¤òÍøÍÑ¤µ¤»¤Æ¤¤¤¿¤À¤­¤Þ¤·¤¿¡£
</p>
EOF

HTML_FOOTER = <<EOF
<hr>
<form action="#{cgi.script_name}" method="GET">
URL: <input type="text" name="uri" value="http://" size="70">
<select name="use_jinmei">
<option value="on" checked>¾ïÍÑ¡Ü¿ÍÌ¾´Á»ú
<option value="off">¾ïÍÑ´Á»ú¤Î¤ß
</select>
<input type="submit" value=" ¥Á¥§¥Ã¥¯¤¹¤ë ">
</form>
<hr>
<address>
¹âµ×²íÀ¸ (Takaku Masao)<br>
<a href="http://nile.ulis.ac.jp/~masao/">http://nile.ulis.ac.jp/~masao/</a>, 
<a href="mailto:masao@ulis.ac.jp">masao@ulis.ac.jp</a>
</address>
<div class="id">$Id$</div>
</body>
</html>
EOF

if cgi.has_key?('uri') then
  # print HTML_HEADER
  uri = URI.parse cgi['uri'][0]
  content = Net::HTTP.get(uri.host, uri.path)
  converted_str = content.toeuc.gsub(/(#{KANJI_REGEXP})/) {|str|
    if cgi['use_jinmei'][0] == 'on' then
      regexp = /(#{JOYO_KANJI_REGEXP}|#{JINMEI_KANJI_REGEXP})/
    else
      regexp = /#{JOYO_KANJI_REGEXP}/
    end
    str =~ regexp ? str : "<span title=\"#{str}\">¢®</span>"
  }
  print cgi.header("charset" => 'EUC-JP')
  print "<base href=\"#{uri}\">"
  print converted_str
  # print CGI.escapeHTML(converted_str)
  # print HTML_FOOTER
else
  print cgi.header("charset" => 'EUC-JP')
  print HTML_HEADER, HTML_FOOTER
end
