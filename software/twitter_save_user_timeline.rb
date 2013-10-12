#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
# $Id$

require "date"
require "yaml"

require "rubygems"
require "twitter"

Faraday::Request.lookup_middleware(:multipart)

def load_twitter_db( file = "twitter.yml" )
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
   Twitter.configure do |c|
      c.consumer_key = config[ "oauth_consumer_token" ]
      c.consumer_secret = config[ "oauth_consumer_secret" ]
      c.oauth_token = config[ "oauth_token" ]
      c.oauth_token_secret = config[ "oauth_token_secret" ]
   end
   tweets = Twitter.user_timeline( "tmasao" )
   tweets = tweets.map do |tweet|
      tweet.attrs.new_str_key
   end
   puts tweets.to_yaml
end
