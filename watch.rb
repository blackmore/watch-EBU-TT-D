#encoding: UTF-8
root = File.expand_path('../', __FILE__)
require 'fileutils'
require "#{root}/config/enviroment"



class Watch
  attr_accessor :file

  def initialize(file)
    reg_win_ends = /\r\n/
    reg_1line_f = /(\d\d\d\d\s:.+:\d\d.+)(\n\[..\].+\n)(\[\]\n)+\n/
    reg_2line_f = /(\d\d\d\d\s:.+:\d\d.+)(\n\[..\].+\n\[..\].+\n)(\[\]\n)+\n/

    file_name = File.basename(file, ".txt")
  
    begin
      text = File.read(file, :encoding => 'utf-8').encode!(Encoding::UTF_8)
      text.gsub!(reg_win_ends,"\n")
      text.gsub!(reg_1line_f, "\\1\\2\[\]\n\[\]\n\[\]\n\[\]\n\[\]\n\[\]\n\[\]\n\[\]\n\n")
      text.gsub!(reg_2line_f, "\\1\\2\[\]\n\[\]\n\[\]\n\[\]\n\[\]\n\[\]\n\[\]\n\n")
      text.gsub!("\n", "\r\n")


      #puts text.force_encoding("UTF-8")
      File.open("#{TARGET_ONE}/#{file_name}.txt", 'w'){|file| file.write(text)}
      FileUtils.cp("#{TARGET_ONE}/#{file_name}.txt", "#{TARGET_TWO}/#{file_name}.txt")
      FileUtils.mv("#{SOURCE_PATH}/#{file_name}.txt", "#{PROCESSED_PATH}/#{file_name}.txt")
    
    
    rescue => err
      puts "Exception: #{err}"
      err
    end
  end
  
end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# 
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

Dir.chdir(SOURCE_PATH)

files = Dir['**'].collect

files.each do |file|
  # not required but need only process text files
  # next if /_midi/.match(file)

  if File.file?(file)
    dir, base = File.split(file)
    Watch.new(file)
  end
end



