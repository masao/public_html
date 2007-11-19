# $Id$
#

# Rsync to http://research.nii.ac.jp/~masao/ ...
rsync:
	../rsync.pl research:public_html/200711cres/form/data/ ./200711cres/form/data/
	../rsync.pl -L --exclude=CVS --delete-after ./ research:public_html/
