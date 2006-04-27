#!/usr/bin/env ruby
# $Id$

require "cgi"
require "erb"

require "rexml/document"
#require "yaml"

class CGI
   attr_accessor :lang, :tmpl
   SORT_ACCEPT = [:year, :type, :author]
   SORT_DEFAULT = SORT_ACCEPT[0]
   def sort_mode
      if self.params["sort_mode"][0] and self.params["sort_mode"][0].size > 0
         mode = self.params["sort_mode"][0].intern
         if SORT_ACCEPT.member? mode
            mode
         else
            SORT_DEFAULT
         end
      else
         SORT_DEFAULT
      end
   end
end

DEFAULT_LANG = "ja"
PUBDATA = "pub.xml"
LASTUPDATE = File::mtime( PUBDATA )

cgi = CGI::new
cgi.lang = DEFAULT_LANG
cgi.tmpl = "pub.rhtml.#{cgi.lang}"

print cgi.header("text/html; charset=UTF-8")

pubs = REXML::Document.new(open(PUBDATA)).elements.to_a("/publist/pub")
pubs.sort_by do |e|
   e.elements[cgi.sort_mode.to_s].text
end

# pubs << e.elements[cgi.sort_mode.to_s]
toc_keys = pubs.map{|e| e.elements[cgi.sort_mode.to_s].text }.uniq.sort
toc_keys.reverse! if cgi.sort_mode == :year

puts result = ERB::new(open(cgi.tmpl){|f|f.read}, $SAFE, 2).result( binding )
