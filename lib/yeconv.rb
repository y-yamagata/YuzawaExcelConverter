require 'yeconv/converter'
require 'yeconv/elements'
require 'yeconv/formatters'
require 'yeconv/loaders'
require 'yeconv/mapping'
require 'yeconv/path'
require 'yeconv/recipe'
require 'yeconv/serializers'
require 'yeconv/source'
require 'yeconv/workspace'

module YEConv
  class ConverterError < StandardError; end

  # Convert excel files to any files with config string
  #
  # @param config_string [String] the config string
  # @param options [Hash] the options hash
  # @option options [String] :output_dir
  # @return [YEConv::Converter::ResultSet] result set
  def self.convert(string_or_io, **options)
    converter = YEConv::Converter.new(string_or_io, **options)
    converter.convert(options[:keys], pretty: options[:pretty])
  end

  # Convert excel files to any files from config file
  #
  # @param config_path [String] the config file path
  # @param options [Hash] the options hash
  # @option options [String] :output_dir
  # @return [YEConv::Converter::ResultSet] result set
  def self.convert_with_file(config_path, **options)
    config = File.read(config_path, :encoding => 'utf-8')
    YEConv::convert(config, **options)
  end
end
