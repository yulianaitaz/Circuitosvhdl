library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity keypad_controller is
    Port (
        clk         : in  STD_LOGIC;
        reset       : in  STD_LOGIC;
        rows        : in  STD_LOGIC_VECTOR(3 downto 0);
        cols        : out STD_LOGIC_VECTOR(3 downto 0);
        product_out : out STD_LOGIC_VECTOR(3 downto 0)
    );
end keypad_controller;

architecture Behavioral of keypad_controller is
    -- Clock de escaneo lento (10Hz = cada 100ms)
    signal scan_clk : STD_LOGIC := '0';
    signal scan_counter : integer range 0 to 5000000 := 0;
    constant SCAN_DIVIDER : integer := 5000000; -- 100ms a 50MHz
    
    -- Índice de columna
    signal col_index : integer range 0 to 3 := 0;
    signal prev_col_index : integer range 0 to 3 := 0;
    
    -- Columnas internas
    signal cols_internal : STD_LOGIC_VECTOR(3 downto 0) := "1110";
    
    -- Detección de tecla
    signal product_reg : STD_LOGIC_VECTOR(3 downto 0) := "0000";
    signal rows_latched : STD_LOGIC_VECTOR(3 downto 0) := "1111";
    
begin

    -- Generador de clock de escaneo
    process(clk, reset)
    begin
        if reset = '1' then
            scan_counter <= 0;
            scan_clk <= '0';
        elsif rising_edge(clk) then
            if scan_counter = SCAN_DIVIDER - 1 then
                scan_counter <= 0;
                scan_clk <= not scan_clk;
            else
                scan_counter <= scan_counter + 1;
            end if;
        end if;
    end process;
    
    -- Proceso de escaneo con retardo
    process(scan_clk, reset)
    begin
        if reset = '1' then
            col_index <= 0;
            prev_col_index <= 0;
            cols_internal <= "1110";
            product_reg <= "0000";
            rows_latched <= "1111";
            
        elsif rising_edge(scan_clk) then
            -- PASO 1: Leer filas con la columna del ciclo ANTERIOR
            rows_latched <= rows;
            
            -- PASO 2: Detectar tecla usando prev_col_index
            if rows /= "1111" then
                case prev_col_index is
                    when 0 => -- Columna 0
                        if rows(0) = '0' then
                            product_reg <= "0001"; -- Tecla 1
                        elsif rows(1) = '0' then
                            product_reg <= "0100"; -- Tecla 4
                        elsif rows(2) = '0' then
                            product_reg <= "0111"; -- Tecla 7
                        elsif rows(3) = '0' then
                            product_reg <= "0000"; -- Tecla * (como 0)
                        end if;
                        
                    when 1 => -- Columna 1
                        if rows(0) = '0' then
                            product_reg <= "0010"; -- Tecla 2
                        elsif rows(1) = '0' then
                            product_reg <= "0101"; -- Tecla 5
                        elsif rows(2) = '0' then
                            product_reg <= "1000"; -- Tecla 8
                        elsif rows(3) = '0' then
                            product_reg <= "0000"; -- Tecla 0
                        end if;
                        
                    when 2 => -- Columna 2
                        if rows(0) = '0' then
                            product_reg <= "0011"; -- Tecla 3
                        elsif rows(1) = '0' then
                            product_reg <= "0110"; -- Tecla 6
                        elsif rows(2) = '0' then
                            product_reg <= "1001"; -- Tecla 9
                        elsif rows(3) = '0' then
                            product_reg <= "0000"; -- Tecla # (como 0)
                        end if;
                        
                    when 3 => -- Columna 3
                        if rows(0) = '0' then
                            product_reg <= "1010"; -- Tecla A
                        elsif rows(1) = '0' then
                            product_reg <= "1011"; -- Tecla B
                        elsif rows(2) = '0' then
                            product_reg <= "1100"; -- Tecla C
                        elsif rows(3) = '0' then
                            product_reg <= "1101"; -- Tecla D
                        end if;
                        
                    when others =>
                        null;
                end case;
            end if;
            
            -- PASO 3: Guardar columna actual como "anterior"
            prev_col_index <= col_index;
            
            -- PASO 4: Avanzar a la siguiente columna
            col_index <= (col_index + 1) mod 4;
            
            -- PASO 5: Activar la nueva columna
            case col_index is
                when 0 => cols_internal <= "1110";
                when 1 => cols_internal <= "1101";
                when 2 => cols_internal <= "1011";
                when 3 => cols_internal <= "0111";
                when others => cols_internal <= "1111";
            end case;
        end if;
    end process;
    
    -- Salidas
    cols <= cols_internal;
    product_out <= product_reg;

end Behavioral;