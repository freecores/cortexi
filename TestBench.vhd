--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   18:16:01 07/17/2009
-- Design Name:   
-- Module Name:   M:/VHDL/CortexI/TestBench.vhd
-- Project Name:  CortexI
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: SOC
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;
 
ENTITY TestBench IS
END TestBench;
 
ARCHITECTURE behavior OF TestBench IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT SOC
    PORT(
         clkExt : IN  std_logic;
         raus : OUT std_logic;
         irq : IN  std_logic;
         RXD : IN  std_logic;
         TXD : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal RXD : std_logic := '0';
   signal irq : std_logic := '1';

 	--Outputs
   signal TXD : std_logic;
   signal raus : std_logic;

   -- Clock period definitions
   constant clk_period : time := 1us;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: SOC PORT MAP (
          clkExt => clk,
          raus => raus,
          irq  => irq,
          RXD => RXD,
          TXD => TXD
        );

   -- Clock process definitions
  clk_process :process
  begin
    clk <= '0';
    wait for 50 ns;
    clk <= '1';
    wait for 50 ns;
  end process;
 
  process
  begin
    wait for 4800 ns;
    irq <= '0';
    wait for 300 ns;
    irq <= '1';
  end process;

   -- Stimulus process
   stim_proc: process
   begin		
      RXD <= '1';
      wait;
   end process;

END;
