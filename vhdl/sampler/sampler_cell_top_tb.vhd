library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sampler_cell_top_tb is
end entity sampler_cell_top_tb;

architecture tb of sampler_cell_top_tb is
	-- Clock periods
	constant SAMPLE_CLK_PERIOD : time := 10 ns; -- 100 MHz
	constant UART_CLK_PERIOD : time := 150 ns; -- 1 MHz

	-- DUT signals
	signal sample_clk_i : std_logic := '0';
	signal uart_clk_i : std_logic := '0';
	signal rst_n_i : std_logic := '0';
	signal start_i : std_logic := '0';
	signal sample_i : std_logic := '0';
	signal sample_o : std_logic_vector(7 downto 0);
	signal uart_read_en_i : std_logic := '0';
	signal uart_data_full_o : std_logic := '0';

	signal run_sim : boolean := true;
begin
	sample_clk_gen: process
	begin
		while run_sim loop
			sample_clk_i <= '0';
			wait for SAMPLE_CLK_PERIOD / 2;
			sample_clk_i <= '1';
			wait for SAMPLE_CLK_PERIOD / 2;
		end loop;
		wait;
	end process sample_clk_gen;

	uart_clk_gen: process
	begin
		while run_sim loop
			uart_clk_i <= '0';
			wait for UART_CLK_PERIOD / 2;
			uart_clk_i <= '1';
			wait for UART_CLK_PERIOD / 2;
		end loop;
		wait;
	end process uart_clk_gen;

	-- instantiate the DUT
	dut: entity work.sampler_cell_top
	port map (
		sample_clk_i => sample_clk_i,
		uart_clk_i => uart_clk_i,
		rst_n_i => rst_n_i,
		start_i => start_i,
		sample_i => sample_i,
		sample_o => sample_o,
		uart_read_en_i => uart_read_en_i,
		uart_data_full_o => uart_data_full_o
	);

    test_process: process
    begin
        wait for 100 ns;
        sample_i <= '1';
        wait for 100 ns;
        sample_i <= '0';
    end process;

    stim_process: process
    begin
        -- start sampling
        uart_read_en_i <= '1';
        start_i <= '1';
        rst_n_i <= '1';

        wait for 50 us;

        rst_n_i <= '0';
        wait for 50 ns;
        rst_n_i <= '1';

    end process;

end architecture tb;
