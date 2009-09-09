library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- uart baudrate
-- baudrate register = 1  =>  clk / 8
-- baudrate register = 2  =>  clk / 12
-- baudrate register = N  =>  clk / ((N + 1) * 4)

entity uart is
    Port ( clk     : in  std_logic;
           rst     : in  std_logic;
           datain  : in  std_logic_vector(7 downto 0);
           dataout : out std_logic_vector(7 downto 0);
           addr    : in  std_logic_vector(2 downto 0);
           cs      : in  std_logic;
           wr      : in  std_logic;
           serIn   : in  std_logic;
           serOut  : out std_logic);
end uart;

architecture Behavioral of uart is

  type UARTregisters is array (0 to 7) of std_logic_vector(7 downto 0);
  signal registers : UARTregisters;
  signal txBaud    : std_logic_vector(15 downto 0);
  signal rxBaud    : std_logic_vector(15 downto 0);
  signal txFSM     : std_logic_vector(3 downto 0);
  signal rxFSM     : std_logic_vector(3 downto 0);
  signal txTick    : std_logic_vector(2 downto 0);
  signal rxTick    : std_logic_vector(2 downto 0);
  signal txBit     : std_logic_vector(2 downto 0);
  signal rxBit     : std_logic_vector(2 downto 0);
  signal sendRequest : std_logic;
  signal serInput  : std_logic;

begin

  process(clk, rst)
  begin
    if falling_edge(clk) then
      if rst = '0' then
        for i in 0 to 7 loop
          registers(i) <= x"00";
        end loop;
        txBaud      <= x"0000";
        rxBaud      <= x"0000";
        dataout     <= x"00";
        sendRequest <= '0';
        txFSM  <= "0000";
        rxFSM  <= "0000";
        txTick <= "000";
        rxTick <= "000";
        txBit  <= "000";
        rxBit  <= "000";
        serOut <= '1';
        serInput <= '1';
      else
        serInput <= serIn;
-------- access to UART registers -----------------------
        if cs = '0' then   -- uart selected
          if wr = '0' then -- write access
            registers(conv_integer(addr)) <= datain;
            if addr = "000" then
              sendRequest <= '1';
            end if;
          else
            if addr = "001" then
              registers(4)(1) <= '0'; -- data ready
              registers(4)(2) <= '0'; -- frame error
            end if;
            dataout <= registers(conv_integer(addr));
          end if;
        end if;
-------- baudrate ---------------------------------------
        txBaud <= txBaud + 1;
        if txBaud = (registers(2) & registers(3)) then
          txBaud <= x"0000";
        end if;
        rxBaud <= rxBaud + 1;
        if rxBaud = (registers(2) & registers(3)) then
          rxBaud <= x"0000";
        end if;
-------- transmitter ------------------------------------
        case txFSM is
          when "0000" => --##### tx idle #####
            if sendRequest = '1' then
              registers(4)(0) <= '1'; -- tx busy
              sendRequest <= '0';
              txFSM  <= "0001";
              txBaud <= x"0000";
              txTick <= "000";
              txBit  <= "000";
              serOut <= '0';  -- start bit
            end if;
          when "0001" => --##### send start bit #####
            if txBaud = x"0000" then
              txTick <= txTick + 1;
              if txTick = "011" then
                txTick <= "000";
                txFSM  <= "0010";
                serOut <= registers(0)(conv_integer(txBit));
                txBit  <= txBit + 1;
              end if;
            end if;
          when "0010" => --##### send data bits #####
            if txBaud = x"0000" then
              txTick <= txTick + 1;
              if txTick = "011" then
                txTick <= "000";
                serOut <= registers(0)(conv_integer(txBit));
                txBit  <= txBit + 1;
                if txBit = "111" then
                  txFSM <= "0011";
                end if;
              end if;
            end if;
          when "0011" => --##### send stop bit #####
            if txBaud = x"0000" then
              txTick <= txTick + 1;
              if txTick = "011" then
                txTick <= "000";
                serOut <= '1';
                txFSM  <= "0100";
              end if;
            end if;
          when "0100" => --##### finishing stop bit #####
            if txBaud = x"0000" then
              txTick <= txTick + 1;
              if txTick = "011" then
                txFSM <= "0000";
                registers(4)(0) <= '0'; -- tx ready
              end if;
            end if;
          when others =>
            txFSM <= "0000";
        end case; -- txFSM
-------- receiver ------------------------------------
        case rxFSM is
          when "0000" => --##### awaiting start bit #####
            if serInput = '0' then
              rxBaud <= x"0000";
              rxTick <= "000";
              rxFSM  <= "0001";
            end if;
          when "0001" => --##### cnt to middle start bit #####
            if rxBaud = x"0000" then
              rxTick <= rxTick + 1;
              if rxTick = "001" then
                if serInput = '1' then -- false start bit
                  rxFSM <= "0000";
                else
                  rxTick <= "000";
                  rxBit  <= "000";
                  rxFSM  <= "0010";
                end if;
              end if;
            end if;
          when "0010" => --##### receive bits ######
            if rxBaud = x"0000" then
              rxTick <= rxTick + 1;
              if rxTick = "011" then
                rxTick <= "000";
                registers(1)(conv_integer(rxBit)) <= serInput; 
                rxBit <= rxBit + 1;
                if rxBit = "111" then -- last bit
                  rxFSM <= "0011";
                end if;
              end if;
            end if;
          when "0011" => --##### receive stop bit #####
            if rxBaud = x"0000" then
              rxTick <= rxTick + 1;
              if rxTick = "011" then
                if serInput = '0' then
                  registers(4)(2) <= '1'; -- frame error
                else
                  registers(4)(1) <= '1'; -- data ready
                end if;
                rxFSM <= "0000";
              end if;
            end if;
          when others =>
            rxFSM <= "0000";
        end case; -- rxFSM
      end if; -- rst = '0'
    end if; -- rising_edge(clk)
  end process;

end Behavioral;
