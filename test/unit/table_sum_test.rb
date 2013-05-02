require "test_helper"


class TableSumTest < ActiveSupport::TestCase

        @@definicija1 = <<DELIMITER
t1
====
o         s       oznaka
----
000k-170k   9.90    1111
170k-260k   7.20    1112
260k-390k   6.60    1113
----
DELIMITER

        @@definicija2 = <<DELIMITER
t2
===
o         s       oznaka
---
000k-170k   8.40    111A
170k-260k   7.50    111C
260k-390k   6.80    111B
---
DELIMITER

 def test_table_combo
   t1 = Table.new @@definicija1
   assert_equal BigDecimal.new(0.0099, 4), t1.evaluate(:o => 150000)[:s]
   t2 = Table.new @@definicija2
   t3 = t1 + t2
   assert_equal BigDecimal.new(0.0099, 4), t3.evaluate(:o => 150000)[0][:s]
   assert_equal BigDecimal.new(0.0084, 4), t3.evaluate(:o => 150000)[1][:s]
   t4 = t2 + t1                   
   assert_equal "111C", t4.evaluate(:o => 190000)[0][:oznaka]
   assert_equal "1112", t4.evaluate(:o => 190000)[1][:oznaka]
 end
end
