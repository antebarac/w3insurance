#encoding: utf-8
require "ostruct"

class Table
  
  def initialize(definicija)
   @vrsta = nil
    if definicija =~ /(.+)\n((#.+\n)*)===+\n(.+)\n---+\n((.|\n)+)\n---+/
      head, cols, data= $1, $4, $5
        @declarations = Hash.new
        $2.split(/\n/).each do |line|
          if line =~ /#(.+)\s+=\s+(.+)/
            @declarations[$1] = $2
          else
            raise "Invalid declaration definition #{line}"
          end
        end
        @global = head 
        cols_def = cols.split(/\s\s+/)
        @varijable = [Varijabla.new(cols_def.shift)]
        @rezultati = cols_def.collect { |i| Varijabla.new(i) }
        @rezultati.each do |rezultat|
          if @vrsta == nil
            @vrsta = :popust if rezultat.naziv.to_s == "popust"
            @vrsta = :doplatak if rezultat.naziv.to_s == "doplatak"
          end
        end
        @map = Hash.new
        data.strip.each_line do |line|
          tokens = line.strip.split(/\s\s+/)
          nulti_token = tokens[0]
          vrijednosti = Hash.new
          nulti_token.split(/\s*,\s*/).each do |individual_key|
            key = @varijable[0].parsiraj_vrijednost(individual_key)
            @map[key] = vrijednosti
            0.upto(@rezultati.size - 1) do |i|
              broj = tokens[i + 1]
              naziv = @rezultati[i].naziv
              vrijednosti[naziv] = @rezultati[i].parsiraj_vrijednost(broj)
              vrijednosti["#{naziv}_original".to_sym] = broj
              vrijednosti["#{naziv}_tip".to_sym] = @rezultati[i].tip(broj)
              if (broj.strip == "F")
                vrijednosti[naziv] = "stopa_#{tokens[0]}_#{@varijable[0].naziv}".to_sym
              end
            end
          end
          vrijednosti[:opis] = @global if vrijednosti[:opis].nil? && !@global.nil?
        end  
    else
      raise "Invalid table definition #{definicija}"
    end   
  end
  
  def evaluate(arguments)
    argument = nil
    @varijable.each do |v|
      if arguments[v.naziv] == nil
        return nil
      elsif argument != nil
        argument = [argument, arguments[v.naziv]]
      else
        argument = arguments[v.naziv]
      end
    end
    argument = argument.to_s if argument.is_a? Symbol 
    @map.each_key do |k| 
      if k === argument
        return process(arguments, @map[k]) 
      end 
    end
    nil
  end
  
  def process(arguments, result_hash)
    result_hash.each_pair do |key, value|
      if value =~ /^=(.*)$/
        code = $1
        @declarations.each_pair do |k, v|
          code.gsub!(k, "arguments[:#{v}]")
        end
        code.gsub!(/(\d\d*)\.?(\d*)%/) do |match|
          "BigDecimal.new(\"#{$1}.#{$2}\")"
        end
        begin
           result_hash[key] = eval(code)
        rescue
          raise "Funkcija se ne moze izvrsiti: eval(" + code + ")\n" + arguments.to_s
        end
      end
    end
  end

  def vrsta
    @vrsta = :premijska_tablica if @vrsta == nil
    @vrsta
  end
  
  def evaluate_array(arguments)
    val = evaluate(arguments)
    return [val] unless val.nil?
    nil
  end

  def |(other)
    if other.is_a?(Table)  || other.is_a?(TableN)
      tc = TableCombo.new
      tc << self << other
      return tc
    else
      raise "Invalid operation Table | #{other.class}"
    end
  end
  
  def +(other)
    if other.is_a? Table || other.is_a?(TableN)
      tc = TableSum.new
      tc << self << other
      return tc
    else
      raise "Invalid operation Table + #{other.class}"
    end
  end

  def set_jedinicna_stopa
    @map.each_value { |v| v[:stopa] = 1.0; v[:stopa_original] = "1000.00" }
    return self
  end
end

