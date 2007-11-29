#!/usr/bin/env ruby
# $Id$

require "kconv"

SUBJECT = "=?ISO-2022-JP?B?GyRCPEI4MyUiJWslUCUkJUg/PSQ3THUkIiRqJF4bKEI=?=\n\t=?ISO-2022-JP?B?GyRCJDskcxsoQg==?="
SENDMAIL = '/usr/sbin/sendmail'

FROM = 'Masao Takaku <masao@nii.ac.jp>' # From: フィールド
REAL_FROM = 'masao@nii.ac.jp'	# error mail 宛先

def usage
   puts "USAGE: #$0 message_file address_tsv"
   exit
end

if $0 == __FILE__
   if not ARGV[0] or not ARGV[1]
      usage
   end
   message = open(ARGV[0]).read

   open(ARGV[1]).each do |line|
      name, addr, = line.chomp.split(/\t/)
      if addr =~ /^[\w\.\-]+@[\w\.\-]+$/
         open("| #{SENDMAIL} -oi -t -f #{REAL_FROM}", "w") do |sendmail|
            sendmail.print <<EOF
From: #{FROM}
Subject: #{SUBJECT}
To: #{addr}
Cc: #{FROM}
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit

EOF

            sendmail.print message.gsub( /%NAME%/, name ).tojis
         end
         puts "#{addr} done."
      else
         puts "#{addr} error: (wrong addres)"
      end
   end

end
