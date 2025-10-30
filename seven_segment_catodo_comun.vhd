library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- ============================================
-- DECODIFICADOR 7 SEGMENTOS PARA DISPLAY 5161BS
-- TIPO: CÁTODO COMÚN
-- Los segmentos se encienden con nivel ALTO (1)
-- Los pines COM (3 y 8) van a GND
-- ============================================

entity seven_segment_catodo_comun is
    Port (
        number : in  STD_LOGIC_VECTOR(3 downto 0);
        seg    : out STD_LOGIC_VECTOR(6 downto 0)  -- gfedcba
    );
end seven_segment_catodo_comun;

architecture Behavioral of seven_segment_catodo_comun is
begin
    
    -- Decodificador BCD a 7 segmentos
    -- Para display CÁTODO COMÚN: 1 = encendido, 0 = apagado
    -- Orden de bits: seg = gfedcba
    
    process(number)
    begin
        case number is
            -- Número 0: segmentos a,b,c,d,e,f encendidos (g apagado)
            when "0000" => seg <= "0111111"; -- 0
            
            -- Número 1: segmentos b,c encendidos
            when "0001" => seg <= "0000110"; -- 1
            
            -- Número 2: segmentos a,b,d,e,g encendidos
            when "0010" => seg <= "1011011"; -- 2
            
            -- Número 3: segmentos a,b,c,d,g encendidos
            when "0011" => seg <= "1001111"; -- 3
            
            -- Número 4: segmentos b,c,f,g encendidos
            when "0100" => seg <= "1100110"; -- 4
            
            -- Número 5: segmentos a,c,d,f,g encendidos
            when "0101" => seg <= "1101101"; -- 5
            
            -- Número 6: segmentos a,c,d,e,f,g encendidos
            when "0110" => seg <= "1111101"; -- 6
            
            -- Número 7: segmentos a,b,c encendidos
            when "0111" => seg <= "0000111"; -- 7
            
            -- Número 8: todos los segmentos encendidos
            when "1000" => seg <= "1111111"; -- 8
            
            -- Número 9: segmentos a,b,c,d,f,g encendidos
            when "1001" => seg <= "1101111"; -- 9
            
            -- Letra A
            when "1010" => seg <= "1110111"; -- A
            
            -- Letra b (minúscula)
            when "1011" => seg <= "1111100"; -- b
            
            -- Letra C
            when "1100" => seg <= "0111001"; -- C
            
            -- Letra d (minúscula)
            when "1101" => seg <= "1011110"; -- d
            
            -- Letra E
            when "1110" => seg <= "1111001"; -- E
            
            -- Letra F
            when "1111" => seg <= "1110001"; -- F
            
            -- Por defecto: todo apagado
            when others => seg <= "0000000";
        end case;
    end process;
    
end Behavioral;