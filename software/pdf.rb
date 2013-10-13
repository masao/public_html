#!/usr/local/bin/ruby

require "zlib"
require "pp"

CR = "(?:\r\n|\n|\r)"
class PDF
   def initialize
   end
end

cont = ARGF.read
puts cont[/\A.*?#{CR}/]
while cont =~ /^%.*?#{CR}/
   cont.sub!(/^%.*?#{CR}/, "")
end

obj = {}
trailer = []
startxref = 0

until cont.empty?
   if cont =~ /\A\s+/
      cont.sub!(/\A\s+/, "")
   elsif cont =~ /\A(\d+ \d+ obj)(.*?)endobj#{CR}?/m
      obj[$1] = $2
      cont.sub!(/\A(\d+ \d+ obj)(.*?)endobj#{CR}?/m, "")
   elsif cont =~ /\Axref#{CR}(\d+) (\d+)#{CR}/
      cont.sub!(/\Axref#{CR}(\d+) (\d+)#{CR}/, "")
      xrefs = $2.to_i
      xrefs.times do
         cont.sub!(/\A(.*#{CR})/, "")
      end
   elsif cont =~ /\Atrailer\s*<<(.*?)>>\s*/m
      trailer << $1
      cont.sub!(/\Atrailer\s*<<(.*?)>>/m, "")
   elsif cont =~ /\Astartxref#{CR}(\d+)#{CR}/
      startxref = $1
      cont.sub!(/\Astartxref#{CR}(\d+)#{CR}/, "")
   else
      #break
   end
end

p trailer

@info = {}
trailer.each do |t|
   if t =~ /\/Root\s*(\d+ \d+) R/
      @info["/Root"] = obj["#$1 obj"]
   end
end
if @info["/Root"] and @info["/Root"] =~ /\/Pages\s*(\d+ \d+) R/
   @info["/Pages"] = obj["#$1 obj"]
   p @info["/Pages"]
end
if @info["/Pages"] and @info["/Pages"] =~ /\/Kids\s*\[((\d+ \d+ R\s*)+)\]/
   @info["/Kids"] = []
   $1.split(/(\d+ \d+) R\s*/).each do |e|
      next if e.empty?
      @info["/Kids"] << obj["#{e} obj"]
   end
   p @info["/Kids"]
end
if @info["/Kids"]
   @info["/Kids"].each do |page|
      @info["/Contents"] = []
      if page =~ /\/Contents (\d+ \d+) R/
         @info["/Contents"] << obj["#$1 obj"]
      end
   end
   p @info["/Contents"][0]
end

# p obj
# @info["/Contents"] << obj["52 0 obj"] 
if @info["/Contents"]
   @info["stream"] = []
   @info["/Contents"].each do |cont|
      #puts cont
      if cont =~ /stream#{CR}(.*?)#{CR}endstream#{CR}/ms
         stream = $1
         #puts stream
         if cont =~ /\/Filter\s*\/FlateDecode/
            stream = Zlib::Inflate.inflate(stream)
         end
         p stream
         open("z","w"){|io| io.print stream }
         @info["stream"] << stream
      end
   end
end

#pp obj
pp @info
