#!/usr/local/bin/ruby
# $Id$

# bsfilter は Paul Graham メソッドでない場合は、
# スパム確率に寄与したトークンをうまく出力しないので自前で…。

def bsfilter_probs(fname)
   probs = {}
   IO.popen("bsfilter -d #{fname}") do |io|
      data = io.readlines
      if data.size > 0
         probs["all"] = data.pop.split[4].to_f
         probs["word"] = data.find_all{|e|
            /^word probability\s/ =~ e
         }.map{|e|
            e.split[2..-1]
         }.sort{|a,b|
            (0.5 - b[-1].to_f).abs - (0.5 - a[-1].to_f).abs
         }
      else
         probs = nil
      end
   end
   probs
end

if $0 == __FILE__
   require 'getopts'
   getopts("m:", "max:")
   max = 20
   max = ($OPT_m or $OPT_max).to_i if $OPT_m or $OPT_max
   ARGV.each do |f|
      prob = bsfilter_probs(f)
      puts prob["word"][0..max-1].map{|e| e.join(" ") }
      puts "%.06f" % prob["all"]
   end
end
