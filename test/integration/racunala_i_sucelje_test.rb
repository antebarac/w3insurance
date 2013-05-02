#encoding: utf-8
require 'test_helper' 

class RacunalaISuceljeTest < ActionController::IntegrationTest
  include Webrat::Matchers

  def setup
    visit "/police"
    click_link 'Nova polica'
    click_link 'Osiguranje računala'
    click_link 'Osiguranje računalnog centra'
    @polica = Polica.new
  end

  test 'sklopi osiguranje racunalnog centra od 1000000 kn' do
    fill_in 'stavka_vrijednost_sustava', :with => 1000000
    @polica.dodaj_stavke(:racunala, "I" , :vrijednost_sustava => 1000000, :adresa => 'Dubovacka 1')
  end

  test 'premija za sto tisuca kuna' do
    fill_in 'stavka_vrijednost_sustava', :with => 100000
    @polica.dodaj_stavke(:racunala, "I", :vrijednost_sustava => 100000)
  end

  test 'racunala prva premijska grup od 200000' do
    fill_in 'stavka_vrijednost_sustava', :with => 200000
    @polica.dodaj_stavke(:racunala, "I", :vrijednost_sustava => 200000)
  end

  test 'racunala prva premijska grupa bankomati' do
    fill_in 'stavka_vrijednost_sustava', :with => 200000
    fill_in 'stavka_poseban_dogovor', :with => :bankomati
    fill_in 'stavka_popis_bankomata', :with => "Popis tra la la"
    @polica.dodaj_stavke(:racunala, "I", :vrijednost_sustava => 200000, :poseban_dogovor => :bankomati)
  end

  test 'racunala prva premijska grupa poseban_dogovor osobna racunala' do
    fill_in 'stavka_vrijednost_sustava', :with => 200000
    fill_in 'stavka_poseban_dogovor', :with => :osobna_racunala
    fill_in 'stavka_broj_racunala', :with => 5
    @polica.dodaj_stavke(:racunala, "I", :vrijednost_sustava => 200000, :poseban_dogovor => :osobna_racunala, :broj_racunala => 5)
  end

  test 'racunala prva premijska grupa poseban_dogovor osobna racunala deset ili vise' do
    fill_in 'stavka_vrijednost_sustava', :with => 200000
    fill_in 'stavka_poseban_dogovor', :with => :osobna_racunala
    fill_in 'stavka_broj_racunala', :with => 10
    @polica.dodaj_stavke(:racunala, "I", :vrijednost_sustava => 200000, :poseban_dogovor => :osobna_racunala, :broj_racunala => 10)
  end

  test 'racunala prva premijska grupa sa licencom_programa' do
    fill_in 'stavka_vrijednost_sustava', :with => 200000
    fill_in 'stavka_poseban_dogovor', :with => :licence_programa
    fill_in 'stavka_cijena_licenci', :with => 30000
    @polica.dodaj_stavke(:racunala, "I", :vrijednost_sustava => 200000, :poseban_dogovor=> :licence_programa, :cijena_licenci => 30000)
  end

  
  test 'racunala prva premijska samostalna procesna racunala' do
    fill_in 'stavka_vrijednost_sustava', :with => 200000
    fill_in 'stavka_procesna_racunala', :with => :samostalna
    fill_in 'stavka_vrijednost_procesnih_racunala', :with => 200000
    @polica.dodaj_stavke(:racunala, "I", :vrijednost_sustava => 200000, :procesna_racunala => :samostalna, :vrijednost_procesnih_racunala => 200000)
  end

  test 'racunala prva premijska ugradjena procesna racunala' do
    fill_in 'stavka_vrijednost_sustava', :with => 200000
    fill_in 'stavka_procesna_racunala', :with => :ugradjena
    fill_in 'stavka_vrijednost_procesnih_racunala', :with => 200000
    @polica.dodaj_stavke(:racunala, "I", :vrijednost_sustava => 200000, :procesna_racunala => :ugradjena, :vrijednost_procesnih_racunala => 200000)
  end
    
  test 'racunala prva premijska grupa pojedinacno' do
    fill_in 'stavka_vrijednost_sustava', :with => 200000
    check 'stavka_pojedinacno_racunalo_check_box'
    fill_in 'stavka_vrijednost_pojedinacnih_uredjaja', :with => 60000
    @polica.dodaj_stavke(:racunala, "I", :vrijednost_sustava => 200000, :vrijednost_pojedinacnih_uredjaja => 60000, :pojedinacno_racunalo => :da)
  end

  test 'racunala prva premijska grupa opsezno sa vise popusta i doplataka' do
    @polica.dodaj_stavke(:racunala, "I", :vrijednost_sustava => 1000000, :prosjecna_otpisanost_opreme => 35, :popust_na_garanciju => "da", :popust_na_garanciju_iznos => 10, 
                        :doplatak_za_trazenje_greske => "da")

    fill_in 'stavka_vrijednost_sustava', :with => 1000000
    check 'stavka_popust_na_garanciju_check_box'
    fill_in 'stavka_popust_na_garanciju_iznos', :with => 10
    check 'stavka_doplatak_za_trazenje_greske_check_box'
    check 'stavka_doplatak_za_osiguranje_amortizirane_vrijednosti_check_box'
    fill_in 'stavka_prosjecna_otpisanost_opreme', :with => 35

  end

  test 'racunala prva premijska grupa opsezno sa vise popusta i doplataka uz validacije' do
    @polica.dodaj_stavke(:racunala, "I", :vrijednost_sustava => 1000000, :prosjecna_otpisanost_opreme => 35, :popust_na_garanciju => "da",
                        :popust_na_garanciju_iznos => 10,  :doplatak_za_trazenje_greske => "da")

    click_button 'Dodaj'
    fill_in 'stavka_vrijednost_sustava', :with => 1000000
    check 'stavka_popust_na_garanciju_check_box'
    fill_in 'stavka_popust_na_garanciju_iznos', :with => 80
    click_button 'Dodaj'
    fill_in 'stavka_popust_na_garanciju_iznos', :with => 10
    check 'stavka_doplatak_za_trazenje_greske_check_box'
    fill_in 'stavka_doplatak_za_trazenje_greske_iznos', :with => 50
    click_button 'Dodaj'
    fill_in 'stavka_doplatak_za_trazenje_greske_iznos', :with => 6.3
    check 'stavka_doplatak_za_osiguranje_amortizirane_vrijednosti_check_box'
    fill_in 'stavka_prosjecna_otpisanost_opreme', :with => 35

  end

  test 'racunala vise premijskih grupa opsezno sa vise popusta i doplataka uz validacije' do
    @polica.dodaj_stavke(:racunala, "I", :vrijednost_sustava => 1000000, :prosjecna_otpisanost_opreme => 35, :popust_na_garanciju => "da",
                        :popust_na_garanciju_iznos => 10,  :doplatak_za_trazenje_greske => "da", :POTRES => "da", :II1PG => "da", 
                        :trosak_ponovnog_dnevnog_unosa => 3000, :vrsta_objekta => :stambeni_do_1964, :potresna_zona => :"1a",
                        :fransiza_potres => :bez, :doplatak_izmisljeni => "da")


    click_button 'Dodaj'
    fill_in 'stavka_vrijednost_sustava', :with => 1000000
    check 'stavka_popust_na_garanciju_check_box'
    fill_in 'stavka_popust_na_garanciju_iznos', :with => 80
    click_button 'Dodaj'
    fill_in 'stavka_popust_na_garanciju_iznos', :with => 10
    check 'stavka_doplatak_za_trazenje_greske_check_box'
    fill_in 'stavka_doplatak_za_trazenje_greske_iznos', :with => 50
    click_button 'Dodaj'
    fill_in 'stavka_doplatak_za_trazenje_greske_iznos', :with => 6.3
    check 'stavka_doplatak_za_osiguranje_amortizirane_vrijednosti_check_box'
    fill_in 'stavka_prosjecna_otpisanost_opreme', :with => 35
    check 'stavka_POTRES_check_box'
    check 'stavka_II1PG_check_box'
    fill_in 'stavka_trosak_ponovnog_dnevnog_unosa', :with => 3000
    check 'stavka_doplatak_izmisljeni_check_box'

  end

  test "izmisljeni doplatak" do
    @polica.dodaj_stavke( :racunala, "I", :vrijednost_sustava => 1000000, :II1PG => :da, :trosak_ponovnog_dnevnog_unosa => 2000, 
                          :doplatak_izmisljeni => :da, :povecana_pouzdanost => :da)
    fill_in 'stavka_vrijednost_sustava', :with => 1000000
    check 'stavka_II1PG_check_box'
    fill_in 'stavka_trosak_ponovnog_dnevnog_unosa', :with => 2000
    check 'stavka_doplatak_izmisljeni_check_box'
    check 'stavka_povecana_pouzdanost_check_box'
  end

  def teardown
    fill_in 'stavka_adresa', :with => 'Dubovacka 1'
    assert_selector_content  "span#stavka_iznos_premije", to_c(@polica.premija)
  end

  def assert_selector_content (selector, content)
    sleep(2)
    matcher = have_selector selector
    assert matcher.matches?(response_body), "Ne postoji #{selector}"
    matcher = have_selector selector, :content => content 
    assert matcher.matches?(response_body), "Nadjen #{selector}, ali sadrzaj nije #{content}"
  end
  
end
