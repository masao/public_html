#!/usr/local/bin/ruby
# $Id$
#
# 使い方：
# nkf -Se ken_all.csv | ruby zipcode.rb

require 'dbi'

DBNAME = "zipcode.db"

CREATE_TABLE = <<EOF
CREATE TABLE zipcode (
       code	  TEXT,
       zipcode7	  TEXT,
       pref	  TEXT,
       city	  TEXT,
       city_yomi  TEXT,
       town	  TEXT,
       town_yomi  TEXT
       );
EOF

if FileTest.exist? DBNAME
   File.unlink DBNAME
end

dbh = DBI.connect("dbi:SQLite:#{DBNAME}")
dbh['AutoCommit'] = false

dbh.transaction do
   dbh.do(CREATE_TABLE)
   sth = dbh.prepare("INSERT INTO zipcode VALUES(?, ?, ?, ?, ?, ?, ?)");
   ARGF.each_line do |line|
      data = line.split(/,/).map{|e| e.sub(/^\"(.*)\"$/, '\1'); }
      sth.execute(data[0], data[2], data[6], data[7], data[4], data[8], data[5]);
   end
end
