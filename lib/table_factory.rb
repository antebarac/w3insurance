class TableFactory
  def self.create(blok)
      if TableN.definition_ok? blok
        return TableN.new(blok)
      else
        return Table.new(blok)
      end
  end

  def self.add(target, table)
    if target == nil
       target = table
    else 
       target += table
    end
    target
  end

  def self.combine(target, table)
    if target == nil
       target = table
    else 
       target |= table
    end
    target
  end
end
