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
        dout     : out std_logic_vector(7 downto 0);
        is_empty : out std_logic;
        is_full  : out std_logic
    );
end entity ram;

architecture rtl of ram is
    type mem_type is array (255 downto 0) of std_logic_vector(7 downto 0);
    signal mem : mem_type;

    signal raddr, waddr : integer range 0 to 255 := 0;
    signal full, empty : std_logic := '0'; 
begin

    full <= '1' when waddr = 255 else '0';
    empty <= '1' when raddr = waddr else '0';

    is_full <= full;
    is_empty <= empty;
    
    process (wclk)
    begin
        if rising_edge(wclk) then
            if write_en = '1' and full = '0' then
                mem(waddr) <= din;
                waddr <= (waddr + 1) mod 256;
            end if;
        end if;
    end process;

    process (rclk)
    begin
        if rising_edge(rclk) then
            if read_en = '1' and empty = '0' then
                dout <= mem(raddr);
                raddr <= (raddr + 1) mod 256;
            else
                dout <= (others => '0');
            end if;
        end if;
    end process;

end architecture rtl;
