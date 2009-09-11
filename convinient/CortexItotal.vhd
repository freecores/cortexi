---------------------------------------------------------------
--  CortexI  a CortexM3 CPU clone
--  Ulrich Riedel
--  2009.09.10
--  supplied at LGPL
--  riedel@ziffernkasten.de
--   search for #MAIN# for CortexI CPU
---------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

package CortexIinclude is

  constant SIZE_8BIT   : std_logic_vector(1 downto 0) := "00";
  constant SIZE_16BIT  : std_logic_vector(1 downto 0) := "01";
  constant SIZE_32BIT  : std_logic_vector(1 downto 0) := "10";
  constant SIZE_32SBIT : std_logic_vector(1 downto 0) := "11";
    
  constant BS_ROL : std_logic_vector(2 downto 0) := "000";
  constant BS_LSL : std_logic_vector(2 downto 0) := "001";
  constant BS_ROR : std_logic_vector(2 downto 0) := "010";
  constant BS_LSR : std_logic_vector(2 downto 0) := "011";
  constant BS_ASR : std_logic_vector(2 downto 0) := "100";

end CortexIinclude;

package body CortexIinclude is

end CortexIinclude;

--------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

use work.CortexIinclude.ALL;

entity bshifter is Port(
           din   : in  std_logic_vector(31 downto 0);
           size  : in  std_logic_vector( 1 downto 0);
           mode  : in  std_logic_vector( 2 downto 0);
           count : in  std_logic_vector( 4 downto 0);
           cyOut : out std_logic;
           dout  : out std_logic_vector(31 downto 0)
           );
end bshifter;

Library UNISIM;
use UNISIM.vcomponents.all;

architecture behavioral of bshifter is

  signal shift  : std_logic_vector(4 downto 0);
  signal ENCODE : STD_LOGIC_VECTOR (17 downto 0);
  signal WORDA  : STD_LOGIC_VECTOR (17 downto 0);
  signal WORDB  : STD_LOGIC_VECTOR (17 downto 0);
  signal WORDC  : STD_LOGIC_VECTOR (17 downto 0);
  signal WORDD  : STD_LOGIC_VECTOR (17 downto 0);

  signal OUTA  : STD_LOGIC_VECTOR (35 downto 0);
  signal OUTB  : STD_LOGIC_VECTOR (35 downto 0);
  signal OUTC  : STD_LOGIC_VECTOR (35 downto 0);
  signal OUTD  : STD_LOGIC_VECTOR (35 downto 0);

  signal temp : std_logic_vector(31 downto 0);

  signal input : std_logic_vector(31 downto 0);
  signal output : std_logic_vector(31 downto 0);

begin

  process(din, size) -- data in multiplexor
  begin
    case size is
      when SIZE_8BIT  =>  -- 8bit
        input <= din(7 downto 0) &
                 din(7 downto 0) &
                 din(7 downto 0) &
                 din(7 downto 0);
      when SIZE_16BIT  =>  -- 16bit
        input <= din(15 downto 0) & din(15 downto 0);
      when SIZE_32BIT | SIZE_32SBIT  => -- 32bit
        input <= din;
      when others =>
        null;
    end case; -- size
  end process;
  
  process(output, size, mode) -- data output multiplexor
  begin
    case size is
      when SIZE_8BIT  =>  -- 8bit
        case mode is
          when "000" => -- ROL
            dout <= output;
          when "001" => -- LSL
            dout <= output;
          when "010" => -- ROR
            dout <= output;
          when "011" => -- LSR
            dout <= x"000000" & output(31 downto 24);
          when "100" => -- ASR
            dout <= x"000000" & output(31 downto 24);
          when others =>
            dout <= output;
        end case; -- mode
      when SIZE_16BIT  =>  -- 16bit
        case mode is
          when "000" => -- ROL
            dout <= output;
          when "001" => -- LSL
            dout <= output;
          when "010" => -- ROR
            dout <= output;
          when "011" => -- LSR
            dout <= x"0000" & output(31 downto 16);
          when "100" => -- ASR
            dout <= x"0000" & output(31 downto 16);
          when others =>
            dout <= output;
        end case; -- mode
      when SIZE_32BIT | SIZE_32SBIT => -- 32bit
        dout <= output;
      when others =>
        null;
    end case; -- size
  end process;
  
  process(count, mode, temp, input)
  begin
    case mode is
      when BS_ROL => -- ROL
        shift  <= count;
        output <= temp;
        cyOut  <= input(conv_integer(32 - count));
      when BS_LSL => -- LSL
        shift  <= count;
        cyOut  <= input(conv_integer(32 - count));        
        case count is
          when "00000" =>
            output <= temp;
          when "00001" =>
            output <= temp and "11111111111111111111111111111110";
          when "00010" =>
            output <= temp and "11111111111111111111111111111100";
          when "00011" =>
            output <= temp and "11111111111111111111111111111000";
          when "00100" =>
            output <= temp and "11111111111111111111111111110000";
          when "00101" =>
            output <= temp and "11111111111111111111111111100000";
          when "00110" =>
            output <= temp and "11111111111111111111111111000000";
          when "00111" =>
            output <= temp and "11111111111111111111111110000000";
          when "01000" =>
            output <= temp and "11111111111111111111111100000000";
          when "01001" =>
            output <= temp and "11111111111111111111111000000000";
          when "01010" =>
            output <= temp and "11111111111111111111110000000000";
          when "01011" =>
            output <= temp and "11111111111111111111100000000000";
          when "01100" =>
            output <= temp and "11111111111111111111000000000000";
          when "01101" =>
            output <= temp and "11111111111111111110000000000000";
          when "01110" =>
            output <= temp and "11111111111111111100000000000000";
          when "01111" =>
            output <= temp and "11111111111111111000000000000000";
          when "10000" =>
            output <= temp and "11111111111111110000000000000000";
          when "10001" =>
            output <= temp and "11111111111111100000000000000000";
          when "10010" =>
            output <= temp and "11111111111111000000000000000000";
          when "10011" =>
            output <= temp and "11111111111110000000000000000000";
          when "10100" =>
            output <= temp and "11111111111100000000000000000000";
          when "10101" =>
            output <= temp and "11111111111000000000000000000000";
          when "10110" =>
            output <= temp and "11111111110000000000000000000000";
          when "10111" =>
            output <= temp and "11111111100000000000000000000000";
          when "11000" =>
            output <= temp and "11111111000000000000000000000000";
          when "11001" =>
            output <= temp and "11111110000000000000000000000000";
          when "11010" =>
            output <= temp and "11111100000000000000000000000000";
          when "11011" =>
            output <= temp and "11111000000000000000000000000000";
          when "11100" =>
            output <= temp and "11110000000000000000000000000000";
          when "11101" =>
            output <= temp and "11100000000000000000000000000000";
          when "11110" =>
            output <= temp and "11000000000000000000000000000000";
          when "11111" =>
            output <= temp and "10000000000000000000000000000000";
          when others =>
            output <= temp;
        end case; -- count
      when BS_ROR =>  -- ROR
        shift  <= 32 - count;
        output <= temp;
        cyOut  <= input(conv_integer(count - 1));
      when BS_LSR =>  -- LSR
        shift  <= 32 - count;
        cyOut  <= input(conv_integer(count - 1));
        case count is
          when "00000" =>
            output <= temp;
          when "00001" =>
            output <= temp and "01111111111111111111111111111111";
          when "00010" =>
            output <= temp and "00111111111111111111111111111111";
          when "00011" =>
            output <= temp and "00011111111111111111111111111111";
          when "00100" =>
            output <= temp and "00001111111111111111111111111111";
          when "00101" =>
            output <= temp and "00000111111111111111111111111111";
          when "00110" =>
            output <= temp and "00000011111111111111111111111111";
          when "00111" =>
            output <= temp and "00000001111111111111111111111111";
          when "01000" =>
            output <= temp and "00000000111111111111111111111111";
          when "01001" =>
            output <= temp and "00000000011111111111111111111111";
          when "01010" =>
            output <= temp and "00000000001111111111111111111111";
          when "01011" =>
            output <= temp and "00000000000111111111111111111111";
          when "01100" =>
            output <= temp and "00000000000011111111111111111111";
          when "01101" =>
            output <= temp and "00000000000001111111111111111111";
          when "01110" =>
            output <= temp and "00000000000000111111111111111111";
          when "01111" =>
            output <= temp and "00000000000000011111111111111111";
          when "10000" =>
            output <= temp and "00000000000000001111111111111111";
          when "10001" =>
            output <= temp and "00000000000000000111111111111111";
          when "10010" =>
            output <= temp and "00000000000000000011111111111111";
          when "10011" =>
            output <= temp and "00000000000000000001111111111111";
          when "10100" =>
            output <= temp and "00000000000000000000111111111111";
          when "10101" =>
            output <= temp and "00000000000000000000011111111111";
          when "10110" =>
            output <= temp and "00000000000000000000001111111111";
          when "10111" =>
            output <= temp and "00000000000000000000000111111111";
          when "11000" =>
            output <= temp and "00000000000000000000000011111111";
          when "11001" =>
            output <= temp and "00000000000000000000000001111111";
          when "11010" =>
            output <= temp and "00000000000000000000000000111111";
          when "11011" =>
            output <= temp and "00000000000000000000000000011111";
          when "11100" =>
            output <= temp and "00000000000000000000000000001111";
          when "11101" =>
            output <= temp and "00000000000000000000000000000111";
          when "11110" =>
            output <= temp and "00000000000000000000000000000011";
          when "11111" =>
            output <= temp and "00000000000000000000000000000001";
          when others =>
            output <= temp;
        end case; -- count
      when BS_ASR =>  -- ASR
        shift  <= 32 - count;
        cyOut  <= input(conv_integer(count - 1));
        case count is
          when "00000" =>
            output <= (input(31) & input(31) & input(31) & input(31) &
                       input(31) & input(31) & input(31) & input(31) &
                       input(31) & input(31) & input(31) & input(31) &
                       input(31) & input(31) & input(31) & input(31) &
                       input(31) & input(31) & input(31) & input(31) &
                       input(31) & input(31) & input(31) & input(31) &
                       input(31) & input(31) & input(31) & input(31) &
                       input(31) & input(31) & input(31) & input(31));
          when "00001" =>
            output <= (temp and "01111111111111111111111111111111") or 
                      (input(31) & "0000000000000000000000000000000");
          when "00010" =>
            output <= (temp and "00111111111111111111111111111111") or 
                      (input(31) & input(31) & 
                      "000000000000000000000000000000");
          when "00011" =>
            output <= (temp and "00011111111111111111111111111111") or 
                      (input(31) & input(31) & input(31) & 
                      "00000000000000000000000000000");
          when "00100" =>
            output <= (temp and "00001111111111111111111111111111") or 
                      (input(31) & input(31) & input(31) & input(31) & 
                      "0000000000000000000000000000");
          when "00101" =>
            output <= (temp and "00000111111111111111111111111111") or 
                      (input(31) & input(31) & input(31) & input(31) &
                       input(31) & "000000000000000000000000000");
          when "00110" =>
            output <= (temp and "00000011111111111111111111111111") or 
                      (input(31) & input(31) & input(31) & input(31) &
                       input(31) & input(31) & 
                       "00000000000000000000000000");
          when "00111" =>
            output <= (temp and "00000001111111111111111111111111") or 
                      (input(31) & input(31) & input(31) & input(31) &
                       input(31) & input(31) & input(31) & 
                       "0000000000000000000000000");
          when "01000" =>
            output <= (temp and "00000000111111111111111111111111") or
                      (input(31) & input(31) & input(31) & input(31) &
                       input(31) & input(31) & input(31) & input(31) & 
                       "000000000000000000000000");
          when "01001" =>
            output <= (temp and "00000000011111111111111111111111") or 
                      (input(31) & input(31) & input(31) & input(31) &
                       input(31) & input(31) & input(31) & input(31) &
                       input(31) & "00000000000000000000000");
          when "01010" =>
            output <= (temp and "00000000001111111111111111111111") or
                      (input(31) & input(31) & input(31) & input(31) &
                       input(31) & input(31) & input(31) & input(31) &
                       input(31) & input(31) & "0000000000000000000000");
          when "01011" =>
            output <= (temp and "00000000000111111111111111111111") or 
                      (input(31) & input(31) & input(31) & input(31) &
                       input(31) & input(31) & input(31) & input(31) &
                       input(31) & input(31) & input(31) & 
                       "000000000000000000000");
          when "01100" =>
            output <= (temp and "00000000000011111111111111111111") or
                      (input(31) & input(31) & input(31) & input(31) &
                       input(31) & input(31) & input(31) & input(31) &
                       input(31) & input(31) & input(31) & input(31) & 
                       "00000000000000000000");
          when "01101" =>
            output <= (temp and "00000000000001111111111111111111") or
                      (input(31) & input(31) & input(31) & input(31) &
                       input(31) & input(31) & input(31) & input(31) &
                       input(31) & input(31) & input(31) & input(31) & 
                       input(31) & "0000000000000000000");
          when "01110" =>
            output <= (temp and "00000000000000111111111111111111") or
                      (input(31) & input(31) & input(31) & input(31) &
                       input(31) & input(31) & input(31) & input(31) &
                       input(31) & input(31) & input(31) & input(31) & 
                       input(31) & input(31) & "000000000000000000");
          when "01111" =>
            output <= (temp and "00000000000000011111111111111111") or
                      (input(31) & input(31) & input(31) & input(31) &
                       input(31) & input(31) & input(31) & input(31) &
                       input(31) & input(31) & input(31) & input(31) & 
                       input(31) & input(31) & input(31) & 
                       "00000000000000000");
          when "10000" =>
            output <= (temp and "00000000000000001111111111111111") or
                      (input(31) & input(31) & input(31) & input(31) &
                       input(31) & input(31) & input(31) & input(31) &
                       input(31) & input(31) & input(31) & input(31) & 
                       input(31) & input(31) & input(31) & input(31) & 
                       "0000000000000000");
          when "10001" =>
            output <= (temp and "00000000000000000111111111111111") or
                      (input(31) & input(31) & input(31) & input(31) &
                       input(31) & input(31) & input(31) & input(31) &
                       input(31) & input(31) & input(31) & input(31) & 
                       input(31) & input(31) & input(31) & input(31) &
                       input(31) & "000000000000000");
          when "10010" =>
            output <= (temp and "00000000000000000011111111111111") or
                      (input(31) & input(31) & input(31) & input(31) &
                       input(31) & input(31) & input(31) & input(31) &
                       input(31) & input(31) & input(31) & input(31) & 
                       input(31) & input(31) & input(31) & input(31) &
                       input(31) & input(31) & "00000000000000");
          when "10011" =>
            output <= (temp and "00000000000000000001111111111111") or
                      (input(31) & input(31) & input(31) & input(31) &
                       input(31) & input(31) & input(31) & input(31) &
                       input(31) & input(31) & input(31) & input(31) & 
                       input(31) & input(31) & input(31) & input(31) &
                       input(31) & input(31) & input(31) & "0000000000000");
          when "10100" =>
            output <= (temp and "00000000000000000000111111111111") or
                      (input(31) & input(31) & input(31) & input(31) &
                       input(31) & input(31) & input(31) & input(31) &
                       input(31) & input(31) & input(31) & input(31) & 
                       input(31) & input(31) & input(31) & input(31) &
                       input(31) & input(31) & input(31) & input(31) & 
                       "000000000000");
          when "10101" =>
            output <= (temp and "00000000000000000000011111111111") or
                      (input(31) & input(31) & input(31) & input(31) &
                       input(31) & input(31) & input(31) & input(31) &
                       input(31) & input(31) & input(31) & input(31) & 
                       input(31) & input(31) & input(31) & input(31) &
                       input(31) & input(31) & input(31) & input(31) &
                       input(31) & "00000000000");
          when "10110" =>
            output <= (temp and "00000000000000000000001111111111") or
                      (input(31) & input(31) & input(31) & input(31) &
                       input(31) & input(31) & input(31) & input(31) &
                       input(31) & input(31) & input(31) & input(31) & 
                       input(31) & input(31) & input(31) & input(31) &
                       input(31) & input(31) & input(31) & input(31) &
                       input(31) & input(31) & "0000000000");
          when "10111" =>
            output <= (temp and "00000000000000000000000111111111") or
                      (input(31) & input(31) & input(31) & input(31) &
                       input(31) & input(31) & input(31) & input(31) &
                       input(31) & input(31) & input(31) & input(31) & 
                       input(31) & input(31) & input(31) & input(31) &
                       input(31) & input(31) & input(31) & input(31) &
                       input(31) & input(31) & input(31) & "000000000");
          when "11000" =>
            output <= (temp and "00000000000000000000000011111111") or
                      (input(31) & input(31) & input(31) & input(31) &
                       input(31) & input(31) & input(31) & input(31) &
                       input(31) & input(31) & input(31) & input(31) & 
                       input(31) & input(31) & input(31) & input(31) &
                       input(31) & input(31) & input(31) & input(31) &
                       input(31) & input(31) & input(31) & input(31) & 
                       "00000000");
          when "11001" =>
            output <= (temp and "00000000000000000000000001111111") or
                      (input(31) & input(31) & input(31) & input(31) &
                       input(31) & input(31) & input(31) & input(31) &
                       input(31) & input(31) & input(31) & input(31) & 
                       input(31) & input(31) & input(31) & input(31) &
                       input(31) & input(31) & input(31) & input(31) &
                       input(31) & input(31) & input(31) & input(31) &
                       input(31) & "0000000");
          when "11010" =>
            output <= (temp and "00000000000000000000000000111111") or
                      (input(31) & input(31) & input(31) & input(31) &
                       input(31) & input(31) & input(31) & input(31) &
                       input(31) & input(31) & input(31) & input(31) & 
                       input(31) & input(31) & input(31) & input(31) &
                       input(31) & input(31) & input(31) & input(31) &
                       input(31) & input(31) & input(31) & input(31) &
                       input(31) & input(31) & "000000");
          when "11011" =>
            output <= (temp and "00000000000000000000000000011111") or
                      (input(31) & input(31) & input(31) & input(31) &
                       input(31) & input(31) & input(31) & input(31) &
                       input(31) & input(31) & input(31) & input(31) & 
                       input(31) & input(31) & input(31) & input(31) &
                       input(31) & input(31) & input(31) & input(31) &
                       input(31) & input(31) & input(31) & input(31) &
                       input(31) & input(31) & input(31) & "00000");
          when "11100" =>
            output <= (temp and "00000000000000000000000000001111") or
                      (input(31) & input(31) & input(31) & input(31) &
                       input(31) & input(31) & input(31) & input(31) &
                       input(31) & input(31) & input(31) & input(31) & 
                       input(31) & input(31) & input(31) & input(31) &
                       input(31) & input(31) & input(31) & input(31) &
                       input(31) & input(31) & input(31) & input(31) &
                       input(31) & input(31) & input(31) & input(31) & 
                       "0000");
          when "11101" =>
            output <= (temp and "00000000000000000000000000000111") or
                      (input(31) & input(31) & input(31) & input(31) &
                       input(31) & input(31) & input(31) & input(31) &
                       input(31) & input(31) & input(31) & input(31) & 
                       input(31) & input(31) & input(31) & input(31) &
                       input(31) & input(31) & input(31) & input(31) &
                       input(31) & input(31) & input(31) & input(31) &
                       input(31) & input(31) & input(31) & input(31) &
                       input(31) & "000");
          when "11110" =>
            output <= (temp and "00000000000000000000000000000011") or
                      (input(31) & input(31) & input(31) & input(31) &
                       input(31) & input(31) & input(31) & input(31) &
                       input(31) & input(31) & input(31) & input(31) & 
                       input(31) & input(31) & input(31) & input(31) &
                       input(31) & input(31) & input(31) & input(31) &
                       input(31) & input(31) & input(31) & input(31) &
                       input(31) & input(31) & input(31) & input(31) &
                       input(31) & input(31) & "00");
          when "11111" =>
            output <= (temp and "00000000000000000000000000000001") or
                      (input(31) & input(31) & input(31) & input(31) &
                       input(31) & input(31) & input(31) & input(31) &
                       input(31) & input(31) & input(31) & input(31) & 
                       input(31) & input(31) & input(31) & input(31) &
                       input(31) & input(31) & input(31) & input(31) &
                       input(31) & input(31) & input(31) & input(31) &
                       input(31) & input(31) & input(31) & input(31) &
                       input(31) & input(31) & input(31) & "0");
          when others =>
            output <= temp;
        end case; -- count        
      when others =>
        shift <= count;
        output  <= temp;
    end case; -- mode
  end process;
    
-------------- 32bit barrel shifter
  ENCODE(17 downto 8) <= (others => '0');
  
  WORDA(17 downto 16) <= (others => '0'); 
  WORDB(17 downto 16) <= (others => '0'); 
  WORDC(17 downto 16) <= (others => '0'); 
  WORDD(17 downto 16) <= (others => '0');
  
  WORDA(15 downto 8) <= input ( 7 downto  0); 
  WORDB(15 downto 8) <= input (15 downto  8); 
  WORDC(15 downto 8) <= input (23 downto 16); 
  WORDD(15 downto 8) <= input (31 downto 24); 
  
  WORDA(7 downto 0) <= input (31 downto 24); 
  WORDB(7 downto 0) <= input ( 7 downto  0); 
  WORDC(7 downto 0) <= input (15 downto  8); 
  WORDD(7 downto 0) <= input (23 downto 16); 
  
  ONE_HOT:
  with SHIFT(2 downto 0) select
     encode(7 downto 0) <=
        "00000001" when "000",   --0
        "00000010" when "001",   --1
        "00000100" when "010",   --2
        "00001000" when "011",   --3
        "00010000" when "100",   --4
        "00100000" when "101",   --5
        "01000000" when "110",   --6
        "10000000" when others;  --7
  
  MULTA: MULT18X18 port map (A => WORDA, B => ENCODE, P => OUTA); 
  MULTB: MULT18X18 port map (A => WORDB, B => ENCODE, P => OUTB);
  MULTC: MULT18X18 port map (A => WORDC, B => ENCODE, P => OUTC);
  MULTD: MULT18X18 port map (A => WORDD, B => ENCODE, P => OUTD);
  
  MUXA:
  process(SHIFT, OUTA, OUTB, OUTC, OUTD)
  begin
     case SHIFT(4 downto 3) is
        when "00" => temp(7 downto 0) <= OUTA(15 downto 8);
        when "01" => temp(7 downto 0) <= OUTD(15 downto 8);
        when "10" => temp(7 downto 0) <= OUTC(15 downto 8);
        when others => temp(7 downto 0) <= OUTB(15 downto 8);
      end case;
  end process;
  
  MUXB:
  process(SHIFT, OUTA, OUTB, OUTC, OUTD)
  begin
     case SHIFT(4 downto 3) is
        when "00" => temp(15 downto 8) <= OUTB(15 downto 8);
        when "01" => temp(15 downto 8) <= OUTA(15 downto 8);
        when "10" => temp(15 downto 8) <= OUTD(15 downto 8);
        when others => temp(15 downto 8) <= OUTC(15 downto 8);
      end case;
  end process;
  
  MUXC:
  process(SHIFT, OUTA, OUTB, OUTC, OUTD)
  begin
     case SHIFT(4 downto 3) is
        when "00" => temp(23 downto 16) <= OUTC(15 downto 8);
        when "01" => temp(23 downto 16) <= OUTB(15 downto 8);
        when "10" => temp(23 downto 16) <= OUTA(15 downto 8);
        when others => temp(23 downto 16) <= OUTD(15 downto 8);
      end case;
  end process;
  
  MUXD:
  process(SHIFT, OUTA, OUTB, OUTC, OUTD)
  begin
     case SHIFT(4 downto 3) is
        when "00" => temp(31 downto 24) <= OUTD(15 downto 8);
        when "01" => temp(31 downto 24) <= OUTC(15 downto 8);
        when "10" => temp(31 downto 24) <= OUTB(15 downto 8);
        when others => temp(31 downto 24) <= OUTA(15 downto 8);
      end case;
  end process;

end behavioral;

----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity Multiplier is
    Port ( a : in   STD_LOGIC_VECTOR (31 downto 0);
           b : in   STD_LOGIC_VECTOR (31 downto 0);
           p : out  STD_LOGIC_VECTOR (63 downto 0));
end Multiplier;

architecture Behavioral of Multiplier is

  signal WORDAL : std_logic_vector(17 downto 0);
  signal WORDAH : std_logic_vector(17 downto 0);
  signal WORDBL : std_logic_vector(17 downto 0);
  signal WORDBH : std_logic_vector(17 downto 0);
  signal PROD0  : std_logic_vector(35 downto 0);
  signal PROD1  : std_logic_vector(35 downto 0);
  signal PROD2  : std_logic_vector(35 downto 0);
  signal PROD3  : std_logic_vector(35 downto 0);
  
begin

--                      A  *  B
--                          B(15.. 0) * A(15..0)
--              B(15.. 0) * A(31..16)
--              B(31..16) * A(15.. 0)
--  B(31..16) * A(31..16)
  WORDAL <= "00" & a(15 downto  0);
  WORDAH <= "00" & a(31 downto 16);
  WORDBL <= "00" & b(15 downto  0);
  WORDBH <= "00" & b(31 downto 16);
  
  MULTA: MULT18X18 port map (A => WORDAL, B => WORDBL, P => PROD0); 
  MULTB: MULT18X18 port map (A => WORDAH, B => WORDBL, P => PROD1); 
  MULTC: MULT18X18 port map (A => WORDAL, B => WORDBH, P => PROD2); 
  MULTD: MULT18X18 port map (A => WORDAH, B => WORDBH, P => PROD3); 

  p <= (x"00000000" & PROD0(31 downto 0)) +
       (x"0000" & PROD1(31 downto 0) & x"0000") +
		 (x"0000" & PROD2(31 downto 0) & x"0000") +
		 (PROD3(31 downto 0) & x"00000000");

end Behavioral;

--################################################################
--###### AT HERE THE Cortex CPU ##################################
--################################################################
--  #MAIN#
LIBRARY ieee;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

use work.CortexIinclude.ALL;

Library UNISIM;
use UNISIM.vcomponents.all;

ENTITY CortexI IS
   PORT(
     clk     : in  std_logic;
     rst     : in  std_logic;
     irq     : in  std_logic;
     addr    : out std_logic_vector(31 downto 0);
     wrl     : out std_logic;
     wrh     : out std_logic;
     datain  : in  std_logic_vector(15 downto 0);
     dataout : out std_logic_vector(15 downto 0)
   );
END CortexI;

ARCHITECTURE behavior OF CortexI IS

  constant STATE_FETCH  : std_logic_vector(6 downto 0) := "0000000";
  constant STATE_READ1  : std_logic_vector(6 downto 0) := "0000001";
  constant STATE_READ2  : std_logic_vector(6 downto 0) := "0000010";
  constant STATE_WRITE1 : std_logic_vector(6 downto 0) := "0000011";
  constant STATE_WRITE2 : std_logic_vector(6 downto 0) := "0000100";
  constant STATE_RD0L   : std_logic_vector(6 downto 0) := "0000101";
  constant STATE_RD0H   : std_logic_vector(6 downto 0) := "0000110";
  constant STATE_RD1L   : std_logic_vector(6 downto 0) := "0000111";
  constant STATE_RD1H   : std_logic_vector(6 downto 0) := "0001000";
  constant STATE_RD2L   : std_logic_vector(6 downto 0) := "0001001";
  constant STATE_RD2H   : std_logic_vector(6 downto 0) := "0001010";
  constant STATE_RD3L   : std_logic_vector(6 downto 0) := "0001011";
  constant STATE_RD3H   : std_logic_vector(6 downto 0) := "0001100";
  constant STATE_RD4L   : std_logic_vector(6 downto 0) := "0001101";
  constant STATE_RD4H   : std_logic_vector(6 downto 0) := "0001110";
  constant STATE_RD5L   : std_logic_vector(6 downto 0) := "0001111";
  constant STATE_RD5H   : std_logic_vector(6 downto 0) := "0010000";
  constant STATE_RD6L   : std_logic_vector(6 downto 0) := "0010001";
  constant STATE_RD6H   : std_logic_vector(6 downto 0) := "0010010";
  constant STATE_RD7L   : std_logic_vector(6 downto 0) := "0010011";
  constant STATE_RD7H   : std_logic_vector(6 downto 0) := "0010100";
  constant STATE_RDPL   : std_logic_vector(6 downto 0) := "0010101";
  constant STATE_RDPH   : std_logic_vector(6 downto 0) := "0010110";
  constant STATE_WR0L   : std_logic_vector(6 downto 0) := "0010111";
  constant STATE_WR0H   : std_logic_vector(6 downto 0) := "0011000";
  constant STATE_WR1L   : std_logic_vector(6 downto 0) := "0011001";
  constant STATE_WR1H   : std_logic_vector(6 downto 0) := "0011010";
  constant STATE_WR2L   : std_logic_vector(6 downto 0) := "0011011";
  constant STATE_WR2H   : std_logic_vector(6 downto 0) := "0011100";
  constant STATE_WR3L   : std_logic_vector(6 downto 0) := "0011101";
  constant STATE_WR3H   : std_logic_vector(6 downto 0) := "0011110";
  constant STATE_WR4L   : std_logic_vector(6 downto 0) := "0011111";
  constant STATE_WR4H   : std_logic_vector(6 downto 0) := "0100000";
  constant STATE_WR5L   : std_logic_vector(6 downto 0) := "0100001";
  constant STATE_WR5H   : std_logic_vector(6 downto 0) := "0100010";
  constant STATE_WR6L   : std_logic_vector(6 downto 0) := "0100011";
  constant STATE_WR6H   : std_logic_vector(6 downto 0) := "0100100";
  constant STATE_WR7L   : std_logic_vector(6 downto 0) := "0100101";
  constant STATE_WR7H   : std_logic_vector(6 downto 0) := "0100110";
  constant STATE_WRPL   : std_logic_vector(6 downto 0) := "0100111";
  constant STATE_WRPH   : std_logic_vector(6 downto 0) := "0101000";
  constant STATE_RESET0 : std_logic_vector(6 downto 0) := "0101001";
  constant STATE_RESET1 : std_logic_vector(6 downto 0) := "0101010";
  constant STATE_RESET2 : std_logic_vector(6 downto 0) := "0101011";
  constant STATE_RESET3 : std_logic_vector(6 downto 0) := "0101100";
  constant STATE_IRQ    : std_logic_vector(6 downto 0) := "0101101";
  constant STATE_IRQ1   : std_logic_vector(6 downto 0) := "0101110";
  constant STATE_IRQ2   : std_logic_vector(6 downto 0) := "0101111";
  constant STATE_IRQ3   : std_logic_vector(6 downto 0) := "0110000";
  constant STATE_IRQ4   : std_logic_vector(6 downto 0) := "0110001";
  constant STATE_IRQ5   : std_logic_vector(6 downto 0) := "0110010";
  constant STATE_IRQ6   : std_logic_vector(6 downto 0) := "0110011";
  constant STATE_IRQ7   : std_logic_vector(6 downto 0) := "0110100";
  constant STATE_IRQ8   : std_logic_vector(6 downto 0) := "0110101";
  constant STATE_IRQ9   : std_logic_vector(6 downto 0) := "0110110";
  constant STATE_IRQ10  : std_logic_vector(6 downto 0) := "0110111";
  constant STATE_IRQ11  : std_logic_vector(6 downto 0) := "0111000";
  constant STATE_IRQ12  : std_logic_vector(6 downto 0) := "0111001";
  constant STATE_IRQ13  : std_logic_vector(6 downto 0) := "0111010";
  constant STATE_IRQ14  : std_logic_vector(6 downto 0) := "0111011";
  constant STATE_IRQ15  : std_logic_vector(6 downto 0) := "0111100";
  constant STATE_IRQ16  : std_logic_vector(6 downto 0) := "0111101";
  constant STATE_IRQ17  : std_logic_vector(6 downto 0) := "0111110";
  constant STATE_RET    : std_logic_vector(6 downto 0) := "0111111";
  constant STATE_RET1   : std_logic_vector(6 downto 0) := "1000000";
  constant STATE_RET2   : std_logic_vector(6 downto 0) := "1000001";
  constant STATE_RET3   : std_logic_vector(6 downto 0) := "1000010";
  constant STATE_RET4   : std_logic_vector(6 downto 0) := "1000011";
  constant STATE_RET5   : std_logic_vector(6 downto 0) := "1000100";
  constant STATE_RET6   : std_logic_vector(6 downto 0) := "1000101";
  constant STATE_RET7   : std_logic_vector(6 downto 0) := "1000110";
  constant STATE_RET8   : std_logic_vector(6 downto 0) := "1000111";
  constant STATE_RET9   : std_logic_vector(6 downto 0) := "1001000";
  constant STATE_RET10  : std_logic_vector(6 downto 0) := "1001001";
  constant STATE_RET11  : std_logic_vector(6 downto 0) := "1001010";
  constant STATE_RET12  : std_logic_vector(6 downto 0) := "1001011";
  constant STATE_RET13  : std_logic_vector(6 downto 0) := "1001100";
  constant STATE_RET14  : std_logic_vector(6 downto 0) := "1001101";
  constant STATE_RET15  : std_logic_vector(6 downto 0) := "1001110";
  constant STATE_RET16  : std_logic_vector(6 downto 0) := "1001111";
  constant STATE_RET17  : std_logic_vector(6 downto 0) := "1010000";

  constant CODE_LSL1   : std_logic_vector(6 downto 0) := "0000000";
  constant CODE_LSR1   : std_logic_vector(6 downto 0) := "0000001";
  constant CODE_ASR1   : std_logic_vector(6 downto 0) := "0000010";
  constant CODE_ADD1   : std_logic_vector(6 downto 0) := "0000011";
  constant CODE_SUB1   : std_logic_vector(6 downto 0) := "0000100";
  constant CODE_ADD2   : std_logic_vector(6 downto 0) := "0000110";
  constant CODE_SUB2   : std_logic_vector(6 downto 0) := "0000111";
  constant CODE_MOV1   : std_logic_vector(6 downto 0) := "0001000";
  constant CODE_CMP1   : std_logic_vector(6 downto 0) := "0001001";
  constant CODE_ADD3   : std_logic_vector(6 downto 0) := "0001010";
  constant CODE_SUB3   : std_logic_vector(6 downto 0) := "0001011";
  constant CODE_AND1   : std_logic_vector(6 downto 0) := "0001100";
  constant CODE_EOR1   : std_logic_vector(6 downto 0) := "0001101";
  constant CODE_LSL2   : std_logic_vector(6 downto 0) := "0001110";
  constant CODE_LSR2   : std_logic_vector(6 downto 0) := "0001111";
  constant CODE_ASR2   : std_logic_vector(6 downto 0) := "0010000";
  constant CODE_ADC1   : std_logic_vector(6 downto 0) := "0010001";
  constant CODE_SBC1   : std_logic_vector(6 downto 0) := "0010010";
  constant CODE_ROR1   : std_logic_vector(6 downto 0) := "0010011";
  constant CODE_TST1   : std_logic_vector(6 downto 0) := "0010100";
  constant CODE_NEG1   : std_logic_vector(6 downto 0) := "0010101";
  constant CODE_CMP2   : std_logic_vector(6 downto 0) := "0010110";
  constant CODE_CMN1   : std_logic_vector(6 downto 0) := "0010111";
  constant CODE_ORR1   : std_logic_vector(6 downto 0) := "0011000";
  constant CODE_MUL1   : std_logic_vector(6 downto 0) := "0011001";
  constant CODE_BIC1   : std_logic_vector(6 downto 0) := "0011010";
  constant CODE_MVN1   : std_logic_vector(6 downto 0) := "0011011";
  constant CODE_ADD4   : std_logic_vector(6 downto 0) := "0011100";
  constant CODE_CMP3   : std_logic_vector(6 downto 0) := "0011101";
  constant CODE_CPY1   : std_logic_vector(6 downto 0) := "0011110";
  constant CODE_BX1    : std_logic_vector(6 downto 0) := "0011111";
  constant CODE_LDR1   : std_logic_vector(6 downto 0) := "0100000";
  constant CODE_STR1   : std_logic_vector(6 downto 0) := "0100001";
  constant CODE_STRH1  : std_logic_vector(6 downto 0) := "0100010";
  constant CODE_STRB1  : std_logic_vector(6 downto 0) := "0100011";
  constant CODE_LDRSB1 : std_logic_vector(6 downto 0) := "0100100";
  constant CODE_LDR2   : std_logic_vector(6 downto 0) := "0100101";
  constant CODE_LDRH1  : std_logic_vector(6 downto 0) := "0100110";
  constant CODE_LDRB1  : std_logic_vector(6 downto 0) := "0100111";
  constant CODE_LDRSH1 : std_logic_vector(6 downto 0) := "0101000";
  constant CODE_STR2   : std_logic_vector(6 downto 0) := "0101001";
  constant CODE_LDR3   : std_logic_vector(6 downto 0) := "0101010";
  constant CODE_STRB2  : std_logic_vector(6 downto 0) := "0101011";
  constant CODE_LDRB2  : std_logic_vector(6 downto 0) := "0101100";
  constant CODE_STRH2  : std_logic_vector(6 downto 0) := "0101101";
  constant CODE_LDRH2  : std_logic_vector(6 downto 0) := "0101110";
  constant CODE_STR3   : std_logic_vector(6 downto 0) := "0101111";
  constant CODE_LDR4   : std_logic_vector(6 downto 0) := "0110000";
  constant CODE_ADD5   : std_logic_vector(6 downto 0) := "0110001";
  constant CODE_ADD6   : std_logic_vector(6 downto 0) := "0110010";
  constant CODE_ADD7   : std_logic_vector(6 downto 0) := "0110011";
  constant CODE_SUB4   : std_logic_vector(6 downto 0) := "0110100";
  constant CODE_SXTH1  : std_logic_vector(6 downto 0) := "0110101";
  constant CODE_SXTB1  : std_logic_vector(6 downto 0) := "0110110";
  constant CODE_UXTH1  : std_logic_vector(6 downto 0) := "0110111";
  constant CODE_UXTB1  : std_logic_vector(6 downto 0) := "0111000";
  constant CODE_PUSH1  : std_logic_vector(6 downto 0) := "0111001";
  constant CODE_POP1   : std_logic_vector(6 downto 0) := "0111010";
  constant CODE_STMIA1 : std_logic_vector(6 downto 0) := "0111011";
  constant CODE_LDMIA1 : std_logic_vector(6 downto 0) := "0111100";
  constant CODE_BCC1   : std_logic_vector(6 downto 0) := "0111101";
  constant CODE_SWI1   : std_logic_vector(6 downto 0) := "0111110";
  constant CODE_B1     : std_logic_vector(6 downto 0) := "0111111";
  constant CODE_BLX1   : std_logic_vector(6 downto 0) := "1000000";
  constant CODE_BLX2   : std_logic_vector(6 downto 0) := "1000001";
  constant CODE_BL1    : std_logic_vector(6 downto 0) := "1000010";
  constant CODE_NOP    : std_logic_vector(6 downto 0) := "1000011";  
  constant CODE_XXX    : std_logic_vector(6 downto 0) := "1111111";
  
  constant N_FLAG : integer := 31;
  constant Z_FLAG : integer := 30;
  constant C_FLAG : integer := 29;
  constant V_FLAG : integer := 28;

  constant WRITE_B_LOW   : std_logic_vector(3 downto 0) := "0000";
  constant WRITE_B_HIGH  : std_logic_vector(3 downto 0) := "0001";
  constant WRITE_H_BOTH  : std_logic_vector(3 downto 0) := "0010";
  constant WRITE_H_LOW   : std_logic_vector(3 downto 0) := "0011";
  constant WRITE_H_HIGH  : std_logic_vector(3 downto 0) := "0100";
  constant WRITE_W_LOW   : std_logic_vector(3 downto 0) := "0101";
  constant WRITE_W_HIGH  : std_logic_vector(3 downto 0) := "0110";
  constant WRITE_W_LOWB  : std_logic_vector(3 downto 0) := "0111";
  constant WRITE_W_MID   : std_logic_vector(3 downto 0) := "1000";
  constant WRITE_W_HIGHB : std_logic_vector(3 downto 0) := "1001";

  constant ADDR_PC : std_logic_vector(1 downto 0) := "00";
  constant ADDR_SP : std_logic_vector(1 downto 0) := "01";
  constant ADDR_RS : std_logic_vector(1 downto 0) := "10";
  constant ADDR_RT : std_logic_vector(1 downto 0) := "11";


  type typeRegisters is array (0 to 15) of std_logic_vector(31 downto 0);
  
  signal theRegisters : typeRegisters;
  signal cpsrRegister : std_logic_Vector(31 downto  0);
  signal cpuState     : std_logic_vector( 6 downto  0);
  signal opcode       : std_logic_vector(15 downto  0);
  signal addrMux      : std_logic_vector( 1 downto  0);
  signal address      : std_logic_vector(31 downto  0);
  signal irq_d        : std_logic;
  signal irqRequest   : std_logic;
  signal writeL       : std_logic;
  signal writeH       : std_logic;
  signal shiftResult  : std_logic_vector(31 downto  0);
  signal cyShiftOut   : std_logic;
  signal shiftMode    : std_logic_vector( 2 downto  0);
  signal shiftCount   : std_logic_vector( 4 downto  0);
  signal shiftIn      : std_logic_vector(31 downto  0);
  signal LDMread      : std_logic_vector( 7 downto  0);

  signal unitControl  : std_logic_vector( 6 downto  0);
  signal unitControl2 : std_logic_vector( 6 downto  0);
  
  signal factor1      : std_logic_vector(31 downto  0);
  signal factor2      : std_logic_vector(31 downto  0);
  signal product      : std_logic_vector(63 downto  0);
  
  signal branch       : std_logic;
  
  signal datain20  : integer range 0 to 15;
  signal datain53  : integer range 0 to 15;
  signal datain86  : integer range 0 to 15;
  signal datain108 : integer range 0 to 15;

  signal opcode20  : integer range 0 to 15;
  signal opcode53  : integer range 0 to 15;
  signal opcode86  : integer range 0 to 15;
  signal opcode108 : integer range 0 to 15;
  
  component bshifter Port (
           din   : in  std_logic_vector(31 downto 0);
           size  : in  std_logic_vector( 1 downto 0);
           mode  : in  std_logic_vector( 2 downto 0);
           count : in  std_logic_vector( 4 downto 0);
           cyOut : out std_logic;
           dout  : out std_logic_vector(31 downto 0)
         );
  end component;

  component Multiplier   -- 32 x 32 = 64 bit unsigned product multiplier
    port(a    : in  std_logic_vector(31 downto 0);  -- multiplicand
         b    : in  std_logic_vector(31 downto 0);  -- multiplier
         p    : out std_logic_vector(63 downto 0)); -- product
  end component;
  
begin

  datain20  <= conv_integer("0" & datain( 2 downto 0));
  datain53  <= conv_integer("0" & datain( 5 downto 3));
  datain86  <= conv_integer("0" & datain( 8 downto 6));
  datain108 <= conv_integer("0" & datain(10 downto 8));
  opcode20  <= conv_integer("0" & opcode( 2 downto 0));
  opcode53  <= conv_integer("0" & opcode( 5 downto 3));
  opcode86  <= conv_integer("0" & opcode( 8 downto 6));
  opcode108 <= conv_integer("0" & opcode(10 downto 8));
  
--#################################################################
--  barrel shifter
  shiftMode <= BS_LSL when (unitControl = CODE_LSL1) or (unitControl = CODE_LSL2) else
               BS_LSR when (unitControl = CODE_LSR1) or (unitControl = CODE_LSR2) else
               BS_ASR when (unitControl = CODE_ASR1) or (unitControl = CODE_ASR2) else
               BS_ROR;
  shiftCount <= datain(10 downto 6)
       when (unitControl = CODE_LSL1) or (unitControl = CODE_LSR1) or (unitControl = CODE_ASR1) else
            theRegisters(datain53)(4 downto 0);
  shiftIn <= theRegisters(datain53)
       when (unitControl = CODE_LSL1) or (unitControl = CODE_LSR1) or (unitControl = CODE_ASR1) else
            theRegisters(datain20);
  barrelShifter :  bshifter Port map(
           din   => shiftIn,     --: in  std_logic_vector(31 downto 0);
           size  => SIZE_32BIT,  --: in  std_logic_vector( 1 downto 0);
           mode  => shiftMode,   --: in  std_logic_vector( 2 downto 0);
           count => shiftCount,  --: in  std_logic_vector( 4 downto 0);
           cyOut => cyShiftOut,  --: out std_logic;
           dout  => shiftResult  --: out std_logic_vector(31 downto 0)
         );
  
--#################################################################
--  multiplier
  multip : Multiplier Port map(
           a => factor1,
           b => factor2,
           p => product
         );
  factor1 <= theRegisters(datain20);
  factor2 <= theRegisters(datain53);
  
--#################################################################
-- decodes instruction bits to control bits for other ARMT units
  process(datain)
  begin
    case datain(15 downto 11) is
      when "00000" =>    unitControl <= CODE_LSL1;
      when "00001" =>    unitControl <= CODE_LSR1;
      when "00010" =>    unitControl <= CODE_ASR1;
      when "00011" =>
        case datain(10 downto 9) is
          when "00" =>   unitControl <= CODE_ADD1;
          when "01" =>   unitControl <= CODE_SUB1;
          when "10" =>   unitControl <= CODE_ADD2;
          when "11" =>   unitControl <= CODE_SUB2;
          when others => unitControl <= CODE_XXX;
        end case;
      when "00100" =>    unitControl <= CODE_MOV1;
      when "00101" =>    unitControl <= CODE_CMP1;
      when "00110" =>    unitControl <= CODE_ADD3;
      when "00111" =>    unitControl <= CODE_SUB3;
      when "01000" =>
        if datain(10) = '0' then
          case datain(9 downto 6) is
            when "0000" => unitControl <= CODE_AND1;
            when "0001" => unitControl <= CODE_EOR1;
            when "0010" => unitControl <= CODE_LSL2;
            when "0011" => unitControl <= CODE_LSR2;
            when "0100" => unitControl <= CODE_ASR2;
            when "0101" => unitControl <= CODE_ADC1;
            when "0110" => unitControl <= CODE_SBC1;
            when "0111" => unitControl <= CODE_ROR1;
            when "1000" => unitControl <= CODE_TST1;
            when "1001" => unitControl <= CODE_NEG1;
            when "1010" => unitControl <= CODE_CMP2;
            when "1011" => unitControl <= CODE_CMN1;
            when "1100" => unitControl <= CODE_ORR1;
            when "1101" => unitControl <= CODE_MUL1;
            when "1110" => unitControl <= CODE_BIC1;
            when "1111" => unitControl <= CODE_MVN1;
            when others => unitControl <= CODE_XXX;
          end case;
        else
          case datain(9 downto 8) is
            when "00" => unitControl <= CODE_ADD4;
            when "01" => unitControl <= CODE_CMP3;
            when "10" => unitControl <= CODE_CPY1; -- MOV
            when "11" => unitControl <= CODE_BX1;
            when others => unitControl <= CODE_XXX;
          end case;
        end if;
      when "01001" =>    unitControl <= CODE_LDR1;
      when "01010" =>
        case datain(10 downto 9) is
          when "00" => unitControl <= CODE_STR1;
          when "01" => unitControl <= CODE_STRH1;
          when "10" => unitControl <= CODE_STRB1;
          when "11" => unitControl <= CODE_LDRSB1;
          when others =>     unitControl <= CODE_XXX;
        end case;
      when "01011" =>
        case datain(10 downto 9) is
          when "00" => unitControl <= CODE_LDR2;
          when "01" => unitControl <= CODE_LDRH1;
          when "10" => unitControl <= CODE_LDRB1;
          when "11" => unitControl <= CODE_LDRSH1;
          when others =>     unitControl <= CODE_XXX;
        end case;
      when "01100" =>    unitControl <= CODE_STR2;
      when "01101" =>    unitControl <= CODE_LDR3;
      when "01110" =>    unitControl <= CODE_STRB2;
      when "01111" =>    unitControl <= CODE_LDRB2;
      when "10000" =>    unitControl <= CODE_STRH2;
      when "10001" =>    unitControl <= CODE_LDRH2;
      when "10010" =>    unitControl <= CODE_STR3;
      when "10011" =>    unitControl <= CODE_LDR4;
      when "10100" =>    unitControl <= CODE_ADD5;
      when "10101" =>    unitControl <= CODE_ADD6;
      when "10110" =>
        case datain(10 downto 7) is
          when "0000" => unitControl <= CODE_ADD7;
          when "0001" => unitControl <= CODE_SUB4;
          when "0100" =>
            if datain(6) = '0' then
                         unitControl <= CODE_SXTH1;
            else
                         unitControl <= CODE_SXTB1;
            end if;
          when "0101" =>
            if datain(6) = '0' then
                         unitControl <= CODE_UXTH1;
            else
                         unitControl <= CODE_UXTB1;
            end if;
          when "1000" | "1001" | "1010" | "1011" =>
                         unitControl <= CODE_PUSH1;  
          when others => unitControl <= CODE_XXX;
        end case;
      when "10111" =>
        if datain(10 downto 8) = "100" or datain(10 downto 8) = "101" then
                         unitControl <= CODE_POP1;  
        else
                         unitControl <= CODE_NOP;
        end if;
      when "11000" =>    unitControl <= CODE_STMIA1;
      when "11001" =>    unitControl <= CODE_LDMIA1;
      when "11010" | "11011" => 
--        if datain(11 downto 8) = "1111" then
--                         unitControl <= CODE_SWI1;
--        else
                         unitControl <= CODE_BCC1;
--        end if;
      when "11100" =>    unitControl <= CODE_B1;
      when "11101" =>    unitControl <= CODE_BLX1;
      when "11110" =>    unitControl <= CODE_BLX2;
      when "11111" =>    unitControl <= CODE_BL1;
      when others =>     unitControl <= CODE_XXX;
    end case; -- datain(15 downto 11)
  end process;
  
  wrl  <= writeL;
  wrH  <= writeH;
--#################################################################
--      address bus multiplexer
  addr <= theRegisters(15) when addrMux = ADDR_PC else
          theRegisters(13) when addrMux = ADDR_SP else
          address;

--#################################################################
--      check flags for branch
  process(datain, cpsrRegister)
  begin
    case datain(11 downto 8) is
      when "0000" => -- EQ
        if cpsrRegister(Z_FLAG) = '1' then
          branch <= '1';
        else
          branch <= '0';
        end if;
      when "0001" => -- NE
        if cpsrRegister(Z_FLAG) = '0' then
          branch <= '1';
        else
          branch <= '0';
        end if;
      when "0010" => -- CS
        if cpsrRegister(C_FLAG) = '1' then
          branch <= '1';
        else
          branch <= '0';
        end if;
      when "0011" => -- CC
        if cpsrRegister(C_FLAG) = '0' then
          branch <= '1';
        else
          branch <= '0';
        end if;
      when "0100" => -- MI
        if cpsrRegister(N_FLAG) = '1' then
          branch <= '1';
        else
          branch <= '0';
        end if;
      when "0101" => -- PL
        if cpsrRegister(N_FLAG) = '0' then
          branch <= '1';
        else
          branch <= '0';
        end if;
      when "0110" => -- VS
        if cpsrRegister(V_FLAG) = '1' then
          branch <= '1';
        else
          branch <= '0';
        end if;
      when "0111" => -- VC
        if cpsrRegister(V_FLAG) = '0' then
          branch <= '1';
        else
          branch <= '0';
        end if;
      when "1000" => -- HI
        if cpsrRegister(C_FLAG) = '1' and cpsrRegister(Z_FLAG) = '0' then
          branch <= '1';
        else
          branch <= '0';
        end if;
      when "1001" => -- LS
        if cpsrRegister(C_FLAG) = '0' or cpsrRegister(Z_FLAG) = '1' then
          branch <= '1';
        else
          branch <= '0';
        end if;
      when "1010" => -- GE
        if cpsrRegister(N_FLAG) = cpsrRegister(V_FLAG) then
          branch <= '1';
        else
          branch <= '0';
        end if;
      when "1011" => -- LT
        if cpsrRegister(N_FLAG) /= cpsrRegister(V_FLAG) then
          branch <= '1';
        else
          branch <= '0';
        end if;
      when "1100" => -- GT
        if cpsrRegister(Z_FLAG) = '0' and (cpsrRegister(N_FLAG) = cpsrRegister(V_FLAG)) then
          branch <= '1';
        else
          branch <= '0';
        end if;
      when "1101" => -- LE
        if cpsrRegister(Z_FLAG) = '1' or (cpsrRegister(N_FLAG) /= cpsrRegister(V_FLAG)) then
          branch <= '1';
        else
          branch <= '0';
        end if;
      when "1110" => -- AL
        branch <= '1';
      when others =>
        branch <= '0';
    end case; -- datain(11 downto 8)
  end process;

--#################################################################  
-- ARMT cpu main state machine
  process(rst, clk)
    variable tres : std_logic_vector(32 downto 0);
    variable tsum : std_logic_vector(31 downto 0);
    variable op1  : std_logic;
    variable op2  : std_logic;
    variable opr  : std_logic;
  begin
    if rising_edge(clk) then
      if rst = '0' then
        theRegisters( 0) <= x"00000000";
        theRegisters( 1) <= x"00000000";
        theRegisters( 2) <= x"00000000";
        theRegisters( 3) <= x"00000000";
        theRegisters( 4) <= x"00000000";
        theRegisters( 5) <= x"00000000";
        theRegisters( 6) <= x"00000000";
        theRegisters( 7) <= x"00000000";
        theRegisters( 8) <= x"00000000";
        theRegisters( 9) <= x"00000000";
        theRegisters(10) <= x"00000000";
        theRegisters(11) <= x"00000000";
        theRegisters(12) <= x"00000000";
        theRegisters(13) <= x"00000000"; -- SP
        theRegisters(14) <= x"00000000"; -- LR
        theRegisters(15) <= x"00000000"; -- PC
        cpsrRegister     <= x"00000000";
        cpuState <= STATE_RESET0;
        writeL   <= '1';
        writeH   <= '1';
        LDMread  <= x"00";
        addrMux  <= ADDR_PC;
        address  <= x"00000000";
        irq_d    <= '1';
        irqRequest <= '0';
        unitControl2 <= "0000000";
      else
        irq_d <= irq;
        if (irq = '0') and (irq_d = '1') then --and (flagI = '0') then -- irq falling edge ?
          irqRequest <= '1';
        end if;
        case cpuState is
          when STATE_RESET0 => -- ##################################################
            theRegisters(13)(15 downto 0) <= datain;  -- STACK low
            theRegisters(15) <= theRegisters(15) + 2;
            cpuState <= STATE_RESET1;
          when STATE_RESET1 => -- ##################################################
            theRegisters(13)(31 downto 16) <= datain; -- STACK high
            theRegisters(15) <= theRegisters(15) + 2;
            cpuState <= STATE_RESET2;
          when STATE_RESET2 => -- ##################################################
            address(15 downto 0) <= datain and x"FFFE"; -- PC low make even address
            theRegisters(15) <= theRegisters(15) + 2;
            cpuState <= STATE_RESET3;
          when STATE_RESET3 => -- ##################################################
            theRegisters(15) <= datain & address(15 downto 0); -- PC high
            cpuState <= STATE_FETCH;
          when STATE_IRQ =>  -- ####################################################
            theRegisters(13) <= theRegisters(13) - 2;
            dataout  <= cpsrRegister(15 downto 0);
            cpuState <= STATE_IRQ1;
          when STATE_IRQ1 =>  -- ####################################################
            theRegisters(13) <= theRegisters(13) - 2;
            dataout  <= theRegisters(15)(31 downto 16);
            cpuState <= STATE_IRQ2;
          when STATE_IRQ2 =>  -- ####################################################
            theRegisters(13) <= theRegisters(13) - 2;
            dataout  <= theRegisters(15)(15 downto 0);
            cpuState <= STATE_IRQ3;
          when STATE_IRQ3 =>  -- ####################################################
            theRegisters(13) <= theRegisters(13) - 2;
            dataout  <= theRegisters(14)(31 downto 16); -- ??? FFFFFFF9
            cpuState <= STATE_IRQ4;
          when STATE_IRQ4 =>  -- ####################################################
            theRegisters(13) <= theRegisters(13) - 2;
            dataout  <= theRegisters(14)(15 downto 0); -- ??? FFFFFFF9
            cpuState <= STATE_IRQ5;
          when STATE_IRQ5 =>  -- ####################################################
            theRegisters(13) <= theRegisters(13) - 2;
            dataout  <= theRegisters(12)(31 downto 16);
            cpuState <= STATE_IRQ6;
          when STATE_IRQ6 =>  -- ####################################################
            theRegisters(13) <= theRegisters(13) - 2;
            dataout  <= theRegisters(12)(15 downto 0);
            cpuState <= STATE_IRQ7;
          when STATE_IRQ7 =>  -- ####################################################
            theRegisters(13) <= theRegisters(13) - 2;
            dataout  <= theRegisters(3)(31 downto 16);
            cpuState <= STATE_IRQ8;
          when STATE_IRQ8 =>  -- ####################################################
            theRegisters(13) <= theRegisters(13) - 2;
            dataout  <= theRegisters(3)(15 downto 0);
            cpuState <= STATE_IRQ9;
          when STATE_IRQ9 =>  -- ####################################################
            theRegisters(13) <= theRegisters(13) - 2;
            dataout  <= theRegisters(2)(31 downto 16);
            cpuState <= STATE_IRQ10;
          when STATE_IRQ10 =>  -- ####################################################
            theRegisters(13) <= theRegisters(13) - 2;
            dataout  <= theRegisters(2)(15 downto 0);
            cpuState <= STATE_IRQ11;
          when STATE_IRQ11 =>  -- ####################################################
            theRegisters(13) <= theRegisters(13) - 2;
            dataout  <= theRegisters(1)(31 downto 16);
            cpuState <= STATE_IRQ12;
          when STATE_IRQ12 =>  -- ####################################################
            theRegisters(13) <= theRegisters(13) - 2;
            dataout  <= theRegisters(1)(15 downto 0);
            cpuState <= STATE_IRQ13;
          when STATE_IRQ13 =>  -- ####################################################
            theRegisters(13) <= theRegisters(13) - 2;
            dataout  <= theRegisters(0)(31 downto 16);
            cpuState <= STATE_IRQ14;
          when STATE_IRQ14 =>  -- ####################################################
            theRegisters(13) <= theRegisters(13) - 2;
            dataout  <= theRegisters(0)(15 downto 0);
            cpuState <= STATE_IRQ15;
          when STATE_IRQ15 =>  -- ####################################################
            writeL <= '1';
            writeH <= '1';
            theRegisters(14) <= x"FFFFFFF9"; -- exception return value
            address <= x"00000008";  -- NMI vector
            addrMux <= ADDR_RS;
            cpuState <= STATE_IRQ16;
          when STATE_IRQ16 =>  -- ###################################################
            theRegisters(15)(15 downto 0) <= datain and x"FFFE";
            address <= address + 2;
            cpuState <= STATE_IRQ17;
          when STATE_IRQ17 =>  -- ###################################################
            theRegisters(15)(31 downto 16) <= datain;
            addrMux <= ADDR_PC;
            cpuState <= STATE_FETCH;
          when STATE_RET =>  -- #####################################################
            addrMux <= ADDR_SP;
            cpuState <= STATE_RET1;
          when STATE_RET1 => -- #####################################################
            theRegisters(0)(15 downto 0) <= datain;
            theRegisters(13) <= theRegisters(13) + 2;
            cpuState <= STATE_RET2;
          when STATE_RET2 => -- #####################################################
            theRegisters(0)(31 downto 16) <= datain;
            theRegisters(13) <= theRegisters(13) + 2;
            cpuState <= STATE_RET3;
          when STATE_RET3 => -- #####################################################
            theRegisters(1)(15 downto 0) <= datain;
            theRegisters(13) <= theRegisters(13) + 2;
            cpuState <= STATE_RET4;
          when STATE_RET4 => -- #####################################################
            theRegisters(1)(31 downto 16) <= datain;
            theRegisters(13) <= theRegisters(13) + 2;
            cpuState <= STATE_RET5;
          when STATE_RET5 => -- #####################################################
            theRegisters(2)(15 downto 0) <= datain;
            theRegisters(13) <= theRegisters(13) + 2;
            cpuState <= STATE_RET6;
          when STATE_RET6 => -- #####################################################
            theRegisters(2)(31 downto 16) <= datain;
            theRegisters(13) <= theRegisters(13) + 2;
            cpuState <= STATE_RET7;
          when STATE_RET7 => -- #####################################################
            theRegisters(3)(15 downto 0) <= datain;
            theRegisters(13) <= theRegisters(13) + 2;
            cpuState <= STATE_RET8;
          when STATE_RET8 => -- #####################################################
            theRegisters(3)(31 downto 16) <= datain;
            theRegisters(13) <= theRegisters(13) + 2;
            cpuState <= STATE_RET9;
          when STATE_RET9 => -- #####################################################
            theRegisters(12)(15 downto 0) <= datain;
            theRegisters(13) <= theRegisters(13) + 2;
            cpuState <= STATE_RET10;
          when STATE_RET10 => -- #####################################################
            theRegisters(12)(31 downto 16) <= datain;
            theRegisters(13) <= theRegisters(13) + 2;
            cpuState <= STATE_RET11;
          when STATE_RET11 => -- #####################################################
            theRegisters(14)(15 downto 0) <= datain;
            theRegisters(13) <= theRegisters(13) + 2;
            cpuState <= STATE_RET12;
          when STATE_RET12 => -- #####################################################
            theRegisters(14)(31 downto 16) <= datain;
            theRegisters(13) <= theRegisters(13) + 2;
            cpuState <= STATE_RET13;
          when STATE_RET13 => -- #####################################################
            theRegisters(15)(15 downto 0) <= datain;
            theRegisters(13) <= theRegisters(13) + 2;
            cpuState <= STATE_RET14;
          when STATE_RET14 => -- #####################################################
            theRegisters(15)(31 downto 16) <= datain;
            theRegisters(13) <= theRegisters(13) + 2;
            cpuState <= STATE_RET15;
          when STATE_RET15 => -- #####################################################
            cpsrRegister(15 downto 0) <= datain;
            theRegisters(13) <= theRegisters(13) + 2;
            cpuState <= STATE_RET16;
          when STATE_RET16 => -- #####################################################
            cpsrRegister(31 downto 16) <= datain;
            theRegisters(13) <= theRegisters(13) + 2;
            addrMux  <= ADDR_PC;
            cpuState <= STATE_FETCH;  
          when STATE_FETCH => -- ###################################################
            unitControl2 <= unitControl;
            opcode       <= datain;
            if irqrequest = '1' then -- irq ???
              irqrequest <= '0';
              cpuState <= STATE_IRQ;
              theRegisters(13) <= theRegisters(13) - 2;
              addrMux  <= ADDR_SP;
              dataout  <= cpsrRegister(31 downto 16);
              writeL   <= '0';
              writeH   <= '0';
            else
              case unitControl is
                when CODE_LSL1 | CODE_LSR1 | CODE_ASR1 |
                     CODE_LSL2 | CODE_LSR2 | CODE_ASR2 |
                     CODE_ROR1 =>
                  theRegisters(datain20) <= shiftResult;
                  cpsrRegister(N_FLAG) <= shiftResult(31);
                  if shiftResult = 0 then
                    cpsrRegister(Z_FLAG) <= '1';
                  else
                    cpsrRegister(Z_FLAG) <= '0';
                  end if;
                  cpsrRegister(C_FLAG) <= cyShiftOut;
                  theRegisters(15) <= theRegisters(15) + 2;
                when CODE_CPY1 => -- Rd = Rm
                  if (datain(7) & datain(2 downto 0) = "1111") then
                    theRegisters(conv_integer(datain(7) & datain(2 downto 0))) <=
                    theRegisters(conv_integer(datain(6 downto 3)));
                  else
                    theRegisters(conv_integer(datain(7) & datain(2 downto 0))) <=
                    theRegisters(conv_integer(datain(6 downto 3)));
                    theRegisters(15) <= theRegisters(15) + 2;
                  end if;
                when CODE_ADD4 => -- Rd = Rd + Rm
                  if (datain(7) & datain(2 downto 0) = "1111") then
                    theRegisters(conv_integer(datain(7) & datain(2 downto 0))) <=
                                theRegisters(conv_integer(datain(7) & datain(2 downto 0))) +
                                theRegisters(conv_integer(datain(6 downto 3)));
                  else
                    theRegisters(conv_integer(datain(7) & datain(2 downto 0))) <=
                                theRegisters(conv_integer(datain(7) & datain(2 downto 0))) +
                                theRegisters(conv_integer(datain(6 downto 3)));
                    theRegisters(15) <= theRegisters(15) + 2;
                  end if;
                when CODE_ADD6 => -- Rn = SP + imm
                  theRegisters(datain108) <=
                                theRegisters(13) +
                                (x"00000" & "00" & datain(7 downto 0) & "00");
                  theRegisters(15) <= theRegisters(15) + 2;
                when CODE_ADD7 => -- SP = SP + imm
                  theRegisters(13) <= theRegisters(13) +
                                    (x"00000" & "000" & datain(6 downto 0) & "00");
                  theRegisters(15) <= theRegisters(15) + 2;
                when CODE_SUB4 => -- SP = SP - imm
                  theRegisters(13) <= theRegisters(13) -
                                    (x"00000" & "000" & datain(6 downto 0) & "00");
                  theRegisters(15) <= theRegisters(15) + 2;
                when CODE_ADD1 =>
                  tres := ("0" & theRegisters(datain53)) +
                          ("0" & theRegisters(datain86));
                  theRegisters(datain20) <=
                          theRegisters(datain53) +
                          theRegisters(datain86);
                  cpsrRegister(C_FLAG) <= tres(32);
                  cpsrRegister(N_FLAG) <= tres(31);
                  if tres(31 downto 0) = 0 then
                    cpsrRegister(Z_FLAG) <= '1';
                  else
                    cpsrRegister(Z_FLAG) <= '0';
                  end if;
                  op1 := theRegisters(datain53)(31);
                  op2 := theRegisters(datain86)(31);
                  opr := tres(31);
                  cpsrRegister(V_FLAG) <= (op1 and op2 and not opr) or
                                          (not op1 and not op2 and opr);
                  theRegisters(15) <= theRegisters(15) + 2;
                when CODE_SUB1 =>
                  tres := ("0" & theRegisters(datain53)) -
                          ("0" & theRegisters(datain86));
                  theRegisters(datain20) <=
                          theRegisters(datain53) -
                          theRegisters(datain86);
                  cpsrRegister(C_FLAG) <= not tres(32);
                  cpsrRegister(N_FLAG) <= tres(31);
                  if tres(31 downto 0) = 0 then
                    cpsrRegister(Z_FLAG) <= '1';
                  else
                    cpsrRegister(Z_FLAG) <= '0';
                  end if;
                  op1 := theRegisters(datain53)(31);
                  op2 := theRegisters(datain86)(31);
                  opr := tres(31);
                  cpsrRegister(V_FLAG) <= (op1 and not op2 and not opr) or
                                          (not op1 and op2 and opr);
                  theRegisters(15) <= theRegisters(15) + 2;              
                when CODE_ADD2 =>
                  tres := ("0" & theRegisters(datain53)) +
                          ("0" & x"0000000" & "0" & datain(8 downto 6));
                  theRegisters(datain20) <=
                          theRegisters(datain53) +
                          (x"0000000" & "0" & datain(8 downto 6));
                  cpsrRegister(C_FLAG) <= tres(32);
                  cpsrRegister(N_FLAG) <= tres(31);
                  if tres(31 downto 0) = 0 then
                    cpsrRegister(Z_FLAG) <= '1';
                  else
                    cpsrRegister(Z_FLAG) <= '0';
                  end if;
                  op1 := theRegisters(datain53)(31);
                  op2 := '0';
                  opr := tres(31);
                  cpsrRegister(V_FLAG) <= (op1 and op2 and not opr) or
                                          (not op1 and not op2 and opr);
                  theRegisters(15) <= theRegisters(15) + 2;
                when CODE_SUB2 =>
                  tres := ("0" & theRegisters(datain53)) -
                          ("0" & x"0000000" & "0" & datain(8 downto 6));
                  theRegisters(datain20) <=
                          theRegisters(datain53) -
                          (x"0000000" & "0" & datain(8 downto 6));
                  cpsrRegister(C_FLAG) <= not tres(32);
                  cpsrRegister(N_FLAG) <= tres(31);
                  if tres(31 downto 0) = 0 then
                    cpsrRegister(Z_FLAG) <= '1';
                  else
                    cpsrRegister(Z_FLAG) <= '0';
                  end if;
                  op1 := theRegisters(datain53)(31);
                  op2 := '0';
                  opr := tres(31);
                  cpsrRegister(V_FLAG) <= (op1 and not op2 and not opr) or
                                          (not op1 and op2 and opr);
                  theRegisters(15) <= theRegisters(15) + 2;
                when CODE_MOV1 =>
                  tres := "0" & x"000000" & datain(7 downto 0);
                  theRegisters(datain108) <= x"000000" & datain(7 downto 0);
                  cpsrRegister(N_FLAG) <= tres(31);
                  if tres(31 downto 0) = 0 then
                    cpsrRegister(Z_FLAG) <= '1';
                  else
                    cpsrRegister(Z_FLAG) <= '0';
                  end if;
                  theRegisters(15) <= theRegisters(15) + 2;
                when CODE_CMP1 =>
                  tres := ("0" & theRegisters(datain108)) -
                          ("0" & x"000000" & datain(7 downto 0));
                  cpsrRegister(C_FLAG) <= not tres(32);
                  cpsrRegister(N_FLAG) <= tres(31);
                  if tres(31 downto 0) = 0 then
                    cpsrRegister(Z_FLAG) <= '1';
                  else
                    cpsrRegister(Z_FLAG) <= '0';
                  end if;
                  op1 := theRegisters(datain108)(31);
                  op2 := '0';
                  opr := tres(31);
                  cpsrRegister(V_FLAG) <= (op1 and not op2 and not opr) or
                                          (not op1 and op2 and opr);
                  theRegisters(15) <= theRegisters(15) + 2;
                when CODE_ADD3 =>
                  tres := ("0" & theRegisters(datain108)) +
                          ("0" & x"000000" & datain(7 downto 0));
                  theRegisters(datain108) <=
                          theRegisters(datain108) +
                          (x"000000" & datain(7 downto 0));
                  cpsrRegister(C_FLAG) <= tres(32);
                  cpsrRegister(N_FLAG) <= tres(31);
                  if tres(31 downto 0) = 0 then
                    cpsrRegister(Z_FLAG) <= '1';
                  else
                    cpsrRegister(Z_FLAG) <= '0';
                  end if;
                  op1 := theRegisters(datain108)(31);
                  op2 := '0';
                  opr := tres(31);
                  cpsrRegister(V_FLAG) <= (op1 and op2 and not opr) or
                                          (not op1 and not op2 and opr);
                  theRegisters(15) <= theRegisters(15) + 2;
                when CODE_SUB3 =>
                  tres := ("0" & theRegisters(datain108)) -
                          ("0" & x"000000" & datain(7 downto 0));
                  theRegisters(datain108) <=
                          theRegisters(datain108) -
                          (x"000000" & datain(7 downto 0));
                  cpsrRegister(C_FLAG) <= not tres(32);
                  cpsrRegister(N_FLAG) <= tres(31);
                  if tres(31 downto 0) = 0 then
                    cpsrRegister(Z_FLAG) <= '1';
                  else
                    cpsrRegister(Z_FLAG) <= '0';
                  end if;
                  op1 := theRegisters(datain108)(31);
                  op2 := '0';
                  opr := tres(31);
                  cpsrRegister(V_FLAG) <= (op1 and not op2 and not opr) or
                                          (not op1 and op2 and opr);
                  theRegisters(15) <= theRegisters(15) + 2;
                when CODE_AND1 =>
                  tres := ("0" & theRegisters(datain20)) and
                          ("0" & theRegisters(datain53));
                  theRegisters(datain20) <=
                          theRegisters(datain20) and
                          theRegisters(datain53);
                  cpsrRegister(N_FLAG) <= tres(31);
                  if tres(31 downto 0) = 0 then
                    cpsrRegister(Z_FLAG) <= '1';
                  else
                    cpsrRegister(Z_FLAG) <= '0';
                  end if;
                  theRegisters(15) <= theRegisters(15) + 2;
                when CODE_EOR1 =>
                  tres := ("0" & theRegisters(datain20)) xor
                          ("0" & theRegisters(datain53));
                  theRegisters(datain20) <=
                          theRegisters(datain20) xor
                          theRegisters(datain53);
                  cpsrRegister(N_FLAG) <= tres(31);
                  if tres(31 downto 0) = 0 then
                    cpsrRegister(Z_FLAG) <= '1';
                  else
                    cpsrRegister(Z_FLAG) <= '0';
                  end if;
                  theRegisters(15) <= theRegisters(15) + 2;
                when CODE_ADC1 =>
                  tres := ("0" & theRegisters(datain20)) +
                          ("0" & theRegisters(datain53)) +
                          (x"00000000" & cpsrRegister(C_FLAG));
                  theRegisters(datain20) <=
                          theRegisters(datain20) +
                          theRegisters(datain53) +
                          ("000" & x"0000000" & cpsrRegister(C_FLAG));
                  cpsrRegister(C_FLAG) <= tres(32);
                  cpsrRegister(N_FLAG) <= tres(31);
                  if tres(31 downto 0) = 0 then
                    cpsrRegister(Z_FLAG) <= '1';
                  else
                    cpsrRegister(Z_FLAG) <= '0';
                  end if;
                  op1 := theRegisters(datain20)(31);
                  op2 := theRegisters(datain53)(31);
                  opr := tres(31);
                  cpsrRegister(V_FLAG) <= (op1 and op2 and not opr) or
                                          (not op1 and not op2 and opr);
                  theRegisters(15) <= theRegisters(15) + 2;
                when CODE_SBC1 =>
                  tres := ("0" & theRegisters(datain20)) -
                          ("0" & theRegisters(datain53)) -
                          ("000" & x"0000000" & (not cpsrRegister(C_FLAG)));
                  theRegisters(datain20) <=
                          theRegisters(datain20) -
                          theRegisters(datain53) -
                          ("000" & x"0000000" & (not cpsrRegister(C_FLAG)));
                  cpsrRegister(C_FLAG) <= not tres(32);
                  cpsrRegister(N_FLAG) <= tres(31);
                  if tres(31 downto 0) = 0 then
                    cpsrRegister(Z_FLAG) <= '1';
                  else
                    cpsrRegister(Z_FLAG) <= '0';
                  end if;
                  op1 := theRegisters(datain20)(31);
                  op2 := theRegisters(datain53)(31);
                  opr := tres(31);
                  cpsrRegister(V_FLAG) <= (op1 and not op2 and not opr) or
                                          (not op1 and op2 and opr);
                  theRegisters(15) <= theRegisters(15) + 2;
                when CODE_TST1 =>
                  tres := ("0" & theRegisters(datain20)) and
                          ("0" & theRegisters(datain53));
                  cpsrRegister(N_FLAG) <= tres(31);
                  if tres(31 downto 0) = 0 then
                    cpsrRegister(Z_FLAG) <= '1';
                  else
                    cpsrRegister(Z_FLAG) <= '0';
                  end if;
                  theRegisters(15) <= theRegisters(15) + 2;
                when CODE_NEG1 =>
                  tres := ("0" & x"00000000") -
                          ("0" & theRegisters(datain53));
                  theRegisters(datain20) <=
                          x"00000000" -
                          theRegisters(datain53);
                  cpsrRegister(C_FLAG) <= not tres(32);
                  cpsrRegister(N_FLAG) <= tres(31);
                  if tres(31 downto 0) = 0 then
                    cpsrRegister(Z_FLAG) <= '1';
                  else
                    cpsrRegister(Z_FLAG) <= '0';
                  end if;
                  op1 := theRegisters(datain20)(31);
                  op2 := theRegisters(datain53)(31);
                  opr := tres(31);
                  cpsrRegister(V_FLAG) <= (op1 and not op2 and not opr) or
                                          (not op1 and op2 and opr);
                  theRegisters(15) <= theRegisters(15) + 2;
                when CODE_CMP2 =>
                  tres := ("0" & theRegisters(datain20)) -
                          ("0" & theRegisters(datain53));
                  cpsrRegister(C_FLAG) <= not tres(32);
                  cpsrRegister(N_FLAG) <= tres(31);
                  if tres(31 downto 0) = 0 then
                    cpsrRegister(Z_FLAG) <= '1';
                  else
                    cpsrRegister(Z_FLAG) <= '0';
                  end if;
                  op1 := theRegisters(datain20)(31);
                  op2 := theRegisters(datain53)(31);
                  opr := tres(31);
                  cpsrRegister(V_FLAG) <= (op1 and not op2 and not opr) or
                                          (not op1 and op2 and opr);
                  theRegisters(15) <= theRegisters(15) + 2;
                when CODE_CMN1 =>
                  tres := ("0" & theRegisters(datain20)) +
                          ("0" & theRegisters(datain53));
                  cpsrRegister(C_FLAG) <= tres(32);
                  cpsrRegister(N_FLAG) <= tres(31);
                  if tres(31 downto 0) = 0 then
                    cpsrRegister(Z_FLAG) <= '1';
                  else
                    cpsrRegister(Z_FLAG) <= '0';
                  end if;
                  op1 := theRegisters(datain20)(31);
                  op2 := theRegisters(datain53)(31);
                  opr := tres(31);
                  cpsrRegister(V_FLAG) <= (op1 and op2 and not opr) or
                                          (not op1 and not op2 and opr);
                  theRegisters(15) <= theRegisters(15) + 2;
                when CODE_ORR1 =>
                  tres := ("0" & theRegisters(datain20)) or
                          ("0" & theRegisters(datain53));
                  theRegisters(datain20) <=
                          theRegisters(datain20) or
                          theRegisters(datain53);
                  cpsrRegister(N_FLAG) <= tres(31);
                  if tres(31 downto 0) = 0 then
                    cpsrRegister(Z_FLAG) <= '1';
                  else
                    cpsrRegister(Z_FLAG) <= '0';
                  end if;
                  theRegisters(15) <= theRegisters(15) + 2;
                when CODE_MUL1 =>
                  theRegisters(datain20) <= product(31 downto 0);
                  cpsrRegister(N_FLAG) <= product(31);
                  if product(31 downto 0) = 0 then
                    cpsrRegister(Z_FLAG) <= '1';
                  else
                    cpsrRegister(Z_FLAG) <= '0';
                  end if;                
                  theRegisters(15) <= theRegisters(15) + 2;			        
                when CODE_BIC1 =>
                  tres := ("0" & theRegisters(datain20)) and
                          not ("0" & theRegisters(datain53));
                  theRegisters(datain20) <=
                          theRegisters(datain20) and
                          not theRegisters(datain53);
                  cpsrRegister(N_FLAG) <= tres(31);
                  if tres(31 downto 0) = 0 then
                    cpsrRegister(Z_FLAG) <= '1';
                  else
                    cpsrRegister(Z_FLAG) <= '0';
                  end if;
                  theRegisters(15) <= theRegisters(15) + 2;
                when CODE_MVN1 =>
                  tres := not ("0" & theRegisters(datain53));
                  theRegisters(datain20) <=
                          not theRegisters(datain53);
                  cpsrRegister(N_FLAG) <= tres(31);
                  if tres(31 downto 0) = 0 then
                    cpsrRegister(Z_FLAG) <= '1';
                  else
                    cpsrRegister(Z_FLAG) <= '0';
                  end if;
                  theRegisters(15) <= theRegisters(15) + 2;
                when CODE_CMP3 =>
                  tres := ("0" & theRegisters(conv_integer(datain(7) & datain(2 downto 0)))) -
                          ("0" & theRegisters(conv_integer(datain(6) & datain(5 downto 3))));
                  cpsrRegister(C_FLAG) <= not tres(32);
                  cpsrRegister(N_FLAG) <= tres(31);
                  if tres(31 downto 0) = 0 then
                    cpsrRegister(Z_FLAG) <= '1';
                  else
                    cpsrRegister(Z_FLAG) <= '0';
                  end if;
                  op1 := theRegisters(conv_integer(datain(7) & datain(2 downto 0)))(31);
                  op2 := theRegisters(conv_integer(datain(6) & datain(5 downto 3)))(31);
                  opr := tres(31);
                  cpsrRegister(V_FLAG) <= (op1 and not op2 and not opr) or
                                          (not op1 and op2 and opr);
                  theRegisters(15) <= theRegisters(15) + 2;
                when CODE_BX1 =>
                  if theRegisters(14) = x"FFFFFFF9" then  -- EXC_RETURN ?
                    if datain(6 downto 3) = "1110" then
                      cpuState <= STATE_RET;
                    else
                      theRegisters(15) <= theRegisters(conv_integer(datain(6 downto 3)))(31 downto 1) & "0";
                      theRegisters(14) <= theRegisters(15) + 2;
                    end if;
                  else
                    theRegisters(15) <= theRegisters(conv_integer(datain(6 downto 3)))(31 downto 1) & "0";
                    if datain(6 downto 3) /= "1110" then
                      theRegisters(14) <= theRegisters(15) + 2;
                    end if;                  
                  end if;                  
                when CODE_LDR1 =>
                  address  <= (theRegisters(15) and x"FFFFFFFC") +
                              (x"00000" & "00" & datain(7 downto 0) & "00") + x"00000004";
                  addrMux  <= ADDR_RS;
                  theRegisters(15) <= theRegisters(15) + 2;
                  cpuState <= STATE_READ1;
                when CODE_LDR4 =>
                  address  <= theRegisters(13) +
                              (x"00000" & "00" & datain(7 downto 0) & "00");
                  addrMux  <= ADDR_RS;
                  theRegisters(15) <= theRegisters(15) + 2;
                  cpuState <= STATE_READ1;
                when CODE_STR1 | CODE_STRH1 =>
                  address  <= theRegisters(datain53) +
                              theRegisters(datain86);
                  addrMux  <= ADDR_RS;
                  writeL   <= '0';
                  writeH   <= '0';
                  dataout  <= theRegisters(datain20)(15 downto 0);
                  theRegisters(15) <= theRegisters(15) + 2;
                  cpuState <= STATE_WRITE1;
                when CODE_STRB1 =>
                  address  <= theRegisters(datain53) +
                              theRegisters(datain86);
                  tsum     := theRegisters(datain53) +
                              theRegisters(datain86);
                  addrMux  <= ADDR_RS;
                  if tsum(0) = '0' then
                    writeL   <= '0';
                    writeH   <= '1';
                  else
                    writeL   <= '1';
                    writeH   <= '0';
                  end if;
                  dataout  <= theRegisters(datain20)(7 downto 0) &
                              theRegisters(datain20)(7 downto 0);
                  theRegisters(15) <= theRegisters(15) + 2;
                  cpuState <= STATE_WRITE1;
                when CODE_LDRSB1 | CODE_LDR2 | CODE_LDRH1 | CODE_LDRB1 | CODE_LDRSH1 =>
                  address  <= theRegisters(datain53) +
                              theRegisters(datain86);
                  addrMux  <= ADDR_RS;
                  theRegisters(15) <= theRegisters(15) + 2;
                  cpuState <= STATE_READ1;
                when CODE_STR2 =>
                  address  <= theRegisters(datain53) +
                              (x"000000" & "0" & datain(10 downto 6) & "00");
                  addrMux  <= ADDR_RS;
                  writeL   <= '0';
                  writeH   <= '0';
                  dataout  <= theRegisters(datain20)(15 downto 0);
                  theRegisters(15) <= theRegisters(15) + 2;
                  cpuState <= STATE_WRITE1;
                when CODE_LDR3 =>
                  address  <= theRegisters(datain53) +
                              (x"000000" & "0" & datain(10 downto 6) & "00");
                  addrMux  <= ADDR_RS;
                  theRegisters(15) <= theRegisters(15) + 2;
                  cpuState <= STATE_READ1;
                when CODE_STRB2 =>
                  address  <= theRegisters(datain53) +
                              (x"000000" & "000" & datain(10 downto 6));
                  tsum     := theRegisters(datain53) +
                              (x"000000" & "000" & datain(10 downto 6));
                  addrMux  <= ADDR_RS;
                  if tsum(0) = '0' then
                    writeL   <= '0';
                    writeH   <= '1';
                  else
                    writeL   <= '1';
                    writeH   <= '0';
                  end if;
                  dataout  <= theRegisters(datain20)(7 downto 0) &
                              theRegisters(datain20)(7 downto 0);
                  theRegisters(15) <= theRegisters(15) + 2;
                  cpuState <= STATE_WRITE1;
                when CODE_LDRB2 =>
                  address  <= theRegisters(datain53) +
                              (x"000000" & "000" & datain(10 downto 6));
                  addrMux  <= ADDR_RS;
                  theRegisters(15) <= theRegisters(15) + 2;
                  cpuState <= STATE_READ1;
                when CODE_LDRH2 =>
                  address  <= theRegisters(datain53) +
                              (x"000000" & "00" & datain(10 downto 6) & "0");
                  addrMux  <= ADDR_RS;
                  theRegisters(15) <= theRegisters(15) + 2;
                  cpuState <= STATE_READ1;                
                when CODE_STRH2 =>
                  address  <= theRegisters(datain53) +
                              (x"000000" & "00" & datain(10 downto 6) & "0");
                  addrMux  <= ADDR_RS;
                  writeL   <= '0';
                  writeH   <= '0';
                  dataout  <= theRegisters(datain20)(15 downto 0);
                  theRegisters(15) <= theRegisters(15) + 2;
                  cpuState <= STATE_WRITE1;
                when CODE_STR3 =>
                  address  <= theRegisters(13) +
                              (x"00000" & "00" & datain(7 downto 0) & "00");
                  addrMux  <= ADDR_RS;
                  writeL   <= '0';
                  writeH   <= '0';
                  dataout  <= theRegisters(datain108)(15 downto 0);
                  theRegisters(15) <= theRegisters(15) + 2;
                  cpuState <= STATE_WRITE1;
                when CODE_ADD5 =>
                  theRegisters(datain108) <= 
                      theRegisters(15) + (x"00000" & "00" & datain(7 downto 0) & "00");
                  theRegisters(15) <= theRegisters(15) + 2;
                  cpuState <= STATE_FETCH;
                when CODE_SXTH1 =>
                  theRegisters(datain20) <= 
                      theRegisters(datain53)(15) & 
                      theRegisters(datain53)(15) & 
                      theRegisters(datain53)(15) & 
                      theRegisters(datain53)(15) & 
                      theRegisters(datain53)(15) & 
                      theRegisters(datain53)(15) & 
                      theRegisters(datain53)(15) & 
                      theRegisters(datain53)(15) & 
                      theRegisters(datain53)(15) & 
                      theRegisters(datain53)(15) & 
                      theRegisters(datain53)(15) & 
                      theRegisters(datain53)(15) & 
                      theRegisters(datain53)(15) & 
                      theRegisters(datain53)(15) & 
                      theRegisters(datain53)(15) & 
                      theRegisters(datain53)(15) &
                      theRegisters(datain53)(15 downto 0);
                  theRegisters(15) <= theRegisters(15) + 2;
                  cpuState <= STATE_FETCH;
                when CODE_SXTB1 =>
                  theRegisters(datain20) <= 
                      theRegisters(datain53)(7) & 
                      theRegisters(datain53)(7) & 
                      theRegisters(datain53)(7) & 
                      theRegisters(datain53)(7) & 
                      theRegisters(datain53)(7) & 
                      theRegisters(datain53)(7) & 
                      theRegisters(datain53)(7) & 
                      theRegisters(datain53)(7) & 
                      theRegisters(datain53)(7) & 
                      theRegisters(datain53)(7) & 
                      theRegisters(datain53)(7) & 
                      theRegisters(datain53)(7) & 
                      theRegisters(datain53)(7) & 
                      theRegisters(datain53)(7) & 
                      theRegisters(datain53)(7) & 
                      theRegisters(datain53)(7) & 
                      theRegisters(datain53)(7) & 
                      theRegisters(datain53)(7) & 
                      theRegisters(datain53)(7) & 
                      theRegisters(datain53)(7) & 
                      theRegisters(datain53)(7) & 
                      theRegisters(datain53)(7) & 
                      theRegisters(datain53)(7) & 
                      theRegisters(datain53)(7) & 
                      theRegisters(datain53)(7 downto 0);
                  theRegisters(15) <= theRegisters(15) + 2;
                  cpuState <= STATE_FETCH;
                when CODE_UXTH1 =>
                  theRegisters(datain20) <= x"0000" &
                      theRegisters(datain53)(15 downto 0);
                  theRegisters(15) <= theRegisters(15) + 2;
                  cpuState <= STATE_FETCH;
                when CODE_UXTB1 =>
                  theRegisters(datain20) <= x"000000" &
                      theRegisters(datain53)(7 downto 0);
                  theRegisters(15) <= theRegisters(15) + 2;
                  cpuState <= STATE_FETCH;
                when CODE_PUSH1 =>
                  theRegisters(15) <= theRegisters(15) + 2;
                  if datain(8 downto 0) = 0 then
                    cpuState <= STATE_FETCH;
                  else
                    theRegisters(13) <= theRegisters(13) - 2;
                    addrMux  <= ADDR_SP;
                    writeL   <= '0';
                    writeH   <= '0';
                    if datain(8) = '1' then
                      dataout <= theRegisters(14)(31 downto 16);
                      cpuState <= STATE_WRPH;
                    elsif datain(7) = '1' then
                      dataout <= theRegisters(7)(31 downto 16);
                      cpuState <= STATE_WR7H;
                    elsif datain(6) = '1' then
                      dataout <= theRegisters(6)(31 downto 16);
                      cpuState <= STATE_WR6H;
                    elsif datain(5) = '1' then
                      dataout <= theRegisters(5)(31 downto 16);
                      cpuState <= STATE_WR5H;
                    elsif datain(4) = '1' then
                      dataout <= theRegisters(4)(31 downto 16);
                      cpuState <= STATE_WR4H;
                    elsif datain(3) = '1' then
                      dataout <= theRegisters(3)(31 downto 16);
                      cpuState <= STATE_WR3H;
                    elsif datain(2) = '1' then
                      dataout <= theRegisters(2)(31 downto 16);
                      cpuState <= STATE_WR2H;
                    elsif datain(1) = '1' then
                      dataout <= theRegisters(1)(31 downto 16);
                      cpuState <= STATE_WR1H;
                    else
                      dataout <= theRegisters(0)(31 downto 16);
                      cpuState <= STATE_WR0H;
                    end if;
                  end if;
                when CODE_POP1 =>
                  theRegisters(15) <= theRegisters(15) + 2;
                  if datain(8 downto 0) = 0 then
                    cpuState <= STATE_FETCH;
                  else
                    addrMux  <= ADDR_SP;
                    if datain(0) = '1' then
                      cpuState <= STATE_RD0L;
                    elsif datain(1) = '1' then
                      cpuState <= STATE_RD1L;
                    elsif datain(2) = '1' then
                      cpuState <= STATE_RD2L;
                    elsif datain(3) = '1' then
                      cpuState <= STATE_RD3L;
                    elsif datain(4) = '1' then
                      cpuState <= STATE_RD4L;
                    elsif datain(5) = '1' then
                      cpuState <= STATE_RD5L;
                    elsif datain(6) = '1' then
                      cpuState <= STATE_RD6L;
                    elsif datain(7) = '1' then
                      cpuState <= STATE_RD7L;
                    else
                      cpuState <= STATE_RDPL;
                    end if;
                  end if;
                when CODE_NOP =>
                  theRegisters(15) <= theRegisters(15) + 2;
                when CODE_STMIA1 =>
                  theRegisters(15) <= theRegisters(15) + 2;
                  if datain(7 downto 0) = 0 then
                    cpuState <= STATE_FETCH;
                  else
                    address  <= theRegisters(datain108);
                    addrMux  <= ADDR_RS;
                    writeL   <= '0';
                    writeH   <= '0';
                    if datain(0) = '1' then
                      dataout <= theRegisters(0)(15 downto 0);
                      cpuState <= STATE_WR0H;
                    elsif datain(1) = '1' then
                      dataout <= theRegisters(1)(15 downto 0);
                      cpuState <= STATE_WR1H;
                    elsif datain(2) = '1' then
                      dataout <= theRegisters(2)(15 downto 0);
                      cpuState <= STATE_WR2H;
                    elsif datain(3) = '1' then
                      dataout <= theRegisters(3)(15 downto 0);
                      cpuState <= STATE_WR3H;
                    elsif datain(4) = '1' then
                      dataout <= theRegisters(4)(15 downto 0);
                      cpuState <= STATE_WR4H;
                    elsif datain(5) = '1' then
                      dataout <= theRegisters(5)(15 downto 0);
                      cpuState <= STATE_WR5H;
                    elsif datain(6) = '1' then
                      dataout <= theRegisters(6)(15 downto 0);
                      cpuState <= STATE_WR6H;
                    else
                      dataout <= theRegisters(7)(15 downto 0);
                      cpuState <= STATE_WR7H;
                    end if;
                  end if;
                when CODE_LDMIA1 =>
                  LDMread <= x"00";
                  theRegisters(15) <= theRegisters(15) + 2;
                  if datain(7 downto 0) = 0 then
                    cpuState <= STATE_FETCH;
                  else
                    address  <= theRegisters(datain108);
                    addrMux  <= ADDR_RS;
                    if datain(0) = '1' then
                      cpuState <= STATE_RD0L;
                    elsif datain(1) = '1' then
                      cpuState <= STATE_RD1L;
                    elsif datain(2) = '1' then
                      cpuState <= STATE_RD2L;
                    elsif datain(3) = '1' then
                      cpuState <= STATE_RD3L;
                    elsif datain(4) = '1' then
                      cpuState <= STATE_RD4L;
                    elsif datain(5) = '1' then
                      cpuState <= STATE_RD5L;
                    elsif datain(6) = '1' then
                      cpuState <= STATE_RD6L;
                    else
                      cpuState <= STATE_RD7L;
                    end if;
                  end if;              
                when CODE_BCC1 =>
                  if branch = '1' then
                    theRegisters(15) <= theRegisters(15) + (
                      datain(7) & datain(7) & datain(7) & datain(7) & 
                      datain(7) & datain(7) & datain(7) & datain(7) & 
                      datain(7) & datain(7) & datain(7) & datain(7) & 
                      datain(7) & datain(7) & datain(7) & datain(7) & 
                      datain(7) & datain(7) & datain(7) & datain(7) & 
                      datain(7) & datain(7) & datain(7) &  
                      datain(7 downto 0) & "0") + x"00000004";                      
                  else
                    theRegisters(15) <= theRegisters(15) + 2;
                  end if;
                when CODE_B1 =>
                  theRegisters(15) <= theRegisters(15) + (
                    datain(10) & datain(10) & datain(10) & datain(10) & 
                    datain(10) & datain(10) & datain(10) & datain(10) & 
                    datain(10) & datain(10) & datain(10) & datain(10) & 
                    datain(10) & datain(10) & datain(10) & datain(10) & 
                    datain(10) & datain(10) & datain(10) & datain(10) & 
                    datain(10 downto 0) & "0") + x"00000004";   
                when CODE_BLX2 =>                  
                  theRegisters(14) <= theRegisters(15) + (
                    datain(10) & datain(10) & datain(10) & datain(10) & 
                    datain(10) & datain(10) & datain(10) & datain(10) & 
                    datain(10) &
                    datain(10 downto 0) & x"000") + x"00000004";   
                  theRegisters(15) <= theRegisters(15) + 2;
                when CODE_BL1 =>
                  theRegisters(15) <= theRegisters(14) + (x"00000" &
                    datain(10 downto 0) & "0");   
                  theRegisters(14) <= theRegisters(15) + 2;

                when others =>
                  cpuState <= STATE_FETCH;
              end case; -- unitControl
            end if; -- irqrequest
          when STATE_READ1 => -- ##################################################
            case unitControl2 is
              when CODE_LDRH1 | CODE_LDRH2 =>
                theRegisters(opcode20)(15 downto 0) <= datain;
                addrMux  <= ADDR_PC;
                cpuState <= STATE_FETCH;
              when CODE_LDRSH1 =>
                theRegisters(opcode20)(15 downto 0) <= datain;
                theRegisters(opcode20)(31 downto 16) <=
                    datain(15) & datain(15) & datain(15) & datain(15) & datain(15) & datain(15) & 
                    datain(15) & datain(15) & datain(15) & datain(15) & datain(15) & datain(15) & 
                    datain(15) & datain(15) & datain(15) & datain(15);
                addrMux  <= ADDR_PC;
                cpuState <= STATE_FETCH;
              when CODE_LDR1 | CODE_LDR4 =>
                theRegisters(opcode108)(15 downto 0) <= datain;
                address <= address + 2;
                cpuState <= STATE_READ2;
              when CODE_LDR2 | CODE_LDR3 =>
                theRegisters(opcode20)(15 downto 0) <= datain;
                address <= address + 2;
                cpuState <= STATE_READ2;
              when CODE_LDRSB1 =>
                if address(0) = '0' then
                  theRegisters(opcode20)(7 downto 0) <= datain(7 downto 0);
                  theRegisters(opcode20)(31 downto 8) <=
                    datain(7) & datain(7) & datain(7) & datain(7) & datain(7) & datain(7) & 
                    datain(7) & datain(7) & datain(7) & datain(7) & datain(7) & datain(7) & 
                    datain(7) & datain(7) & datain(7) & datain(7) & datain(7) & datain(7) & 
                    datain(7) & datain(7) & datain(7) & datain(7) & datain(7) & datain(7);
                else
                  theRegisters(opcode20)(7 downto 0) <= datain(15 downto 8);
                  theRegisters(opcode20)(31 downto 8) <=
                    datain(15) & datain(15) & datain(15) & datain(15) & datain(15) & datain(15) & 
                    datain(15) & datain(15) & datain(15) & datain(15) & datain(15) & datain(15) & 
                    datain(15) & datain(15) & datain(15) & datain(15) & datain(15) & datain(15) & 
                    datain(15) & datain(15) & datain(15) & datain(15) & datain(15) & datain(15);
                end if;
                addrMux  <= ADDR_PC;
                cpuState <= STATE_FETCH;
              when CODE_LDRB1 | CODE_LDRB2 =>
                if address(0) = '0' then
                  theRegisters(opcode20)(7 downto 0) <= datain(7 downto 0);
                else
                  theRegisters(opcode20)(7 downto 0) <= datain(15 downto 8);
                end if;
                theRegisters(opcode20)(31 downto 8) <= x"000000";
                addrMux  <= ADDR_PC;
                cpuState <= STATE_FETCH;

              when others =>
                cpuState <= STATE_FETCH;
            end case; -- unitControl2

          when STATE_READ2 => -- ##################################################
            case unitControl2 is
              when CODE_LDR1 | CODE_LDR4 =>
                theRegisters(opcode108)(31 downto 16) <= datain;
                addrMux  <= ADDR_PC;
                cpuState <= STATE_FETCH;
              when CODE_LDR2 | CODE_LDR3 =>
                theRegisters(opcode20)(31 downto 16) <= datain;
                addrMux  <= ADDR_PC;
                cpuState <= STATE_FETCH;

              when others =>
                cpuState <= STATE_FETCH;
            end case; -- unitControl2
            
          when STATE_RD0L => -- ##################################################
            case unitControl2 is
              when CODE_POP1 =>
                theRegisters(13) <= theRegisters(13) + 2;
                theRegisters(0)(15 downto 0) <= datain;
                cpuState <= STATE_RD0H;
              when CODE_LDMIA1 =>
                LDMread(0) <= '1';
                theRegisters(0)(15 downto 0) <= datain;
                address <= address + 2;
                cpuState <= STATE_RD0H;

              when others =>
                cpuState <= STATE_FETCH;
            end case; -- unitControl2
            
          when STATE_RD0H => -- ##################################################
            case unitControl2 is
              when CODE_POP1 =>
                theRegisters(13) <= theRegisters(13) + 2;
                theRegisters(0)(31 downto 16) <= datain;
                if opcode(8 downto 1) = 0 then
                  addrMux  <= ADDR_PC;
                  cpuState <= STATE_FETCH;
                else
                  if opcode(1) = '1' then
                    cpuState <= STATE_RD1L;
                  elsif opcode(2) = '1' then
                    cpuState <= STATE_RD2L;
                  elsif opcode(3) = '1' then
                    cpuState <= STATE_RD3L;
                  elsif opcode(4) = '1' then
                    cpuState <= STATE_RD4L;
                  elsif opcode(5) = '1' then
                    cpuState <= STATE_RD5L;
                  elsif opcode(6) = '1' then
                    cpuState <= STATE_RD6L;
                  elsif opcode(7) = '1' then
                    cpuState <= STATE_RD7L;
                  else
                    cpuState <= STATE_RDPL;
                  end if;
                end if;
              when CODE_LDMIA1 =>
                address <= address + 2;
                if opcode(7 downto 1) = 0 then
                  addrMux  <= ADDR_PC;
                  if opcode108 = 0 then
                    theRegisters(0)(31 downto 16) <= datain;
                  else
                    theRegisters(opcode108) <= address + 2;
                  end if;
                  cpuState <= STATE_FETCH;
                else
                  theRegisters(0)(31 downto 16) <= datain;
                  if opcode(1) = '1' then
                    cpuState <= STATE_RD1L;
                  elsif opcode(2) = '1' then
                    cpuState <= STATE_RD2L;
                  elsif opcode(3) = '1' then
                    cpuState <= STATE_RD3L;
                  elsif opcode(4) = '1' then
                    cpuState <= STATE_RD4L;
                  elsif opcode(5) = '1' then
                    cpuState <= STATE_RD5L;
                  elsif opcode(6) = '1' then
                    cpuState <= STATE_RD6L;
                  else
                    cpuState <= STATE_RD7L;
                  end if;
                end if;

              when others =>
                cpuState <= STATE_FETCH;
            end case; -- unitControl2
            
          when STATE_RD1L => -- ##################################################
            case unitControl2 is
              when CODE_POP1 =>
                theRegisters(13) <= theRegisters(13) + 2;
                theRegisters(1)(15 downto 0) <= datain;
                cpuState <= STATE_RD1H;
              when CODE_LDMIA1 =>
                LDMread(1) <= '1';
                theRegisters(1)(15 downto 0) <= datain;
                address <= address + 2;
                cpuState <= STATE_RD1H;

              when others =>
                cpuState <= STATE_FETCH;
            end case; -- unitControl2

          when STATE_RD1H => -- ##################################################
            case unitControl2 is
              when CODE_POP1 =>
                theRegisters(13) <= theRegisters(13) + 2;
                theRegisters(1)(31 downto 16) <= datain;
                if opcode(8 downto 2) = 0 then
                  addrMux  <= ADDR_PC;
                  cpuState <= STATE_FETCH;
                else
                  if opcode(2) = '1' then
                    cpuState <= STATE_RD2L;
                  elsif opcode(3) = '1' then
                    cpuState <= STATE_RD3L;
                  elsif opcode(4) = '1' then
                    cpuState <= STATE_RD4L;
                  elsif opcode(5) = '1' then
                    cpuState <= STATE_RD5L;
                  elsif opcode(6) = '1' then
                    cpuState <= STATE_RD6L;
                  elsif opcode(7) = '1' then
                    cpuState <= STATE_RD7L;
                  else
                    cpuState <= STATE_RDPL;
                  end if;
                end if;
              when CODE_LDMIA1 =>
                address <= address + 2;
                if opcode(7 downto 2) = 0 then
                  theRegisters(1)(31 downto 16) <= datain;
                  if opcode108 /= 1 then
                    if LDMread(opcode108) /= '1' then
                      theRegisters(opcode108) <= address + 2;
                    end if;
                  end if;
                  addrMux  <= ADDR_PC;
                  cpuState <= STATE_FETCH;
                else
                  theRegisters(1)(31 downto 16) <= datain;
                  if opcode(2) = '1' then
                    cpuState <= STATE_RD2L;
                  elsif opcode(3) = '1' then
                    cpuState <= STATE_RD3L;
                  elsif opcode(4) = '1' then
                    cpuState <= STATE_RD4L;
                  elsif opcode(5) = '1' then
                    cpuState <= STATE_RD5L;
                  elsif opcode(6) = '1' then
                    cpuState <= STATE_RD6L;
                  else
                    cpuState <= STATE_RD7L;
                  end if;
                end if;

              when others =>
                cpuState <= STATE_FETCH;
            end case; -- unitControl2

          when STATE_RD2L => -- ##################################################
            case unitControl2 is
              when CODE_POP1 =>
                theRegisters(13) <= theRegisters(13) + 2;
                theRegisters(2)(15 downto 0) <= datain;
                cpuState <= STATE_RD2H;
              when CODE_LDMIA1 =>
                LDMread(2) <= '1';
                theRegisters(2)(15 downto 0) <= datain;
                address <= address + 2;
                cpuState <= STATE_RD2H;

              when others =>
                cpuState <= STATE_FETCH;
            end case; -- unitControl2

          when STATE_RD2H => -- ##################################################
            case unitControl2 is
              when CODE_POP1 =>
                theRegisters(13) <= theRegisters(13) + 2;
                theRegisters(2)(31 downto 16) <= datain;
                if opcode(8 downto 3) = 0 then
                  addrMux  <= ADDR_PC;
                  cpuState <= STATE_FETCH;
                else
                  if opcode(3) = '1' then
                    cpuState <= STATE_RD3L;
                  elsif opcode(4) = '1' then
                    cpuState <= STATE_RD4L;
                  elsif opcode(5) = '1' then
                    cpuState <= STATE_RD5L;
                  elsif opcode(6) = '1' then
                    cpuState <= STATE_RD6L;
                  elsif opcode(7) = '1' then
                    cpuState <= STATE_RD7L;
                  else
                    cpuState <= STATE_RDPL;
                  end if;
                end if;
              when CODE_LDMIA1 =>
                address <= address + 2;
                if opcode(7 downto 3) = 0 then
                  addrMux  <= ADDR_PC;
                  theRegisters(2)(31 downto 16) <= datain;
                  if opcode108 /= 2 then
                    if LDMread(opcode108) /= '1' then
                      theRegisters(opcode108) <= address + 2;
                    end if;
                  end if;
                  cpuState <= STATE_FETCH;
                else
                  theRegisters(2)(31 downto 16) <= datain;
                  if opcode(3) = '1' then
                    cpuState <= STATE_RD3L;
                  elsif opcode(4) = '1' then
                    cpuState <= STATE_RD4L;
                  elsif opcode(5) = '1' then
                    cpuState <= STATE_RD5L;
                  elsif opcode(6) = '1' then
                    cpuState <= STATE_RD6L;
                  else
                    cpuState <= STATE_RD7L;
                  end if;
                end if;

              when others =>
                cpuState <= STATE_FETCH;
            end case; -- unitControl2

          when STATE_RD3L => -- ##################################################
            case unitControl2 is
              when CODE_POP1 =>
                theRegisters(13) <= theRegisters(13) + 2;
                theRegisters(3)(15 downto 0) <= datain;
                cpuState <= STATE_RD3H;
              when CODE_LDMIA1 =>
                LDMread(3) <= '1';
                theRegisters(3)(15 downto 0) <= datain;
                address <= address + 2;
                cpuState <= STATE_RD3H;

              when others =>
                cpuState <= STATE_FETCH;
            end case; -- unitControl2

          when STATE_RD3H => -- ##################################################
            case unitControl2 is
              when CODE_POP1 =>
                theRegisters(13) <= theRegisters(13) + 2;
                theRegisters(3)(31 downto 16) <= datain;
                if opcode(8 downto 4) = 0 then
                  addrMux  <= ADDR_PC;
                  cpuState <= STATE_FETCH;
                else
                  if opcode(4) = '1' then
                    cpuState <= STATE_RD4L;
                  elsif opcode(5) = '1' then
                    cpuState <= STATE_RD5L;
                  elsif opcode(6) = '1' then
                    cpuState <= STATE_RD6L;
                  elsif opcode(7) = '1' then
                    cpuState <= STATE_RD7L;
                  else
                    cpuState <= STATE_RDPL;
                  end if;
                end if;
              when CODE_LDMIA1 =>
                address <= address + 2;
                if opcode(7 downto 4) = 0 then
                  addrMux  <= ADDR_PC;
                  theRegisters(3)(31 downto 16) <= datain;
                  if opcode108 /= 3 then
                    if LDMread(opcode108) /= '1' then
                      theRegisters(opcode108) <= address + 2;
                    end if;
                  end if;
                  cpuState <= STATE_FETCH;
                else
                  theRegisters(3)(31 downto 16) <= datain;
                  if opcode(4) = '1' then
                    cpuState <= STATE_RD4L;
                  elsif opcode(5) = '1' then
                    cpuState <= STATE_RD5L;
                  elsif opcode(6) = '1' then
                    cpuState <= STATE_RD6L;
                  else
                    cpuState <= STATE_RD7L;
                  end if;
                end if;

              when others =>
                cpuState <= STATE_FETCH;
            end case; -- unitControl2

          when STATE_RD4L => -- ##################################################
            case unitControl2 is
              when CODE_POP1 =>
                theRegisters(13) <= theRegisters(13) + 2;
                theRegisters(4)(15 downto 0) <= datain;
                cpuState <= STATE_RD4H;
              when CODE_LDMIA1 =>
                LDMread(4) <= '1';
                theRegisters(4)(15 downto 0) <= datain;
                address <= address + 2;
                cpuState <= STATE_RD4H;

              when others =>
                cpuState <= STATE_FETCH;
            end case; -- unitControl2

          when STATE_RD4H => -- ##################################################
            case unitControl2 is
              when CODE_POP1 =>
                theRegisters(13) <= theRegisters(13) + 2;
                theRegisters(4)(31 downto 16) <= datain;
                if opcode(8 downto 5) = 0 then
                  addrMux  <= ADDR_PC;
                  cpuState <= STATE_FETCH;
                else
                  if opcode(5) = '1' then
                    cpuState <= STATE_RD5L;
                  elsif opcode(6) = '1' then
                    cpuState <= STATE_RD6L;
                  elsif opcode(7) = '1' then
                    cpuState <= STATE_RD7L;
                  else
                    cpuState <= STATE_RDPL;
                  end if;
                end if;
              when CODE_LDMIA1 =>
                address <= address + 2;
                if opcode(7 downto 5) = 0 then
                  addrMux  <= ADDR_PC;
                  theRegisters(4)(31 downto 16) <= datain;
                  if opcode108 /= 4 then
                    if LDMread(opcode108) /= '1' then
                      theRegisters(opcode108) <= address + 2;
                    end if;
                  end if;
                  cpuState <= STATE_FETCH;
                else
                  theRegisters(4)(31 downto 16) <= datain;
                  if opcode(5) = '1' then
                    cpuState <= STATE_RD5L;
                  elsif opcode(6) = '1' then
                    cpuState <= STATE_RD6L;
                  else
                    cpuState <= STATE_RD7L;
                  end if;
                end if;

              when others =>
                cpuState <= STATE_FETCH;
            end case; -- unitControl2

          when STATE_RD5L => -- ##################################################
            case unitControl2 is
              when CODE_POP1 =>
                theRegisters(13) <= theRegisters(13) + 2;
                theRegisters(5)(15 downto 0) <= datain;
                cpuState <= STATE_RD5H;
              when CODE_LDMIA1 =>
                LDMread(5) <= '1';
                theRegisters(5)(15 downto 0) <= datain;
                address <= address + 2;
                cpuState <= STATE_RD5H;

              when others =>
                cpuState <= STATE_FETCH;
            end case; -- unitControl2

          when STATE_RD5H => -- ##################################################
            case unitControl2 is
              when CODE_POP1 =>
                theRegisters(13) <= theRegisters(13) + 2;
                theRegisters(5)(31 downto 16) <= datain;
                if opcode(8 downto 6) = 0 then
                  addrMux  <= ADDR_PC;
                  cpuState <= STATE_FETCH;
                else
                  if opcode(6) = '1' then
                    cpuState <= STATE_RD6L;
                  elsif opcode(7) = '1' then
                    cpuState <= STATE_RD7L;
                  else
                    cpuState <= STATE_RDPL;
                  end if;
                end if;
              when CODE_LDMIA1 =>
                address <= address + 2;
                if opcode(7 downto 6) = 0 then
                  addrMux  <= ADDR_PC;
                  theRegisters(5)(31 downto 16) <= datain;
                  if opcode108 /= 5 then
                    if LDMread(opcode108) /= '1' then
                      theRegisters(opcode108) <= address + 2;
                    end if;
                  end if;
                  cpuState <= STATE_FETCH;
                else
                  theRegisters(5)(31 downto 16) <= datain;
                  if opcode(6) = '1' then
                    cpuState <= STATE_RD6L;
                  else
                    cpuState <= STATE_RD7L;
                  end if;
                end if;

              when others =>
                cpuState <= STATE_FETCH;
            end case; -- unitControl2

          when STATE_RD6L => -- ##################################################
            case unitControl2 is
              when CODE_POP1 =>
                theRegisters(13) <= theRegisters(13) + 2;
                theRegisters(6)(15 downto 0) <= datain;
                cpuState <= STATE_RD6H;
              when CODE_LDMIA1 =>
                LDMread(7) <= '1';
                theRegisters(6)(15 downto 0) <= datain;
                address <= address + 2;
                cpuState <= STATE_RD6H;

              when others =>
                cpuState <= STATE_FETCH;
            end case; -- unitControl2

          when STATE_RD6H => -- ##################################################
            case unitControl2 is
              when CODE_POP1 =>
                theRegisters(13) <= theRegisters(13) + 2;
                theRegisters(6)(31 downto 16) <= datain;
                if opcode(8 downto 7) = 0 then
                  addrMux  <= ADDR_PC;
                  cpuState <= STATE_FETCH;
                else
                  if opcode(7) = '1' then
                    cpuState <= STATE_RD7L;
                  else
                    cpuState <= STATE_RDPL;
                  end if;
                end if;
              when CODE_LDMIA1 =>
                address <= address + 2;
                if opcode(7) = '0' then
                  addrMux  <= ADDR_PC;
                  theRegisters(6)(31 downto 16) <= datain;
                  if opcode108 /= 6 then
                    if LDMread(opcode108) /= '1' then
                      theRegisters(opcode108) <= address + 2;
                    end if;
                  end if;
                  cpuState <= STATE_FETCH;
                else
                  theRegisters(6)(31 downto 16) <= datain;              
                  cpuState <= STATE_RD7L;
                end if;

              when others =>
                cpuState <= STATE_FETCH;
            end case; -- unitControl2

          when STATE_RD7L => -- ##################################################
            case unitControl2 is
              when CODE_POP1 =>
                theRegisters(13) <= theRegisters(13) + 2;
                theRegisters(7)(15 downto 0) <= datain;
                cpuState <= STATE_RD7H;
              when CODE_LDMIA1 =>
                LDMread(7) <= '1';
                theRegisters(7)(15 downto 0) <= datain;
                address <= address + 2;
                cpuState <= STATE_RD7H;

              when others =>
                cpuState <= STATE_FETCH;
            end case; -- unitControl2

          when STATE_RD7H => -- ##################################################
            case unitControl2 is
              when CODE_POP1 =>
                theRegisters(13) <= theRegisters(13) + 2;
                theRegisters(7)(31 downto 16) <= datain;
                if opcode(8) = '0' then
                  addrMux  <= ADDR_PC;
                  cpuState <= STATE_FETCH;
                else
                  cpuState <= STATE_RDPL;
                end if;
              when CODE_LDMIA1 =>
                address <= address + 2;
                theRegisters(7)(31 downto 16) <= datain;
                if opcode108 /= 7 then
                  if LDMread(opcode108) /= '1' then
                    theRegisters(opcode108) <= address + 2;
                  end if;
                end if;
                addrMux  <= ADDR_PC;
                cpuState <= STATE_FETCH;

              when others =>
                cpuState <= STATE_FETCH;
            end case; -- unitControl2

          when STATE_RDPL => -- ##################################################
            case unitControl2 is
              when CODE_POP1 =>
                if theRegisters(14) = x"FFFFFFF9" then
                  cpuState <= STATE_RET;
                else
                  theRegisters(13) <= theRegisters(13) + 2;
                  theRegisters(15)(15 downto 0) <= datain;
                  cpuState <= STATE_RDPH;
                end if;
              when others =>
                cpuState <= STATE_FETCH;
            end case; -- unitControl2

          when STATE_RDPH => -- ##################################################
            case unitControl2 is
              when CODE_POP1 =>
                theRegisters(13) <= theRegisters(13) + 2;
                theRegisters(15)(31 downto 16) <= datain;
                addrMux  <= ADDR_PC;
                cpuState <= STATE_FETCH;
              when others =>
                cpuState <= STATE_FETCH;
            end case; -- unitControl2



          when STATE_WRITE1 => -- ##################################################
            case unitControl2 is
              when CODE_STR1 | CODE_STR2 =>
                address <= address + 2;
                dataout  <= theRegisters(opcode20)(31 downto 16);
                cpuState <= STATE_WRITE2;
              when CODE_STRH1 | CODE_STRB1 | CODE_STRB2 | CODE_STRH2 =>
                addrMux  <= ADDR_PC;
                writeL   <= '1';
                writeH   <= '1';
                cpuState <= STATE_FETCH;
              when CODE_STR3 =>
                address <= address + 2;
                dataout  <= theRegisters(opcode108)(31 downto 16);
                cpuState <= STATE_WRITE2;

              when others =>
                cpuState <= STATE_FETCH;
            end case; -- unitControl2

          when STATE_WRITE2 => -- ##################################################
            case unitControl2 is
              when CODE_STR1 | CODE_STR2 | CODE_STR3 =>
                addrMux  <= ADDR_PC;
                writeL   <= '1';
                writeH   <= '1';
                cpuState <= STATE_FETCH;

              when others =>
                cpuState <= STATE_FETCH;
            end case; -- unitControl2

          when STATE_WRPH =>  -- ##################################################
            case unitControl2 is
              when CODE_PUSH1 =>
                theRegisters(13) <= theRegisters(13) - 2;
                dataout  <= theRegisters(14)(15 downto 0);
                cpuState <= STATE_WRPL;
                
              when others =>
                writeL <= '1';
                writeH <= '1';
                cpuState <= STATE_FETCH;
            end case; -- unitControl2
            
          when STATE_WRPL =>  -- ##################################################
            case unitControl2 is
              when CODE_PUSH1 =>
                if opcode(7 downto 0) = 0 then
                  writeL   <= '1';
                  writeH   <= '1';
                  addrMux  <= ADDR_PC;
                  cpuState <= STATE_FETCH;    
                else                  
                  theRegisters(13) <= theRegisters(13) - 2;
                  if opcode(7) = '1' then
                    dataout <= theRegisters(7)(31 downto 16);
                    cpuState <= STATE_WR7H;
                  elsif opcode(6) = '1' then
                    dataout <= theRegisters(6)(31 downto 16);
                    cpuState <= STATE_WR6H;
                  elsif opcode(5) = '1' then
                    dataout <= theRegisters(5)(31 downto 16);
                    cpuState <= STATE_WR5H;
                  elsif opcode(4) = '1' then
                    dataout <= theRegisters(4)(31 downto 16);
                    cpuState <= STATE_WR4H;
                  elsif opcode(3) = '1' then
                    dataout <= theRegisters(3)(31 downto 16);
                    cpuState <= STATE_WR3H;
                  elsif opcode(2) = '1' then
                    dataout <= theRegisters(2)(31 downto 16);
                    cpuState <= STATE_WR2H;
                  elsif opcode(1) = '1' then
                    dataout <= theRegisters(1)(31 downto 16);
                    cpuState <= STATE_WR1H;
                  else
                    dataout <= theRegisters(0)(31 downto 16);
                    cpuState <= STATE_WR0H;
                  end if;
                end if;
              
              when others =>
                writeL <= '1';
                writeH <= '1';
                cpuState <= STATE_FETCH;
            end case; -- unitControl2
            
          when STATE_WR7H =>  -- ##################################################
            case unitControl2 is
              when CODE_PUSH1 =>
                theRegisters(13) <= theRegisters(13) - 2;
                dataout  <= theRegisters(7)(15 downto 0);
                cpuState <= STATE_WR7L;
              when CODE_STMIA1 =>
                address <= address + 2;
                dataout <= theRegisters(7)(31 downto 16);
                cpuState <= STATE_WR7L;
                
              when others =>
                writeL <= '1';
                writeH <= '1';
                cpuState <= STATE_FETCH;
            end case; -- unitControl2
            
          when STATE_WR7L =>  -- ##################################################
            case unitControl2 is
              when CODE_PUSH1 =>
                if opcode(6 downto 0) = 0 then
                  writeL   <= '1';
                  writeH   <= '1';
                  addrMux  <= ADDR_PC;
                  cpuState <= STATE_FETCH;    
                else                  
                  theRegisters(13) <= theRegisters(13) - 2;
                  if opcode(6) = '1' then
                    dataout <= theRegisters(6)(31 downto 16);
                    cpuState <= STATE_WR6H;
                  elsif opcode(5) = '1' then
                    dataout <= theRegisters(5)(31 downto 16);
                    cpuState <= STATE_WR5H;
                  elsif opcode(4) = '1' then
                    dataout <= theRegisters(4)(31 downto 16);
                    cpuState <= STATE_WR4H;
                  elsif opcode(3) = '1' then
                    dataout <= theRegisters(3)(31 downto 16);
                    cpuState <= STATE_WR3H;
                  elsif opcode(2) = '1' then
                    dataout <= theRegisters(2)(31 downto 16);
                    cpuState <= STATE_WR2H;
                  elsif opcode(1) = '1' then
                    dataout <= theRegisters(1)(31 downto 16);
                    cpuState <= STATE_WR1H;
                  else
                    dataout <= theRegisters(0)(31 downto 16);
                    cpuState <= STATE_WR0H;
                  end if;
                end if;
              when CODE_STMIA1 =>
                address <= address + 2;
                writeL <= '1';
                writeH <= '1';
                addrMux <= ADDR_PC;
                theRegisters(opcode108) <= address + 2;
                cpuState <= STATE_FETCH;
              
              when others =>
                writeL <= '1';
                writeH <= '1';
                cpuState <= STATE_FETCH;
            end case; -- unitControl2
            
          when STATE_WR6H =>  -- ##################################################
            case unitControl2 is
              when CODE_PUSH1 =>
                theRegisters(13) <= theRegisters(13) - 2;
                dataout  <= theRegisters(6)(15 downto 0);
                cpuState <= STATE_WR6L;
              when CODE_STMIA1 =>
                address <= address + 2;
                dataout <= theRegisters(6)(31 downto 16);
                cpuState <= STATE_WR6L;
                
              when others =>
                writeL <= '1';
                writeH <= '1';
                cpuState <= STATE_FETCH;
            end case; -- unitControl2
            
          when STATE_WR6L =>  -- ##################################################
            case unitControl2 is
              when CODE_PUSH1 =>
                if opcode(5 downto 0) = 0 then
                  writeL   <= '1';
                  writeH   <= '1';
                  addrMux  <= ADDR_PC;
                  cpuState <= STATE_FETCH;    
                else                  
                  theRegisters(13) <= theRegisters(13) - 2;
                  if opcode(5) = '1' then
                    dataout <= theRegisters(5)(31 downto 16);
                    cpuState <= STATE_WR5H;
                  elsif opcode(4) = '1' then
                    dataout <= theRegisters(4)(31 downto 16);
                    cpuState <= STATE_WR4H;
                  elsif opcode(3) = '1' then
                    dataout <= theRegisters(3)(31 downto 16);
                    cpuState <= STATE_WR3H;
                  elsif opcode(2) = '1' then
                    dataout <= theRegisters(2)(31 downto 16);
                    cpuState <= STATE_WR2H;
                  elsif opcode(1) = '1' then
                    dataout <= theRegisters(1)(31 downto 16);
                    cpuState <= STATE_WR1H;
                  else
                    dataout <= theRegisters(0)(31 downto 16);
                    cpuState <= STATE_WR0H;
                  end if;
                end if;
              when CODE_STMIA1 =>
                address <= address + 2;
                if opcode(7) = '0' then
                  writeL <= '1';
                  writeH <= '1';
                  addrMux <= ADDR_PC;
                  theRegisters(opcode108) <= address + 2;
                  cpuState <= STATE_FETCH;
                else
                  dataout <= theRegisters(7)(15 downto 0);
                  cpuState <= STATE_WR7H;
                end if;
              
              when others =>
                writeL <= '1';
                writeH <= '1';
                cpuState <= STATE_FETCH;
            end case; -- unitControl2

          when STATE_WR5H =>  -- ##################################################
            case unitControl2 is
              when CODE_PUSH1 =>
                theRegisters(13) <= theRegisters(13) - 2;
                dataout  <= theRegisters(5)(15 downto 0);
                cpuState <= STATE_WR5L;
              when CODE_STMIA1 =>
                address <= address + 2;
                dataout <= theRegisters(5)(31 downto 16);
                cpuState <= STATE_WR5L;
                
              when others =>
                writeL <= '1';
                writeH <= '1';
                cpuState <= STATE_FETCH;
            end case; -- unitControl2
            
          when STATE_WR5L =>  -- ##################################################
            case unitControl2 is
              when CODE_PUSH1 =>
                if opcode(4 downto 0) = 0 then
                  writeL   <= '1';
                  writeH   <= '1';
                  addrMux  <= ADDR_PC;
                  cpuState <= STATE_FETCH;    
                else                  
                  theRegisters(13) <= theRegisters(13) - 2;
                  if opcode(4) = '1' then
                    dataout <= theRegisters(4)(31 downto 16);
                    cpuState <= STATE_WR4H;
                  elsif opcode(3) = '1' then
                    dataout <= theRegisters(3)(31 downto 16);
                    cpuState <= STATE_WR3H;
                  elsif opcode(2) = '1' then
                    dataout <= theRegisters(2)(31 downto 16);
                    cpuState <= STATE_WR2H;
                  elsif opcode(1) = '1' then
                    dataout <= theRegisters(1)(31 downto 16);
                    cpuState <= STATE_WR1H;
                  else
                    dataout <= theRegisters(0)(31 downto 16);
                    cpuState <= STATE_WR0H;
                  end if;
                end if;
              when CODE_STMIA1 =>
                address <= address + 2;
                if opcode(7 downto 6) = 0 then
                  writeL <= '1';
                  writeH <= '1';
                  addrMux <= ADDR_PC;
                  theRegisters(opcode108) <= address + 2;
                  cpuState <= STATE_FETCH;
                else
                  if opcode(6) = '1' then
                    dataout <= theRegisters(6)(15 downto 0);
                    cpuState <= STATE_WR6H;
                  else
                    dataout <= theRegisters(7)(15 downto 0);
                    cpuState <= STATE_WR7H;
                  end if;
                end if;
              
              when others =>
                writeL <= '1';
                writeH <= '1';
                cpuState <= STATE_FETCH;
            end case; -- unitControl2

          when STATE_WR4H =>  -- ##################################################
            case unitControl2 is
              when CODE_PUSH1 =>
                theRegisters(13) <= theRegisters(13) - 2;
                dataout  <= theRegisters(4)(15 downto 0);
                cpuState <= STATE_WR4L;
              when CODE_STMIA1 =>
                address <= address + 2;
                dataout <= theRegisters(4)(31 downto 16);
                cpuState <= STATE_WR4L;
                
              when others =>
                writeL <= '1';
                writeH <= '1';
                cpuState <= STATE_FETCH;
            end case; -- unitControl2
            
          when STATE_WR4L =>  -- ##################################################
            case unitControl2 is
              when CODE_PUSH1 =>
                if opcode(3 downto 0) = 0 then
                  writeL   <= '1';
                  writeH   <= '1';
                  addrMux  <= ADDR_PC;
                  cpuState <= STATE_FETCH;    
                else                  
                  theRegisters(13) <= theRegisters(13) - 2;
                  if opcode(3) = '1' then
                    dataout <= theRegisters(3)(31 downto 16);
                    cpuState <= STATE_WR3H;
                  elsif opcode(2) = '1' then
                    dataout <= theRegisters(2)(31 downto 16);
                    cpuState <= STATE_WR2H;
                  elsif opcode(1) = '1' then
                    dataout <= theRegisters(1)(31 downto 16);
                    cpuState <= STATE_WR1H;
                  else
                    dataout <= theRegisters(0)(31 downto 16);
                    cpuState <= STATE_WR0H;
                  end if;
                end if;
              when CODE_STMIA1 =>
                address <= address + 2;
                if opcode(7 downto 5) = 0 then
                  writeL <= '1';
                  writeH <= '1';
                  addrMux <= ADDR_PC;
                  theRegisters(opcode108) <= address + 2;
                  cpuState <= STATE_FETCH;
                else
                  if opcode(5) = '1' then
                    dataout <= theRegisters(5)(15 downto 0);
                    cpuState <= STATE_WR5H;
                  elsif opcode(6) = '1' then
                    dataout <= theRegisters(6)(15 downto 0);
                    cpuState <= STATE_WR6H;
                  else
                    dataout <= theRegisters(7)(15 downto 0);
                    cpuState <= STATE_WR7H;
                  end if;
                end if;
              
              when others =>
                writeL <= '1';
                writeH <= '1';
                cpuState <= STATE_FETCH;
            end case; -- unitControl2

          when STATE_WR3H =>  -- ##################################################
            case unitControl2 is
              when CODE_PUSH1 =>
                theRegisters(13) <= theRegisters(13) - 2;
                dataout  <= theRegisters(3)(15 downto 0);
                cpuState <= STATE_WR3L;
              when CODE_STMIA1 =>
                address <= address + 2;
                dataout <= theRegisters(3)(31 downto 16);
                cpuState <= STATE_WR3L;
                
              when others =>
                writeL <= '1';
                writeH <= '1';
                cpuState <= STATE_FETCH;
            end case; -- unitControl2
            
          when STATE_WR3L =>  -- ##################################################
            case unitControl2 is
              when CODE_PUSH1 =>
                if opcode(2 downto 0) = 0 then
                  writeL   <= '1';
                  writeH   <= '1';
                  addrMux  <= ADDR_PC;
                  cpuState <= STATE_FETCH;    
                else                  
                  theRegisters(13) <= theRegisters(13) - 2;
                  if opcode(2) = '1' then
                    dataout <= theRegisters(2)(31 downto 16);
                    cpuState <= STATE_WR2H;
                  elsif opcode(1) = '1' then
                    dataout <= theRegisters(1)(31 downto 16);
                    cpuState <= STATE_WR1H;
                  else
                    dataout <= theRegisters(0)(31 downto 16);
                    cpuState <= STATE_WR0H;
                  end if;
                end if;
              when CODE_STMIA1 =>
                address <= address + 2;
                if opcode(7 downto 4) = 0 then
                  writeL <= '1';
                  writeH <= '1';
                  addrMux <= ADDR_PC;
                  theRegisters(opcode108) <= address + 2;
                  cpuState <= STATE_FETCH;
                else
                  if opcode(4) = '1' then
                    dataout <= theRegisters(4)(15 downto 0);
                    cpuState <= STATE_WR4H;
                  elsif opcode(5) = '1' then
                    dataout <= theRegisters(5)(15 downto 0);
                    cpuState <= STATE_WR5H;
                  elsif opcode(6) = '1' then
                    dataout <= theRegisters(6)(15 downto 0);
                    cpuState <= STATE_WR6H;
                  else
                    dataout <= theRegisters(7)(15 downto 0);
                    cpuState <= STATE_WR7H;
                  end if;
                end if;
              
              when others =>
                writeL <= '1';
                writeH <= '1';
                cpuState <= STATE_FETCH;
            end case; -- unitControl2

          when STATE_WR2H =>  -- ##################################################
            case unitControl2 is
              when CODE_PUSH1 =>
                theRegisters(13) <= theRegisters(13) - 2;
                dataout  <= theRegisters(2)(15 downto 0);
                cpuState <= STATE_WR2L;
              when CODE_STMIA1 =>
                address <= address + 2;
                dataout <= theRegisters(2)(31 downto 16);
                cpuState <= STATE_WR2L;
                
              when others =>
                writeL <= '1';
                writeH <= '1';
                cpuState <= STATE_FETCH;
            end case; -- unitControl2
            
          when STATE_WR2L =>  -- ##################################################
            case unitControl2 is
              when CODE_PUSH1 =>
                if opcode(1 downto 0) = 0 then
                  writeL   <= '1';
                  writeH   <= '1';
                  addrMux  <= ADDR_PC;
                  cpuState <= STATE_FETCH;    
                else                  
                  theRegisters(13) <= theRegisters(13) - 2;
                  if opcode(1) = '1' then
                    dataout <= theRegisters(1)(31 downto 16);
                    cpuState <= STATE_WR1H;
                  else
                    dataout <= theRegisters(0)(31 downto 16);
                    cpuState <= STATE_WR0H;
                  end if;
                end if;
              when CODE_STMIA1 =>
                address <= address + 2;
                if opcode(7 downto 3) = 0 then
                  writeL <= '1';
                  writeH <= '1';
                  addrMux <= ADDR_PC;
                  theRegisters(opcode108) <= address + 2;
                  cpuState <= STATE_FETCH;
                else
                  if opcode(3) = '1' then
                    dataout <= theRegisters(3)(15 downto 0);
                    cpuState <= STATE_WR3H;
                  elsif opcode(4) = '1' then
                    dataout <= theRegisters(4)(15 downto 0);
                    cpuState <= STATE_WR4H;
                  elsif opcode(5) = '1' then
                    dataout <= theRegisters(5)(15 downto 0);
                    cpuState <= STATE_WR5H;
                  elsif opcode(6) = '1' then
                    dataout <= theRegisters(6)(15 downto 0);
                    cpuState <= STATE_WR6H;
                  else
                    dataout <= theRegisters(7)(15 downto 0);
                    cpuState <= STATE_WR7H;
                  end if;
                end if;
              
              when others =>
                writeL <= '1';
                writeH <= '1';
                cpuState <= STATE_FETCH;
            end case; -- unitControl2

          when STATE_WR1H =>  -- ##################################################
            case unitControl2 is
              when CODE_PUSH1 =>
                theRegisters(13) <= theRegisters(13) - 2;
                dataout  <= theRegisters(1)(15 downto 0);
                cpuState <= STATE_WR1L;
              when CODE_STMIA1 =>
                address <= address + 2;
                dataout <= theRegisters(1)(31 downto 16);
                cpuState <= STATE_WR1L;
                
              when others =>
                writeL <= '1';
                writeH <= '1';
                cpuState <= STATE_FETCH;
            end case; -- unitControl2
            
          when STATE_WR1L =>  -- ##################################################
            case unitControl2 is
              when CODE_PUSH1 =>
                if opcode(0) = '0' then
                  writeL   <= '1';
                  writeH   <= '1';
                  addrMux  <= ADDR_PC;
                  cpuState <= STATE_FETCH;    
                else                  
                  theRegisters(13) <= theRegisters(13) - 2;
                  dataout <= theRegisters(0)(31 downto 16);
                  cpuState <= STATE_WR0H;
                end if;
            when CODE_STMIA1 =>
                address <= address + 2;
                if opcode(7 downto 2) = 0 then
                  writeL <= '1';
                  writeH <= '1';
                  addrMux <= ADDR_PC;
                  theRegisters(opcode108) <= address + 2;
                  cpuState <= STATE_FETCH;
                else
                  if opcode(2) = '1' then
                    dataout <= theRegisters(2)(15 downto 0);
                    cpuState <= STATE_WR2H;
                  elsif opcode(3) = '1' then
                    dataout <= theRegisters(3)(15 downto 0);
                    cpuState <= STATE_WR3H;
                  elsif opcode(4) = '1' then
                    dataout <= theRegisters(4)(15 downto 0);
                    cpuState <= STATE_WR4H;
                  elsif opcode(5) = '1' then
                    dataout <= theRegisters(5)(15 downto 0);
                    cpuState <= STATE_WR5H;
                  elsif opcode(6) = '1' then
                    dataout <= theRegisters(6)(15 downto 0);
                    cpuState <= STATE_WR6H;
                  else
                    dataout <= theRegisters(7)(15 downto 0);
                    cpuState <= STATE_WR7H;
                  end if;
                end if;
              
              when others =>
                writeL <= '1';
                writeH <= '1';
                cpuState <= STATE_FETCH;
            end case; -- unitControl2

          when STATE_WR0H =>  -- ##################################################
            case unitControl2 is
              when CODE_PUSH1 =>
                theRegisters(13) <= theRegisters(13) - 2;
                dataout  <= theRegisters(0)(15 downto 0);
                cpuState <= STATE_WR0L;
              when CODE_STMIA1 =>
                address <= address + 2;
                dataout <= theRegisters(0)(31 downto 16);
                cpuState <= STATE_WR0L;

                
              when others =>
                writeL <= '1';
                writeH <= '1';
                cpuState <= STATE_FETCH;
            end case; -- unitControl2
            
          when STATE_WR0L =>  -- ##################################################
            case unitControl2 is
              when CODE_PUSH1 =>
                writeL   <= '1';
                writeH   <= '1';
                addrMux  <= ADDR_PC;
                cpuState <= STATE_FETCH;    
              when CODE_STMIA1 =>
                address <= address + 2;
                if opcode(7 downto 1) = 0 then
                  writeL <= '1';
                  writeH <= '1';
                  addrMux <= ADDR_PC;
                  theRegisters(opcode108) <= address + 2;
                  cpuState <= STATE_FETCH;
                else
                  if opcode(1) = '1' then
                    dataout <= theRegisters(1)(15 downto 0);
                    cpuState <= STATE_WR1H;
                  elsif opcode(2) = '1' then
                    dataout <= theRegisters(2)(15 downto 0);
                    cpuState <= STATE_WR2H;
                  elsif opcode(3) = '1' then
                    dataout <= theRegisters(3)(15 downto 0);
                    cpuState <= STATE_WR3H;
                  elsif opcode(4) = '1' then
                    dataout <= theRegisters(4)(15 downto 0);
                    cpuState <= STATE_WR4H;
                  elsif opcode(5) = '1' then
                    dataout <= theRegisters(5)(15 downto 0);
                    cpuState <= STATE_WR5H;
                  elsif opcode(6) = '1' then
                    dataout <= theRegisters(6)(15 downto 0);
                    cpuState <= STATE_WR6H;
                  else
                    dataout <= theRegisters(7)(15 downto 0);
                    cpuState <= STATE_WR7H;
                  end if;
                end if;
              
              when others =>
                writeL <= '1';
                writeH <= '1';
                cpuState <= STATE_FETCH;
            end case; -- unitControl2
            
            
            
          when others =>
            cpuState <= STATE_FETCH;
        end case; -- cpuState
      end if; -- rst = '0'
    end if; -- rising_edge(clk)
  end process;
  
  
end behavior;
