#! /usr/local/bin/ruby
# $Id$

NEWS_URI = "http://www.slis.tsukuba.ac.jp/ipc/ipnews/ipcnews_new.html"

# ニュース記事一本ずつを扱うクラス
class NewsItem
   attr_accessor :title, :lastmodified, :description
   def initialize (title, description, lastmodified)
      @title = title
      @description = description
      @lastmodified = lastmodified
   end
end
