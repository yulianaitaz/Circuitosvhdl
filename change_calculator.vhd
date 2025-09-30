library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity change_calculator is
    Port (
        clk        : in  std_logic;
        reset      : in  std_logic;
        money_in   : in  std_logic_vector(31 downto 0); -- 💡 entrada, no salida
        price      : in  std_logic_vector(31 downto 0);
        change_out : out std_logic_vector(31 downto 0)
    );
end change_calculator;

architecture Behavioral of change_calculator is
    signal money_int  : integer := 0;
    signal price_int  : integer := 0;
    signal change_int : integer := 0;
begin

    ----------------------------------------------------------------
    -- Convert inputs and calculate change on each clock
    ----------------------------------------------------------------
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                money_int  <= 0;
                price_int  <= 0;
                change_int <= 0;
            else
                -- Convert std_logic_vector to integer
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

    ----------------------------------------------------------------
    -- Convert result back to std_logic_vector
    ----------------------------------------------------------------
    change_out <= std_logic_vector(to_unsigned(change_int, 32));

end Behavioral;


