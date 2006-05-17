#!/usr/bin/env ruby
# $Id$

require "nkf"

# link => :last_modified
FILES = [
         "firefox.html",
         "ir-journal.html",
         "unihan-onkun.html",
         "zipcode.cgi",
         "test-ttf.php",
         "paper-checklist.html",
         "wikiwiki.html",
         "windows-software.html",
         "clover-papi.html",
         "rpm.html",
         "emacs20-unicode.html",
         "config.html",
        ]

def title( file )
   open(file){|io|
      if /<title>(.+?)<\/title>/ =~ io.read
         title = $1
         NKF.nkf("-m0 -e", title)
      end
   }
end

FILES.sort_by{|f|
   [ File.mtime( f ), f ]
}.reverse.each do |f|
   puts %Q(<li><a href="#{f}">#{title( f )}</a>)
end
