#!/usr/bin/env ruby
# $Id$

require "date"

DATA_FILE = "bicycle-meter.txt"

dates = open( DATA_FILE ){|io| io.readlines }.map{|e| e.split[0] }
first_date = Date.parse( dates[0]  ) - 7
last_date  = Date.parse( dates[-1] ) + 7

monthes = (first_date .. last_date).to_a.select{|d| d.day == 1 }
#p monthes.map{|e| e.to_s }

open( "|gnuplot", "w" ) do |gnuplot|
   gnuplot.puts "set term png transparent"
   gnuplot.puts "set out 'bicycle-meter.png'"
   gnuplot.puts <<EOF
	  set xdata time
	  set timefmt "%Y-%m-%d"
	  set format x "%Y-%m-%d"
	  set xtic rotate
	  set bmargin 6
	  set ylabel "Distance (km)"
	  set xtics ( #{ monthes.map{|d| %Q["#{d.to_s}"] }.join(",") } )
	  plot ["#{first_date.to_s}":"#{last_date.to_s}"] "#{DATA_FILE}" \
		using 1:2 with impulses lw 3 \
		notitle
EOF
   # Thumbnail:
   gnuplot.puts <<EOF
  	  set size .4
	  set out "bicycle-meter-s.png"
	  plot ["#{first_date.to_s}":"#{last_date.to_s}"] "#{DATA_FILE}" \
		using 1:2 with impulses lw 3 \
		notitle
EOF
end
