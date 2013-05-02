class Kontakt < ActiveRecord::Base
  has_one :polica
  acts_as_solr

  def formatirani_naziv
    return naziv if vrsta == 1 
    return ime + " " + prezime 
  end
end
