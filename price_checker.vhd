library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity price_checker is
    Port (
        total_money   : in  STD_LOGIC_VECTOR(13 downto 0);
        product_price : in  STD_LOGIC_VECTOR(12 downto 0);
        enough_money  : out STD_LOGIC
    );
end price_checker;

architecture Behavioral of price_checker is
begin
    process(total_money, product_price)
        variable money_int : integer;
        variable price_int : integer;
    begin
        money_int := to_integer(unsigned(total_money));
        price_int := to_integer(unsigned(product_price));
        
        if money_int >= price_int then
            enough_money <= '1';
        else
            enough_money <= '0';
        end if;
    end process;
end Behavioral;