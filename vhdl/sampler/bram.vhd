library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ram is
    port (
        rst_n : in std_logic;
        write_en : in  std_logic;
        wclk     : in  std_logic;
        rclk     : in  std_logic;
        read_en  : in  std_logic;
        din      : in  std_logic_vector(7 downto 0);
        dout     : out std_logic_vector(7 downto 0);
        is_full  : out std_logic
    );
end entity ram;

architecture rtl of ram is
    type mem_type is array (255 downto 0) of std_logic_vector(7 downto 0);
    signal mem : mem_type;

    signal raddr, waddr : integer range 0 to 255 := 0;
    signal full : std_logic := '0'; 
begin

    full <= '1' when waddr > 254 else '0';
    is_full <= full;
    
    process (wclk, rst_n)
    begin
				if rst_n = '0' then
					waddr <= 0;
        elsif rising_edge(wclk) then
            if write_en = '1' and full = '0' then
                mem(waddr) <= din;
                waddr <= (waddr + 1);
            end if;
        end if;
    end process;

    process (rclk, rst_n)
    begin
				if rst_n = '0' then
					raddr <= 0;
				elsif read_en = '1' then
					if rising_edge(rclk) then
						-- check for overflow state;
						if raddr < 255 then
							raddr <= raddr + 1;
							dout <= mem(raddr);
						else
							raddr <= 255;
							dout <= mem(raddr);
            end if;
					end if;
				else
						dout <= (others => '0');
        end if;
    end process;

end architecture rtl;
