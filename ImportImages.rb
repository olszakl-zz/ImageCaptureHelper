#!/usr/bin/env ruby

require 'FileUtils'
require 'optparse'

year = "2019"
images = []
videos = []

IMPORT="/Users/lionheart/Pictures/0_IMPORT/"
EXPORT="/Users/lionheart/Pictures/2_EXPORT/#{year}/#{year}0000_other/"

def mime_type(file)
  return `file --brief --mime-type #{file} | awk -F/ '{print $1}'`
end

Dir.chdir(EXPORT)
last_image = Dir.children('.').reject{|f| File.directory?(f)}.sort_by{|f| File.basename(f)}.last.scan(/\d{5}.JPG/)[0].split('.')[0]
last_movie = Dir.children('movies/.').reject{|f| File.directory?(f)}.sort_by{|f| File.basename(f)}.last.scan(/\d{4}\./)[0][0...-1]

Dir.chdir(IMPORT)
Dir.children('.').each do |file|
  File.rename(file, file.gsub(/\s+/, '_'))
end

Dir.children('.').each do |file|
  type = mime_type(file)
  images << file if type =~ /image/
  videos << file if type =~ /video/
end

unless images.empty?
  images.sort_by{ |f| File.birthtime(f) }.each do |image|
    renamed = File.new(image).birthtime.to_s.split(' ')[0].gsub("-",'') + "_export_#{last_image.next!}#{File.extname(image)}"
    FileUtils.mv(image,"#{EXPORT}#{renamed}")
  end
else
  puts "No images found."
end

unless videos.empty?
  videos.sort_by{ |f| File.birthtime(f) }.each do |movie|
    renamed = File.new(movie).birthtime.to_s.split(' ')[0].gsub("-",'') + "_#{last_movie.next!}#{File.extname(movie)}"
    FileUtils.mv(movie,"#{EXPORT}#{renamed}")
  end
else
  puts "No videos found."
end
