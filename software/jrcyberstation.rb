#!/usr/bin/env ruby
# $Id$

# http://www1.jr.cyberstation.ne.jp/csws/Vacancy.do
#
# month=12&day=31&hour=06&minute=30&train=1&dep_stn=%93%8C%8B%9E&arr_stn=%95%9F%8ER&dep_stnpb=4000&arr_stnpb=6220&script=1
# month=08&day=13&hour=06&minute=30&train=3&dep_stn=%91%E5%8B%7B&arr_stn=%90V%89%D4%8A%AA&dep_stnpb=4320&arr_stnpb=2145&stn=4320&stn=2145&script=1

#require "open-uri"

$KCODE = "s"

TOPURL = "http://www.jr.cyberstation.ne.jp/vacancy/Vacancy.html"
URL = "http://www1.jr.cyberstation.ne.jp/csws/Vacancy.do"
#POSTDATA = "month=8&day=13&hour=06&minute=30&train=1&dep_stn=%93%8C%8B%9E&arr_stn=%95%9F%8ER&dep_stnpb=4000&arr_stnpb=6220&script=1"
POSTDATA="month=08&day=13&hour=06&minute=30&train=3&dep_stn=%91%E5%8B%7B&arr_stn=%90V%89%D4%8A%AA&dep_stnpb=4320&arr_stnpb=2145&stn=4320&stn=2145&script=1"

system("curl -s -X POST -e #{TOPURL} -d '#{POSTDATA}' #{URL} > z.jr")
content = open("z.jr"){|io| io.read }

vacant = content.scan(%r|<tr>\s*<td\s+align="left">([^<]+)</td>\s*<td\s+align="center">([\d\:]+)</td>\s*<td\s+align="center">([\d\:]+)</td>\s*<td\s+align="center">([^<]+)</td>\s*<td\s+align="center">([^<]+)</td>\s*<td\s*align="center">([^<]+)</td>\s*<td\s+align="center">([^<]+)</td>\s*</tr>|)
if vacant.find_all{|e| ( e[1] <=> "12:53" ) <= 0 }.find{|e| e[3] != "~" }
   vacant.each do |v|
      puts v.join("\t")
   end
end
