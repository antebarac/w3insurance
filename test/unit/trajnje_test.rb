require 'test_helper'

class TrajanjeTest < ActiveSupport::TestCase

  test 'Jednogodisnje' do
    trajanje = Trajanje.new(:jednogodisnje, :pocetak => '15.09.2009')
    assert_equal(Date.parse('15.09.2009'), trajanje.pocetak, 'Pocetak')
    assert_equal(Date.parse('15.09.2010'), trajanje.kraj, 'Kraj')
  end

  test 'Jednogodisnje salji datum' do
    trajanje = Trajanje.new(:jednogodisnje, :pocetak => Date.parse('15.09.2009'))
    assert_equal(Date.parse('15.09.2009'), trajanje.pocetak, 'Pocetak')
    assert_equal(Date.parse('15.09.2010'), trajanje.kraj, 'Kraj')
  end

  test 'Jednogodisnje 2' do
    trajanje = Trajanje.new(:jednogodisnje, :pocetak => '20.09.2009')
    assert_equal(Date.parse('20.09.2009'), trajanje.pocetak, 'Pocetak')
    assert_equal(Date.parse('20.09.2010'), trajanje.kraj, 'Kraj')
    assert_equal(1, trajanje.godine)
  end

  test 'Visegodisnje' do
    assert_raise(ArgumentError) do
      trajanje = Trajanje.new(:visegodisnje, :pocetak => '20.09.2009')
    end
  end

  test 'Visegodisnje od dvije godine' do
   trajanje = Trajanje.new(:visegodisnje, :pocetak => '20.09.2009', :broj_godina => 2)
   assert_equal(Date.parse('20.09.2009'), trajanje.pocetak, 'Pocetak')
   assert_equal(Date.parse('20.09.2011'), trajanje.kraj, 'Kraj')
   assert_equal(2, trajanje.godine)
  end


  test 'Dugorocno osiguranje' do
   trajanje = Trajanje.new(:dugorocno, :pocetak => '20.09.2009')
   assert_equal(Date.parse('20.09.2009'), trajanje.pocetak, 'Pocetak')
   assert_equal(:inf, trajanje.kraj, 'Kraj')
   assert_equal(:inf, trajanje.godine)
  end
  
  test 'Kratkorocno' do
   trajanje = Trajanje.new(:kratkorocno, :pocetak => '20.09.2009', :kraj => '20.10.2009')
   assert_equal(Date.parse('20.09.2009'), trajanje.pocetak, 'Pocetak')
   assert_equal(Date.parse('20.10.2009'), trajanje.kraj, 'Kraj')
   assert_equal(0.0822, trajanje.godine)
  end
  
  test 'Kratkorocno bez kraja' do
    assert_raise(ArgumentError) do
      trajanje = Trajanje.new(:kratkorocno, :pocetak => '20.09.2009')
    end
  end

  test 'Jednogodisnje bez pocetka' do
    assert_raise(ArgumentError) do
      trajanje = Trajanje.new(:jednogodisnje, :kraj => '20.09.2009')
    end
  end

end
