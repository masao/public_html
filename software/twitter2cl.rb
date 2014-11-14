#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
# $Id$

require "date"
require "time"
require "yaml"

CL_NAME = "Masao Takaku <tmasao@acm.org>"
SCREEN_NAME = "tmasao"

list = []
dup = {}
YAML.load_stream( ARGF ) do |doc|
   doc.each do |status|
      next if dup[ status["id"] ]
      list << status
      dup[ status["id"] ] = true
   end
end
prev_date = nil
list.sort_by{|e| e["id"] }.reverse.each do |status|
   date = Time.parse( status[ "created_at" ] ).strftime("%Y-%m-%d")
   if prev_date.nil? or date != prev_date
      prev_date = date
      puts "#{ date }  #{ CL_NAME }"
      puts "\t* [[今日のつぶやき|http://twitter.com/#{ SCREEN_NAME }]]:"
   end
   time_s = Time.parse( status[ "created_at" ] ).strftime("%H:%M")
   screen_name = status[ "user" ][ "screen_name" ]
   #STDERR.puts status[ "user" ].inspect
   text = status[ "text" ].gsub( /\'/ ){|m| "\\'" }
   puts "\t{{twitter '#{ screen_name }', '#{ time_s }', '#{ text }', '#{ status[ "id_str" ] }', '#{ status[ "source" ] }', '#{ status[ "in_reply_to_status_id" ] }', '#{ status["in_reply_to_screen_name"] }' }}"
end
