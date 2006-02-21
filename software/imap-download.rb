#!/usr/local/bin/ruby

# IMAP�����Ф�ί��Ƥ���᡼���1�᡼��1�ե������MH��������Ȥ��ġ���
# cf. ~masao/ChangeLog:[2004-10-28]

require 'net/imap'
require 'ftools'

File.umask(0077)	# ��ͭ�԰ʳ��ϸ���ʤ��褦�ˡ�����

HOST	 = "mp.nii.ac.jp"
UID	 =  "masao"
PASSWORD = "XXXXXXXXX"

USE_SSL = false # true
PORT = USE_SSL ? 993 : 143

OUTDIR	 = "/tmp/#{UID}-#{HOST}"
File.makedirs OUTDIR unless File.directory? OUTDIR

#Net::IMAP.debug = true
imap = Net::IMAP.new(HOST)
imap.login(UID, PASSWORD)
folder = imap.list("", "*")
folder.each do |d|
   dir = d.name
   imap.select(dir)
   File.makedirs "#{OUTDIR}/#{dir}" unless File.directory? "#{OUTDIR}/#{dir}"
   data = imap.fetch(1..-1, "RFC822")
   data.each do |m|
      fname =  "#{dir}/#{m.seqno}"
      open("#{OUTDIR}/#{fname}", "wb") do |f|
         f.print m.attr["RFC822"].gsub(/\r$/, "")
      end
      puts fname
   end
end
imap.disconnect
