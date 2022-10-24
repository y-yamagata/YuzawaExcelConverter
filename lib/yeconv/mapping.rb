module YEConv
  class Mapping
    def initialize(mapping)
      output_type = Element::get_type(mapping[:type])
      unless output_type
        raise ConverterError.new("No support for the type, #{mapping[:type]}")
      end
      unless mapping[:destination]
        raise ConverterError.new("Mapping destination is required")
      end
      unless mapping[:source]
        raise ConverterError.new("Mapping source is required")
      end
      @output_type = output_type
      @destination_path = Path.new(mapping[:destination])
      @source = Source::create(mapping.merge(mapping[:source]))
      @formatter = nil
      if mapping[:format]
        @formatter = YEConv::Formatter::create(mapping[:format][:type], **mapping[:format][:args])
      end
    end

    def apply(workspace)
      workspace.set(@destination_path, @output_type, @source, formatter: @formatter)
    end
  end
end
