---------------------------------------------------------------
-- Engineer: Ulrich Riedel
--
-- Create Date:    21:47:11 20090508
-- Design Name:    
-- Module Name:    ARMTinclude
-- Project Name:   
-- Target Device:  
-- Tool versions:  
-- Description:
--
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
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
