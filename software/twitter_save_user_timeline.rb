#!/usr/bin/env ruby
# $Id$

require "uri"
require "open-uri"
require "yaml"

require "rubygems"
require "json"

if $0 == __FILE__
   FILENAME = "user_timeline.yml"
   params = ARGV
   params = [ "screen_name=tmasao" ] if ARGV.empty?
   params_u = params.join( "&" )
   #STDERR.puts params_u.inspect
   url = "http://api.twitter.com/1/statuses/user_timeline.json?#{ params_u }"
   json = open( url ){|io| io.read }
   data = JSON.load( json )
   #p data
   puts data.to_yaml
end
