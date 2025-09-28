library ieee;
use ieee.std_logic_1164.all;

entity top is
	port (
		clk_100mhz_i : in std_logic;
		rst_n_i      : in std_logic;

		-- uart comms
		uart_rxd_i   : in std_logic;
		uart_txd_o   : out std_logic
	);
end top;

architecture rtl of top is

begin
end architecture;
