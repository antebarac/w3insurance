class SchemaNode
  attr_reader :children, :type, :defined_as_required, :default_value, :range_as_string
  attr_accessor :name, :indent_children, :parent

  @@reserved_keys = [ :svota_osiguranja, :oznaka ]

  def initialize(name, value, parent = nil)
    @forbidden_parents = []
    @exclusive_parents = []
    @name = name.to_sym
    if(value == "TITLE")
      @type = :title
      return
    end
    if(name.to_s =~ /^(.*)\[(.*)\](.*)$/)
      original_name = name
      selector = $2
      @name = ($1 + $3).to_sym
      if(!selector.nil?)
        selector.split(",").each do |token|
          if(token =~ /^!(.*)$/)
            @forbidden_parents << $1 
          else
            @exclusive_parents << token 
          end
        end
        if(@exclusive_parents.size > 0 && @forbidden_parents.size > 0) 
          raise RuntimeError.new("Nedozvoljen format forbidden/exclusive liste za node: #{original_name}") 
        end
      end
    end
    @readonly = false
    @indent_children = false
    @children = []
    raise ArgumentError.new("U definiciji sheme nije dozvoljena upotreba naziva: #{@name}") if @@reserved_keys.include?(@name)
    @parent = parent
    @defined_as_required = @essential = @optional = false
    if(@name =~ /^(.*)\*$/)
      @name = $1.to_sym
      @defined_as_required = @essential = true
    elsif(@name =~ /^(.*)\+$/)
      @name = $1.to_sym
      @defined_as_required = true
    elsif(@name =~ /^(.*)\?$/)
      @name = $1.to_sym
      @type = :text 
      @optional = true
    elsif(@name =~ /^(.*)!$/)
      @name = $1.to_sym
      @parent = SchemaNode.new(:dodatno_pokrice,"")
      @indent_children = true
    end
    @value = value
    if(value.class == Hash || value.class == Array)
      if @parent.nil?
        @type = :root
      elsif @parent.type == :enum
        @type = :branch
      else
        @type = :enum
      end
      parse_children(value, self)
    elsif @optional != true
      @type = value
    elsif @optional == true
      if (@value =~ /^=(.*)%-(.*)%/)  #range
        @default_value = $1
        @type = :range_percentage
        @valid_range = (BigDecimal.new($1)..BigDecimal.new($2))
        @range_as_string = "[#{$1}% - #{$2}%]".gsub('.',',')
      elsif (@value =~ /^=\s*do\s+(.*)%$/)
        upper_limit = $1
        @default_value = "0"
        @type = :range_percentage
        @valid_range = (BigDecimal.new("0.01")..BigDecimal.new(upper_limit))
        @range_as_string =  "(do #{upper_limit}%)".gsub('.',',')
      elsif (@value =~ /^=\s*(.*)%$/)  #fixed value
        @default_value = $1
        @readonly = true
        @type = :fixed_percentage
        @valid_range = (BigDecimal.new($1)..BigDecimal.new($1))
        @range_as_string = "(#{@default_value}%)".gsub('.',',')
      end
    end
  end
  
  def can_be_child_of?(name)
    return false if(@exclusive_parents.size > 0 && !@exclusive_parents.include?(name.to_s))
    return false if(@forbidden_parents.size > 0 && @forbidden_parents.include?(name.to_s))
    return true
  end

  def readonly?
    @readonly
  end

  def optional?
    @optional
  end

  def visible?(postavke = {})
    if @type == :branch 
      return false
    end
    if !@parent.nil? && @parent.type == :branch
      if(!postavke[@parent.parent.name].nil? && postavke[@parent.parent.name].to_s == @parent.name.to_s)
        return @parent.parent.visible?(postavke) 
      else
        return false
      end
    end
    return true
  end
  
  def <=> (other)
    @name.to_s <=> other.name.to_s
  end

  def parse_children_array(definicija, parent)
    definicija.each do |i|
      @children << SchemaNode.new(i, {}, parent)
    end
  end

  def parse_children(definicija, parent)
    if(definicija.class == Array)
      parse_children_array(definicija, parent)
    else
      parse_children_hash(definicija, parent)
    end
  end

  def parse_children_hash(definicija, parent)
    definicija.each_pair do |key, value|
      @children << SchemaNode.new(key, value, parent)
    end
  end

  def descendants(type = :normal)
    ret = Array.new
    @children.each do |i|
      ret << i
      i.desc_to(ret, type)
    end
    return ret
  end

  def desc_to(list, type)
    @children.each do |i|
      list << i
      i.desc_to(list, type)
    end
    if optional? && type == :normal
      list << SchemaNode.new("#{@name}_iznos", :decimal, self)
    end
  end

  def [](key)
    descendants.each do |i|
      return i if i.name.to_s == key.to_s
    end
    raise "Schema node with name #{key} not found"
  end

  def contains?(key)
    return descendants.select { |i|  i.name.to_s == key.to_s }.size > 0 
  end

  def required?(postavke = {})
    ret = @defined_as_required && visible?(postavke)
    if(!@parent.nil? && !@parent.parent.nil? && @parent.type == :branch)
      @parent.parent.children.each do |item|
        item.children.each do |sibling|
          if(sibling.name == @name && !sibling.equal?(self))
            ret = ret || (sibling.defined_as_required && sibling.visible?(postavke))
          end
        end
      end
    end
    return ret
  end

  def essential?(postavke = {})
    @essential && visible?(postavke)
  end

  def not_possible?(postavke)
    return !value(postavke).nil? && @type == :enum && children.select() { |i| i.name.to_s == value(postavke).to_s }.size == 0
  end

  def required_and_not_in?(postavke)
    return required?(postavke) && value(postavke) == nil 
  end

  def ==(other)
    return false if other.class != self.class
    @name == other.name 
  end

  def value(postavke)
    valid_format?(postavke)
    @value = postavke[@name.to_sym] unless postavke.nil?
    if @value == nil
      @value = default
    end
    return @value
  end

  def default
    return children[0].name if(@type == :enum && children.size >0)
    return nil
  end

  def valid_format?(postavke = nil)
    return true if @type.nil? || ( !postavke.nil? && postavke[@name].nil? )
    @value = postavke[@name] unless postavke.nil?
    case @type.to_sym
      when :decimal then check_decimal(postavke)
      when :integer then check_integer(postavke) 
      when :money then check_money(postavke)
      when :enum then check_symbol(postavke) 
      when :boolean then check_boolean(postavke)
      when :fixed_percentage then check_range_percentage(postavke)
      when :range_percentage then check_range_percentage(postavke)
      when :text  then true 
      when :branch then true
      when :root then true
      else raise ArgumentError.new("Unsupported format: #{@type}")
    end
  end
  
  def parse_number(number)
    if (number != nil)
      number.gsub!(',','.') if number.class == String
    end
    Float(number) rescue return nil
    return BigDecimal.new(number.to_s)
  end

  def check_range_percentage(postavke)
    if(postavke[@name].to_s == "da")
      value_index = (@name.to_s + "_iznos").to_sym
      return false if(parse_number(postavke[value_index]).nil?)
      return false if(!(@valid_range === BigDecimal.new(postavke[value_index].to_s)))
    end
    return true
  end


  def check_money(postavke)
    if @value.class == String 
      @value.gsub!(".",'') unless @value.nil? 
    end
    result = check_decimal(postavke)
    postavke[@name] = @value = @value.round(2) if result 
    return result
  end

  def check_decimal(postavke)
    @value = parse_number(@value)
    return false if @value.nil?
    postavke[@name] = @value
    return true
  end

  def check_integer(postavke)
    result = ( @value.to_i.to_s == @value.to_s)
    postavke[@name] = @value = @value.to_i if result 

    return result
  end

  def check_symbol(postavke)
    result = ( @value.class == String || @value.class == Symbol )
    postavke[@name] = @value = @value.to_s.to_sym unless @value.nil? rescue result = false
    return result
  end

  def check_boolean(postavke)
   if @value.to_s.downcase == 'da' 
      result = true 
      postavke[@name] = :da
   elsif @value.to_s.downcase == 'ne'
      result = true
      postavke[@name] = :ne
   end
    return result
  end

  def possible_values
    return nil if @type != :enum
    return children.collect { |i| i.name.to_s }
  end

  def da_ne?
    if(type == :enum && children.size == 2 &&
      children.select { |i| i.name == :da }.size == 1 &&
      children.select { |i| i.name == :ne }.size == 1)
        return true
    end
    return false
  end

  def append_child(child)
    @children << child
  end

  def get_indent
    return 1 if parent != nil &&  parent.parent != nil && parent.parent.indent_children 
    return 0
  end

  def get_class
    case @type.to_sym
      when :money then result = "money"
      else result = ""
    end
    return result
  end

  def get_size
    case @type.to_sym
        when :decimal then result = 5
        when :money then result = 15
        when :integer then result = 5 
        when :fixed_percentage then result = 2
        when :range_percentage then result = 2
        when :text  then result = 80 
        else raise ArgumentError.new("Unsupported format za get_size: #{@type}")
      end
    return result
  end

  def to_s
    "#{name}"
  end
end
