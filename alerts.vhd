library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity alerts is
    Port (
        clk          : in  STD_LOGIC;
        reset        : in  STD_LOGIC;
        no_stock     : in  STD_LOGIC;
        delivering   : in  STD_LOGIC;
        error        : in  STD_LOGIC;
        led_red      : out STD_LOGIC;
        buzzer       : out STD_LOGIC
    );
end alerts;

architecture Behavioral of alerts is
    signal counter   : integer := 0;
    signal led_int   : STD_LOGIC := '0';
    signal buzzer_int: STD_LOGIC := '0';
begin
    process(clk, reset)
    begin
        if reset = '1' then
            counter <= 0;
            led_int <= '0';
            buzzer_int <= '0';
        elsif rising_edge(clk) then
            counter <= counter + 1;

            if error = '1' then
                led_int <= '1';
                buzzer_int <= '1';

            elsif no_stock = '1' then
                if counter mod 20000000 = 0 then -- parpadeo lento
                    led_int <= not led_int;
                end if;

            elsif delivering = '1' then
                if counter mod 5000000 = 0 then -- parpadeo rápido
                    led_int <= not led_int;
                    buzzer_int <= not buzzer_int;
                end if;

            else
                led_int <= '0';
                buzzer_int <= '0';
            end if;
        end if;
    end process;

    -- asignación de señales internas a los puertos
    led_red <= led_int;
    buzzer  <= buzzer_int;

end Behavioral;
