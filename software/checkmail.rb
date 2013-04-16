#!/usr/local/bin/ruby
# -*- coding: euc-jp -*-
# $Id$

require "mailread"
require "nkf"
require "kconv"
require "time"
require "stringio"

TO_ADDRESS = 'tmasao@acm.org'

class String
   def mail_decode
      NKF.nkf( "-m -e", self ).gsub( /\s+/, " ").strip
   end
end

now = Time.now
mail = Mail.new( STDIN )
subject = mail[ "subject" ].to_s.mail_decode
from = mail[ "from" ].to_s.mail_decode
body = mail.body
attach = nil
multiparts = false
open("checkmail.log", "a") do |log|
   log.puts [ now.strftime( "%Y%m%dT%H%M%S" ), from, subject ].join( "\t" )
end
#STDERR.puts mail[ "content-type" ].inspect
if /^text\/plain/i =~ mail[ "content-type" ]
elsif /^multipart\/.*boundary\s*=\s*(\"?)([^\"]+)\1/ism =~ mail[ "content-type" ]
   #STDERR.puts "multipart!"
   boundary = $2
   first_text = nil
   multiparts = body.join( "" ).split( /\n--#{ Regexp.quote boundary }.*\n/s )
   attach = []
   multiparts.each do |str|
      next if str.empty?
      m = Mail.new( StringIO.new( str ) )
      type = m[ "content-type" ].to_s.mail_decode
      if first_text.nil? and type =~ /^text\/plain/i
         body = m.body
         first_text = body
      else
         next if m.body.empty?
         attach << m
      end
   end
end
body = body.map{|e| e.toeuc }
if body.size > 100
   body = body[ 0..100 ]
   body << "..."
end

warning = ""
if attach
   warning << "\n#{attach.size}つの添付ファイルが付いていました。\n"
   attach.each_with_index do |m, i|
      type = m[ "content-type" ].to_s.mail_decode
      filename = $2 if type =~ /name\s*=\s*(\"?)(.+)\1/
      warning << " 添付#{i + 1}: #{filename}"
      warning << " （サイズ: #{m.body.size} バイト）\n"
      #m.header.keys.sort.each do |k|
      #   warning << "#{ k.capitalize }: #{ m[k].mail_decode }\n"
      #end
   end
end

message = <<EOF
From: #{ TO_ADDRESS }
To: #{ TO_ADDRESS }
Subject: address found
X-Mailer: checkmail.rb $Revision$
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp

The following message contains a responding address.

From: #{ mail["from"].to_s.gsub( /\s+/, " " ).strip }
To: #{ mail["to"].to_s.gsub( /\s+/, " " ).strip }
Date: #{ mail["date"].to_s.gsub( /\s+/, " " ).strip}
Subject: #{ mail["subject"].to_s.gsub( /\s+/, " " ).strip }

#{body}
EOF
message << "--\n#{warning}" if not warning.empty?
# puts message

open("|/usr/sbin/sendmail -oi -t -f #{ TO_ADDRESS }", "w") do |sendmail|
   sendmail.puts NKF.nkf( "-j", message )
end
