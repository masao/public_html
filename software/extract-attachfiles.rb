#!/usr/bin/env ruby

require "mailread"
require "stringio"
require "base64"

ARGV.each do |f|
   m = Mail.new(open f)
   if m["Content-Type"] =~ /^multipart\/mixed;\s*boundary=(\"?)([^\s\"]+)\1/
      boundary = $2
      body = m.body
      #p body
      parts = body.join.split(/^--#{Regexp.escape(boundary)}(--)?\n/)
      parts.shift # blank part.
      #p parts
      parts.each do |mm|
	 filename = nil
	 mailpart = Mail.new(StringIO.new(mm))
	 if mailpart["Content-Disposition"] =~ /filename=(\"?)([^\s\"]+)\1/
	    filename = $2
	 end
	 cont = mailpart.body.join
	 if mailpart["Content-Disposition"] =~ /base64/
	    cont = Base64.decode64( cont )
	 end
 	 if filename
#            p [f, filename]
#            print cont
 	    open(filename, "w") do |io|
 	       io.print cont
 	    end
 	 end
      end
   end
end


