#encoding: utf-8
class TableSum
  def initialize
    @tables = Array.new
  end
  
  def +(other)
    if other.is_a? Table
      return self << other
    end
    raise "Invalid operation TableSum + #{other.class}"
  end
  
  def <<(other)
    @tables << other
    return self
  end
  
  def evaluate(argument)
    results = Array.new
    @tables.each do |table|
      result = table.evaluate(argument)
      results << result unless result.nil? 
    end
    return results
  end
  
  alias evaluate_array evaluate
end
