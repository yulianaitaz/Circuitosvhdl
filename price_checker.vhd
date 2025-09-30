library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity price_checker is
    Port (
        total_money : in  STD_LOGIC_VECTOR (7 downto 0);
        enough_money : out STD_LOGIC
    );
end price_checker;

architecture Behavioral of price_checker is
    constant PRODUCT_PRICE : integer := 15;
begin
    process(total_money)
    begin
        if to_integer(unsigned(total_money)) >= PRODUCT_PRICE then
            enough_money <= '1';
        else
            enough_money <= '0';
        end if;
    end process;
end Behavioral;
