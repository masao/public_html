#!/usr/bin/env ruby
# $Id$

require "mailread"
require "nkf"
require "kconv"
require "time"
require "stringio"

TO_ADDRESS = 'takaku-masao@ezweb.ne.jp'

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
open("forwardmail_mobile.log", "a") do |log|
   log.puts [ now.strftime( "%Y%m%dT%H%M%S" ), from, subject ].join( "\t" )
end
if /^text\/plain/i =~ mail[ "content-type" ]
elsif /^multipart\/.*boundary=\"([^\"]+)\"/ =~ mail[ "content-type" ]
   boundary = $1
   first_text = nil
   multiparts = body.join( "" ).split( /\n--#{ Regexp.quote boundary }.*\n/ )
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

warning = ""
if attach
   warning << "\n#{attach.size}�Ĥ�ź�եե����뤬�դ��Ƥ��ޤ�����\n"
   attach.each_with_index do |m, i|
      type = m[ "content-type" ].to_s.mail_decode
      filename = $2 if type =~ /name\s*=\s*(\"?)(.+)\1/
      warning << " ź��#{i + 1}: #{filename}"
      warning << " �ʥ�����: #{m.body.size} �Х��ȡ�\n"
      #m.header.keys.sort.each do |k|
      #   warning << "#{ k.capitalize }: #{ m[k].mail_decode }\n"
      #end
   end
end

message = <<EOF
From: #{ mail["from"].to_s.gsub( /\s+/, " " ).strip }
To: #{ TO_ADDRESS }
Subject: Fwd: #{ mail["subject"].to_s.gsub( /\s+/, " " ).strip }
X-Mailer: forwardmail_mobile.rb $Revision$
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp

#{body}
#{warning}
EOF
# puts message

open("|/usr/sbin/sendmail -oi -t -f masao@nii.ac.jp", "w") do |sendmail|
   sendmail.puts NKF.nkf( "-jm0", message )
end
