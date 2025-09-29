library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ram is
    port (
        write_en : in  std_logic;
        wclk     : in  std_logic;
        rclk     : in  std_logic;
        read_en  : in  std_logic;
        din      : in  std_logic_vector(7 downto 0);
        dout     : out std_logic_vector(7 downto 0)
    );
end entity ram;

architecture rtl of ram is
    type mem_type is array (255 downto 0) of std_logic_vector(7 downto 0);
    signal mem : mem_type;

    signal raddr, waddr : integer range 0 to 255 := 0;
begin
    
	-- write memory
    process (wclk) is
    begin
        if rising_edge(wclk) then
            if (write_en = '1') then
                mem(waddr) <= din;
                waddr <= (waddr + 1) mod 256;
            end if;
        end if;
    end process;

    -- sync read memory
    process (rclk) is
    begin
        if rising_edge(rclk) then
            if (read_en = '1') then
                dout <= mem(raddr);
                raddr <= (raddr + 1) mod 256;
            else
                dout <= (others => '0');
            end if;
        end if;
    end process;

end architecture rtl;
