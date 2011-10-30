#!/usr/bin/env ruby
# $Id$

require "date"

DATA_FILE = "bicycle-meter.txt"

dates = open( DATA_FILE ){|io| io.readlines }.map{|e| e.split[0] }
first_date = Date.parse( dates[0]  ) - 7
last_date  = Date.parse( dates[-1] ) + 7

monthes = (first_date .. last_date).to_a.select{|d| d.day == 1 }
bi_monthes = monthes.select{|d|	# for thumbnail
   d.month % 2 == 1 and d.day == 1
}
tri_monthes = monthes.select{|d|	# for thumbnail
   d.month % 3 == 1 and d.day == 1
}
#p monthes.map{|e| e.to_s }

open( "|gnuplot", "w" ) do |gnuplot|
   gnuplot.puts "set term png transparent"
   gnuplot.puts "set out 'bicycle-meter.png'"
   gnuplot.puts <<EOF
	  set title "(Cycling meter)"
	  set xdata time
	  set timefmt "%Y-%m-%d"
	  set format x "%Y-%m-%d"
	  set xtic rotate
	  set bmargin 6
	  set ylabel "Distance (km)"
	  set y2label "Cumulative Distance (km)"
	  set y2tics autofreq
	  set xtics ( #{ monthes.map{|d| %Q["#{d.to_s}"] }.join(",") } )
	  plot ["#{first_date.to_s}":"#{last_date.to_s}"] \
		"#{DATA_FILE}" using 1:2 with impulses lw 3 title "Distance (km)", \
		"#{DATA_FILE}" using 1:4 axes x1y2 with steps title "Cumulative distance (km)"
EOF
   # Thumbnail:
   gnuplot.puts <<EOF
  	  set size .4
	  set out "bicycle-meter-s.png"
	  set xtics ( #{ tri_monthes.map{|d| %Q["#{d.to_s}"] }.join(",") } )
	  set y2label "Cumulative Distance (km)" 0,-3
	  plot ["#{first_date.to_s}":"#{last_date.to_s}"] \
		"#{DATA_FILE}" using 1:2 with impulses lw 3 notitle, \
		"#{DATA_FILE}" using 1:4 axes x1y2 with steps notitle
EOF
end
