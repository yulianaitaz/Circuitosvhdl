library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity dual_seven_segment is
    Port (
        value : in  STD_LOGIC_VECTOR(7 downto 0); -- 8 bits (dos dígitos hex)
        HEX0  : out STD_LOGIC_VECTOR(6 downto 0); -- dígito bajo
        HEX1  : out STD_LOGIC_VECTOR(6 downto 0)  -- dígito alto
    );
end dual_seven_segment;

architecture Behavioral of dual_seven_segment is
    signal digit_low  : STD_LOGIC_VECTOR(3 downto 0);
    signal digit_high : STD_LOGIC_VECTOR(3 downto 0);
begin
    digit_low  <= value(3 downto 0);
    digit_high <= value(7 downto 4);

    -- Decoder
    process(digit_low)
    begin
        case digit_low is
            when "0000" => HEX0 <= "0000001"; -- 0
            when "0001" => HEX0 <= "1001111"; -- 1
            when "0010" => HEX0 <= "0010010"; -- 2
            when "0011" => HEX0 <= "0000110"; -- 3
            when "0100" => HEX0 <= "1001100"; -- 4
            when "0101" => HEX0 <= "0100100"; -- 5
            when "0110" => HEX0 <= "0100000"; -- 6
            when "0111" => HEX0 <= "0001111"; -- 7
            when "1000" => HEX0 <= "0000000"; -- 8
            when "1001" => HEX0 <= "0000100"; -- 9
            when "1010" => HEX0 <= "0001000"; -- A
            when "1011" => HEX0 <= "1100000"; -- b
            when "1100" => HEX0 <= "0110001"; -- C
            when "1101" => HEX0 <= "1000010"; -- d
            when "1110" => HEX0 <= "0110000"; -- E
            when "1111" => HEX0 <= "0111000"; -- F
            when others => HEX0 <= "1111111";
        end case;
    end process;

    process(digit_high)
    begin
        case digit_high is
            when "0000" => HEX1 <= "0000001";
            when "0001" => HEX1 <= "1001111";
            when "0010" => HEX1 <= "0010010";
            when "0011" => HEX1 <= "0000110";
            when "0100" => HEX1 <= "1001100";
            when "0101" => HEX1 <= "0100100";
            when "0110" => HEX1 <= "0100000";
            when "0111" => HEX1 <= "0001111";
            when "1000" => HEX1 <= "0000000";
            when "1001" => HEX1 <= "0000100";
            when "1010" => HEX1 <= "0001000";
            when "1011" => HEX1 <= "1100000";
            when "1100" => HEX1 <= "0110001";
            when "1101" => HEX1 <= "1000010";
            when "1110" => HEX1 <= "0110000";
            when "1111" => HEX1 <= "0111000";
            when others => HEX1 <= "1111111";
        end case;
    end process;

end Behavioral;
