#!/usr/local/bin/ruby
# $Id$

#require "mailread"

class Mail
   def initialize(file)
      @header = {}
      open(file) do |f|
         lines = f.readlines
         while (not lines.empty?) do
            line = lines.shift
            break if line =~ /^$/
            line << lines.shift while lines[0] =~ /^\s/
            if line =~ /\A(\S+):\s*(.*)\Z/m
               @header[$1.downcase] ||= []
               @header[$1.downcase] << $2.gsub(/\s+/, " ").strip
            end
         end
      end
   end
   def [](key)
      @header[key.downcase]
   end
   def keys
      @header.keys
   end
end

ARGV.each do |f|
   m = Mail.new(f)
   next if m["received"].nil?
   m["received"].each do |l|
      if l =~ /masao@ulis\.ac\.jp/io
         #puts f
         mlname = m["list-id"] ? m["list-id"] :
            m["list-help"] ? m["list-help"] :
            m["list-subscribe"] ? m["list-subscribe"] :
            m["x-ml-name"] ? m["x-ml-name"] :
            m["sender"] ? m["sender"] :
            m["errors-to"] ? m["errors-to"] : m["from"]
         case mlname
         when "<webir.yahoogroups.com>",
            "<mailto:skk-help@ring.gr.jp>",
            "newsletterhelp@internet.com",
            /\.namazu\.org>$/,
            "<namazu-users-ja.namazu.org>",
            "<project-ja.namazu.org>",
            "ruby-list.ruby-lang.org",
            "<soap4r.googlegroups.com>",
            "memo.memo.st.ryukoku.ac.jp",
            /\.lists\.sourceforge\.jp>$/,
            "mule-ja.m17n.org",
            "mule.m17n.org",
            /\.indexdata\.dk/,
            "installer-request@o.nu",
            "<mailto:htmllint-help@ring.gr.jp>",
            /<http:\/\/www2\.xml\.gr\.jp\/1ml_main\.html\?MLID=.*>/,
            "JPCERT/CC <info@jpcert.or.jp>",
            "owner-lib@karin00.flib.fukui-u.ac.jp",
            "ipsj-info.ipsj.or.jp",
            "1-admin-ml-deliver-error@mmz.kantei.go.jp"
         else
            puts [f, mlname].join("\t")
         end
         break
      end
   end
end
