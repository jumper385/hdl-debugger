library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top is
	port (
		clk_100mhz_i : in std_logic;
		rst_n_i      : in std_logic;
		uart_rx_i    : in std_logic;
		uart_tx_o    : out std_logic;
		uart_dbg_o   : out std_logic
	);
end entity top;

architecture rtl of top is

	component UART is
		generic (
			CLK_FREQ     : integer := 100_000_000;
			BAUD_RATE : INTEGER := 115200;
			PARITY_BIT : STRING := "none";
			USE_DEBOUNCER : BOOLEAN := True
		);
		port (
			CLK : in STD_LOGIC;
			RST : in STD_LOGIC;
			UART_TXD : out STD_LOGIC;
			UART_RXD : in STD_LOGIC;
			DIN : in STD_LOGIC_VECTOR(7 downto 0);
			DIN_VLD : in STD_LOGIC;
			DIN_RDY : out STD_LOGIC;
			DOUT : out STD_LOGIC_VECTOR(7 downto 0);
			DOUT_VLD : out STD_LOGIC;
			FRAME_ERROR : out STD_LOGIC;
			PARITY_ERROR : out STD_LOGIC
		);
	end component UART;

	signal data_in : std_logic_vector(7 downto 0);
	signal data_out : std_logic_vector(7 downto 0);
	signal rx_valid : std_logic;
	signal tx_valid : std_logic;
	
	-- sump fsm
	type sump_states is (RESET, IDLE, SEND_ID, ARMED, CAPTURE, RUN, UPLOAD_PREP, UPLOAD, ERROR);
	signal cs, ns : sump_states;
	signal id_counter : integer range 0 to 1 := 0;
	signal data_counter : integer range 0 downto 16; 

begin

	uart_inst: component UART
	generic map (
		CLK_FREQ => 100e6,
		BAUD_RATE => 115200,
		PARITY_BIT => "none",
		USE_DEBOUNCER => True
	)
	port map (
		CLK => clk_100mhz_i,
		RST => not rst_n_i,

		UART_TXD => uart_tx_o,
		UART_RXD => uart_rx_i,

		DIN => data_out,
		DIN_VLD => tx_valid,
		DIN_RDY => open,

		DOUT => data_in,
		DOUT_VLD => rx_valid,
		FRAME_ERROR => open,
		PARITY_ERROR => open 
	);

	-- sump fsm sequential
	process (clk_100mhz_i, rst_n_i) is
	begin
		if rst_n_i = '0' then
			cs <= IDLE;
		elsif rising_edge(clk_100mhz_i) then
			cs <= ns;
		end if;
	end process;

	-- sump fsm combinatorial
	process (cs, data_in) is
	begin

		case cs is

			when IDLE =>
				uart_dbg_o <= '1';
				data_out <= x"00";
				tx_valid <= '0';

				if data_in = x"27" then -- r: ready
					ns <= ARMED;
				else
					ns <= cs;
				end if;
		
			when ARMED =>
				uart_dbg_o <= '0';
				data_out <= x"00";
				tx_valid <= '0';

				if data_in = x"73" then -- s: start
					ns <= RUN;
				elsif data_in = x"78" then -- x: stop
					ns <= IDLE;
				else
					ns <= cs;
				end if;

			when RUN =>
				uart_dbg_o <= '1';
				data_out <= x"00";
				tx_valid <= '0';

				if data_in = x"67" then -- g: get
					data_out <= x"46";
					tx_valid <= '1';
				end if;

				if data_in = x"78" then -- x: stop
					ns <= IDLE;
				else
					ns <= cs;
				end if;	
		
			when others =>
				uart_dbg_o <= '0';
				data_out <= x"00";
				tx_valid <= '0';

				ns <= IDLE;
			
		end case;

	end process;

end architecture rtl;
