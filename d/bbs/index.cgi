#!/usr/bin/env perl
# -*-CPerl-*-
# $Id$
use strict;
use POSIX qw(strftime);
use CGI;
use CGI::Carp;

### 編集して下さい
my $conf_file = "kuttukibbs.conf"; # ユーザ設定ファイルの場所

### ユーザ設定項目 (kuttukibbs.conf で設定できます)
my $log_dir = "kblog";		# コメントログファイルを置くディレクトリ
my $latest_comment_display_num = 20; # 最新投稿表示のときに一度に表示する数
my $kb_js_display_max = 5;	# 表示するコメントの数 for js
my $kb_js_strlen_max = 40;	# 1 コメントが表示される文字数 for js
my $admin_log_file = "kblog/log.txt"; # 管理者用ログファイル
my $passwd = "";		# 管理者用パスワード
my $noname = "???";		# デフォルトの投稿者名
my $page_template_default;
my $page_template_latest;
my $page_template_edit;
my $charset = "EUC-JP";		# 文字コード
my $css = "diary.css";
my $header = "";
my $footer = "";

### グローバル変数
my $latest_id = -1;		# 最新のコメントの ID
my %com_hash;			# コメントを格納するハッシュ
my $URLCHARS = "[-_.!~*'a-zA-Z0-9;/?:@&=+,%\#\$]";

my $SPAM_BLACKLIST_WORDS = <<EOF;
A bit surprised
AFAICT
AFCAIT
AFICAT
Abslueotly
Absoltuely
All of my questions
All posts of this
Always a good job
Arictles
Aritecls
Articles like this
Awosmee
Awsemoe
Brilialcne
Brilliance
Bristih
Calling all cars
Calnlig
Cheers
Cool!
Could you write about
Death Star
Deep thought
Divorce
Essays like this
Excellent!
Excleelnt
Execlelnt
Exelcenlt
Facebook page
Fell out of bed
Gee whiz
Good job
Got it!
Grade A stuff
Great common sense
Great hammer
Great posintg
Great stuff
Great work
Halleulajh
Hey hey hey
Ho ho
Holy Toledo
Holy concise
Hot damn
How neat
I can already tell
I can count on
I don't hate it
I feel so much
I found myself
I found this article
I found this info
I have what I need
I love reading these articles
I love these articles
I really appreciate free
I saw this post
I sure appreciate
I thought finding this
I was the sensible one
I wish I would have had
I would find this
I'd have to pay
I'd thought of
I'm impressed
I'm quite pleased
I'm so glad
I've been informed
I've finally found
Infomrtaion
Infortmioan
Infromaiton
It was dark
It's great to read
Keep on writing
Kudos to you
Kudos!
Learning a ton
Life is short
Lol thank
Lol thanks
Lol!
Many many quality
Mighty useful
More power to you
Never would have thunk
Nice posting
Noralmly
Not bad at all
Not the usual
Phsiycs
Play informative
Ppl like you
San Diego
Scniece
Shoot,
Sir/Madam
Slam dunkin
So much info
So true
Someone who understands
Son of a gun
Sooenme
Stands back
Stay with this guys
Suepiror
Super excited
Super informative
Super jazzed
Superb information
Superbly illuminating
Supieror
Thank God
Thanks alot
Thanks for hanging out
Thanks for posting
Thanks for setting me
Thanks for sharing
Thanks for taking the time
Thanks for the insight
Thanks for the news
Thanks for writing
Thanks guys
Thanky
That saves me.
There are no words
There is a critical shortage
Thgouht
This article achieved
This has made my day
This information is off
This is what we need
This makes everything
Tip top
Unrpaalleled
Very true
Very valid
View my complete
WINNING!
Way to go on
Well done
Well put
What a joy
What a joy to find someone
Wheevor
Whoa, whoa
Woah nelly
Wow! Great
You know what
You make things
You really found
You saved me
You've hit the ball
Your answer lifts
Your cranium
a lot easier from here
ability to think
absoelutly
accucray
achieevd
actulaly
aenswr
aenwsr
aesnwr
after reading this
aftrneoon
airclte
airtcle
airtlce
alhrgit
all my problems
allows free info like this
amlsot
aneswr
anewsr
ansewr
answeerd
answer from
anwesr
anwser
apeapr
aplpes
appaer
apprceiaiton
apprceita
apprcieate
aprepciate
aprpeication
arcitles
arctile
arctlie
aricetls
arictles
arirevd
aritcle
aritlce
aritlces
arltices
arrtcile
artclie
arteilcs
article perfectly
article up
artlice
arvried
asenwr
asewnr
aslbuotely
asnewr
asnwer
aswenr
asweome
aswner
atcriles
atilrce
atircle
atircles
atrcile
atrciles
atricels
atricle
atrilce
atrilecs
atrlcie
awalys
awnesr
awnser
awsemoe
awsenr
awsner
aymnroe
aynthing
back from the keyboard
bceasue
bdoaciuos
beenift
beettr
beilvee
betsest
betsset
better than a brick
bferoe
bfreoe
big help
birans
birllanit
birnas
birnay
bla bla bla bla
bleeive
bleivee
bocdiauos
bodacoius
bortehr
borther
brain power
bravo!
brhoetr
brightened my day
brinas
brings light into
brliialnt
brngis
bseetst
bsetest
btesset
bteter
btorher
btteer
bullsyee
buy these articles
cahnge
cahnigng
calling up people
ceelvr
cehered
cehreed
celevr
celver
cevelr
cevler
cgahne
cgwho
chganing
chugging away
ciclked
cilcked
claered
cleared it up
cleevr
clever 4
clever by half
clever way
cloudn't
clveer
cmiong
cmmoon
cmnoig
cmonig
cnfoused
cnocout
cnocrens
cnortuibting
coimng
come up with that
come up with the
comlpicaetd
completely painless
compliatns
compuetr
conmig
consfuing
convoulted
cool thinking
cool way
cotnributing
couldn't pay me to
crietanly
cteairnly
cveler
cvleer
cvoreed
dazlznig
dcotor
deep thinking
demnsortated
dicattor
dilaspy
doctor ordered
doing so much
doors for me
drvier
easei
easily impressed
easy to understand
easy-to-understand article
ecxalty
ecxelelnt
ecxellnet
ecxelnelt
edcuaiton
eesair
eevrynoe
eevrywhree
eiasly
eisaer
end of the line
enetrtaniing
enthlraling
enuogh
epxcet
epxlain
epxuonder
erdutioin
esaeir
esaier
esaliy
esbtalishment
eseair
esesntial
esteeemd
estemeed
etinrely
etneilry
evertyihng
everynoe
evryeday
exact point
excatly
excleelnt
exclelnet
exelclent
exetrmely
exlceelnt
expeictng
expert answer
expertise answers
expetcnig
exptceing
exrpet
exrtmeely
fabluous
facts available here
failnly
falbberagsting
fathom
fbauolus
fblauuos
fbualous
feeilng
feel stupid
feelnig
fianlly
filnlay
finally found
firgue
fiurgnig
fnially
foloish
for years without
for years without knowing
gareetst
garetest
gdnaer
geaertst
geartest
gertaest
get this online
getnleemn
getraset
getting that know-how
gettnig
giinvg
giivng
give it a shot
going for years
going to talk to
goldoy
golody
good enough
good stuff
good to be true
good to find
good to find someone
good to know
good to see
gooldy
goooooal
got it in one
goto expert
graeetst
graetset
grateest
grateful you
greaestt
greaetst
great info
great internet
great page
great thinking
great to me
greeatst
greetast
gtreaset
gviing
had no idea
halsse
happeend
hard fucking
hard to find out
have thought of that
have to be the case
have you on our side
hear from you
heelpd
heepld
heflpul
helfpul
hella easy
helnpig
help tons
helpful article
helpful information
helping me out
helps me
helupfl
hepilng
hepled
heplful
heplnig
high brow literature
hit the ball
hizool
hlefpul
hleipng
hlepful
hlepnig
hlepufl
hlpeed
hlpeufl
home run
hooilgnas
hoolignas
how clever some
hpaepir
hpeflul
hpeled
huelpfl
icnlnied
icrndeible
ideal answer
idinspensable
idnispensable
ifnmoratoin
ifnomred
ifnoramtion
ifnoratimve
ifnormation
ifrnomation
ignronat
illuimnating
illumniaitng
ilncined
ilulmintaing
imemdiately
immedaeitly
immedaitely
imperssing
impesrsed
impressing me!
imrpseesd
in the same forum
increbdile
incredilbe
indebted
indispeansble
info out
infoarmtion
infomraiton
infomrtaion
informative article
informatoin
informatvie
infortamoin
infortmaion
infromaitve
ingshit
inisght
inisghts
inofmratvie
inoframtion
inoframtoin
inoframtvie
inofrmtaion
inorfmative
inrcedblie
insghit
insgiht
inteillegnt
intelliegcne
intelligent answer
intelligent point
internet hooligans
internet writer
intreent
intrenet
ipmeraivte
ipmossbile
is power
isinght
isinght
it all makes sense
job on that
just like these articles
just logic
just read this
kbaoom
kbeyoard
keep coming
keep on reading
keyaobrd
keybroad
kliler
knlowedge
knolwdege
know everything
knwlodege
knwloedge
knwodlege
knwoeldge
knwolegde
knwonig
konlwedge
kownledge
kyeborad
laoedd
lcoekd
learn a lot
liebrty
like a classroom
like yourself
lkonoig
lkooing
logic set out
loiokn
lokinog
lokiong
loknoig
lokoed
lokonig
lolita
lolitas
lonoikg
lonokig
looikng
looinkg
looking for your posts
looknig
loonikg
loonkig
lot easier
love of God
maagned
macadmaia
macamdaia
made my day
magnaed
mainkg
mangaed
marvelously good
mcaadmaia
mdniight
miknag
million thanks
mituens
miuents
mknaig
mnitue
mold-breaker
monoploy
more clever
more from this article
mortar establishment
munties
my problem
naked
nbaibt
nciley
ndeeed
neat articles
nedeed
neeedd
nelicy
never happened
nggoin
nice work!
nicely put
nilcey
none can doubt
nothnig
ntoihng
oenped
onnlie
paajmas
padrenr
pay me to ignore
pefrect
pefrtecly
pelaesd
penis
pepyaka
perecft
perfcet
perfect reply
perfect way
pertty
pianelss
pjaaams
pjamaas
plainyg
pleasure to read
pobrmles
poeuwrfl
ponits
porlbem
porlebm
porlebms
pormiisng
porn company
posntigs
possbily
possbliy
potinsg
potsing
potsings
powerfully helpful
ppoped
pragmatisdc
prbloem
prbloems
prboemls
prbolmes
preescne
probelm
probelms
problem solved
probmels
prodigious writers
proelbm
prseence
prsoen
psosilby
psoting
psoting!
psotnig
pttunig
purhcseas
pussy
put aside a whole afternoon
put it better
put this to good use
pwoerufl
pworeful
qaulity
qeustions
qluaity
queistnos
queiston
questnios
quseitons
qusetions
qusetoins
raeidng
raelly
ralely
ralley
rceokn
reading this
reaindg
really appreciate
really cool way of
really helped
really informative
really neat
reemmber
reevlation
reiandg
relaible
relaly
reliable data like this
rellay
reocgniezd
reockn
rescoure
resorcue
ritaonal
rlaely
rlealy
rlelay
rmemeber
rnunnig
roesurce
rotten egg
rpseect
rseocrue
rseoucre
rsourece
s***
saecrehd
sahring
sarhing
satifsied
satsifeid
save me time
saved me
sbulmie
sceert
sceret
scucinct
sebnsile
seecrt
semlls
semoone
senisble
sensible answer
seomnoe
seotmhing
sepkas
sercet about your post
seriusoly
sesnlibe
setting me straight
sex
sexy images
sglguing
shairng
shanrig
sharing your wisdom
sharnig
shed a ray
shloud
shluod
shnziit
shoratge
shranig
shulod
silly websites
siplme
skillful answer
skopoy
slainet
slhuod
slohud
smart way of
smeoone
smoehntig
smoenoe
smoeone
smoething
smoneoe
smooene
smoonee
snseible
snushnie
so awesome
so much learning
so much simpler
so well
socks off
socrue
sodnus
soelvd
soeomne
sohcked
sohlud
solhud
solve problems
somenoe
someone comes up with
someone who thinks
something I agree
somethnig
sometnhig
sometnihg
somneoe
somteinhg
sooemne
sopkoy
souhld
soutolin
soveld
spending time
spkooy
sppuoess
sppusoes
spurrsied
sreect
srhanig
srhwed
srmats
ssnebile
stadnrad
standard in the industry
stdnas
stgrugling
stnadard
stnadrad
stucrk
sturgglnig
sublime
sublmie
succnict
such greatness
suciccnt
suodns
suonds
super helpful
superior thinking
suppsoes
surprsied
susnnhie
svoled
svreeal
sweetheart
taelnt
tahknful
tahkns
tahnks
tailkng
take the next step
taknhs
talnikg
tanhks
tanlet
tcriky
tealnt
ternchant
terrfiic
terrific amount
tghins
thakns
thank you for this
thank you humbly
thanks for he answer
thanks for posting
thanks to your post
thanks to your posts
thanukfl
that posting
that really helped
there you
thgins
thgnis
thguhot
thienkr
thigns
thiinnkg
thikinng
thikning
thiknnig
thinikng
thininkg
thinking demonstrated
thinknig
thinks this way
thinnikg
this article saved
this helped me
this is so cool
this makes it understandable
this post hits
thkinnig
thkninig
thnaks
thngis
thnigs
thniinkg
thniknig
thninikg
thninkig
thnkaful
thnkas
thnkiing
thoghut
thohugt
thuoght
ticrky
tieckt
tihgns
tihiknng
tihkning
tihngs
tihnking
tihnknig
tihnnkig
tinhgs
tinhking
tinhknig
tiopcs
tirkcy
tkhinnig
tkhnaful
tlanet
tleant
tnahks
tnakhs
tnghis
tnhaks
tnhgis
tnhiinkg
tnhiknig
tnhkiing
tocpis
tohrugh
tohuhgt
toltaly
tons of links
too good
top of the game
topic-bravo
touchdown
touhght
trencahnt
trikcy
true I guess
truly appreciate
ttoally
tuhoght
tuhohgt
tuohhgt
turthflluy
ubneilevblae
udnersatnd
udnesrtand
ufseul
uiltzie
undsretnad
unebilevbale
useufl
valaulbes
valubaels
vauallbes
vlauables
voyeur
vuallabe
wanetd
want to get read
was looking everywhere
watching for your posts
way more helpful
way of thinking about
web20power
webiste
weeeknd
well-written
what I needed
what I was needed
what a quick and easy
what the dotcor ordered
what's up
where to find this info
who you wrote this
wirter
witohut
witring
wndeoring
wnodernig
wnodreing
wodnernig
wodnreing
wohrty
woke up down
wondreing
wonedrnig
wothry
wrierts
wrintig
write for me
write more
writnig
wrtiing
wrtinig
wrtohy
wrttien
wsebites
wtiring
wuodla
xxx
you are quite
you helped
you struck us
your answer solved
your post makes mine
EOF

# ユーザ設定ファイルの読み込み
if (not -e $conf_file) {
    die "error: can't read $conf_file\n";
}
open(CONF, "$conf_file") or die "can't open $conf_file : $!";
my $conf = join('', <CONF>);
eval $conf;

# 現在時刻の獲得
my $what_time_is_it_now = strftime "%Y-%m-%d %H:%M:%S", localtime;

my $q = new CGI;
#print $q->Dump;

my $mode = $q->param('mode');
my $logid = $q->param('id'); # コメントの ID。ログファイル指定に利用
$mode = "latest" if not defined $mode and not defined $logid;

# ユーザ情報
my $name = $q->param('name');
my $mail_or_url = $q->param('mail');
my $body = $q->param('body');

my $content_type = 'text/html';
$content_type = 'text/xml' if $mode eq 'rss';

# header
if ($mode eq 'write') {
    my $cookie = $q->cookie(-name=>'kuttukibbs',
			    -value=>"$name\t$mail_or_url",
			    -expires=>'+30d');
    print $q->header(-cookie=>$cookie, -charset=>$charset);
} else {
    print $q->header(-type=>$content_type, -charset=>$charset);
    if (defined $q->cookie('kuttukibbs')) {
	($name, $mail_or_url) = split(/\t/, $q->cookie('kuttukibbs')); 
    }
}

my $cgi_url = $q->url();

my $comments;
my $page_html;


if ($mode eq 'latest') {
    output_latest();
} elsif ($mode eq 'rss') {
    output_latest_rss();
}

# コメント対象の情報
$logid =~ s{[^a-zA-Z0-9\.\-\#_]}{_}g;
die( 'invalid id' ) if ($logid =~ /^\s*$/);
my $target_url = id2url($logid); # コメント対象の URL
$cgi_url .= "?id=$logid";
my $fn_pref = "$log_dir/$logid";

### 読み込み
my $fn = "$fn_pref.log";
my $all;
read_file($fn, \$all);

if ($mode eq "edit") {
    my $co = $q->param('content');
    if (defined $co) {
	my $pw = $q->param('passwd');
	if (defined $pw and $pw ne "" and $pw eq $passwd) { 
	    rename $fn, $fn."~";
	    save_file($fn, \$co);
	    read_file($fn, \$all);
	    set_comment_hash(\%com_hash, \$all);
            write_to_jsfile($fn_pref.".js"); # JavaScript Feed ファイル
            %com_hash = ();
	} else {
	    print "wrong password!\n";
	}
    } else {
	my $content = $all;
	$content =~ s/&/&amp;/g;
	eval qq(\$page_html = << "FFF"\n$page_template_edit\nFFF\n);
	print $page_html;
	exit;
    }
}

set_comment_hash(\%com_hash, \$all);

### 書き込み
if ($mode eq "write") {
    $name = $noname if ($name =~ /^\s*$/sm);
    
    if ($body !~ /\A\s*\Z/m) {
	# Spam対策;
	my @spam;

	# 特定のURLリンク記法やHTMLリンク記法は禁止
	@spam = ($body =~ /(\[url=https?:\/\/|<a\s+href\s*=\s*["']?\s*https?:\/\/)/gmoi);
	error("リンク記法が含まれています。\nYour comment contains a inappropriate hyperlink format.") if scalar(@spam) > 0;

	# URLを3つ以上書くのは禁止
	@spam = ($body =~ /https?:\/\//gmo);
	error("複数のURLが書かれています。\nYour comment contains too many URLs.") if scalar(@spam) > 2;

	# 特定の文字列を禁止
	my $spam_regex = join( '|', map { quotemeta($_) } split( /\n/, $SPAM_BLACKLIST_WORDS ) );
	@spam = ($body =~ /(\b|\s)($spam_regex)(\b|\s)/gmio);
	error("禁止された語句が含まれています。\nYour comment contains one or more stop words, such as 'cool','funny' etc.") if scalar(@spam) > 0;
	@spam = ($body =~ /\b(good|nice|cool|funny|best|great|neat|sweet|wonderful|big|super|informative|salient|awesome|easy-to-understand|brilliant|free|deep|useful) (site|post|work|article|job|help|answer|point|info|internet|way|page|thought|sharing)/gmoi);
	error("禁止された語句が含まれています。\nYour comment contains one or more stop words, such as 'cool','funny' etc.") if scalar(@spam) > 0;
	@spam = ($body =~ /\b(brain power|gareetst|aswenr|asnwer|awnesr|awnser|aneswr|asnewr|aswner|anwesr|cevelr|cleevr|impesrsed|inrcedblie|tahnks|tahkns|taknhs|thniknig|tihnknig|celver|seomnoe|hlepnig|magnaed|birnas|thuoght|slohud|suodns|fnially|rlaely|raelly|eiasly|fnially)\b/gmoi);
	error("禁止された語句が含まれています。\nYour comment contains one or more stop words, such as 'cool','funny' etc.") if scalar(@spam) > 0;
	@spam = ($body =~ /\b(good point|sounds great|great thinking)/gmoi);
	error("禁止された語句が含まれています。\nYour comment contains one or more stop words, such as 'cool','funny' etc.") if scalar(@spam) > 0;
	@spam = ($body =~ /\b(great|cool|really|superior) (thinking)/gmoi);
	error("禁止された語句が含まれています。\nYour comment contains one or more stop words, such as 'cool','funny' etc.") if scalar(@spam) > 0;
	@spam = ($body =~ /^(\w+\d\.txt\;\d+\;\d+|comment\d+)/gmoi);
	error("禁止された語句が含まれています。\nYour comment contains one or more stop words, such as 'cool','funny' etc.") if scalar(@spam) > 0;
	@spam = ($body =~ /ｗｗｗｗｗ/gmoi);
	error("禁止された語句が含まれています。\nYour comment contains one or more stop words, such as 'cool','funny' etc.") if scalar(@spam) > 0;

	# 特定のURLを禁止
	@spam = ($body =~ /\bhttps?:\/\/(\w+\.)?google\.(com|us|jp)\/group\/\w?\w?(ticket|teens)/gmoi);
	error("禁止されたURLが含まれています。\nYour comment contains a spamming URL.") if scalar(@spam) > 0;
	@spam = ($body =~ /\bhttps?:\/\/(ylm\.me|jtgvrqveco\.com|fastcashloans\.tv|(jn|www)\.l7i7\.com|\w+\.lefora\.com)/gmoi);
	error("禁止されたURLが含まれています。\nYour comment contains a spamming URL.") if scalar(@spam) > 0;

	# 特定のアドレスからの投稿を禁止
	error("禁止されたアドレス/URLが含まれています。\nYour comment contains a spamming E-mail address/URL.") if $mail_or_url eq 'maxhamehame@livedoor.com';
	error("禁止されたアドレス/URLが含まれています。\nYour comment contains a spamming E-mail address/URL.") if $mail_or_url eq 'mail';
	error("禁止されたアドレス/URLが含まれています。\nYour comment contains a spamming E-mail address/URL.") if $mail_or_url eq 'email@gmail.com';

	# 特定のホストからの投稿を禁止
	error("禁止されたホストからの投稿です。\nYour host has been blocked as a spamming server.") if $q->remote_host() =~ /(giga-dns\.com|localmatchmakerservices\.com|hostkey\.ru|quadranet\.com|comcast\.net|xsserver\.eu|bergdorf-group\.com|\.kimsufi\.com)$/o;
	error("禁止されたホストからの投稿です。\nYour host has been blocked as a spamming server.") if $q->remote_host() =~ /^(208\.53\.158\.241|68\.169\.86\.22.|199\.19\.104\.197)$/o;

	$name = CGI::escapeHTML( $name );
	$mail_or_url = CGI::escapeHTML( $mail_or_url );
	$body = CGI::escapeHTML( $body );

	$body =~ s/\r?\n/<br>/gsm;

	my $name_tmp = $name;
	if ($mail_or_url =~ /^http:\/\/$URLCHARS+$/) {
	    $name_tmp = qq(<a href="$mail_or_url">$name</a>);
	}

	$latest_id++;
	$com_hash{$latest_id}{n} = $name_tmp;
	$com_hash{$latest_id}{m} = $body;
	$com_hash{$latest_id}{d} = $what_time_is_it_now;

	write_to_logfile();	# ログファイルへの書き込み
	write_to_jsfile($fn_pref.".js"); # JavaScript Feed ファイルへの書き込み
	write_to_adminlogfile(); # 管理者用ログファイルへの書き込み
    }
}

### 表示
for (my $i = $latest_id; $i >= 0; $i--) {
    next unless defined $com_hash{$i};
    $comments .= make_comment_html($com_hash{$i}, $i + 1);
}

eval qq(\$page_html = << "FFF"\n$page_template_default\nFFF\n);
print $page_html;
exit;

#----------------------------------------------------------------------

sub error {
    my ($str) = @_;
    print <<EOF;
<html><head><title>Internal Server Error</title></head>
<body>
<h1>Internal Server Error</h1>
<pre>
$str
</pre>
<p><a href="javascript:history.back()">[Back]</a></p>
</body>
</html>
EOF
    exit;
}

### ファイルを読む
sub read_file {
    my ($fn, $strp) = @_;
#    if (-e $fn and -s $fn != 0) {
    if (-e $fn) {
	open(F, $fn) or die "can't open $fn : $!\n";
	$$strp = join('', <F>);
	close(F);
    }
}

### ファイルをセーブ
sub save_file {
    my ($fn, $strp) = @_;
    open(F, "> $fn") or die "can't open $fn : $!\n";
    flock(F, 2);
    print F $$strp;
    close F;
}

### コメントログファイルを解析し、各コメントごとに hash に格納する。
sub set_comment_hash {
    my ($hashp, $allp) = @_;
    foreach (split(/\r?\n/, $$allp)) {
	if (/^([nmd])\[(\d+)\] = "(.*?)";$/) {
	    $hashp->{$2}{$1} = $3;
	    $latest_id = $2 if ($latest_id < $2);
	}
    }
}


### コメント出力用 HTML を作る。
sub make_comment_html {
    my ($commentp, $commentid) = @_;
    my $mes = $commentp->{'m'};
    #$mes = CGI::escapeHTML( $mes );
    $mes =~ s{((s?https?|ftp)://($URLCHARS+))}{<a href="$1">$1</a>}g;

    my $anchor = qq(<span class="canchor">*</span>);
    my $page_info = "";
    if (defined $commentp->{i}) {
	my $id = $commentp->{i};
	my $url = id2url($id);
	my $bbs_url = "$cgi_url?id=$id";
	$page_info = qq(<span class="page">[<a href="$url">$url</a>, 
			<a href="$bbs_url">BBS</a>]</span>);
    } else {
	$anchor = qq(<a name="$commentid" href="$cgi_url\#$commentid">
		     <span class="canchor">*</span></a>);
    }
    my $rv .= << "DAY"
<div class="acomment">
<div class="commentator">
$anchor
<span class="commentator">$$commentp{'n'}</span>
<span class="commenttime">$$commentp{'d'}</span>
$page_info
</div>
<p>$mes</p>
</div>
DAY
    ;
    return $rv;
}

### ログファイルへの書き込み
sub write_to_logfile {
    my $fn = "$fn_pref.log";
    my $str;
    foreach (sort {$a <=> $b} keys %com_hash) {
	$str .= qq(n[$_] = "$com_hash{$_}{n}";\nm[$_] = "$com_hash{$_}{m}";
d[$_] = "$com_hash{$_}{d}";\n);
    }
    save_file($fn, \$str);
}


### JavaScript Feed ファイルへの書き込み
sub write_to_jsfile {
    my ($jsfn) = @_;
#    my $jsfn = "$fn_pref.js";
    my $str = "";
    my $cnt = $kb_js_display_max;
    for (my $i = $latest_id; $i >= 0; $i--) {
	next unless defined $com_hash{$i};

	my ($n,$m,$d)  = ($com_hash{$i}{n},$com_hash{$i}{m},$com_hash{$i}{d});
	$n =~ s/^(.{1000}).*$/$1/;
	$m =~ s/<br>//ig;	# 改行タグは削除

	$n =~ s/\\/\\\\/g;
	$m =~ s/\\/\\\\/g;

	$n =~ s/\'/\\'/g;
	$m =~ s/\'/\\'/g;

	# 文字多いときの末尾カット - charsetにより問題あるかも
	if ($m =~ s/^(([\x80-\xff].|[\x00-\x7f]){$kb_js_strlen_max}).*$/$1/) {
	    $m =~ s/((s?https?|ftp):\/\/$URLCHARS+)$/$2/;
	    $m .= "...";
	}
	# URL to anchor
	$m =~ s/((s?https?|ftp):\/\/$URLCHARS+)/<a href="$1">$1<\/a>/ig;

	my $commentid = $i + 1;

	$str .= << "JS";
document.writeln('<p><span class="canchor"><a href="$cgi_url#$commentid">_</a></span>');
document.writeln('<span class="commentator">$n</span>');
document.writeln(' [$m]</p>');
JS
    ;

	$cnt--;
	last if ($cnt <= 0);
    }
    if ((keys %com_hash) > $kb_js_display_max) {
	$str .= << "JS";
document.writeln('<p><span class="canchor">_</span>');
document.writeln('<span class="commentator">...</span></p>');
JS
    ;
    }

    save_file($jsfn, \$str);
}


### 管理者用ログファイルへの書き込み
sub write_to_adminlogfile {
    my $str = "remote_host: ". $q->remote_host(). "\n";
    $str .= "id: $logid\n";
    $str .= "mail or url: $mail_or_url\n";
    $str .= << "ADD";		# 追加内容
n[$latest_id] = "$name";
m[$latest_id] = "$body";
d[$latest_id] = "$what_time_is_it_now";

ADD
    ;
    open(F, ">> $admin_log_file") or die "can't open $admin_log_file : $!\n";
    flock(F, 2);
    print F $str;
    close(F);
}


sub get_latest_list {
    my @fl = <$log_dir/*.log>;
    my @lalist;
    my $spam_regex = join( '|', map { quotemeta($_) } split( /\n/, $SPAM_BLACKLIST_WORDS ) );
    print STDERR $spam_regex;
    foreach my $f (@fl) {
	open(F, $f) or die "$! $f";
	next if (-s $f == 0);
	my $all = join('', <F>);
	my %hash;
	my ($id) = ($f =~ /([^\/]+)\.log$/);
	set_comment_hash(\%hash, \$all);
	foreach my $i (keys %hash) {
	    # next if $hash{$i}{'m'} =~ /(\b|\s)($spam_regex)(\b|\s)/mio;
	    push @lalist, {d => $hash{$i}{'d'}, m => $hash{$i}{'m'},
			   n => $hash{$i}{'n'}, i => $id,
			   ii => $i,
			  };
	}
	my $last = $latest_comment_display_num - 1;
	$last = $#lalist if $last > $#lalist;
	@lalist = (sort {$b->{d} cmp $a->{d}}
		   @lalist)[0..$last];
    }
    return @lalist;
}

### 最近投稿されたコメントを表示
sub output_latest {
    my @lalist = get_latest_list();
    foreach my $i (@lalist) {
	last if $i eq "";
	$comments .= make_comment_html($i, 0);
    }

    $cgi_url .= "?mode=latest";

    eval qq(\$page_html = << "FFF"\n$page_template_latest\nFFF\n);
    print $page_html;
    exit;
}
sub output_latest_rss {
    my @lalist = get_latest_list();
    $cgi_url .= "?mode=latest";

    my $mtime = (stat($admin_log_file))[9];
    my $date = strftime("%y-%m-%dT%h:%M:%sZ", gmtime($mtime));
    print <<RSS;
<?xml version="1.0" encoding="$charset"?>
<rdf:RDF
 xmlns="http://purl.org/rss/1.0/"
 xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
 xmlns:dc="http://purl.org/dc/elements/1.1/"
 xmlns:content="http://purl.org/rss/1.0/modules/content/"
 xmlns:admin="http://webns.net/mvcb/"
 xml:lang="ja">
<channel rdf:about="$cgi_url">
 <title>Kuttuki BBS</title>
 <link>$cgi_url</link>
 <description>Kuttuki BBS</description>
 <dc:language>ja</dc:language>
 <dc:date>$date</dc:date>
 <admin:generatorAgent rdf:resource="kuttukibbs"/>
 <items>
 <rdf:Seq>
RSS
    foreach my $item (@lalist) {
	my $commentid = $item->{ii};
	my $url = $q->url() ."?id=". $item->{i} ."#". $commentid;
	print qq{  <rdf:li rdf:resource="$url"/>\n};
    }
    print <<RSS;
 </rdf:Seq>
 </items>
</channel>
RSS
    foreach my $item (@lalist) {
	my $commentid = $item->{ii};
	my $url = $q->url() ."?id=". $item->{i} ."#". $commentid;
	my $cont = $item->{m};
	$cont =~ s/<br>/\n/g;
	my $name = $item->{n};
	my $time = $item->{d};
	print <<RSS;
<item rdf:about="$url">
 <link>$url</link>
 <description>$cont</description>
 <dc:creator>$name</dc:creator>
 <dc:date>$time</dc:date>
</item>
RSS
    }
    print <<RSS;
</rdf:RDF>
RSS
    exit;
}
