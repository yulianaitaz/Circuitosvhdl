library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity stock_manager is
    Port (
        clk        : in  STD_LOGIC;
        reset      : in  STD_LOGIC;
        product_id : in  STD_LOGIC_VECTOR(3 downto 0);
        valid_buy  : in  STD_LOGIC;
        no_stock   : out STD_LOGIC
    );
end stock_manager;

architecture Behavioral of stock_manager is
    type stock_array is array(0 to 15) of INTEGER range 0 to 15;
    signal stock : stock_array := (others => 5);
begin
    process(clk, reset)
    begin
        if reset = '1' then
            stock <= (others => 5);
            no_stock <= '0';
        elsif rising_edge(clk) then
            if valid_buy = '1' then
                if stock(to_integer(unsigned(product_id))) > 0 then
                    stock(to_integer(unsigned(product_id))) <= stock(to_integer(unsigned(product_id))) - 1;
                end if;
            end if;
            
            if stock(to_integer(unsigned(product_id))) = 0 then
                no_stock <= '1';
            else
                no_stock <= '0';
            end if;
        end if;
    end process;
end Behavioral;