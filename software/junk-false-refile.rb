#!/usr/local/bin/ruby
# $Id$

TOSPAM_DIR	= "/home/masao/Mail/junk.tospam"
TOCLEAN_DIR	= "/home/masao/Mail/junk.toclean"

BSFILTER = "/home/masao/bin/bsfilter"
REFILE = "/usr/local/bin/mh/refile"

Dir::open( TOSPAM_DIR ) do |dir|
	dir.each do |f|
		next unless f =~ /^\d+$/
		unless system( BSFILTER, "-s", "-C", "-u", TOSPAM_DIR + "/" + f )
			raise "bsfilter failed."
		end
		system( BSFILTER, TOSPAM_DIR + "/" + f )
		if ($?.to_i / 256) == 0 then
			system( REFILE, "-src", "+junk.tospam", f, "+junk" )
			puts "#{f} refile done."
		else
			puts "#{f} must be re-validate."
		end
	end
end
