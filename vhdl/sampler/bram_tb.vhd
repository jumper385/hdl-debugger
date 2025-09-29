library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bram_tb is
end entity;

architecture sim of bram_tb is

	-- bram signals
	signal write_en : std_logic;
	signal wclk : std_logic;
	signal rclk : std_logic;
	signal read_en : std_logic;
	signal din : std_logic_vector(7 downto 0);
	signal dout : std_logic_vector(7 downto 0);

	-- clocks
	constant RCLK_PERIOD : time := 10 ns;
	constant WCLK_PERIOD : time := 10 ns;

begin

	-- instantiate the bram
	uut: entity work.ram
	port map (
		write_en => write_en,
		wclk => wclk,
		rclk => rclk,
		din => din,
		dout => dout,
		read_en => read_en
	);

	-- read clock process 
	rclk_gen : process
	begin
		rclk <= '0';
		wait for RCLK_PERIOD/2;
		rclk <= '1';
		wait for RCLK_PERIOD/2;
	end process;

	-- write clock process
	wclk_gen : process
	begin
		wclk <= '0';
		wait for WCLK_PERIOD/2;
		wclk <= '1';
		wait for WCLK_PERIOD/2;
	end process;

	test_proc: process 
	begin

		-- test the bram
		write_en <= '0';
		wait for WCLK_PERIOD*2;
		write_en <= '1';
		
		din <= "11001100";
		wait for WCLK_PERIOD;
		write_en <= '0';

		read_en <= '1';
		wait for RCLK_PERIOD;
		assert dout = din report "Data mismatch" severity error;

		read_en <= '0';
		wait for RCLK_PERIOD;
		assert dout = "00000000" report "Not Zero" severity error;

		write_en <= '1';
		din <= "11110000";
		wait for WCLK_PERIOD;
		din <= "10101010";
		wait for WCLK_PERIOD;
		write_en <= '0';

		read_en <= '1';
		wait for RCLK_PERIOD;
		assert dout = "11110000" report "Data mismatch" severity error;
		wait for RCLK_PERIOD;
		assert dout = "10101010" report "Data mismatch" severity error;

		-- end test
		wait;

	end process;

end architecture;

