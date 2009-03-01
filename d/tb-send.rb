#!/usr/bin/env ruby
# $Id$

require "net/http"
require "kconv"

module Trackback
   def self::auto_discovery(dest_url)
      uri = URI.parse(dest_url)
      response = nil
      body     = nil
      Net::HTTP.version_1_2
      Net::HTTP.start( uri.host, uri.port ) do |http|
         response = http.get( uri.path )
         body = response.body
      end
      result = nil
      if body and body.gsub(/\s+/, " ").match( %r{ xmlns:(\w+)="http://madskills.com/public/xml/rss/module/trackback/"} )
         tb_namespace = $1
         if body.match( %r{ #{tb_namespace}:ping="([^\"]+)"} )
            tb_url = $1
            #result = self.send( tb_url, title, excerpt, url, blog_name )
            result = tb_url
         end
      end
      result
   end

   def self::send(tb_url, title, excerpt, url, blog_name)
      uri = URI.parse(tb_url)
      path = uri.path
      path << "?" << uri.query if uri.query && !uri.query.empty?
      #
      formdata = ""
      formdata << "title="     << URI::escape(title)     << "&"
      formdata << "url="       << URI::escape(url)       << "&"
      formdata << "blog_name=" << URI::escape(blog_name) << "&"
      formdata << "excerpt="   << URI::escape(excerpt)
      #
      response = nil
      body     = nil
      Net::HTTP.version_1_2
      Net::HTTP.start(uri.host, uri.port) {|http|
         response = http.post(path,formdata)
         body     = response.read_body
      }
      [response, body]
   end
end

module Chalow
   def parse_itemlist( file = "cl.itemlist" )
      itemlist = []
      open( file ).each do |line|
         url = nil
         href, title, content, = line.chomp.split( /\t/ )
         next if title == "URL memo"
         url = $1 if /<a href=\"(.*)\">/ =~ href
         next if url.nil?
         entry_id = $1 if /#([0-9\-]+)\Z/ =~ url
         next if entry_id.nil?
         itemlist << {
            :id => entry_id,
            :url => url,
            :title => title,
            :content => content,
         }
      end
      #p itemlist.size
      #p itemlist.map{|e| /\A(\d+-\d+)/ =~ e[:url] and $1 }.uniq
      itemlist
   end

   def parse_html( entry )
      #p entry
      file = entry[:url].gsub( /#.*$/, "" )
      content = open( file ){|io| io.read }
      html = $1 if /<!-- start:#{entry[:id]} -->(.*)<!-- end:#{entry[:id]} -->/ms =~ content
      external_urls = []
      html.gsub( /<a href=\"((?:http|ftp):\/\/[^\"]+)"/ ) do |match|
         external_urls << $1
      end
      #p external_urls
      external_urls
   end
end

def usage( itemlist )
   puts <<EOF
  #{$0} entry_id
	(List all possible trackbak pings in the entry_id)
	entry_id:
		#{itemlist[0][:id]}	#{itemlist[0][:title]}
		#{itemlist[1][:id]}	#{itemlist[1][:title]}
		#{itemlist[2][:id]}	#{itemlist[2][:title]}
		#{itemlist[3][:id]}	#{itemlist[3][:title]}
		#{itemlist[4][:id]}	#{itemlist[4][:title]}

  #{$0} entry_id url [excerpt]
	(Send a trackback ping of the entry_id to the url)
EOF
end

if $0 == __FILE__
   include Chalow

   itemlist = parse_itemlist

   BLOG_NAME = "まさおのChangeLogメモ";
   BLOG_BASEURI = URI.parse( "http://masao.jpn.org/d/" )

   entry_id = ARGV.shift
   if entry_id.nil?
      usage( itemlist )
      exit
   end
   entry = itemlist.find{|e| e[:id] == entry_id }

   ping_url = ARGV.shift
   if ping_url
      title = entry[:title].toutf8
      excerpt = entry[:content].toutf8
      blog_name = BLOG_NAME.toutf8
      url = ( BLOG_BASEURI + entry[:url] ).to_s
      puts url
      p Trackback.send( ping_url, title, excerpt, url, blog_name )
   else
      urllist = parse_html( entry )
      skiplist = []
      puts "Trackback ping:"
      urllist.each do |url|
         tb_url = Trackback.auto_discovery( url )
         if tb_url
            puts url
            puts "\t" + tb_url
         else
            skiplist << url
         end
      end
      puts "Trackback ping not found:"
      skiplist.each do |url|
         puts url
      end
   end
end
