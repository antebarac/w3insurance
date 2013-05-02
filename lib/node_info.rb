class NodeInfo
  attr_reader :visible, :default_value

  def initialize(visible, default_value = nil)
    @visible = visible
    @default_value = default_value
  end

  def ==(other)
    @visible == other.visible && @default_value.to_s == other.default_value.to_s 
  end

end
