#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
# $Id$

require "date"
require "yaml"

require "rubygems"
require "twitter"

Faraday::Request.lookup_middleware(:multipart)

def load_twitter_db( file = "twitter_log.yml" )
   YAML.load( open( file ) ) 
end

class Hash
   def new_str_key
      h = Hash.new
      self.each do |k, v|
	 k = k.to_s
         if v.class == Hash
	    v = v.new_str_key
	 end
	 h[ k ] = v
      end
      h
   end
end

if $0 == __FILE__
   config_file = "twitter.yml"
   config = YAML.load( open( config_file ) )["test"]
   username = config["login"]
   #p config
   client = Twitter::REST::Client.new do |c|
      c.consumer_key = config[ "oauth_consumer_token" ]
      c.consumer_secret = config[ "oauth_consumer_secret" ]
      c.access_token = config[ "oauth_token" ]
      c.access_token_secret = config[ "oauth_token_secret" ]
   end
   done = {}
   load_twitter_db.each do |tw|
      # p tw
      done[ tw["id"] ] = true
   end
   max_id = done.keys.max
   STDERR.puts max_id.inspect
   tweets = client.user_timeline( "tmasao" )
   min_id = tweets.first.id
   results = []
   while min_id > max_id
      STDERR.puts min_id
      tweets = client.user_timeline( "tmasao", max_id: min_id )
      tweets.each do |tweet|
        results << tweet.attrs.new_str_key
      end
      min_id = results.map{|e| e["id"] }.min
      sleep 5
   end
   puts results.to_yaml
end
