#!/usr/local/bin/ruby -Ke
# $Id$

require 'jcode'

class ConvertZipcode
   def initialize
      @all = Hash::new
   end

   def convert(entry, word)
      entry = entry.delete("\"").gsub(/\(.+\)/, "").sub(/\(.+$/, "").gsub(/-/, "ー").tr('ァ-ン', 'ぁ-ん')

      word = word.delete("\"").gsub(/（.+）/, "").sub(/（.+$/, "")

      case word
      when "以下に掲載がない場合", /）$/, /、/, /〜/
	 return false
      end

      if word =~ /の次に番地がくる場合$/ and entry =~ /のつぎにばんちがくるばあい/
	 word.sub!(/の次に番地がくる場合$/, "")
	 entry.sub!(/のつぎにばんちがくるばあい/, "")
      end

      if word =~ /一円$/ and entry =~ /いちえん$/
	 word.sub!(/一円$/, "")
	 entry.sub!(/いちえん$/, "")
      end

      if word =~ /[一二三四五六七八九十０-９]*地割$/ and entry =~ /\d*ちわり$/
	 word.sub!(/[一二三四五六七八九十０-９]*地割$/, "")
	 entry.sub!(/\d*ちわり$/, "")
      end

      if entry =~ /\d+/
	 entry = entry.gsub(/\d+/, "#")
	 if word =~ /[一二三四五六七八九十]+/
	    word = word.gsub(/[一二三四五六七八九十]+/, "#3")
	 elsif word =~ /[０-９]+/
	    word = word.gsub(/[０-９]+/, "#1")
	 end
      end

      if entry == word or entry.tr('ぁ-ん', 'ァ-ン') == word
	 return false
      end
      
      unless entry =~ /^[ぁ-んー#]+$/  # wrong entry
	 return false
      end

      puts "#{entry} /#{word}/" unless @all[entry + word]
      @all[entry + word] = true
   end
end

if $0 == __FILE__

   converter = ConvertZipcode::new

   ARGF.each_line do |line|
      array = line.split(/,/)
      converter.convert(array[4], array[7])
      converter.convert(array[5], array[8])
   end

end
