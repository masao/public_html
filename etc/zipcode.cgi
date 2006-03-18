#!/usr/local/bin/ruby -Ke
# -*- Ruby -*-
# $Id$

require 'jcode'
require 'cgi'
begin
   require 'dbi'
rescue LoadError
   require 'sqlite3'
end

begin
   require 'erb'
   ERbLight = ERB
rescue LoadError
   require 'erb/erbl'
end

ZIPCODECGI_VERSION = '$Id$'

class String
   def format_zipcode
      self.sub(/^(\d\d\d)(\d?\d?\d?\d?)$/) {
	 if $2.size == 4
	    "〒" << $1 << "-" << $2
	 else
	    "〒" << $1
	 end
      }
   end
end

class CGI
   def valid?( arg )
      self.params[arg][0] and self.params[arg][0].length > 0
   end
end

class ZipcodeCGI
   attr_reader :keyword, :pref, :city

   def initialize( cgi, rhtml )
      @cgi, @rhtml = cgi, rhtml
      @keyword = @cgi.params['keyword'][0] if @cgi.valid?( 'keyword' )
      @pref = @cgi.params['pref'][0] if @cgi.valid?( 'pref' )
      @city = @cgi.params['city'][0] if @cgi.valid?( 'city' )
   end

   # 実際の検索を行う
   def do_search
      #dbh = DBI.connect("dbi:SQLite:zipcode.db")	# For DBI
      dbh = SQLite3::Database.new("zipcode.db")		# For SQLite3
      @result = []
      # @search_time = DBI::Utils.measure do
      @search_time = Time.now
      if @keyword
         sql = ""
         args = []
         case @keyword
         when /^[0-9\-]+$/
            sql << "zipcode7 like ?"
            args << "#{ @keyword.delete("-") }%"
         when /^[ぁ-ん]+$/
            keyword_yomi = @keyword.tr('ぁ-ん', 'ァ-ン')
            sql << "city_yomi like ? or town_yomi like ?"
            args.push "%#{ keyword_yomi }%", "%#{ keyword_yomi }%"
         when /^[ァ-ン]+$/
            sql << "city_yomi like ? or town_yomi like ?"
            args.push "%#{ @keyword }%", "%#{ @keyword }%"
         else
            sql << "city like ? or town like ?"
            args.push "%#{ @keyword }%", "%#{ @keyword }%"
         end
         sth = dbh.prepare("select zipcode7, pref, city, town from zipcode where #{sql} order by zipcode7")
         rows = sth.execute(*args)
         rows.each do |row|
            zipcode7 = row.shift
            @result.push(zipcode7.format_zipcode << " " << row.join(" "))
         end
      elsif @pref and @city
         sth = dbh.prepare("select zipcode7, pref, city, town from zipcode where pref = ? and city = ? order by zipcode7")
         rows = sth.execute(@pref, @city)
         rows.each do |row|
            zipcode7 = row.shift
            @result.push(zipcode7.format_zipcode << " " << row.join(" "))
         end
      elsif @pref
         sth = dbh.prepare("select distinct city from zipcode where pref = ? order by city_yomi")
         rows = sth.execute(@pref)
         rows.each do |row|
            @result.push "<a href=\"./zipcode.cgi?pref=#{CGI.escape(@pref)};city=#{CGI.escape(row[0])}\">#{h(row[0])}</a>\n"
         end
      end
      #sth.finish	# For DBI
      #dbh.close	# For SQLite3
      @search_time = Time.now - @search_time
   end

   include ERbLight::Util
   def do_eval_rhtml
      ERbLight::new( open( @rhtml ).read ).result( binding )
   end
end

begin
   cgi = CGI.new
   zipcode_app = ZipcodeCGI.new(cgi, "zipcode.rhtml")

   if zipcode_app.keyword or zipcode_app.pref
      zipcode_app.do_search
   end

   cgi.out("text/html; charset=EUC-JP"){ zipcode_app.do_eval_rhtml }

rescue Exception
   if cgi then
      print cgi.header( 'type' => 'text/plain' )
   else
      print "Content-Type: text/plain\n\n"
   end
   puts "#$! (#{$!.class})"
   puts ""
   puts $@.join( "\n" )
end
