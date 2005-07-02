#!/usr/local/bin/ruby
# $Id$

# bsfilter �� Paul Graham �᥽�åɤǤʤ����ϡ�
# ���ѥ��Ψ�˴�Ϳ�����ȡ�����򤦤ޤ����Ϥ��ʤ��ΤǼ����ǡġ�

def bsfilter_probs(io)
   probs = {}
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
      probs
   else
      nil
   end
end

if $0 == __FILE__
   require 'getopts'
   getopts("m:", "max:")
   max = 20
   max = ($OPT_m or $OPT_max).to_i if $OPT_m or $OPT_max
   ARGV.each do |f|
      IO.popen("bsfilter -d #{f}") do |io|
         prob = bsfilter_probs(io)
         puts prob["word"][0..max-1].map{|e| e.join(" ") }
         puts prob["all"]
      end
   end
end
