#!/usr/local/bin/ruby
# $Id$

require "hikidoc"
require 'erb'

# HierFilename:
#
#  If a file is not found, refer to parental directories with same
#  filename automatically
class HierFilename
   def initialize( name )
      @file = name
      while true do
         break if File.file?( @file )
         @file = File.join( "..", @file )
      end
   end
   def to_s
      @file
   end
end

class Plugin
   def initialize( content )
      Plugin::Div.new
      content.gsub!(/\A<div class=(["'])plugin\1>\{\{\s*(.*)\s*\}\}<\/div>\Z/imso, '\2')
      content.gsub!(/\A\s*(\w+)\s*(.*)\Z/imso) do
         name = $1
         args = $2
         search_plugin(name).expand( args )
      end
   end
   def search_plugin( name )
      Plugin.const_get(name.capitalize).new
   end

   class Div
      def initialize
      end
      def expand( args )
         lines = args.split(/\n/)
         attrs = lines.shift
         %Q[<div #{attrs}>#{ HikiDoc.new( lines.join("\n") ).to_html }</div>]
      end
   end
end

class ToHTML
   attr_reader :content
   def initialize( content, opt )
      @content = content
      @opt = opt
      @opt["title.short"] = @opt["title"] if not @opt["title.short"]
      @opt["navi"] = true if not @opt["navi"] == "false"
      @opt["css"] = HierFilename.new( "default.css" ) if @opt["css"].nil?
   end
   def expand( template = "template.html.in" )
      body = HikiDoc.new( @content ).to_html
      body = expand_plugin( body )
      ERB.new( open(HierFilename.new(template).to_s){|io| io.read },
               nil, "<>" ).result( binding )
   end
   def expand_plugin( text )
      #STDERR.puts text
      text.gsub(/<div class="plugin">\{\{\s*(\w+)\s*(.*?)\s*\}\}<\/div>(?=\n|$)/ms) do |match|
         #STDERR.puts match
         Plugin.const_get($1.capitalize).new.expand( $2 )
      end
   end
   def method_missing( name, *args )
      name = name.to_s.gsub("_", ".")
      if @opt.has_key?( name ) or @opt.has_key?( name = name.split(/\./)[0] )
         @opt[ name ]
      else
         ""
      end
   end
end

if $0 == __FILE__
   ARGV.each do |f|
      content = open(f){|io| io.readlines }
      header = {}
      while line = content.shift do
         case line
         when /^$/
            break
         when /^([\w\.]+):\s*(.*)$/
            header[$1] = $2
         else
            STDERR.puts "WARN: Unknown format: #{line}"
         end
      end
      puts ToHTML.new( content.join, header ).expand
   end
end
