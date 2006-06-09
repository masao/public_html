#!/usr/local/bin/ruby
# $Id$

require "pathname"
require "uri"
require "yaml"
require "erb"
require "hikidoc"
require "cgi"

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
   def initialize( opts )
      opts.each do |var, val|
         var = var.to_s.sub(/^/, "@") unless /^@/ =~ var.to_s
         instance_variable_set( var, val )
      end
   end
   class Lastmodified < Plugin
      def expand( *args )
         file, format = args
         format ||= '%Y-%m-%d'
         mtime = File.mtime( file )
         %Q[<#{@style} class="lastmodified">#{mtime.strftime( format )}</#{@style}>]
      end
   end
   class Rawhtml < Plugin
      def expand( *args )
         args.map{|e| CGI.unescapeHTML(e) }.join("\n")
      end
   end
   class Div < Plugin
      def expand( *args )
      lines = args.join("\n").split(/\n/)
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
      #STDERR.puts @rootdir
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
      require "shellwords"
      #STDERR.puts text
      text.gsub(/<(div|span) class="plugin">\{\{\s*(\w+)\s*(.*?)\s*\}\}<\/\1>/ms) do |match|
         #STDERR.puts match
         style = $1
         name = $2
         args = $3
         args.sub!(/\A\s*\(/, "") && args.sub!(/\)\s*\Z/, "")
         args = Shellwords.shellwords( args )
         plugin = Plugin.const_get( name.capitalize ).new(:style => style)
         plugin.expand( *args )
      end
   end
   def method_missing( name, *args )
      name = name.to_s.gsub("_", ".")
      force, = args
      if @conf.has_key?( name ) or
            ( not force.nil? and @conf.has_key?( name = name.split(/\./)[0] ) )
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
