#!/usr/local/bin/ruby -Ke
# -*- Ruby -*-
# $Id$

require 'jcode'
require 'cgi'
require 'dbi'

begin
   require 'erb'
   ERbLight = ERB
rescue LoadError
   require 'erb/erbl'
end

# escapeHTML のラッパー
def e(str)
   if str
      CGI.escapeHTML(str)
   else
      ""
   end
end

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
   ID = '$Id$'

   def initialize( cgi, rhtml )
      @cgi, @rhtml = cgi, rhtml
      @keyword = @cgi.params['keyword'][0] if @cgi.valid?( 'keyword' )
      @pref = @cgi.params['pref'][0] if @cgi.valid?( 'pref' )
      @city = @cgi.params['city'][0] if @cgi.valid?( 'city' )
   end

   # 実際の検索を行う
   def do_search
      dbh = DBI.connect("dbi:SQLite:zipcode.db")
      @result = []
      @search_time = Time.now
      if @keyword
	 sql = ""
	 case @keyword
	 when /^[0-9\-]+$/
	    sql << "where zipcode7 like '#{ @keyword.delete("-") }%'"
	 when /^[ぁ-ん]+$/
	    escaped_keyword = @keyword.tr('ぁ-ん', 'ァ-ン').gsub('\'', '\'\'')
	    sql << "where city_yomi like '%#{ escaped_keyword }%' or town_yomi like '%#{ escaped_keyword }%'"
	 when /^[ァ-ン]+$/
	    escaped_keyword = @keyword.gsub('\'', '\'\'')
	    sql << "where city_yomi like '%#{ escaped_keyword }%' or town_yomi like '%#{ escaped_keyword }%'"
	 else
	    sql << "where town like '%#{ @keyword.gsub('\'', '\'\'') }%'"
	 end
	 sth = dbh.prepare("select zipcode7, pref, city, town from zipcode #{sql}")
	 sth.execute
	 sth.each do |row|
	    zipcode7 = row.shift
	    @result.push(zipcode7.format_zipcode << " " << row.join(" "))
	 end
	 sth.finish
      elsif @pref and @city
	 sth = dbh.prepare("select zipcode7, pref, city, town from zipcode where pref = ? and city = ?")
	 sth.execute(@pref, @city)
	 sth.each do |row|
	    zipcode7 = row.shift
	    @result.push(zipcode7.format_zipcode << " " << row.join(" "))
	 end
      elsif @pref
	 sth = dbh.prepare("select distinct city from zipcode where pref = ?")
	 sth.execute(@pref)
	 sth.each do |row|
	    STDERR.puts row.inspect
	    @result.push "<a href=\"./zipcode.cgi?pref=#{CGI.escape(@pref)};city=#{CGI.escape(row['city'])}\">#{row.join(" ")}</a>\n"
	 end
      end
      @search_time = Time.now - @search_time
   end

   def do_eval_rhtml
      ERbLight::new( open( @rhtml ).read ).result( binding )
   end
end

begin
   @cgi = CGI.new
   zipcode_app = ZipcodeCGI.new(@cgi, "zipcode.rhtml")

   if zipcode_app.keyword or zipcode_app.pref or zipcode_app.city
      zipcode_app.do_search
   end

   @cgi.out("text/html; charset=EUC-JP"){ zipcode_app.do_eval_rhtml }

rescue Exception
   if @cgi then
      print @cgi.header( 'type' => 'text/plain' )
   else
      print "Content-Type: text/plain\n\n"
   end
   puts "#$! (#{$!.class})"
   puts ""
   puts $@.join( "\n" )
end
