require 'open-uri'

url = "http://ruby.bastardsbook.com/files/fundamentals/hamlet.txt"
puts URI.open(url).readline
