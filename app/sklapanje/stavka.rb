class Stavka
 attr_reader :oznaka, :stopa, :temeljna_premija 
 attr_accessor :opis, :doplatci, :popusti, :svota_osiguranja

 def  initialize(oznaka, temeljna_premija, stopa )
    @oznaka = oznaka
    @temeljna_premija = temeljna_premija
    @stopa = stopa
 end

 def premija
   @temeljna_premija + zbroji_premije(@doplatci) + zbroji_premije(@popusti)
 end
 
 def simple_stavka?
   doplatci.size == 0 && popusti.size == 0
 end

 def zbroji_premije(lista)
   return 0 if lista.nil?
   lista.collect { |i| i.premija }.sum
 end

  def svota_osiguranja
    return "&nbsp;" if @stopa.jedinicna?
    return @svota_osiguranja
  end
end
