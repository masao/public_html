#!/usr/local/bin/ruby -Ke
# $Id$

require 'jcode'

class ConvertZipcode
   def initialize
      @all = Hash::new
   end

   def convert(entry, word)
      entry = entry.delete("\"").gsub(/\(.+\)/, "").sub(/\(.+$/, "").gsub(/-/, "��").tr('��-��', '��-��')

      word = word.delete("\"").gsub(/��.+��/, "").sub(/��.+$/, "")

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

      if entry == word or entry.tr('��-��', '��-��') == word
	 return false
      end
      
      unless entry =~ /^[��-��#]+$/  # wrong entry
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
