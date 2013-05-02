require 'ostruct'

class Cjenik
  attr_reader :premijska_grupa, :schema

  def initialize(vrsta, definicija = nil, schema = nil)
    raise 'vrsta ne moze biti nil' if vrsta == nil
    schema = Schema.new(self.class.name.downcase.to_sym) if(schema.nil?)
    @premijska_grupa = schema[vrsta]
    @vrsta = vrsta
    load_definition(definicija)
    init
    @schema = schema
  end

  def init
  end

  def pravila
  end

  def defaults
     @premijska_grupa.defaults
  end

  def init_postavke(postavke)
    @premijska_grupa.preload_defaults(procisti_postavke(postavke))
    raise ArgumentError.new("Attributes are not valid:\n#{@premijska_grupa.validate}") if @premijska_grupa.valid? == false  
    pravila
  end

  def procisti_postavke(postavke) 
    ret = {}
    postavke.each_pair do |key, value|
      retain = true
      if !@schema.zajednicke_odredbe.nil? && @schema.zajednicke_odredbe.contains?(key)
        node = @schema.zajednicke_odredbe[key]
        retain = false if !node.can_be_child_of?(@vrsta) 
      end
      ret[key] = value if retain
    end
    return ret
  end

  def validate(postavke)
    @premijska_grupa.postavke = postavke
    return @premijska_grupa.validate
  end
  
  def stavka
    evaluirana_stavka = @tablica_premija.evaluate(@premijska_grupa.postavke)
    if evaluirana_stavka.nil?
     raise "Nema stavke za vrsta: #{@vrsta} i postavke: #{@premijska_grupa.postavke}"
    end
    stavka = Stavka.new(oznaka, temeljna_premija, Stopa.new(evaluirana_stavka[:stopa_original],evaluirana_stavka[:stopa_tip]  ))
    stavka.opis = evaluirana_stavka[:opis]
    @osnovica = temeljna_premija
    stavka.doplatci = izracunaj_doplatke
    stavka.popusti = izracunaj_popuste
    stavka.svota_osiguranja = svota_osiguranja
    return stavka
  end
   
  def load_osnovica_from_file
    osnovica_def = ""
    if File.exists?("#{definition_root_folder}/osnovica.def") && @vrsta.downcase != "potres" && @vrsta.downcase != "nezgoda"
     File.open("#{definition_root_folder}/osnovica.def") do |file| 
        osnovica_def = file.read  
     end
    end
    if osnovica_def != ""
      ret_val = nil
      osnovica_def.split("\n\n").each do |blok|
        ret_val = TableFactory.combine(ret_val, TableFactory.create(blok).set_jedinicna_stopa())
      end
      return ret_val
    end
  end

  def svota_osiguranja 
    osnovice_table = load_osnovica_from_file
    if(!osnovice_table.nil?)
      result = osnovice_table.evaluate(postavke)
      if(!result.nil? && !result[:osnovica_original].nil?)
        return result[:osnovica_original].to_f
      end
    end
  end

  def oznaka 
    @tablica_premija.evaluate(@premijska_grupa.postavke)[:oznaka] 
  rescue
    print @premijska_grupa.postavke
  end

 def temeljna_premija 
 # todo: treba validirati samo da li ima essential polja
 # @premijska_grupa.validate
 # return 0 if @premijska_grupa.valid? == false
    koeficijent_map = @tablica_premija.evaluate(@premijska_grupa.postavke)
    if koeficijent_map != nil 
      raise "Nema stope/osnovice za postavke #{@premijska_grupa.postavke}" if koeficijent_map[:stopa].nil? && koeficijent_map[:osnovica].nil?
      raise "Svota osiguranja nije definirana za postavke #{@premijska_grupa.postavke}; vrsta: #{@vrsta}" if svota_osiguranja.nil?
      return svota_osiguranja if koeficijent_map[:stopa].nil?
      koeficijent_map[:stopa] * svota_osiguranja 
    else
      0
    end
 end

 def doplatci
   create_list(@tablica_doplataka, :doplatak) 
 end   

 def popusti 
    create_list(@tablica_popusta, :popust) 
 end

 def izracunaj_doplatke
   collection =  create_list(@tablica_doplataka, :doplatak)  
   vrati_stavke(collection, 1, :doplatak)
 end

 def izracunaj_popuste
   collection =  create_list(@tablica_popusta, :popust)  
   vrati_stavke(collection, -1, :popust)
 end

 def vrati_stavke(collection, predznak, vrsta)
    collection.collect do |i|
      begin
        stopa = Stopa.new(i["#{vrsta}_original".to_sym], i["#{vrsta}_tip".to_sym])
      rescue
        raise "Problemi sa: #{vrsta}_original i #{vrsta}_tip" + i.to_s 
      end
      s = Stavka.new(i[:oznaka], BigDecimal.new(@osnovica.to_s) * BigDecimal.new(stopa.koeficijent.to_s) * predznak, stopa)
      @osnovica += s.premija
      s.opis = i[:opis]
      s
    end
 end
  
  def preprocess(definicija)
    definicija.gsub(/#begin\s*\n===+\n(.*)\n---+\n((\n|.)*)\n---+\n#end\n/) do |match|
      def_line = $1
      body = $2
      substitution = ""
      opis_index = 3
      if(def_line.split(/\s\s+/).include?("vrijednost"))
        opis_index = 4
      end
      body.split("\n").each do |line|
        tokens = line.split(/\s\s+/)
        naziv = tokens[opis_index]
        varijabla = tokens[1]
        tip = "doplatak"
        tip = "popust" if tokens[0].strip == "P"
        oznaka = tokens[2]
        vrijednost = "=v"
        vrijednost = tokens[3] if opis_index == 4
        substitution += "#{naziv}\n#v = #{varijabla}_iznos\n===\n#{varijabla}  oznaka  #{tip}\n---\nda  #{oznaka}  #{vrijednost}\n---\n\n"
      end
      substitution
    end
  end

 def load_definition(definicija)
    osnovice_table = load_osnovica_from_file
    if(!osnovice_table.nil?)
      @tablica_premija = osnovice_table
    end
    definicija = read_definition_from_file if definicija.nil? 
    if !definicija.nil? && definicija != ""
      definicija = preprocess(definicija)
      definicija.gsub!(/\n+$/, "\n")
      definicija.split("\n\n").each do |blok|
         table = TableFactory.create(blok)
         case table.vrsta 
           when :doplatak  then @tablica_doplataka = TableFactory.add(@tablica_doplataka, table)
           when :popust then  @tablica_popusta = TableFactory.add(@tablica_popusta, table)
           when :premijska_tablica then  @tablica_premija = TableFactory.combine(@tablica_premija, table)
         end
      end
    else

    end
  end
  
   def postavke
    return @premijska_grupa.postavke
   end

  def create_list(tablica, type)
    lista = tablica.evaluate_array(@premijska_grupa.postavke) if tablica.nil? == false
    return Array.new if lista.nil?
    # ako postoje funckije - izracunaj vrijednosti
    lista.each do |val| 
       if val[type].class == Symbol
         val[type] = eval(val[type])
         val["#{type}_original".to_sym] = (val[type] * 100 ).to_s + "%"
       end
    end
  end

  def read_definition_from_file 
     definicija = ""
     if File.exists?("#{definition_root_folder}/#{@vrsta.downcase}.def")
      File.open("#{definition_root_folder}/#{@vrsta.downcase}.def") do |file| 
        definicija += file.read  
      end
     end
     
     if File.exists?("#{definition_root_folder}/z.def") && @vrsta.downcase != "potres" && @vrsta.downcase != "nezgoda"
       File.open("#{definition_root_folder}/z.def") do |file| 
          definicija += "\n\n" if definicija != ""
          definicija += file.read  
       end
     end
     return definicija
  end

  def definition_root_folder
    "#{Rails.root}/app/cjenik/#{self.class.name.downcase}"
  end

  def self.instanca(cjenik, grupa)
    Object::const_get(cjenik.to_s.capitalize).new(grupa.to_s) 
  end


  def self.all
    result = []
    folder = "#{Rails.root}/app/cjenik/"
    files = Dir.glob(folder + "*.rb")
    files.each do |file|
      if(file =~ /.*\/(.*)\.rb/)
        ime_cjenika = $1.downcase
        schema = Schema.new(ime_cjenika)
        result << OpenStruct.new({:oznaka => ime_cjenika.to_sym, :naziv => schema.naziv})
      end
    end
    return result
  end

end
