require 'test_helper'

class RacunalaII2PGTest < ActiveSupport::TestCase

  def setup
    @osiguranje = Racunala.new('II2PG')
  end

  def test_osiguranje_should_have_vrstu_osiguranja_2211
    @osiguranje.init_postavke(:trosak_ponovnog_unosa_i_instaliranja => 5000)
    assert_equal "2211", @osiguranje.stavka.oznaka 
    assert_equal 200, @osiguranje.stavka.premija
  end

  def test_osiguranje_should_have_vrstu_osiguranja_odredjuje_strucna_sluzba
    @osiguranje.init_postavke(:trosak_ponovnog_unosa_i_instaliranja => 7500)
    assert_equal "odredjuje_strucna_sluzba", @osiguranje.stavka.oznaka 
    assert_equal 0, @osiguranje.stavka.premija
  end
end
