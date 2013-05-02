class TableN
  attr_reader :varijable
  
  @@definicija = /(.+)\n===+(\n(.|\n)+)/
  
  def initialize definicija
    @current_values = Hash.new
    @varijable = Array.new
    @map = Hash.new
    if definicija =~ @@definicija
      tail = $2
      @opis = $1
    else
      raise "Invalid definition: #{definicija}"
    end
     
    parts = tail.split(/---+/)
    process_first_part parts[0]
    1.upto parts.size - 1 do |i|
      if parts[i] =~ /((.|\n)+)\.\.\.+((.|\n)+)/
        body = $3
        vars = $1.split(/\n/).collect do |line|
          if line.strip =~ /(.+)\s\s+(.+)/
            [$1, $2]
            var_name = $1.strip
            varijabla = Varijabla.new "v"
            @current_values[var_name.strip.to_sym] = varijabla.parsiraj_vrijednost($2.strip)
            if !@varijable.include?(var_name.to_sym)
              @varijable << var_name.to_sym
            end
          end
        end 
        body.split(/\n/).each do |line|
          process_table_line line
        end
      end
    end
  end


  def vrsta
    :premijska_tablica
  end
  
  def evaluate arguments
    ret_val = nil
    argument = nil
    @varijable.each do |v|
      if arguments[v] == nil
        return nil
      elsif argument != nil && argument.is_a?(Array)
        argument << arguments[v]
      elsif argument != nil
        argument = [argument, arguments[v]]
      else
        argument = arguments[v]
      end
    end
    @map.each_key do |k|
      if argument.size == k.size
        ok = true
        0.upto k.size - 1 do |i|
          if k[i].class == String then argument[i] = argument[i].to_s end
          if !(k[i] === argument[i])
            ok = false
          end
          
        end
      end 
      if ok
        ret = @map[k]
        # ovdje mi oznaku krivo parsira ako nije string, workaround za testove
        if ret[0].class == BigDecimal 
           ret[0] = ret[0].to_i.to_s 
        end
        if ret.size == 5
          return { :stopa => ret[4], :oznaka => ret[0], :stopa_original => ret[4], :stopa_tip => ret[3], :opis => @opis, :osnovica => ret[2].to_f, :osnovica_original => ret[2] } 
        else
          return { :stopa => ret[1], :oznaka => ret[0], :stopa_original => ret[2], :stopa_tip => ret[3], :opis => @opis, :osnovica => ret[2].to_f, :osnovica_original => ret[2] } 
        end
      end
    end
    nil
  end
  
  def evaluate_array arguments
    val = evaluate(arguments)
    return [val] unless val.nil?
    nil
  end
   
  def self.definition_ok? definition
    definition =~ /(.+)\n===+\n(.+)\n\.\.\.+\n(.|\n)+/
  end

  def set_jedinicna_stopa
    @map.each_value { |v| v << 1.0 }
    return self
  end

private
  def process_first_part part
    lines = part.split(/\.\.\.+/)
    @varijable << lines[0].strip.to_sym
    
    @variables = Array.new
    if lines.size > 1
      @second_col_def = lines[1].split(/\s\s+/)
      @varijable << @second_col_def.shift.strip.to_sym
      @second_col_def = @second_col_def.collect { |v| if v.strip != "" then v.strip else nil end }
      @second_col_def.compact!
    end
  end
  
  def process_table_line line
    line.strip!
    if !line.empty? && line =~ /(.+?)\s\s+(.+)/
      first_col = $1.strip
      values = $2.split("|").collect { |v| if v.strip != "" then v.strip else nil end }
      values.compact!

      if @second_col_def.size != values.size
        puts @second_col_def
      end
      
      0.upto @second_col_def.size - 1 do |i|
        key = Array.new
        var = Varijabla.new "v"
        string_var = Varijabla.new "v$"
        key << var.parsiraj_vrijednost(first_col)
        key << var.parsiraj_vrijednost(@second_col_def[i])
        2.upto @varijable.size - 1 do |j|
          key << @current_values[@varijable[j]]
        end
        parsed_values = Array.new
        values_to_parse = values[i].split(/\s/).collect { |vtp| if vtp.strip != "" then vtp.strip else nil end }
        values_to_parse.compact!
        0.upto values_to_parse.size - 1 do |j|
          if j == 0
            parsed_values << string_var.parsiraj_vrijednost(values_to_parse[j])
          else
            parsed_values << var.parsiraj_vrijednost(values_to_parse[j])
            parsed_values << values_to_parse[j]
            parsed_values << var.tip(values_to_parse[j])
          end
        end
        @map[key] = parsed_values.compact
      end

    end
  end
end
