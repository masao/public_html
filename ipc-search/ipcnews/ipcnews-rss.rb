#!/usr/local/bin/ruby
# $Id$

# RSS を生成する

require "uconv"
require "date"
require "base64"
require "pstore"
require "ipcnews"

BASEURI = "http://masao.jpn.org/ipc-search/ipcnews/news.cgi"

rss = []
db = PStore.new("ipcnews.db")
db.transaction do
   items = db.roots.sort {|a, b| db[b].lastmodified <=> db[a].lastmodified }
   items[0, 15].each do |i|
      rss.push db[i].dup
   end
end

result = <<EOF
<?xml version="1.0" encoding="utf-8"?>
<rdf:RDF 
  xmlns="http://purl.org/rss/1.0/"
  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" 
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xml:lang="ja">
  <channel rdf:about="http://nile.ulis.ac.jp/ipc-search/ipcnews-rss.rdf">
    <title>センターニュース</title>
    <link>http://www.slis.tsukuba.ac.jp/ipc/ipnews/ipcnews_new.html</link>
    <description>筑波大学学術情報処理センターの春日サブセンターが配信しているニュースです。</description>
    <items>
      <rdf:Seq>
EOF

rss.each do |item|
   result += <<-EOF
      <rdf:li rdf:resource="#{BASEURI}?#{encode64(item.title).tr("\n","")}"/>
   EOF
end

result += <<EOF
      </rdf:Seq>
    </items>
  </channel>
EOF

rss.each do |item|
   result += <<-EOF
  <item rdf:about="#{BASEURI}?#{encode64(item.title).tr("\n","")}">
    <title>#{item.title}</title>
    <link>#{BASEURI}?#{encode64(item.title).tr("\n","")}</link>
    <description>#{item.description}</description>
    <dc:date>#{item.lastmodified}</dc:date>
  </item>
   EOF
end

result += "</rdf:RDF>"

open("ipcnews-rss.rdf", "w") do |f|
   f.print Uconv.euctou8(result)
end
