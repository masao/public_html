#!/usr/local/bin/ruby -Ke
# $Id$

# �Ȥ���:
#   �ʰʲ��Τ褦�ˤ���ȡ�̤��Ͽ����ν��礬�����
#   % nkf -SXe ken_all.csv | ./zipcode2skkdic.rb > tmp
#   % skkdic-expr2 tmp - SKK-JISYO.geo SKK-JISYO.L > geo.new

require 'jcode'

class ConvertZipcode
   attr_accessor :duplicate, :annotation, :kana, :split_city
   def initialize(duplicate = false, annotation = false, kana = false, split_city = true)
      @duplicate = duplicate	# ��ʣ���륨��ȥ����ϡ�
      @annotation = annotation	# ���Υơ���������ϡ�
      @split_city = split_city	# �Զ�Į¼�η�����ʬ�䤷������ȥ����ϡ�
      @kana = kana		# �֤��� �� ���ʡפΥ���ȥ����ϡ�

      @all_table = Hash::new unless @duplicate
   end

   def register(entry, word, annotation = nil)
      if entry == word or @kana and entry.tr('��-��', '��-��') == word
	 return false
      end
      
      unless entry =~ /^[��-��#]+$/  # wrong entry
	 return false
      end

      if @duplicate or !@all_table[entry + word]
	 puts "#{entry} /#{word}#{ (@annotation and annotation)? ";��̾," + annotation : ""}/"
      end
      @all_table[entry + word] = true unless @duplicate
   end

   # �Զ�Į¼̾��ι��ܤ�������ʬ���뤿����㳰�ơ��֥�
   SPLIT_TABLE = {
      '���Ϸ�����Į' => [['���Ϸ�', '����Į'], ['����ޤ���', '����ޤޤ�']],
      '���淴�巴Į' => [['���淴', '�巴Į'], ['����������', '���ߤ�������礦']],
      'ȬƬ������Į' => [['ȬƬ��', '����Į'], ['�䤺����', '���������礦']],
      '���߷�����Į' => [['���߷�', '����Į'], ['�褷������', '����������礦']],
      '���ַ�����Į' => [['���ַ�', '����Į'], ['�Ҥ�������', '�������ޤ��礦']],

      '���ڻ����' => [['���ڻ�', '���'], ['���äݤ�', '�Ҥ�����']],
      '���ڻ����ж�' => [['���ڻ�', '���ж�'], ['���äݤ�', '��������']],
      '���ڻ�����' => [['���ڻ�', '����'], ['���äݤ�', '�ˤ���']],
      '����Լ��Ӷ�' => [['�����', '���Ӷ�'], ['���������', '�狼�Ф䤷��']],
      '�������޻�����' => [['�������޻�', '����'], ['�������ޤ�', '�ˤ���']],
      '���ͻ�����' => [['���ͻ�', '����'], ['�褳�Ϥޤ�', '�ˤ���']],
      '̾�Ų������' => [['̾�Ų���', '���'], ['�ʤ��䤷', '�Ҥ�����']],
      '̾�Ų�������' => [['̾�Ų���', '����'], ['�ʤ��䤷', '�ˤ���']],
      '̾�Ų��Ծ��¶�' => [['̾�Ų���', '���¶�'], ['�ʤ��䤷', '���礦�勞']],
      '���Ի��컳��' => [['���Ի�', '�컳��'], ['���礦�Ȥ�', '�Ҥ�����ޤ�']],
      '���ԻԲ�����' => [['���Ի�', '������'], ['���礦�Ȥ�', '���⤮�礦��']],
      '���Ի�������' => [['���Ի�', '������'], ['���礦�Ȥ�', '�դ��ߤ�']],
      '���ԻԻ��ʶ�' => [['���Ի�', '���ʶ�'], ['���礦�Ȥ�', '��ޤ��ʤ�']],
      '���Ի�������' => [['���Ի�', '������'], ['���礦�Ȥ�', '�ˤ����礦��']],
      '����ʡ���' => [['����', 'ʡ���'], ['����������', '�դ����ޤ�']],
      '��������' => [['����', '����'], ['����������', '�ˤ���']],
      '����������' => [['����', '������'], ['����������', '�������礦��']],
      '�����������' => [['����', '�������'], ['����������', '�ˤ���ɤ��勞']],
      '�����������' => [['����', '�������'], ['����������', '�Ҥ�����ɤ��勞']],
      '����������' => [['����', '������'], ['����������', '�Ҥ����ʤ꤯']],
      '���Խ��ȶ�' => [['����', '���ȶ�'], ['����������', '���ߤ褷��']],
      '�����콻�ȶ�' => [['����', '�콻�ȶ�'], ['����������', '�Ҥ������ߤ褷��']],
      '����������' => [['����', '������'], ['����������', '�ˤ��ʤ꤯']],
      '���ͻ������' => [['���ͻ�', '�����'], ['�����٤�', '�Ҥ����ʤ���']],
      '���ͻ�����' => [['���ͻ�', '����'], ['�����٤�', '�ˤ���']],
      '���������' => [['�����', '����'], ['�Ҥ��ޤ�', '�ˤ���']],
      '��������' => [['�����', '���'], ['�Ҥ��ޤ�', '�Ҥ�����']],
      '�̶彣��ȬȨ����' => [['�̶彣��', 'ȬȨ����'], ['�������夦���夦��', '��Ϥ��ˤ���']],
      '�̶彣��ȬȨ���' => [['�̶彣��', 'ȬȨ���'], ['�������夦���夦��', '��Ϥ��Ҥ�����']],
      'ʡ�������' => [['ʡ����', '���'], ['�դ�������', '�Ҥ�����']],
      'ʡ��������' => [['ʡ����', '����'], ['�դ�������', '�ˤ���']],
   }

   # �Զ�Į¼̾���Ѵ�
   def convert_city(entry, word, annotation = nil)
      entry = entry.delete("\"").tr('��-��', '��-��')
      word = word.delete("\"")
      annotation = annotation.delete("\"") if annotation

      if @split_city
	 # �֡������ߡ�Į�פ�ñ�̤�2�Ĥ�ʬ�䤹��
	 if SPLIT_TABLE[word]
	    w = SPLIT_TABLE[word][0]
	    e = SPLIT_TABLE[word][1]
	    register(e[0], w[0], annotation)
	    register(e[1], w[1], annotation ? annotation + w[1] : nil)
	 elsif (w = /^(.+��)(.+)$/.match(word)) and (e = /^(.+����)(.+)$/.match(entry))
	    if e[1] =~ /^.+����.*����$/ or w[1] =~ /^.+��.*��$/
	       STDERR.puts "�㳰����ȥ�: ��#{entry} /#{word}/��" unless w[1] == "�̷��Ϸ�" 
	    end
	    register(e[1], w[1], annotation)
	    register(e[2], w[2], annotation ? annotation + w[1] : nil)
	 elsif (w = /^(.+��)(.+)$/.match(word)) and (e = /^(.+��)(.+)$/.match(entry))
	    if e[1] =~ /^.+��.*��$/ or w[1] =~ /^.+��.*��$/
	       STDERR.puts "�㳰����ȥ�: ��#{entry} /#{word}/��" unless w[1] =~ /^�����|�̶彣��$/
	    end
	    register(e[1], w[1], annotation)
	    register(e[2], w[2], annotation ? annotation + w[1] : nil)
	 end
      end

      register(entry, word, annotation)
   end

   # Į��̾���Ѵ�
   def convert_town(entry, word, annotation = nil)
      entry = entry.delete("\"").gsub(/\(.+\)/, "").sub(/\(.+$/, "").gsub(/-/, "��").tr('��-��', '��-��')

      word = word.delete("\"").gsub(/��.+��/, "").sub(/��.+$/, "")

      annotation = annotation.delete("\"") if annotation

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

# FIXME: ������ʬ���Ѵ�
#        if entry =~ /\d+/
#  	 entry = entry.gsub(/\d+/, "#")
#  	 if word =~ /[���󻰻͸�ϻ��Ȭ�彽]+/
#  	    word = word.gsub(/[���󻰻͸�ϻ��Ȭ�彽]+/, "#3")
#  	 elsif word =~ /[��-��]+/
#  	    word = word.gsub(/[��-��]+/, "#1")
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
