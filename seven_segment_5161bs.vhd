library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Componente específico para displays 5161BS con tu mapeo correcto
entity seven_segment_5161bs is
    Port (
        number : in  STD_LOGIC_VECTOR(3 downto 0);
        seg    : out STD_LOGIC_VECTOR(6 downto 0)
    );
end seven_segment_5161bs;

architecture Behavioral of seven_segment_5161bs is
begin
    -- Decodificador BCD a 7 segmentos
    -- MAPEO CORRECTO PARA TU DISPLAY 5161BS:
    -- seg[0] → Pin 4 del display → Segmento A
    -- seg[1] → Pin 5 del display → Segmento B
    -- seg[2] → Pin 9 del display → Segmento C
    -- seg[3] → Pin 7 del display → Segmento D
    -- seg[4] → Pin 6 del display → Segmento E
    -- seg[5] → Pin 2 del display → Segmento F
    -- seg[6] → Pin 1 del display → Segmento G
    --
    -- Lógica ACTIVO EN BAJO: '0' = encendido, '1' = apagado
    -- Orden de bits: seg(6:0) = gfedcba
    
    process(number)
    begin
        case number is
            when "0000" => seg <= "1000000"; -- 0: abcdef encendidos
            when "0001" => seg <= "1111001"; -- 1: bc encendidos
            when "0010" => seg <= "0100100"; -- 2: abdeg encendidos (gfedcba = 0100100)
            when "0011" => seg <= "0110000"; -- 3: abcdg encendidos
            when "0100" => seg <= "0011001"; -- 4: bcfg encendidos
            when "0101" => seg <= "0010010"; -- 5: acdfg encendidos
            when "0110" => seg <= "0000010"; -- 6: acdefg encendidos
            when "0111" => seg <= "1111000"; -- 7: abc encendidos
            when "1000" => seg <= "0000000"; -- 8: todos encendidos
            when "1001" => seg <= "0010000"; -- 9: abcdfg encendidos
            when "1010" => seg <= "0001000"; -- A: abcefg encendidos
            when "1011" => seg <= "0000011"; -- b: cdefg encendidos
            when "1100" => seg <= "1000110"; -- C: adef encendidos
            when "1101" => seg <= "0100001"; -- d: bcdeg encendidos
            when "1110" => seg <= "0000110"; -- E: adefg encendidos
            when "1111" => seg <= "0001110"; -- F: aefg encendidos
            when others => seg <= "1111111"; -- Apagado
        end case;
    end process;
    
end Behavioral;