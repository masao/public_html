#! /usr/local/bin/ruby
# $Id$
# 
# カレントディレクトリ以下のすべてのHTMLファイルに対して
# htmllint を実行し、スコアをつける。

require "find"

files = {}
scorefile = "score"
open(scorefile).each do |line|
   if line =~ /^(\S+)\s+(.*)$/ then
      files[$2] = $1
   end
end

last_time = File.mtime(scorefile)

File.rename(scorefile, scorefile+".bak")	# Backup
out = open(scorefile, "w")
target = []
Find::find('.') do |f|
   if f =~ /\.html?$/i
      if files.key?(f) && File.mtime(f) < last_time
	 score = files[f]
	 out.puts "#{score} #{f}"
      else
	 target.push f
      end
   end
end

target.each do |f|
   score = `htmllint -scoreonly -nobanner -nowarnings #{f}`
   puts "#{f} => #{score}"
   out.puts "#{score}\t#{f}"
end
