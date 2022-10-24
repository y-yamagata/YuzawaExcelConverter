require 'rubyXL'

module YEConv
  module Source
    module Direction
      Vertical = 1
      Horizontal = 2
    end

    class Ref
      def initialize(sheet)
        @sheet = sheet
      end

      def self.ref2ind(cell)
        cell.is_a?(String) ? RubyXL::Reference.ref2ind(cell) : cell
      end

      def self.ref2row(row)
        row.is_a?(String) ? row.to_i - 1 : row
      end

      def self.ref2col(column)
        if column.is_a?(String)
          unless column =~ /\A([A-Z]+)\Z/
            raise ConverterError.new('Syntax error')
          end
          return Regexp.last_match(1).each_byte.inject(0) { |col, chr| col * 26 + (chr - 64) } - 1
        end
        column
      end

      def self.get_cell(worksheet, r, c)
        unless row = worksheet[r]
          return nil
        end
        row[c]
      end

      def self.empty?(value)
        if value.is_a?(String)
          return value.empty?
        end
        value.nil?
      end
    end

    class Fixed
      def initialize(config)
        @value = config[:value]
      end

      def values(*)
        [@value]
      end
    end

    class Join
      def initialize(config)
        base_config = { :sheet => config[:sheet] }
        @delimiter = config[:delimiter] || ''
        @refs = config[:refs].map { |c| YEConv::Source::create(base_config.merge(c)) }
      end

      def values(workbook)
        car = @refs.slice(0).values(workbook)
        cdr = @refs.slice(1, @refs.size).map { |r| r.values(workbook) }
        car.zip(*cdr).map { |r| r.join(@delimiter) }
      end
    end

    class Merge
      def initialize(config)
        base_config = { :sheet => config[:sheet] }
        @refs = config[:refs].map { |c| YEConv::Source::create(base_config.merge(c)) }
      end

      def values(workbook)
        @refs.inject([]) { |result, item| result + item.values(workbook) }
      end
    end

    class Cell < Ref
      def initialize(config)
        @position = self.class.ref2ind(config[:cell])
        super(config[:sheet])
      end

      def values(workbook)
        worksheet = workbook[@sheet]
        cell = worksheet[@position[0]][@position[1]]
        [cell.value]
      end
    end

    class Range < Ref
      def initialize(config)
        @from = self.class.ref2ind(config[:from])
        @to = self.class.ref2ind(config[:to])
        @skip_empty = config[:skip_empty]
        @direction = YEConv::Source::get_direction(config[:direction])
        super(config[:sheet])
      end

      def values(workbook)
        worksheet = workbook[@sheet]
        results = []
        row_range = @from[0]..@to[0]
        column_range = @from[1]..@to[1]
        if @direction == Direction::Horizontal
          row_range.each do |r|
            column_range.each do |c|
              cell = worksheet[r][c]
              if !cell.value || (@skip_empty && self.class.empty?(cell.value))
                next
              end
              results.append(cell.value)
            end
          end
        else
          column_range.each do |c|
            row_range.each do |r|
              cell = worksheet[r][c]
              if !cell.value || (@skip_empty && self.class.empty?(cell.value))
                next
              end
              results.append(cell.value)
            end
          end
        end
        results
      end
    end

    class Table < Ref
      def initialize(config)
        @direction = YEConv::Source::get_direction(config[:direction])
        @column = nil
        @start_column = nil
        @row = nil
        @start_row = nil
        if @direction == Direction::Horizontal
          @row = self.class.ref2row(config[:row])
          @start_column = self.class.ref2col(config[:start_column])
          @end_column = self.class.ref2col(config[:end_column])
        else
          @column = self.class.ref2col(config[:column])
          @start_row = self.class.ref2row(config[:start_row])
          @end_row = self.class.ref2row(config[:end_row])
        end
        @skip = config[:skip] || 1
        @skip_if_empty = config[:skip_if_empty] || false
        @end_if_empty = config[:end_if_empty] || false
        @copy_prev_if_empty = config[:copy_prev_if_empty] || false
        super(config[:sheet])
      end

      def values(workbook)
        worksheet = workbook[@sheet]
        results = []
        prev_value = nil
        if @direction == Direction::Horizontal
          column = @start_column
          while true do
            unless cell = self.class.get_cell(worksheet, @row, column)
              break
            end
            if (@end_column && @end_column < column) ||
               (@end_if_empty && self.class.empty?(cell.value))
              break
            end
            if @skip_if_empty && self.class.empty?(cell.value)
              column += @skip
              next
            end
            value = value
            if @copy_prev_if_empty && self.class.empty?(value)
              value = prev_value
            end
            results.append(value)
            prev_value = value
            column += @skip
          end
        else
          row = @start_row
          while true do
            unless cell = self.class.get_cell(worksheet, row, @column)
              break
            end
            if (@end_row && @end_row < row) ||
               (@end_if_empty && self.class.empty?(cell.value))
              break
            end
            if @skip_if_empty && self.class.empty?(cell.value)
              row += @skip
              next
            end
            value = cell.value
            if @copy_prev_if_empty && self.class.empty?(value)
              value = prev_value
            end
            results.append(value)
            prev_value = value
            row += @skip
          end
        end
        results
      end
    end

    NameToClass = {
      'fixed' => Fixed,
      'join' => Join,
      'merge' => Merge,
      'cell' => Cell,
      'range' => Range,
      'table' => Table,
    }
    NameToDirection = {
      'vertical' => Direction::Vertical,
      'horizontal' => Direction::Horizontal,
    }

    def self.get_direction(name)
      NameToDirection[name]
    end

    def self.get_source(name)
      NameToClass[name]
    end

    def self.create(config)
      klass = get_source(config[:type])
      unless klass
        raise ConverterError.new("No support for the source, #{config[:type]}")
      end
      klass.new(config)
    end
  end
end
