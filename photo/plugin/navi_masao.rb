#!ruby
# $Id$

alias :_orig_navi :navi

def navi
   #_orig_navi
   if @cgi.server_name == "localhost"
      _orig_navi
   else
      _orig_navi.split(/\n/).find_all{|e| e !~ /#{@conf.update}/ }.join("\n")
   end
end
