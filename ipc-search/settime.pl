#!/usr/local/bin/perl

use MD5;
$md5 = new MD5;

$file = '/home/masao/public_html/ipc-search/digest';
$dir = '/home/masao/Namazu/ipc-search/www.ulis.ac.jp/';
$cmd_find = '/usr/bin/find';

undef %old;
if (open(IN, $file)) {
    while (<IN>) {
        chomp;
        split(/\t/, $_, 2);
        $old{$_[0]} = $_[1];
    }
    close(IN);
}

open(IN, "$cmd_find $dir -type f -print |") || die "Can't exec $cmd_find";
open(OUT, "> $file.new") || die "Can't open $file.new";
while ($f = <IN>) {
    chomp($f);
    @stat = stat($f);
    $mtime = $stat[9];
    $size = $stat[7];
    if (defined($old{$f})) {
        ($mtime_old, $size_old, $digest_old) = split(/\t/, $old{$f});
        if ($mtime == $mtime_old && $size == $size_old) {
            $digest = $digest_old;
        } else {
            open(F, $f) || next;
            $md5->reset;
            $md5->addfile(F);
            $digest = $md5->hexdigest;
            close(F);
            if ($size == $size_old && $digest eq $digest_old) {
                $mtime = $mtime_old;
                utime(time, $mtime, $f);
            }
        }
    } else {
        open(F, $f) || next;
        $md5->reset;
        $md5->addfile(F);
        $digest = $md5->hexdigest;
        close(F);
    }
    print OUT join("\t", $f, $mtime, $size, $digest)."\n";
}
close(OUT);
close(IN);

if (-e $file) {
    rename($file, "$file.old") || die "Can't rename $file";
}
rename("$file.new", $file) || die "Can't rename $file.new";

exit 0;
