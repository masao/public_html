#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
# $Id$

require "date"
require "rubygems"
require "twitter"
require "twitter/console"

CL_NAME = "Masao Takaku <tmasao@acm.org>"
config_file = "twitter.yml"
username = YAML.load( open( config_file ) )["test"]["login"]

twitter = Twitter::Client.from_config( config_file )

prev_date = nil
twitter.timeline_for( :me, :count => 200 ) do |status|
   date = status.created_at.strftime("%Y-%m-%d")
   if prev_date.nil? or date != prev_date
      prev_date = date
      puts "#{ date }  #{ CL_NAME }"
      puts "\t* [[今日のつぶやき|http://twitter.com/#{ username }]]:"
   end
   time_s = status.created_at.strftime("%H:%M")
   puts "\t{{twitter \"#{username}\", \"#{ time_s }\", \"#{ status.text.gsub(/[\"\@]/){|e| "\\#{e}" } }\", #{ status.id }, '#{ status.source }', '#{ status.in_reply_to_status_id }', '#{ status.in_reply_to_screen_name }' }}"
end
