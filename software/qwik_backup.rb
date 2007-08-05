#!/usr/bin/env ruby
# $Id$

require "uri"
require "net/http"
require 'net/https'
require "time"

$KCODE = "utf-8"

class QwikBackup
   def initialize( baseurl, username, password )
      @baseurl = URI.parse( baseurl )
      @conn = Net::HTTP.new( @baseurl.host, @baseurl.port )
      cookie = login( @baseurl + ".typekey", username, password )
      @cookie = { "Cookie" => cookie.keys.map{|c| "#{c}=#{cookie[c]}" }.join("; ") }
   end

   def login( baseurl, username, password )
      # Location: https://www.typekey.com/t/typekey/login?t=0NTLU925g4FfXP94wt43&need_email=1&_return=http://qwik.jp/irce/.typekey&v=1.1
      #p baseurl
      return_url = nil
      cookie = nil
      response = get( "", ".typekey" )
      redir_url = URI.parse( response[ 'Location' ] )
      #p response
      #p redir_url
      http_tk = Net::HTTP.new( redir_url.host, redir_url.port )
      if redir_url.scheme == "https"
         http_tk.use_ssl = true
         #http_tk.ca_file = '/var/ssl/cert.pem'
         #http_tk.verify_mode = OpenSSL::SSL::VERIFY_PEER
         #http_tk.verify_depth = 5
      end
      http_tk.start do |conn|
         conn.get( redir_url.request_uri )
         data = redir_url.query + "&__mode=save_login&username=#{ username }&password=#{ password }"
         #__mode=save_login&_return=http%3A%2F%2Fqwik.jp%2Firce%2F.typekey&t=0NTLU925g4FfXP94wt43&v=1.1&username=#{ username }&password=#{ password }&layout=&need_email=1&keep_me=1
         #p data
         login_response = conn.post( "/t/typekey", data )
         login_session = parse_cookie( login_response )
         #p login_response.canonical_each{|k, v| }
         #p login_response.body
         #p login_session
         header = { "Cookie" => login_session.keys.map{|c| "#{c}=#{login_session[c]}" }.join("; ") }
         data = redir_url.query + "&__mode=save_login&pass_email=1"
         #__mode=save_login&v=1.1&t=0NTLU925g4FfXP94wt43&_return=http%3A%2F%2Fqwik.jp%2Firce%2F.typekey&pass_email=1&need_email=1
         login_response2 = conn.post( "/t/typekey", data, header )
         #p login_response2.body
         #p login_response2.canonical_each{|k, v| }
         #p login_response2[ 'Location' ]
         return_url = URI.parse( login_response2[ 'Location' ] )
      end
      Net::HTTP.start( return_url.host, return_url.port ) do |http|
         response = http.get( return_url.request_uri )
         cookie = parse_cookie( response )
         #p cookie
         #p response.body
      end
      cookie
   end

   def parse_cookie( response )
      cookies = response.get_fields('Set-Cookie') # Ruby 1.8.3
      #STDERR.puts cookies.inspect
      session = {}
      if cookies
         cookies.each do |cookie|
            c, *attrs = cookie.split(/\s*;\s*/)
            if /^(\w+)=(\w+)$/ =~ c
               cname = $1
               val = $2
               session[cname] = val
            else
               raise "Cookie error: #{c}"
            end
            attrs.each do |e|
               if /^(\w+)=(.*)$/ =~ e
                  if $1 == "expires" and Time.parse( $2 ) < Time.now
                     session.delete( cname )
                  end
               end
            end
         end
         @token.update( session ) if @token
      end
      session
   end

   def get( page, mode )
      unless @conn.active?
         STDERR.puts "reactivate conn"
         @conn.start
      end
      @conn.get( @baseurl.path + page + mode, @cookie )
   end
   def get_html( page )
      get( page, ".html" )
   end
   def get_edit( page )
      get( page, ".edit" )
   end

   def get_titlelist
      files = []
      get_html( "TitleList" ).body.gsub(/<a href=\"([^\"]+)\"/) do
         file = $1
         next if file.include?("/")
         next if file[0] == ?.
         files << file
      end
      files
   end

   def get_txt( page )
      response = get_edit( page )
      if /<textarea [^>]*name=\"contents\"[^>]*>(.*)<\/textarea/mo =~ response.body
         $1
      end
   end

   def get_attach_list( page )
      files = []
      response = get_edit( page )
      response.body.gsub(/<a href=\"(#{ page }.download\/[^\"]+)\"/) do
         files << $1
      end
      files
   end
end

if $0 == __FILE__
   QWIKPASS = File.join( ENV["HOME"], ".qwikpass" )
   username, password = open( QWIKPASS ){|io| io.read }.chomp.split(/:/)
   qwik = QwikBackup.new( "http://qwik.jp/irce/", username, password )
   #puts qwik.get_txt( "1" )
   qwik.get_titlelist.each do |page|
      page.sub!(/\..*$/, "")
      files = qwik.get_attach_list( page )
      p files
      files.each do |file|
         response = qwik.get( file, "" )
         dir = File.dirname( file )
         begin
            Dir.mkdir( dir )
         rescue Errno::EEXIST
         end
         open( file, "w" ) do |io|
            io.print response.body
         end
      end
   end
end
