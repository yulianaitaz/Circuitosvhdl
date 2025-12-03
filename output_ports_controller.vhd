library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity output_ports_controller is
    Port (
        clock        : in  STD_LOGIC;
        reset        : in  STD_LOGIC;                 
        write_enable : in  STD_LOGIC;
        address      : in  STD_LOGIC_VECTOR(7 downto 0);
        data_in      : in  STD_LOGIC_VECTOR(7 downto 0);
        port_out_00  : out STD_LOGIC_VECTOR(7 downto 0);
        port_out_01  : out STD_LOGIC_VECTOR(7 downto 0)
    );
end output_ports_controller;

architecture behavioral of output_ports_controller is
begin

    PORT_00_CONTROL : process (clock, reset)
    begin
        if (reset = '0') then
            port_out_00 <= (others => '0');
        elsif (clock'event and clock = '1') then
            if (address = x"E0" and write_enable = '1') then
                port_out_00 <= data_in;
            end if;
        end if;
    end process;

    PORT_01_CONTROL : process (clock, reset)
    begin
        if (reset = '0') then
            port_out_01 <= (others => '0');
        elsif (clock'event and clock = '1') then
            if (address = x"E1" and write_enable = '1') then
                port_out_01 <= data_in;
            end if;
        end if;
    end process;

end behavioral;