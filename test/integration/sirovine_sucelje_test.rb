#encoding: utf-8
require 'test_helper' 

class SirovineSuceljeTest < ActionController::IntegrationTest
  include Webrat::Matchers

  def setup
    visit "/police"
    click_link 'Nova polica'
    click_link 'Osiguranje sirovina'
    click_link 'Osigurnje sirovina i poluproizvoda za vrijeme trajanja tehnološkog ili termičkog procesa'
    @polica = Polica.new
  end

  test 'sirovine preko sucelja' do
    @polica.dodaj_stavke(:sirovine, "I", :osigurani_iznos => 1000000, :vrsta => :metalna_industrija, :vrijeme_kvarenja => :do_4_sata, :odbitna_fransiza => :fransiza_10  )

    click_button 'Dodaj'
    fill_in 'stavka_osigurani_iznos', :with => 1000000
    fill_in 'stavka_vrsta', :with => :metalna_industrija
    fill_in 'stavka_vrijeme_kvarenja', :with => :do_4_sata
    fill_in 'stavka_odbitna_fransiza', :with => :fransiza_10
  end


  def teardown
    assert_selector_content  "span#stavka_iznos_premije", to_c(@polica.premija)
  end

  def assert_selector_content (selector, content)
    sleep(0.2)
    matcher = have_selector selector
    assert matcher.matches?(response_body), "Ne postoji #{selector}"
    matcher = have_selector selector, :content => content 
    assert matcher.matches?(response_body), "Nadjen #{selector}, ali sadrzaj nije #{content}"
  end
  
end



