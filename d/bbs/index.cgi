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
Apaperntl
Arceilts
Arcetlis
Arciltes
Arictles
Aritcels
Aritecls
Arlcites
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
Charlie Sheen
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
Grazi
Great common sense
Great hammer
Great posintg
Great stuff
Great work
Halleulajh
Halullejah
Hats off
Hello good day
Hey hey hey
Ho ho
Holy Toledo
Holy Toodle
Holy Tooeld
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
Inisgths
Inshgits
Insights like this
It was dark
It's great to read
Kamagra
Keep on writing
Kick the tires
Klonopin
Knowledge wants to be free
Knowledge wants to be free
Kudos and such
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
Quotes Chimp
QuotesChimp
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
Stolen credit card
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
Thkans
Threesomes
Tip top
Toodel
Tramadol
Transsexuals
Truly appreciated
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
Wheoevr
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
Your honesty
Your post
a lot easier from here
abiilty
ability to think
absoelutly
accraute
accucray
accutane insurance
achieevd
actulaly
acveehid
addictive
addsreses
aenswr
aenwsr
aesnwr
aewomse
afronteon
after reading this
aftrneoon
airclte
airltce
airtcle
airtlce
airtlces
aitcon
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
anwers
anwesr
anwrse
anwser
apeapr
aplpes
apopeciatirn
apopnciatire
appaer
apporcah
apprceiaiton
apprceita
apprcieate
apprecaite
apprecitaion
approcah
aprepciate
aprpecaition
aprpeication
arcielt
arcielts
arcitles
arcleits
arcteils
arcteils
arctile
arctlie
arectlis
aricetls
arictles
arirevd
aritcle
aritelcs
aritelcs
aritlce
aritlces
arlcites
arlictes
arltices
army knife
arrtcile
artciels
artciles
artclie
artecli
arteilcs
article perfectly
article up
artiecls
artielcs
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
at a high level
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
auto insurance
avdice
awalys
awnesr
awnser
awsemoe
awsenr
awsner
aymnroe
aynthing
baceon
baceon
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
beitang
best content
bestest
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
brhgetined
brhoetr
brightened my day
brilalint
brinas
brings light into
brliialnt
brlnliait
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
buyllese
cahnge
cahnigng
call you back
calling up people
carnuim
catpeurs
cedrit
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
chgilenalng
chlalengnig
chlnaelging
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
clever answer
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
cnofused
cnomig
cnortuibting
cnotbirution
cnotribtiuon
cocinvned
coeedqrnu
coeequrnd
cofneusd
cofuesnd
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
crceakrjcak
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
diceovsry
difficult question
dificfult
dilaspy
direcvosy
doctor ordered
doing so much
doors for me
drugs and
drvier
easei
easily impressed
easy to understand
easy-to-understand article
ecletronic
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
engouh
engouh
enthlraling
enthralling
enuogh
eognuh
epxcet
epxlain
epxuonder
erdiiuton
erdutioin
eriotiudn
erudiotin
erudition
esaeir
esaier
esaliy
esbtalishment
eseair
esesntial
esestnial
essetnails
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
evherwreye
evryeday
exact point
excatly
excleelnt
exclelnet
exelclent
exeretisp
exetrmely
exlceelnt
expeictng
expert advice
expert answer
expertise answers
expetcnig
exptceing
exrept
exrept
exrept answer
exrpet
exrstpiee
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
figure this out
filnlay
finally found
find someone
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
grtesneas
grtesneas
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
heledp
helfpul
hella easy
helnpig
help articles
help tons
helpful answers
helpful article
helpful articles
helpful information
helping me out
helps me
helupfl
hepeld
hepilng
hepled
heplful
heplnig
high brow literature
high level
hit the ball
hizool
hleepd
hlefpul
hleipng
hlepful
hlepnig
hlepufl
hlpeed
hlpeful
hlpeufl
hnosety
hnotesy
hoeplses
hoestny
home run
hooilgnas
hoolaigns
hoolignas
hot ass
hotnsey
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
ietrnnet
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
imsirspeve
in the same forum
increbdile
incredilbe
indebted
indispeansble
ineelligtnce
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
inigths
inisght
inisghts
inishgt
inmoofatirn
inofmratvie
inofmred
inofmrtaion
inoframtion
inoframtoin
inoframtvie
inofrmtaion
inonmratifo
inorfmative
inrcedblie
inrtneet
insghit
insgiht
insgihts
inshigt
insurance policy
inteernt
inteillegnt
intelliegcne
intelligent answer
intelligent point
intellignece
interesntig
interesting question
interetsing
internet hooligans
internet writer
intmorafive
intreent
intrenet
ipmeraivte
ipmossbile
iprmesesd
is power
isinght
isinght
isndie
isngiht
isngihts
isnihgt
isnihgts
isuess
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
knogeldwe
knolwdege
know everything
knowgedle
knowledge in this article
knwlodege
knwloedge
knwodlege
knwoeldge
knwolegde
knwonig
konlwedge
konlwegde
konwdlege
kownledge
kyeborad
laoedd
lcoekd
learn a lot
levitra
liebrty
like a classroom
like to pay
like yourself
litlte
lkonoig
lkooing
lkoonig
logic set out
loikong
loinokg
loiokn
lokinog
lokion
lokion
lokiong
loknoig
lokoed
lokonig
loli
lolicon
lolita
lolita
lolitas
lonikog
lonoikg
lonokig
looikn
looikng
looinkg
look promising
looking for answers
looking for your posts
looknig
loonikg
loonkig
lot easier
love of God
love this site
ltilte
maaacdmia
maacadmia
maagned
macadmaia
macamdaia
made my day
magnaed
mainkg
makes you think
maknig
mamdaacia
mangaed
marvelously good
mcaaadmia
mcaadmaia
mcadaamia
mcdaaamia
mdniight
meh--tat
miknag
million thanks
minteus
mintue
mituens
miuents
mknaig
mnitue
mnueits
mnueits
mold-breaker
monoploy
monopoly
more clever
more from this article
mortar establishment
most useful
movie clips
mttear
munties
music armed
my ignorance
my problem
naked
nbaibt
nciley
ncliey
ncliey
ndeeed
neat articles
nedeed
needde
neeedd
nelicy
never find this
never happened
nggoin
nice work!
nicely put
nielcy
nilcey
none can doubt
noramlly
nothnig
ntoihng
oenped
oervview
off the list
online house
online india
onnlie
orreded
out of credit
paajmas
paamjas
padrenr
paid weekly
pajaams
pajmaas
pay me to ignore
pborlem
pcuarhses
pecerft
pecfert
pecfret
pecreft
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
personal insurance
personal loans
pertty
petlecrfy
pharmacies
pianelss
pills
pinots
pinots
piotns
pjaaams
pjamaas
plainyg
plaserue
plaserue
pleasure to read
pleausre
pleausre
plesead
plesuare
plsaeed
pnapoly
pobrmles
poeuwrfl
ponits
porbelm
porlbem
porlebm
porlebms
pormiisng
porn company
portmoe
posntig
posntigs
possbily
possbliy
posting shines
potinsg
potnisg
potnisg
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
private insurance
prlbeoms
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
pstoing
pttunig
purcsahes
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
qsuetion
queistnos
queiston
quesiotn
questnios
quetoisn
quetsion
quetsoin
quieston
qulatiy
quseiotns
quseitons
qusetions
qusetoins
qusoetin
qusotien
quteisons
raeding
raeidng
raelly
raitnoaltiy
ralely
ralley
ratiaonl
rational answer
ratnoial
ratnoial
rceokn
reading this
readnig
reaindg
real intelligence
really appreciate
really captured
really confused
really cool way of
really great
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
relbaile
reliable data like this
reliable information
relief of finding
relilabe
rellay
reocgniezd
reockn
replica watches
rescoure
resorcue
resoruce
respect from me
retin
revleatoin
ritaonal
rlaely
rlealy
rlelay
rlieef
rlloing
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
rtoten
ruinnng out
s***
saecrehd
saercehd
sahring
saihrng
sarhing
sasftiied
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
seomone
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
shafts
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
shrewd answer
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
smiple
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
so clearly
so much learning
so much simpler
so straightforward
so well
socks off
socrue
sodnus
soelvd
soenome
soeomne
soeonme
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
soneome
sonhteimg
sonmoee
sonoeme
sooemne
sopkoy
sort things
sotehming
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
srtcuk
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
suprrised
surprsied
susnnhie
susrpired
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
taotlly
tarpnsaretnly
tceikt
tceikt
tckiet
tcriky
tealnt
tehard
ternchant
terrfiic
terribly
terrific amount
tghins
thakns
thaknufl
thaknufl
thank you enough
thank you for posting
thank you for this
thank you humbly
thankity
thanks for he answer
thanks for posting
thanks to this article
thanks to your post
thanks to your posts
thanks y'all
thanukfl
that posting
that really helped
the tikcet
there you
thghout
thgins
thgnis
thgnkini
thguhot
thienkr
thignikn
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
this was the best
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
thnkinig
thnkinig
thnkniig
thnnikig
thoghut
thoguht
thohugt
throguh
thugoht
thuhgots
thuoght
thurogh
tiakng
ticrky
tieckt
tihgns
tihiknng
tihkning
tihknnig
tihngs
tihnking
tihnknig
tihnnkig
tikect
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
too tricky
top of the game
topic-bravo
touchdown
touhght
transaprnetly
trciky
trehncant
trencahnt
trenchant
tricky question
trikcy
trkicy
trnsapraenlty
trplnaarestny
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
ufesul
ufseul
uiltzie
unbeeliavble
unbelieavlbe
undeniable importance
understand the issues
undsaetrndable
undsretnad
unebilevable
unebilevbale
unedrtsadning
uneirstanddng
unrdetsanding
unrsnetadd
useufl
usfeul
valaulbes
valbulaes
valium
valuable brains
valubaels
vauallbes
vehicle insurance
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
wehlttlough
well spent
well spent
well-written
well-wrtiten
wetntwri
what I need
what I needed
what I was looking for
what I was needed
what a quick and easy
what info I want
what the dotcor ordered
what we need
what you write
what's up
where to buy
where to find this info
whevoer
who you wrote this
whoeevr
wirter
witohut
witring
wndeoring
wndoering
wnodernig
wnodreing
wnordenig
wodnernig
wodnreing
wohrty
woke up down
wondreing
wonedrnig
wonrednig
work with computers
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
wrtniig
wrtohy
wrttien
wsebites
wthuiot
wtiring
wtriing
wtrires
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
誰損多
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
