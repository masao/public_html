#!/usr/local/bin/ruby
# -*- coding: euc-jp -*-
# $Id$

require "pathname"
require "uri"
require "yaml"
require "erb"
require "hikidoc"
require "cgi"
require "shellwords"
require "nkf"

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
   def escape_html(text)
      text.gsub(/&(?!#(x[\da-f]+|\d{2,3}))/i, "&amp;").gsub(/</, "&lt;").gsub(/>/, "&gt;")
   end
   def headline(level, title, attr)
      attr_s = ""
      attr.keys.sort.each do |k|
         attr_s << %Q[ #{k}="#{attr[k]}"]
      end
      @f.puts "<h#{level}#{ attr_s if attr_s.size > 0 }>#{title}</h#{level}>"
   end
end

# My HikiDoc...
#
class MHikiDoc < HikiDoc
   attr_reader :toc, :label, :options
   def initialize( content, options = {} )
      @toc = []
      @label = options[:label] || ''
      @interwiki = options[:interwiki] || {}
      @lang = options[:lang]
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
            label = "目次" unless label
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
      class Recent_publication < Plugin
         def expand( *args )
            Dir.chdir( "./pub" ) do
               cgi = {}
               def cgi.params; Hash.new( "" ); end
               require "index.rb"
               app = PubApp::new( cgi )
               app.load_pubdata( open(PUBDATA) )
               result = []
               app.each do |pub|
                  if pub.refereed != "true"
                     if pub.type !~ /\Abook|chapter\Z/
                        next
                     end
                  end
                  next if @lang == "en" and pub.language != @lang
                  #STDERR.puts pub.inspect
                  result << pub.eval_rhtml( "pub_recent.rhtml.ja" )
                  break if result.size > 4
               end
               contents = %Q[<ul id="publist">#{ result.join }</ul>]
               #STDERR.puts contents.inspect
               #contents = app.eval_rhtml( "publist.rhtml.#{app.lang}" )
               #contents.sub!( /^.*<dl id="publist">\s*(.*)\s*<\/dl>.*$/ms, '\1' )
               #list = contents.split( /<dt / )
               #list = list.find_all{|e| /refereed/ =~ e }[0...5]
               #contents = list.map{|e| e.gsub( /<span class="(refereed|type|year)">.*?<\/span>/, "" ).gsub( /<(\/?)d[td](.*)>/, "<\\1span\\2>" ) }.join( "<li " )
               #contents = %Q[<ul id="publist"><li #{ contents }</ul>]
               NKF.nkf( "-em0", contents )
            end
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
            options = @doc.options
            options[:label] = args[0].gsub(/\W+/,'')
            MHikiDoc.to_xhtml( content, options )
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
            options = @doc.options
            options[:label] = args[0].gsub(/\W+/,'')
            text = MHikiDoc.to_html( lines.join("\n"), options )
            %Q[<div #{ attrs }>#{ text }</div>]
         end
      end
      class Blockquote < Plugin
         def expand( *args )
            #STDERR.puts [@style,args].inspect
            lines = args.join("\n").split(/\n/)
            #attrs = lines.shift
            options = @doc.options
            options[:label] = args[0].gsub(/\W+/,'')
            text = MHikiDoc.to_html( lines.join("\n"), options )
            %Q[<blockquote>#{ text }</blockquote>]
         end
      end
      class SimpleInlinePlugin < Plugin
         def expand( *args )
            element_name = self.class.to_s.split(/::/).last.downcase
            str = args.join("\n")
            if str.empty?
               "<#{ element_name } />"
            else
               %Q[<#{element_name}>#{ str }</#{element_name}>]
            end
         end
      end
      class Code  < SimpleInlinePlugin; end
      class U     < SimpleInlinePlugin; end
      class Q     < SimpleInlinePlugin; end
      class Ins   < SimpleInlinePlugin; end
      class Kbd   < SimpleInlinePlugin; end
      class Small < SimpleInlinePlugin; end
      class Br    < SimpleInlinePlugin; end
      class Clear < Plugin
         def expand( *args )
            return %Q[<div style="clear:both;"/>]
         end
      end
      class Image < Plugin
         def expand( *args )
            src, label, *opts = args
            @css = {}
            opts.each do |opt|
               case opt
               when "thumbs"
                  @thumbs = true
               when "right", "left"  # align
                  @css[:float] = opt
                  #@css[:clear] = opt
               when "center"
                  @center = true
               when /\A(\d+)(?:px)?\Z/ # width
                  @css[:width] = $1 + "px"
               end
            end
            if not @css.empty?
               css_str = @css.keys.map{|k| "#{k}:#{@css[k]}" }.join(";")
               style_attr = %Q[ style="#{css_str}"]
            end
            caption = nil
            if @thumbs
               caption = MHikiDoc.to_xhtml( label, @doc.options ).gsub( /\A<p>/, "" ).gsub( /<\/p>\Z/, "" )
               label = caption.gsub( /<[^>]*>/, "" )
            end
            label_attr = label ? %Q[ alt="#{label}" title="#{label}"] : ""
            img_tag = %Q[<img src="#{src}" #{label_attr}/>]
            tags = if @thumbs
                      %Q[<div class="thumbs"#{style_attr}><div class="thumbs-image">#{img_tag}</div><div class="thumbs-caption">#{caption}</div></div>]
                   else
                      %Q[<#{@style}#{style_attr} class="image"><img src="#{src}"#{label_attr}/></#{@style}>]
                   end
            tags = %Q[<div class="center">#{ tags }</div>] if @center
            tags
         end
      end
      class Sortable < Plugin
         def expand( *args )
            @@sortable_id ||= 0
            @@sortable_id += 1
            lines = args.join("\n").split(/\n/)
            text = MHikiDoc.to_html( lines.join("\n"), @doc.options )
            text.gsub( /<table\b/, "<table class=\"sortable\" id=\"sortable#{ @@sortable_id }\"" )
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
      @conf["navi"] = true if not @conf["navi"] == false and not @conf["navi"] == "false"
      if @conf["css"].nil?
         @conf["css"] = HierFilename.new( "default.css", File.dirname( file ) )
      end
      #STDERR.puts @conf
      basename = file.gsub( /\.hikidoc/, ".html" )
      basename = basename.sub( /(\A|\/)index\.html(\.ja)?\Z/, "/" )
      @permalink = URI.join( @conf[ "baseurl" ], basename )
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
      lines = open(file){|io| io.readlines }
      header = {}
      while line = lines.shift do
         case line
         when /^$/
            break
         when /^([\w\.]+):\s*(.*)$/
            key, val = $1, $2
            while lines[0] and lines[0] =~ /^[ \t]/
               val += lines.shift
            end
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
      [ lines.join, header ]
   end
   include ERB::Util
   def expand( template = "template.html.#{@lang}" )
      @doc = MHikiDoc.new( HikiDoc::HTMLOutput.new(" />"),
                           { :interwiki => @conf["interwiki"],
                             :plugin_syntax => Proc.new{ true },
                             :use_wiki_name => false,
                             :lang => @lang,
                             :allow_bracket_inline_image => false,
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
         plugin_class = MHikiDoc::Plugin.const_get( name.capitalize )
         plugin = plugin_class.new( :doc => @doc,
                                    :style => style,
                                    :lang => @lang,
                                    :interwiki => @conf["interwiki"] )
         plugin.expand( *args )
      end
   end
   def subject_path
      result = []
      @conf["subject"].to_a.each do |category|
         label = @conf["subject.label"][category] || category
         category_dir  = File.join( rootdir, category )
         category_file = HierFilename.new( "#{category}.html" )
         category_file = HierFilename.new( "#{category}.html.#{@lang}" ) if not File.file?( category_file )
         if File.file?( category_file ) 
            result << [ label, category_file ] 
         else File.directory?( category_dir )
            result << [ label, category_dir + "/" ]
         end
      end
      result
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
