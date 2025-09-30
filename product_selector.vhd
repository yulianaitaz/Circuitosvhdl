library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity product_selector is
    Port (
        sw_product : in  STD_LOGIC_VECTOR(3 downto 0);  -- 16 productos
        price      : out STD_LOGIC_VECTOR(7 downto 0)   -- precio en binario
    );
end product_selector;

architecture Behavioral of product_selector is
begin
    process(sw_product)
    begin
        case sw_product is
            when "0000" => price <= std_logic_vector(to_unsigned(15, 8));
            when "0001" => price <= std_logic_vector(to_unsigned(20, 8));
            when "0010" => price <= std_logic_vector(to_unsigned(25, 8));
            when "0011" => price <= std_logic_vector(to_unsigned(30, 8));
            when "0100" => price <= std_logic_vector(to_unsigned(35, 8));
            when "0101" => price <= std_logic_vector(to_unsigned(40, 8));
            when "0110" => price <= std_logic_vector(to_unsigned(45, 8));
            when "0111" => price <= std_logic_vector(to_unsigned(50, 8));
            when "1000" => price <= std_logic_vector(to_unsigned(55, 8));
            when "1001" => price <= std_logic_vector(to_unsigned(60, 8));
            when "1010" => price <= std_logic_vector(to_unsigned(65, 8));
            when "1011" => price <= std_logic_vector(to_unsigned(70, 8));
            when "1100" => price <= std_logic_vector(to_unsigned(75, 8));
            when "1101" => price <= std_logic_vector(to_unsigned(80, 8));
            when "1110" => price <= std_logic_vector(to_unsigned(85, 8));
            when "1111" => price <= std_logic_vector(to_unsigned(90, 8));
            when others => price <= (others => '0');
        end case;
    end process;
end Behavioral;


