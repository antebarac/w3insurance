#encoding: utf-8
require 'test_helper'

class CjenikTest < ActiveSupport::TestCase

@@definicija = <<DELIMITER
mile-Osiguranje računalnog centra
=============
osigurana_svota   stopa   oznaka
---------------------------------
true               8.40    1111    
false              6.60    1113    
--------------------------------          
DELIMITER

@@definicija2 = <<DELIMITER
#begin 
==============================================================================================================
tip   naziv                                   oznaka    opis
--------------------------------------------------------------------------------------------------------------
 D    doplatak_za_troskove_popravka            R111      Osiguranje troškova popravka za prekovremeni i noćni rad, rad u praznične dane te hitni prijevoz 
 P    popust_za_trazenje_greske                R311      Osiguranje troškova traženja greške
 D    doplatak_troskovi_inozemstvo             R211      Osiguranje povećanih troškova popravka u inozemstvu 
 P    popust_na_garanciju                      P411      Popust na garanciju
--------------------------------------------------------------------------------------------------------------
#end
DELIMITER

@@expected2 = <<DELIMITER
Osiguranje troškova popravka za prekovremeni i noćni rad, rad u praznične dane te hitni prijevoz 
#v = doplatak_za_troskove_popravka_iznos
===
doplatak_za_troskove_popravka  oznaka  doplatak
---
da  R111  =v
---

Osiguranje troškova traženja greške
#v = popust_za_trazenje_greske_iznos
===
popust_za_trazenje_greske  oznaka  popust
---
da  R311  =v
---

Osiguranje povećanih troškova popravka u inozemstvu 
#v = doplatak_troskovi_inozemstvo_iznos
===
doplatak_troskovi_inozemstvo  oznaka  doplatak
---
da  R211  =v
---

Popust na garanciju
#v = popust_na_garanciju_iznos
===
popust_na_garanciju  oznaka  popust
---
da  P411  =v
---

DELIMITER

@@schema_def = <<DELIMITER
I:
  procesna_racunala*: 
DELIMITER

@@schema1 = <<DELIMITER
Z: 
  doplatak_na_glupost[II]: =6.3%
I:
  iznos_osiguranja*: decimal
II:
  svota*: decimal
DELIMITER

@@schema_bez_zajednickih_odredbi_def = <<DELIMITER
I:
  iznos_osiguranja*: decimal
II:
  svota*: decimal
DELIMITER

@@definicija3 = <<DELIMITER
#begin 
==============================================================================================================
tip   naziv                                   oznaka        vrijednost        opis
--------------------------------------------------------------------------------------------------------------
 D    doplatak_za_troskove_popravka            R111         10.0%              Osiguranje troškova popravka za prekovremeni i noćni rad, rad u praznične dane te hitni prijevoz 
 P    popust_za_trazenje_greske                R311         15.0%              Osiguranje troškova traženja greške
 D    doplatak_troskovi_inozemstvo             R211         20.0%              Osiguranje povećanih troškova popravka u inozemstvu 
 P    popust_na_garanciju                      P411         25.0%              Popust na garanciju
--------------------------------------------------------------------------------------------------------------
#end
DELIMITER

@@expected3 = <<DELIMITER
Osiguranje troškova popravka za prekovremeni i noćni rad, rad u praznične dane te hitni prijevoz 
#v = doplatak_za_troskove_popravka_iznos
===
doplatak_za_troskove_popravka  oznaka  doplatak
---
da  R111  10.0%
---

Osiguranje troškova traženja greške
#v = popust_za_trazenje_greske_iznos
===
popust_za_trazenje_greske  oznaka  popust
---
da  R311  15.0%
---

Osiguranje povećanih troškova popravka u inozemstvu 
#v = doplatak_troskovi_inozemstvo_iznos
===
doplatak_troskovi_inozemstvo  oznaka  doplatak
---
da  R211  20.0%
---

Popust na garanciju
#v = popust_na_garanciju_iznos
===
popust_na_garanciju  oznaka  popust
---
da  P411  25.0%
---

DELIMITER



@@schema = Schema.new(:racunala, @@schema_def)

  test 'Cjenik bez zajednickih odredbi' do
    schema = Schema.new(:racunala, @@schema_bez_zajednickih_odredbi_def)
    grupa = Cjenik.new("I", @@definicija, schema)
    grupa.init_postavke(:iznos_osiguranja => 100000)
  end

  test "Preprocess" do
    cjenik = Cjenik.new("I", @@definicija2, @@schema) 
    assert_equal(@@expected2, cjenik.preprocess(@@definicija2))
  end

  test "Preprocess sa fiksnim vrijednostima" do
    cjenik = Cjenik.new("I", @@definicija3, @@schema)
    assert_equal(@@expected3, cjenik.preprocess(@@definicija3))
  end

  test "Proscisti postavke" do
    schema = Schema.new(:racunala, @@schema1)
    cjenik = Cjenik.new("I", @@definicija2, schema)
    assert_equal( {:iznos_osiguranja => 1000 }, cjenik.procisti_postavke({:doplatak_na_glupost => "da", :iznos_osiguranja => 1000}) )

    cjenik = Cjenik.new("II", @@definicija2, schema)
    assert_equal( {:doplatak_na_glupost => "da", :svota => 5000 }, cjenik.procisti_postavke({:doplatak_na_glupost => "da", :svota => 5000}) )

  end


end
