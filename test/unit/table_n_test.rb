#encoding: utf-8
require "test_helper"

class TableNTest < ActiveSupport::TestCase
  @@definicija = <<DELIMITER
Dodatno osiguranje troškova za najam drugog računala
===================================================================================
vrijednost_sustava  
...................................................................................
fransiza                2d           3d          5d          10d         20d
-----------------------------------------------------------------------------------  
jamstveno_razdoblje     1g
...................................................................................
0-170k              3111  4.80 | 3121  4.65 | 3131  4.00 | 3141 3.30 | 3151 2.70
170k-260k           3112  6.00 | 3122  5.80 | 3132  5.00 | 3142 4.20 | 3152 3.40
260k-390k           3113  7.05 | 3123  6.80 | 3133  5.90 | 3143 5.00 | 3153 4.10
390k-550k           3114  7.95 | 3124  7.70 | 3134  6.70 | 3144 5.70 | 3154 4.70
550k-770k           3115  9.05 | 3125  8.75 | 3135  7.70 | 3145 6.60 | 3155 5.45
770k-970k           3116 10.40 | 3126 10.05 | 3136  8.90 | 3146 7.70 | 3156 6.50
970k-inf.           311A 11.90 | 312A 11.60 | 313A 10.30 | 314A 8.95 | 315A 7.60
-----------------------------------------------------------------------------------
jamstveno_razdoblje     9m  
...................................................................................
0-170k              3211  4,65 | 3221  4,55 | 3231 3,85  | 3241 3,20 | 3251 2,55
170k-260k           3212  5,80 | 3222  5,55 | 3232 4,80  | 3242 4,00 | 3252 3,20
260k-390k           3213  6,70 | 3223  6,50 | 3233 5,55  | 3243 4,65 | 3253 3,75
390k-550k           3214  7,50 | 3224  7,30 | 3234 6,25  | 3244 5,25 | 3254 4,25
550k-770k           3215  8,40 | 3225  8,10 | 3235 7,05  | 3245 5,95 | 3255 4,85
770k-970k           3216  9,55 | 3226  9,20 | 3236 8,00  | 3246 6,80 | 3256 5,60
970k-inf.           321A 10,85 | 322A 11,10 | 323A 9,20  | 324A 7,90 | 325A 6,50 
-----------------------------------------------------------------------------------
jamstveno_razdoblje     6m            
...................................................................................
0-170k              3311  4,45 | 3321 4,30  | 3331 3,65  | 3341 2,95 | 3351 2,30
170k-260k           3312  5,55 | 3322 5,30  | 3332 4,55  | 3342 3,75 | 3352 2,95
260k-390k           3313  6,35 | 3323 6,10  | 3333 5,25  | 3343 4,30 | 3353 3,40
390k-550k           3314  7,15 | 3324 6,90  | 3334 5,90  | 3344 4,90 | 3354 3,90
550k-770k           3315  8,00 | 3325 7,70  | 3335 6,65  | 3345 5,55 | 3355 4,45
770k-970k           3316  8,95 | 3326 8,65  | 3336 7,45  | 3346 6,25 | 3356 5,05
970k-inf.           331A 10,10 | 332A 9,75  | 333A 8,50  | 334A 7,15 | 335A 5,80
-----------------------------------------------------------------------------------
DELIMITER

  @@definicija2 = <<DELIMITER
Dodatno osiguranje troškova za najam drugog računala
===================================================================================
vrijednost_sustava  
...................................................................................
fransiza                2d           3d          5d          10d         20d       
-----------------------------------------------------------------------------------
0-170k              3111  4.80 | 3121  4.65 | 3131  4.00 | 3141 3.30 | 3151 2.70
170k-260k           3112  6.00 | 3122  5.80 | 3132  5.00 | 3142 4.20 | 3152 3.40
260k-390k           3113  7.05 | 3123  6.80 | 3133  5.90 | 3143 5.00 | 3153 4.10
390k-550k           3114  7.95 | 3124  7.70 | 3134  6.70 | 3144 5.70 | 3154 4.70
550k-770k           3115  9.05 | 3125  8.75 | 3135  7.70 | 3145 6.60 | 3155 5.45
770k-970k           3116 10.40 | 3126 10.05 | 3136  8.90 | 3146 7.70 | 3156 6.50
970k-inf.           311A 11.90 | 312A 11.60 | 313A 10.30 | 314A 8.95 | 315A 7.60
-----------------------------------------------------------------------------------
DELIMITER

  @@definicija3 = <<DELIMITER
Dodatno osiguranje troškova za najam drugog računala
===================================================================================
vrsta_sustava
...................................................................................
fransiza                2d           3d          5d          10d         20d       
-----------------------------------------------------------------------------------
jamstveno_razdoblje     1g
...................................................................................
profesionalna       3111  4.80 | 3121  4.65 | 3131  4.00 | 3141 3.30 | 3151 2.70
amaterska           3112  6.00 | 3122  5.80 | 3132  5.00 | 3142 4.20 | 3152 3.40
-----------------------------------------------------------------------------------
jamstveno_razdoblje     2g
...................................................................................
profesionalna       3111  5.80 | 3121  8.65 | 3131  6.09 | 3141 1.30 | 3151 3.70
amaterska           3112  5.00 | 3122  8.80 | 3132  4.00 | 3142 2.20 | 3152 4.40
-----------------------------------------------------------------------------------
DELIMITER

  test "Definicija sa praznim redovima" do
    definicija4 =   File.open("#{Rails.root}/test/unit/definicija4.def") do |file| 
        file.read  
    end
    assert TableN.definition_ok?( definicija4 )
    t = TableN.new definicija4
  end

  def test_init_table
    assert TableN.definition_ok?( @@definicija )
    assert TableN.definition_ok?( @@definicija2 )
    
    t = TableN.new @@definicija
    
    assert_equal [:vrijednost_sustava, :fransiza, :jamstveno_razdoblje], t.varijable

    assert_equal 0.0077, t.evaluate(:vrijednost_sustava => 400000, :fransiza => "3d", :jamstveno_razdoblje => "1g")[:stopa]
    assert_equal "3124", t.evaluate(:vrijednost_sustava => 400000, :fransiza => "3d", :jamstveno_razdoblje => "1g")[:oznaka]
    assert_equal "Dodatno osiguranje troškova za najam drugog računala", t.evaluate(:vrijednost_sustava => 400000, :fransiza => "3d", :jamstveno_razdoblje => "1g")[:opis]
  end
  
  def test_dimenzije
    table = TableN.new @@definicija
    assert_equal 3, table.varijable.size
  end
  
  def test_dimenzije_2
    table = TableN.new @@definicija2
    assert_equal 2, table.varijable.size
  end
  
  def test_tip_i_original
    t = TableN.new @@definicija
    result = t.evaluate(:vrijednost_sustava => 400000, :fransiza => "3d", :jamstveno_razdoblje => "1g")
    assert_equal 0.0077, result[:stopa]
    assert_equal "7.70", result[:stopa_original]
    assert_equal :promil, result[:stopa_tip]
  end

  test "Testiraj sa simbolima" do
    t = TableN.new @@definicija
    result = t.evaluate(:vrijednost_sustava => 400000, :fransiza => :"3d", :jamstveno_razdoblje => :"1g")
    assert_equal 0.0077, result[:stopa]
    assert_equal "7.70", result[:stopa_original]
    assert_equal :promil, result[:stopa_tip]
  end
  
  test "Kada vrijednost jedne dimenzije nije range" do
    t = TableN.new @@definicija3
    result = t.evaluate(:vrsta_sustava => :profesionalna,  :fransiza => "5d" , :jamstveno_razdoblje => "2g")
    assert_equal 0.00609, result[:stopa]
    assert_equal "6.09", result[:stopa_original]
    assert_equal :promil, result[:stopa_tip]
  end

  test "osnovica" do 
    t = TableN.new @@definicija
    result = t.evaluate(:vrijednost_sustava => 400000, :fransiza => "3d", :jamstveno_razdoblje => "1g")
    assert_equal 7.70, result[:osnovica]
  end

end
