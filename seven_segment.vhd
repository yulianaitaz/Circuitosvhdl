-- seven_segment.vhd CORREGIDO
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity seven_segment is
    Port (
        number : in  STD_LOGIC_VECTOR(3 downto 0);
        seg    : out STD_LOGIC_VECTOR(6 downto 0)  -- {a,b,c,d,e,f,g}
    );
end seven_segment;

architecture Behavioral of seven_segment is
begin
    process(number)
    begin
        case number is
            when "0000" => seg <= "1000000"; -- 0 (a,b,c,d,e,f)
            when "0001" => seg <= "1111001"; -- 1 (b,c)
            when "0010" => seg <= "0100100"; -- 2 (a,b,d,e,g)
            when "0011" => seg <= "0110000"; -- 3 (a,b,c,d,g)
            when "0100" => seg <= "0011001"; -- 4 (b,c,f,g)
            when "0101" => seg <= "0010010"; -- 5 (a,c,d,f,g)
            when "0110" => seg <= "0000010"; -- 6 (a,c,d,e,f,g)
            when "0111" => seg <= "1111000"; -- 7 (a,b,c)
            when "1000" => seg <= "0000000"; -- 8 (a,b,c,d,e,f,g)
            when "1001" => seg <= "0010000"; -- 9 (a,b,c,d,f,g)
            when "1010" => seg <= "0001000"; -- A (a,b,c,e,f,g)
            when "1011" => seg <= "0000011"; -- b (c,d,e,f,g)
            when "1100" => seg <= "1000110"; -- C (a,d,e,f)
            when "1101" => seg <= "0100001"; -- d (b,c,d,e,g)
            when "1110" => seg <= "0000110"; -- E (a,d,e,f,g)
            when "1111" => seg <= "0001110"; -- F (a,e,f,g)
            when others => seg <= "1111111"; -- apagado
        end case;
    end process;
end Behavioral;
