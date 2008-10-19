#!/usr/bin/env ruby
# $Id$

require "cgi"
require "erb"

require "rexml/document"
require "yaml"

class PubData
   attr_reader :type, :author, :author_role, :title, :subtitle
   attr_reader :journal, :conference, :org, :publisher
   attr_reader :volume, :number, :year, :month, :city
   attr_reader :page_start, :page_end, :page, :isbn, :note
   attr_reader :url, :url_label, :doi, :slide, :poster, :file
   attr_reader :language
   attr_reader :refereed
   def initialize( element )
      @type = element.attributes["type"]
      @refereed = element.attributes["refereed"]
      @author = []
      @author_role = {}
      element.get_elements("author").to_a.each{|e|
         @author << e.text
         @author_role[e.text] = e.attributes["role"] if e.attributes["role"]
      }
      @title = element.text("title")
      @subtitle = element.text("subtitle")
      @journal = element.text("journal")
      @conference = element.text("conference")
      @org = element.text("org")
      @publisher = element.text("publisher")
      @volume = element.text("volume")
      @number = element.text("number")
      @year = element.text("year")
      @month = element.text("month")
      @city = element.text("city")
      @page_start = element.text("page/start")
      @page_end = element.text("page/end")
      if @page_start.nil? and @page_end.nil?
         @page = element.text("page")
      end
      @isbn = element.text("isbn")
      @note = element.text("note")
      @language = element.text("language")
      @url = element.text("url")
      @url_label = element.elements["url"].attributes["label"] if @url
      @doi = element.text("doi")
      @slide = element.text("slide")
      @poster = element.text("poster")
      @file = element.text("file")
   end
end

class PubApp
   attr_reader :config, :lang

   def initialize( cgi, lang = "ja" )
      @cgi = cgi
      @config = YAML.load( open( "config.yml") )
      @lang = lang
   end

   def load_pubdata( io )
      @pubs = []
      REXML::Document.new( io ).elements.to_a("/publist/pub").each do |e|
         @pubs << PubData.new( e )
      end
      @pubs = @pubs.sort_by do |e|
         sort_keys = [ sort_order(e, :year),
                       sort_order(e, :month) ]
         unless sort_mode == :year
            sort_keys.unshift( sort_order(e) )
         end
         sort_keys
      end
      @toc_keys = @pubs.map{|e| toc_key(e) }.uniq
   end

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
#         author = element.send( :author )[0]
#          if @config and @config["author_maping"]
#             author_map = @config["author_maping"]["ja"]
#             author_map.keys.each do |k|
#                if author_map[ k ].to_a.include? author
#                   author = k
#                   break
#                end
#             end
#          end
#          author
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
      cgi.out("charset" => "UTF-8") {
         app.eval_rhtml( "pub.rhtml.#{app.lang}" )
      }
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
