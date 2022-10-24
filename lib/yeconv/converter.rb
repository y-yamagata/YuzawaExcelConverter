require 'tomlrb'

module YEConv
  class Converter
    class ResultSet
      Result = Struct.new('Result', :key, :is_success, :error)

      def initialize
        @results = {}
      end

      def add(result)
        key = result.key.to_sym
        @results[key] = result
      end

      def success?(key)
        key = key.to_sym
        @results[key] && @results[key].is_success
      end

      def error(key)
        key = key.to_sym
        @results[key] && @results[key].error
      end

      def each(&block)
        @results.each do |k, r|
          block.call(r)
        end
      end
    end

    def initialize(string_or_io, **options)
      begin
        @configs = Tomlrb.parse(string_or_io, symbolize_keys: true)
        @recipes = {}
        @output_dir = options[:output_dir]
      rescue Tomlrb::ParseError => e
        raise ConverterError.new(e.message)
      end
    end

    def convert(keys=nil, pretty: false)
      results = ResultSet.new
      @configs.each do |k, c|
        if keys && !keys.include?(k.to_s)
          next
        end
        begin
          recipe = compile(k, c)
          recipe.convert(pretty)
          results.add(ResultSet::Result.new(k, true, nil))
        rescue => e
          results.add(ResultSet::Result.new(k, false, e))
        end
      end
      results
    end

    private

    def compile(key, config)
      if @recipes.has_key?(key)
        return @recipes[key]
      end
      recipe = Recipe.new(key, config, output_dir: @output_dir)
      @recipes[key] = recipe
      recipe
    end
  end
end
