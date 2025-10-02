library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity product_selector is
    Port (
        sw_product : in  STD_LOGIC_VECTOR(3 downto 0);
        price      : out STD_LOGIC_VECTOR(7 downto 0)
    );
end product_selector;

architecture Behavioral of product_selector is
begin
    process(sw_product)
    begin
        case sw_product is
            when "0000" => price <= std_logic_vector(to_unsigned(5, 8));   -- Producto 0: 5 pesos
            when "0001" => price <= std_logic_vector(to_unsigned(10, 8));  -- Producto 1: 10 pesos
            when "0010" => price <= std_logic_vector(to_unsigned(15, 8));  -- Producto 2: 15 pesos
            when "0011" => price <= std_logic_vector(to_unsigned(20, 8));  -- Producto 3: 20 pesos
            when "0100" => price <= std_logic_vector(to_unsigned(25, 8));  -- Producto 4: 25 pesos
            when "0101" => price <= std_logic_vector(to_unsigned(30, 8));  -- Producto 5: 30 pesos
            when "0110" => price <= std_logic_vector(to_unsigned(35, 8));  -- Producto 6: 35 pesos
            when "0111" => price <= std_logic_vector(to_unsigned(40, 8));  -- Producto 7: 40 pesos
            when "1000" => price <= std_logic_vector(to_unsigned(45, 8));  -- Producto 8: 45 pesos
            when "1001" => price <= std_logic_vector(to_unsigned(50, 8));  -- Producto 9: 50 pesos
            when "1010" => price <= std_logic_vector(to_unsigned(55, 8));  -- Producto 10: 55 pesos
            when "1011" => price <= std_logic_vector(to_unsigned(60, 8));  -- Producto 11: 60 pesos
            when "1100" => price <= std_logic_vector(to_unsigned(65, 8));  -- Producto 12: 65 pesos
            when "1101" => price <= std_logic_vector(to_unsigned(70, 8));  -- Producto 13: 70 pesos
            when "1110" => price <= std_logic_vector(to_unsigned(75, 8));  -- Producto 14: 75 pesos
            when "1111" => price <= std_logic_vector(to_unsigned(80, 8));  -- Producto 15: 80 pesos
            when others => price <= std_logic_vector(to_unsigned(5, 8));   -- Default
        end case;
    end process;
end Behavioral;