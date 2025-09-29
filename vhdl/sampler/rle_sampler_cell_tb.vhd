-- rle_sampler_cell_tb.vhd
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rle_sampler_cell_tb is
end entity rle_sampler_cell_tb;

architecture tb of rle_sampler_cell_tb is
	component rle_sampler_cell is
		port (
			clk_i : in STD_LOGIC; -- sampling clock
			signal_i : in STD_LOGIC; -- signal to sample
			rst_n_i : in STD_LOGIC; -- active-low reset
			sample_o : out STD_LOGIC_VECTOR(7 downto 0); -- {signal, count[7:0]}
			sample_rdy_o : out STD_LOGIC -- 1-cycle pulse when sample_o valid
		);
	end component rle_sampler_cell;

	signal clk : std_logic := '0';
	signal rst_n : std_logic := '0';
	signal signal_in : std_logic := '0';
	signal sample_out : std_logic_vector(7 downto 0);
	signal sample_rdy : std_logic;

	constant clk_period : time := 10 ns;

	-- simple process to generate a clock
begin
	clk_process: process
	begin
		clk <= '0';
		wait for clk_period / 2;
		clk <= '1';
		wait for clk_period / 2;
	end process clk_process;

	uut: component rle_sampler_cell
	port map (
		clk_i => clk,
		rst_n_i => rst_n,
		signal_i => signal_in,
		sample_o => sample_out,
		sample_rdy_o => sample_rdy
	);

	stim_proc: process
	begin
		-- hold reset state for a few clock cycles
		rst_n <= '0';
		wait for 3 * clk_period;
		rst_n <= '1';
		wait for clk_period;

		-- first run of 5 samples of '1'
		signal_in <= '1';
		wait for 5 * clk_period;

		-- second run of 3 samples of '0'
		signal_in <= '0';
		wait for 3 * clk_period;

		-- third run of 130 samples of '1' (should split into two runs: {1,128} and {1,2})
		signal_in <= '1';
		wait for 130 * clk_period;

		-- fourth run of 1 sample of '0'
		signal_in <= '0';
		wait for 1 * clk_period;

		-- fifth run of 128 samples of '1'
		signal_in <= '1';
		wait for 200 * clk_period;

		-- sixth run of 4 samples of '0'
		signal_in <= '0';
		wait for 4 * clk_period;

	end process stim_proc;
end architecture tb;
