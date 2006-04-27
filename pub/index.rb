#!/usr/bin/env ruby
# $Id$

require "yaml"
require "cgi"

puts "Content-Type: text/plain"
puts

pubs = []
YAML::load_documents(open("pub.yaml")){|e| pubs << e }
#p pubs
pubs.sort_by{|e| e["year"] }.each do |pub|
   puts pub.to_yaml
end
