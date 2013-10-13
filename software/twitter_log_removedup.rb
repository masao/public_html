#!/usr/bin/env ruby
# $Id$

require "yaml"

list = []
dup = {}
YAML.each_document( ARGF ) do |doc|
   doc.each do |status|
      next if dup[ status["id"] ]
      list << status
      dup[ status["id"] ] = true
   end
end

print list.to_yaml
