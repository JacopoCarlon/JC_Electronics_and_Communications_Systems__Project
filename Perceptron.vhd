
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;


use IEEE.fixed_float_types.all; -- per truncate ..?
use IEEE.fixed_pkg.all;

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
-- la somma va da -11 a +11, quindi servono 01011.000 ovvero 5 bit interi   01011 _ 10101
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

    -- i fili per le somme-prodotti avranno in input valori su 9 bit, di cui 2 interi e 7 o 6 fract,  = 8 o 9 bit

    -- il risultati dei prodotti saranno su 4 interi e 13 fract,  = 17 bit, 
    -- di cui però posso ignorare i 2 bit più significativi e che quindi registro su 15 bit
    -- per fare la somma lo espando già a 18 bit
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
        signal esp_bias:  std_logic_vector(18 - 1 downto 0);

        -- espansione di s_x0 : (s_x0(8-1) & s_x0(8-1) & s_x0(8-1) & s_x0(8-1) & s_x0(8-1) & s_x0(8-1) & s_x0(8-1) & s_x0(8-1) & s_x0(8-1) & s_x0 )
        -- espansione di s_w0 : (s_w0(9-1) & s_w0(9-1) & s_w0(9-1) & s_w0(9-1) & s_w0(9-1) & s_w0(9-1) & s_w0(9-1) & s_w0(9-1) & s_w0             )
        -- prod_0 <= (  )(15-1 down to 0)


        -- sum_product_result   -- da "-11" a "+11", con 13 bit frazionali e 5 interi
        signal sp_res:          std_logic_vector(18 - 1 downto 0);
        signal sp_plus_two:     std_logic_vector(18 - 1 downto 0);
        
        -- output del filtro -- da "-1" a "+1", con 13 bit frazionali e 3 interi
        signal value_to_out:    std_logic_vector(16 - 1 downto 0);
        signal af_out:  std_logic_vector(16 - 1 downto 0);

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

    -- end constants


    -- architecture description [begin, end)
    -- architecture begin
    begin --J_perceptron
        y <= af_out;

        mainBlock: process ( clk, resetn )
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
                -- output 0 by default
                -- 16 bit, valori tra -1 e +1, quindi 3 bit interi e 13 bit frazionali
                -- signal af_out:  std_logic_vector(16 - 1 downto 0);
                af_out      <= (others => '0') ; 
                --        "0123456789ABCDEF"012"345678"

            elsif ( rising_edge(clk) ) then
                -- acquisico correttamente tutti gli input (8 o 9 bit) e li metto a 15 bit

                -- espansione di s_x0 : (s_x0(8-1) & s_x0(8-1) & s_x0(8-1) & s_x0(8-1) & s_x0(8-1) & s_x0(8-1) & s_x0(8-1) & s_x0(8-1) & s_x0(8-1) & s_x0 )
                -- espansione di s_w0 : (s_w0(9-1) & s_w0(9-1) & s_w0(9-1) & s_w0(9-1) & s_w0(9-1) & s_w0(9-1) & s_w0(9-1) & s_w0(9-1) & s_w0             )
                -- tutti gli input li espando con segno a 15 bit per il prodotto minimo corretto
                reg_x0      <=  ( x0 ) ;
                reg_x1      <=  ( x1 ) ;
                reg_x2      <=  ( x2 ) ;
                reg_x3      <=  ( x3 ) ;
                reg_x4      <=  ( x4 ) ;
                reg_x5      <=  ( x5 ) ;
                reg_x6      <=  ( x6 ) ;
                reg_x7      <=  ( x7 ) ;
                reg_x8      <=  ( x8 ) ;
                reg_x9      <=  ( x9 ) ;
                reg_w0      <=  ( w0 ) ; 
                reg_w1      <=  ( w1 ) ; 
                reg_w2      <=  ( w2 ) ; 
                reg_w3      <=  ( w3 ) ; 
                reg_w4      <=  ( w4 ) ; 
                reg_w5      <=  ( w5 ) ; 
                reg_w6      <=  ( w6 ) ; 
                reg_w7      <=  ( w7 ) ; 
                reg_w8      <=  ( w8 ) ; 
                reg_w9      <=  ( w9 ) ; 
                reg_bias    <=  ( b  ) ; 
            end if;
        end process mainBlock;    


        combinational_part: process (   reg_x0 , reg_x1 , reg_x2 , reg_x3 , reg_x4 , 
                                        reg_x5 , reg_x6 , reg_x7 , reg_x8 , reg_x9 , 
                                        reg_w0 , reg_w1 , reg_w2 , reg_w3 , reg_w4 , 
                                        reg_w5 , reg_w6 , reg_w7 , reg_w8 , reg_w9 , 
                                        reg_bias  
                                        --  , prod_0 , prod_1 , prod_2 , prod_3 , prod_4 , 
                                        --  prod_5 , prod_6 , prod_7 , prod_8 , prod_9 ,                                     
                                        --  esp_bias, 
                                        --  af_out
                                    )
            -- IDEALMENTE, calcola in continuo, e assegna all'output in continuo;
            -- quando l'ultimo degli input di questo combinational_part<process> si stabilizza, 
            -- allora anche l'output "af_out" e quindi y si stabilizza

            -- process begin
            begin
                -- !!!
                -- la parte con il clock acquisisce gli input ad ogni clock, e aggiorna i "registri"
                -- esp_x0, esp_x1, ... + esp_w0, esp_w1, ... + esp_bias
                -- !!!

                -- adesso ho tutti gli input su 15 bit pronti per un prodotto che rimanga su 15 bit, 
                -- so che ci sono 13 bit di frazione e 2 bit interi, ma so che per ora il valore intero è in [-1, 1]
                -- quindi FUNZIONA
                -- faccio i prodotti (con segno) che staranno in [-1,1] e sta su 2int+13fract = 15 bit
                -- adesso prod_0 sarà a 30 bit, 

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
                sp_res <= ( prod_0 + prod_1 + prod_2 + prod_3 + prod_4 + prod_5 + 
                            prod_6 + prod_7 + prod_8 + prod_9 + esp_bias );
                -- adesso !!! sp_res contiene un [-11,+11] che è 5int +13fract = 18 bit !!!

                -- !!! Funzione di Attivazione !!!
                -- af_out: 16 bit, valori tra -1 e +1, quindi 3 bit interi e 13 bit frazionali (non me ne posso inventare lol)
                -- signal af_out:  std_logic_vector(16 - 1 downto 0);
                if ( sp_res > DUE_POS_18bit ) then
                    --        "0123456789ABCDEF"012345678"
                    af_out <= "0010000000000000";       -- 1
                elsif ( sp_res < DUE_NEG_18bit ) then                     
                    --        "0123456789ABCDEF"012345678"
                    af_out <= "0000000000000000";       -- 0
                else 
                    -- allora i valori da -2 a +2 vengono spannati nell'intervallo tra 0 e 1
                    -- per farlo eseguirò : x/4 + 1/2 , che è equivalente a (x+2)/4
                    -- però è una divisione di signed !!!, quindi oltre allo shift a destra di 2, 
                    --      devo anche ricordarmi di aggiustare bene i 2 bit di segno in testa
                    --  -- signal value_to_out:    std_logic_vector(18 - 1 downto 0);
                    --  --  value_to_out <= ( sp_res(18-1) & sp_res(18-1) &  sp_res((18-1) downto 2 ) ) + UN_MEZ_18bit;

                    -- arrivato qui ho valori in [ -2, 2], su 5 bit interi (me ne servirebbero 3) e 13 fract = 18 bit totali.
                    -- prima sommo 2, così il valore che ho è sicuramente positivo [0,4]
                    -- poi divido per 4 (due shift a destra).
                    sp_plus_two <= sp_res + DUE_POS_18bit;
                    -- ovviamente l'operazione di shift (troncamento) fa perdere precisione...
                    -- value adesso è un numero tra [0, 1] = [ 000.fract , 001.fract_a_zero ]
                    -- con ancora 3 bit interi (di cui i primi 4 sono 0)
                    -- REMINDER
                    -- e con ancora 13 bit frazionari
                    -- sp_plus_two è sicuramente positivo !!!
                    -- sp_plus_two è del tipo 00XXX.fract_13, 
                    -- lo shift lo renderebbe SS00X.XXfract_11
                    -- se poi lo riduco da sopra a 16 bit, diventa 00X.XXfract_11
                    -- che è già il valore di output !!!
                    af_out <= ( sp_plus_two((18-1) downto 2 ) );
                    
                    --  -- value_to_out <= ( sp_plus_two((18-1) downto 2 ) );
                    --  -- e adesso passo come output degli zeri per la parte intera, seguita dai 13 bit di frazione
                    --  -- sapendo che sp_res era a 18 bit, di cui 5 interi e 13 fract
                    --  -- mentre af_out vuole 16 bit, di cui 3 interi e 13 fract , 
                    --  -- quindi devo prendere value i 13 bit fract e il bit delle unità .
                    --  af_out <= ( "0" & "0" & value_to_out( (14-1) downto 0 ) );

                end if;

            end process combinational_part;

    end J_perceptron;

-- end architecture J_perceptron

        



-- aaa ss

--  signal prod_0 : sfixed(0 downto -15);
--  
--  if (rising_edge(clk)) then
--      _x0 <= x0
--  
--      prod_0 <= (_x0*_w0 + x1*w1) + (x2*w2 + x3*w3) ;
--      y <= prod_0
--  
--  
--  
--  end J_perceptron;
