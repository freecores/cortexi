use STD.textio.all;
LIBRARY ieee;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

Library UNISIM;
use UNISIM.vcomponents.all;

ENTITY SOC IS
   PORT(
     clkExt  : in  std_logic;
     raus    : out std_logic;
     irq     : in  std_logic;
     RXD     : in  std_logic;
     TXD     : out std_logic
   );
END SOC;

ARCHITECTURE behavior OF SOC IS

  component CortexI PORT(
     clk     : in  std_logic;
     rst     : in  std_logic;
     irq     : in  std_logic;
     addr    : out std_logic_vector(31 downto 0);
     wrl     : out std_logic;
     wrh     : out std_logic;
     datain  : in  std_logic_vector(15 downto 0);
     dataout : out std_logic_vector(15 downto 0)
   );
  END component;

  component uart Port (
           clk     : in  std_logic;
           rst     : in  std_logic;
           datain  : in  std_logic_vector(7 downto 0);
           dataout : out std_logic_vector(7 downto 0);
           addr    : in  std_logic_vector(2 downto 0);
           cs      : in  std_logic;
           wr      : in  std_logic;
           serIn   : in  std_logic;
           serOut  : out std_logic
          );
  end component;

  component TheRAM port (
          clka  : IN  std_logic;
          dina  : IN  std_logic_VECTOR(7 downto 0);
          addra : IN  std_logic_VECTOR(13 downto 0);
	        ena   : IN  std_logic;
          wea   : IN  std_logic_VECTOR(0 downto 0);
          douta : OUT std_logic_VECTOR(7 downto 0)
          );
  END component;

  signal bufClk  : std_logic;
  signal clock   : std_logic;
  signal clockFB : std_logic;
  signal clk0    : std_logic;
  signal clkDiv  : std_logic;
  signal clk     : std_logic;
  signal rst     : std_logic := '0';
  signal addr    : std_logic_vector(31 downto 0);
  signal wrl     : std_logic;
  signal wrh     : std_logic;
  signal datain  : std_logic_vector(15 downto 0);
  signal dataout : std_logic_vector(15 downto 0);
  signal cs_uart : std_logic;
  signal cs_ram  : std_logic;
  signal cs_bram : std_logic;
  signal cs_led  : std_logic;
  signal dataFromUart : std_logic_vector(15 downto 0);
  signal dataFromRAM  : std_logic_vector(15 downto 0);
  signal dataFrombigRAM  : std_logic_vector(15 downto 0);
  signal wrl_ram : std_logic;
  signal wrh_ram : std_logic;
  signal wrl_bram : std_logic_vector(0 downto 0);
  signal wrh_bram : std_logic_vector(0 downto 0);
  signal clk_ram : std_logic;

  signal rstCounter : std_logic_vector(15 downto 0) := x"0000";

  type   tRam is array (0 to 2047) of std_logic_vector(15 downto 0);
  signal ram : tRam;

  -- converts a std_logic_vector into a hex string.
  function hstr(slv: std_logic_vector) return string is
    variable hexlen: integer;
    variable longslv : std_logic_vector(67 downto 0) := (others => '0');
    variable hex : string(1 to 16);
    variable fourbit : std_logic_vector(3 downto 0);
  begin
    hexlen := (slv'left+1)/4;
    if (slv'left+1) mod 4 /= 0 then
      hexlen := hexlen + 1;
    end if;
    longslv(slv'left downto 0) := slv;
    for i in (hexlen -1) downto 0 loop
      fourbit := longslv(((i*4)+3) downto (i*4));
      case fourbit is
        when "0000" => hex(hexlen -I) := '0';
        when "0001" => hex(hexlen -I) := '1';
        when "0010" => hex(hexlen -I) := '2';
        when "0011" => hex(hexlen -I) := '3';
        when "0100" => hex(hexlen -I) := '4';
        when "0101" => hex(hexlen -I) := '5';
        when "0110" => hex(hexlen -I) := '6';
        when "0111" => hex(hexlen -I) := '7';
        when "1000" => hex(hexlen -I) := '8';
        when "1001" => hex(hexlen -I) := '9';
        when "1010" => hex(hexlen -I) := 'A';
        when "1011" => hex(hexlen -I) := 'B';
        when "1100" => hex(hexlen -I) := 'C';
        when "1101" => hex(hexlen -I) := 'D';
        when "1110" => hex(hexlen -I) := 'E';
        when "1111" => hex(hexlen -I) := 'F';
        when "ZZZZ" => hex(hexlen -I) := 'z';
        when "UUUU" => hex(hexlen -I) := 'u';
        when "XXXX" => hex(hexlen -I) := 'x';
        when others => hex(hexlen -I) := '?';
      end case;
    end loop;
    return hex(1 to hexlen);
  end hstr;
  
begin
  
--  process(clk, stat)
--    variable my_line : LINE;
--    FILE writeFile : text OPEN write_mode IS "SIMLOG.txt";
--  begin
--    if rising_edge(clk) and (stat = 0) then
--      write(my_line, string'(" 0x"));
--      write(my_line, hstr(addr));
--      write(my_line, string'(" 0x"));
--      write(my_line, hstr(r13));
--      write(my_line, string'(" 0x"));
--      write(my_line, hstr(r14));
--      write(my_line, string'(" 0x"));
--      write(my_line, hstr(r0));
--      write(my_line, string'(" 0x"));
--      write(my_line, hstr(r1));
--      write(my_line, string'(" 0x"));
--      write(my_line, hstr(r2));
--      write(my_line, string'(" 0x"));
--      write(my_line, hstr(r3));
--      write(my_line, string'(" 0x"));
--      write(my_line, hstr(r4));
--      write(my_line, string'(" 0x"));
--      write(my_line, hstr(r5));
--      write(my_line, string'(" 0x"));
--      write(my_line, hstr(r6));
--      write(my_line, string'(" 0x"));
--      write(my_line, hstr(r7));      
--      writeline(writeFile, my_line);
--    end if;
--  end process;

--#################################################################
--  CLOCK
  clk <= clkExt;

--#################################################################
--  LED
  process(clk, rst)
  begin
    if rising_edge(clk) then
      if rst = '0' then
        raus <= '0';
      else
        if cs_led = '1' then
          raus <= dataout(0);
        end if;
      end if;
    end if;
  end process;
  
--#################################################################
--  RESET
  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '0' then
        rstCounter <= rstCounter + 1;
        if rstCounter = x"0003" then
          rst <= '1';
        end if;
      end if;
    end if;
  end process;

--#################################################################
--  CPU
  CPU : CortexI Port map(
           clk     => clk,     --: in  std_logic;
           rst     => rst,     --: in  std_logic;
           irq     => irq,     --: in  std_logic;
           addr    => addr,    --: out std_logic_vector(31 downto 0);
           wrl     => wrl,     --: out std_logic;
           wrh     => wrh,     --: out std_logic;
           datain  => datain,  --: in  std_logic_vector(15 downto 0);
           dataout => dataout  --: out std_logic_vector(15 downto 0)
         );

--#################################################################
--  address decode
  cs_uart  <= '0' when addr(31 downto 16) = x"8000"  else '1'; -- x"80000000";
  cs_ram   <= '1' when addr(31 downto 12) = x"00000" else '0'; -- x"00000000";
  cs_bram  <= '1' when addr(31 downto 15) = "00000000000000001" else '0'; -- x"00008000";
  cs_led   <= '1' when addr(31 downto 16) = x"4000"  else '0'; -- x"40000000";

--#################################################################
--  read data mux
  datain <= dataFromRAM  when cs_ram  = '1' else
            dataFromUart when cs_uart = '0' else
            x"0000";

  wrl_bram(0) <= wrl_ram;
  wrh_bram(0) <= wrh_ram;
--#################################################################
--  RAM
  dataFromRAM <= ram(conv_integer(addr(11 downto 1)));
  process(clk, rst)
  begin
    if rst = '0' then
    ram(0)  <= x"0080"; -- 0000
    ram(1)  <= x"0000"; -- 0002
    ram(2)  <= x"0026"; -- 0004
    ram(3)  <= x"0000"; -- 0006
    ram(4)  <= x"001C"; -- 0008
    ram(5)  <= x"0000"; -- 000A 
    ram(6)  <= x"BF00"; -- 000C NOP
    ram(7)  <= x"BF00"; -- 000E NOP
    ram(8)  <= x"4770"; -- 0010 BX lr
    ram(9)  <= x"BF00"; -- 0012 NOP
    ram(10) <= x"E7FD"; -- 0014 B -3
    ram(11) <= x"0000"; -- 0016
    ram(12) <= x"0c21"; -- 0018
    ram(13) <= x"0000"; -- 001A
    ram(14) <= x"20A5"; -- 001C -- MOVS r0, #0xA5
    ram(15) <= x"2111"; -- 001E
    ram(16) <= x"2222"; -- 0020
    ram(17) <= x"2333"; -- 0022
    ram(18) <= x"4770"; -- 0024 -- BX lr
    ram(19) <= x"2055"; -- 0026 -- MOVS r0, #0x55
    ram(20) <= x"2166"; -- 0028
    ram(21) <= x"2277"; -- 002A
    ram(22) <= x"2388"; -- 002C
    ram(23) <= x"3101"; -- 002E -- ADDS r1,#1
    ram(24) <= x"E7FD"; -- 0030 -- B 2E
    ram(25) <= x"0000"; -- 0032
    ram(26) <= x"0000"; -- 0034
    ram(27) <= x"0000"; -- 0036
    ram(28) <= x"0c21"; -- 0038
    ram(29) <= x"0000"; -- 003A
    ram(30) <= x"0c21"; -- 003C
    ram(31) <= x"0000"; -- 003E
    ram(32) <= x"b5f4"; -- 0040
    ram(33) <= x"b084"; -- 0042
    ram(34) <= x"0004"; -- 0044
    ram(35) <= x"000d"; -- 0046
    ram(36) <= x"4668"; -- 0048
    ram(37) <= x"c030"; -- 004A
    ram(38) <= x"4894"; -- 004C
    ram(39) <= x"4669"; -- 004E
    ram(40) <= x"88c9"; -- 0050
    ram(41) <= x"4001"; -- 0052
    ram(42) <= x"4281"; -- 0054
    ram(43) <= x"4668"; -- 0056
    ram(44) <= x"88c0"; -- 0058
    ram(45) <= x"d118"; -- 005A
    ram(46) <= x"0700"; -- 005C
    ram(47) <= x"d10b"; -- 005E
    ram(48) <= x"4668"; -- 0060
    ram(49) <= x"8880"; -- 0062
    ram(50) <= x"2800"; -- 0064
    ram(51) <= x"d107"; -- 0066
    ram(52) <= x"4668"; -- 0068
    ram(53) <= x"8840"; -- 006A
    ram(54) <= x"2800"; -- 006C
    ram(55) <= x"d103"; -- 006E
    ram(56) <= x"4668"; -- 0070
    ram(57) <= x"8800"; -- 0072
    ram(58) <= x"2800"; -- 0074
    ram(59) <= x"d002"; -- 0076
    ram(60) <= x"0020"; -- 0078
    ram(61) <= x"0029"; -- 007A
    ram(62) <= x"e10e"; -- 007C
    ram(63) <= x"f000"; -- 007E
    ram(64) <= x"fdb5"; -- 0080
    ram(65) <= x"2121"; -- 0082
    ram(66) <= x"6001"; -- 0084
    ram(67) <= x"2000"; -- 0086
    ram(68) <= x"43c0"; -- 0088
    ram(69) <= x"0841"; -- 008A
    ram(70) <= x"e106"; -- 008C
    ram(71) <= x"0440"; -- 008E
    ram(72) <= x"d10b"; -- 0090
    ram(73) <= x"4668"; -- 0092
    ram(74) <= x"8880"; -- 0094
    ram(75) <= x"2800"; -- 0096
    ram(76) <= x"d107"; -- 0098
    ram(77) <= x"4668"; -- 009A
    ram(78) <= x"8840"; -- 009C
    ram(79) <= x"2800"; -- 009E
    ram(80) <= x"d103"; -- 00A0
    ram(81) <= x"4668"; -- 00A2
    ram(82) <= x"8800"; -- 00A4
    ram(83) <= x"2800"; -- 00A6
    ram(84) <= x"d026"; -- 00A8
    ram(85) <= x"0020"; -- 00AA
    ram(86) <= x"0029"; -- 00AC
    ram(87) <= x"22d0"; -- 00AE
    ram(88) <= x"0612"; -- 00B0
    ram(89) <= x"4b7c"; -- 00B2
    ram(90) <= x"f000"; -- 00B4
    ram(91) <= x"fd0c"; -- 00B6
    ram(92) <= x"d304"; -- 00B8
    ram(93) <= x"4a7b"; -- 00BA
    ram(94) <= x"4b7b"; -- 00BC
    ram(95) <= x"f000"; -- 00BE
    ram(96) <= x"fd21"; -- 00C0
    ram(97) <= x"d805"; -- 00C2
    ram(98) <= x"4a7a"; -- 00C4
    ram(99) <= x"4b7b"; -- 00C6
    ram(100) <= x"f000"; -- 00C8
    ram(101) <= x"fa20"; -- 00CA
    ram(102) <= x"0004"; -- 00CC
    ram(103) <= x"000d"; -- 00CE
    ram(104) <= x"4879"; -- 00D0
    ram(105) <= x"497a"; -- 00D2
    ram(106) <= x"0022"; -- 00D4
    ram(107) <= x"002b"; -- 00D6
    ram(108) <= x"f000"; -- 00D8
    ram(109) <= x"faee"; -- 00DA
    ram(110) <= x"aa02"; -- 00DC
    ram(111) <= x"c203"; -- 00DE
    ram(112) <= x"a802"; -- 00E0
    ram(113) <= x"c803"; -- 00E2
    ram(114) <= x"2200"; -- 00E4
    ram(115) <= x"2300"; -- 00E6
    ram(116) <= x"f000"; -- 00E8
    ram(117) <= x"fd0c"; -- 00EA
    ram(118) <= x"a802"; -- 00EC
    ram(119) <= x"c80c"; -- 00EE
    ram(120) <= x"d20d"; -- 00F0
    ram(121) <= x"2000"; -- 00F2
    ram(122) <= x"4972"; -- 00F4
    ram(123) <= x"e00c"; -- 00F6
    ram(124) <= x"9804"; -- 00F8
    ram(125) <= x"2800"; -- 00FA
    ram(126) <= x"d004"; -- 00FC
    ram(127) <= x"466a"; -- 00FE
    ram(128) <= x"2000"; -- 0100
    ram(129) <= x"4970"; -- 0102
    ram(130) <= x"c203"; -- 0104
    ram(131) <= x"e0c7"; -- 0106
    ram(132) <= x"4668"; -- 0108
    ram(133) <= x"c030"; -- 010A
    ram(134) <= x"e0c4"; -- 010C
    ram(135) <= x"2000"; -- 010E
    ram(136) <= x"496d"; -- 0110
    ram(137) <= x"f000"; -- 0112
    ram(138) <= x"f911"; -- 0114
    ram(139) <= x"f000"; -- 0116
    ram(140) <= x"fcb1"; -- 0118
    ram(141) <= x"9904"; -- 011A
    ram(142) <= x"0782"; -- 011C
    ram(143) <= x"0f92"; -- 011E
    ram(144) <= x"1889"; -- 0120
    ram(145) <= x"9104"; -- 0122
    ram(146) <= x"f000"; -- 0124
    ram(147) <= x"fd08"; -- 0126
    ram(148) <= x"0006"; -- 0128
    ram(149) <= x"000f"; -- 012A
    ram(150) <= x"2080"; -- 012C
    ram(151) <= x"05c0"; -- 012E
    ram(152) <= x"4966"; -- 0130
    ram(153) <= x"0032"; -- 0132
    ram(154) <= x"003b"; -- 0134
    ram(155) <= x"f000"; -- 0136
    ram(156) <= x"fabf"; -- 0138
    ram(157) <= x"0002"; -- 013A
    ram(158) <= x"000b"; -- 013C
    ram(159) <= x"0020"; -- 013E
    ram(160) <= x"0029"; -- 0140
    ram(161) <= x"f000"; -- 0142
    ram(162) <= x"f96b"; -- 0144
    ram(163) <= x"0004"; -- 0146
    ram(164) <= x"000d"; -- 0148
    ram(165) <= x"0030"; -- 014A
    ram(166) <= x"0039"; -- 014C
    ram(167) <= x"4a60"; -- 014E
    ram(168) <= x"4b60"; -- 0150
    ram(169) <= x"f000"; -- 0152
    ram(170) <= x"fab1"; -- 0154
    ram(171) <= x"0002"; -- 0156
    ram(172) <= x"000b"; -- 0158
    ram(173) <= x"0020"; -- 015A
    ram(174) <= x"0029"; -- 015C
    ram(175) <= x"f000"; -- 015E
    ram(176) <= x"f95d"; -- 0160
    ram(177) <= x"0004"; -- 0162
    ram(178) <= x"000d"; -- 0164
    ram(179) <= x"2201"; -- 0166
    ram(180) <= x"43d2"; -- 0168
    ram(181) <= x"4b5b"; -- 016A
    ram(182) <= x"f000"; -- 016C
    ram(183) <= x"fcca"; -- 016E
    ram(184) <= x"d80c"; -- 0170
    ram(185) <= x"2200"; -- 0172
    ram(186) <= x"23f9"; -- 0174
    ram(187) <= x"059b"; -- 0176
    ram(188) <= x"f000"; -- 0178
    ram(189) <= x"fcaa"; -- 017A
    ram(190) <= x"d206"; -- 017C
    ram(191) <= x"9804"; -- 017E
    ram(192) <= x"07c0"; -- 0180
    ram(193) <= x"d400"; -- 0182
    ram(194) <= x"e080"; -- 0184
    ram(195) <= x"2400"; -- 0186
    ram(196) <= x"4d4e"; -- 0188
    ram(197) <= x"e07d"; -- 018A
    ram(198) <= x"0022"; -- 018C
    ram(199) <= x"002b"; -- 018E
    ram(200) <= x"f000"; -- 0190
    ram(201) <= x"fa92"; -- 0192
    ram(202) <= x"466a"; -- 0194
    ram(203) <= x"c203"; -- 0196
    ram(204) <= x"9804"; -- 0198
    ram(205) <= x"07c0"; -- 019A
    ram(206) <= x"4668"; -- 019C
    ram(207) <= x"d530"; -- 019E
    ram(208) <= x"c80c"; -- 01A0
    ram(209) <= x"484e"; -- 01A2
    ram(210) <= x"494e"; -- 01A4
    ram(211) <= x"f000"; -- 01A6
    ram(212) <= x"fa87"; -- 01A8
    ram(213) <= x"4a4e"; -- 01AA
    ram(214) <= x"4b4e"; -- 01AC
    ram(215) <= x"f000"; -- 01AE
    ram(216) <= x"f8c3"; -- 01B0
    ram(217) <= x"466a"; -- 01B2
    ram(218) <= x"ca0c"; -- 01B4
    ram(219) <= x"f000"; -- 01B6
    ram(220) <= x"fa7f"; -- 01B8
    ram(221) <= x"4a4c"; -- 01BA
    ram(222) <= x"4b4c"; -- 01BC
    ram(223) <= x"f000"; -- 01BE
    ram(224) <= x"f8bb"; -- 01C0
    ram(225) <= x"466a"; -- 01C2
    ram(226) <= x"ca0c"; -- 01C4
    ram(227) <= x"f000"; -- 01C6
    ram(228) <= x"fa77"; -- 01C8
    ram(229) <= x"4a4a"; -- 01CA
    ram(230) <= x"4b4a"; -- 01CC
    ram(231) <= x"f000"; -- 01CE
    ram(232) <= x"f8b3"; -- 01D0
    ram(233) <= x"466a"; -- 01D2
    ram(234) <= x"ca0c"; -- 01D4
    ram(235) <= x"f000"; -- 01D6
    ram(236) <= x"fa6f"; -- 01D8
    ram(237) <= x"4a48"; -- 01DA
    ram(238) <= x"4b48"; -- 01DC
    ram(239) <= x"f000"; -- 01DE
    ram(240) <= x"f8ab"; -- 01E0
    ram(241) <= x"466a"; -- 01E2
    ram(242) <= x"ca0c"; -- 01E4
    ram(243) <= x"f000"; -- 01E6
    ram(244) <= x"fa67"; -- 01E8
    ram(245) <= x"2251"; -- 01EA
    ram(246) <= x"43d2"; -- 01EC
    ram(247) <= x"4b45"; -- 01EE
    ram(248) <= x"f000"; -- 01F0
    ram(249) <= x"f8a2"; -- 01F2
    ram(250) <= x"466a"; -- 01F4
    ram(251) <= x"ca0c"; -- 01F6
    ram(252) <= x"f000"; -- 01F8
    ram(253) <= x"fa5e"; -- 01FA
    ram(254) <= x"2200"; -- 01FC
    ram(255) <= x"4b31"; -- 01FE
    ram(256) <= x"e03e"; -- 0200
    ram(257) <= x"c803"; -- 0202
    ram(258) <= x"0022"; -- 0204
    ram(259) <= x"002b"; -- 0206
    ram(260) <= x"f000"; -- 0208
    ram(261) <= x"fa56"; -- 020A
    ram(262) <= x"0006"; -- 020C
    ram(263) <= x"000f"; -- 020E
    ram(264) <= x"4668"; -- 0210
    ram(265) <= x"c803"; -- 0212
    ram(266) <= x"4a3c"; -- 0214
    ram(267) <= x"4b3d"; -- 0216
    ram(268) <= x"f000"; -- 0218
    ram(269) <= x"fa4e"; -- 021A
    ram(270) <= x"4a3c"; -- 021C
    ram(271) <= x"4b3d"; -- 021E
    ram(272) <= x"f000"; -- 0220
    ram(273) <= x"f88a"; -- 0222
    ram(274) <= x"0002"; -- 0224
    ram(275) <= x"000b"; -- 0226
    ram(276) <= x"4668"; -- 0228
    ram(277) <= x"c803"; -- 022A
    ram(278) <= x"f000"; -- 022C
    ram(279) <= x"fa44"; -- 022E
    ram(280) <= x"4a39"; -- 0230
    ram(281) <= x"4b3a"; -- 0232
    ram(282) <= x"f000"; -- 0234
    ram(283) <= x"f880"; -- 0236
    ram(284) <= x"0002"; -- 0238
    ram(285) <= x"000b"; -- 023A
    ram(286) <= x"4668"; -- 023C
    ram(287) <= x"c803"; -- 023E
    ram(288) <= x"f000"; -- 0240
    ram(289) <= x"fa3a"; -- 0242
    ram(290) <= x"4a36"; -- 0244
    ram(291) <= x"4b37"; -- 0246
    ram(292) <= x"f000"; -- 0248
    ram(293) <= x"f876"; -- 024A
    ram(294) <= x"0002"; -- 024C
    ram(295) <= x"000b"; -- 024E
    ram(296) <= x"4668"; -- 0250
    ram(297) <= x"c803"; -- 0252
    ram(298) <= x"f000"; -- 0254
    ram(299) <= x"fa30"; -- 0256
    ram(300) <= x"4a33"; -- 0258
    ram(301) <= x"4b34"; -- 025A
    ram(302) <= x"f000"; -- 025C
    ram(303) <= x"f86c"; -- 025E
    ram(304) <= x"0002"; -- 0260
    ram(305) <= x"000b"; -- 0262
    ram(306) <= x"4668"; -- 0264
    ram(307) <= x"c803"; -- 0266
    ram(308) <= x"f000"; -- 0268
    ram(309) <= x"fa26"; -- 026A
    ram(310) <= x"4a30"; -- 026C
    ram(311) <= x"4b31"; -- 026E
    ram(312) <= x"f000"; -- 0270
    ram(313) <= x"f862"; -- 0272
    ram(314) <= x"0032"; -- 0274
    ram(315) <= x"003b"; -- 0276
    ram(316) <= x"f000"; -- 0278
    ram(317) <= x"fa1e"; -- 027A
    ram(318) <= x"0022"; -- 027C
    ram(319) <= x"002b"; -- 027E
    ram(320) <= x"f000"; -- 0280
    ram(321) <= x"f85a"; -- 0282
    ram(322) <= x"0004"; -- 0284
    ram(323) <= x"000d"; -- 0286
    ram(324) <= x"9804"; -- 0288
    ram(325) <= x"0780"; -- 028A
    ram(326) <= x"4668"; -- 028C
    ram(327) <= x"d502"; -- 028E
    ram(328) <= x"2180"; -- 0290
    ram(329) <= x"0609"; -- 0292
    ram(330) <= x"404d"; -- 0294
    ram(331) <= x"c030"; -- 0296
    ram(332) <= x"4668"; -- 0298
    ram(333) <= x"c803"; -- 029A
    ram(334) <= x"b005"; -- 029C
    ram(335) <= x"bdf0"; -- 029E
    ram(336) <= x"7ff0"; -- 02A0
    ram(337) <= x"0000"; -- 02A2
    ram(338) <= x"570f"; -- 02A4
    ram(339) <= x"c1e4"; -- 02A6
    ram(340) <= x"0001"; -- 02A8
    ram(341) <= x"d000"; -- 02AA
    ram(342) <= x"570f"; -- 02AC
    ram(343) <= x"41e4"; -- 02AE
    ram(344) <= x"2d18"; -- 02B0
    ram(345) <= x"5444"; -- 02B2
    ram(346) <= x"21fb"; -- 02B4
    ram(347) <= x"4019"; -- 02B6
    ram(348) <= x"c883"; -- 02B8
    ram(349) <= x"6dc9"; -- 02BA
    ram(350) <= x"5f30"; -- 02BC
    ram(351) <= x"3fe4"; -- 02BE
    ram(352) <= x"0000"; -- 02C0
    ram(353) <= x"3fe0"; -- 02C2
    ram(354) <= x"0000"; -- 02C4
    ram(355) <= x"3ff0"; -- 02C6
    ram(356) <= x"0000"; -- 02C8
    ram(357) <= x"bfe0"; -- 02CA
    ram(358) <= x"21fb"; -- 02CC
    ram(359) <= x"3ff9"; -- 02CE
    ram(360) <= x"9899"; -- 02D0
    ram(361) <= x"1846"; -- 02D2
    ram(362) <= x"442d"; -- 02D4
    ram(363) <= x"3e74"; -- 02D6
    ram(364) <= x"ffff"; -- 02D8
    ram(365) <= x"be3f"; -- 02DA
    ram(366) <= x"2609"; -- 02DC
    ram(367) <= x"100a"; -- 02DE
    ram(368) <= x"ba39"; -- 02E0
    ram(369) <= x"3e21"; -- 02E2
    ram(370) <= x"a83b"; -- 02E4
    ram(371) <= x"c661"; -- 02E6
    ram(372) <= x"7df9"; -- 02E8
    ram(373) <= x"be92"; -- 02EA
    ram(374) <= x"ac63"; -- 02EC
    ram(375) <= x"9030"; -- 02EE
    ram(376) <= x"019f"; -- 02F0
    ram(377) <= x"3efa"; -- 02F2
    ram(378) <= x"fbf6"; -- 02F4
    ram(379) <= x"1651"; -- 02F6
    ram(380) <= x"c16c"; -- 02F8
    ram(381) <= x"bf56"; -- 02FA
    ram(382) <= x"02b1"; -- 02FC
    ram(383) <= x"5555"; -- 02FE
    ram(384) <= x"5555"; -- 0300
    ram(385) <= x"3fa5"; -- 0302
    ram(386) <= x"ffff"; -- 0304
    ram(387) <= x"bfdf"; -- 0306
    ram(388) <= x"8fb0"; -- 0308
    ram(389) <= x"c32f"; -- 030A
    ram(390) <= x"d810"; -- 030C
    ram(391) <= x"3de5"; -- 030E
    ram(392) <= x"0c8f"; -- 0310
    ram(393) <= x"a173"; -- 0312
    ram(394) <= x"e5e1"; -- 0314
    ram(395) <= x"be5a"; -- 0316
    ram(396) <= x"ad4d"; -- 0318
    ram(397) <= x"4fe4"; -- 031A
    ram(398) <= x"1de3"; -- 031C
    ram(399) <= x"3ec7"; -- 031E
    ram(400) <= x"e33e"; -- 0320
    ram(401) <= x"19b5"; -- 0322
    ram(402) <= x"01a0"; -- 0324
    ram(403) <= x"bf2a"; -- 0326
    ram(404) <= x"f0fa"; -- 0328
    ram(405) <= x"1110"; -- 032A
    ram(406) <= x"1111"; -- 032C
    ram(407) <= x"3f81"; -- 032E
    ram(408) <= x"5542"; -- 0330
    ram(409) <= x"5555"; -- 0332
    ram(410) <= x"5555"; -- 0334
    ram(411) <= x"bfc5"; -- 0336
    ram(412) <= x"b4f0"; -- 0338
    ram(413) <= x"2501"; -- 033A
    ram(414) <= x"07ed"; -- 033C
    ram(415) <= x"000f"; -- 033E
    ram(416) <= x"405f"; -- 0340
    ram(417) <= x"d44f"; -- 0342
    ram(418) <= x"428b"; -- 0344
    ram(419) <= x"d100"; -- 0346
    ram(420) <= x"4282"; -- 0348
    ram(421) <= x"d905"; -- 034A
    ram(422) <= x"4684"; -- 034C
    ram(423) <= x"0010"; -- 034E
    ram(424) <= x"4662"; -- 0350
    ram(425) <= x"468c"; -- 0352
    ram(426) <= x"0019"; -- 0354
    ram(427) <= x"4663"; -- 0356
    ram(428) <= x"18df"; -- 0358
    ram(429) <= x"184c"; -- 035A
    ram(430) <= x"0d64"; -- 035C
    ram(431) <= x"0d7f"; -- 035E
    ram(432) <= x"d03a"; -- 0360
    ram(433) <= x"1c66"; -- 0362
    ram(434) <= x"0576"; -- 0364
    ram(435) <= x"d037"; -- 0366
    ram(436) <= x"1be6"; -- 0368
    ram(437) <= x"2e35"; -- 036A
    ram(438) <= x"dc34"; -- 036C
    ram(439) <= x"02db"; -- 036E
    ram(440) <= x"432b"; -- 0370
    ram(441) <= x"0adb"; -- 0372
    ram(442) <= x"0d0c"; -- 0374
    ram(443) <= x"02c9"; -- 0376
    ram(444) <= x"4329"; -- 0378
    ram(445) <= x"12c9"; -- 037A
    ram(446) <= x"2e20"; -- 037C
    ram(447) <= x"db0d"; -- 037E
    ram(448) <= x"0017"; -- 0380
    ram(449) <= x"3e20"; -- 0382
    ram(450) <= x"d006"; -- 0384
    ram(451) <= x"001f"; -- 0386
    ram(452) <= x"41f7"; -- 0388
    ram(453) <= x"40f3"; -- 038A
    ram(454) <= x"405f"; -- 038C
    ram(455) <= x"2600"; -- 038E
    ram(456) <= x"2a01"; -- 0390
    ram(457) <= x"4177"; -- 0392
    ram(458) <= x"18c0"; -- 0394
    ram(459) <= x"4171"; -- 0396
    ram(460) <= x"d20d"; -- 0398
    ram(461) <= x"e017"; -- 039A
    ram(462) <= x"0017"; -- 039C
    ram(463) <= x"41f7"; -- 039E
    ram(464) <= x"40f2"; -- 03A0
    ram(465) <= x"4057"; -- 03A2
    ram(466) <= x"41f3"; -- 03A4
    ram(467) <= x"405a"; -- 03A6
    ram(468) <= x"40b3"; -- 03A8
    ram(469) <= x"40f3"; -- 03AA
    ram(470) <= x"405a"; -- 03AC
    ram(471) <= x"2600"; -- 03AE
    ram(472) <= x"1880"; -- 03B0
    ram(473) <= x"4159"; -- 03B2
    ram(474) <= x"d30a"; -- 03B4
    ram(475) <= x"1ca2"; -- 03B6
    ram(476) <= x"0552"; -- 03B8
    ram(477) <= x"d00f"; -- 03BA
    ram(478) <= x"07c2"; -- 03BC
    ram(479) <= x"2f01"; -- 03BE
    ram(480) <= x"4172"; -- 03C0
    ram(481) <= x"0017"; -- 03C2
    ram(482) <= x"0840"; -- 03C4
    ram(483) <= x"07cb"; -- 03C6
    ram(484) <= x"4318"; -- 03C8
    ram(485) <= x"0849"; -- 03CA
    ram(486) <= x"1c64"; -- 03CC
    ram(487) <= x"0524"; -- 03CE
    ram(488) <= x"0842"; -- 03D0
    ram(489) <= x"41af"; -- 03D2
    ram(490) <= x"4170"; -- 03D4
    ram(491) <= x"4161"; -- 03D6
    ram(492) <= x"bcf0"; -- 03D8
    ram(493) <= x"4770"; -- 03DA
    ram(494) <= x"1c64"; -- 03DC
    ram(495) <= x"0521"; -- 03DE
    ram(496) <= x"2000"; -- 03E0
    ram(497) <= x"e7f9"; -- 03E2
    ram(498) <= x"406b"; -- 03E4
    ram(499) <= x"e01f"; -- 03E6
    ram(500) <= x"406b"; -- 03E8
    ram(501) <= x"e7ab"; -- 03EA
    ram(502) <= x"b4f0"; -- 03EC
    ram(503) <= x"2501"; -- 03EE
    ram(504) <= x"07ed"; -- 03F0
    ram(505) <= x"000f"; -- 03F2
    ram(506) <= x"405f"; -- 03F4
    ram(507) <= x"d4f7"; -- 03F6
    ram(508) <= x"000c"; -- 03F8
    ram(509) <= x"1a87"; -- 03FA
    ram(510) <= x"419c"; -- 03FC
    ram(511) <= x"d21b"; -- 03FE
    ram(512) <= x"1bc0"; -- 0400
    ram(513) <= x"41a1"; -- 0402
    ram(514) <= x"19d2"; -- 0404
    ram(515) <= x"4163"; -- 0406
    ram(516) <= x"e018"; -- 0408
    ram(517) <= x"42f7"; -- 040A
    ram(518) <= x"d1e4"; -- 040C
    ram(519) <= x"43e9"; -- 040E
    ram(520) <= x"e7e2"; -- 0410
    ram(521) <= x"4224"; -- 0412
    ram(522) <= x"d1e0"; -- 0414
    ram(523) <= x"2000"; -- 0416
    ram(524) <= x"2100"; -- 0418
    ram(525) <= x"e7dd"; -- 041A
    ram(526) <= x"b4f0"; -- 041C
    ram(527) <= x"2501"; -- 041E
    ram(528) <= x"07ed"; -- 0420
    ram(529) <= x"000f"; -- 0422
    ram(530) <= x"405f"; -- 0424
    ram(531) <= x"d4df"; -- 0426
    ram(532) <= x"000c"; -- 0428
    ram(533) <= x"1a87"; -- 042A
    ram(534) <= x"419c"; -- 042C
    ram(535) <= x"d205"; -- 042E
    ram(536) <= x"1bc0"; -- 0430
    ram(537) <= x"41a1"; -- 0432
    ram(538) <= x"19d2"; -- 0434
    ram(539) <= x"4163"; -- 0436
    ram(540) <= x"4069"; -- 0438
    ram(541) <= x"406b"; -- 043A
    ram(542) <= x"0aae"; -- 043C
    ram(543) <= x"18df"; -- 043E
    ram(544) <= x"184c"; -- 0440
    ram(545) <= x"42f4"; -- 0442
    ram(546) <= x"d2e1"; -- 0444
    ram(547) <= x"0d64"; -- 0446
    ram(548) <= x"0d7f"; -- 0448
    ram(549) <= x"d0e2"; -- 044A
    ram(550) <= x"1be6"; -- 044C
    ram(551) <= x"2e36"; -- 044E
    ram(552) <= x"dcc2"; -- 0450
    ram(553) <= x"02db"; -- 0452
    ram(554) <= x"432b"; -- 0454
    ram(555) <= x"0adb"; -- 0456
    ram(556) <= x"46a4"; -- 0458
    ram(557) <= x"0d0c"; -- 045A
    ram(558) <= x"02c9"; -- 045C
    ram(559) <= x"4329"; -- 045E
    ram(560) <= x"0ac9"; -- 0460
    ram(561) <= x"2e01"; -- 0462
    ram(562) <= x"dc24"; -- 0464
    ram(563) <= x"d104"; -- 0466
    ram(564) <= x"07d6"; -- 0468
    ram(565) <= x"0852"; -- 046A
    ram(566) <= x"07df"; -- 046C
    ram(567) <= x"433a"; -- 046E
    ram(568) <= x"085b"; -- 0470
    ram(569) <= x"0aef"; -- 0472
    ram(570) <= x"4276"; -- 0474
    ram(571) <= x"4190"; -- 0476
    ram(572) <= x"4199"; -- 0478
    ram(573) <= x"d014"; -- 047A
    ram(574) <= x"4239"; -- 047C
    ram(575) <= x"d137"; -- 047E
    ram(576) <= x"19b6"; -- 0480
    ram(577) <= x"4140"; -- 0482
    ram(578) <= x"4149"; -- 0484
    ram(579) <= x"1c76"; -- 0486
    ram(580) <= x"4239"; -- 0488
    ram(581) <= x"d104"; -- 048A
    ram(582) <= x"1c76"; -- 048C
    ram(583) <= x"1800"; -- 048E
    ram(584) <= x"4149"; -- 0490
    ram(585) <= x"4239"; -- 0492
    ram(586) <= x"d0fa"; -- 0494
    ram(587) <= x"43b9"; -- 0496
    ram(588) <= x"4667"; -- 0498
    ram(589) <= x"42b7"; -- 049A
    ram(590) <= x"d931"; -- 049C
    ram(591) <= x"1ba4"; -- 049E
    ram(592) <= x"0524"; -- 04A0
    ram(593) <= x"4321"; -- 04A2
    ram(594) <= x"e798"; -- 04A4
    ram(595) <= x"4200"; -- 04A6
    ram(596) <= x"d1ea"; -- 04A8
    ram(597) <= x"4236"; -- 04AA
    ram(598) <= x"d1e8"; -- 04AC
    ram(599) <= x"e793"; -- 04AE
    ram(600) <= x"2e20"; -- 04B0
    ram(601) <= x"dd0b"; -- 04B2
    ram(602) <= x"3e20"; -- 04B4
    ram(603) <= x"001f"; -- 04B6
    ram(604) <= x"40f3"; -- 04B8
    ram(605) <= x"41f7"; -- 04BA
    ram(606) <= x"405f"; -- 04BC
    ram(607) <= x"2a01"; -- 04BE
    ram(608) <= x"2200"; -- 04C0
    ram(609) <= x"4157"; -- 04C2
    ram(610) <= x"427e"; -- 04C4
    ram(611) <= x"4198"; -- 04C6
    ram(612) <= x"4191"; -- 04C8
    ram(613) <= x"e00b"; -- 04CA
    ram(614) <= x"0017"; -- 04CC
    ram(615) <= x"41f7"; -- 04CE
    ram(616) <= x"40f2"; -- 04D0
    ram(617) <= x"4057"; -- 04D2
    ram(618) <= x"41f3"; -- 04D4
    ram(619) <= x"405a"; -- 04D6
    ram(620) <= x"40b3"; -- 04D8
    ram(621) <= x"40f3"; -- 04DA
    ram(622) <= x"405a"; -- 04DC
    ram(623) <= x"427e"; -- 04DE
    ram(624) <= x"4190"; -- 04E0
    ram(625) <= x"4199"; -- 04E2
    ram(626) <= x"030a"; -- 04E4
    ram(627) <= x"d203"; -- 04E6
    ram(628) <= x"1e64"; -- 04E8
    ram(629) <= x"19b6"; -- 04EA
    ram(630) <= x"4140"; -- 04EC
    ram(631) <= x"4149"; -- 04EE
    ram(632) <= x"2700"; -- 04F0
    ram(633) <= x"1e64"; -- 04F2
    ram(634) <= x"0524"; -- 04F4
    ram(635) <= x"0842"; -- 04F6
    ram(636) <= x"41ae"; -- 04F8
    ram(637) <= x"4178"; -- 04FA
    ram(638) <= x"4161"; -- 04FC
    ram(639) <= x"bcf0"; -- 04FE
    ram(640) <= x"4770"; -- 0500
    ram(641) <= x"0ae4"; -- 0502
    ram(642) <= x"07e1"; -- 0504
    ram(643) <= x"2000"; -- 0506
    ram(644) <= x"e766"; -- 0508
    ram(645) <= x"0000"; -- 050A
    ram(646) <= x"b5f8"; -- 050C
    ram(647) <= x"b40c"; -- 050E
    ram(648) <= x"b084"; -- 0510
    ram(649) <= x"0006"; -- 0512
    ram(650) <= x"000f"; -- 0514
    ram(651) <= x"4668"; -- 0516
    ram(652) <= x"c0c0"; -- 0518
    ram(653) <= x"4a66"; -- 051A
    ram(654) <= x"4668"; -- 051C
    ram(655) <= x"88c0"; -- 051E
    ram(656) <= x"4010"; -- 0520
    ram(657) <= x"4290"; -- 0522
    ram(658) <= x"4668"; -- 0524
    ram(659) <= x"88c0"; -- 0526
    ram(660) <= x"d111"; -- 0528
    ram(661) <= x"0700"; -- 052A
    ram(662) <= x"d10b"; -- 052C
    ram(663) <= x"4668"; -- 052E
    ram(664) <= x"8880"; -- 0530
    ram(665) <= x"2800"; -- 0532
    ram(666) <= x"d107"; -- 0534
    ram(667) <= x"4668"; -- 0536
    ram(668) <= x"8840"; -- 0538
    ram(669) <= x"2800"; -- 053A
    ram(670) <= x"d103"; -- 053C
    ram(671) <= x"4668"; -- 053E
    ram(672) <= x"8800"; -- 0540
    ram(673) <= x"2800"; -- 0542
    ram(674) <= x"d001"; -- 0544
    ram(675) <= x"2302"; -- 0546
    ram(676) <= x"e013"; -- 0548
    ram(677) <= x"2301"; -- 054A
    ram(678) <= x"e011"; -- 054C
    ram(679) <= x"0440"; -- 054E
    ram(680) <= x"d10b"; -- 0550
    ram(681) <= x"4668"; -- 0552
    ram(682) <= x"8880"; -- 0554
    ram(683) <= x"2800"; -- 0556
    ram(684) <= x"d107"; -- 0558
    ram(685) <= x"4668"; -- 055A
    ram(686) <= x"8840"; -- 055C
    ram(687) <= x"2800"; -- 055E
    ram(688) <= x"d103"; -- 0560
    ram(689) <= x"4668"; -- 0562
    ram(690) <= x"8800"; -- 0564
    ram(691) <= x"2800"; -- 0566
    ram(692) <= x"d002"; -- 0568
    ram(693) <= x"2300"; -- 056A
    ram(694) <= x"43db"; -- 056C
    ram(695) <= x"e000"; -- 056E
    ram(696) <= x"2300"; -- 0570
    ram(697) <= x"466c"; -- 0572
    ram(698) <= x"a804"; -- 0574
    ram(699) <= x"c803"; -- 0576
    ram(700) <= x"c403"; -- 0578
    ram(701) <= x"4668"; -- 057A
    ram(702) <= x"88c0"; -- 057C
    ram(703) <= x"4010"; -- 057E
    ram(704) <= x"4290"; -- 0580
    ram(705) <= x"4668"; -- 0582
    ram(706) <= x"88c0"; -- 0584
    ram(707) <= x"d111"; -- 0586
    ram(708) <= x"0700"; -- 0588
    ram(709) <= x"d10b"; -- 058A
    ram(710) <= x"4668"; -- 058C
    ram(711) <= x"8880"; -- 058E
    ram(712) <= x"2800"; -- 0590
    ram(713) <= x"d107"; -- 0592
    ram(714) <= x"4668"; -- 0594
    ram(715) <= x"8840"; -- 0596
    ram(716) <= x"2800"; -- 0598
    ram(717) <= x"d103"; -- 059A
    ram(718) <= x"4668"; -- 059C
    ram(719) <= x"8800"; -- 059E
    ram(720) <= x"2800"; -- 05A0
    ram(721) <= x"d001"; -- 05A2
    ram(722) <= x"2002"; -- 05A4
    ram(723) <= x"e011"; -- 05A6
    ram(724) <= x"2001"; -- 05A8
    ram(725) <= x"e00f"; -- 05AA
    ram(726) <= x"0440"; -- 05AC
    ram(727) <= x"d10b"; -- 05AE
    ram(728) <= x"4668"; -- 05B0
    ram(729) <= x"8880"; -- 05B2
    ram(730) <= x"2800"; -- 05B4
    ram(731) <= x"d107"; -- 05B6
    ram(732) <= x"4668"; -- 05B8
    ram(733) <= x"8840"; -- 05BA
    ram(734) <= x"2800"; -- 05BC
    ram(735) <= x"d103"; -- 05BE
    ram(736) <= x"4668"; -- 05C0
    ram(737) <= x"8800"; -- 05C2
    ram(738) <= x"2800"; -- 05C4
    ram(739) <= x"d001"; -- 05C6
    ram(740) <= x"2000"; -- 05C8
    ram(741) <= x"43c0"; -- 05CA
    ram(742) <= x"2b00"; -- 05CC
    ram(743) <= x"d506"; -- 05CE
    ram(744) <= x"2800"; -- 05D0
    ram(745) <= x"d413"; -- 05D2
    ram(746) <= x"2802"; -- 05D4
    ram(747) <= x"d105"; -- 05D6
    ram(748) <= x"a804"; -- 05D8
    ram(749) <= x"c803"; -- 05DA
    ram(750) <= x"e067"; -- 05DC
    ram(751) <= x"2b02"; -- 05DE
    ram(752) <= x"d1f8"; -- 05E0
    ram(753) <= x"e062"; -- 05E2
    ram(754) <= x"2b01"; -- 05E4
    ram(755) <= x"d001"; -- 05E6
    ram(756) <= x"2800"; -- 05E8
    ram(757) <= x"d15e"; -- 05EA
    ram(758) <= x"f000"; -- 05EC
    ram(759) <= x"fafe"; -- 05EE
    ram(760) <= x"2121"; -- 05F0
    ram(761) <= x"6001"; -- 05F2
    ram(762) <= x"2000"; -- 05F4
    ram(763) <= x"43c0"; -- 05F6
    ram(764) <= x"0841"; -- 05F8
    ram(765) <= x"e058"; -- 05FA
    ram(766) <= x"a804"; -- 05FC
    ram(767) <= x"c803"; -- 05FE
    ram(768) <= x"2200"; -- 0600
    ram(769) <= x"2300"; -- 0602
    ram(770) <= x"f000"; -- 0604
    ram(771) <= x"fa64"; -- 0606
    ram(772) <= x"d206"; -- 0608
    ram(773) <= x"aa04"; -- 060A
    ram(774) <= x"a804"; -- 060C
    ram(775) <= x"c803"; -- 060E
    ram(776) <= x"2380"; -- 0610
    ram(777) <= x"061b"; -- 0612
    ram(778) <= x"4059"; -- 0614
    ram(779) <= x"c203"; -- 0616
    ram(780) <= x"2400"; -- 0618
    ram(781) <= x"0030"; -- 061A
    ram(782) <= x"0039"; -- 061C
    ram(783) <= x"2200"; -- 061E
    ram(784) <= x"2300"; -- 0620
    ram(785) <= x"f000"; -- 0622
    ram(786) <= x"fa55"; -- 0624
    ram(787) <= x"d204"; -- 0626
    ram(788) <= x"2080"; -- 0628
    ram(789) <= x"0600"; -- 062A
    ram(790) <= x"4047"; -- 062C
    ram(791) <= x"2501"; -- 062E
    ram(792) <= x"e000"; -- 0630
    ram(793) <= x"2500"; -- 0632
    ram(794) <= x"466a"; -- 0634
    ram(795) <= x"a804"; -- 0636
    ram(796) <= x"c803"; -- 0638
    ram(797) <= x"c203"; -- 063A
    ram(798) <= x"4669"; -- 063C
    ram(799) <= x"a802"; -- 063E
    ram(800) <= x"1c80"; -- 0640
    ram(801) <= x"f000"; -- 0642
    ram(802) <= x"f9df"; -- 0644
    ram(803) <= x"e018"; -- 0646
    ram(804) <= x"1e64"; -- 0648
    ram(805) <= x"b224"; -- 064A
    ram(806) <= x"2c00"; -- 064C
    ram(807) <= x"d414"; -- 064E
    ram(808) <= x"466a"; -- 0650
    ram(809) <= x"a804"; -- 0652
    ram(810) <= x"c803"; -- 0654
    ram(811) <= x"c203"; -- 0656
    ram(812) <= x"0021"; -- 0658
    ram(813) <= x"4668"; -- 065A
    ram(814) <= x"f000"; -- 065C
    ram(815) <= x"f8ee"; -- 065E
    ram(816) <= x"0030"; -- 0660
    ram(817) <= x"0039"; -- 0662
    ram(818) <= x"466a"; -- 0664
    ram(819) <= x"ca0c"; -- 0666
    ram(820) <= x"f000"; -- 0668
    ram(821) <= x"fa4c"; -- 066A
    ram(822) <= x"d8ec"; -- 066C
    ram(823) <= x"466a"; -- 066E
    ram(824) <= x"ca0c"; -- 0670
    ram(825) <= x"f7ff"; -- 0672
    ram(826) <= x"fed3"; -- 0674
    ram(827) <= x"0006"; -- 0676
    ram(828) <= x"000f"; -- 0678
    ram(829) <= x"4668"; -- 067A
    ram(830) <= x"c0c0"; -- 067C
    ram(831) <= x"2c00"; -- 067E
    ram(832) <= x"d40e"; -- 0680
    ram(833) <= x"4669"; -- 0682
    ram(834) <= x"f000"; -- 0684
    ram(835) <= x"f9be"; -- 0686
    ram(836) <= x"2800"; -- 0688
    ram(837) <= x"d009"; -- 068A
    ram(838) <= x"4668"; -- 068C
    ram(839) <= x"8900"; -- 068E
    ram(840) <= x"4669"; -- 0690
    ram(841) <= x"8949"; -- 0692
    ram(842) <= x"1a44"; -- 0694
    ram(843) <= x"b224"; -- 0696
    ram(844) <= x"2c00"; -- 0698
    ram(845) <= x"d401"; -- 069A
    ram(846) <= x"d5d8"; -- 069C
    ram(847) <= x"e7ec"; -- 069E
    ram(848) <= x"2d00"; -- 06A0
    ram(849) <= x"d002"; -- 06A2
    ram(850) <= x"2080"; -- 06A4
    ram(851) <= x"0600"; -- 06A6
    ram(852) <= x"4047"; -- 06A8
    ram(853) <= x"0030"; -- 06AA
    ram(854) <= x"0039"; -- 06AC
    ram(855) <= x"b007"; -- 06AE
    ram(856) <= x"bdf0"; -- 06B0
    ram(857) <= x"bf00"; -- 06B2
    ram(858) <= x"7ff0"; -- 06B4
    ram(859) <= x"0000"; -- 06B6
    ram(860) <= x"b5f4"; -- 06B8
    ram(861) <= x"000e"; -- 06BA
    ram(862) <= x"405e"; -- 06BC
    ram(863) <= x"2501"; -- 06BE
    ram(864) <= x"07ed"; -- 06C0
    ram(865) <= x"402e"; -- 06C2
    ram(866) <= x"46b4"; -- 06C4
    ram(867) <= x"0aae"; -- 06C6
    ram(868) <= x"18df"; -- 06C8
    ram(869) <= x"184c"; -- 06CA
    ram(870) <= x"42f4"; -- 06CC
    ram(871) <= x"d208"; -- 06CE
    ram(872) <= x"42f7"; -- 06D0
    ram(873) <= x"d20e"; -- 06D2
    ram(874) <= x"0d64"; -- 06D4
    ram(875) <= x"d001"; -- 06D6
    ram(876) <= x"0d7f"; -- 06D8
    ram(877) <= x"d112"; -- 06DA
    ram(878) <= x"2000"; -- 06DC
    ram(879) <= x"4661"; -- 06DE
    ram(880) <= x"bdf4"; -- 06E0
    ram(881) <= x"d105"; -- 06E2
    ram(882) <= x"42f7"; -- 06E4
    ram(883) <= x"d801"; -- 06E6
    ram(884) <= x"0d7f"; -- 06E8
    ram(885) <= x"d105"; -- 06EA
    ram(886) <= x"2000"; -- 06EC
    ram(887) <= x"43c1"; -- 06EE
    ram(888) <= x"bdf4"; -- 06F0
    ram(889) <= x"d1fb"; -- 06F2
    ram(890) <= x"0d64"; -- 06F4
    ram(891) <= x"d0f9"; -- 06F6
    ram(892) <= x"2000"; -- 06F8
    ram(893) <= x"43c1"; -- 06FA
    ram(894) <= x"0549"; -- 06FC
    ram(895) <= x"0849"; -- 06FE
    ram(896) <= x"e08f"; -- 0700
    ram(897) <= x"19e4"; -- 0702
    ram(898) <= x"02c9"; -- 0704
    ram(899) <= x"02db"; -- 0706
    ram(900) <= x"4329"; -- 0708
    ram(901) <= x"432b"; -- 070A
    ram(902) <= x"0adb"; -- 070C
    ram(903) <= x"0d46"; -- 070E
    ram(904) <= x"02c0"; -- 0710
    ram(905) <= x"4331"; -- 0712
    ram(906) <= x"468e"; -- 0714
    ram(907) <= x"b430"; -- 0716
    ram(908) <= x"b287"; -- 0718
    ram(909) <= x"b295"; -- 071A
    ram(910) <= x"437d"; -- 071C
    ram(911) <= x"0c2e"; -- 071E
    ram(912) <= x"b2ad"; -- 0720
    ram(913) <= x"0c14"; -- 0722
    ram(914) <= x"437c"; -- 0724
    ram(915) <= x"19a4"; -- 0726
    ram(916) <= x"0c26"; -- 0728
    ram(917) <= x"0424"; -- 072A
    ram(918) <= x"4325"; -- 072C
    ram(919) <= x"b29c"; -- 072E
    ram(920) <= x"437c"; -- 0730
    ram(921) <= x"19a4"; -- 0732
    ram(922) <= x"0c19"; -- 0734
    ram(923) <= x"4379"; -- 0736
    ram(924) <= x"0c27"; -- 0738
    ram(925) <= x"19c9"; -- 073A
    ram(926) <= x"b2a4"; -- 073C
    ram(927) <= x"040f"; -- 073E
    ram(928) <= x"433c"; -- 0740
    ram(929) <= x"0c09"; -- 0742
    ram(930) <= x"0c00"; -- 0744
    ram(931) <= x"b297"; -- 0746
    ram(932) <= x"4347"; -- 0748
    ram(933) <= x"0c2e"; -- 074A
    ram(934) <= x"19be"; -- 074C
    ram(935) <= x"4335"; -- 074E
    ram(936) <= x"b2ad"; -- 0750
    ram(937) <= x"0c17"; -- 0752
    ram(938) <= x"4347"; -- 0754
    ram(939) <= x"0c36"; -- 0756
    ram(940) <= x"19bf"; -- 0758
    ram(941) <= x"b2a6"; -- 075A
    ram(942) <= x"19bf"; -- 075C
    ram(943) <= x"043e"; -- 075E
    ram(944) <= x"4335"; -- 0760
    ram(945) <= x"0c24"; -- 0762
    ram(946) <= x"0c3e"; -- 0764
    ram(947) <= x"1936"; -- 0766
    ram(948) <= x"b29f"; -- 0768
    ram(949) <= x"4347"; -- 076A
    ram(950) <= x"19bf"; -- 076C
    ram(951) <= x"b2bc"; -- 076E
    ram(952) <= x"0c3e"; -- 0770
    ram(953) <= x"1989"; -- 0772
    ram(954) <= x"0c1f"; -- 0774
    ram(955) <= x"4347"; -- 0776
    ram(956) <= x"187f"; -- 0778
    ram(957) <= x"043e"; -- 077A
    ram(958) <= x"4334"; -- 077C
    ram(959) <= x"0c39"; -- 077E
    ram(960) <= x"4670"; -- 0780
    ram(961) <= x"b280"; -- 0782
    ram(962) <= x"b297"; -- 0784
    ram(963) <= x"4347"; -- 0786
    ram(964) <= x"0c2e"; -- 0788
    ram(965) <= x"19be"; -- 078A
    ram(966) <= x"4335"; -- 078C
    ram(967) <= x"b2ad"; -- 078E
    ram(968) <= x"0c17"; -- 0790
    ram(969) <= x"4347"; -- 0792
    ram(970) <= x"0c36"; -- 0794
    ram(971) <= x"19bf"; -- 0796
    ram(972) <= x"b2a6"; -- 0798
    ram(973) <= x"19bf"; -- 079A
    ram(974) <= x"043e"; -- 079C
    ram(975) <= x"4335"; -- 079E
    ram(976) <= x"0c24"; -- 07A0
    ram(977) <= x"0c3e"; -- 07A2
    ram(978) <= x"1936"; -- 07A4
    ram(979) <= x"b29f"; -- 07A6
    ram(980) <= x"4347"; -- 07A8
    ram(981) <= x"19bf"; -- 07AA
    ram(982) <= x"b2bc"; -- 07AC
    ram(983) <= x"0c3e"; -- 07AE
    ram(984) <= x"1989"; -- 07B0
    ram(985) <= x"0c1f"; -- 07B2
    ram(986) <= x"4347"; -- 07B4
    ram(987) <= x"187f"; -- 07B6
    ram(988) <= x"043e"; -- 07B8
    ram(989) <= x"4334"; -- 07BA
    ram(990) <= x"0c39"; -- 07BC
    ram(991) <= x"4677"; -- 07BE
    ram(992) <= x"0c3f"; -- 07C0
    ram(993) <= x"b290"; -- 07C2
    ram(994) <= x"4378"; -- 07C4
    ram(995) <= x"0c2e"; -- 07C6
    ram(996) <= x"1980"; -- 07C8
    ram(997) <= x"0406"; -- 07CA
    ram(998) <= x"b2ad"; -- 07CC
    ram(999) <= x"432e"; -- 07CE
    ram(1000) <= x"0c05"; -- 07D0
    ram(1001) <= x"b2a0"; -- 07D2
    ram(1002) <= x"182d"; -- 07D4
    ram(1003) <= x"0c12"; -- 07D6
    ram(1004) <= x"437a"; -- 07D8
    ram(1005) <= x"1950"; -- 07DA
    ram(1006) <= x"0c02"; -- 07DC
    ram(1007) <= x"b280"; -- 07DE
    ram(1008) <= x"0c24"; -- 07E0
    ram(1009) <= x"18a4"; -- 07E2
    ram(1010) <= x"b29a"; -- 07E4
    ram(1011) <= x"437a"; -- 07E6
    ram(1012) <= x"1912"; -- 07E8
    ram(1013) <= x"0414"; -- 07EA
    ram(1014) <= x"4320"; -- 07EC
    ram(1015) <= x"0c12"; -- 07EE
    ram(1016) <= x"1889"; -- 07F0
    ram(1017) <= x"0c1b"; -- 07F2
    ram(1018) <= x"437b"; -- 07F4
    ram(1019) <= x"18c9"; -- 07F6
    ram(1020) <= x"bc30"; -- 07F8
    ram(1021) <= x"0aef"; -- 07FA
    ram(1022) <= x"4239"; -- 07FC
    ram(1023) <= x"d103"; -- 07FE
    ram(1024) <= x"19b6"; -- 0800
    ram(1025) <= x"4140"; -- 0802
    ram(1026) <= x"4149"; -- 0804
    ram(1027) <= x"1e64"; -- 0806
    ram(1028) <= x"126f"; -- 0808
    ram(1029) <= x"0dbf"; -- 080A
    ram(1030) <= x"1be4"; -- 080C
    ram(1031) <= x"db0b"; -- 080E
    ram(1032) <= x"19ff"; -- 0810
    ram(1033) <= x"42bc"; -- 0812
    ram(1034) <= x"da11"; -- 0814
    ram(1035) <= x"0524"; -- 0816
    ram(1036) <= x"2700"; -- 0818
    ram(1037) <= x"0842"; -- 081A
    ram(1038) <= x"41ae"; -- 081C
    ram(1039) <= x"4178"; -- 081E
    ram(1040) <= x"4161"; -- 0820
    ram(1041) <= x"4666"; -- 0822
    ram(1042) <= x"4331"; -- 0824
    ram(1043) <= x"bdf4"; -- 0826
    ram(1044) <= x"1c64"; -- 0828
    ram(1045) <= x"d105"; -- 082A
    ram(1046) <= x"1c40"; -- 082C
    ram(1047) <= x"4161"; -- 082E
    ram(1048) <= x"02cf"; -- 0830
    ram(1049) <= x"d301"; -- 0832
    ram(1050) <= x"0849"; -- 0834
    ram(1051) <= x"e7f4"; -- 0836
    ram(1052) <= x"e750"; -- 0838
    ram(1053) <= x"e75d"; -- 083A
    ram(1054) <= x"b570"; -- 083C
    ram(1055) <= x"0004"; -- 083E
    ram(1056) <= x"000d"; -- 0840
    ram(1057) <= x"88e0"; -- 0842
    ram(1058) <= x"493d"; -- 0844
    ram(1059) <= x"4001"; -- 0846
    ram(1060) <= x"1108"; -- 0848
    ram(1061) <= x"4e3d"; -- 084A
    ram(1062) <= x"42b0"; -- 084C
    ram(1063) <= x"d110"; -- 084E
    ram(1064) <= x"88e0"; -- 0850
    ram(1065) <= x"210f"; -- 0852
    ram(1066) <= x"4208"; -- 0854
    ram(1067) <= x"d108"; -- 0856
    ram(1068) <= x"88a0"; -- 0858
    ram(1069) <= x"2800"; -- 085A
    ram(1070) <= x"d105"; -- 085C
    ram(1071) <= x"8860"; -- 085E
    ram(1072) <= x"2800"; -- 0860
    ram(1073) <= x"d102"; -- 0862
    ram(1074) <= x"8820"; -- 0864
    ram(1075) <= x"2800"; -- 0866
    ram(1076) <= x"d001"; -- 0868
    ram(1077) <= x"2002"; -- 086A
    ram(1078) <= x"bd70"; -- 086C
    ram(1079) <= x"2001"; -- 086E
    ram(1080) <= x"bd70"; -- 0870
    ram(1081) <= x"2800"; -- 0872
    ram(1082) <= x"d106"; -- 0874
    ram(1083) <= x"0020"; -- 0876
    ram(1084) <= x"f000"; -- 0878
    ram(1085) <= x"f868"; -- 087A
    ram(1086) <= x"2801"; -- 087C
    ram(1087) <= x"db01"; -- 087E
    ram(1088) <= x"2000"; -- 0880
    ram(1089) <= x"bd70"; -- 0882
    ram(1090) <= x"182d"; -- 0884
    ram(1091) <= x"42b5"; -- 0886
    ram(1092) <= x"db0a"; -- 0888
    ram(1093) <= x"88e0"; -- 088A
    ram(1094) <= x"0400"; -- 088C
    ram(1095) <= x"d502"; -- 088E
    ram(1096) <= x"2000"; -- 0890
    ram(1097) <= x"492c"; -- 0892
    ram(1098) <= x"e001"; -- 0894
    ram(1099) <= x"2000"; -- 0896
    ram(1100) <= x"0531"; -- 0898
    ram(1101) <= x"c403"; -- 089A
    ram(1102) <= x"2001"; -- 089C
    ram(1103) <= x"bd70"; -- 089E
    ram(1104) <= x"2d01"; -- 08A0
    ram(1105) <= x"db04"; -- 08A2
    ram(1106) <= x"88e0"; -- 08A4
    ram(1107) <= x"4928"; -- 08A6
    ram(1108) <= x"4001"; -- 08A8
    ram(1109) <= x"0128"; -- 08AA
    ram(1110) <= x"e040"; -- 08AC
    ram(1111) <= x"88e1"; -- 08AE
    ram(1112) <= x"2080"; -- 08B0
    ram(1113) <= x"0200"; -- 08B2
    ram(1114) <= x"4008"; -- 08B4
    ram(1115) <= x"0709"; -- 08B6
    ram(1116) <= x"0f09"; -- 08B8
    ram(1117) <= x"2210"; -- 08BA
    ram(1118) <= x"430a"; -- 08BC
    ram(1119) <= x"80e2"; -- 08BE
    ram(1120) <= x"1e6d"; -- 08C0
    ram(1121) <= x"2133"; -- 08C2
    ram(1122) <= x"43c9"; -- 08C4
    ram(1123) <= x"428d"; -- 08C6
    ram(1124) <= x"da05"; -- 08C8
    ram(1125) <= x"80e0"; -- 08CA
    ram(1126) <= x"2000"; -- 08CC
    ram(1127) <= x"80a0"; -- 08CE
    ram(1128) <= x"8060"; -- 08D0
    ram(1129) <= x"8020"; -- 08D2
    ram(1130) <= x"bd70"; -- 08D4
    ram(1131) <= x"b22d"; -- 08D6
    ram(1132) <= x"210e"; -- 08D8
    ram(1133) <= x"43c9"; -- 08DA
    ram(1134) <= x"428d"; -- 08DC
    ram(1135) <= x"da0b"; -- 08DE
    ram(1136) <= x"8862"; -- 08E0
    ram(1137) <= x"8022"; -- 08E2
    ram(1138) <= x"88a2"; -- 08E4
    ram(1139) <= x"8062"; -- 08E6
    ram(1140) <= x"88e2"; -- 08E8
    ram(1141) <= x"80a2"; -- 08EA
    ram(1142) <= x"2200"; -- 08EC
    ram(1143) <= x"80e2"; -- 08EE
    ram(1144) <= x"3510"; -- 08F0
    ram(1145) <= x"b22d"; -- 08F2
    ram(1146) <= x"428d"; -- 08F4
    ram(1147) <= x"dbf3"; -- 08F6
    ram(1148) <= x"4269"; -- 08F8
    ram(1149) <= x"b209"; -- 08FA
    ram(1150) <= x"2900"; -- 08FC
    ram(1151) <= x"d016"; -- 08FE
    ram(1152) <= x"2210"; -- 0900
    ram(1153) <= x"1a52"; -- 0902
    ram(1154) <= x"8823"; -- 0904
    ram(1155) <= x"410b"; -- 0906
    ram(1156) <= x"8865"; -- 0908
    ram(1157) <= x"4095"; -- 090A
    ram(1158) <= x"431d"; -- 090C
    ram(1159) <= x"8025"; -- 090E
    ram(1160) <= x"8863"; -- 0910
    ram(1161) <= x"410b"; -- 0912
    ram(1162) <= x"88a5"; -- 0914
    ram(1163) <= x"4095"; -- 0916
    ram(1164) <= x"431d"; -- 0918
    ram(1165) <= x"8065"; -- 091A
    ram(1166) <= x"88a3"; -- 091C
    ram(1167) <= x"410b"; -- 091E
    ram(1168) <= x"88e5"; -- 0920
    ram(1169) <= x"4095"; -- 0922
    ram(1170) <= x"431d"; -- 0924
    ram(1171) <= x"80a5"; -- 0926
    ram(1172) <= x"88e2"; -- 0928
    ram(1173) <= x"40ca"; -- 092A
    ram(1174) <= x"80e2"; -- 092C
    ram(1175) <= x"88e1"; -- 092E
    ram(1176) <= x"4308"; -- 0930
    ram(1177) <= x"80e0"; -- 0932
    ram(1178) <= x"2000"; -- 0934
    ram(1179) <= x"43c0"; -- 0936
    ram(1180) <= x"bd70"; -- 0938
    ram(1181) <= x"bf00"; -- 093A
    ram(1182) <= x"7ff0"; -- 093C
    ram(1183) <= x"0000"; -- 093E
    ram(1184) <= x"07ff"; -- 0940
    ram(1185) <= x"0000"; -- 0942
    ram(1186) <= x"0000"; -- 0944
    ram(1187) <= x"fff0"; -- 0946
    ram(1188) <= x"800f"; -- 0948
    ram(1189) <= x"0000"; -- 094A
    ram(1190) <= x"b4f0"; -- 094C
    ram(1191) <= x"0001"; -- 094E
    ram(1192) <= x"88c8"; -- 0950
    ram(1193) <= x"2280"; -- 0952
    ram(1194) <= x"0212"; -- 0954
    ram(1195) <= x"4002"; -- 0956
    ram(1196) <= x"2001"; -- 0958
    ram(1197) <= x"230f"; -- 095A
    ram(1198) <= x"88cc"; -- 095C
    ram(1199) <= x"401c"; -- 095E
    ram(1200) <= x"80cc"; -- 0960
    ram(1201) <= x"d114"; -- 0962
    ram(1202) <= x"888c"; -- 0964
    ram(1203) <= x"2c00"; -- 0966
    ram(1204) <= x"d105"; -- 0968
    ram(1205) <= x"884c"; -- 096A
    ram(1206) <= x"2c00"; -- 096C
    ram(1207) <= x"d102"; -- 096E
    ram(1208) <= x"880c"; -- 0970
    ram(1209) <= x"2c00"; -- 0972
    ram(1210) <= x"d041"; -- 0974
    ram(1211) <= x"888c"; -- 0976
    ram(1212) <= x"80cc"; -- 0978
    ram(1213) <= x"884d"; -- 097A
    ram(1214) <= x"808d"; -- 097C
    ram(1215) <= x"880d"; -- 097E
    ram(1216) <= x"804d"; -- 0980
    ram(1217) <= x"2500"; -- 0982
    ram(1218) <= x"800d"; -- 0984
    ram(1219) <= x"3810"; -- 0986
    ram(1220) <= x"b200"; -- 0988
    ram(1221) <= x"2c00"; -- 098A
    ram(1222) <= x"d0f3"; -- 098C
    ram(1223) <= x"88cc"; -- 098E
    ram(1224) <= x"2c10"; -- 0990
    ram(1225) <= x"d216"; -- 0992
    ram(1226) <= x"888c"; -- 0994
    ram(1227) <= x"88cd"; -- 0996
    ram(1228) <= x"006e"; -- 0998
    ram(1229) <= x"0be5"; -- 099A
    ram(1230) <= x"4335"; -- 099C
    ram(1231) <= x"80cd"; -- 099E
    ram(1232) <= x"884e"; -- 09A0
    ram(1233) <= x"0064"; -- 09A2
    ram(1234) <= x"0bf7"; -- 09A4
    ram(1235) <= x"4327"; -- 09A6
    ram(1236) <= x"808f"; -- 09A8
    ram(1237) <= x"880c"; -- 09AA
    ram(1238) <= x"0076"; -- 09AC
    ram(1239) <= x"0be7"; -- 09AE
    ram(1240) <= x"4337"; -- 09B0
    ram(1241) <= x"804f"; -- 09B2
    ram(1242) <= x"0064"; -- 09B4
    ram(1243) <= x"800c"; -- 09B6
    ram(1244) <= x"1e40"; -- 09B8
    ram(1245) <= x"b200"; -- 09BA
    ram(1246) <= x"b2ad"; -- 09BC
    ram(1247) <= x"2d10"; -- 09BE
    ram(1248) <= x"d3e8"; -- 09C0
    ram(1249) <= x"88cc"; -- 09C2
    ram(1250) <= x"2c20"; -- 09C4
    ram(1251) <= x"d315"; -- 09C6
    ram(1252) <= x"884c"; -- 09C8
    ram(1253) <= x"880d"; -- 09CA
    ram(1254) <= x"086d"; -- 09CC
    ram(1255) <= x"03e6"; -- 09CE
    ram(1256) <= x"432e"; -- 09D0
    ram(1257) <= x"800e"; -- 09D2
    ram(1258) <= x"888d"; -- 09D4
    ram(1259) <= x"0864"; -- 09D6
    ram(1260) <= x"03ee"; -- 09D8
    ram(1261) <= x"4326"; -- 09DA
    ram(1262) <= x"804e"; -- 09DC
    ram(1263) <= x"88cc"; -- 09DE
    ram(1264) <= x"086d"; -- 09E0
    ram(1265) <= x"03e6"; -- 09E2
    ram(1266) <= x"432e"; -- 09E4
    ram(1267) <= x"808e"; -- 09E6
    ram(1268) <= x"0864"; -- 09E8
    ram(1269) <= x"80cc"; -- 09EA
    ram(1270) <= x"1c40"; -- 09EC
    ram(1271) <= x"b200"; -- 09EE
    ram(1272) <= x"2c20"; -- 09F0
    ram(1273) <= x"d2e9"; -- 09F2
    ram(1274) <= x"88cc"; -- 09F4
    ram(1275) <= x"4023"; -- 09F6
    ram(1276) <= x"80cb"; -- 09F8
    ram(1277) <= x"88cb"; -- 09FA
    ram(1278) <= x"431a"; -- 09FC
    ram(1279) <= x"80ca"; -- 09FE
    ram(1280) <= x"bcf0"; -- 0A00
    ram(1281) <= x"4770"; -- 0A02
    ram(1282) <= x"b538"; -- 0A04
    ram(1283) <= x"0005"; -- 0A06
    ram(1284) <= x"000c"; -- 0A08
    ram(1285) <= x"88e0"; -- 0A0A
    ram(1286) <= x"4916"; -- 0A0C
    ram(1287) <= x"4001"; -- 0A0E
    ram(1288) <= x"1108"; -- 0A10
    ram(1289) <= x"4916"; -- 0A12
    ram(1290) <= x"4288"; -- 0A14
    ram(1291) <= x"d111"; -- 0A16
    ram(1292) <= x"2000"; -- 0A18
    ram(1293) <= x"8028"; -- 0A1A
    ram(1294) <= x"88e0"; -- 0A1C
    ram(1295) <= x"0700"; -- 0A1E
    ram(1296) <= x"d108"; -- 0A20
    ram(1297) <= x"88a0"; -- 0A22
    ram(1298) <= x"2800"; -- 0A24
    ram(1299) <= x"d105"; -- 0A26
    ram(1300) <= x"8860"; -- 0A28
    ram(1301) <= x"2800"; -- 0A2A
    ram(1302) <= x"d102"; -- 0A2C
    ram(1303) <= x"8820"; -- 0A2E
    ram(1304) <= x"2800"; -- 0A30
    ram(1305) <= x"d001"; -- 0A32
    ram(1306) <= x"2002"; -- 0A34
    ram(1307) <= x"bd32"; -- 0A36
    ram(1308) <= x"2001"; -- 0A38
    ram(1309) <= x"bd32"; -- 0A3A
    ram(1310) <= x"2801"; -- 0A3C
    ram(1311) <= x"da04"; -- 0A3E
    ram(1312) <= x"0020"; -- 0A40
    ram(1313) <= x"f7ff"; -- 0A42
    ram(1314) <= x"ff83"; -- 0A44
    ram(1315) <= x"2801"; -- 0A46
    ram(1316) <= x"da0b"; -- 0A48
    ram(1317) <= x"88e1"; -- 0A4A
    ram(1318) <= x"4a08"; -- 0A4C
    ram(1319) <= x"400a"; -- 0A4E
    ram(1320) <= x"4908"; -- 0A50
    ram(1321) <= x"4311"; -- 0A52
    ram(1322) <= x"80e1"; -- 0A54
    ram(1323) <= x"4908"; -- 0A56
    ram(1324) <= x"1a40"; -- 0A58
    ram(1325) <= x"8028"; -- 0A5A
    ram(1326) <= x"2000"; -- 0A5C
    ram(1327) <= x"43c0"; -- 0A5E
    ram(1328) <= x"bd32"; -- 0A60
    ram(1329) <= x"2000"; -- 0A62
    ram(1330) <= x"8028"; -- 0A64
    ram(1331) <= x"bd32"; -- 0A66
    ram(1332) <= x"7ff0"; -- 0A68
    ram(1333) <= x"0000"; -- 0A6A
    ram(1334) <= x"07ff"; -- 0A6C
    ram(1335) <= x"0000"; -- 0A6E
    ram(1336) <= x"800f"; -- 0A70
    ram(1337) <= x"0000"; -- 0A72
    ram(1338) <= x"3fe0"; -- 0A74
    ram(1339) <= x"0000"; -- 0A76
    ram(1340) <= x"03fe"; -- 0A78
    ram(1341) <= x"0000"; -- 0A7A
    ram(1342) <= x"46f4"; -- 0A7C
    ram(1343) <= x"184a"; -- 0A7E
    ram(1344) <= x"d205"; -- 0A80
    ram(1345) <= x"f000"; -- 0A82
    ram(1346) <= x"f80f"; -- 0A84
    ram(1347) <= x"d501"; -- 0A86
    ram(1348) <= x"1780"; -- 0A88
    ram(1349) <= x"0840"; -- 0A8A
    ram(1350) <= x"4760"; -- 0A8C
    ram(1351) <= x"f000"; -- 0A8E
    ram(1352) <= x"f809"; -- 0A90
    ram(1353) <= x"2101"; -- 0A92
    ram(1354) <= x"07c9"; -- 0A94
    ram(1355) <= x"4288"; -- 0A96
    ram(1356) <= x"d900"; -- 0A98
    ram(1357) <= x"0008"; -- 0A9A
    ram(1358) <= x"4240"; -- 0A9C
    ram(1359) <= x"4760"; -- 0A9E
    ram(1360) <= x"184a"; -- 0AA0
    ram(1361) <= x"d212"; -- 0AA2
    ram(1362) <= x"0d40"; -- 0AA4
    ram(1363) <= x"02c9"; -- 0AA6
    ram(1364) <= x"4308"; -- 0AA8
    ram(1365) <= x"2101"; -- 0AAA
    ram(1366) <= x"07c9"; -- 0AAC
    ram(1367) <= x"4308"; -- 0AAE
    ram(1368) <= x"0d52"; -- 0AB0
    ram(1369) <= x"2140"; -- 0AB2
    ram(1370) <= x"0109"; -- 0AB4
    ram(1371) <= x"1a52"; -- 0AB6
    ram(1372) <= x"1c52"; -- 0AB8
    ram(1373) <= x"d406"; -- 0ABA
    ram(1374) <= x"4252"; -- 0ABC
    ram(1375) <= x"321f"; -- 0ABE
    ram(1376) <= x"d401"; -- 0AC0
    ram(1377) <= x"40d0"; -- 0AC2
    ram(1378) <= x"4770"; -- 0AC4
    ram(1379) <= x"17c0"; -- 0AC6
    ram(1380) <= x"4770"; -- 0AC8
    ram(1381) <= x"2000"; -- 0ACA
    ram(1382) <= x"4770"; -- 0ACC
    ram(1383) <= x"0000"; -- 0ACE
    ram(1384) <= x"b430"; -- 0AD0
    ram(1385) <= x"2401"; -- 0AD2
    ram(1386) <= x"0564"; -- 0AD4
    ram(1387) <= x"004d"; -- 0AD6
    ram(1388) <= x"42ec"; -- 0AD8
    ram(1389) <= x"d80b"; -- 0ADA
    ram(1390) <= x"005d"; -- 0ADC
    ram(1391) <= x"42ec"; -- 0ADE
    ram(1392) <= x"d808"; -- 0AE0
    ram(1393) <= x"000c"; -- 0AE2
    ram(1394) <= x"431c"; -- 0AE4
    ram(1395) <= x"0064"; -- 0AE6
    ram(1396) <= x"4304"; -- 0AE8
    ram(1397) <= x"4314"; -- 0AEA
    ram(1398) <= x"d204"; -- 0AEC
    ram(1399) <= x"4299"; -- 0AEE
    ram(1400) <= x"d100"; -- 0AF0
    ram(1401) <= x"4290"; -- 0AF2
    ram(1402) <= x"bc30"; -- 0AF4
    ram(1403) <= x"4770"; -- 0AF6
    ram(1404) <= x"d0fc"; -- 0AF8
    ram(1405) <= x"428b"; -- 0AFA
    ram(1406) <= x"d1fa"; -- 0AFC
    ram(1407) <= x"4282"; -- 0AFE
    ram(1408) <= x"e7f8"; -- 0B00
    ram(1409) <= x"0000"; -- 0B02
    ram(1410) <= x"b430"; -- 0B04
    ram(1411) <= x"2401"; -- 0B06
    ram(1412) <= x"0564"; -- 0B08
    ram(1413) <= x"004d"; -- 0B0A
    ram(1414) <= x"42ec"; -- 0B0C
    ram(1415) <= x"d80b"; -- 0B0E
    ram(1416) <= x"005d"; -- 0B10
    ram(1417) <= x"42ec"; -- 0B12
    ram(1418) <= x"d808"; -- 0B14
    ram(1419) <= x"000c"; -- 0B16
    ram(1420) <= x"431c"; -- 0B18
    ram(1421) <= x"0064"; -- 0B1A
    ram(1422) <= x"4304"; -- 0B1C
    ram(1423) <= x"4314"; -- 0B1E
    ram(1424) <= x"d204"; -- 0B20
    ram(1425) <= x"428b"; -- 0B22
    ram(1426) <= x"d100"; -- 0B24
    ram(1427) <= x"4282"; -- 0B26
    ram(1428) <= x"bc30"; -- 0B28
    ram(1429) <= x"4770"; -- 0B2A
    ram(1430) <= x"d0fc"; -- 0B2C
    ram(1431) <= x"4299"; -- 0B2E
    ram(1432) <= x"d1fa"; -- 0B30
    ram(1433) <= x"4290"; -- 0B32
    ram(1434) <= x"e7f8"; -- 0B34
    ram(1435) <= x"0000"; -- 0B36
    ram(1436) <= x"0001"; -- 0B38
    ram(1437) <= x"d508"; -- 0B3A
    ram(1438) <= x"46f4"; -- 0B3C
    ram(1439) <= x"4240"; -- 0B3E
    ram(1440) <= x"f000"; -- 0B40
    ram(1441) <= x"f805"; -- 0B42
    ram(1442) <= x"2201"; -- 0B44
    ram(1443) <= x"07d2"; -- 0B46
    ram(1444) <= x"4311"; -- 0B48
    ram(1445) <= x"4760"; -- 0B4A
    ram(1446) <= x"0001"; -- 0B4C
    ram(1447) <= x"2242"; -- 0B4E
    ram(1448) <= x"0112"; -- 0B50
    ram(1449) <= x"1ed2"; -- 0B52
    ram(1450) <= x"4200"; -- 0B54
    ram(1451) <= x"d007"; -- 0B56
    ram(1452) <= x"d402"; -- 0B58
    ram(1453) <= x"1e52"; -- 0B5A
    ram(1454) <= x"1800"; -- 0B5C
    ram(1455) <= x"d5fc"; -- 0B5E
    ram(1456) <= x"0ac1"; -- 0B60
    ram(1457) <= x"0540"; -- 0B62
    ram(1458) <= x"0512"; -- 0B64
    ram(1459) <= x"1889"; -- 0B66
    ram(1460) <= x"4770"; -- 0B68
    ram(1461) <= x"0000"; -- 0B6A
    ram(1462) <= x"0bb9"; -- 0B6C
    ram(1463) <= x"0000"; -- 0B6E
    ram(1464) <= x"0008"; -- 0B70
    ram(1465) <= x"0000"; -- 0B72
    ram(1466) <= x"0d80"; -- 0B74
    ram(1467) <= x"0000"; -- 0B76
    ram(1468) <= x"0000"; -- 0B78
    ram(1469) <= x"0000"; -- 0B7A
    ram(1470) <= x"b510"; -- 0B7C
    ram(1471) <= x"4805"; -- 0B7E
    ram(1472) <= x"4c05"; -- 0B80
    ram(1473) <= x"42a0"; -- 0B82
    ram(1474) <= x"d004"; -- 0B84
    ram(1475) <= x"6801"; -- 0B86
    ram(1476) <= x"1d00"; -- 0B88
    ram(1477) <= x"4788"; -- 0B8A
    ram(1478) <= x"42a0"; -- 0B8C
    ram(1479) <= x"d1fa"; -- 0B8E
    ram(1480) <= x"bd10"; -- 0B90
    ram(1481) <= x"bf00"; -- 0B92
    ram(1482) <= x"0b6c"; -- 0B94
    ram(1483) <= x"0000"; -- 0B96
    ram(1484) <= x"0b7c"; -- 0B98
    ram(1485) <= x"0000"; -- 0B9A
    ram(1486) <= x"b580"; -- 0B9C
    ram(1487) <= x"2200"; -- 0B9E
    ram(1488) <= x"4803"; -- 0BA0
    ram(1489) <= x"4904"; -- 0BA2
    ram(1490) <= x"f7ff"; -- 0BA4
    ram(1491) <= x"fa4c"; -- 0BA6
    ram(1492) <= x"2220"; -- 0BA8
    ram(1493) <= x"c203"; -- 0BAA
    ram(1494) <= x"4400"; -- 0BAC
    ram(1495) <= x"e7fd"; -- 0BAE
    ram(1496) <= x"3333"; -- 0BB0
    ram(1497) <= x"3333"; -- 0BB2
    ram(1498) <= x"3333"; -- 0BB4
    ram(1499) <= x"3ff3"; -- 0BB6
    ram(1500) <= x"2100"; -- 0BB8
    ram(1501) <= x"e005"; -- 0BBA
    ram(1502) <= x"6802"; -- 0BBC
    ram(1503) <= x"1d00"; -- 0BBE
    ram(1504) <= x"6011"; -- 0BC0
    ram(1505) <= x"1d12"; -- 0BC2
    ram(1506) <= x"1f1b"; -- 0BC4
    ram(1507) <= x"d1fb"; -- 0BC6
    ram(1508) <= x"6803"; -- 0BC8
    ram(1509) <= x"1d00"; -- 0BCA
    ram(1510) <= x"2b00"; -- 0BCC
    ram(1511) <= x"d1f5"; -- 0BCE
    ram(1512) <= x"4770"; -- 0BD0
    ram(1513) <= x"0000"; -- 0BD2
    ram(1514) <= x"f000"; -- 0BD4
    ram(1515) <= x"f822"; -- 0BD6
    ram(1516) <= x"2800"; -- 0BD8
    ram(1517) <= x"d001"; -- 0BDA
    ram(1518) <= x"f7ff"; -- 0BDC
    ram(1519) <= x"ffce"; -- 0BDE
    ram(1520) <= x"2000"; -- 0BE0
    ram(1521) <= x"f7ff"; -- 0BE2
    ram(1522) <= x"ffdb"; -- 0BE4
    ram(1523) <= x"f000"; -- 0BE6
    ram(1524) <= x"f816"; -- 0BE8
    ram(1525) <= x"0000"; -- 0BEA
    ram(1526) <= x"b510"; -- 0BEC
    ram(1527) <= x"4c03"; -- 0BEE
    ram(1528) <= x"6820"; -- 0BF0
    ram(1529) <= x"0001"; -- 0BF2
    ram(1530) <= x"d000"; -- 0BF4
    ram(1531) <= x"4780"; -- 0BF6
    ram(1532) <= x"1d20"; -- 0BF8
    ram(1533) <= x"bd10"; -- 0BFA
    ram(1534) <= x"0d80"; -- 0BFC
    ram(1535) <= x"0000"; -- 0BFE
    ram(1536) <= x"4901"; -- 0C00
    ram(1537) <= x"2018"; -- 0C02
    ram(1538) <= x"beab"; -- 0C04
    ram(1539) <= x"e7fb"; -- 0C06
    ram(1540) <= x"0026"; -- 0C08
    ram(1541) <= x"0002"; -- 0C0A
    ram(1542) <= x"4607"; -- 0C0C
    ram(1543) <= x"4638"; -- 0C0E
    ram(1544) <= x"f7ff"; -- 0C10
    ram(1545) <= x"fff6"; -- 0C12
    ram(1546) <= x"e7fb"; -- 0C14
    ram(1547) <= x"b580"; -- 0C16
    ram(1548) <= x"f7ff"; -- 0C18
    ram(1549) <= x"fff8"; -- 0C1A
    ram(1550) <= x"2001"; -- 0C1C
    ram(1551) <= x"4770"; -- 0C1E
    ram(1552) <= x"e7fe"; -- 0C20
    ram(1553) <= x"0000"; -- 0C22
    ram(1554) <= x"0000"; -- 0C24
    ram(1555) <= x"0000"; -- 0C26
    ram(1556) <= x"0000"; -- 0C28
    ram(1557) <= x"0000"; -- 0C2A
    ram(1558) <= x"0000"; -- 0C2C
    ram(1559) <= x"0000"; -- 0C2E
    ram(1560) <= x"e7fe"; -- 0C30
    ram(1561) <= x"0000"; -- 0C32
    ram(1562) <= x"0000"; -- 0C34
    ram(1563) <= x"0000"; -- 0C36
    ram(1564) <= x"0000"; -- 0C38
    ram(1565) <= x"0000"; -- 0C3A
    ram(1566) <= x"0000"; -- 0C3C
    ram(1567) <= x"0000"; -- 0C3E
    else
      if rising_edge(clk) then
        if wrl = '0' then
          ram(conv_integer(addr(11 downto 1)))(7 downto 0) <= dataout(7 downto 0);
        end if;
        if wrh = '0' then
          ram(conv_integer(addr(11 downto 1)))(15 downto 8) <= dataout(15 downto 8);
        end if;
      end if;
    end if;
  end process;

--#################################################################
--  UART
  dataFromUart(15 downto 8) <= x"00";
  SERUART : uart Port map (
           clk     => clk, --: in  std_logic;
           rst     => rst, --: in  std_logic;
           datain  => dataout(7 downto 0), --: in  std_logic_vector(7 downto 0);
           dataout => dataFromUart(7 downto 0), --: out std_logic_vector(7 downto 0);
           addr    => addr(3 downto 1), --: in  std_logic_vector(2 downto 0);
           cs      => cs_uart, --: in  std_logic;
           wr      => wrl,     --: in  std_logic;
           serIn   => RXD,     --: in  std_logic;
           serOut  => TXD      --: out std_logic
          );
          
end behavior;
