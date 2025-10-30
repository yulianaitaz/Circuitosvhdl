library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity coin_memory is
    Port (
        clk            : in  STD_LOGIC;
        reset          : in  STD_LOGIC;
        -- Señales para agregar monedas (recarga manual)
        add_500        : in  STD_LOGIC;
        add_1000       : in  STD_LOGIC;
        -- Señales para restar monedas (cuando se entrega cambio)
        sub_500        : in  STD_LOGIC;
        sub_1000       : in  STD_LOGIC;
        -- Cantidad de monedas a restar (para cambios múltiples)
        sub_500_count  : in  integer range 0 to 3 := 1;
        sub_1000_count : in  integer range 0 to 3 := 1;
        -- Monedas disponibles
        coin_500_avail  : out integer range 0 to 255;
        coin_1000_avail : out integer range 0 to 255;
        -- Señal de error (no hay suficientes monedas)
        no_change      : out STD_LOGIC
    );
end coin_memory;

architecture Behavioral of coin_memory is
    -- Registros de memoria para las monedas
    signal coins_500  : integer range 0 to 255 := 10;  -- Inicializar con 10 monedas
    signal coins_1000 : integer range 0 to 255 := 10;  -- Inicializar con 10 monedas
    
    -- Señales previas para detección de flancos
    signal add_500_prev   : STD_LOGIC := '0';
    signal add_1000_prev  : STD_LOGIC := '0';
    signal sub_500_prev   : STD_LOGIC := '0';
    signal sub_1000_prev  : STD_LOGIC := '0';

begin

    -- Proceso principal de gestión de memoria
    process(clk, reset)
    begin
        if reset = '1' then
            -- Reiniciar a valores iniciales
            coins_500  <= 10;
            coins_1000 <= 10;
            add_500_prev   <= '0';
            add_1000_prev  <= '0';
            sub_500_prev   <= '0';
            sub_1000_prev  <= '0';
            
        elsif rising_edge(clk) then
            -- ============================================
            -- AGREGAR MONEDAS (detección de flanco)
            -- ============================================
            -- Agregar moneda de 500
            if add_500 = '1' and add_500_prev = '0' then
                if coins_500 < 255 then
                    coins_500 <= coins_500 + 1;
                end if;
            end if;
            add_500_prev <= add_500;
            
            -- Agregar moneda de 1000
            if add_1000 = '1' and add_1000_prev = '0' then
                if coins_1000 < 255 then
                    coins_1000 <= coins_1000 + 1;
                end if;
            end if;
            add_1000_prev <= add_1000;
            
            -- ============================================
            -- RESTAR MONEDAS (detección de flanco)
            -- ============================================
            -- Restar monedas de 500
            if sub_500 = '1' and sub_500_prev = '0' then
                if coins_500 >= sub_500_count then
                    coins_500 <= coins_500 - sub_500_count;
                else
                    coins_500 <= 0;  -- Protección contra negativos
                end if;
            end if;
            sub_500_prev <= sub_500;
            
            -- Restar monedas de 1000
            if sub_1000 = '1' and sub_1000_prev = '0' then
                if coins_1000 >= sub_1000_count then
                    coins_1000 <= coins_1000 - sub_1000_count;
                else
                    coins_1000 <= 0;  -- Protección contra negativos
                end if;
            end if;
            sub_1000_prev <= sub_1000;
        end if;
    end process;
    
    -- Asignación de salidas
    coin_500_avail  <= coins_500;
    coin_1000_avail <= coins_1000;
    
    -- Señal de error: no hay suficientes monedas para cualquier cambio
    no_change <= '1' when (coins_500 = 0 and coins_1000 = 0) else '0';

end Behavioral;