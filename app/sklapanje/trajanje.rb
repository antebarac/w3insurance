require 'ostruct'

class Trajanje

   attr_reader :pocetak, :kraj

   def initialize(tip, opcije)
     @tip = tip
     @opcije = OpenStruct.new(opcije)
     raise ArgumentError.new(':pocetak je obavezno polje') if @opcije.pocetak == nil
     izracunaj_trajanje
   end

   def izracunaj_trajanje
     @pocetak = Date.parse(@opcije.pocetak.to_s)
     case @tip
      when :jednogodisnje then  @kraj = @pocetak >> 12
      when :visegodisnje then izracunaj_visegodisnje
      when :dugorocno then @kraj = :inf
      when :kratkorocno then izracunaj_kratkorocno
      else raise "Nepodrzan tip trajanja:#{@tip}" 
     end
   end

   def izracunaj_visegodisnje 
     raise ArgumentError.new(':broj_godina je obavezna opcija za :visegodisnje trajanje') if @opcije.broj_godina == nil
     @kraj = @pocetak >> 12 * @opcije.broj_godina
   end

   def izracunaj_kratkorocno
     raise ArgumentError.new(':kraj je obavezna opcija za :kratkorocan tip trajanja') if @opcije.kraj == nil
     @kraj = Date.parse(@opcije.kraj)
   end

   def godine
     case @tip
      when :jednogodisnje then  1
      when :visegodisnje then @opcije.broj_godina
      when :dugorocno then :inf
      when :kratkorocno then ((@kraj - @pocetak)/365.0).round(4)
     end
   end

end
