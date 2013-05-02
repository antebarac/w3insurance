require 'test_helper'


class SchemaNodeTest < ActiveSupport::TestCase

  def setup
    @parent = SchemaNode.new(:parent, {})
  end

  test "Vrijednost nije moguca" do
    atribut = SchemaNode.new(:alkohol, { :pivo => [], :vino => []}, @parent)
    assert_equal :enum, atribut.type
    assert atribut.not_possible?(:alkohol => :kavica)
    assert_equal false, atribut.not_possible?(:alkohol => :pivo)
  end
  
  test "Vrijednost je moguca ali je zadana kao string" do
    atribut = SchemaNode.new(:alkohol, { "pivo" => [], "vino" => [] })
    assert_equal false, atribut.not_possible?(:alkohol => 'pivo')
  end

  test "Obavezno polje" do
    atribut = SchemaNode.new(:"alkohol*", { "pivo" => [], "vino" => [] })
    assert atribut.required_and_not_in?( :milence => :kavica)
  end
  
  test "Obavezno polje sa uvjetom" do
    alkohol = SchemaNode.new(:"alkohol*", { :pivo => { :"pereci*" => [] }, :rakija => [] }, @parent)
    pereci = alkohol.children[0].children[0]
    assert_equal(:pereci, pereci.name)
    assert pereci.visible?(:alkohol => :pivo)
    assert pereci.required_and_not_in?( :alkohol => :pivo )
    assert_equal false, pereci.required_and_not_in?( :alkohol => :pivo, :pereci => :svjezi )
    assert_equal false, pereci.required_and_not_in?( :alkohol => :rakija )
  end
  
  test "Jednakost dva atributa" do
    assert  SchemaNode.new(:"alkohol*", { :pivo => { :"pereci*" => [] }, :rakija => [] }, @parent) == SchemaNode.new(:"alkohol", [])
    assert  SchemaNode.new(:"alkohol*", { :pivo => { :"pereci*" => [] }, :rakija => [] }, @parent) != SchemaNode.new(:"1alkohol*", { :pivo => { :"pereci*" => [] }, :rakija => [] }, @parent)
  end

  test "Regexp atribut" do
    atribut = SchemaNode.new(:milence, "decimal")
    assert atribut.valid_format?(:milence => "123.45")
    assert !atribut.valid_format?(:milence => "12ar")
    assert atribut.valid_format?(:milence => "2282828326743874678236487" )
    assert atribut.valid_format?(:milence => "2282828326743874678236487.462" )
    assert !atribut.valid_format?(:milence => "2282828326743874678236487.462.9" )
  end

  test "Cijeli broj" do
    atribut = SchemaNode.new(:milence, "integer")
    assert atribut.valid_format?(:milence => "123")
    assert_equal 123,  atribut.value(:milence => "123")
    assert !atribut.valid_format?(:milence => "12ar")
    assert_equal '12ar',  atribut.value(:milence => "12ar")
    assert atribut.valid_format?(:milence => "2282828326743874678236487" )
    assert !atribut.valid_format?(:milence => "2282828326743874678236487.462" )
    assert !atribut.valid_format?(:milence => "2282828326743874678236487.462.9" )
    assert !atribut.valid_format?(:milence => "123.7")
    assert !atribut.valid_format?(:milence => 123.7)
    assert_equal 123.7, atribut.value(:milence => 123.7)
  end

  test "Currency" do
    atribut = SchemaNode.new(:iznos, :money)
    assert atribut.valid_format?(:iznos => "123,444")
    assert_equal 123.44,  atribut.value(:iznos => "123,444") 
    assert atribut.valid_format?(:iznos => "123.125,44")
    assert_equal 123125.44,  atribut.value(:iznos => "123.125,44") 
    assert atribut.valid_format?(:iznos => BigDecimal.new("20,00"))
    assert_equal 20,  atribut.value(:iznos => BigDecimal.new("20,00"))
    assert atribut.valid_format?(:iznos => BigDecimal.new("20.00"))
    assert_equal 20,  atribut.value(:iznos => BigDecimal.new("20.00"))
  end


  test "Nil objekt sa formatom" do
    atribut = SchemaNode.new(:broj, :integer, @parent)
    assert atribut.valid_format?(:milence => "123")
  end

  test "Nil opcije" do
    atribut = SchemaNode.new(:broj, nil, @parent)
    assert atribut.valid_format?(:broj => "123")
  end
   
  test "Unsupported format" do
    assert_raise(ArgumentError) do 
      atribut = SchemaNode.new(:broj, :nomber, @parent)
      atribut.valid_format?(:broj => "123")
    end
  end
  
  test "Symbol with whitespace" do
    atribut = SchemaNode.new(:simbol, { :format => [] }, @parent)
    assert atribut.valid_format?(:simbol => "Ole ole ole ole")
  end

  test "Default atribut" do
    atribut = SchemaNode.new(:"procesno_racunalo*", [:nije_procesno, :ugradjeno, :procesno], @parent)
    assert_equal(:nije_procesno, atribut.value({}))
    assert_equal false, atribut.required_and_not_in?( :alkohol => :rakija )
  end

  test "Vidljivost atributa" do
      atribut = SchemaNode.new(:broj, :integer, @parent)
      assert atribut.visible?
      alkohol = SchemaNode.new(:"alkohol", {:rakija => [], :pivo => [:"pereci*"]}, @parent)
      pereci = alkohol.children[1].children[0]
      assert_equal(:pereci, pereci.name)
      assert !pereci.visible?
      assert pereci.visible?(:alkohol => :pivo )
  end

  test "Required ponovljeni atribut" do
    node = SchemaNode.new(:"alkohol*", { :pivo => { :"pereci*" => [] }, :rakija => { :"pereci*" => [] }, :viski => [] } , @parent) 
    pereci = node.children[0].children[0]
    assert_equal(:pereci, pereci.name)
    assert(pereci.required_and_not_in?(:alkohol => :pivo))
    assert(pereci.required_and_not_in?(:alkohol => :rakija))
    assert_equal(false, pereci.required_and_not_in?(:alkohol => :viski))
    pereci = node.children[1].children[0]
    assert_equal(:pereci, pereci.name)
    assert(pereci.required_and_not_in?(:alkohol => :pivo))
    assert(pereci.required_and_not_in?(:alkohol => :rakija))
    assert_equal(false, pereci.required_and_not_in?(:alkohol => :viski))
  end

  test "Optional polje" do
    atribut = SchemaNode.new(:"alkohol?", :decimal)
    assert_equal(:alkohol, atribut.name)
    assert_equal(:text, atribut.type)
    assert atribut.optional?
  end

  test "Optional polje fiksna vrijednost" do
    atribut = SchemaNode.new(:"alkohol?", "=6.3%")
    assert_equal(:alkohol, atribut.name)
    assert_equal(:fixed_percentage, atribut.type)
    assert atribut.optional?
    assert_equal("6.3", atribut.default_value)
  end
 
  test "Validacija optional polja - range" do
    atribut = SchemaNode.new(:"range?", "=6.3%-20%")
    assert !atribut.valid_format?(:range => "da", :range_iznos => "5")
    assert !atribut.valid_format?(:range => "da", :range_iznos => "20.01")
    assert atribut.valid_format?(:range => "da", :range_iznos => "6.3")
    assert atribut.valid_format?(:range => "da", :range_iznos => "20")
    assert atribut.valid_format?(:range => "da", :range_iznos => 7)
    assert !atribut.valid_format?(:range => "da", :range_iznos => "6.34a9b")
  end
  
  test "Validacija optional polja - fixed" do
    atribut = SchemaNode.new(:"fixed?", "=6.3%")
    assert !atribut.valid_format?(:fixed => "da", :fixed_iznos => "5")
    assert !atribut.valid_format?(:fixed => "da", :fixed_iznos => "6.31")
    assert !atribut.valid_format?(:fixed => "da", :fixed_iznos => "6a.31")
    assert !atribut.valid_format?(:fixed => "da", :fixed_iznos => "20")
    assert atribut.valid_format?(:fixed => "da", :fixed_iznos => "6.3")
  end
  
  test "Validacija optional polja - otvoreni range lijevi" do
    atribut = SchemaNode.new(:"range?", "=do 20%")
    assert !atribut.valid_format?(:range => "da", :range_iznos => "0")
    assert !atribut.valid_format?(:range => "da", :range_iznos => "20.01")
    assert atribut.valid_format?(:range => "da", :range_iznos => "6.3")
    assert atribut.valid_format?(:range => "da", :range_iznos => "20")
    assert atribut.valid_format?(:range => "da", :range_iznos => 7)
    assert !atribut.valid_format?(:range => "da", :range_iznos => "6a.31")
  end


  test "Ispis range-a kao stringa" do
    assert_equal("(6,3%)", SchemaNode.new(:range?, "=6.3%").range_as_string)
    assert_equal("(7,3%)", SchemaNode.new(:range?, "= 7.3%").range_as_string)
    assert_equal("[6,3% - 20%]", SchemaNode.new(:range?, "=6.3%-20%").range_as_string)
    assert_equal("(do 15%)", SchemaNode.new(:range?, "=do 15%").range_as_string)
    assert_equal("(do 18%)", SchemaNode.new(:range?, "= do 18%").range_as_string)
  end

  test "Test include/exclude list - exclusive" do
    node = SchemaNode.new("node[mile,pero]", "")
    assert_equal(true, node.can_be_child_of?("mile"))
    assert_equal(true, node.can_be_child_of?("pero"))
    assert_equal(false, node.can_be_child_of?("djuka"))
  end
  
  test "Test include/exclude list - exclusive optional" do
    node = SchemaNode.new("node[mile,pero]?", "")
    assert_equal(true, node.can_be_child_of?("mile"))
    assert_equal(true, node.can_be_child_of?("pero"))
    assert_equal(false, node.can_be_child_of?("djuka"))
  end

  test "Test include/exclude list - exclusive essential" do
    node = SchemaNode.new("node[mile,pero]*", "")
    assert_equal(true, node.can_be_child_of?("mile"))
    assert_equal(true, node.can_be_child_of?("pero"))
    assert_equal(false, node.can_be_child_of?("djuka"))
  end

  test "Test include/exclude list - vanilla" do
    node = SchemaNode.new("node", "")
    assert_equal(true, node.can_be_child_of?("bilo_sta"))
  end

  test "Test include/exclude list - forbidden" do
    node = SchemaNode.new("node[!mile,!pero]", "")
    assert_equal(false, node.can_be_child_of?("mile"))
    assert_equal(false, node.can_be_child_of?("pero"))
    assert_equal(true, node.can_be_child_of?("djuka"))
  end

  test "Test include/exclude list - forbidden optional" do
    node = SchemaNode.new("node[!mile,!pero]?", "")
    assert_equal(false, node.can_be_child_of?("mile"))
    assert_equal(false, node.can_be_child_of?("pero"))
    assert_equal(true, node.can_be_child_of?("djuka"))
  end
  
  test "Test include/exclude list - forbidden essential" do
    node = SchemaNode.new("node[!mile,!pero]*", "")
    assert_equal(false, node.can_be_child_of?("mile"))
    assert_equal(false, node.can_be_child_of?("pero"))
    assert_equal(true, node.can_be_child_of?("djuka"))
  end

  test "Test include/exclude list - invalid format" do
    assert_raise RuntimeError do
      node = SchemaNode.new("node[!mile,pero]", "")
    end
  end
 
end
