#!/usr/local/bin/ruby
# $Id$

# bsfilter �� Paul Graham �᥽�åɤǤʤ����ϡ�
# ���ѥ��Ψ�˴�Ϳ�����ȡ�����򤦤ޤ����Ϥ��ʤ��ΤǼ����ǡġ�

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
