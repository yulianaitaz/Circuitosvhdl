library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity coin_counter is
    Port (
        clk       : in  STD_LOGIC;
        reset     : in  STD_LOGIC;
        coin_in   : in  STD_LOGIC_VECTOR(3 downto 0); -- valor de la moneda
        total_out : out integer                       -- total acumulado en pesos
    );
end coin_counter;

architecture Behavioral of coin_counter is
    signal total : integer := 0;
begin
    process(clk, reset)
    begin
        if reset = '1' then
            total <= 0;
        elsif rising_edge(clk) then
            if coin_in = "0101" then
                total <= total + 500;   -- moneda de 500
            elsif coin_in = "1010" then
                total <= total + 1000;  -- moneda de 1000
            end if;
        end if;
    end process;

    total_out <= total;
end Behavioral;
