#!/usr/local/bin/ruby
# $Id$
#
# 使い方：
# nkf -Se ken_all.csv | ruby zipcode.rb

require 'ftools'
require 'dbi'

DBNAME = "zipcode.db"
DBNAME_TMP = DBNAME + ".tmp"

CREATE_TABLE = <<EOF
CREATE TABLE zipcode (
       zipcode7	  TEXT,
       pref	  TEXT,
       city	  TEXT,
       city_yomi  TEXT,
       town	  TEXT,
       town_yomi  TEXT
       );
EOF

if FileTest.exist? DBNAME
   File.cp(DBNAME, DBNAME + ".old", true)
end

dbh = DBI.connect("dbi:SQLite:#{DBNAME_TMP}")
dbh['AutoCommit'] = false

dbh.transaction do
   dbh.do(CREATE_TABLE)
   sth = dbh.prepare("INSERT INTO zipcode VALUES(?, ?, ?, ?, ?, ?)");
   logfile = open("zipcode.log.#{Time.now.strftime("%Y%m%d")}", "w")
   ARGF.each_line do |line|
      data = line.split(/,/).map{|e| e.sub(/^\"(.*)\"$/, '\1'); }
      sth.execute(data[2], data[6], data[7], data[4], data[8], data[5]);
      logfile.puts [ data[2], data[6], data[7], data[8] ].join(" ")
   end
   logfile.close
end

File.mv(DBNAME_TMP, DBNAME, true)
