#!/usr/local/bin/ruby
# $Id$

# HTML 文書の翻訳などで使うスクリプト:

# 以下の要素およびその内容を削除する
#
#  class="orig" 属性の指定された要素（原文）
#
#  class="draft-comment" 属性の指定された要素（草稿中のコメント）
#

puts ARGF.read.gsub(/<(\w+)\s+class="(orig|draft-comment)">((?:(?!<\1).)*?)(<\1[^>]*>.*?<\/\1>)*((?:(?!<\1).)*?)<\/\1>/m, '')
