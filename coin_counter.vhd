library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity coin_counter is
    Port (
        clk       : in  STD_LOGIC;
        reset     : in  STD_LOGIC;
        coin_in   : in  STD_LOGIC_VECTOR(3 downto 0);
        total_out : out integer range 0 to 9999
    );
end coin_counter;

architecture Behavioral of coin_counter is
    signal total : integer range 0 to 9999 := 0;
    signal coin_prev : STD_LOGIC_VECTOR(3 downto 0) := "0000";
begin
    process(clk, reset)
    begin
        if reset = '1' then
            total <= 0;
            coin_prev <= "0000";
        elsif rising_edge(clk) then
            -- Detectar flanco ascendente de moneda (cambio de 0000 a 0101 o 1010)
            if coin_prev = "0000" and coin_in /= "0000" then
                case coin_in is
                    when "0101" => -- 500 pesos
                        if total <= 9999 - 500 then
                            total <= total + 500;
                        end if;
                    when "1010" => -- 1000 pesos
                        if total <= 9999 - 1000 then
                            total <= total + 1000;
                        end if;
                    when others =>
                        null;
                end case;
            end if;
            
            -- Guardar valor anterior
            coin_prev <= coin_in;
        end if;
    end process;
    
    total_out <= total;
end Behavioral;