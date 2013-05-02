#encoding: utf-8
class Stopa
 
  attr_reader :tip
  attr_accessor :oznaka, :opis

  def initialize(vrijednost = 0, tip = :odredjuje_strucna_sluzba)
    if tip != :posto && tip != :promil && tip != :odredjuje_strucna_sluzba
      raise "Stopa.Initialize, unknown type (Stopa.tip): #{tip}"
    end
    @vrijednost = vrijednost
    @tip = tip
  end
  
  def to_s
    return "Odredjuje strucna sluzba" if @tip == :odredjuje_strucna_sluzba
    return "&nbsp;" if @tip == :promil && @vrijednost.to_f == 1000.00
    return "#{@vrijednost}‰" if @tip == :promil
    # postotak
    result = koeficijent * 100
    if result.to_i == result
     result = result.to_i
    end
    return "#{result}%"
  end
  
  def koeficijent
    return 0 if @tip == :odredjuje_strucna_sluzba
    return @vrijednost.to_f / 1000.0 if @tip == :promil
    @vrijednost.to_f / 100 
  end
  
  def self.odredjuje_strucna_sluzba
    Stopa.new
  end

  def jedinicna?
    return @tip == :promil && @vrijednost.to_f == 1000.00 || @tip == :postotak && @vrijednost.to_f == 100.0
  end
end
