library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity delivery_timer is
    Port (
        clk       : in  STD_LOGIC;
        reset     : in  STD_LOGIC;
        start     : in  STD_LOGIC;
        active    : out STD_LOGIC
    );
end delivery_timer;

architecture Behavioral of delivery_timer is
    constant MAX_COUNT : integer := 1500000000; -- 30s @ 50 MHz
    signal counter : integer := 0;
    signal running : STD_LOGIC := '0';
begin
    process(clk, reset)
    begin
        if reset = '1' then
            counter <= 0;
            running <= '0';
        elsif rising_edge(clk) then
            if start = '1' and running = '0' then
                running <= '1';
                counter <= 0;
            elsif running = '1' then
                if counter < MAX_COUNT then
                    counter <= counter + 1;
                else
                    running <= '0';
                end if;
            end if;
        end if;
    end process;

    active <= running;
end Behavioral;
