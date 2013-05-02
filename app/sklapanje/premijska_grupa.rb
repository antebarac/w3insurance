class PremijskaGrupa

  attr_reader :oznaka, :opis, :node
  attr_writer :postavke

  def initialize(node, opis, schema)
    raise "Premijska grupa ne moze biti nil" if node == nil
    @schema = schema
    @node = node
    @oznaka = node.name.to_s
    @opis = opis
  end

  def append_child(child_node)
    @node.append_child(child_node)
  end

  def visibility_list(postavke = {}) 
    result = {}
    enumerate_with_duplicates.each do |node|
      visible = node.visible?(postavke)
      if result[node.name].nil? || visible 
        result[node.name] = NodeInfo.new(visible, node.default_value)
      end
    end
    return result
  end
  
  def postavke
    @postavke ||= defaults
  end

  def popusti_i_doplatci
    return [] unless @schema.zajednicke_odredbe.can_be_child_of?(@oznaka)
    return @schema.zajednicke_odredbe.children.select do |item|
      item.can_be_child_of?(@oznaka) 
    end
  end

  def enumerate_with_duplicates
    enumerate(true, :render)
  end

  def enumerate(include_duplicates = false, type = :normal)
    unique_map = {}
    @node.descendants(type).select do |node| 
      if (node.type != :branch) && unique_map[node.name].nil?
        unique_map[node.name] = node unless include_duplicates
        true
      else
        false
      end
    end
  end

  def [](key)
    @node[key] 
  end

  def descendants(type = :normal)
    @node.descendants(type)
  end

  def preload_defaults(postavke)
    @postavke = postavke
    enumerate.each do |node|
      if node.optional? && @postavke[node.name].to_s == "da" && !node.default_value.nil? 
        iznos_name = node.name.to_s + "_iznos"
        @postavke[iznos_name.to_sym] = node.default_value if @postavke[iznos_name.to_sym].nil?
      end
    end
  end

  def defaults
    result = {}
    enumerate.each do |node|
       if node.type == :enum && node.children.size > 0
         result[node.name] = node.children[0].name
       end
    end
    return result
  end

  def has_attribute(name)
    enumerate.each do |node|
      if node.type != :branch && node.name.to_s == name.to_s
        return true
      end
    end
    return false
  end 

  def dodaj_samo_jednom(lista, item, unique_map)
    if (!unique_map.include?(item.name)) 
      lista << item
      unique_map[item.name] = item
    end
  end

  def render_list
    osnovno_osiguranje = []
    dodatna_pokrica = []
    popusti_i_doplatci = @schema.shared_popusti_i_doplatci(@oznaka)
    unique_map = {}
    @schema.original_children(@oznaka).each { |i| dodaj_samo_jednom(osnovno_osiguranje, i, unique_map) } 
    @schema.popusti_i_doplatci(@oznaka).each { |i| dodaj_samo_jednom(osnovno_osiguranje, i, unique_map) }
    @schema.dodatna_pokrica.each_pair do |key, value|
      dodaj_samo_jednom(dodatna_pokrica, value.node, unique_map) 
      value.descendants(:render).each { |i| dodaj_samo_jednom(dodatna_pokrica, i, unique_map) }
    end
    dodatna_pokrica.insert(0, SchemaNode.new(:dodatna_osiguranja, "TITLE")) if dodatna_pokrica.size > 0
    popusti_i_doplatci.insert(0, SchemaNode.new(:popusti_i_doplatci, "TITLE")) if popusti_i_doplatci.size > 0
    return (osnovno_osiguranje  + dodatna_pokrica + popusti_i_doplatci).select{ |i| i.type != :branch }
  end

  def validate
    result = ValidationResult.new
    enumerate.each do |node|
      if node.type != :branch 
       node_name = node.name
       node_name = node.name.to_s + "_iznos" if node.optional?
       result.add(node_name, :missing_required_attribute) if node.required_and_not_in?(@postavke)
       result.add(node_name, :invalid_format) unless node.valid_format?(@postavke)
       result.add(node_name, :invalid_value) if node.not_possible?(@postavke)
      end
    end

   if @postavke != nil
     @postavke.each_key do |key|
         result.add(key, :attribute_not_declared)  if  @allow_undeclared_attributes == false &&  has_attribute(key, premijska_grupa) == false 
     end
   end
   result
  end

  def valid?
     validate.ok?
  end

end
