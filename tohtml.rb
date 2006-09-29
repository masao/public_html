#!/usr/local/bin/ruby
# $Id$

require "pathname"
require "uri"
require "yaml"
require "erb"
require "hikidoc"
require "cgi"

class HikiDoc
   attr_reader :toc
   # For ToC
   def parse_header( text )
      #STDERR.puts text
      @toc ||= []
      text.gsub( /^(#{HEADER_RE}{1,#{7-@level}})\s*(.*)\n?/ ) do |str|
         level, title = $1.size + @level - 1, $2
         if @toc.empty? or @toc[-1].first != level
            @toc << [level, inline_parser(title)]
         else
            @toc[-1] << inline_parser(title)
         end
         #STDERR.puts @toc.inspect
         %Q[\n<h#{level} id="#{@toc.size}_#{@toc[-1].size-1}" name="#{@toc.size}_#{@toc[-1].size-1}">%s</h#{level}>\n\n] % inline_parser(title)
      end
   end
end

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
   class Toc < Plugin
     def expand( *args )
        result = "<ul class=\"toc\">\n"
        @doc.toc.each_with_index do |bag, lidx|
           level = bag.shift
           bag.each_with_index do |title, idx|
              result << %Q[<li><a href="##{lidx+1}_#{idx+1}">#{title}</a></li>\n]
           end
        end
        result << "</ul>"
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
   class Include < Plugin
      def expand( *args )
         content = open(args[0]){|io| io.readlines }.join
         HikiDoc.new( content ).to_html
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
      @doc = HikiDoc.new( @content )
      body = @doc.to_html
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
         plugin = Plugin.const_get( name.capitalize ).new(:doc => @doc,
                                                          :style => style)
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
