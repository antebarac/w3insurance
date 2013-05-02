#encoding: utf-8
class TableCombo
  def initialize
    @tables = Array.new
  end
  
  def |(other)
    if other.is_a?(Table) || other.is_a?(TableN)
      return self << other
    end
    raise "Invalid operation TableCombo | #{other.class}"
  end
  
  def <<(table)
    @tables.insert(0,table)
    return self
  end
  
  def evaluate(argument)
    results = Array.new
    @tables.each do |table|
      results << table.evaluate(argument)
    end
    results.compact!
    end_result = nil
    results.each do |result|
      if end_result == nil 
        end_result = result
      else
        result.each_key do |key|
          if end_result[key].to_s.strip == '-' && result[key].to_s.strip != "-" && key == :stopa_original
            end_result[key] = result[key] 
            end_result[:stopa_tip] = result[:stopa_tip]
          end
          if end_result[key] == nil && result[key] != nil
            end_result[key] = result[key]
          end
        end  
      end
    end
    return end_result
  end
  
  def evaluate_array(arguments)
    val = evaluate(arguments)
    return [val] unless val.nil?
    nil
  end
end
