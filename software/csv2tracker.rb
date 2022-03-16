#!/usr/bin/env ruby
# -*- coding: euc-jp -*-
# $Id$

require "csv"
# require "kconv"

PAGE_NAME = "Issue/%%DATA1%%"
PAGE_TEMPLATE = <<EOF
* %%DATA7%%
-ページ: [[Issue]]
-報告者: [[%%DATA5%%]]
-状態: %%DATA3%%
-カテゴリー: %%DATA2%%
-報告日: %%DATA4%%
-対応予定日: %%DATA11%%
-報告メール: %%DATA6%%

**メッセージ
%%DATA8%%

%%DATA9%%

(解決策)
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
