require "test_helper"

class AoTest < ActiveSupport::TestCase

  def setup
    @osiguranje = Ao.new("I")
  end

  def test_jednostavna_premija
    @osiguranje.init_postavke(:registracija => "ZG", :snaga => 55)
    assert_equal 2313.40, @osiguranje.svota_osiguranja
    assert_equal 2690.48, @osiguranje.stavka.premija.round(2)
    @osiguranje.init_postavke(:registracija => "ST-483-DA", :snaga => 90)
    assert_equal 1913.80, @osiguranje.svota_osiguranja
    assert_equal 3343.41, @osiguranje.stavka.premija.round(2)
  end

  def test_premija_ino
    @osiguranje = Ao.new("VIII")
    @osiguranje.init_postavke(:registracija => "ZG", :vrsta_vozila_ino => :motocikl_moped, :trajanje => :do_90)
    assert_equal 280.00, @osiguranje.svota_osiguranja
    assert_equal 280.00, @osiguranje.stavka.premija.round(2)
  end
end
