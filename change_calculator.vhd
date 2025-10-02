library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity change_calculator is
    Port (
        clk        : in  std_logic;
        reset      : in  std_logic;
        money_in   : in  std_logic_vector(11 downto 0); -- Reducido a 12 bits (0-4095)
        price      : in  std_logic_vector(7 downto 0);  -- 8 bits para precios (0-255)
        change_out : out std_logic_vector(11 downto 0)  -- 12 bits para cambio
    );
end change_calculator;

architecture Behavioral of change_calculator is
    signal money_int  : integer range 0 to 4095 := 0;
    signal price_int  : integer range 0 to 255 := 0;
    signal change_int : integer range 0 to 4095 := 0;
begin

    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                change_int <= 0;
            else
                money_int <= to_integer(unsigned(money_in));
                price_int <= to_integer(unsigned(price));

                if money_int >= price_int then
                    change_int <= money_int - price_int;
                else
                    change_int <= 0;
                end if;
            end if;
        end if;
    end process;

    change_out <= std_logic_vector(to_unsigned(change_int, 12));

end Behavioral;