#! /usr/local/bin/ruby
# $Id$

NEWS_URI = "http://www.slis.tsukuba.ac.jp/ipc/ipnews/ipcnews_new.html"

# �˥塼���������ܤ��Ĥ򰷤����饹
class NewsItem
   attr_accessor :title, :lastmodified, :description
   def initialize (title, description, lastmodified)
      @title = title
      @description = description
      @lastmodified = lastmodified
   end
end
