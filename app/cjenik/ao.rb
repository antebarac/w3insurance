require 'sklapanje/cjenik'

class Ao < Cjenik
  def pravila
    if @vrsta == "IX" && postavke[:dodatni_dani_trajanja] == nil?
      postavke[:dodatni_dani_trajanja] = 0.0
    end
    postavke[:zona_rizika] = postavke[:registracija][0, 2]
  end
end
