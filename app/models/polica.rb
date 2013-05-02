class Polica < ActiveRecord::Base
  belongs_to :ugovaratelj, :class_name => :kontakt

  attr_reader :stavke

  def initialize(*args)
      super(*args)
    @cjenici = []
  end
 
  def stavke
    @cjenici.collect { |cjenik| cjenik.stavka }
  end
 
  def premija
    stavke.collect { |stavka| stavka.premija }.sum
  end
 
  def validate
    result = ValidationResult.new
    return result
  end
  
  def valid?
    validate.ok?
  end
  
  def dodaj_stavke(osiguranje, premijska_grupa, postavke)
    original_postavke = postavke.clone
    cjenik = Cjenik.instanca(osiguranje, premijska_grupa)
    cjenik.init_postavke(postavke)
    @cjenici << cjenik
    schema = Schema.new(osiguranje)
    schema.dodatna_pokrica.each_key do |dodatno_pokrice|
      oznaka = dodatno_pokrice.to_sym  
      if original_postavke[oznaka].to_s == "da"
        cjenik_pokrica = Cjenik.instanca(osiguranje, oznaka)
        cjenik_pokrica.init_postavke(original_postavke)
        @cjenici << cjenik_pokrica 
      end
    end
    return self
  end
end

