require 'test_helper'

class RacunalaITest < ActiveSupport::TestCase

  def setup
    @osiguranje =  Racunala.new("I")
  end

  def test_osiguranje_should_have_vrstu_osiguranja_1111
    @osiguranje.init_postavke(:vrijednost_sustava => 100000)
    assert_equal "1111", @osiguranje.stavka.oznaka 
  end

  def test_osiguranje_should_have_vrstu_osiguranja_1111_test_2
    @osiguranje.init_postavke(:vrijednost_sustava => 115000)
    assert_equal  "1111", @osiguranje.stavka.oznaka 
  end

  def test_osiguranje_should_have_vrstu_osiguranja_1112
    @osiguranje.init_postavke(:vrijednost_sustava => 170000)
    assert_equal  "1111", @osiguranje.stavka.oznaka
  end

  def test_osiguranje_should_have_vrstu_osiguranja_1112
    @osiguranje.init_postavke(:vrijednost_sustava => 200000)
    assert_equal "1112", @osiguranje.stavka.oznaka 
  end

  def test_osiguranje_should_have_vrstu_osiguranja_1113
    @osiguranje.init_postavke(:vrijednost_sustava => 300000)
    assert_equal "1113", @osiguranje.stavka.oznaka  
  end

  def test_osiguranje_should_have_vrstu_osiguranja_111A
    @osiguranje.init_postavke(:vrijednost_sustava => 1000000)
    assert_equal "111A", @osiguranje.stavka.oznaka 
  end

  def test_osiguranje_should_have_vrstu_osiguranja_1114
    @osiguranje.init_postavke(:vrijednost_sustava => 500000)
    assert_equal "1114", @osiguranje.stavka.oznaka
  end

  def test_osiguranje_should_have_vrstu_osiguranja_1115
    @osiguranje.init_postavke(:vrijednost_sustava => 745000)
    assert_equal "1115", @osiguranje.stavka.oznaka 
  end

  def test_osiguranje_should_have_vrstu_osiguranja_1116
    @osiguranje.init_postavke(:vrijednost_sustava => 912000)
    assert_equal "1116", @osiguranje.stavka.oznaka 
  end

  def test_premija_za_milion_kuna
    @osiguranje.init_postavke(:vrijednost_sustava => 1000000)
    assert_equal 4300, @osiguranje.stavka.premija
  end

  def test_premija_za_sto_tisuca_kuna
    @osiguranje.init_postavke(:vrijednost_sustava => 100000)
    assert_equal 840, @osiguranje.stavka.premija
  end

  def test_racunala_prva_premijska_grupa
    @osiguranje.init_postavke(:vrijednost_sustava => 200000)
    assert_equal 1440, @osiguranje.stavka.premija

    @osiguranje.init_postavke(:vrijednost_sustava => 1000000)
    assert_equal 4300, @osiguranje.stavka.premija
  end

  def test_racunala_prva_premijska_grupa_bankomati
    @osiguranje.init_postavke(:vrijednost_sustava => 200000, :poseban_dogovor => :bankomati)
    assert_equal(1680, @osiguranje.stavka.premija)
    assert_equal("1311", @osiguranje.stavka.oznaka)
  end

  def test_racunala_prva_premijska_grupa_poseban_dogovor
    @osiguranje.init_postavke(:vrijednost_sustava => 200000, :poseban_dogovor => :osobna_racunala, :broj_racunala => 5)
    assert_equal(2520, @osiguranje.stavka.premija)
    assert_equal("1211", @osiguranje.stavka.oznaka)
    assert_equal(:promil, @osiguranje.stavka.stopa.tip)
    assert_equal(0.01260, @osiguranje.stavka.stopa.koeficijent)
  end

  def test_racunala_prva_premijska_grupa_poseban_dogovor_10_ili_vise
    @osiguranje.init_postavke(:vrijednost_sustava => 200000, :poseban_dogovor => :osobna_racunala, :broj_racunala => 10)
    assert_equal(1440, @osiguranje.stavka.premija)
    assert_equal("1211", @osiguranje.stavka.oznaka)
    assert_equal(:promil, @osiguranje.stavka.stopa.tip)
    assert_equal(0.0072, @osiguranje.stavka.stopa.koeficijent)
  end

  def test_racunala_prva_premijska_grupa_sa_licencom_programa
    @osiguranje.init_postavke(:vrijednost_sustava => 200000, :poseban_dogovor=> :licence_programa, :cijena_licenci => 30000)
    assert_equal(216, @osiguranje.stavka.premija)
    assert_equal("1411", @osiguranje.stavka.oznaka)
    assert_equal(:promil, @osiguranje.stavka.stopa.tip)
    assert_equal(0.0072, @osiguranje.stavka.stopa.koeficijent)
  end

  
  def test_racunala_prva_premijska_samostalna_procesna_racunala
    @osiguranje.init_postavke(:vrijednost_sustava => 200000, :procesna_racunala => :samostalna, :vrijednost_procesnih_racunala => 200000)
    assert_equal(1440, @osiguranje.stavka.temeljna_premija)
    assert_equal(360, @osiguranje.stavka.doplatci[0].premija)
  end

  def test_racunala_prva_premijska_samostalna_procesna_racunala_udio_manji_od_100_posto
    @osiguranje.init_postavke(:vrijednost_sustava => 1000000, :procesna_racunala => :samostalna, :vrijednost_procesnih_racunala => 100000)
    assert_equal(4300, @osiguranje.stavka.temeljna_premija)
    assert_equal(107.5, @osiguranje.stavka.doplatci[0].premija)
    assert_equal("2.5%", @osiguranje.stavka.doplatci[0].stopa.to_s)
  end

  def test_racunala_prva_premijska_grupa_ugradjena_procesna_racunala
    @osiguranje.init_postavke(:vrijednost_sustava => 200000, :procesna_racunala => :ugradjena, :vrijednost_procesnih_racunala => 200000)
    assert_equal(1440, @osiguranje.stavka.temeljna_premija)
    assert_equal(504, @osiguranje.stavka.doplatci[0].premija)
  end
  
  
  def test_racunala_prva_premijska_grupa_pojedinacno
    @osiguranje.init_postavke(:vrijednost_sustava => 200000, :vrijednost_pojedinacnih_uredjaja => 60000, :pojedinacno_racunalo => :da)
    assert_equal(432, @osiguranje.stavka.temeljna_premija)
    assert_equal("1112", @osiguranje.stavka.oznaka)
    assert_equal(172.80, @osiguranje.stavka.doplatci[0].premija.to_f)
    assert_equal("1S12", @osiguranje.stavka.doplatci[0].oznaka)
  end
  
  def test_racunala_prva_premijska_grupa_poseban_dogovor_10_ili_vise_broj_racunala_kao_string
    @osiguranje.init_postavke(:vrijednost_sustava => 200000, :poseban_dogovor => :osobna_racunala, :broj_racunala => '12')
    assert_equal(1440, @osiguranje.stavka.premija)
    assert_equal("1211", @osiguranje.stavka.oznaka)
  end

  def test_racunala_prva_premijska_grupa_poseban_dogovor_10_ili_vise_broj_racunala_kao_string
    assert_raise(ArgumentError) do
      @osiguranje.init_postavke(:vrijednost_sustava => 200000, :poseban_dogovor => :osobna_racunala, :broj_racunala => '12.2')
    end
  end

  test 'decimale' do
    @osiguranje.init_postavke(:vrijednost_sustava => "200000", :poseban_dogovor => :osobna_racunala, :broj_racunala => '12')
    assert_equal(1440, @osiguranje.stavka.premija)
    assert_equal("1211", @osiguranje.stavka.oznaka)
  end

  test 'pojedinacni uredjaj od 60000 u centru od 200000' do
    @osiguranje.init_postavke(:poseban_dogovor=>:nema_posebnog_dogovora,
       :vrijednost_pojedinacnih_uredjaja=>60000,
       :procesna_racunala=>:nije_procesno_racunalo,
       :vrijednost_sustava=>200000,
       :pojedinacno_racunalo=>:da)
    assert_equal(432, @osiguranje.stavka.temeljna_premija)
    assert_equal("1112", @osiguranje.stavka.oznaka)
    assert_equal(172.80, @osiguranje.stavka.doplatci[0].premija.to_f)
    assert_equal("1S12", @osiguranje.stavka.doplatci[0].oznaka)
 end

  test 'skraceni doplatci doplatak za troskove popravka' do
    @osiguranje.init_postavke(:vrijednost_sustava => 1000000, :doplatak_za_troskove_popravka => 'da', :doplatak_za_troskove_popravka_iznos => 6.3)
    assert_equal(4300, @osiguranje.stavka.temeljna_premija)
    assert_equal(270.90, @osiguranje.stavka.doplatci[0].premija.to_f)
  end


  test 'skraceni doplatci doplatak za povecanu opasnost' do
    @osiguranje.init_postavke(:vrijednost_sustava => 1000000, :doplatak_za_povecanu_opasnost => 'da', :doplatak_za_povecanu_opasnost_iznos => 11)
    assert_equal(4300, @osiguranje.stavka.temeljna_premija)
    assert_equal(473.0, @osiguranje.stavka.doplatci[0].premija.to_f)
  end

  test 'skraceni popust na garanciju' do
  
    @osiguranje.init_postavke( :vrijednost_sustava => 1000000, :procesna_racunala => :nije_procesno_racunalo, :pojedinacno_racunalo => :ne,
                          :poseban_dogovor => :nema_posebnog_dogovora, :doplatak_za_osiguranje_amortizirane_vrijednosti => :ne, 
                          :postotak_sudjelovanja_u_steti => :sudjelovanje_10, :vrsta_uredjaja_za_gasenje => :nema_uredjaja, :popust_na_garanciju => :da,
                          :popust_na_garanciju_iznos => 10) 
    assert_equal(4300, @osiguranje.stavka.temeljna_premija)
    assert_equal(-430.0, @osiguranje.stavka.popusti[0].premija.to_f)
 end
  

  test 'skraceni doplatci puni podaci' do
    @osiguranje.init_postavke( :opis => "", :adresa =>"", :vrijednost_sustava =>"1000000",
                          :procesna_racunala=>"nije_procesno_racunalo", 
                          :pojedinacno_racunalo_check_box=>"0", :pojedinacno_racunalo=>"ne", :poseban_dogovor=>"nema_posebnog_dogovora",
                          :doplatak_za_osiguranje_amortizirane_vrijednosti_check_box=>"0", :doplatak_za_osiguranje_amortizirane_vrijednosti=>"ne",
                          :doplatak_za_povecanu_opasnost_check_box=>"0", 
                          :postotak_sudjelovanja_u_steti=>"sudjelovanje_10", 
                          :vrsta_uredjaja_za_gasenje=>"nema_uredjaja", :popust_na_garanciju_check_box=>"0", 
                          :doplatak_za_troskove_popravka_check_box=>"1", :doplatak_za_troskove_popravka=>"da", 
                          :doplatak_za_troskove_popravka_iznos => 6.3,
                          :doplatak_troskovi_inozemstvo_check_box=>"0",
                          :doplatak_za_trazenje_greske_check_box=>"0") 
    assert_equal(4300, @osiguranje.stavka.temeljna_premija)
    assert_equal(270.90, @osiguranje.stavka.doplatci[0].premija.to_f)
  end
  
  test "racunala s default vrijednosti" do
    @osiguranje.init_postavke(:vrijednost_sustava => 1000000, :prosjecna_otpisanost_opreme => 35, :popust_na_garanciju => "da", :popust_na_garanciju_iznos => 10, 
                        :doplatak_za_trazenje_greske => "da")
    assert_equal(4300, @osiguranje.stavka.temeljna_premija)
    assert_equal(1720, @osiguranje.stavka.doplatci[0].premija)
    assert_equal(379.26, @osiguranje.stavka.doplatci[1].premija)
    assert_equal(-639.926, @osiguranje.stavka.popusti[0].premija.to_f)
  end
 
  test "racunala - test shared doplatka" do
    @osiguranje.init_postavke(:vrijednost_sustava => 1000000, :prosjecna_otpisanost_opreme => 35, :popust_na_garanciju => "da", :popust_na_garanciju_iznos => 10, 
                        :doplatak_za_troskove_popravka => "da")
    assert_equal(4300, @osiguranje.stavka.temeljna_premija)
    assert_equal(1720, @osiguranje.stavka.doplatci[0].premija)
    assert_equal(379.26, @osiguranje.stavka.doplatci[1].premija)
    assert_equal(-639.926, @osiguranje.stavka.popusti[0].premija.to_f)
  end

  test 'skraceni popust na garanciju - bez da' do
  
    @osiguranje.init_postavke( :vrijednost_sustava => 1000000, :procesna_racunala => :nije_procesno_racunalo, :pojedinacno_racunalo => :ne,
                          :poseban_dogovor => :nema_posebnog_dogovora, :doplatak_za_osiguranje_amortizirane_vrijednosti => :ne, 
                          :postotak_sudjelovanja_u_steti => :sudjelovanje_10, :vrsta_uredjaja_za_gasenje => :nema_uredjaja, :popust_na_garanciju => :ne,
                          :popust_na_garanciju_iznos => 10) 
    assert_equal(4300, @osiguranje.stavka.temeljna_premija)
    assert_equal(0, @osiguranje.stavka.popusti.size)
  end
end


