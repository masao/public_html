#!/usr/bin/env ruby
# $Id$

require "net/http"
require "nkf"
require "cgi"
require "erb"

class CGI
   def self_url
      "http://" + server_name.to_s + script_name.to_s
   end
end

module Trackback
   def self::auto_discovery(dest_url)
      uri = URI.parse(dest_url)
      response = nil
      body     = nil
      Net::HTTP.version_1_2
      Net::HTTP.start( uri.host, uri.port ) do |http|
         response = http.get( uri.path )
         body = response.read_body
      end
      result = nil
      if body
         body.gsub!(/\s+/, " ")
         if body.match( %r{ xmlns:(\w+)="http://madskills.com/public/xml/rss/module/trackback/"} )
            tb_namespace = $1
            if body.match( %r{\s#{tb_namespace}:ping="([^\"]+)"} )
               tb_url = $1
               #result = self.send( tb_url, title, excerpt, url, blog_name )
               result = tb_url
            end
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
      formdata << "title="     << CGI::escape(title)   << "&"
      formdata << "excerpt="   << CGI::escape(excerpt) << "&"
      formdata << "url="       << CGI::escape(url)     << "&"
      formdata << "blog_name=" << CGI::escape(blog_name)
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

if $0 == __FILE__
   include Chalow

   itemlist = parse_itemlist

   BLOG_NAME = "まさおのChangeLogメモ";
   TEMPLATE_FILE = "tb-send.rhtml"
   css = "../default.css"

   cgi = CGI.new
   puts cgi.header( "text/html; charset=EUC-JP" )
   if cgi.params["id"][0]
      if cgi.params["submit"][0]
      else
         entry = itemlist.find{|e| e[:id] == cgi.params["id"][0] }
         puts ERB.new( open( "tb-send.id.rhtml" ){|io| io.read }, nil, "<>" ).result( binding )
      end
   elsif cgi.params["date"][0]
      itemlist = itemlist.select{|e| /\A#{ cgi.params["date"][0] }/ =~ e[:id] }
      puts ERB.new( open( "tb-send.rhtml" ){|io| io.read }, nil, "<>" ).result( binding )
   else
      puts ERB.new( open( "tb-send.rhtml" ){|io| io.read }, nil, "<>" ).result( binding )
   end
end

