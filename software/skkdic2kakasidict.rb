#!/usr/bin/env ruby
# $Id$

$KCODE = "euc"

word = {}
ARGF.each do |line|
   if /^(\S+)\s(.+)$/ =~ line
      headword = $1
      candidates = $2
      next if headword =~ /^[^¤¡-¤ó]/
      next if headword =~ />$/
      candidates.split(/\//).each_with_index do |w, i|
         w.gsub!(/;.*$/,"")
         next if w.empty?
         word[w] ||= []
         word[w] << [ headword,  i / candidates.size.to_f ]
      end
   end
end

word.keys.sort.each do |w|
   headword = word[w].sort_by{|e| e[1] }.first[0]
   puts "#{headword} #{w}"
end
