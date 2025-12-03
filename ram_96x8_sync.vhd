library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ram_96x8_sync is
    port (
        clock        : in  std_logic;
        write_enable : in  std_logic;
        address      : in  std_logic_vector(7 downto 0);
        data_in      : in  std_logic_vector(7 downto 0);
        data_out     : out std_logic_vector(7 downto 0)
    );
end ram_96x8_sync;

architecture behavioral of ram_96x8_sync is

    type ram_array_type is array (128 to 223) of std_logic_vector(7 downto 0);
    signal RAM_CONTENT : ram_array_type;
    signal ram_enable  : std_logic;

begin

    RAM_ENABLE_PROCESS: process(address)
    begin
        if ((to_integer(unsigned(address)) >= 128) and 
            (to_integer(unsigned(address)) <= 223)) then
            ram_enable <= '1';
        else
            ram_enable <= '0';
        end if;
    end process;

    RAM_ACCESS_PROCESS: process(clock)
    begin
        if (clock'event and clock = '1') then
            if (ram_enable = '1' and write_enable = '1') then
                RAM_CONTENT(to_integer(unsigned(address))) <= data_in;
            elsif (ram_enable = '1' and write_enable = '0') then
                data_out <= RAM_CONTENT(to_integer(unsigned(address)));
            end if;
        end if;
    end process;

end behavioral;