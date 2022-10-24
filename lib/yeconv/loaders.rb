require 'net/http'
require 'uri'
require 'rubyXL'

module YEConv
  module Loader
    class FileLoader
      def load(uri)
        RubyXL::Parser.parse(uri.path)
      end
    end

    class HttpLoader
      def load(uri)
        content = Net::HTTP.get(uri)
        RubyXL::Parser.parse_buffer(content)
      end
    end

    NameToClass = {
      'file' => FileLoader,
      'http' => HttpLoader
    }

    class Loaders
      @store = {}

      def self.get_loader(uri)
        uri = uri.is_a?(String) ? URI.parse(uri) : uri
        scheme = uri.scheme
        if scheme == 'https'
          scheme = 'http'
        elsif !uri.scheme
          scheme = 'file'
        end

        loader = @store[scheme]
        if loader
          return loader
        end

        klass = NameToClass[scheme]
        unless klass
          return nil
        end
        loader = klass.new
        @store[scheme] = loader
      end

      def self.load(path)
        uri = URI.parse(path)
        loader = get_loader(uri)
        unless loader
          raise ConverterError.new("No support for the scheme, #{uri.scheme}")
        end
        # Zip::Error might be thrown
        loader.load(uri)
      end
    end
  end
end
