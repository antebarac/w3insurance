require 'test_helper'

class RacunalaII1PGTest < ActiveSupport::TestCase

  def setup
    @cjenik =  Racunala.new('II1PG')
  end


  def test_osiguranje_should_have_vrstu_osiguranja_2111
    @cjenik.init_postavke(:vrijednost_sustava => 115000, :trosak_ponovnog_dnevnog_unosa => 10000)
    assert_equal "2111", @cjenik.stavka.oznaka 
    assert_equal 336, @cjenik.stavka.premija 
  end

  def test_osiguranje_should_have_vrstu_osiguranja_211A
    @cjenik.init_postavke(:vrijednost_sustava => 1115000, :trosak_ponovnog_dnevnog_unosa => 10000)
    assert_equal  "211A", @cjenik.stavka.oznaka 
  end

  def test_osiguranje_should_have_vrstu_osiguranja_2114_i_doplatak_za_procesna
    @cjenik.init_postavke(:vrijednost_sustava => 500000, :trosak_ponovnog_dnevnog_unosa => 20000, :procesna_racunala => "samostalna", :vrijednost_procesnih_racunala => 500000)
    assert_equal "2114", @cjenik.stavka.oznaka 

    assert_equal(506, @cjenik.stavka.temeljna_premija) 
    assert_equal(126.5, @cjenik.stavka.doplatci[0].premija)
    assert_equal("2S11", @cjenik.stavka.doplatci[0].oznaka)
  end

  def test_osiguranje_should_have_vrstu_osiguranja_2115_i_doplatak_za_ugradjena_procesna
    @cjenik.init_postavke(:vrijednost_sustava => 700000, :trosak_ponovnog_dnevnog_unosa => 20000, :procesna_racunala => "ugradjena", :vrijednost_procesnih_racunala => 700000)
    assert_equal @cjenik.stavka.oznaka , "2115"
   
    assert_equal(486, @cjenik.stavka.temeljna_premija) 
    assert_equal(170.1, @cjenik.stavka.doplatci[0].premija)
    assert_equal("2S12", @cjenik.stavka.doplatci[0].oznaka)
  end

 def test_osiguranje_should_have_vrstu_osiguranja_2114_i_popust_na_povecanje_pouzdanosti
    @cjenik.init_postavke(:vrijednost_sustava => 500000, :trosak_ponovnog_dnevnog_unosa => 20000, :povecana_pouzdanost => :da)
    assert_equal @cjenik.stavka.oznaka , "2114"

    assert_equal(506, @cjenik.stavka.temeljna_premija) 
    assert_equal(-202.4, @cjenik.stavka.popusti[0].premija)
    assert_equal("2P11", @cjenik.stavka.popusti[0].oznaka)
  end
  
  test "Defaults" do
    assert_equal(:ne, @cjenik.postavke[:povecana_pouzdanost])
    assert_equal(:nije_procesno_racunalo, @cjenik.postavke[:procesna_racunala])
  end
end
