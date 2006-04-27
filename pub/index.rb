#!/usr/bin/env ruby
# $Id$

require "yaml"
require "cgi"
require "erb"

class CGI
   attr_accessor :lang, :tmpl
end

DEFAULT_LANG = "ja"
PUBDATA = "pub.yaml"
LASTUPDATE = File::mtime( PUBDATA )

cgi = CGI::new
cgi.lang = DEFAULT_LANG
cgi.tmpl = "pub.rhtml.#{cgi.lang}"

print cgi.header("text/html; charset=UTF-8")

pubs = []
YAML::load_documents(open(PUBDATA)){|e| pubs << e }
#p pubs

sort_mode = :year
pubs.select{|e| not e.nil? }.sort_by do |e|
   e[sort_mode.to_s]
end
all_keys = pubs.map{|e| e[sort_mode] }.uniq.sort
all_keys.reverse! if sort_mode == :year

puts result = ERB::new( open("pub.rhtml.ja"){|f| f.read } ).result( binding )
