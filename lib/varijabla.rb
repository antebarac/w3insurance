require "bigdecimal"
	
class Varijabla
  attr_reader :naziv
  
  def initialize naziv
    @force_string = ( (naziv == 'oznaka') || (naziv.to_s == ':oznaka') )
    @naziv = naziv.strip.to_sym
  end
  
  def parsiraj_vrijednost(vrijednost)
    return nil if(vrijednost.strip == "-")
    return vrijednost.strip if @force_string

    case vrijednost.strip
    when /(\d+\.?\d*k?%?)-(\d+\.?\d*k?%?|inf\.)/
      if $2 == "inf." then return (parsiraj_broj($1)...79228162514264337593543950336) end
      return (parsiraj_broj($1)...parsiraj_broj($2))
    when /(\d+\.?\d*k?%?)\.\.(\d+\.?\d*k?%?|inf\.)/
      if $2 == "inf." then return (parsiraj_broj($1)..79228162514264337593543950336) end
      return (parsiraj_broj($1)..parsiraj_broj($2))
    when /^(\d+\.?\d*)(k?)(%?)$/
      return parsiraj_broj($&)
    when /^(\d+,?\d*)(k?)(%?)$/
      return parsiraj_broj($&.gsub(",", "."))
    when "true"
      return true
    when "false"
      return false
    else
      vrijednost
    end
  end

  def tip(broj)
    return :posto if broj.strip == "F"
    case broj
    when /(\d+\.\d+)$/
      return :promil
    when /(\d+\.?\d*)(%)?/  
      return :posto
    else 
      return :posto
    end
  end
  
  def ==(other)
    (self <=> other) == 0
  end

  def <=>(other)
    return self.naziv.to_s <=> other.naziv.to_s
  end
    
  def parsiraj_broj(broj)
    case broj
    when /(\d+\.\d+)$/
      number = BigDecimal.new($1) / 1000
    when /(\d+\.?\d*)(k|%)?/  
      number = BigDecimal.new($1)
      number *= 1000 if $2 == "k"
      number /= 100 if $2 == "%" 
      return number
    else
      raise "invalid number '#{broj}'"
    end
  end
  
  def ==(other)
    (self <=> other) == 0
  end

  def <=>(other)
    return self.naziv.to_s <=> other.naziv.to_s
  end
end
