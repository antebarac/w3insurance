#encoding: utf-8
require "test_helper"

class TableTest2 < ActiveSupport::TestCase
       @@definicija = <<DELIMITER

Defaultni opis
=============
osigurana_svota   stopa   oznaka    opis
---------------------------------------
000k-170k          8.40    1111     Osiguranje računalnog centra
170k-260k          7.20    1112     Milence
260k-390k          6.60    1113     Osiguranje računalnog centra
390k-550k          5.90    1114     Osiguranje računalnog centra
550k-770k          5.40    1115     Osiguranje računalnog centra
770k-970k          4.80    1116     Osiguranje računalnog centra
970k-inf.          4.30    111A     -
---------------------------------------
DELIMITER

       @@definicija_nil = <<DELIMITER
Osiguranje računalnog centra
=============
osigurana_svota     stopa   oznaka
---------------------------------
000k-170k           8.40    1111 
170k-260k           -       1112 
260k-390k           6.60    1113 
390k-550k           5.90    1114 
550k-770k           5.40    1115 
770k-970k           4.80    1116 
970k-inf.           -       111A 
----------------------------------
DELIMITER

       @@definicija_crazy_spacing = <<DELIMITER
Osiguranje računalnog centra
=============
osigurana_svota   stopa   oznaka    opis
---------------------------------
000k-170k                  8.40                  1111                  Osiguranje računalnog centra
------------------------------
DELIMITER

       @@definicija_bool = <<DELIMITER
Osiguranje računalnog centra
=============
osigurana_svota   stopa   oznaka
---------------------------------
true               8.40    1111    
false              6.60    1113    
--------------------------------          
DELIMITER

      @@definicija_funkcija = <<DELIMITER
Procesna racunala
=======================================================================================
procesna_racunala   oznaka     doplatak   opis
---------------------------------------------------------------------------------------
samostalna          1S21           F      Doplatak na samostalno procesno računalo  
ugradjena           1S31           F      Doplatak na ugrađeno procesno računalo
---------------------------------------------------------------------------------------
DELIMITER

@@definicija_funkcija_embedded = <<DELIMITER
Procesna racunala
#vp = vrijednost_procesnih_racunala
#vs = vrijednost_sustava
===================================================================================================================================================
procesna_racunala   oznaka         doplatak           opis
--------------------------------------------------------------------------------------------------------------------------------------------------
samostalna          1S21         =25% * vp/vs         Doplatak na samostalno procesno računalo  
ugradjena           1S31         =35% * vp/vs         Doplatak na ugrađeno procesno računalo
slonovska           1S41         =1.5 * vs - vp       -
--------------------------------------------------------------------------------------------------------------------------------------------------
DELIMITER

@@definicija_problematican_doplatak = <<DELIMITER
Doplatak na odbitnu franšizu
==================================================================================================
odbitna_fransiza                oznaka              doplatak     opis 
--------------------------------------------------------------------------------------------------
fransiza_0                      S111                100%         Doplatak za odbitnu franšizu od 0%
fransiza_10                     S112                50%          Doplatak za odbitnu franšizu od 10%
fransiza_ostalo_doplatak        S11A                0.00%        Doplatak za dogovorenu odbitnu franšizu
--------------------------------------------------------------------------------------------------
DELIMITER

@@definicija_sa_multi_keyevima = <<DELIMITER
Osnovice
=================================
kljuc             vrijednost
---------------------------------
JEDAN,DVA         100.00
TRI,CETIRI        200.50
---------------------------------
DELIMITER


  test "Definicija sa multi keyevima" do
    t = Table.new(@@definicija_sa_multi_keyevima)
    assert_equal 100, t.evaluate(:kljuc => "JEDAN")[:vrijednost_original].to_f
    assert_equal 100, t.evaluate(:kljuc => "DVA")[:vrijednost_original].to_f
    assert_equal 200.50, t.evaluate(:kljuc => "TRI")[:vrijednost_original].to_f
    assert_equal 200.50, t.evaluate(:kljuc => "CETIRI")[:vrijednost_original].to_f
  end

  test "Doplatak na odbitnu fransizu" do
    t = Table.new(@@definicija_problematican_doplatak)
    assert_equal "Doplatak za odbitnu franšizu od 10%", t.evaluate(:odbitna_fransiza => :fransiza_10)[:opis]
  end

  test "Parsiranje funkcije" do
    t = Table.new(@@definicija_funkcija_embedded)
    assert_equal(2.5, t.evaluate(:vrijednost_procesnih_racunala => 1, :vrijednost_sustava => 10, :procesna_racunala => :samostalna)[:doplatak])
    assert_equal(3.5, t.evaluate(:vrijednost_procesnih_racunala => 1, :vrijednost_sustava => 10, :procesna_racunala => :ugradjena)[:doplatak])
    assert_equal(14, t.evaluate(:vrijednost_procesnih_racunala => 1, :vrijednost_sustava => 10, :procesna_racunala => :slonovska)[:doplatak])
  end

  test "Odredi doplatak kao funckiju" do
    t = Table.new(@@definicija_funkcija)
    assert_equal "1S21", t.evaluate(:procesna_racunala => :samostalna)[:oznaka]
    assert_equal "Doplatak na samostalno procesno računalo", t.evaluate(:procesna_racunala => :samostalna)[:opis]
    assert_equal :posto, t.evaluate(:procesna_racunala => :samostalna)[:doplatak_tip]
    assert_equal :stopa_samostalna_procesna_racunala, t.evaluate(:procesna_racunala => :samostalna)[:doplatak]
    assert_equal :stopa_ugradjena_procesna_racunala, t.evaluate(:procesna_racunala => :ugradjena)[:doplatak]
  end

  def test_globalni_opis
    t = Table.new(@@definicija_bool)
    assert_equal "Osiguranje računalnog centra", t.evaluate(:osigurana_svota => true)[:opis]
    assert_equal "Osiguranje računalnog centra", t.evaluate(:osigurana_svota => false)[:opis]
  end
  def test_opis
    t = Table.new(@@definicija)
    assert_equal "Milence", t.evaluate(:osigurana_svota => 170000)[:opis]
    assert_equal "Osiguranje računalnog centra", t.evaluate(:osigurana_svota => 260000)[:opis]
    assert_equal "Osiguranje računalnog centra", t.evaluate(:osigurana_svota => 770000)[:opis]
    assert_equal "Defaultni opis", t.evaluate(:osigurana_svota => 1000000)[:opis]
  end

  def test_init
    t = Table.new(@@definicija)
    assert_equal 0.0072, t.evaluate(:osigurana_svota => 170001)[:stopa]
    assert_equal "1112", t.evaluate(:osigurana_svota => 170000)[:oznaka]
    assert_equal "Milence", t.evaluate(:osigurana_svota => 170000)[:opis]
  end
  
  def test_nil
    t = Table.new(@@definicija_nil)
    assert_equal nil, t.evaluate(:osigurana_svota => 990000)[:stopa]
    assert_equal nil, t.evaluate(:osigurana_svota => 180000)[:stopa]
  end
  
  def test_crazy_spacing
    t = Table.new(@@definicija_crazy_spacing)
    assert_equal 0.0084, t.evaluate(:osigurana_svota => 120000)[:stopa]
  end
  
  def test_bool
    t = Table.new(@@definicija_bool)
    assert_equal 0.0084, t.evaluate(:osigurana_svota => true)[:stopa]
  end

=begin
  test "vrati stopu kao objekt" do
   t = Table.new(@@definicija)
   assert_equal 0.0072, t.get_stopa(:osigurana_svota => 170000).koeficijent
   assert_equal "1112", t.get_stopa(:osigurana_svota => 170000).oznaka
   assert_equal "Milence", t.get_stopa(:osigurana_svota => 170000).opis
   assert_equal '7.20‰', t.get_stopa(:osigurana_svota => 170000).to_s
   assert_equal :promil, t.get_stopa(:osigurana_svota => 170000).tip
  end
=end
end
