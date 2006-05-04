#!ruby
# $Id$

alias :_orig_navi :navi

def navi
   STDERR.puts @cgi.server_name
   if @cgi.server_name == "local_host"
      _orig_navi
   else
      _orig_navi.split(/\n/).find_all{|e| e !~ /#{@conf.update}/ }.join("\n")
   end
end
