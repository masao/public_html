#! /usr/local/bin/ruby
# $Id$
# 
# �����ȥǥ��쥯�ȥ�ʲ��Τ��٤Ƥ�HTML�ե�������Ф���
# htmllint ��¹Ԥ�����������Ĥ��롣

require "find"

files = {}
scorefile = "score"
open(scorefile).each do |line|
  if line =~ /^(\S+)\s+(.*)$/ then
    files[$2] = $1
  end
end

last_time = File.mtime(scorefile)
out = open(scorefile, "w")
target = []
Find::find('.') do |f|
  if f =~ /\.html?$/i then
    if not files.key? f || File.mtime(f) > last_time
      target.push f
    else
      score = files[f]
      out.puts "#{score} #{f}"
    end
  end
end

target.each do |f|
  score = `htmllint -scoreonly -nobanner -nowarnings #{f}`
  puts "#{f} => #{score}"
  out.puts "#{score} #{f}"
end
