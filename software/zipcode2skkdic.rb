#!/usr/local/bin/ruby -Ke
# $Id$

# 使い方:
#   （以下のようにすると、未登録候補の集合が作れる）
#   % nkf -SXe ken_all.csv | ./zipcode2skkdic.rb > tmp
#   % skkdic-expr2 tmp - SKK-JISYO.geo SKK-JISYO.L > geo.new

require 'jcode'

class ConvertZipcode
   def initialize
      @all = Hash::new
   end

   def register(entry, word, annotation = nil)
      if entry == word   # or entry.tr('ぁ-ん', 'ァ-ン') == word
	 return false
      end
      
      unless entry =~ /^[ぁ-んー#]+$/  # wrong entry
	 return false
      end

      unless @all[entry + word]
	 puts "#{entry} /#{word};#{annotation ? "[地名] " + annotation : ""}/"
      end
      @all[entry + word] = true
   end

   # 市区町村名の変換
   def convert_city(entry, word, annotation = nil)
      entry = entry.delete("\"").tr('ァ-ン', 'ぁ-ん')
      word = word.delete("\"")
      annotation = annotation.delete("\"")

      # 「○○郡××町」の単位を2つに分割する
      # FIXME: ぐぐんまぐんぐんままち /群馬郡群馬町/
      if (w = /^(.+郡)(.+)$/.match(word)) and (e = /^(.+ぐん)(.+)$/.match(entry))
	 register(e[1], w[1], annotation)
	 register(e[2], w[2], annotation + w[1])
      end

      register(entry, word, annotation)
   end

   # 町域名の変換
   def convert_town(entry, word, annotation = nil)
      entry = entry.delete("\"").gsub(/\(.+\)/, "").sub(/\(.+$/, "").gsub(/-/, "ー").tr('ァ-ン', 'ぁ-ん')

      word = word.delete("\"").gsub(/（.+）/, "").sub(/（.+$/, "")

      annotation = annotation.delete("\"")

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

      register(entry, word, annotation)
   end
end

if $0 == __FILE__

   converter = ConvertZipcode::new

   ARGF.each_line do |line|
      array = line.split(/,/)
      converter.convert_city(array[4], array[7], array[6])
      converter.convert_town(array[5], array[8], array[7])
   end

end
