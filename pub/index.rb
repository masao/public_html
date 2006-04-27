#!/usr/bin/env ruby
# $Id$

require "cgi"
require "erb"

require "rexml/document"
#require "yaml"

class PubList
   attr_accessor :lang, :tmpl
   attr_reader :cgi

   def initialize
      @cgi = CGI.new
   end
   def header(arg)
      @cgi.header(arg)
   end
   
   SORT_ACCEPT = [:year, :type, :author]
   SORT_DEFAULT = SORT_ACCEPT[0]
   def sort_mode
      if @cgi.params["sort_mode"][0] and @cgi.params["sort_mode"][0].size > 0
         mode = @cgi.params["sort_mode"][0].intern
         if SORT_ACCEPT.member? mode
            mode
         else
            SORT_DEFAULT
         end
      else
         SORT_DEFAULT
      end
   end
   def get_sort_key(element)
      case self.sort_mode
      when :type
         element.attributes["type"]
      else
         element.elements[self.sort_mode.to_s].text
      end
   end
end

DEFAULT_LANG = "ja"
PUBDATA = "pub.xml"
LASTUPDATE = File::mtime( PUBDATA )

cgi = PubList::new
cgi.lang = DEFAULT_LANG
cgi.tmpl = "pub.rhtml.#{cgi.lang}"

print cgi.header("text/html; charset=UTF-8")

pubs = REXML::Document.new(open(PUBDATA)).elements.to_a("/publist/pub")
pubs = pubs.sort_by do |e|
   #p cgi.get_sort_key(e)
   cgi.get_sort_key(e)
end

# pubs << e.elements[cgi.sort_mode.to_s]
toc_keys = pubs.map{|e| cgi.get_sort_key(e) }.uniq
if cgi.sort_mode == :year
   toc_keys.reverse!
   pubs.reverse!
end

print result = ERB::new(open(cgi.tmpl){|f|f.read}, $SAFE, 2).result( binding )
