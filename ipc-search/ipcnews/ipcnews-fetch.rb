#! /usr/local/bin/ruby -Ke
# $Id$
# センターニュースを取得し、（強引に）解析し、PStore として永続化する

require "date"
require "uri"
require "net/http"
require "pstore"

require "ipcnews"

# "＜...＞" だけを頼りに適当にパースする。
def parse_news(content, date = Date.today)
   result = []

   content.split(/<hr\s*\/?>/i).each do |part|
      part.gsub!(/<!--.+?-->/m, " ")	# コメントを除去
      part.gsub!(/<.+?>/m, " ")		# タグを除去
      part.gsub!(/　/, " ")		# 空白類を除去
      part.gsub!(/\s+/, " ")
      
      part.scan(/＜+(.+?)＞+([^＜]*)/m) do |match|
	 description = match[1].strip
	 result.push NewsItem.new(match[0].strip, description, date)
      end
   end

   result
end

newslist = []
if ARGV.size > 0
   while filename = ARGV.shift
      content = open(filename).read
      puts "reading #{File.basename(filename)}"
      date = Date.new(File.basename(filename)[0,4].to_i,
		      File.basename(filename)[4,2].to_i,
		      File.basename(filename)[6,2].to_i)
      newslist += parse_news(content, date)
   end
else
   uri = URI.parse NEWS_URI
   Net::HTTP.start( uri.host, uri.port ) {|http|
      response , = http.get(uri.request_uri)
      content = response.body
   }
   newslist += parse_news(content)
end

modified = false

db = PStore.new("ipcnews.db")
newslist.each do |item|
   db.transaction do
      if not db.root?(item.title)
	 db[item.title] = item
	 puts "#{item.lastmodified}\t#{item.title}"
      elsif item.lastmodified >= db[item.title].lastmodified &&
	    item.description != db[item.title].description
	 db[item.title] = item
	 modified = true
	 puts "#{item.lastmodified}\t#{item.title}"
      end
   end
end

db.transaction do
   puts "#{db.path} has #{db.roots.size} items."
end if modified
