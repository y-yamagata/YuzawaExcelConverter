module YEConv
  module Formatter
    class Floor
      def initialize(ndigits: 0, **)
        @ndigits = ndigits
      end

      def call(v)
        if v.nil?
          return nil
        end
        v.to_f.floor(@ndigits)
      end
    end

    class Ceil
      def initialize(ndigits: 0, **)
        @ndigits = ndigits
      end

      def call(v)
        if v.nil?
          return nil
        end
        v.ceil(@ndigits)
      end
    end

    class Round
      def initialize(ndigits: 0, **)
        @ndigits = ndigits
      end

      def call(v)
        if v.nil?
          return nil
        end
        v.round(@ndigits)
      end
    end

    class Includes
      def initialize(substr: nil, **)
        @substr = substr
      end

      def call(v)
        unless @substr
          return true
        end
        if v.nil?
          return false
        end
        return v.include?(@substr)
      end
    end

    class Replace
      def initialize(src: nil, dist: nil, **)
        @src = src
        @dist = dist
      end

      def call(v)
        if !@src || !@dist
          return v
        end
        if v.nil?
          return v
        end
        v.gsub(@src, @dist)
      end
    end

    class Regexp
      def initialize(src: nil, dist: nil, **)
        @src = src && ::Regexp.new(src)
        @dist = dist
      end

      def call(v)
        if !@src || !@dist
          return v
        end
        if v.nil?
          return v
        end
        v.gsub(@src, @dist)
      end
    end

    NameToClass = {
      'floor' => Floor,
      'ceil' => Ceil,
      'round' => Round,
      'includes' => Includes,
      'replace' => Replace,
      'regexp' => Regexp,
    }

    def self.create(name, **options)
      klass = NameToClass[name]
      unless klass
        raise ConverterError.new("No support for the name, #{name}")
      end
      klass.new(**options)
    end
  end
end
