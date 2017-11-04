class Object
  # Alias of <tt>to_s</tt>.
  def to_attrs
    to_s
  end
end

class NilClass
  # Returns +self+.
  def to_attrs
    self
  end
end

class TrueClass
  # Returns +self+.
  def to_attrs
    self
  end
end

class FalseClass
  # Returns +self+.
  def to_attrs
    self
  end
end

class Array
  # Calls <tt>to_param</tt> on all its elements
  def to_attrs
    collect(&:to_attrs)
  end

end

class Hash
  def to_attrs
    hash = self.clone
    hash.each do |k,v|
      hash[k] = v.to_attrs
    end
    hash
  end
end
