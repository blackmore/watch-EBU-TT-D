#encoding: UTF-8
root = File.expand_path('../', __FILE__)
require 'fileutils'
require 'nokogiri'
require "#{root}/config/enviroment"


class Watch

  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
  # tweak EZTitles EBU-TT-D files to meet the BBC's EBU-TT-D
  # specifications. This will be part of a automated workflow to
  # for file coversion
  # - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

  attr_accessor :file

  def initialize(file)

    begin

    # xml_doc  = Nokogiri::XML(file)
    @doc = Nokogiri::XML(File.open(file))
    file_name = File.basename(file, ".xml")

    # remove the backgroundColor attribute form the default style
    default_style = @doc.xpath('//tt:style', '//*[@xml:id="defaultStyle"]')
    default_style.xpath("//@tts:backgroundColor").remove

    # ensure that the language code is en-GB
    tt_tt = @doc.at_xpath('//tt:tt')# = "ee"
    tt_tt['xml:lang'] = 'en-GB'


    # find nested spans place them after parent changing the style to
    # textFFFFFFOn000000
    spans = @doc.xpath('//tt:span')

    spans.each do |span|
      unless span.elements.empty?
        span.elements.each do |element|
          self.set_style element
          #element['style'] = "textFFFFFFOn000000Italic"
          puts element
          element.parent.after self.set_style element
        end
      end

    end

    File.write("#{TARGET_ONE}/#{file_name}.xml", @doc.to_xml)
    FileUtils.mv("#{SOURCE_PATH}/#{file_name}.xml", "#{PROCESSED_PATH}/#{file_name}.xml")

    rescue => err
      puts "Exception: #{err}"
      err
    end
  end

  def set_style node
    if node['style'] == 'textItalic'
      node['style'] = 'textFFFFFFOn000000Italic'
    else
      node
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
