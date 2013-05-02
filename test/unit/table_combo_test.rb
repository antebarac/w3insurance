require 'test_helper'


class TableComboTest < ActiveSupport::TestCase
  
         @@definicija1 = <<DELIMITER
mile1(opis=Osiguranje racunalnog centra)
===========================================
osigurana_svota   stopa   oznaka
-------------------------------------------
000k-170k         -       1111   
170k-260k         7.20    1112   
260k-390k         6.60    1113
-------------------------------------------
DELIMITER
                                 
         @@definicija2 = <<DELIMITER
mile1(opis=Osiguranje racunalnog centra)
===========================================
osigurana_svota   stopa   oznaka
-------------------------------------------
000k-170k         8.40    111A 
170k-260k         7.50    -    
260k-390k         6.80    111B 
-------------------------------------------
DELIMITER

  def test_table_combo
    t1 = Table.new @@definicija1
    t2 = Table.new @@definicija2
    t3 = t2 | t1
    assert_equal 0.0072, t3.evaluate(:osigurana_svota => 180000)[:stopa]
    assert_equal 0.0084, t3.evaluate(:osigurana_svota => 150000)[:stopa]
    t4 = t1 | t2
    assert_equal "111B", t4.evaluate(:osigurana_svota => 270000)[:oznaka]
    assert_equal "1112", t4.evaluate(:osigurana_svota => 190000)[:oznaka]
  end
end
