#!/usr/local/bin/ruby
# $Id$

# bsfilter は Paul Graham メソッドでない場合は、
# スパム確率に寄与したトークンをうまく出力しないので自前で…。

require 'getopts'

$max = 20

getopts("m:", "max:")
if $OPT_m or $OPT_max
   $max = ($OPT_m or $OPT_max).to_i
end

ARGV.each do |f|
   IO.popen("bsfilter -d #{f}") do |io|
      data = io.readlines
      if data.size > 0
	 data.collect{|e|
	    e.split
	 }.find_all{|e|
	    e[5]
	 }.sort{|a,b|
	    (0.5 - b[5].to_f).abs - (0.5 - a[5].to_f).abs
	 }[0..$max-1].each{|e|
	    puts e.join(" ")
	 }
	 puts data[-1]
      end
   end
end
