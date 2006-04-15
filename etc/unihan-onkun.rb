#!/usr/bin/env ruby
# $Id$

require "romkan"
$KCODE = "euc"

require "iconv"

hash = {}
ARGF.each do |line|
   next if /^#/ =~ line
   code, prop, val = line.chomp.split(/\t/)
   if prop =~ /^kJapanese(Kun|On)$/
      char = [code.sub(/^U\+/,"").hex].pack("U*")
      hash[char] ||= []
      hash[char] << val
   end
end

to_utf8 = Iconv.new("utf-8", "euc-jp")

hash.keys.sort.each do |char|
   puts [ char, hash[char].map{|e| to_utf8.iconv(e.downcase.to_kana) } ].join("\t")
end
