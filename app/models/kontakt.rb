class Kontakt < ActiveRecord::Base
  has_one :polica
  attr_accessible :vrsta, :oib, :maticni_broj, :ime, :prezime, :naziv
  acts_as_solr

  def formatirani_naziv
    return naziv if vrsta == 1 
    return ime + " " + prezime 
  end
end
