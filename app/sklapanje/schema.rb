require 'yaml'

class Schema
  attr_accessor :naziv, :oznaka_cjenika
  attr_reader :dodatna_pokrica, :premijske_grupe

  def initialize(oznaka_cjenika, definicija = nil)
    @oznaka_cjenika = oznaka_cjenika
    definicija = read_schema_definition if definicija == nil
    init_premijske_grupe(definicija)
    init_dodatna_pokrica
    init_zajednicke_odredbe
  end

  def init_premijske_grupe(definicija)
    @original_map = {}
    @premijske_grupe = {}
    @map = YAML::load(definicija)
    @map.each_pair do |key, value|
      if key == "NAZIV"
        @naziv = value
      elsif !(key =~ /^Z(\[.*\])*$/) && !(key =~ /^.*!$/)
        @premijske_grupe[key] = PremijskaGrupa.new(SchemaNode.new(key, value), get_opis_premijske_grupe(key), self )
        @original_map[key] = @premijske_grupe[key].descendants(:render).select { |i| i.type != :branch}
      elsif (key =~ /^Z(\[.*\])*$/)  
        @zajednicke_odredbe = SchemaNode.new(key, value)
      end
    end
    @premijske_grupe
    @original_chidren
  end
  
  def original_children(oznaka)
    @original_map[oznaka.to_s]
  end


  def zajednicke_odredbe
    @zajednicke_odredbe 
  end

  def popusti_i_doplatci(oznaka)
   return [] if @zajednicke_odredbe.nil?
   oznaka = oznaka.to_s
   ret = []
   sve_oznake = []
   @premijske_grupe.merge(@dodatna_pokrica).each_pair do |key, value|
    sve_oznake << value.oznaka 
   end
   @zajednicke_odredbe.descendants(:render).select { |i| i.type != :branch }.each do |odredba|
    count = 0
    sve_oznake.each do |item|
      count +=1 if odredba.can_be_child_of?(item) && odredba.parent.can_be_child_of?(item)
    end
    if oznaka != "Z" && count == 1 && odredba.can_be_child_of?(oznaka) && odredba.parent.can_be_child_of?(oznaka)
      ret << odredba
    elsif oznaka == "Z" && count > 1
      ret << odredba
    end
   end
   return ret
  end

  def shared_popusti_i_doplatci(oznaka)
    popusti_i_doplatci("Z").select do |i|
      i.can_be_child_of?(oznaka) && i.parent.can_be_child_of?(oznaka)
    end
  end

  def init_zajednicke_odredbe
    @premijske_grupe.each_pair do |premijska_grupa, value|
      (popusti_i_doplatci(premijska_grupa) + shared_popusti_i_doplatci(premijska_grupa)).each do |i|
        value.append_child(i) 
      end
    end
    @dodatna_pokrica.each_pair do |premijska_grupa, value|
      (popusti_i_doplatci(premijska_grupa) ).each do |i|
        i.parent = value.node.children[1]
        value.node.children[1].append_child(i) 
      end
    end
  end

  def init_dodatna_pokrica
    @dodatna_pokrica = {}
    @map.each_key do |key|
      if key =~ /^(.*)!$/
        clean_key = $1
        @dodatna_pokrica[clean_key] = PremijskaGrupa.new(SchemaNode.new(key, @map[key]), get_opis_premijske_grupe(clean_key), self) 
        @premijske_grupe.each_key do |oznaka|
          @premijske_grupe[oznaka].append_child(@dodatna_pokrica[clean_key].node)
        end
      end
    end
  end

  def get_opis_premijske_grupe(oznaka)
    return I18n.t "#{oznaka_cjenika}.#{oznaka.upcase}"
  end

  def method_missing(method, *params) 
    return self[method.to_s]
  end 

  def [] key
    mapa = @premijske_grupe
    mapa = @dodatna_pokrica if @premijske_grupe[key].nil?
    raise "Ne postoji premijska grupa #{key}" if mapa[key].nil?
    mapa[key]
  end

  def read_schema_definition
    definicija = File.open("#{Rails.root}/app/cjenik/#{@oznaka_cjenika.to_s.downcase}/schema.yml") do |file| 
      file.read  
    end
  end

end
