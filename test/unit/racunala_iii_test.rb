require 'test_helper'

class RacunalaIIITest < ActiveSupport::TestCase

  def setup
    @cjenik =  Racunala.new("III")
  end

  def test_osiguranje_should_have_vrstu_osiguranja_3113
    @cjenik.init_postavke(:vrijednost_sustava => 300000, :trosak_za_najam => 80000,  :fransiza => '2d', :jamstveno_razdoblje => '1g')
    
    assert_equal "3113", @cjenik.stavka.oznaka 
    assert_equal 564, @cjenik.stavka.premija
  end

  def test_osiguranje_should_have_vrstu_osiguranja_3125
    @cjenik.init_postavke(:vrijednost_sustava => 600000, :trosak_za_najam => 80000,  :fransiza => '3d', :jamstveno_razdoblje => '1g')
    assert_equal "3125", @cjenik.stavka.oznaka
    assert_equal 700, @cjenik.stavka.premija
  end

  def test_osiguranje_should_have_vrstu_osiguranja_312A
    @cjenik.init_postavke(:vrijednost_sustava => 1000000, :trosak_za_najam => 80000, :fransiza => '5d', :jamstveno_razdoblje => '1g')
    assert_equal "313A", @cjenik.stavka.oznaka
    assert_equal 824, @cjenik.stavka.premija
  end

  def test_osiguranje_should_have_vrstu_osiguranja_315A
    @cjenik.init_postavke(:vrijednost_sustava => 1000000, :trosak_za_najam => 80000, :fransiza => '20d', :jamstveno_razdoblje => '1g')
    assert_equal "315A", @cjenik.stavka.oznaka
    assert_equal 608, @cjenik.stavka.premija
  end
  
  def test_osiguranje_should_have_vrstu_osiguranja_3613_1_mjesec_2_dana_fransiza
    @cjenik.init_postavke(:vrijednost_sustava => 300000, :trosak_za_najam => 80000, :fransiza => '2d', :jamstveno_razdoblje => '1m')
    assert_equal "3613", @cjenik.stavka.oznaka
    assert_equal 384, @cjenik.stavka.premija
  end

end
