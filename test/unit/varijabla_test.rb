require "test_helper"

class VarijablaTest < ActiveSupport::TestCase
  def test_varijabla_parsiraj_vrijednost_1000
    varijabla = Varijabla.new("var")
    assert_equal 100000...200000, varijabla.parsiraj_vrijednost("100k-200k")
  end
  
  def test_varijabla_parsiraj_vrijednost_1
    varijabla = Varijabla.new("var")
    assert_equal 100...200, varijabla.parsiraj_vrijednost("100-200")
  end
  
  def test_varijabla_parsiraj_vrijednost_promil
    varijabla = Varijabla.new("var")
    assert_equal 0.0083, varijabla.parsiraj_vrijednost("8.3")
  end
  
  def test_varijabla_parsiraj_vrijednost_promil_zarez
    varijabla = Varijabla.new("var")
    assert_equal 0.0083, varijabla.parsiraj_vrijednost("8,3")
  end
  
  def test_varijabla_parsiraj_vrijednost_str
    varijabla = Varijabla.new("var")
    assert_equal "mile", varijabla.parsiraj_vrijednost("mile")
  end
  
  def test_varijabla_parsiraj_vrijednost_posto
     varijabla = Varijabla.new("var")
     assert_equal 0.083, varijabla.parsiraj_vrijednost("8.3%")
  end
   
  def test_varijabla_parsiraj_range
    varijabla = Varijabla.new("var")
    assert_equal 100...200, varijabla.parsiraj_vrijednost("100-200")
  end
     
  def test_varijabla_parsiraj_range_inf
    varijabla = Varijabla.new("var")
    assert_equal 5...79228162514264337593543950336, varijabla.parsiraj_vrijednost("5-inf.")
  end

  def test_varijabla_parsiraj_range_right_open_inf
    varijabla = Varijabla.new("var")
    assert_equal 5..79228162514264337593543950336, varijabla.parsiraj_vrijednost("5..inf.")
  end

  def test_varijabla_parsiraj_range_right_open
    varijabla = Varijabla.new("var")
    assert_equal 5..10, varijabla.parsiraj_vrijednost("5..10")
  end
  
  def test_varijabla_bool
    varijabla = Varijabla.new("var")
    assert_equal true, varijabla.parsiraj_vrijednost("true")
    assert_equal false, varijabla.parsiraj_vrijednost("false")
  end
  
  def test_varijabla_str_num
    varijabla = Varijabla.new("var")
    assert_equal 1111, varijabla.parsiraj_vrijednost("1111")
  end
  
  def test_varijabla_str
    varijabla = Varijabla.new("var$")
    assert_equal :var, varijabla.naziv
    assert_equal "1111", varijabla.parsiraj_vrijednost("1111")
  end
  
  def test_varijabla_str
    varijabla = Varijabla.new("var")
    assert_equal :var, varijabla.naziv
    assert_equal "1g", varijabla.parsiraj_vrijednost("1g")
  end
  
  def test_varijabla_nil
    varijabla = Varijabla.new("var")
    assert_equal nil, varijabla.parsiraj_vrijednost("-")
    varijabla = Varijabla.new("var$")
    assert_equal nil, varijabla.parsiraj_vrijednost("-")
  end
  
  def test_eql
    v1 = Varijabla.new("var")
    v2 = Varijabla.new("var")
    assert(v1 == v2)
    
    v3 = Varijabla.new("var=1")
    v4 = Varijabla.new("var1=1")
    assert(v3 != v4)
  end

  test "tip broja" do
    v1 = Varijabla.new("var")
    assert_equal :promil, v1.tip("7.2") 
    assert_equal :posto, v1.tip("70%")
  end

  test "veza na funkciju" do
    v1 = Varijabla.new("var")
    assert_equal :posto, v1.tip("F")
    assert_equal "F", v1.parsiraj_vrijednost("F")
  end
  

end
