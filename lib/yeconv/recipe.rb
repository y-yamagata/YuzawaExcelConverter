require 'pathname'

module YEConv
  PathSet = Struct.new('PathSet', :path, :filename) do
    def make(extention)
      extention = extention.delete_prefix('.')
      path_filename = Pathname.new(filename).basename(".#{extention}")
      Pathname.new(path).join(path_filename).to_s + '.' + extention
    end
  end

  class Recipe
    attr_reader :id

    def initialize(id, config, output_dir: Dir.pwd)
      unless config[:uri]
        raise ConverterError.new("URI is required")
      end
      output_filename = !config[:output_filename] ? id : config[:output_filename]
      unless config[:format_type]
        raise ConverterError.new("Format type is required")
      end
      unless config[:mappings]
        raise ConverterError.new("Mappings is required")
      end
      format_types = config[:format_type].is_a?(Array) ? config[:format_type] : [config[:format_type]]
      @id = id
      @uri = config[:uri]
      @pathset = PathSet.new(output_dir, output_filename)
      @format_types = format_types
      mapping_config = { :sheet => config[:sheet] }
      @mappings = config[:mappings].map { |m| Mapping.new(mapping_config.merge(m)) }
    end

    def make
      workspace = WorkSpace.new(Loader::Loaders.load(@uri))
      workspace.set(Path.new('origin'), Element::Type::String, Source::Fixed.new({ :value => @uri }))
      @mappings.each { |m| m.apply(workspace) }
      workspace.build()
    end

    def convert(pretty=false)
      data = make()
      @format_types.each do |type|
        Serializer::Serializers.output(type, data, @pathset, pretty: pretty)
      end
    end
  end
end
