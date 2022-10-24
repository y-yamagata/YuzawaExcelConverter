module YEConv
  def self.to_bool(v)
    if is_bool?(v)
      return v;
    end
    if v.is_a?(String)
      return v == 'false' || v == 'False' || v == 'FALSE' || v == '0' || v.empty? ? false : true
    end
    if v.is_a?(Integer) || v.is_a?(Float)
      return v == 0 ? false : true
    end
    if v.nil?
      return false
    end
    return true
  end

  def self.is_bool?(v)
    v.is_a?(TrueClass) || v.is_a?(FalseClass)
  end

  def self.debbug(v)
    puts "\n===\n#{v}\n==="
  end
end
