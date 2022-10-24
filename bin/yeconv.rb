#!/usr/bin/env ruby

require "fileutils"
require 'optparse'

require 'bundler'

Bundler.require

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'yeconv'

class Options
  attr_reader :config_file, :output_dir, :target_keys, :pretty

  def initialize
    @config_file = nil
    @output_dir = Dir.pwd
    @target_keys = nil
    @pretty = false

    @parser = OptionParser.new
    @parser.banner = 'Usage: app.py [options]'
    @parser.on('-c', '--config FILE') { |file| @config_file = file }
    @parser.on('-o', '--output DIR') { |dir| @output_dir = dir }
    @parser.on('-t', '--target TARGET_LIST', klass=Array) { |list| @target_keys = list }
    @parser.on('-p', '--pretty') { |f| @pretty = f }
    @parser.on_tail('-h', '--help') { |v| puts @parser.help; exit }
  end

  def parse(args)
    rest_args = @parser.parse(args)
    unless @config_file
      raise StandardError.new('設定ファイルが指定されていません')
    end
    unless File.exist?(@config_file)
      raise StandardError.new("設定ファイルが存在しません(config_file=#{@config_file})")
    end
    FileUtils.mkdir_p(@output_dir)
    rest_args
  end
end

def main(args)
  begin
    options = Options.new
    options.parse(args)
    results = YEConv::convert_with_file(options.config_file,
                                        :output_dir => options.output_dir,
                                        :keys => options.target_keys,
                                        :pretty => options.pretty)
    results.each do |r|
      if r.is_success
        puts "#{r.key}: success!!"
      else
        puts "#{r.key}: failure!!, #{r.error.message}"
      end
    end
  rescue => e
    STDERR.puts e.message
  end
end

main(ARGV)
