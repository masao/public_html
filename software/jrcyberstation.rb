#!/usr/bin/env ruby
# -*- coding: cp932 -*-
# $Id$

# http://www1.jr.cyberstation.ne.jp/csws/Vacancy.do

require "kconv"
require "open-uri"
require "uri"

$KCODE = "s"

TOPURL = "http://www.jr.cyberstation.ne.jp/vacancy/Vacancy.html"
URL = "http://www1.jr.cyberstation.ne.jp/csws/Vacancy.do"

mail = nil
#mail = "takaku-masao@ezweb.ne.jp,yuka@nier.go.jp"

POSTDATA = {
   :month => 1,
   :day => 3,
   :hour => 15,
   :minute => 30,
   :dep_stn => "福山", # 乗車駅
   :arr_stn => "東京", # 降車駅
   :train => 1,	# 列車種別:
	      # 1:のぞみ・ひかり
	      # 2:こだま
	      # 3:はやて・やまびこ・なすの・つばさ・こまち
	      # 4:とき・たにがわ・あさま
	      # 5:つばめ
	      # 6:在来線列車
   :script => 1,
}
#DEP_BEFORE = "12:53"	# 出発時刻指定
DEP_BEFORE = nil
ARR_BEFORE = "19:00"		# 到着時刻指定
# ARR_BEFORE = nil

STATION_JS = "http://www.jr.cyberstation.ne.jp/vacancy/Station.js"
stn = []
stnpb = []
open( STATION_JS ) do |cont|
   cont.each do |line|
      case line
      when /^\s+\"(\d\d\d\d)\|?\"\+\s*$/# 駅番号
         stnpb.push $1
      when /^\s+\"(.*?)\|?\"\+\s*$/	# 駅名
         stn.push $1
      end
   end
end
POSTDATA[ :dep_stnpb ] = stnpb[ stn.index( POSTDATA[:dep_stn] ) ]
POSTDATA[ :arr_stnpb ] = stnpb[ stn.index( POSTDATA[:arr_stn] ) ]

postdata = POSTDATA.map{|k,v| "#{k}=#{URI.escape v.to_s}" }.join("&")
#POSTDATA = "month=8&day=13&hour=06&minute=30&train=1&dep_stn=%93%8C%8B%9E&arr_stn=%95%9F%8ER&dep_stnpb=4000&arr_stnpb=6220&script=1"
#POSTDATA="month=12&day=29&hour=06&minute=30&train=3&dep_stn=%91%E5%8B%7B&arr_stn=%90V%89%D4%8A%AA&dep_stnpb=4320&arr_stnpb=2145&stn=4320&stn=2145&script=1"
# month=12&day=29&hour=06&minute=30&train=1&dep_stn=%93%8C%8B%9E&arr_stn=%95%9F%8ER&dep_stnpb=4000&arr_stnpb=6220&script=1

system("curl -s -X POST -e #{TOPURL} -d '#{postdata}' #{URL} > z.jr")
content = open("z.jr"){|io| io.read }

vacant = content.scan(%r|<tr>\s*<td\s+align="left">([^<]+)</td>\s*<td\s+align="center">([\d\:]+)</td>\s*<td\s+align="center">([\d\:]+)</td>\s*<td\s+align="center">([^<]+)</td>\s*<td\s+align="center">([^<]+)</td>\s*<td\s*align="center">([^<]+)</td>\s*<td\s+align="center">([^<]+)</td>\s*</tr>|)
#p vacant
vacant = vacant.find_all{|e| e[1] < DEP_BEFORE } if DEP_BEFORE
vacant = vacant.find_all{|e| e[2] < ARR_BEFORE } if ARR_BEFORE
vacant = vacant.find_all{|e| e[3] != "×" }
if not vacant.empty?
   output = STDOUT
   output = open("|Mail -s 'JR Cyberstation' '#{mail}'", "w") if mail
   output.puts "#{POSTDATA[:month]}/#{POSTDATA[:day]} #{POSTDATA[:dep_stn]}-#{POSTDATA[:arr_stn]}".tojis
   vacant.each do |v|
      output.puts v.join("\t").tojis
   end
end
