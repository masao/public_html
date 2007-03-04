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
      #STDERR.puts @file
      @file = Pathname.new( @file ).relative_path_from( Pathname.new(basedir) )
   end
   def to_str
      @file.to_s
   end
   alias :to_s :to_str
end

# My HikiDoc...
#
class MHikiDoc < HikiDoc
   attr_reader :toc, :label
   def initialize( content, options = {} )
      @label = options[:label] || ''
      @interwiki = options[:interwiki] || ''
      super( content, options )
   end

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
         href_id = "toc#{@label}#{@toc.size}_#{@toc[-1].size-1}"
         %Q[\n<h#{level} id="#{href_id}">%s</h#{level}>\n\n] % inline_parser(title)
      end
   end

   # For Interwiki
   def parse_link( text )
      ret = text
      ret.gsub!( BRACKET_LINK_RE ) do |str|
         link = $1
         if NAMED_LINK_RE =~ link
            uri, title = $2, $1
            title = parse_modifier( title )
         else
            uri = title = link
         end
         uri.sub!( /^(?:https?|ftp|file)+:/, '' ) if %r|://| !~ uri && /^mailto:/ !~ uri
         if /^(\w+):(.*)$/ =~ uri and @interwiki.has_key?( $1 )
            prefix = $1
            str = $2
            uri = @interwiki[prefix].gsub(/%s/, str)
         end
         store_block( %Q|<a href="#{escape_quote( uri )}">#{title}</a>| )
      end
      ret.gsub!( URI_RE ) do |uri|
         uri.sub!( /^\w+:/, '' ) if %r|://| !~ uri && /^mailto:/ !~ uri
         if IMAGE_RE =~ uri
            store_block( %Q|<img src="#{uri}" alt="#{File.basename( uri )}"#{@empty_element_suffix}| )
         else
            store_block( %Q|<a href="#{uri}">#{uri}</a>| )
         end
      end
      ret
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
            label, = args
            label = "ÌÜ¼¡" unless label
            result = %Q[<h2>#{label}</h2><ul class="toc">\n]
            pre_level = nil
            @doc.toc.each_with_index do |bag, lidx|
               level = bag.shift
               if pre_level.nil?
                  gap = nil
               else
                  gap = pre_level - level
               end
               if gap.nil?
               elsif gap == 0
                  result << %Q[</li>\n]
               elsif gap > 0
                  result << %Q[</li>\n]
                  gap.times do
                     result << %Q[</ul></li>\n]
                  end
               elsif gap < 0
                  gap.abs.times do
                     result << %Q[<ul>\n]
                  end
               end
               bag.each_with_index do |title, idx|
                  result << %Q[<li><a href="#toc#{lidx+1}_#{idx+1}">#{title}</a>]
                  result << %Q[</li>\n] unless idx == bag.size - 1
               end
               pre_level = level
            end
            result << "</li></ul>"
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
            MHikiDoc.new( content, :label => args[0].gsub(/\W+/,'') ).to_html
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
            text = MHikiDoc.new( lines.join("\n"),
                                 :label => args[0].gsub(/\W+/,'') ).to_html
            %Q[<div #{ attrs }>#{ text }</div>]
         end
      end
      class Code < Plugin
         def expand( *args )
            str = args.join("\n")
            #str = MHikiDoc.new( str ).to_html.gsub(/^<p>/,'').gsub(/<\/p>$/,'')
            %Q[<code>#{ str }</code>]
         end
      end
      class Image < Plugin
         def expand( *args )
            #STDERR.puts args.inspect
            src, label, align = args
            label_text = ""
            label_text = %Q[ alt="#{label}" title="#{label}"] if label
            align_text = ""
            align_text = %Q[ style="display:#{align};clear:#{align}"] if align
            %Q[<img src="#{src}"#{align_text}#{label_text}/>]
         end
      end
   end
end

class ToHTML
   attr_reader :conf, :file, :content, :rootdir
   def initialize( file )
      @conf = YAML.load(open(HierFilename.new("tohtml.conf")))
      @lang = (file =~ /\.([a-z][a-z])$/)? $1 : conf["language"]
      @conf.update( YAML.load(open(HierFilename.new("tohtml.conf.#{@lang}"))) )
      @file = file
      @rootdir = File.join( ".", [ ".." ] * ( @file.split("/").size - 1 ) )
      @content, header = parse( @file )
      @conf.update( header )
      @conf["title.short"] = @conf["title"] if not @conf["title.short"]
      @conf["navi"] = true if not @conf["navi"] == "false"
      if @conf["css"].nil?
         @conf["css"] = HierFilename.new( "default.css", File.dirname( file ) )
      end
      #STDERR.puts @conf
   end
   def lang_file( lang = "ja" )
      file = nil
      case lang
      when "ja"
         file = @file.gsub( /\.\w+\.([a-z][a-z])$/, ".html.ja" )
      when "en"
         file = @file.gsub( /\.\w+\.([a-z][a-z])$/, ".html.en" )
         file = @file.gsub( /\.\w+$/, ".html.en" ) if not File.file?( file )
      end
      file = nil if not File.file?( file )
      file
   end
   def lang_switch
      result = []
      @conf["interlang"].keys.each do |lang|
         result << lang if lang_file( lang )
      end
      result
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
   def expand( template = "template.html.#{@lang}" )
      @doc = MHikiDoc.new( @content, :interwiki => @conf["interwiki"] )
      body = @doc.to_html
      body = expand_plugin( body )
      ERB.new( open(HierFilename.new(template)){|io| io.read },
               nil, "<>" ).result( binding )
   end
   def expand_plugin( text )
      require "shellwords"
      #STDERR.puts text
      text.gsub(/<(div|span) class="plugin">\{\{\s*(\w+)\s*(.*?)\s*\}\}<\/\1>/m) do |match|
         #STDERR.puts match
         style = $1
         name = $2
         args = $3
         args.sub!(/\A\s*\(/, "") && args.sub!(/\)\s*\Z/, "")
         args = Shellwords.shellwords( args )
         plugin = MHikiDoc::Plugin.const_get( name.capitalize ).new(:doc => @doc,
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
   ARGV.each do |f|
      puts ToHTML.new( f ).expand
   end
end
