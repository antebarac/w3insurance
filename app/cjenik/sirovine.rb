require 'sklapanje/cjenik'

class Sirovine <  Cjenik
    def svota_osiguranja
      return postavke[:osigurani_iznos]
    end
end
