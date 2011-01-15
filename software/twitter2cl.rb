#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
# $Id$

require "date"
require "rubygems"
require "twitter"
require "twitter/console"

CL_NAME = "Masao Takaku <tmasao@acm.org>"
config_file = "twitter.yml"
config = YAML.load( open( config_file ) )["test"]
username = config["login"]
#p config

Twitter::Client.configure do |conf|
   conf.oauth_consumer_token = config[ "oauth_consumer_token" ]
   conf.oauth_consumer_secret = config[ "oauth_consumer_secret" ]
   #p conf
end
twitter = Twitter::Client.new(:oauth_access => {
                                :key => config["oauth_token"],
                                :secret => config["oauth_token_secret"]
                             })

prev_date = nil
twitter.timeline_for( :me, :count => 200 ) do |status|
   date = status.created_at.strftime("%Y-%m-%d")
   if prev_date.nil? or date != prev_date
      prev_date = date
      puts "#{ date }  #{ CL_NAME }"
      puts "\t* [[今日のつぶやき|http://twitter.com/#{ username }]]:"
   end
   time_s = status.created_at.strftime("%H:%M")
   puts "\t{{twitter '#{username}', '#{ time_s }', '#{ status.text.gsub( /\'/, "\\'" ) }', #{ status.id }, '#{ status.source }', '#{ status.in_reply_to_status_id }', '#{ status.in_reply_to_screen_name }' }}"
end
