#!/usr/local/bin/ruby
# $Id$

require "pathname"
require "uri"
require "yaml"
require "erb"
require "hikidoc"

# HierFilename:
#
#  If a file is not found, refer to parental directories with same
#  filename automatically
class HierFilename < Pathname
   def initialize( name, basedir = "." )
      level = 0
      10.times do |level|
         @file = File.join( basedir, [".."] * level,  name )
         #STDERR.puts @file
         break if File.file?( @file )
      end
      @file = Pathname.new( File.join( ".", [".."] * level,  @file ) ).cleanpath
   end
   def to_str
      @file.to_s
   end
   alias :to_s :to_str
end

class Plugin
   def initialize( content )
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
   attr_reader :conf, :file, :content, :rootdir
   def initialize( conf, file )
      @conf = conf
      @file = file
      @rootdir = File.join( ".", [ ".." ] * ( @file.split("/").size - 1 ) )
      @content, header = parse( @file )
      @conf.update( header )
      @conf["title.short"] = @conf["title"] if not @conf["title.short"]
      @conf["navi"] = true if not @conf["navi"] == "false"
      if @conf["css"].nil?
         @conf["css"] = HierFilename.new( "default.css", File.dirname( file ) )
      end
      STDERR.puts @rootdir
   end
   def parse( file )
      content = open(file){|io| io.readlines }
      header = {}
      while line = content.shift do
         case line
         when /^$/
            break
         when /^([\w\.]+):\s*(.*)$/
            key, val = $1, $2
            if /^date(\.|$)/ =~ key
               val = DateTime.parse(val)
            end
            if header[key]
               header[key] = [ header[key], val ]
            else
               header[key] = val
            end
         else
            STDERR.puts "WARN: Unknown format: #{line}"
         end
      end
      [ content.join, header ]
   end
   def expand( template = "template.html.in" )
      body = HikiDoc.new( @content ).to_html
      body = expand_plugin( body )
      ERB.new( open(HierFilename.new(template)){|io| io.read },
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
      if @conf.has_key?( name ) or @conf.has_key?( name = name.split(/\./)[0] )
         @conf[ name ]
      else
         nil
      end
   end
end

if $0 == __FILE__
   conf = YAML.load(open(HierFilename.new("tohtml.conf")))
   ARGV.each do |f|
      puts ToHTML.new( conf, f ).expand
   end
end
