#!/usr/local/bin/ruby -Ke
# $Id$

# �Ȥ���:
#   �ʰʲ��Τ褦�ˤ���ȡ�̤��Ͽ����ν��礬�����
#   % nkf -SXe ken_all.csv | ./zipcode2skkdic.rb > tmp
#   % skkdic-expr2 tmp - SKK-JISYO.geo SKK-JISYO.L > geo.new

require 'jcode'

class ConvertZipcode
   def initialize
      @all = Hash::new
   end

   def register(entry, word, annotation = nil)
      if entry == word   # or entry.tr('��-��', '��-��') == word
	 return false
      end
      
      unless entry =~ /^[��-��#]+$/  # wrong entry
	 return false
      end

      unless @all[entry + word]
	 puts "#{entry} /#{word};#{annotation ? "[��̾] " + annotation : ""}/"
      end
      @all[entry + word] = true
   end

   # �Զ�Į¼̾���Ѵ�
   def convert_city(entry, word, annotation = nil)
      entry = entry.delete("\"").tr('��-��', '��-��')
      word = word.delete("\"")
      annotation = annotation.delete("\"")

      # �֡������ߡ�Į�פ�ñ�̤�2�Ĥ�ʬ�䤹��
      # FIXME: ������ޤ��󤰤�ޤޤ� /���Ϸ�����Į/
      if (w = /^(.+��)(.+)$/.match(word)) and (e = /^(.+����)(.+)$/.match(entry))
	 register(e[1], w[1], annotation)
	 register(e[2], w[2], annotation + w[1])
      end

      register(entry, word, annotation)
   end

   # Į��̾���Ѵ�
   def convert_town(entry, word, annotation = nil)
      entry = entry.delete("\"").gsub(/\(.+\)/, "").sub(/\(.+$/, "").gsub(/-/, "��").tr('��-��', '��-��')

      word = word.delete("\"").gsub(/��.+��/, "").sub(/��.+$/, "")

      annotation = annotation.delete("\"")

      case word
      when "�ʲ��˷Ǻܤ��ʤ����", /��$/, /��/, /��/
	 return false
      end

      if word =~ /�μ������Ϥ�������$/ and entry =~ /�ΤĤ��ˤФ��������Ф���/
	 word.sub!(/�μ������Ϥ�������$/, "")
	 entry.sub!(/�ΤĤ��ˤФ��������Ф���/, "")
      end

      if word =~ /���$/ and entry =~ /��������$/
	 word.sub!(/���$/, "")
	 entry.sub!(/��������$/, "")
      end

      if word =~ /[���󻰻͸�ϻ��Ȭ�彽��-��]*�ϳ�$/ and entry =~ /\d*�����$/
	 word.sub!(/[���󻰻͸�ϻ��Ȭ�彽��-��]*�ϳ�$/, "")
	 entry.sub!(/\d*�����$/, "")
      end

      if entry =~ /\d+/
	 entry = entry.gsub(/\d+/, "#")
	 if word =~ /[���󻰻͸�ϻ��Ȭ�彽]+/
	    word = word.gsub(/[���󻰻͸�ϻ��Ȭ�彽]+/, "#3")
	 elsif word =~ /[��-��]+/
	    word = word.gsub(/[��-��]+/, "#1")
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
