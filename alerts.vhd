library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

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
    -- Contadores para temporizadores
    signal counter_2s : integer range 0 to 100000000 := 0;  -- Para 2 segundos
    signal counter_500ms : integer range 0 to 25000000 := 0; -- Para 500 ms
    
    -- Señales de parpadeo
    signal blink_2s : STD_LOGIC := '0';
    signal blink_500ms : STD_LOGIC := '0';
    
    -- Constantes de tiempo (asumiendo clk de 50 MHz)
    constant CLK_2S : integer := 100000000;    -- 2 segundos
    constant CLK_500MS : integer := 25000000;  -- 500 ms
    
begin

    -- Generador de parpadeo de 2 segundos (para no_stock)
    process(clk, reset)
    begin
        if reset = '1' then
            counter_2s <= 0;
            blink_2s <= '0';
        elsif rising_edge(clk) then
            if no_stock = '1' then
                if counter_2s = CLK_2S - 1 then
                    counter_2s <= 0;
                    blink_2s <= not blink_2s;
                else
                    counter_2s <= counter_2s + 1;
                end if;
            else
                counter_2s <= 0;
                blink_2s <= '0';
            end if;
        end if;
    end process;
    
    -- Generador de parpadeo de 500ms (para delivering)
    process(clk, reset)
    begin
        if reset = '1' then
            counter_500ms <= 0;
            blink_500ms <= '0';
        elsif rising_edge(clk) then
            if delivering = '1' then
                if counter_500ms = CLK_500MS - 1 then
                    counter_500ms <= 0;
                    blink_500ms <= not blink_500ms;
                else
                    counter_500ms <= counter_500ms + 1;
                end if;
            else
                counter_500ms <= 0;
                blink_500ms <= '0';
            end if;
        end if;
    end process;
    
    -- Logica de salida para LED y buzzer
    process(no_stock, delivering, error, blink_2s, blink_500ms)
    begin
        if no_stock = '1' then
            -- Sin stock: LED parpadea cada 2 segundos, buzzer apagado
            led_red <= blink_2s;
            buzzer <= '0';
        elsif delivering = '1' then
            -- Entregando: LED y buzzer parpadean cada 500ms
            led_red <= blink_500ms;
            buzzer <= blink_500ms;
        elsif error = '1' then
            -- Error: LED y buzzer encendidos constantemente
            led_red <= '1';
            buzzer <= '1';
        else
            -- Inactivo: Todo apagado
            led_red <= '0';
            buzzer <= '0';
        end if;
    end process;

end Behavioral;
