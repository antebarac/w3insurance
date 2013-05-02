require 'sklapanje/cjenik'

class Racunala <  Cjenik
    def svota_osiguranja
      case @vrsta.to_sym
        when :I then return svota_osiguranja_I
        when :II1PG then return postavke[:trosak_ponovnog_dnevnog_unosa]
        when :II2PG then return postavke[:trosak_ponovnog_unosa_i_instaliranja]
        when :III then return postavke[:trosak_za_najam]
        when :POTRES then return postavke[:vrijednost_sustava]
        when :NEZGODA then return postavke[:iznos_nezgoda]
      end
    end
  
    def pravila
      case @vrsta.to_sym
        when :I
          postavke[:udio_pojedinacnog_u_centru] = postavke[:vrijednost_pojedinacnih_uredjaja].to_f / postavke[:vrijednost_sustava].to_f if postavke[:pojedinacno_racunalo] == :da
          postavke[:poseban_dogovor] = :osobna_racunala_deset_ili_vise if postavke[:poseban_dogovor] == :osobna_racunala &&  postavke[:broj_racunala] >= 10 
      end
    end

    def svota_osiguranja_I
      return postavke[:cijena_licenci] if postavke[:poseban_dogovor] == :licence_programa
      return postavke[:vrijednost_pojedinacnih_uredjaja] if postavke[:pojedinacno_racunalo] == :da 
      return postavke[:vrijednost_sustava]
    end
end
