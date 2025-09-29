library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rle_sampler_cell is
	port (
		clk_i : in STD_LOGIC; -- sampling clock
		signal_i : in STD_LOGIC; -- signal to sample
		rst_n_i : in STD_LOGIC; -- active-low reset
		sample_o : out STD_LOGIC_VECTOR(7 downto 0); -- {signal, count[7:0]}
		sample_rdy_o : out STD_LOGIC -- 1-cycle pulse when sample_o valid
	);
end entity rle_sampler_cell;

architecture rtl of rle_sampler_cell is
	
	type states is (IDLE, OVERFLOW, CHANGED);
	signal cs : states;
	signal counter : integer range 0 to 127 := 0;
	signal prev_signal : std_logic;
	signal curr_signal : std_logic;
	signal changed_signal : std_logic;

begin

	process (clk_i, rst_n_i)
	begin

		if rst_n_i = '0' then
			cs <= IDLE;
			counter <= 0;
			sample_o(7 downto 0) <= (others => '0');
			sample_rdy_o <= '0';
		elsif rising_edge(clk_i) then

			if prev_signal /= signal_i then
				prev_signal <= signal_i;
				sample_rdy_o <= '1';

				-- packed {signal, counter[6:0]}
				sample_o(7) <= prev_signal;
				sample_o(6 downto 0) <= std_logic_vector(to_unsigned(counter, 7));
				counter <= 0;

			elsif counter >= 127 then
				prev_signal <= signal_i;
				sample_rdy_o <= '1';

				-- packed {signal, counter[6:0]}
				sample_o(7) <= prev_signal;
				sample_o(6 downto 0) <= std_logic_vector(to_unsigned(counter, 7));
				counter <= 0;

			else
				prev_signal <= signal_i;
				counter <= counter + 1;
				sample_o(7 downto 0) <= (others => '0');
				sample_rdy_o <= '0';

			end if;

		end if;
		
	end process;

end architecture rtl;
