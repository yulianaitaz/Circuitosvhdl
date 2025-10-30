-- product_selector.vhd - Versión con precios ajustados para cambio físico
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity product_selector is
    Port (
        sw_product : in  STD_LOGIC_VECTOR(3 downto 0);
        price      : out STD_LOGIC_VECTOR(12 downto 0)
    );
end product_selector;

architecture Behavioral of product_selector is
begin
    process(sw_product)
    begin
        case sw_product is
            when "0000" => price <= std_logic_vector(to_unsigned(500, 13));
            when "0001" => price <= std_logic_vector(to_unsigned(1000, 13));
            when "0010" => price <= std_logic_vector(to_unsigned(1500, 13));
            when "0011" => price <= std_logic_vector(to_unsigned(500, 13));
            when "0100" => price <= std_logic_vector(to_unsigned(1500, 13));
            when "0101" => price <= std_logic_vector(to_unsigned(1000, 13));
            when "0110" => price <= std_logic_vector(to_unsigned(500, 13));
            when "0111" => price <= std_logic_vector(to_unsigned(2000, 13));
            when "1000" => price <= std_logic_vector(to_unsigned(1500, 13));
            when "1001" => price <= std_logic_vector(to_unsigned(500, 13));
            when "1010" => price <= std_logic_vector(to_unsigned(2500, 13));
            when "1011" => price <= std_logic_vector(to_unsigned(1000, 13));
            when "1100" => price <= std_logic_vector(to_unsigned(500, 13));
            when "1101" => price <= std_logic_vector(to_unsigned(1000, 13));
            when "1110" => price <= std_logic_vector(to_unsigned(1500, 13));
            when "1111" => price <= std_logic_vector(to_unsigned(2000, 13));
            when others => price <= std_logic_vector(to_unsigned(1000, 13));
        end case;
    end process;
end Behavioral;