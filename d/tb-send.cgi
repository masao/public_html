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

class String
   def shorten( length = 300 )
      if self.length > len
         require "nkf"
         lines = NKF.nkf("-E -e -m0 -f#{len - 2}", self).split(/\n/)
         if lines.size > 1
            lines[0].concat( '..' )
         else
            self
         end
      else
         self
      end
   end
end

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
def parse_html
   
end

if $0 == __FILE__
   itemlist = parse_itemlist

   TEMPLATE_FILE = "tb-send.rhtml"
   css = "../default.css"

   cgi = CGI.new
   if cgi.params["id"][0]
      #puts ERB.new( open( TEMPLATE_FILE ){|io| io.read }, nil, "<>" ).result( binding )
   else
      puts ERB.new( open( TEMPLATE_FILE ){|io| io.read }, nil, "<>" ).result( binding )
   end
end
