#!/usr/local/bin/ruby
# $Id$

require "pathname"
require "uri"
require "yaml"
require "erb"
require "hikidoc"
require "cgi"
require "shellwords"

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

class HikiDoc::HTMLOutput
   def headline(level, title, attr)
      attr_s = ""
      attr.keys.sort.each do |k|
         attr_s << %Q[ #{k}="#{attr[k]}"]
      end
      @f.puts "<h#{level}#{ " " + attr_s if attr_s.size > 0 }>#{title}</h#{level}>"
   end
end

# My HikiDoc...
#
class MHikiDoc < HikiDoc
   attr_reader :toc, :label
   def initialize( content, options = {} )
      @toc = []
      @label = options[:label] || ''
      @interwiki = options[:interwiki] || ''
      super( content, options )
   end

   # For ToC
   def compile_header(line)
      @header_re ||= /\A!{1,#{7 - @level}}/
      level = @level + (line.slice!(@header_re).size - 1)
      title = strip(line)
      compiled_text = compile_inline(title)
      if @toc.empty? or @toc[-1].first != level
         @toc << [level, compiled_text]
      else
         @toc[-1] << compiled_text
      end
      h_id = "toc#{@label}#{@toc.size}_#{@toc[-1].size-1}"
      @output.headline level, compiled_text, :id => h_id
   end

   # For Interwiki
   def fix_uri(uri)
      if /^(\w+):(.*)$/ =~ uri and @interwiki.has_key?( $1 )
         prefix = $1
         str = $2
         uri = @interwiki[prefix]
         uri << str if not uri.gsub!(/%s/, str)
      elsif %r|://| !~ uri and /\Amailto:/ !~ uri
         uri.sub(/\A\w+:/, "")
      end
      uri
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
            MHikiDoc.to_xhtml( content,
                              { :label => args[0].gsub(/\W+/,''),
                                :interwiki => @interwiki } )
         end
      end
      class Rawhtml < Plugin
         def expand( *args )
            args.map{|e| CGI.unescapeHTML(e) }.join("\n")
         end
      end
      class Div < Plugin
         def expand( *args )
            #STDERR.puts [@style,args].inspect
            lines = args.join("\n").split(/\n/)
            attrs = lines.shift
            text = MHikiDoc.to_html( lines.join("\n"),
                                     {  :label => args[0].gsub(/\W+/,''),
                                        :interwiki => @interwiki } )
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
      class U < Plugin
         def expand( *args )
            str = args.join("\n")
            #str = MHikiDoc.new( str ).to_html.gsub(/^<p>/,'').gsub(/<\/p>$/,'')
            %Q[<u>#{ str }</u>]
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
      file = nil if file == @file or not File.file?( file )
      file
   end
   def lang_switch
      result = []
      @conf["interlang"].keys.each do |lang|
         #STDERR.puts lang_file( lang )
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
      @doc = MHikiDoc.new( HikiDoc::HTMLOutput.new("/>"),
                           { :interwiki => @conf["interwiki"],
                             :plugin_syntax => Proc.new{ true }
                           })
      body = @doc.compile( @content )
      body = expand_plugin( body )
      ERB.new( open(HierFilename.new(template)){|io| io.read },
               nil, "<>" ).result( binding )
   end
   def expand_plugin( text )
      #STDERR.puts text
      text.gsub(/<(div|span) class="plugin">\{\{\s*(\w+)\s*(.*?)\s*\}\}<\/\1>/m) do |match|
         #STDERR.puts match
         style = $1
         name = $2
         args = $3
         args.sub!(/\A\s*\(/, "") && args.sub!(/\)\s*\Z/, "")
         case style
         when "div"
            args = args.split(/\n/)
            args = Shellwords.shellwords( args.join("\n") ) if args.size == 1
         when "span"
            #STDERR.puts args
            args = Shellwords.shellwords( args )
         else
            raise "unknown plugin style: #{style}"
         end
         plugin = MHikiDoc::Plugin.const_get( name.capitalize ).new( :doc => @doc,
                                                                     :style => style,
                                                                     :interwiki => @conf["interwiki"] )
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
