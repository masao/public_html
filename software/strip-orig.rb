#!/usr/local/bin/ruby
# $Id$

# HTML 文書の翻訳などで使うスクリプト:
#  class="orig" 属性の指定された要素を完全に削除する。

puts ARGF.read.gsub(/<(\w+)\s+class="orig">((?:(?!<\1).)*?)(<\1[^>]*>.*?<\/\1>)*((?:(?!<\1).)*?)<\/\1>/m, '')
