
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity Perceptron is
    port(
        clk          : in std_logic;
        resetn       : in std_logic; -- active low

        -- input values xi 8 bit, fpv, in [-1, 1]
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
        -- input weights wi 9 bit, fpv, [-1, 1]
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
        -- input bias b, 9 bit, fpv, [-1, 1] 
        b:      in  std_logic_vector(9 - 1 downto 0);
        -- output y, 16 bit, fpv, [-1, 1]
        y :     out std_logic_vector(16 - 1 downto 0)
        --  ;
    );
end Perceptron;

--  /**/ /**/ /**/
architecture J_perceptron of Perceptron is
    -- "registers" input
        signal reg_x0       :   std_logic_vector(8 - 1 downto 0);
        signal reg_x1       :   std_logic_vector(8 - 1 downto 0);
        signal reg_x2       :   std_logic_vector(8 - 1 downto 0);
        signal reg_x3       :   std_logic_vector(8 - 1 downto 0);
        signal reg_x4       :   std_logic_vector(8 - 1 downto 0);
        signal reg_x5       :   std_logic_vector(8 - 1 downto 0);
        signal reg_x6       :   std_logic_vector(8 - 1 downto 0);
        signal reg_x7       :   std_logic_vector(8 - 1 downto 0);
        signal reg_x8       :   std_logic_vector(8 - 1 downto 0);
        signal reg_x9       :   std_logic_vector(8 - 1 downto 0);
        signal reg_w0       :   std_logic_vector(9 - 1 downto 0);
        signal reg_w1       :   std_logic_vector(9 - 1 downto 0);
        signal reg_w2       :   std_logic_vector(9 - 1 downto 0);
        signal reg_w3       :   std_logic_vector(9 - 1 downto 0);
        signal reg_w4       :   std_logic_vector(9 - 1 downto 0);
        signal reg_w5       :   std_logic_vector(9 - 1 downto 0);
        signal reg_w6       :   std_logic_vector(9 - 1 downto 0);
        signal reg_w7       :   std_logic_vector(9 - 1 downto 0);
        signal reg_w8       :   std_logic_vector(9 - 1 downto 0);
        signal reg_w9       :   std_logic_vector(9 - 1 downto 0);
        signal reg_bias     :   std_logic_vector(9 - 1 downto 0);
    -- "register"  output
        -- sì reg out : 
        signal reg_y        :   std_logic_vector(16 - 1 downto 0);

    -- sum-prod of 2int + 6|7 fract -> 17 = 4 int 13 fract in [-1,1]
    -- sum 11 of these -> 21 = 8 int 13 fract in [-11,11]
    -- ->>> 5 int 13 fract suffice to avoid OF, -> all in 18 bits 5 int 13 fract
        signal esp_bias     :   std_logic_vector(18 - 1 downto 0);
        signal prod_0       :   std_logic_vector(18 - 1 downto 0);
        signal prod_1       :   std_logic_vector(18 - 1 downto 0);
        signal prod_2       :   std_logic_vector(18 - 1 downto 0);
        signal prod_3       :   std_logic_vector(18 - 1 downto 0);
        signal prod_4       :   std_logic_vector(18 - 1 downto 0);
        signal prod_5       :   std_logic_vector(18 - 1 downto 0);
        signal prod_6       :   std_logic_vector(18 - 1 downto 0);
        signal prod_7       :   std_logic_vector(18 - 1 downto 0);
        signal prod_8       :   std_logic_vector(18 - 1 downto 0);
        signal prod_9       :   std_logic_vector(18 - 1 downto 0);

        signal sum_0to1     :   std_logic_vector(18 - 1 downto 0);  -- group 2
        signal sum_2to3     :   std_logic_vector(18 - 1 downto 0);  -- group 2
        signal sum_4to5     :   std_logic_vector(18 - 1 downto 0);  -- group 2
        signal sum_6to7     :   std_logic_vector(18 - 1 downto 0);  -- group 2
        signal sum_8to9     :   std_logic_vector(18 - 1 downto 0);  -- group 2        
        signal sum_0to3     :   std_logic_vector(18 - 1 downto 0);  -- group 4
        signal sum_4to7     :   std_logic_vector(18 - 1 downto 0);  -- group 4
        signal sum_8to9_bs  :   std_logic_vector(18 - 1 downto 0);  -- group 3
        signal sum_0to7     :   std_logic_vector(18 - 1 downto 0);  -- group 8

        -- sum_product_result   -- [ "-11" , "+11" ], 5 int 13 fract
        signal sp_res:          std_logic_vector(18 - 1 downto 0);
        signal sp_plus_two:     std_logic_vector(18 - 1 downto 0);
        signal cut_sp_plus_two: std_logic_vector(16 - 1 downto 0);
        
        -- filter output _y_    -- [ "-1" , "+1" ], 5 int 13 fract
        signal value_to_out:    std_logic_vector(16 - 1 downto 0);
        signal af_out:          std_logic_vector(16 - 1 downto 0);

    -- end signals

    -- begin constants
        --                                                            "0123456789ABCDEF01"2345678"
        -- 18 bits : 5 int 13 fract :
        constant DUE_POS_18bit  : std_logic_vector(18 - 1 downto 0) := "000100000000000000" ;
        constant DUE_NEG_18bit  : std_logic_vector(18 - 1 downto 0) := "111100000000000000" ;
        constant UN_MEZ_18bit   : std_logic_vector(18 - 1 downto 0) := "000001000000000000" ;
        -- 16 bits : 3 int 13 fract
        constant ZERO_16b       : std_logic_vector(16 - 1 downto 0) := ( others => '0')     ; --   0
        constant PUNO_16b       : std_logic_vector(16 - 1 downto 0) := ("0010000000000000") ; --  +1
        --                                                             "0123456789ABCDEF"012345678"
    -- end constants

    -- architecture description [begin, end)
    -- architecture begin
    begin --J_perceptron
        mainBlock: process  (   clk, 
                                resetn
                            )
        begin
            -- handle @resetn==0
            if ( resetn = '0' ) then
                -- all inputs are considered 0 
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
                -- bias 
                reg_bias    <= (others => '0') ; 
                -- sì reg uscita : 
                -- output default 0
                reg_y       <= (others => '0') ; 
            elsif ( rising_edge(clk) ) then
                -- acquire input (8 or 9 bit) 
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

        -- reg_bias is signed 9 bit, signed expand to 18 bit
        esp_bias    <= ( reg_bias(9-1) & reg_bias(9-1) & reg_bias(9-1) & reg_bias(9-1) & reg_bias(9-1) & reg_bias(9-1) & reg_bias(9-1) & reg_bias(9-1) & reg_bias(9-1) & reg_bias );

        -- from considerations above, 5 int 13 fract enough to not worry for OF, 
        -- sum in BALANCED BINARY TREE 
        sum_0to1        <= ( prod_0 + prod_1 ) ;     -- group 2
        sum_2to3        <= ( prod_2 + prod_3 ) ;     -- group 2
        sum_4to5        <= ( prod_4 + prod_5 ) ;     -- group 2
        sum_6to7        <= ( prod_6 + prod_7 ) ;     -- group 2
        sum_8to9        <= ( prod_8 + prod_9 ) ;     -- group 2

        sum_0to3        <= ( sum_0to1 + sum_2to3 ) ; -- group 4
        sum_4to7        <= ( sum_4to5 + sum_6to7 ) ; -- group 4
        sum_8to9_bs     <= ( sum_8to9 + esp_bias ) ; -- group 3
        
        sum_0to7        <= ( sum_0to3 + sum_4to7 ) ; -- group 8
        
        sp_res  <= ( sum_0to7 + sum_8to9_bs ) ;
        --  non balanced sum (sequential):
        --  sp_res <= ( prod_0 + prod_1 + prod_2 + prod_3 + prod_4 + prod_5 + prod_6 + prod_7 + prod_8 + prod_9 + esp_bias );

        -- !!! OUT_DECISOR !!!
        -- let sp_res = x
        -- _ if x > 2, 1
        -- _ if x <2, 0
        -- _ else : [ (x+2)/4 ]  ==  [ (x/2) + 1/2 ] 
        -- from given, note : x+2 GE0 && x+2 AE0
        -- sp_plus_two :        00XXX.fract_13, 
        -- after shift :        SS00X.XXfract_11
        -- reduce to 16 bit :   00X.XXfract_11
        -- i will just cut after addition and all is good

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

    -- (end architecture J_perceptron)
    end J_perceptron;


