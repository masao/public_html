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
Ab fab
Abslueotly
Absoltuely
All of my questions
All posts of this
Always a good job
Arictles
Aritcels
Aritecls
Articles like
Articles like this
Awemsoe
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
Do you know the address
Dude
Essays like this
Excellent!
Excleelnt
Execlelnt
Exelcenlt
Facebook page
Fell out of bed
Fidnnig
Fidnnig
Filanly
Free movies
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
Hats off
Hey hey hey
Ho ho
Holy Toledo
Holy concise
Hot damn
How neat
I am forever
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
I must confess
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
Kamagra
Keep on writing
Klonopin
Kudos to you
Kudos!
Learning a ton
Life is short
Lol thank
Lol thanks
Lol!
Lorazepam
Many many quality
Mighty useful
More power to you
Nature is spiritual
Never would have thunk
Nice posting
Ninja Turtle
No complaints
Noralmly
Norlmaly
Not bad at all
Not the usual
POV videos
Party girls
Phsiycs
Plasneig
Play informative
Porn
Posts like this
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
Superb
Superb information
Superbly illuminating
Supieror
Thank God
Thanks alot
Thanks for contributing
Thanks for contributing
Thanks for hanging out
Thanks for helping me
Thanks for posting
Thanks for setting me
Thanks for sharing
Thanks for starting
Thanks for taking the time
Thanks for the answer
Thanks for the insight
Thanks for the news
Thanks for writing
Thanks guys
Thanks!
Thanks!
Thanky
That insight
That saves me.
There are no words
There is a critical shortage
Thgouht
Thinking like that
This article achieved
This has made my day
This information is off
This is what we need
This makes everything
Threesomes
Tip top
Tramadol
Transsexuals
Unparalleled accuracy
Unrpaalleled
Very true
Very valid
Viagra
View my complete
WINNING!
Way to go on
Welcome to the debate
Well done
Well put
What a joy
What a joy to find someone
What a pleasure
Wheevor
Which came first
Whoa, whoa
Woah nelly
Wow! Great
You know what
You make things
You really found
You saved me
You've hit the ball
Your answer
Your answer lifts
Your cranium
Your post
a lot easier from here
abiilty
ability to think
absoelutly
accraute
accucray
achieevd
actulaly
addictive
aenswr
aenwsr
aesnwr
aewomse
after reading this
aftrneoon
airclte
airltce
airtcle
airtlce
airtlces
alhrgit
all my problems
allows free info like this
amainzg
ambien
amlsot
amnout
an expert
aneswr
anewsr
ansewr
answeerd
answer from
answreed
anwesr
anwser
apeapr
aplpes
appaer
apprceiaiton
apprceita
apprcieate
apprecaite
apprecitaion
approcah
aprepciate
aprpecaition
aprpeication
arcitles
arctile
arctlie
aricetls
arictles
arirevd
aritcle
aritelcs
aritelcs
aritlce
aritlces
arltices
arrtcile
artciels
artciles
artclie
arteilcs
article perfectly
article up
artiecls
artlcie
artlcies
artlice
arvried
asenwr
asewnr
ask her to call me
aslbuotely
asnewr
asnwer
astute
aswenr
asweome
aswner
atcriles
atilrce
atircle
atircles
ativan
atlrice
atnyhing
atrcile
atrciles
atricels
atricle
atrilce
atrilecs
atrlcie
aucrcate
avdice
awalys
awnesr
awnser
awsemoe
awsenr
awsner
aymnroe
aynthing
back from the keyboard
bareable
bceasue
bdoaciuos
be happy
beacsue
beaten us
beenfit
beenift
beettr
beilvee
betsest
betsset
better than a brick
beucase
beucase
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
blown away
bluleyse
bocdiauos
bodacoius
boom boom
boom boom
borhetr
bortehr
borther
brain power
bravo!
brhoetr
brightened my day
brilalint
brinas
brings light into
brliialnt
brngis
bseetst
bsetest
bsetset
btesset
bteter
btorher
btteer
bullsyee
buy online
buy these articles
cahnge
cahnigng
call you back
calling up people
carnuim
catpeurs
ceelvr
cehered
cehreed
celared
celevr
celver
cevelr
cevler
cgahne
cgwho
chganing
chlalengnig
chugging away
cialis
ciclked
cilcked
cimnog
claered
cleared it up
cleared my thoughts
cleared the air
cleevr
clerlay
clever 4
clever by half
clever way
clips
cloudn't
clveer
cmiong
cmmoon
cmnoig
cmomnuicated
cmonig
cnfoused
cnocout
cnocrens
cnofuesd
cnomig
cnortuibting
cnotribtiuon
cofneusd
coimng
come up with that
come up with the
comlpicaetd
completely painless
compliatns
compuetr
coniesdred
conmig
connviced
consfuing
contriutbing
convoulted
cool models
cool thinking
cool way
cotnributing
cotnributnig
couldn't pay me to
crackerjack
crateive
creative answer
creative mind
creiavte
crietanly
crystal clear
cteairnly
cunning
cveler
cvleer
cvoreed
dazlznig
dbetae
dcotor
deabte
debtae
deep thinker
deep thinking
defiinetly
demnsortated
detbae
dicattor
difficult question
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
eestemed
eevryhwere
eevrynoe
eevrywhree
effrot
eiasly
eisaer
end of the line
enetrtaniing
enthlraling
enthralling
enuogh
eognuh
epxcet
epxlain
epxuonder
erdutioin
erudition
esaeir
esaier
esaliy
esbtalishment
eseair
esesntial
esestnial
esteeemd
estemeed
etinrely
etneilry
etxcied
eungoh
eunogh
evertyihng
everynoe
eveyrewhre
evryeday
exact point
excatly
excleelnt
exclelnet
exelclent
exetrmely
exlceelnt
expeictng
expert advice
expert answer
expertise answers
expetcnig
exptceing
exrpet
exrtmeely
extermely
fabluous
facts available here
failnly
falbberagsting
fathom
fbauolus
fblauuos
fbualous
feeilng
feel satisfied
feel stupid
feelnig
fgiruing
fianlly
filnlay
finally found
fioricet
firgue
first class post
first rate
fiurgnig
fnially
foloish
for years without
for years without knowing
foveerr
fucking
gareetst
garetest
garetufl
gatrfuel
gdnaer
geaertst
geartest
genius store
gertaest
get paid
get this info
get this online
getnleemn
getraset
getting that know-how
gettnig
geunienly
giinvg
giivng
give it a shot
gneetlmen
going for years
going to talk to
goldoy
golody
good enough
good many
good piece
good stuff
good to be true
good to find
good to find someone
good to know
good to see
gooldy
gooooaol
goooooal
got it in one
goto expert
graeetst
graetset
grateest
grateful you
greaestt
greaetnss
greaetst
great aritcels
great info
great internet
great minds
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
hate my life
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
help articles
help tons
helpful article
helpful articles
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
hleepd
hlefpul
hleipng
hlepful
hlepnig
hlepufl
hlpeed
hlpeufl
hnosety
home run
hooilgnas
hoolaigns
hoolignas
hot ass
how awesome
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
ifnormatoin
ifnrmoatoin
ifnromative
ifrnomation
ignronat
ignsiht
iinsght
illuimnating
illuminating data
illumniaitng
ilncined
ilulmintaing
imemdiately
immedaeitly
immedaitely
imperssing
impesrsed
imporatnt
impressing me!
impressive answer
imprseesd
impsresed
imrpessive
imrpseesd
imrpsesed
in the same forum
increbdile
incredilbe
indebted
indispeansble
inetllgicene
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
inishgt
inofmratvie
inofmrtaion
inoframtion
inoframtoin
inoframtvie
inofrmtaion
inorfmative
inrcedblie
insghit
insgiht
insgihts
inteernt
inteillegnt
intelliegcne
intelligent answer
intelligent point
intellignece
interesntig
internet hooligans
internet writer
intreent
intrenet
ipmeraivte
ipmossbile
iprmesesd
is power
isinght
isinght
isndie
isnihgt
it all makes sense
job description
job on that
just about right
just like these articles
just logic
just read this
kbaoom
kbeyoard
keep coming
keep on reading
keep them
keep writing
keyaobrd
keybroad
kind of knowledge
kliler
knlowedge
knolwdege
know everything
knowledge in this article
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
levitra
liebrty
like a classroom
like yourself
litlte
lkonoig
lkooing
logic set out
loikong
loiokn
lokinog
lokion
lokion
lokiong
loknoig
lokoed
lokonig
lolita
lolitas
lonoikg
lonokig
looikn
looikng
looinkg
look promising
looking for your posts
looknig
loonikg
loonkig
lot easier
love of God
maacadmia
maagned
macadmaia
macamdaia
made my day
magnaed
mainkg
mangaed
marvelously good
mcaaadmia
mcaadmaia
mcadaamia
mcdaaamia
mdniight
miknag
million thanks
minteus
mintue
mituens
miuents
mknaig
mnitue
mold-breaker
monoploy
more clever
more from this article
mortar establishment
movie clips
mttear
munties
music armed
my ignorance
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
off the list
onnlie
paajmas
paamjas
padrenr
pay me to ignore
pefrect
pefrtecly
pelaesd
pelasrue
pelasure
pelsaure
penis
people like you
pepyaka
perecft
perfcet
perfect insight
perfect reply
perfect way
pertty
pharmacies
pianelss
pills
piotns
pjaaams
pjamaas
plainyg
pleasure to read
pleausre
pleausre
plesead
plesuare
plsaeed
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
posting shines
potinsg
potsing
potsings
potsnig
powerfully helpful
ppoped
pragmatisdc
prbloem
prbloems
prboemls
prbolmes
preescne
preteen
probelm
probelms
problem solved
probmels
prodigious writers
proelbm
prolebm
prolebm
propecia
prseence
prsoen
psoitng
psosilby
psoting
psoting!
psotnig
pttunig
purhcseas
pussy
pussy
put aside a whole afternoon
put it better
put this to good use
pwoerufl
pworeful
qaulity
qeustion
qeustions
qeustoin
qlaiuty
qluaity
queistnos
queiston
questnios
quetsion
quetsoin
qulatiy
quseiotns
quseitons
qusetions
qusetoins
qusoetin
raeding
raeidng
raelly
ralely
ralley
rational answer
rceokn
reading this
readnig
reaindg
real intelligence
really appreciate
really cool way of
really helped
really informative
really neat
really raised
reemmber
reevlation
refsrehing
reiandg
relaible
relaly
reliable data like this
reliable information
relilabe
rellay
reocgniezd
reockn
replica watches
rescoure
resorcue
respect from me
revleatoin
ritaonal
rlaely
rlealy
rlelay
rlieef
rlolnig
rmemeber
rnuning
rnunnig
roesurce
roilnlg
rotten egg
rpseect
rquereis
rseocrue
rseoucre
rsourece
rtoetn
ruinnng out
s***
saecrehd
sahring
sarhing
satifsied
satirntg
satsifeid
save me time
saved me
saved us
sbulmie
sceert
sceret
screet
scucinct
searhced
searhced
sebnsile
seecrt
semlls
semoone
senisble
sensible answer
sensilbe
seomnoe
seotmhing
sepkas
serached
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
simlpy
siplme
skillful answer
skopoy
slainet
slemls
slhuod
slick answer
slkilful
slohud
sluaghetred
smart and intelligent
smart thinking
smart way of
smeoone
smoehntig
smoenoe
smoeone
smoething
smoethnig
smoneoe
smooene
smoonee
snseible
snushnie
so awesome
so much learning
so much simpler
so straightforward
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
solves a problem
somenoe
someone comes up with
someone who thinks
something I agree
something like that
somethnig
sometnhig
sometnihg
somneoe
somoene
somonee
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
swrhed
taelnt
tahknful
tahkns
tahnks
taikng
tailkng
take the next step
taknhs
talnikg
tanhks
tanlet
tarpnsaretnly
tckiet
tcriky
tealnt
tehard
ternchant
terrfiic
terrific amount
tghins
thakns
thank you enough
thank you for this
thank you humbly
thanks for he answer
thanks for posting
thanks to your post
thanks to your posts
thanks y'all
thanukfl
that posting
that really helped
the tikcet
there you
thgins
thgnis
thguhot
thienkr
thigns
thiiknng
thiinkng
thiinnkg
thikinng
thikning
thiknnig
thinikng
thininkg
think like that
thinking demonstrated
thinknig
thinks this way
thinnikg
this article saved
this helped me
this is so cool
this kind of stuff
this makes it understandable
this post hits
thkanufl
thkinnig
thkninig
thnaks
thngis
thnigs
thniikng
thniinkg
thniknig
thninikg
thninkig
thnkaful
thnkas
thnkiing
thoghut
thohugt
throguh
thuoght
thurogh
tiakng
ticrky
tieckt
tihgns
tihiknng
tihkning
tihngs
tihnking
tihnknig
tihnnkig
time is money
time to contribute
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
tnahkufl
tnakhs
tnghis
tnhaks
tnhgis
tnhiinkg
tnhiknig
tnhkiing
tnihikng
to the point
tocpis
tohguht
tohguhts
tohrugh
tohuhgt
toltaly
tons of links
too good
top of the game
topic-bravo
touchdown
touhght
transaprnetly
trehncant
trencahnt
trenchant
tricky question
trikcy
trkicy
true I guess
truly appreciate
ttoally
tuhoght
tuhohgt
tuohhgt
turthflluy
type of insight
ubneilevblae
udnersatnd
udnesrtand
uefsul
ufseul
uiltzie
unbelieavlbe
undeniable importance
understand the issues
undsretnad
unebilevable
unebilevbale
unedrtsadning
unrdetsanding
useufl
usfeul
valaulbes
valbulaes
valium
valubaels
vauallbes
very helpful
virgins
vlauables
voyeur
vuallabe
waiting for
wanetd
want to get read
was looking everywhere
watching for your posts
way more helpful
way of thinking about
way to kick
weathlier
web20power
webiste
weeeknd
well-written
well-wrtiten
what I need
what I needed
what I was needed
what a quick and easy
what info I want
what the dotcor ordered
what we need
what's up
where to buy
where to find this info
who you wrote this
wirter
witohut
witring
wndeoring
wnodernig
wnodreing
wnordenig
wodnernig
wodnreing
wohrty
woke up down
wondreing
wonedrnig
wothry
wrierts
wrinitg
wrintig
write for me
write more
writing this topic
writnig
wrtiing
wrtinig
wrtiten
wrtohy
wrttien
wsebites
wthuiot
wtiring
wtriing
wuodla
wvoheer
xanax
xxx
you are quite
you helped
you struck us
your answer solved
your post makes mine
your posting
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
	@spam = ($body =~ /(^|\b|\s)($spam_regex)(\b|\s|$)/gmio);
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
	@spam = ($body =~ /ｗｗｗｗｗ|熟女|人妻/gmoi);
	error("禁止された語句が含まれています。\nYour comment contains one or more stop words, such as 'cool','funny' etc.") if scalar(@spam) > 0;

	# 特定のURLを禁止
	@spam = ($body =~ /\bhttps?:\/\/(\w+\.)?google\.(com|us|jp)\/group\/\w?\w?(ticket|teens)/gmoi);
	error("禁止されたURLが含まれています。\nYour comment contains a spamming URL.") if scalar(@spam) > 0;
	@spam = ($body =~ /\bhttps?:\/\/(ylm\.me|jtgvrqveco\.com|fastcashloans\.tv|(jn|www)\.l7i7\.com|\w+\.lefora\.com|\w+\.blog\.free\.fr|\w+\.de\.tl)/gmoi);
	error("禁止されたURLが含まれています。\nYour comment contains a spamming URL.") if scalar(@spam) > 0;

	# 特定のアドレスからの投稿を禁止
	error("禁止されたアドレス/URLが含まれています。\nYour comment contains a spamming E-mail address/URL.") if $mail_or_url eq 'maxhamehame@livedoor.com';
	error("禁止されたアドレス/URLが含まれています。\nYour comment contains a spamming E-mail address/URL.") if $mail_or_url eq 'mail';
	error("禁止されたアドレス/URLが含まれています。\nYour comment contains a spamming E-mail address/URL.") if $mail_or_url eq 'email@gmail.com';

	# 特定のホストからの投稿を禁止
	error("禁止されたホストからの投稿です。\nYour host has been blocked as a spamming server.") if $q->remote_host() =~ /(giga-dns\.com|localmatchmakerservices\.com|hostkey\.ru|quadranet\.com|comcast\.net|xsserver\.eu|bergdorf-group\.com|\.kimsufi\.com)$/o;
	error("禁止されたホストからの投稿です。\nYour host has been blocked as a spamming server.") if $q->remote_host() =~ /^(208\.53\.158\.241|68\.169\.86\.22.|199\.19\.104\.197|68\.169\.80\.\d+)$/o;

	# 特定の氏名による投稿を禁止
	@spam = ($body =~ /(^|\b|\s)($spam_regex)(\b|\s|$)/gmio);
	error("禁止された語句が含まれています。\nYour name contains one or more stop words, such as 'cool','funny' etc.") if scalar(@spam) > 0;

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
