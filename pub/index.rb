#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
# $Id$

require "cgi"
require "erb"
require "date"
require "uri"
require "yaml"

Encoding.default_external = 'utf-8' if defined? Encoding

if File.directory?( "/home/etk2/.gem" )
   ENV["GEM_HOME"] = "/home/etk2/.gem"
   ENV["GEM_PATH"] = "/home/etk2/.gem:/home/etk2/.gem/ruby/#{ RUBY_VERSION[0..2] }"
end

begin
   require "rubygems"
   require "libxml"
   XML_PARSER = :libxml
rescue LoadError
   require "rexml/document"
   XML_PARSER =  :rexml
end

module XMLAlternate
   class Document
      def initialize( io )
         case XML_PARSER
         when :libxml
            parser = LibXML::XML::Parser.io( io )
            @doc = parser.parse
         when :rexml
            @doc = REXML::Document.new( io )
         end
      end
      def get_elements( elem )
         case XML_PARSER
         when :libxml
            @doc.find( elem )
         when :rexml
            @doc.get_elements( elem )
         end
      end
      def each_elements( path )
         case XML_PARSER
         when :libxml
            @doc.find( path ).each do |elem|
               yield elem
            end
         when :rexml
            @doc.elements.to_a( "/publist/pub" ).each do |elem|
               yield elem
            end
         end
      end
   end
end
if XML_PARSER == :libxml
   class LibXML::XML::Node
      def text( path = nil )
         if path.nil?
            content
         else
            elem = find_first( path )
            if elem
               elem.content
            else
               nil
            end
         end
      end
      alias :get_elements :find
      def each_elements( path )
         find( path ).each do |child|
            yield child
         end
      end
   end
elsif XML_PARSER == :rexml
   class REXML::Element
      def each_elements( path )
         get_elements( path ).to_a.each do |child|
            yield child
         end
      end
   end
end

class PubData
   attr_reader :type, :author, :author_role, :title, :subtitle
   attr_reader :journal, :conference, :org, :publisher
   attr_reader :booktitle, :series
   attr_reader :volume, :number, :sequence_number, :year, :month, :city
   attr_reader :page_start, :page_end, :page, :isbn, :note, :awards, :awards_url
   attr_reader :url, :doi, :slides, :poster, :file, :abstract
   attr_reader :language
   attr_reader :refereed
   attr_reader :date
   attr_reader :chapter
   def initialize( element, config )
      @config = config
      @type = element.attributes["type"]
      @refereed = element.attributes["refereed"]
      @author = []
      @author_role = {}
      element.each_elements( "author" ) do |e|
         @author << e.text
         @author_role[e.text] = e.attributes["role"] if e.attributes["role"]
      end
      @title = element.text("title")
      @subtitle = element.text("subtitle")
      @journal = element.text("journal")
      @booktitle = element.text("booktitle")
      @chapter = element.text("chapter")
      @series = element.text("series")
      @conference = element.text("conference")
      @org = element.text("org")
      @publisher = element.text("publisher")
      @volume = element.text("volume")
      @number = element.text("number")
      @sequence_number = element.text("sequence-number")
      @year = element.text("year")
      @month = element.text("month")
      @city = element.text("city")
      @page_start = element.text("page/start")
      @page_end = element.text("page/end")
      if @page_start.nil? and @page_end.nil?
         @page = element.text("page")
      end
      @issn = element.text("issn")
      @isbn = element.text("isbn")
      @note = element.text("note")
      @language = element.text("language")
      @awards = element.text("awards")
      @awards_url = element.text("awards_url")
      @doi = element.text("doi")
      %w[ abstract slides poster url ].each do |target|
         values = element.get_elements( target )
         if values.empty?
            next
         else
            instance_eval( "@#{ target } = []" )
            values.each do |e|
               instance_eval( "@#{ target } << e.text" )
            end
         end
      end
      @file = element.text("file")
      @date = element.text("date")
   end

   def to_coins
      matrix = []
      @author.each do |a|
         matrix << [:au, a]
      end
      title_s = @title
      title_s << ": " + @subtitle if @subtitle
      if @type == "book"
         matrix << [ :btitle, title_s ]
      else
         matrix << [ :atitle, title_s ]
      end
      matrix << [ :jtitle, @journal ]
      matrix << [ :place, @city ]
      matrix << [ :pub, @publisher ]
      matrix << [ :date, @month ? "#{@year}-#{@month}" : @year ]
      matrix << [ :volume, @volume ]
      matrix << [ :issue, @number ]
      matrix << [ :spage, @page_start ]
      matrix << [ :epage, @page_end ]
      matrix << [ :pages, @page ? @page : "#{page_start}-#{page_end}" ]
      matrix << [ :tpages, @page ] if @page
      matrix << [ :issn, @issn ]
      matrix << [ :isbn, @isbn ]
      genre =  case @type
               when "conference"
                  "proceeding"
               when "techreport"
                  "report"
               when "book"
                  "book"
               else
                  "article"
               end
      matrix << [ :genre, genre ]
      coins = "url_ver=Z39.88-2004&rft_val_fmt=info:ofi/fmt:kev:mtx:"
      case @type
      when "journal", "conference"
         coins << "journal"
      else
         coins << "book"
      end
      coins << "&rft_id=#{ @doi ? "info:doi/#{@doi}" : @url }&"
      matrix = matrix.to_a.map do |e|
         key = "rft." + e[0].to_s
         val = e[1]
         if val
            "#{key}=#{URI.escape( val )}"
         else
            nil
         end
      end
      coins << matrix.compact.join("&")
   end

   def to_plaintext
      result = { :meta => [], :author => "", :title => "", :info => [], :note => "" }
      result[ :meta ] << @type
      result[ :meta ] << :refereed if @refereed
      result[ :author ] << @author.join(", ")
      result[ :title ] << @title
      result[ :title ] << ": " + @subtitle if @subtitle
      result[ :info ] << @journal if @journal
      result[ :info ] << "vol."+@volume if @volume
      result[ :info ] << "no."+@number if @number
      result[ :info ] << @conference if @conference
      result[ :info ] << @city if @city
      result[ :info ] << @publisher if @publisher
      if @page
         result[ :info ] << @page + "p."
      elsif @page_start
         result[ :info ] << "pp.#{page_start}-#{page_end}"
      end
      if @month
         result[ :info ] << "#{ @year }-#{ "%02d" % @month.to_i }"
      else
         result[ :info ] << @year
      end
      if @note
         result[ :note ] << @note
      elsif @type == "misc" and @volume.nil? and @number.nil? and @page.nil? and @page_start.nil?
         result[ :note ] << "（口頭発表）"
      end

      result_str = result[ :meta ].join( " " )
      result_str << "\n" if not result_str.empty?
      result_str << "#{ result[ :author ] }: #{ result[ :title ] }. #{ result[ :info ].join( ", " ) } #{ result[ :note ] }"
      result_str << "\n"
   end
   def to_bibtex
      bibtex = {}
      genre =  case @type
               when "conference"
                  "inproceedings"
               else
                  @type
               end
      bibtex[ :author ] = @author.join(" and ")
      bibtex[ :title ] = @title
      bibtex[ :title ] << ": " + @subtitle if @subtitle
      bibtex[ :journal ] = @journal if @journal
      bibtex[ :conference ] = @conference if @conference
      if genre == "inproceedings"
         bibtex[ :booktitle ] = @conference ? @conference : @journal
      end
      bibtex[ :address ] = @city if @city
      bibtex[ :publisher ] = @publisher if @publisher
      bibtex[ :year ] = @year
      #bibtex[ :month ] = @month if @month
      bibtex[ :volume ] = @volume if @volume
      bibtex[ :number ] = @number if @number
      if @page
         bibtex[ :pages ] = @page
      elsif @page_start
         bibtex[ :pages ] = "#{page_start}-#{page_end}"
      end
      bibtex[ :issn ] = @issn if @issn
      bibtex[ :isbn ] = @isbn if @isbn
      bibtex[ :note ] = @note if @note
      bibtex_s = bibtex.keys.map{|k| "#{k} = {#{bibtex[k]}}" }.join(",\n")
      <<EOF
@#{genre}{pubid#{object_id},
#{bibtex_s}
}
EOF
   end

   def eval_rhtml( tmpl )
      rhtml = open( tmpl ){|f| f.read }
      ERB::new( rhtml, $SAFE, 2 ).result( binding )
   end
   include ERB::Util
end

class PubApp
   attr_reader :config, :lang

   def initialize( cgi, lang = "ja" )
      @cgi = cgi
      @config = YAML.load( open( "config.yml") )
      @lang = lang
   end

   def load_pubdata( io )
      doc = XMLAlternate::Document.new( io )
      @version = doc.get_elements( "/publist" ).first.attributes[ "version" ]
      @pubs = []
      doc.each_elements("/publist/pub") do |e|
         @pubs << PubData.new( e, @config )
      end
      @pubs = @pubs.sort_by do |e|
         sort_keys = [ sort_order(e, :year),
                       sort_order(e, :month) ]
         sort_keys << ( - Date.parse( e.date ).jd ) if e.date
         unless sort_mode == :year
            sort_keys.unshift( sort_order(e) )
         end
         sort_keys
      end
      @toc_keys = @pubs.map{|e| toc_key(e) }.uniq
   end

   def each
      @pubs.each do |e|
         yield e
      end
   end
   include Enumerable

   SORT_ACCEPT = {
      :month => ( "0".."12" ).to_a.reverse,
      :year => ( 1945 .. Time.now.year+2 ).to_a.map{|e|e.to_s}.reverse,
      :type => %w[ book journal conference thesis techreport misc ],
      :author => nil,
      :refereed => [ "refereed", "not refereed" ]
   }
   SORT_DEFAULT = :year
   def sort_mode
      if @cgi.params["sort_mode"][0] and @cgi.params["sort_mode"][0].size > 0
         mode = @cgi.params["sort_mode"][0].intern
         #STDERR.puts mode.inspect
         if SORT_ACCEPT.member? mode
            mode
         else
            SORT_DEFAULT
         end
      else
         SORT_DEFAULT
      end
   end
   def toc_key( element, sort_mode = self.sort_mode )
      #STDERR.puts sort_mode.inspect
      case sort_mode
      when :type
         element.send( :type )
      when :author
         element.send( :author )[0]
         author = element.send( :author )[0]
         if @config and @config["author_map"]
            author_map = @config["author_map"]
            author_map.keys.each do |k|
               if author_map[ k ] == author or author_map[ k ].include?( author )
                  # STDERR.puts "#{ k } == #{ author_map[ k ] }"
                  author = k
                  break
               end
            end
         end
         author
      when :refereed
         element.send( :refereed ) == "true" ? "refereed" : "not refereed"
      else
         element.send( sort_mode ) or nil
      end
   end
   def sort_order(e, sort_mode = self.sort_mode)
      key = toc_key(e, sort_mode)
#       if sort_mode == :author
#          if @config["author_mine"]
#             mine = @config["author_mine"].any?{|r| r =~ key } ? 0 : 1
#             [ mine, key ]
#          else
#             key
#          end
#       elsif SORT_ACCEPT[sort_mode]
      if SORT_ACCEPT[sort_mode]
         SORT_ACCEPT[sort_mode].index(key) or SORT_ACCEPT[sort_mode].size
      else
         key
      end
   end

   def eval_rhtml( tmpl )
      rhtml = open( tmpl ){|f| f.read }
      ERB::new( rhtml, $SAFE, 2 ).result( binding )
   end
   include ERB::Util
end

PUBDATA = "pub.xml"
LASTUPDATE = File::mtime( PUBDATA )

if $0 == __FILE__
   begin
      cgi = CGI.new
      app = PubApp::new( cgi )
      app.load_pubdata( open(PUBDATA) )
      if cgi.params["action"] and cgi.params["action"][0] == "bibtex"
         cgi.out( "application/x-bibtex; charset=UTF-8" ) do
            app.map{|e| e.to_bibtex }.join
         end
      elsif cgi.params["action"] and cgi.params["action"][0] == "plaintext"
         cgi.out( "text/plain; charset=UTF-8" ) do
            app.map{|e| e.to_plaintext }.join
         end
      else
         cgi.out( "charset" => "UTF-8" ) do
            app.eval_rhtml( "publist.rhtml.#{app.lang}" )
         end
      end
   rescue
      print cgi.header( { "status" => "500 Internal Server Error",
                          "type"   => "text/plain; charset=utf-8" } )
      puts "500 Internal Server Error:"
      puts
      puts "#{$!} (#{$!.class})"
      puts
      puts $@.join("\n")
   end
end
