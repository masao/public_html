#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
# $Id$

require "date"
require "yaml"

require "rubygems"
require "twitter"

Faraday::Request.lookup_middleware(:multipart)

def load_twitter_db( file = "twitter_log.yml" )
   YAML.load_stream( open( file ) ).flatten
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
      done[ tw["id"] ] = true
   end
   max_id = done.keys.max
   #STDERR.puts max_id.inspect
   tweets = client.user_timeline( "tmasao" )
   #tweets = client.user_timeline( "tmasao", max_id: 608421794534576128 )
   results = []
   tweets.each do |tweet|
      next if done[ tweet.id ]
      results << tweet.attrs.new_str_key
   end
   puts results.to_yaml if not results.empty?
end
