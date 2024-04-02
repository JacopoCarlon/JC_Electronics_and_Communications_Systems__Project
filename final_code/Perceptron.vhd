
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;


--  use IEEE.fixed_float_types.all; -- per truncate ..?
--  use IEEE.fixed_pkg.all;

-- ogni cosa sarà no std_logic_vector
-- osservazioen Signed Fixed Point usando il complemento a 2
-- se ad esempio io avessi il numero "+0.5" da scrivere su 2 bit interi e 4 decimali, avrei: 
-- "+0.5" = "00.1000" [2, 4], noto che il numero "001000" = "8", 
--      quindi è come se io avessi moltiplicato per 16
--  il numero "-8" si scrive "1101111 + 1"="1110000"
-- "-0.5" = "11.1000"
-- continuando, con [2, 4] : "+1" = "01.0000"; "-1" = "11.0000"
-- con [1, 4]: "+1"= "1.0000" (?); "-1"="1.0000" ... non funziona !!!
-- per rappresentare +1 io rappresenterei 16, ma su 5 bit con segno posso fare [-16, +15] !!!
-- quindi per avere un input tra [-1, +1] ho bisogno di tenere sempre 2 bit per le unità!

-- INIZIO ESERCIZIO 
-- input x è su 8 bit tra -1 e 1, quindi lo considero: [2, 6] e lo scrivo come moltiplicato per 2^6
-- quindi scriverò : "0.5" = "2^5" = [0010 0000]    ; "-0.5" = [1110 0000];
-- poi              "+1.0" = "2^6" = [0100 0000]    ; "-1.0" = [1100 0000];
-- la cosa da ricordare è che per un numero da -1,1 su 8 bit, mi servono 2 bit per intero e 6 per fract
-- per un numero -1,1 su 9 bit, mi servono 2 bit intero e 7 fract, 
-- quindi quando dovrò sommare 0.5 a 8 bit e 0.5 a 9 bit, 
-- dovrò prima espandere quello a 8 aggiungendo uno 0 a destra

-- quando poi moltiplicherò 1.0(8) con 1.0(9) avrò un numero su 9+8 = 17 bit, 
-- di cui i primi 4 saranno la parte intera e i restanti 13 la parte decimale !

--  --  -- nel farlo, tuttavia, mi aspetto che i 3 bit più significativi rimarranno uguali 
--  --  -- e quindi li taglierò tosto e lo ridurrò ad avere 2 bit di parte intera e 13 di parte decimale
-- quando infine sommo tra loro 11 numeri, tutti con parte intera di 2 bit, allora 
-- il numero crescerà in modulo di al massimo 11 ("undici" = "1011.0") volte, 
-- e la sua parte fract non diverrà più "fine"
-- quindi avrò in principio un numero con 8 bit di parte intera e 13 di parte decimale. 
-- so tuttavia che il numero sarà sicuramente nell'intervallo [-11, +11] e
-- so che i numeri "+11" = "0000_1011.0" e "-11" = "1111_0101.0", quindi lo posso rappresentare su 5 bit interi anzchè su 8 interi
-- ... arrivato qua la somma avrà 8 interi e 13 decimali, 

-- la funzione di scelta poi avrà solo il compito di verificare che il numero sia in modulo maggiore di 2 o non

-- i fili per le somme-prodotti avranno in input valori su 9 bit, di cui 2 interi e 7 o 6 fract,  = 8 o 9 bit
-- il risultati dei prodotti saranno su 4 interi e 13 fract,  = 17 bit
-- che verranno ridotti a 2 interi e 13 fract = 15 bit

-- e poi la somma sarà su 6 interi e 13 fract= 19 bit
-- la somma va da -11 a +11, quindi servono 01011.000 ovvero 5 bit interi
-- quindi la somma verrà subito ridotta a 5 interi e 13 fract = 18 bit


entity Perceptron is
    port(
        clk          : in std_logic;
        resetn       : in std_logic; -- active low

        -- input xi a 8 bit, in virgola fissa, tra -1 e 1
        -- quindi std_logic_vector a 8 bit
        -- nota : 
        x0:     in  std_logic_vector(8 - 1 downto 0);
        x1:     in  std_logic_vector(8 - 1 downto 0);
        x2:     in  std_logic_vector(8 - 1 downto 0);
        x3:     in  std_logic_vector(8 - 1 downto 0);
        x4:     in  std_logic_vector(8 - 1 downto 0);
        x5:     in  std_logic_vector(8 - 1 downto 0);
        x6:     in  std_logic_vector(8 - 1 downto 0);
        x7:     in  std_logic_vector(8 - 1 downto 0);
        x8:     in  std_logic_vector(8 - 1 downto 0);
        x9:     in  std_logic_vector(8 - 1 downto 0);

        -- input weights wi a 9 bit, in virgola fissa, tra -1 e 1
        w0:     in  std_logic_vector(9 - 1 downto 0);
        w1:     in  std_logic_vector(9 - 1 downto 0);
        w2:     in  std_logic_vector(9 - 1 downto 0);
        w3:     in  std_logic_vector(9 - 1 downto 0);
        w4:     in  std_logic_vector(9 - 1 downto 0);
        w5:     in  std_logic_vector(9 - 1 downto 0);
        w6:     in  std_logic_vector(9 - 1 downto 0);
        w7:     in  std_logic_vector(9 - 1 downto 0);
        w8:     in  std_logic_vector(9 - 1 downto 0);
        w9:     in  std_logic_vector(9 - 1 downto 0);

        -- input bias a 9 bit, in virgola fissa, tra -1 e 1
        b:      in  std_logic_vector(9 - 1 downto 0);

        -- output
        y :     out std_logic_vector(16 - 1 downto 0)
        --  ;
    );
end Perceptron;



--  /**/ /**/ /**/

architecture J_perceptron of Perceptron is

    -- begin signals
    -- "registri" per gli input
        signal reg_x0:    std_logic_vector(8 - 1 downto 0);
        signal reg_x1:    std_logic_vector(8 - 1 downto 0);
        signal reg_x2:    std_logic_vector(8 - 1 downto 0);
        signal reg_x3:    std_logic_vector(8 - 1 downto 0);
        signal reg_x4:    std_logic_vector(8 - 1 downto 0);
        signal reg_x5:    std_logic_vector(8 - 1 downto 0);
        signal reg_x6:    std_logic_vector(8 - 1 downto 0);
        signal reg_x7:    std_logic_vector(8 - 1 downto 0);
        signal reg_x8:    std_logic_vector(8 - 1 downto 0);
        signal reg_x9:    std_logic_vector(8 - 1 downto 0);
        signal reg_w0:    std_logic_vector(9 - 1 downto 0);
        signal reg_w1:    std_logic_vector(9 - 1 downto 0);
        signal reg_w2:    std_logic_vector(9 - 1 downto 0);
        signal reg_w3:    std_logic_vector(9 - 1 downto 0);
        signal reg_w4:    std_logic_vector(9 - 1 downto 0);
        signal reg_w5:    std_logic_vector(9 - 1 downto 0);
        signal reg_w6:    std_logic_vector(9 - 1 downto 0);
        signal reg_w7:    std_logic_vector(9 - 1 downto 0);
        signal reg_w8:    std_logic_vector(9 - 1 downto 0);
        signal reg_w9:    std_logic_vector(9 - 1 downto 0);
        signal reg_bias:  std_logic_vector(9 - 1 downto 0);
    -- "registro" per l' output
        -- sì reg uscita : 
        signal reg_y:     std_logic_vector(16 - 1 downto 0);

    -- i fili per le somme-prodotti avranno in input valori su 9 bit, di cui 2 interi e 7 o 6 fract,  = 8 o 9 bit

    -- il risultati dei prodotti saranno su 4 interi e 13 fract,  = 17 bit, 
    -- di cui però posso ignorare i 2 bit più significativi e che quindi registro su 15 bit
    -- per fare la somma lo espando già a 18 bit
        signal esp_bias:  std_logic_vector(18 - 1 downto 0);

        signal prod_0:    std_logic_vector(18 - 1 downto 0);
        signal prod_1:    std_logic_vector(18 - 1 downto 0);
        signal prod_2:    std_logic_vector(18 - 1 downto 0);
        signal prod_3:    std_logic_vector(18 - 1 downto 0);
        signal prod_4:    std_logic_vector(18 - 1 downto 0);
        signal prod_5:    std_logic_vector(18 - 1 downto 0);
        signal prod_6:    std_logic_vector(18 - 1 downto 0);
        signal prod_7:    std_logic_vector(18 - 1 downto 0);
        signal prod_8:    std_logic_vector(18 - 1 downto 0);
        signal prod_9:    std_logic_vector(18 - 1 downto 0);

        signal sum_0to1     :   std_logic_vector(18 - 1 downto 0);  -- group 2
        signal sum_2to3     :   std_logic_vector(18 - 1 downto 0);  -- group 2
        signal sum_4to5     :   std_logic_vector(18 - 1 downto 0);  -- group 2
        signal sum_6to7     :   std_logic_vector(18 - 1 downto 0);  -- group 2
        signal sum_8to9     :   std_logic_vector(18 - 1 downto 0);  -- group 2        
        signal sum_0to3     :   std_logic_vector(18 - 1 downto 0);  -- group 4
        signal sum_4to7     :   std_logic_vector(18 - 1 downto 0);  -- group 4
        signal sum_8to9_bs  :   std_logic_vector(18 - 1 downto 0);  -- group 3
        signal sum_0to7     :   std_logic_vector(18 - 1 downto 0);  -- group 8

        
        -- espansione di s_x0 : (s_x0(8-1) & s_x0(8-1) & s_x0(8-1) & s_x0(8-1) & s_x0(8-1) & s_x0(8-1) & s_x0(8-1) & s_x0(8-1) & s_x0(8-1) & s_x0 )
        -- espansione di s_w0 : (s_w0(9-1) & s_w0(9-1) & s_w0(9-1) & s_w0(9-1) & s_w0(9-1) & s_w0(9-1) & s_w0(9-1) & s_w0(9-1) & s_w0             )
        -- prod_0 <= (  )(15-1 down to 0)


        -- sum_product_result   -- da "-11" a "+11", con 13 bit frazionali e 5 interi
        signal sp_res:          std_logic_vector(18 - 1 downto 0);
        signal sp_plus_two:     std_logic_vector(18 - 1 downto 0);
        signal cut_sp_plus_two: std_logic_vector(16 - 1 downto 0);
        
        -- output del filtro -- da "-1" a "+1", con 13 bit frazionali e 3 interi
        signal value_to_out:    std_logic_vector(16 - 1 downto 0);
        signal af_out:          std_logic_vector(16 - 1 downto 0);

    -- end signals

    -- begin constants
        -- con 13 bit frazionali e 5 interi 
        -- constant DUE_POS_18bit : to_sfixed(1, 3, -15);
        --                                                            "0123456789ABCDEF01"2345678"
        constant DUE_POS_18bit : std_logic_vector(18 - 1 downto 0) := "000100000000000000";
        -- constant DUE_NEG_18bit : to_sfixed(-1, 3, -15);
        -- con 13 bit frazionali e 5 interi 
        --                                                            "0123456789ABCDEF01"2345678"
        constant DUE_NEG_18bit : std_logic_vector(18 - 1 downto 0) := "111100000000000000";
        --  UN_MEZ_18bit, dove 5 interi e 13 frazionali
        --                                                           "0123456789ABCDEF01"2345678"
        constant UN_MEZ_18bit : std_logic_vector(18 - 1 downto 0) := "000001000000000000";

        constant ZERO_16b     : std_logic_vector(16 - 1 downto 0)  := (others => '0') ;      --  0
        constant PUNO_16b     : std_logic_vector(16 - 1 downto 0)  := ("0010000000000000") ; -- +1
        --                                                             "0123456789ABCDEF"012345678"
    
    -- end constants


    -- architecture description [begin, end)
    -- architecture begin
    begin --J_perceptron
        --  y <= af_out;

        mainBlock: process  (   clk, 
                                resetn
                            )
        -- process begin
        begin
            -- handle @resetn==0
            if ( resetn = '0' ) then
                -- all inputs are consdered 0 (15 zeri)
                -- x        "0123456789ABCDE"F012345678"
                reg_x0      <= (others => '0') ; 
                reg_x1      <= (others => '0') ; 
                reg_x2      <= (others => '0') ; 
                reg_x3      <= (others => '0') ; 
                reg_x4      <= (others => '0') ; 
                reg_x5      <= (others => '0') ; 
                reg_x6      <= (others => '0') ; 
                reg_x7      <= (others => '0') ; 
                reg_x8      <= (others => '0') ; 
                reg_x9      <= (others => '0') ; 
                -- w        "0123456789ABCDE"F012345678"
                reg_w0      <= (others => '0') ; 
                reg_w1      <= (others => '0') ; 
                reg_w2      <= (others => '0') ; 
                reg_w3      <= (others => '0') ; 
                reg_w4      <= (others => '0') ; 
                reg_w5      <= (others => '0') ; 
                reg_w6      <= (others => '0') ; 
                reg_w7      <= (others => '0') ; 
                reg_w8      <= (others => '0') ; 
                reg_w9      <= (others => '0') ; 
                -- bias a 18 bit pronto per la somma finale
                reg_bias    <= (others => '0') ; 
                -- sì reg uscita : 
                reg_y       <= (others => '0') ; 
                
            elsif ( rising_edge(clk) ) then
                -- acquisico correttamente tutti gli input (8 o 9 bit) e li metto a 15 bit
                reg_x0      <=  ( x0 )      ;
                reg_x1      <=  ( x1 )      ;
                reg_x2      <=  ( x2 )      ;
                reg_x3      <=  ( x3 )      ;
                reg_x4      <=  ( x4 )      ;
                reg_x5      <=  ( x5 )      ;
                reg_x6      <=  ( x6 )      ;
                reg_x7      <=  ( x7 )      ;
                reg_x8      <=  ( x8 )      ;
                reg_x9      <=  ( x9 )      ;
                reg_w0      <=  ( w0 )      ; 
                reg_w1      <=  ( w1 )      ; 
                reg_w2      <=  ( w2 )      ; 
                reg_w3      <=  ( w3 )      ; 
                reg_w4      <=  ( w4 )      ; 
                reg_w5      <=  ( w5 )      ; 
                reg_w6      <=  ( w6 )      ; 
                reg_w7      <=  ( w7 )      ; 
                reg_w8      <=  ( w8 )      ; 
                reg_w9      <=  ( w9 )      ; 
                reg_bias    <=  ( b  )      ;
                -- sì reg uscita : 
                reg_y       <=  af_out      ; 
                
            end if;
        end process mainBlock;    

        -- sì reg uscita : 
        y <= reg_y ; 

      
        prod_0      <= std_logic_vector( to_signed ( ( to_integer(signed(reg_x0)) * to_integer(signed(reg_w0)) ) , 18 ) ) ;
        prod_1      <= std_logic_vector( to_signed ( ( to_integer(signed(reg_x1)) * to_integer(signed(reg_w1)) ) , 18 ) ) ;
        prod_2      <= std_logic_vector( to_signed ( ( to_integer(signed(reg_x2)) * to_integer(signed(reg_w2)) ) , 18 ) ) ;
        prod_3      <= std_logic_vector( to_signed ( ( to_integer(signed(reg_x3)) * to_integer(signed(reg_w3)) ) , 18 ) ) ;
        prod_4      <= std_logic_vector( to_signed ( ( to_integer(signed(reg_x4)) * to_integer(signed(reg_w4)) ) , 18 ) ) ;
        prod_5      <= std_logic_vector( to_signed ( ( to_integer(signed(reg_x5)) * to_integer(signed(reg_w5)) ) , 18 ) ) ;
        prod_6      <= std_logic_vector( to_signed ( ( to_integer(signed(reg_x6)) * to_integer(signed(reg_w6)) ) , 18 ) ) ;
        prod_7      <= std_logic_vector( to_signed ( ( to_integer(signed(reg_x7)) * to_integer(signed(reg_w7)) ) , 18 ) ) ;
        prod_8      <= std_logic_vector( to_signed ( ( to_integer(signed(reg_x8)) * to_integer(signed(reg_w8)) ) , 18 ) ) ;
        prod_9      <= std_logic_vector( to_signed ( ( to_integer(signed(reg_x9)) * to_integer(signed(reg_w9)) ) , 18 ) ) ;

        -- reg_bias è a 9 bit, lo devo espandere con segno a 18 bit
        esp_bias    <= ( reg_bias(9-1) & reg_bias(9-1) & reg_bias(9-1) & reg_bias(9-1) & reg_bias(9-1) & reg_bias(9-1) & reg_bias(9-1) & reg_bias(9-1) & reg_bias(9-1) & reg_bias );

        -- i vari !!! prod_i sono su 18 bit, di cui 5 di interi e 13 di fract !!!
                        
        -- dato che devo sommare i prodotti tra di loro, dove ogni fattore è in [-1,1] e sta su 2int+13fract = 15 bit
        -- so che il risultato starà in [-11,+11] che è 5int +13fract = 18 bit
        -- quindi prendo i 15 bit che sono sicuri, e li espando a 18 bit 
        -- e sommo senza problemi di overflow               


        -- somma ad albero binario bilanciato per evitare percorso pessimo di somma a cascata
        sum_0to1        <= ( prod_0 + prod_1 ) ;     -- group 2
        sum_2to3        <= ( prod_2 + prod_3 ) ;     -- group 2
        sum_4to5        <= ( prod_4 + prod_5 ) ;     -- group 2
        sum_6to7        <= ( prod_6 + prod_7 ) ;     -- group 2
        sum_8to9        <= ( prod_8 + prod_9 ) ;     -- group 2

        sum_0to3        <= ( sum_0to1 + sum_2to3 ) ; -- group 4
        sum_4to7        <= ( sum_4to5 + sum_6to7 ) ; -- group 4
        sum_8to9_bs     <= ( sum_8to9 + esp_bias ) ; -- group 3
        
        sum_0to7        <= ( sum_0to3 + sum_4to7 ) ; -- group 8
        
        --  sp_res <= ( prod_0 + prod_1 + prod_2 + prod_3 + prod_4 + prod_5 + prod_6 + prod_7 + prod_8 + prod_9 + esp_bias );
        sp_res  <= ( sum_0to7 + sum_8to9_bs ) ;

        -- !!! OUT_DECISOR !!!
        -- adesso !!! sp_res contiene un [-11,+11] che è 5int +13fract = 18 bit !!!
        -- la funzione di attivazione è : 
        -- _ if x > 2, 1
        -- _ if x <2, 0
        -- _ else : [ (x+2)/4 ]  ==  [ (x/2) + 1/2 ]
        -- per la retta obliqua, dato che accadrè quando x in [-2,2], 
        -- io prima lo incremento di 2, rendendolo positivo, tra [0, +4]
        -- e poi dovrei dividerlo per 4 (shidt a destra di 2)
        -- e infine espandere la parte intera per avere 3 interi e 13 fract, ma osservo : 
        -- !!! sp_plus_two è sicuramente positivo !!!
        -- sp_plus_two è del tipo 00XXX.fract_13, 
        -- lo shift lo renderebbe SS00X.XXfract_11
        -- se poi lo riduco da sopra a 16 bit, diventa 00X.XXfract_11
        -- che è già il valore di output !!!

        sp_plus_two <= sp_res + DUE_POS_18bit;
        cut_sp_plus_two <= ( sp_plus_two((18-1) downto 2 ) );

        -- no reg uscita : 
        --  y <=    PUNO_16b when ( signed(sp_res) > signed(DUE_POS_18bit) ) else 
        --          ZERO_16b when ( signed(sp_res) < signed(DUE_NEG_18bit) ) else
        --          cut_sp_plus_two ;

        -- sì reg uscita : 
        af_out <=   PUNO_16b when ( signed(sp_res) > signed(DUE_POS_18bit) ) else 
                    ZERO_16b when ( signed(sp_res) < signed(DUE_NEG_18bit) ) else
                    cut_sp_plus_two ;

    end J_perceptron;

-- end architecture J_perceptron


