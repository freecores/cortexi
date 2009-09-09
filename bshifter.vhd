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

