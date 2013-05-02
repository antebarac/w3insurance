require 'test_helper'

class PremijskaGrupaTest < ActiveSupport::TestCase

@@definicija = <<DELIMITER
I:
  procesna_racunala*: 
    nije_procesno_racunalo: []
    samostalna:
      vrijednost_procesnih_racunala*: decimal
  popust_na_garanciju?: =6.3%
DELIMITER

@@definicija1 = <<DELIMITER
Z[!POTRES]:
  mile: decimal
  miki: decimal
  milence[I]: decimal
  jovo[II]: decimal

I:
  procesna_racunala: decimal 
  popust_na_garanciju?: =6.3%
  vrijednost_sustava*: decimal

II!:
  vrijednost_sustava*: decimal
  pero: decimal

POTRES!:
  fransiza: decimal

DELIMITER


  test "Defaults metodu" do
    schema = Schema.new(:racunala, @@definicija)
    premijska_grupa = schema.I
    assert_equal(1, premijska_grupa.defaults.size)
    postavke = { :miki => "voli milenu" }
    premijska_grupa.postavke = postavke
    assert_equal(postavke, premijska_grupa.postavke)
  end

  test "Render list" do
    schema = Schema.new(:racunala, @@definicija1)
    pg = schema.I
    l = pg.render_list
    assert_equal(:procesna_racunala, l[0].name)
    assert_equal(:popust_na_garanciju, l[1].name)
    assert_equal(:vrijednost_sustava, l[2].name)
    assert_equal(:milence, l[3].name)
    assert_equal(:dodatna_osiguranja, l[4].name)
    assert_equal(:II, l[5].name)
    assert_equal(:pero, l[6].name)
    assert_equal(:jovo, l[7].name)
    assert_equal(:POTRES, l[8].name)
    assert_equal(:fransiza, l[9].name)
    assert_equal(:popusti_i_doplatci, l[10].name)
    assert_equal(:mile, l[11].name)
    assert_equal(:miki, l[12].name)
    assert(l[4].type == :title)
    assert(l[10].type == :title)
    assert_equal(13, l.size)
  end

end
