#!/usr/bin/env ruby
# -*- coding: euc-jp -*-
# $Id$

require "csv"
# require "kconv"

PAGE_NAME = "Issue/%%DATA1%%"
PAGE_TEMPLATE = <<EOF
* %%DATA7%%
-�ڡ���: [[Issue]]
-����: [[%%DATA5%%]]
-����: %%DATA3%%
-���ƥ��꡼: %%DATA2%%
-�����: %%DATA4%%
-�б�ͽ����: %%DATA11%%
-���᡼��: %%DATA6%%

**��å�����
%%DATA8%%

%%DATA9%%

(����)
%%DATA10%%

----
#comment
EOF

class String
   def expand_vars( data_row )
      self.gsub( /%%DATA(\d+)%%/ ) do |matched|
         colnum = $1.to_i
         data_row[colnum - 1]
      end
   end
end

csvreader = CSV::IOReader.new( ARGF )
csvreader.each do |data|
   # p data
   content = PAGE_TEMPLATE.expand_vars( data )
   pagename = PAGE_NAME.expand_vars( data ).unpack("H*0").join.upcase + ".txt"
   open( "wiki/#{pagename}", "w" ) do |io|
      io.print content
   end
   sleep 1
end
