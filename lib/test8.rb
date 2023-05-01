require 'open-uri'

url = "http://ruby.bastardsbook.com/files/fundamentals/hamlet.txt"

File.open('hamlet.txt', 'w') do |file|
  remote_hamlet_text = URI.open(url).read
  file.write(remote_hamlet_text)
end

lines = nil
File.open('hamlet.txt', 'r') do |file|
  lines = file.readlines
end

lines.each_with_index do |line, index|
  if (index + 1) % 42 == 41
    puts line
  end
end
