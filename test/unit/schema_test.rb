require 'test_helper'

class SchemaTest<ActiveSupport::TestCase
  @@definicija = <<DELIMITER
I:
  opis+: text
  adresa: text
  vrijednost_sustava*: decimal
  procesna_racunala*: [ nije_procesno_racunalo, ugradjena, samostalna ]
  pojedinacno_racunalo*: 
    ne:
      poseban_dogovor*:
        nema_posebnog_dogovora
        bankomati:
          popis_bankomata*: text
        osobna_racunala:
          broj_racunala*: integer
        licence_programa:
          cijena_licenci*: decimal
    da:
      vrijednost_pojedinacnog_racunala*: decimal

II1PG:
  vrijednost_sustava*: decimal
  trosak_ponovnog_unosa*: decimal
  procesna_racunala*: [ nije_procesno_racunalo, ugradjena, samostalna ]
  povecana_pouzdanost*: [ da, ne ]

II2PG:
  trosak_za_najam*: decimal

III:
  vrijednost_sustava*: decimal
  trosak_za_najam*: decimal
  fransiza*: [ 2d, 3d, 5d, 10d, 20d ]
  jamstveno_razdoblje*: [ 1g, 9m, 6m, 3m, 2m, 1m ]

IV:
  neobavezno: decimal
  obavezno+: text
  esencijalno*: integer
  ima_dijete:
    da:
      dijete: text
    ne:
      pas: text
DELIMITER

@@definicija2 =<<DELIMITER
    assert_equal(4, list.size)
    assert_equal({:vrijednost_sustava => true, :trosak_ponovnog_unosa => true, :procesna_racunala => true, :povecana_pouzdanost => true } , list)
I:
  opis: text
  svota_osiguranja: decimal
DELIMITER

@@definicija3 =<<DELIMITER
I:
  neko_polje:
     oznaka: text
DELIMITER

@@definicija4 =<<DELIMITER
I:
  procesna_racunala*: 
    nije_procesno_racunalo: []
    ugradjena:
      vrijednost_procesnih_racunala*: decimal
    samostalna:
      vrijednost_procesnih_racunala*: decimal
DELIMITER

@@definicija5 = <<DELIMITER
I:
  procesna_racunala*: 
    nije_procesno_racunalo: []
    samostalna:
      vrijednost_procesnih_racunala*: decimal
  popust_na_garanciju?: decimal
DELIMITER


@@definicija5 = <<DELIMITER
I:
  procesna_racunala*: 
    nije_procesno_racunalo: []
    samostalna:
      vrijednost_procesnih_racunala*: decimal
  popust_na_garanciju?: =6.3%
DELIMITER


@@definicija6 = <<DELIMITER
I:
  procesna_racunala*: 
    nije_procesno_racunalo: []
    samostalna:
      vrijednost_procesnih_racunala*: decimal
  popust_na_garanciju?: =0%-20%
DELIMITER

@@definicija7 = <<DELIMITER
NAZIV: Osiguranje racunala

Z[!POTRES,!NEZGODA]:
  doplatak_za_povecanu_opasnost?: =10%-30%
  postotak_sudjelovanja_u_steti*: [ sudjelovanje_10, sudjelovanje_0, ostalo_manje_od_10, sudjelovanje_15, sudjelovanje_20, sudjelovanje_25, ostalo_preko_10 ]
  vrsta_uredjaja_za_gasenje*: [nema_uredjaja, automatski_s_CO2_ili_halonom, uredjaj_koji_dojavljuje_pozar, uredjaj_za_neprekidno_napajanje]
  popust_na_garanciju[I]?: =do 20%
  doplatak_za_troskove_popravka[II1PG]?: =6.3%
  doplatak_troskovi_inozemstvo[!I]?: =6.3%-20%
  doplatak_za_trazenje_greske[!III]?: =6.3%

I:
  opis+: text
  adresa: text
  vrijednost_sustava*: doplatak_troskovi_inozemstvo
  procesna_racunala*: [ nije_procesno_racunalo, ugradjena, samostalna ]
  pojedinacno_racunalo*: 
    ne:
      poseban_dogovor*:
        bankomati:
          popis_bankomata*: text
        osobna_racunala:
          broj_racunala*: integer
        licence_programa:
          cijena_licenci*: decimal
    da:
      vrijednost_pojedinacnog_racunala*: decimal

II1PG!:
  vrijednost_sustava*: decimal
  trosak_ponovnog_unosa*: decimal
  procesna_racunala*: [ nije_procesno_racunalo, ugradjena, samostalna ]
  povecana_pouzdanost*: [ da, ne ]

III!:
  vrijednost: decimal

POTRES!:
  ne: []
  da:
    vrijednost_osiguranja*: decimal
    opis: text
    mile: money
    milence: integer

NEZGODA!:
  ne: []
  da:
    iznos_za_nezgodu
DELIMITER

@@definicija8 = <<DELIMITER
NAZIV: Osiguranje racunala

Z:
  doplatak_za_povecanu_opasnost?: =10%-30%
  popust_na_garanciju[I]?: =do 20%
  doplatak_za_troskove_popravka[II]?: =10.3%
  doplatak_troskovi_inozemstvo[!I]?: =6.3%-20%
  doplatak_za_trazenje_greske[III]?: =9.3%
  doplatak_za_osiguranje_amortizirane_vrijednosti*:
    ne: []
    da:
      prosjecna_otpisanost_opreme*: decimal 
 
I:
  opis+: text

II:
  milence: decimal

III!:
  ne: []
  da:
    milence: decimal
DELIMITER


  test 'dublja hijerarhija zajednickih odredbi' do
    schema = Schema.new(:racunala, @@definicija8)
    assert_equal(3, schema.shared_popusti_i_doplatci("I").size)
  end

  test 'original_children list' do
    schema = Schema.new(:racunala, @@definicija7)
    assert_equal(:opis, schema.original_children(:I)[0].name)
    assert_equal(:adresa, schema.original_children(:I)[1].name)
    assert_equal(:vrijednost_sustava, schema.original_children(:I)[2].name)
    assert_equal(:procesna_racunala, schema.original_children(:I)[3].name)
    assert_equal(:pojedinacno_racunalo, schema.original_children(:I)[4].name)
    assert_equal(:poseban_dogovor, schema.original_children(:I)[5].name)
    assert_equal(:popis_bankomata, schema.original_children(:I)[6].name)
    assert_equal(:broj_racunala, schema.original_children(:I)[7].name)
    assert_equal(:cijena_licenci, schema.original_children(:I)[8].name)
    assert_equal(:vrijednost_pojedinacnog_racunala, schema.original_children(:I)[9].name)
    assert_equal(10, schema.original_children(:I).size)
  end


  test 'popusti i doplatci po grupi' do
    schema = Schema.new(:racunala, @@definicija7)
    lista = schema.I.popusti_i_doplatci
    assert_equal(5, lista.size)
    lista = schema.POTRES.popusti_i_doplatci
    assert_equal(0, lista.size)
    lista = schema.NEZGODA.popusti_i_doplatci
    assert_equal(0, lista.size)
    lista = schema.II1PG.popusti_i_doplatci
    assert_equal(6, lista.size)
  end

  test 'popusti i doplatci grupirani za sucelje' do
    schema = Schema.new(:racunala, @@definicija7)
    lista = schema.popusti_i_doplatci(:I)
    assert_equal(1, lista.size)
    lista = schema.popusti_i_doplatci(:II1PG)
    assert_equal(1, lista.size)
    lista = schema.popusti_i_doplatci(:Z)
    assert_equal(5, lista.size)
    lista = schema.popusti_i_doplatci(:POTRES)
    assert_equal(0, lista.size)
    lista = schema.popusti_i_doplatci(:NEZGODA)
    assert_equal(0, lista.size)
    lista = schema.shared_popusti_i_doplatci("III")
    assert_equal(4, lista.size)
  end

  test "schema s dodatnim pokricem" do
    schema = Schema.new(:racunala, @@definicija7)
    assert schema.I.visibility_list[:POTRES].visible == true
  end


  test "schema s dodatnim pokricem koje je odabrano" do
    schema = Schema.new(:racunala, @@definicija7)
    assert schema.I.visibility_list(:POTRES => "da")[:"milence"].visible == true
  end

  test "preload defaults" do
    schema = Schema.new(:racunala, @@definicija5)
    schema.I.preload_defaults({:procesna_racunala => :samostalna, :popust_na_garanciju => :da})
    assert_equal({:procesna_racunala => :samostalna, :popust_na_garanciju => :da, :popust_na_garanciju_iznos => "6.3"}, schema.I.postavke)
  end

  test 'preload defaults za druga grupa' do
    schema = Schema.new(:racunala, @@definicija8)
    schema.II.preload_defaults({:milence => 100.00,:doplatak_za_troskove_popravka => :da})
    assert_equal({:milence => 100.00, :doplatak_za_troskove_popravka => :da, :doplatak_za_troskove_popravka_iznos => "10.3" }, schema.II.postavke)
  end

  test 'preload defaults za dodatno pokrice' do
    schema = Schema.new(:racunala, @@definicija8)
    schema.III.preload_defaults({:iznos => 100.00,:doplatak_za_trazenje_greske => :da})
    assert_equal({:iznos => 100.00, :doplatak_za_trazenje_greske => :da, :doplatak_za_trazenje_greske_iznos => "9.3" }, schema.III.postavke)
  end

  test "iznos optional polja range" do
    schema = Schema.new(:racunala, @@definicija6)
    list = schema.I.visibility_list(:procesna_racunala => :nije_procesno_racunalo, :popust_na_garanciju => "da")
    assert_equal({:procesna_racunala => NodeInfo.new(true) , :vrijednost_procesnih_racunala => NodeInfo.new(false), :popust_na_garanciju => NodeInfo.new(true, 0) }, list)
  end

  test "iznos optional polja" do
    schema = Schema.new(:racunala, @@definicija5)
    list = schema.I.visibility_list(:procesna_racunala => :nije_procesno_racunalo, :popust_na_garanciju => "da")
    assert_equal({:procesna_racunala => NodeInfo.new(true) , :vrijednost_procesnih_racunala => NodeInfo.new(false), :popust_na_garanciju => NodeInfo.new(true, 6.3) }, list)
  end

  test "optional polja" do
    schema = Schema.new(:racunala, @@definicija5)
    list = schema.I.visibility_list(:procesna_racunala => :nije_procesno_racunalo)
    assert_equal(3, list.size)
  end


  test "raspisi optional polje"  do
    schema = Schema.new(:racunala, @@definicija5)
    list = schema.I.visibility_list(:procesna_racunala => :nije_procesno_racunalo, :popust_na_garanciju => "da")
    assert_equal(3, list.size)
    assert_equal({:procesna_racunala => NodeInfo.new(true), :vrijednost_procesnih_racunala => NodeInfo.new(false), :popust_na_garanciju => NodeInfo.new(true, "6.3")}, list)

  end

  test "Ponavljanje atributa" do
    schema = Schema.new(:racunala, @@definicija4)
    list = schema.I.visibility_list(:procesna_racunala => :ugradjena)
    assert_equal(2, list.size)
    assert_equal({ :procesna_racunala => NodeInfo.new(true), :vrijednost_procesnih_racunala => NodeInfo.new(true) } , list)
    assert_equal(2, schema.I.enumerate.size)
    list = schema.I.visibility_list(:procesna_racunala => :samostalna)
    assert_equal(2, list.size)
    assert_equal({ :procesna_racunala => NodeInfo.new(true), :vrijednost_procesnih_racunala => NodeInfo.new(true) } , list)
    assert_equal(2, schema.I.enumerate.size)
  end

  test "Rezervirane rijeci" do
   assert_raise ArgumentError do 
    schema = Schema.new(:racunala, @@definicija2)
   end
  end

  test "Rezervirane rijeci unutar strukutre" do
   assert_raise ArgumentError do
    schema = Schema.new(:racunala, @@definicija3)
   end
  end

  test "Visible lista" do
    schema = Schema.new(:racunala, @@definicija)
    list = schema.II2PG.visibility_list
    assert_equal({:trosak_za_najam => NodeInfo.new(true) } , list)
  end

  test "Visible lista 4" do
    schema = Schema.new(:racunala, @@definicija)
    list = schema.II1PG.visibility_list
    assert_equal(4, list.size)
    assert_equal({:vrijednost_sustava => NodeInfo.new(true), :trosak_ponovnog_unosa => NodeInfo.new(true), :procesna_racunala => NodeInfo.new(true), :povecana_pouzdanost => NodeInfo.new(true) } , list)
  end
  
  test "Visible s djetetom" do
    schema = Schema.new(:racunala, @@definicija)
    list = schema.IV.visibility_list(:ima_dijete => :da)
    assert_equal({:neobavezno => NodeInfo.new(true), :obavezno => NodeInfo.new(true), :esencijalno => NodeInfo.new(true), :ima_dijete => NodeInfo.new(true), :dijete => NodeInfo.new(true), :pas => NodeInfo.new(false)}, list)
    list = schema.IV.visibility_list(:ima_dijete => :ne)
    assert_equal({:neobavezno => NodeInfo.new(true), :obavezno => NodeInfo.new(true), :esencijalno => NodeInfo.new(true), :ima_dijete => NodeInfo.new(true), :dijete => NodeInfo.new(false), :pas => NodeInfo.new(true)}, list)
  end

  test "+ i * modifieri" do
    schema = Schema.new(:racunala, @@definicija)
    assert_equal(false, schema.IV[:neobavezno].required?)    
    assert_equal(false, schema.IV[:neobavezno].essential?)
    assert_equal(true, schema.IV[:obavezno].required?)
    assert_equal(false, schema.IV[:obavezno].essential?)
    assert_equal(true, schema.IV[:esencijalno].required?)
    assert_equal(true, schema.IV[:esencijalno].essential?)
  end

  test "node type" do
    schema = Schema.new(:racunala, @@definicija)
    assert_equal(:branch, schema.IV[:da].type)
    assert_equal(:enum, schema.IV[:ima_dijete].type)
  end

  test "optional node" do
    schema = Schema.new(:racunala, @@definicija5)
    assert_equal(:fixed_percentage, schema.I[:popust_na_garanciju].type)
    assert_equal(true, schema.I[:popust_na_garanciju].optional?)
  end

  test "milence" do
    schema = Schema.new(:racunala, @@definicija7)
    assert_raise RuntimeError do
      schema.milence
    end
  end

  test "lista premijskih grupa" do
    schema = Schema.new(:racunala, @@definicija7)
    assert_equal(1, schema.premijske_grupe.size)
    assert_equal("I", schema.premijske_grupe["I"].oznaka)

    assert_equal(4, schema.dodatna_pokrica.size)
    assert_equal("II1PG", schema.dodatna_pokrica["II1PG"].oznaka)    
    assert_equal("Osiguranje racunala", schema.naziv)
    assert_equal("POTRES", schema.dodatna_pokrica["POTRES"].oznaka)
    assert_equal("NEZGODA", schema.dodatna_pokrica["NEZGODA"].oznaka)

  end

end
