#!/usr/bin/env ruby
# $Id$

require "cgi"
require "erb"

require "rexml/document"
#require "yaml"

class PubList
   attr_accessor :lang, :tmpl

   def initialize
      @cgi = CGI.new
   end
   def header(arg)
      @cgi.header(arg)
   end

   SORT_ACCEPT = {
      :year => (1998 .. Time.now.year+1).to_a.map{|e|e.to_s}.reverse,
      :type => %w[ book journal conference thesis techreport misc ],
      :author => nil,
   }
   SORT_DEFAULT = :year
   def sort_mode
      if @cgi.params["sort_mode"][0] and @cgi.params["sort_mode"][0].size > 0
         mode = @cgi.params["sort_mode"][0].intern
         #STDERR.puts mode.inspect
         if SORT_ACCEPT.member? mode
            mode
         else
            SORT_DEFAULT
         end
      else
         SORT_DEFAULT
      end
   end
   def toc_key(element, sort_mode = self.sort_mode)
      #STDERR.puts sort_mode.inspect
      if sort_mode == :type
         element.attributes["type"]
      else
         element.elements[sort_mode.to_s].text
      end
   end
   def sort_order(e, sort_mode = self.sort_mode)
      key = toc_key(e, sort_mode)
      if SORT_ACCEPT[sort_mode]
         SORT_ACCEPT[sort_mode].index(key) or key
      else
         key
      end
   end
end

DEFAULT_LANG = "ja"
PUBDATA = "pub.xml"
LASTUPDATE = File::mtime( PUBDATA )

if $0 == __FILE__
   cgi = PubList::new
   cgi.lang = DEFAULT_LANG
   cgi.tmpl = "pub.rhtml.#{cgi.lang}"

   print cgi.header("text/html; charset=UTF-8")

   pubs = REXML::Document.new(open(PUBDATA)).elements.to_a("/publist/pub")
   pubs = pubs.sort_by do |e|
      #p cgi.toc_key(e)
      #p cgi.sort_order(e)
      [ cgi.sort_order(e), cgi.sort_order(e, :year) ]
   end

   # pubs << e.elements[cgi.sort_mode.to_s]
   toc_keys = pubs.map{|e| cgi.toc_key(e) }.uniq

   print result = ERB::new(open(cgi.tmpl){|f|f.read}, $SAFE, 2).result(binding)
end
