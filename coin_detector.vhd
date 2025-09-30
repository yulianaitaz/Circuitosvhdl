library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity coin_detector is
    Port (
        sw_coin500  : in  STD_LOGIC;
        sw_coin1000 : in  STD_LOGIC;
        coin_out    : out STD_LOGIC_VECTOR(3 downto 0)
    );
end coin_detector;

architecture Behavioral of coin_detector is
begin
    process(sw_coin500, sw_coin1000)
    begin
        if sw_coin500 = '1' then
            coin_out <= "0101"; -- 5
        elsif sw_coin1000 = '1' then
            coin_out <= "1010"; -- 10
        else
            coin_out <= "0000"; -- 0
        end if;
    end process;
end Behavioral;



