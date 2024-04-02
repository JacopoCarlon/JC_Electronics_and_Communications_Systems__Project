library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity Perceptron_tb is
end Perceptron_tb ;

architecture tb of Perceptron_tb is
    constant CLK_PERIOD : time := 400 ns;
    constant THREE_QUARTERS_PERIOD : time := 300 ns;

    constant ZERO_15b     : std_logic_vector(15 - 1 downto 0)   := (others => '0') ;-- 0
    constant ZERO_6b      : std_logic_vector(6 - 1 downto 0)    := (others => '0') ;-- 0    -- per 7f
    constant ZERO_7b      : std_logic_vector(7 - 1 downto 0)    := (others => '0') ;-- 0    -- per 6f
    constant UNO_15b      : std_logic_vector(15 - 1 downto 0)   := (others => '1') ;-- 1
    constant UNO_6b       : std_logic_vector(6 - 1 downto 0)    := (others => '1') ;-- 1    -- per 7f
    constant UNO_7b       : std_logic_vector(7 - 1 downto 0)    := (others => '1') ;-- 1    -- per 6f

    constant PUNO_30b_7f  : std_logic_vector(30 - 1 downto 0)   := ( ZERO_15b & ZERO_6b & "010000000" ) ; -- +1
    constant PHLF_30b_7f  : std_logic_vector(30 - 1 downto 0)   := ( ZERO_15b & ZERO_6b & "001000000" ) ; -- +0.5
    constant PQRT_30b_7f  : std_logic_vector(30 - 1 downto 0)   := ( ZERO_15b & ZERO_6b & "000100000" ) ; -- +0.25
    constant NQRT_30b_7f  : std_logic_vector(30 - 1 downto 0)   := ( UNO_15b  & UNO_6b  & "111100000" ) ; -- -0.25
    constant NHLF_30b_7f  : std_logic_vector(30 - 1 downto 0)   := ( UNO_15b  & UNO_6b  & "111000000" ) ; -- -0.5
    constant NUNO_30b_7f  : std_logic_vector(30 - 1 downto 0)   := ( UNO_15b  & UNO_6b  & "110000000" ) ; -- -1

    constant PUNO_30b_6f  : std_logic_vector(30 - 1 downto 0)   :=  ( ZERO_15b & ZERO_7b & "01000000" ) ; -- +1
    constant PHLF_30b_6f  : std_logic_vector(30 - 1 downto 0)   :=  ( ZERO_15b & ZERO_7b & "00100000" ) ; -- +0.5
    constant PQRT_30b_6f  : std_logic_vector(30 - 1 downto 0)   :=  ( ZERO_15b & ZERO_7b & "00010000" ) ; -- +0.25
    constant NQRT_30b_6f  : std_logic_vector(30 - 1 downto 0)   :=  ( UNO_15b  & UNO_7b  & "11110000" ) ; -- -0.25
    constant NHLF_30b_6f  : std_logic_vector(30 - 1 downto 0)   :=  ( UNO_15b  & UNO_7b  & "11100000" ) ; -- -0.5
    constant NUNO_30b_6f  : std_logic_vector(30 - 1 downto 0)   :=  ( UNO_15b  & UNO_7b  & "11000000" ) ; -- -1
    
    constant ZERO_30b     : std_logic_vector(30 - 1 downto 0)   := (others => '0' ) ;-- 0

    -- y ha 13 fract e 3 interi, ed è in [0, 1]
    -- il +1 sarebbe 001_000_000_000_000_0
    constant ZERO_16b     : std_logic_vector(16 - 1 downto 0)   := (others => '0') ;-- 0
    constant PUNO_16b     : std_logic_vector(16 - 1 downto 0)   := ("0010000000000000") ; -- +1
    constant PHLF_16b     : std_logic_vector(16 - 1 downto 0)   := ("0001000000000000") ;-- 0


    component Perceptron
        port(
            clk     : in std_logic;
            resetn  : in std_logic; -- active low
            -- input xi a 8 bit, in virgola fissa, tra -1 e 1
            x0      : in  std_logic_vector(8 - 1 downto 0);
            x1      : in  std_logic_vector(8 - 1 downto 0);
            x2      : in  std_logic_vector(8 - 1 downto 0);
            x3      : in  std_logic_vector(8 - 1 downto 0);
            x4      : in  std_logic_vector(8 - 1 downto 0);
            x5      : in  std_logic_vector(8 - 1 downto 0);
            x6      : in  std_logic_vector(8 - 1 downto 0);
            x7      : in  std_logic_vector(8 - 1 downto 0);
            x8      : in  std_logic_vector(8 - 1 downto 0);
            x9      : in  std_logic_vector(8 - 1 downto 0);
            -- input weights wi a 9 bit, in virgola fissa, tra -1 e 1
            w0      : in  std_logic_vector(9 - 1 downto 0);
            w1      : in  std_logic_vector(9 - 1 downto 0);
            w2      : in  std_logic_vector(9 - 1 downto 0);
            w3      : in  std_logic_vector(9 - 1 downto 0);
            w4      : in  std_logic_vector(9 - 1 downto 0);
            w5      : in  std_logic_vector(9 - 1 downto 0);
            w6      : in  std_logic_vector(9 - 1 downto 0);
            w7      : in  std_logic_vector(9 - 1 downto 0);
            w8      : in  std_logic_vector(9 - 1 downto 0);
            w9      : in  std_logic_vector(9 - 1 downto 0);
            -- input bias a 9 bit, in virgola fissa, tra -1 e 1
            b       : in  std_logic_vector(9 - 1 downto 0);
            -- output [-1, 1]
            y       : out std_logic_vector(16 - 1 downto 0)
        );
    end component;

    -- control signals
    -- timings signals
    signal clk_tb   : std_logic     := '0';
    signal resetn_tb: std_logic     := '0';
    -- test estimators
    signal success  : std_logic     := '0';
    signal fail     : std_logic     := '0';
    signal pass_input: std_logic    := '0';
    signal testing  : boolean := true;
    -- mi preparo tutti i registri a 0
    -- input vals
    signal tb_reg_x0    :   std_logic_vector(30 - 1 downto 0)   := (others => '0' ) ;
    signal tb_reg_x1    :   std_logic_vector(30 - 1 downto 0)   := (others => '0' ) ;
    signal tb_reg_x2    :   std_logic_vector(30 - 1 downto 0)   := (others => '0' ) ;
    signal tb_reg_x3    :   std_logic_vector(30 - 1 downto 0)   := (others => '0' ) ;
    signal tb_reg_x4    :   std_logic_vector(30 - 1 downto 0)   := (others => '0' ) ;
    signal tb_reg_x5    :   std_logic_vector(30 - 1 downto 0)   := (others => '0' ) ;
    signal tb_reg_x6    :   std_logic_vector(30 - 1 downto 0)   := (others => '0' ) ;
    signal tb_reg_x7    :   std_logic_vector(30 - 1 downto 0)   := (others => '0' ) ;
    signal tb_reg_x8    :   std_logic_vector(30 - 1 downto 0)   := (others => '0' ) ;
    signal tb_reg_x9    :   std_logic_vector(30 - 1 downto 0)   := (others => '0' ) ;
    -- input weights
    signal tb_reg_w0    :   std_logic_vector(30 - 1 downto 0)   := (others => '0' ) ;
    signal tb_reg_w1    :   std_logic_vector(30 - 1 downto 0)   := (others => '0' ) ;
    signal tb_reg_w2    :   std_logic_vector(30 - 1 downto 0)   := (others => '0' ) ;
    signal tb_reg_w3    :   std_logic_vector(30 - 1 downto 0)   := (others => '0' ) ;
    signal tb_reg_w4    :   std_logic_vector(30 - 1 downto 0)   := (others => '0' ) ;
    signal tb_reg_w5    :   std_logic_vector(30 - 1 downto 0)   := (others => '0' ) ;
    signal tb_reg_w6    :   std_logic_vector(30 - 1 downto 0)   := (others => '0' ) ;
    signal tb_reg_w7    :   std_logic_vector(30 - 1 downto 0)   := (others => '0' ) ;
    signal tb_reg_w8    :   std_logic_vector(30 - 1 downto 0)   := (others => '0' ) ;
    signal tb_reg_w9    :   std_logic_vector(30 - 1 downto 0)   := (others => '0' ) ;
    -- input system bias
    signal tb_reg_bias  :   std_logic_vector(30 - 1 downto 0)   := (others => '0' ) ;
    -- output filtered result
    signal tbs_y_rcv    :   std_logic_vector(16 - 1 downto 0)   := (others => '0' ) ;
    -- end signals

    -- begin testing
    begin
        clk_tb <= not clk_tb after CLK_PERIOD / 2 when testing else '0';
        -- attach device to test (device under test)
        dut : Perceptron
        port map(
            clk         =>  clk_tb,
            resetn      =>  resetn_tb,
            x0          =>  tb_reg_x0( 8-1 downto 0 ) ,  
            x1          =>  tb_reg_x1( 8-1 downto 0 ) ,
            x2          =>  tb_reg_x2( 8-1 downto 0 ) ,
            x3          =>  tb_reg_x3( 8-1 downto 0 ) ,
            x4          =>  tb_reg_x4( 8-1 downto 0 ) ,
            x5          =>  tb_reg_x5( 8-1 downto 0 ) ,
            x6          =>  tb_reg_x6( 8-1 downto 0 ) ,
            x7          =>  tb_reg_x7( 8-1 downto 0 ) ,
            x8          =>  tb_reg_x8( 8-1 downto 0 ) ,
            x9          =>  tb_reg_x9( 8-1 downto 0 ) ,
            w0          =>  tb_reg_w0( 9-1 downto 0 ) , 
            w1          =>  tb_reg_w1( 9-1 downto 0 ) , 
            w2          =>  tb_reg_w2( 9-1 downto 0 ) , 
            w3          =>  tb_reg_w3( 9-1 downto 0 ) , 
            w4          =>  tb_reg_w4( 9-1 downto 0 ) , 
            w5          =>  tb_reg_w5( 9-1 downto 0 ) , 
            w6          =>  tb_reg_w6( 9-1 downto 0 ) , 
            w7          =>  tb_reg_w7( 9-1 downto 0 ) , 
            w8          =>  tb_reg_w8( 9-1 downto 0 ) , 
            w9          =>  tb_reg_w9( 9-1 downto 0 ) , 
            b           =>  tb_reg_bias( 9-1 downto 0 ) , 
            y           =>  tbs_y_rcv   
        );
        
        -- testing "program"
        TB_PROC: process -- (clk_tb) 
        begin
            if testing then
                wait until rising_edge(clk_tb);
                resetn_tb <= '0' ;
                wait until rising_edge(clk_tb);
                -- end reset (resent begins at 0 in tb, now i put it at 1)
                resetn_tb <= '1' ;
            -- give initial data: weights not 0, x all 0
                wait until rising_edge(clk_tb);
                -- x ha 6 bit fract e 2 interi, metto tutto a 0 _ il reg è a 30 bit               
                tb_reg_x0 <= ZERO_30b ; 
                tb_reg_x1 <= ZERO_30b ; 
                tb_reg_x2 <= ZERO_30b ; 
                tb_reg_x3 <= ZERO_30b ; 
                tb_reg_x4 <= ZERO_30b ; 
                tb_reg_x5 <= ZERO_30b ; 
                tb_reg_x6 <= ZERO_30b ; 
                tb_reg_x7 <= ZERO_30b ; 
                tb_reg_x8 <= ZERO_30b ; 
                tb_reg_x9 <= ZERO_30b ; 
                -- w e bias hanno 7 bit fract e 2 interi _ il reg è a 30 bit
                tb_reg_w0 <=  PUNO_30b_7f ;   -- +1
                tb_reg_w1 <=  PUNO_30b_7f ;   -- +1
                tb_reg_w2 <=  PUNO_30b_7f ;   -- +1
                tb_reg_w3 <=  PHLF_30b_7f ;   -- +0.5
                tb_reg_w4 <=  PQRT_30b_7f ;   -- +0.25
                tb_reg_w5 <=  NUNO_30b_7f ;   -- -1
                tb_reg_w6 <=  NUNO_30b_7f ;   -- -1
                tb_reg_w7 <=  NUNO_30b_7f ;   -- -1
                tb_reg_w8 <=  NHLF_30b_7f ;   -- -0.5
                tb_reg_w9 <=  NQRT_30b_7f ;   -- -0.25
                -- bias come sopra
                tb_reg_bias <= ZERO_30b ;     -- +0
                pass_input <= '1';
            --  tutti gli input sono 0, output dovrebbe essere 1/2;
                wait until rising_edge(clk_tb);
                pass_input <= '0';
                wait until rising_edge(clk_tb);
                wait for 15 ns;
                if tbs_y_rcv /= PHLF_16b then
                    fail<= '1' ;
                end if;
        -- daccapino
            -- test x values:
            -- pos -> 1
                wait until rising_edge(clk_tb);
                pass_input <= '1';
                wait for THREE_QUARTERS_PERIOD ;
                -- cambio solo un paio di registri intanto
                tb_reg_x0 <= PUNO_30b_6f    ; -- * +1
                tb_reg_x1 <= PUNO_30b_6f    ; -- * +1
                tb_reg_x2 <= PUNO_30b_6f    ; -- * +1
                tb_reg_x5 <= PUNO_30b_6f    ; -- * -1
                tb_reg_x6 <= ZERO_30b       ; -- * -1
                tb_reg_x7 <= ZERO_30b       ; -- * -1
                -- adesso y dovrebbe essere 1+1+1-1-0-0 = 2 quindi 1
                wait until rising_edge(clk_tb);
                pass_input <= '0';
                wait until rising_edge(clk_tb);
                wait for 15 ns;
                if tbs_y_rcv /= PUNO_16b then
                    fail<= '1' ;
                end if;
            -- neg -> 0
                wait until rising_edge(clk_tb);
                pass_input <= '1';
                wait for THREE_QUARTERS_PERIOD ;
                -- cambio solo un paio di registri intanto
                tb_reg_x0 <= NUNO_30b_6f    ; -- * +1
                tb_reg_x1 <= NUNO_30b_6f    ; -- * +1
                tb_reg_x2 <= NUNO_30b_6f    ; -- * +1
                tb_reg_x5 <= NUNO_30b_6f    ; -- * -1
                tb_reg_x6 <= ZERO_30b       ; -- * -1
                tb_reg_x7 <= ZERO_30b       ; -- * -1
                -- adesso y dovrebbe essere -1 -1 -1 +1 +0 +0 = -2 quindi 0
                wait until rising_edge(clk_tb);
                pass_input <= '0';
                wait until rising_edge(clk_tb);
                wait for 15 ns;
                if tbs_y_rcv /= ZERO_16b then
                    fail<= '1' ;
                end if;
            -- zero -> 0.5
                wait until rising_edge(clk_tb);
                pass_input <= '1';
                wait for THREE_QUARTERS_PERIOD ;
                -- cambio solo un paio di registri intanto
                tb_reg_x0 <= PUNO_30b_6f    ; -- * +1
                tb_reg_x1 <= PUNO_30b_6f    ; -- * +1
                tb_reg_x2 <= PUNO_30b_6f    ; -- * +1
                tb_reg_x5 <= PUNO_30b_6f    ; -- * -1
                tb_reg_x6 <= PUNO_30b_6f    ; -- * -1
                tb_reg_x7 <= PUNO_30b_6f    ; -- * -1
                -- adesso y dovrebbe essere -1 -1 -1 +1 +0 +0 = 0 quindi 1/2
                wait until rising_edge(clk_tb);
                pass_input <= '0';
                wait until rising_edge(clk_tb);
                wait for 15 ns;
                if tbs_y_rcv /= PHLF_16b then
                    fail<= '1' ;
                end if;
            -- daccapone
                -- test x values:
            -- pos -> 1
                wait until rising_edge(clk_tb);
                pass_input <= '1';
                wait for THREE_QUARTERS_PERIOD ;
                -- cambio solo un paio di registri intanto
                tb_reg_x0 <= PUNO_30b_6f    ; -- * +1
                tb_reg_x1 <= PUNO_30b_6f    ; -- * +1
                tb_reg_x2 <= PUNO_30b_6f    ; -- * +1
                tb_reg_x5 <= PUNO_30b_6f    ; -- * -1
                tb_reg_x6 <= ZERO_30b       ; -- * -1
                tb_reg_x7 <= ZERO_30b       ; -- * -1
                -- adesso y dovrebbe essere 1+1+1-1-0-0 = 2 quindi 1
                wait until rising_edge(clk_tb);
                pass_input <= '0';
                wait until rising_edge(clk_tb);
                wait for 15 ns;
                if tbs_y_rcv /= PUNO_16b then
                    fail<= '1' ;
                end if;
            -- neg -> 0
                wait until rising_edge(clk_tb);
                pass_input <= '1';
                wait for THREE_QUARTERS_PERIOD ;
                -- cambio solo un paio di registri intanto
                tb_reg_x0 <= NUNO_30b_6f    ; -- * +1
                tb_reg_x1 <= NUNO_30b_6f    ; -- * +1
                tb_reg_x2 <= NUNO_30b_6f    ; -- * +1
                tb_reg_x5 <= NUNO_30b_6f    ; -- * -1
                tb_reg_x6 <= ZERO_30b       ; -- * -1
                tb_reg_x7 <= ZERO_30b       ; -- * -1
                -- adesso y dovrebbe essere -1 -1 -1 +1 +0 +0 = -2 quindi 0
                wait until rising_edge(clk_tb);
                pass_input <= '0';
                wait until rising_edge(clk_tb);
                wait for 15 ns;
                if tbs_y_rcv /= ZERO_16b then
                    fail<= '1' ;
                end if;
            -- zero -> 0.5
                wait until rising_edge(clk_tb);
                pass_input <= '1';
                wait for THREE_QUARTERS_PERIOD ;
                -- cambio solo un paio di registri intanto
                tb_reg_x0 <= PUNO_30b_6f    ; -- * +1
                tb_reg_x1 <= PUNO_30b_6f    ; -- * +1
                tb_reg_x2 <= PUNO_30b_6f    ; -- * +1
                tb_reg_x5 <= PUNO_30b_6f    ; -- * -1
                tb_reg_x6 <= PUNO_30b_6f    ; -- * -1
                tb_reg_x7 <= PUNO_30b_6f    ; -- * -1
                -- adesso y dovrebbe essere -1 -1 -1 +1 +0 +0 = 0 quindi 1/2
                wait until rising_edge(clk_tb);
                pass_input <= '0';
                wait until rising_edge(clk_tb);
                wait for 15 ns;
                if tbs_y_rcv /= PHLF_16b then
                    fail<= '1' ;
                end if;
                -- other tests omitted for brevity of print
                -- ...
                wait until rising_edge(clk_tb);
                pass_input <= '1';
                wait until rising_edge(clk_tb);
                pass_input <= '0';
                wait until rising_edge(clk_tb);
                pass_input <= '1';
                wait until rising_edge(clk_tb);
                pass_input <= '0';
                testing <= false;
            end if; -- (di testing == 1)

        end process;
    
    end architecture;
-- fine

    
