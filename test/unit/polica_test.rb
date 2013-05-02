#encoding: utf-8

require "test_helper"

class PolicaTest < ActiveSupport::TestCase

  def setup
    @polica = Polica.new
  end

  test 'Provjeri polica' do
    @polica.dodaj_stavke(:racunala, "I", :vrijednost_sustava => 1000000)
    assert_equal(true, @polica.valid?)
    assert_equal(4300, @polica.premija)
  end

  test "Dva centra" do
    @polica.dodaj_stavke(:racunala, "I", :vrijednost_sustava => 1000000)
    @polica.dodaj_stavke(:racunala, "I" , :vrijednost_sustava => 100000)
    assert_equal(5140, @polica.premija)
  end

  test "Racunalni centar 100k" do
    @polica.dodaj_stavke(:racunala, "I" , :vrijednost_sustava => 100000)
    assert_equal(840, @polica.premija)
    assert @polica.stavke[0].simple_stavka? 
  end

  test "Racunalni centar 100k za samostalna racunala" do
    @polica.dodaj_stavke(:racunala, "I" , :vrijednost_sustava => 100000, :procesna_racunala => :samostalna, :vrijednost_procesnih_racunala => 100000)
    assert_equal(1050, @polica.premija)
    assert_equal false,  @polica.stavke[0].simple_stavka? 
  end

  test "Raspisivanje za samostalno procesno racunalo + ponovni dnevni unos s popustom" do
    @polica.dodaj_stavke(:racunala, "I" , :vrijednost_sustava => 1000000, :procesna_racunala => :samostalna, :vrijednost_procesnih_racunala => 1000000)
    @polica.dodaj_stavke(:racunala, "II1PG", :vrijednost_sustava => 300000, :trosak_ponovnog_dnevnog_unosa => 300000, :povecana_pouzdanost => :da)

    assert_equal(10361, @polica.premija)
    assert_equal("111A", @polica.stavke[0].oznaka)
    assert_equal("Osiguranje računalnog centra", @polica.stavke[0].opis)
    assert_equal("4.30‰", @polica.stavke[0].stopa.to_s)
    assert_equal("2113", @polica.stavke[1].oznaka)
    
    assert_equal("1S21", @polica.stavke[0].doplatci[0].oznaka)
    assert_equal("25%", @polica.stavke[0].doplatci[0].stopa.to_s)
    assert_equal("Doplatak na samostalno procesno računalo", @polica.stavke[0].doplatci[0].opis)

    assert_equal("2P11", @polica.stavke[1].popusti[0].oznaka)
    assert_equal("40%", @polica.stavke[1].popusti[0].stopa.to_s)
    assert_equal("Popust na povećanu pouzdanost", @polica.stavke[1].popusti[0].opis)

  end

  test "Zajedno popust i doplatak na jednoj stavci" do
    @polica.dodaj_stavke(:racunala, "II1PG", :vrijednost_sustava => 300000, :trosak_ponovnog_dnevnog_unosa => 300000, 
      :procesna_racunala => :samostalna, :vrijednost_procesnih_racunala => 300000, :povecana_pouzdanost => :da)
    
    stavka = @polica.stavke[0]
    assert_equal 8310, stavka.temeljna_premija
    assert_equal 2077.5, stavka.doplatci[0].premija
    assert_equal -4155, stavka.popusti[0].premija
    assert_equal 6232.5, @polica.premija
  end

  test 'Dodatno pokrice za potres' do
    @polica.dodaj_stavke(:racunala, "I", :vrijednost_sustava => 1000000, :POTRES => "da", :vrsta_objekta => :stambeni_do_1964, :potresna_zona => "1a", :fransiza_potres => :bez )
    assert_equal(true, @polica.valid?)
    assert_equal(4420, @polica.premija)
  end
  
  test "Dodatno pokrice za potres - stavke" do
    @polica.dodaj_stavke(:racunala, "I", :vrijednost_sustava => 1000000, :POTRES => "da",  :vrsta_objekta => :stambeni_do_1964, :potresna_zona => "1a", 
      :fransiza_potres => :bez  )

    assert_equal("111A", @polica.stavke[0].oznaka)
    assert_equal("Osiguranje računalnog centra", @polica.stavke[0].opis)
    assert_equal("4.30‰", @polica.stavke[0].stopa.to_s)
    assert_equal("R512", @polica.stavke[1].oznaka)
    assert_equal("0.12‰", @polica.stavke[1].stopa.to_s)
  end

  test "Polica I i II1PG grupa sa dodatnim doplatkom" do
    @polica.dodaj_stavke(:racunala, "I", :vrijednost_sustava => 1000000, :II1PG => "da", :trosak_ponovnog_dnevnog_unosa => 10000,
                         :doplatak_za_trazenje_greske => :da)
  
    assert_equal("111A", @polica.stavke[0].oznaka)
    assert_equal("Osiguranje računalnog centra", @polica.stavke[0].opis)
    assert_equal("4.30‰", @polica.stavke[0].stopa.to_s)
    assert_equal(4300, @polica.stavke[0].temeljna_premija)
    assert_equal(270.9, @polica.stavke[0].doplatci[0].premija)
    assert_equal(4570.9, @polica.stavke[0].premija)

    assert_equal("211A", @polica.stavke[1].oznaka)
    assert_equal("Osiguranje troškova ponovnog dnevnog unosa podataka", @polica.stavke[1].opis)
    assert_equal("21.60‰", @polica.stavke[1].stopa.to_s)
    assert_equal(216, @polica.stavke[1].temeljna_premija)
    assert_equal(0, @polica.stavke[1].doplatci.size) 
    assert_equal(216, @polica.stavke[1].premija)
  end

  test 'izmisljeni doplatak na ii1pg' do
    @polica.dodaj_stavke( :racunala, "I", :vrijednost_sustava => 1000000, :II1PG => :da, :trosak_ponovnog_dnevnog_unosa => 2000, 
                          :doplatak_izmisljeni => :da)

    assert_equal("111A", @polica.stavke[0].oznaka)
    assert_equal("Osiguranje računalnog centra", @polica.stavke[0].opis)
    assert_equal("4.30‰", @polica.stavke[0].stopa.to_s)
    assert_equal(4300, @polica.stavke[0].temeljna_premija)
    assert_equal("211A", @polica.stavke[1].oznaka)
    assert_equal("Osiguranje troškova ponovnog dnevnog unosa podataka", @polica.stavke[1].opis)
    assert_equal("21.60‰", @polica.stavke[1].stopa.to_s)
    assert_equal(43.2, @polica.stavke[1].temeljna_premija)
    assert_equal(1, @polica.stavke[1].doplatci.size) 

    assert_equal("I411", @polica.stavke[1].doplatci[0].oznaka) 
    assert_equal("8.2%", @polica.stavke[1].doplatci[0].stopa.to_s) 
    assert_equal(BigDecimal.new(3.5424, 5), @polica.stavke[1].doplatci[0].premija.round(4)) 
    assert_equal(BigDecimal.new(46.7424, 6), @polica.stavke[1].premija.round(4))
    assert_equal(BigDecimal.new(4346.7424, 8), @polica.premija.round(4))
  end

end
