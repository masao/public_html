#!/usr/local/bin/ruby
# $Id$
#
# 使い方：
# nkf -Se ken_all.csv | ruby zipcode.rb | sqlite zipcode.db

MAX = nil

puts <<EOF
BEGIN;
CREATE TABLE zipcode (
       code	  TEXT,
       zipcode5	  TEXT,
       zipcode7	  TEXT,
       pref	  TEXT,
       pref_yomi  TEXT,
       city	  TEXT,
       city_yomi  TEXT,
       town	  TEXT,
       town_yomi  TEXT
       );
EOF

i = 0
STDIN.each_line do |l|
   i += 1
   data = l.split(/,/)
   STDERR.puts data[2]
   puts "INSERT INTO zipcode VALUES(#{data[0]}, #{data[1]}, #{data[2]}, #{data[6]}, #{data[3]}, #{data[7]}, #{data[4]}, #{data[8]}, #{data[5]});"
   if MAX and i > MAX
      break;
   end
end
puts "COMMIT;"
