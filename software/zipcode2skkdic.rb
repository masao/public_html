#!/usr/local/bin/ruby -Ke
# $Id$

# 使い方:
#   （以下のようにすると、未登録候補の集合が作れる）
#   % nkf -SXe ken_all.csv | ./zipcode2skkdic.rb > tmp
#   % skkdic-expr2 tmp - SKK-JISYO.geo SKK-JISYO.L > geo.new

require 'jcode'

class ConvertZipcode
   attr_accessor :duplicate, :annotation, :kana, :split_city
   def initialize(duplicate = false, annotation = false, kana = false, split_city = true)
      @duplicate = duplicate	# 重複するエントリを出力？
      @annotation = annotation	# アノテーションを出力？
      @split_city = split_city	# 市区町村の形式を分割したエントリも出力？
      @kana = kana		# 「かな → カナ」のエントリも出力？

      @all_table = Hash::new unless @duplicate
   end

   def register(entry, word, annotation = nil)
      if entry == word or @kana and entry.tr('ぁ-ん', 'ァ-ン') == word
	 return false
      end
      
      unless entry =~ /^[ぁ-んー#]+$/  # wrong entry
	 return false
      end

      if @duplicate or !@all_table[entry + word]
	 puts "#{entry} /#{word}#{ (@annotation and annotation)? ";地名," + annotation : ""}/"
      end
      @all_table[entry + word] = true unless @duplicate
   end

   # 市区町村名中の項目を正しく分けるための例外テーブル
   SPLIT_TABLE = {
      '群馬郡群馬町' => [['群馬郡', '群馬町'], ['ぐんまぐん', 'ぐんままち']],
      '赤穂郡上郡町' => [['赤穂郡', '上郡町'], ['あこうぐん', 'かみごおりちょう']],
      '八頭郡郡家町' => [['八頭郡', '郡家町'], ['やずぐん', 'こおげちょう']],
      '吉敷郡小郡町' => [['吉敷郡', '小郡町'], ['よしきぐん', 'おごおりちょう']],
      '日置郡郡山町' => [['日置郡', '郡山町'], ['ひおきぐん', 'こおりやまちょう']],

      '札幌市東区' => [['札幌市', '東区'], ['さっぽろし', 'ひがしく']],
      '札幌市白石区' => [['札幌市', '白石区'], ['さっぽろし', 'しろいしく']],
      '札幌市西区' => [['札幌市', '西区'], ['さっぽろし', 'にしく']],
      '仙台市若林区' => [['仙台市', '若林区'], ['せんだいし', 'わかばやしく']],
      'さいたま市西区' => [['さいたま市', '西区'], ['さいたまし', 'にしく']],
      '横浜市西区' => [['横浜市', '西区'], ['よこはまし', 'にしく']],
      '名古屋市東区' => [['名古屋市', '東区'], ['なごやし', 'ひがしく']],
      '名古屋市西区' => [['名古屋市', '西区'], ['なごやし', 'にしく']],
      '名古屋市昭和区' => [['名古屋市', '昭和区'], ['なごやし', 'しょうわく']],
      '京都市東山区' => [['京都市', '東山区'], ['きょうとし', 'ひがしやまく']],
      '京都市下京区' => [['京都市', '下京区'], ['きょうとし', 'しもぎょうく']],
      '京都市伏見区' => [['京都市', '伏見区'], ['きょうとし', 'ふしみく']],
      '京都市山科区' => [['京都市', '山科区'], ['きょうとし', 'やましなく']],
      '京都市西京区' => [['京都市', '西京区'], ['きょうとし', 'にしきょうく']],
      '大阪市福島区' => [['大阪市', '福島区'], ['おおさかし', 'ふくしまく']],
      '大阪市西区' => [['大阪市', '西区'], ['おおさかし', 'にしく']],
      '大阪市大正区' => [['大阪市', '大正区'], ['おおさかし', 'たいしょうく']],
      '大阪市西淀川区' => [['大阪市', '西淀川区'], ['おおさかし', 'にしよどがわく']],
      '大阪市東淀川区' => [['大阪市', '東淀川区'], ['おおさかし', 'ひがしよどがわく']],
      '大阪市東成区' => [['大阪市', '東成区'], ['おおさかし', 'ひがしなりく']],
      '大阪市住吉区' => [['大阪市', '住吉区'], ['おおさかし', 'すみよしく']],
      '大阪市東住吉区' => [['大阪市', '東住吉区'], ['おおさかし', 'ひがしすみよしく']],
      '大阪市西成区' => [['大阪市', '西成区'], ['おおさかし', 'にしなりく']],
      '神戸市東灘区' => [['神戸市', '東灘区'], ['こうべし', 'ひがしなだく']],
      '神戸市西区' => [['神戸市', '西区'], ['こうべし', 'にしく']],
      '広島市西区' => [['広島市', '西区'], ['ひろしまし', 'にしく']],
      '広島市東区' => [['広島市', '東区'], ['ひろしまし', 'ひがしく']],
      '北九州市八幡西区' => [['北九州市', '八幡西区'], ['きたきゅうしゅうし', 'やはたにしく']],
      '北九州市八幡東区' => [['北九州市', '八幡東区'], ['きたきゅうしゅうし', 'やはたひがしく']],
      '福岡市東区' => [['福岡市', '東区'], ['ふくおかし', 'ひがしく']],
      '福岡市西区' => [['福岡市', '西区'], ['ふくおかし', 'にしく']],
   }

   # 市区町村名の変換
   def convert_city(entry, word, annotation = nil)
      entry = entry.delete("\"").tr('ァ-ン', 'ぁ-ん')
      word = word.delete("\"")
      annotation = annotation.delete("\"") if annotation

      if @split_city
	 # 「○○郡××町」の単位を2つに分割する
	 if SPLIT_TABLE[word]
	    w = SPLIT_TABLE[word][0]
	    e = SPLIT_TABLE[word][1]
	    register(e[0], w[0], annotation)
	    register(e[1], w[1], annotation ? annotation + w[1] : nil)
	 elsif (w = /^(.+郡)(.+)$/.match(word)) and (e = /^(.+ぐん)(.+)$/.match(entry))
	    if e[1] =~ /^.+ぐん.*ぐん$/ or w[1] =~ /^.+郡.*郡$/
	       STDERR.puts "例外エントリ: 「#{entry} /#{word}/」" unless w[1] == "北群馬郡" 
	    end
	    register(e[1], w[1], annotation)
	    register(e[2], w[2], annotation ? annotation + w[1] : nil)
	 elsif (w = /^(.+市)(.+)$/.match(word)) and (e = /^(.+し)(.+)$/.match(entry))
	    if e[1] =~ /^.+し.*し$/ or w[1] =~ /^.+市.*市$/
	       STDERR.puts "例外エントリ: 「#{entry} /#{word}/」" unless w[1] =~ /^広島市|北九州市$/
	    end
	    register(e[1], w[1], annotation)
	    register(e[2], w[2], annotation ? annotation + w[1] : nil)
	 end
      end

      register(entry, word, annotation)
   end

   # 町域名の変換
   def convert_town(entry, word, annotation = nil)
      entry = entry.delete("\"").gsub(/\(.+\)/, "").sub(/\(.+$/, "").gsub(/-/, "ー").tr('ァ-ン', 'ぁ-ん')

      word = word.delete("\"").gsub(/（.+）/, "").sub(/（.+$/, "")

      annotation = annotation.delete("\"") if annotation

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

# FIXME: 数字部分の変換
#        if entry =~ /\d+/
#  	 entry = entry.gsub(/\d+/, "#")
#  	 if word =~ /[一二三四五六七八九十]+/
#  	    word = word.gsub(/[一二三四五六七八九十]+/, "#3")
#  	 elsif word =~ /[０-９]+/
#  	    word = word.gsub(/[０-９]+/, "#1")
#  	 end
#        end

      register(entry, word, annotation)
   end
end

if $0 == __FILE__

   converter = ConvertZipcode::new

   ARGF.each_line do |line|
      array = line.split(/,/)
      converter.convert_city(array[4], array[7], array[6])
      # converter.convert_town(array[5], array[8], array[7])
   end

end
