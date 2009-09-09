-- http://www.cs.umbc.edu/help/VHDL/samples/samples.shtml
-- mul32c.vhdl parallel multiply 32 bit x 32 bit to get 64 bit unsigned product
--              uses add32 component and fadd component, includes carry save
--              uses VHDL 'generate' to have less statements

library IEEE;
use IEEE.std_logic_1164.all;

entity add32csa is          -- one stage of carry save adder for multiplier
  port(
    b       : in  std_logic;                      -- a multiplier bit
    a       : in  std_logic_vector(31 downto 0);  -- multiplicand
    sum_in  : in  std_logic_vector(31 downto 0);  -- sums from previous stage
    cin     : in  std_logic_vector(31 downto 0);  -- carrys from previous stage
    sum_out : out std_logic_vector(31 downto 0);  -- sums to next stage
    cout    : out std_logic_vector(31 downto 0)); -- carrys to next stage
end add32csa;

architecture circuits of add32csa is
  signal zero : std_logic_vector(31 downto 0) := X"00000000";
  signal aa : std_logic_vector(31 downto 0) := X"00000000";
  component fadd    -- duplicates entity port
    port(a    : in  std_logic;
         b    : in  std_logic;
         cin  : in  std_logic;
         s    : out std_logic;
         cout : out std_logic);
  end component fadd;
begin  -- circuits of add32csa
  aa <= a when b='1' else zero after 1 ns;
  stage: for I in 0 to 31 generate
    sta: fadd port map(aa(I), sum_in(I), cin(I) , sum_out(I), cout(I));
  end generate stage;  
end architecture circuits; -- of add32csa


library IEEE;
use IEEE.std_logic_1164.all;

entity mul32c is  -- 32 x 32 = 64 bit unsigned product multiplier
  port(a    : in  std_logic_vector(31 downto 0);  -- multiplicand
       b    : in  std_logic_vector(31 downto 0);  -- multiplier
       prod : out std_logic_vector(63 downto 0)); -- product
end mul32c;

architecture circuits of mul32c is
  signal zero : std_logic_vector(31 downto 0) := X"00000000";
  signal nc1  : std_logic;
  type arr32 is array(0 to 31) of std_logic_vector(31 downto 0);
  signal s    : arr32; -- partial sums
  signal c    : arr32; -- partial carries
  signal ss   : arr32; -- shifted sums

  component add32csa is  -- duplicate entity port
    port(b       : in  std_logic;
         a       : in  std_logic_vector(31 downto 0);
         sum_in  : in  std_logic_vector(31 downto 0);
         cin     : in  std_logic_vector(31 downto 0);
         sum_out : out std_logic_vector(31 downto 0);
         cout    : out std_logic_vector(31 downto 0));
  end component add32csa;
  component add32 -- duplicate entity port
    port(a    : in  std_logic_vector(31 downto 0);
         b    : in  std_logic_vector(31 downto 0);
         cin  : in  std_logic; 
         sum  : out std_logic_vector(31 downto 0);
         cout : out std_logic);
  end component add32;
begin  -- circuits of mul32c
  st0: add32csa port map(b(0), a, zero , zero, s(0), c(0));  -- CSA stage
  ss(0) <= '0'&s(0)(31 downto 1) after 1 ns;
  prod(0) <= s(0)(0) after 1 ns;

  stage: for I in 1 to 31 generate
    st: add32csa port map(b(I), a, ss(I-1) , c(I-1), s(I), c(I));  -- CSA stage
    ss(I) <= '0'&s(I)(31 downto 1) after 1 ns;
    prod(I) <= s(I)(0) after 1 ns;
  end generate stage;
  
  add: add32 port map(ss(31), c(31), '0' , prod(63 downto 32), nc1);  -- adder
end architecture circuits; -- of mul32c

