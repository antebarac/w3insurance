class Range
  def overlap?(other)
    if self.first > other.first then return other.overlap?(self) end
    if self.first == other.first || self.last == other.last then return true end
    if self.last > other.first then return true end  
  end
  def negative?
    if self.first < 0 || self.last < 0 then return true end
    false
  end
  def descending?
    if self.first > self.last then return true end
    false
  end
end