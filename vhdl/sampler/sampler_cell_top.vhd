library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sampler_cell_top is
	port (
		sample_clk_i : in std_logic;
		uart_clk_i : in std_logic;

		rst_n_i : in std_logic;
		start_i : in std_logic;
		sample_i : in std_logic;
		sample_o : out std_logic_vector(7 downto 0);

		uart_read_en_i : in std_logic;
		uart_data_full_o : out std_logic
	);
end entity sampler_cell_top;

architecture rtl of sampler_cell_top is

	component rle_sampler_cell is
		port (
			clk_i : in STD_LOGIC; -- sampling clock
			signal_i : in STD_LOGIC; -- signal to sample
			rst_n_i : in STD_LOGIC; -- active-low reset
			sample_o : out STD_LOGIC_VECTOR(7 downto 0); -- {signal, count[7:0]}
			sample_rdy_o : out STD_LOGIC -- 1-cycle pulse when sample_o valid
		);
	end component rle_sampler_cell;

	component ram is
		port (
			rst_n : in std_logic;
			write_en : in std_logic;
			wclk : in std_logic;
			rclk : in std_logic;
			read_en : in std_logic;
			din : in std_logic_vector(7 downto 0);
			dout : out std_logic_vector(7 downto 0);
			is_full : out std_logic
		);
	end component ram;

	signal rle_sampler_out : std_logic_vector(7 downto 0);
	signal sample_rdy : std_logic;

begin

	-- Instantiate the RLE sampler cell
	rle_sampler_inst: component rle_sampler_cell
	port map (
		clk_i => sample_clk_i,
		signal_i => sample_i,
		rst_n_i => rst_n_i,
		sample_o => rle_sampler_out,
		sample_rdy_o => sample_rdy
	);

	-- Instantiate the RAM
	ram_inst: component ram
	port map (
		rst_n => rst_n_i,
		write_en => sample_rdy,
		wclk => sample_clk_i,
		rclk => uart_clk_i,
		read_en => uart_read_en_i,
		din => rle_sampler_out,
		dout => sample_o,
		is_full => uart_data_full_o
	);

end architecture rtl;
