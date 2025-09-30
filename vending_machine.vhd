-- vending_machine.vhd con divisor de frecuencia
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity vending_machine is
    Port (
        clk          : in  STD_LOGIC;
        reset        : in  STD_LOGIC;
        -- Entradas de monedas (botones)
        btn_coin500  : in  STD_LOGIC;
        btn_coin1000 : in  STD_LOGIC;
        btn_buy      : in  STD_LOGIC;
        -- Selector de producto con 4 switches (16 productos)
        sw_product   : in  STD_LOGIC_VECTOR(3 downto 0);
        -- Salidas de display (4 displays de 7 segmentos)
        display0     : out STD_LOGIC_VECTOR(6 downto 0);
        display1     : out STD_LOGIC_VECTOR(6 downto 0);
        display2     : out STD_LOGIC_VECTOR(6 downto 0);
        display3     : out STD_LOGIC_VECTOR(6 downto 0);
        -- Salidas de alertas
        led_red      : out STD_LOGIC;
        buzzer       : out STD_LOGIC;
        -- Salida de puerta
        door         : out STD_LOGIC
    );
end vending_machine;

architecture Behavioral of vending_machine is

    -- Señales internas
    signal coin_value      : STD_LOGIC_VECTOR(3 downto 0);
    signal total_money_int : integer := 0;
    signal product_price   : STD_LOGIC_VECTOR(7 downto 0);
    signal enough_money    : STD_LOGIC;
    signal no_stock        : STD_LOGIC;
    signal delivering      : STD_LOGIC;
    signal valid_buy       : STD_LOGIC;
    
    -- Señales para displays
    signal digit0, digit1, digit2, digit3 : STD_LOGIC_VECTOR(3 downto 0);
    
    -- Divisor de frecuencia para 1 Hz
    signal clk_1hz : STD_LOGIC;
    signal counter_1hz : integer := 0;
    constant DIVIDER_1HZ : integer := 50000000; -- Para 50 MHz -> 1 Hz
    
    -- Timer de entrega (ahora en segundos)
    signal timer_seconds : integer := 0;
    constant DELIVERY_TIME : integer := 30; -- 30 segundos

    -- Component declarations
    component coin_detector
        Port (
            sw_coin500  : in  STD_LOGIC;
            sw_coin1000 : in  STD_LOGIC;
            coin_out    : out STD_LOGIC_VECTOR(3 downto 0)
        );
    end component;

    component coin_counter
        Port (
            clk       : in  STD_LOGIC;
            reset     : in  STD_LOGIC;
            coin_in   : in  STD_LOGIC_VECTOR(3 downto 0);
            total_out : out integer
        );
    end component;

    component product_selector
        Port (
            sw_product : in  STD_LOGIC_VECTOR(3 downto 0);
            price      : out STD_LOGIC_VECTOR(7 downto 0)
        );
    end component;

    component price_checker
        Port (
            total_money  : in  STD_LOGIC_VECTOR(7 downto 0);
            enough_money : out STD_LOGIC
        );
    end component;

    component stock_manager
        Port (
            clk        : in  STD_LOGIC;
            reset      : in  STD_LOGIC;
            product_id : in  STD_LOGIC_VECTOR(3 downto 0);
            valid_buy  : in  STD_LOGIC;
            no_stock   : out STD_LOGIC
        );
    end component;

    component alerts
        Port (
            clk          : in  STD_LOGIC;
            reset        : in  STD_LOGIC;
            no_stock     : in  STD_LOGIC;
            delivering   : in  STD_LOGIC;
            error        : in  STD_LOGIC;
            led_red      : out STD_LOGIC;
            buzzer       : out STD_LOGIC
        );
    end component;

    component seven_segment
        Port (
            number : in  STD_LOGIC_VECTOR(3 downto 0);
            seg    : out STD_LOGIC_VECTOR(6 downto 0)
        );
    end component;

begin

    -- Divisor de frecuencia para 1 Hz
    process(clk, reset)
    begin
        if reset = '1' then
            counter_1hz <= 0;
            clk_1hz <= '0';
        elsif rising_edge(clk) then
            if counter_1hz < DIVIDER_1HZ/2 then
                counter_1hz <= counter_1hz + 1;
                clk_1hz <= '0';
            elsif counter_1hz < DIVIDER_1HZ then
                counter_1hz <= counter_1hz + 1;
                clk_1hz <= '1';
            else
                counter_1hz <= 0;
                clk_1hz <= '0';
            end if;
        end if;
    end process;

    -- Lógica de compra válida
    valid_buy <= btn_buy and enough_money and not no_stock;

    -- Mapeo de componentes (usando clk_1hz para algunos procesos)
    U1: coin_detector
        port map (
            sw_coin500  => btn_coin500,
            sw_coin1000 => btn_coin1000,
            coin_out    => coin_value
        );

    U2: coin_counter
        port map (
            clk       => clk_1hz,  -- Usar reloj de 1 Hz para contar monedas
            reset     => reset,
            coin_in   => coin_value,
            total_out => total_money_int
        );

    U3: product_selector
        port map (
            sw_product => sw_product,
            price      => product_price
        );

    U4: price_checker
        port map (
            total_money  => std_logic_vector(to_unsigned(total_money_int, 8)),
            enough_money => enough_money
        );

    U6: stock_manager
        port map (
            clk        => clk_1hz,  -- Usar reloj de 1 Hz para gestión de stock
            reset      => reset,
            product_id => sw_product,
            valid_buy  => valid_buy,
            no_stock   => no_stock
        );

    U8: alerts
        port map (
            clk        => clk,
            reset      => reset,
            no_stock   => no_stock,
            delivering => delivering,
            error      => '0',
            led_red    => led_red,
            buzzer     => buzzer
        );

    -- Lógica de entrega simplificada (usando clk_1hz para timer en segundos)
    process(clk_1hz, reset)
    begin
        if reset = '1' then
            delivering <= '0';
            timer_seconds <= 0;
            door <= '0';
        elsif rising_edge(clk_1hz) then
            if valid_buy = '1' and delivering = '0' then
                -- Iniciar entrega
                delivering <= '1';
                timer_seconds <= DELIVERY_TIME;
                door <= '1';
            elsif delivering = '1' then
                if timer_seconds > 0 then
                    timer_seconds <= timer_seconds - 1;
                else
                    -- Terminar entrega
                    delivering <= '0';
                    door <= '0';
                end if;
            else
                door <= '0';
            end if;
        end if;
    end process;

    -- Lógica de display MEJORADA
    process(clk_1hz, reset)
        variable money_temp : integer;
    begin
        if reset = '1' then
            digit0 <= "0000";
            digit1 <= "0000";
            digit2 <= "0000";
            digit3 <= "0000";
        elsif rising_edge(clk_1hz) then
            if delivering = '1' then
                -- Mostrar tiempo restante de entrega
                digit3 <= std_logic_vector(to_unsigned(timer_seconds / 10, 4)); -- Decenas de segundos
                digit2 <= std_logic_vector(to_unsigned(timer_seconds mod 10, 4)); -- Unidades de segundos
                digit1 <= "1110"; -- E
                digit0 <= "1110"; -- E
            else
                -- Mostrar dinero acumulado
                money_temp := total_money_int;
                
                -- Unidades
                digit0 <= std_logic_vector(to_unsigned(money_temp mod 10, 4));
                money_temp := money_temp / 10;
                
                -- Decenas
                digit1 <= std_logic_vector(to_unsigned(money_temp mod 10, 4));
                money_temp := money_temp / 10;
                
                -- Centenas
                digit2 <= std_logic_vector(to_unsigned(money_temp mod 10, 4));
                money_temp := money_temp / 10;
                
                -- Millares
                digit3 <= std_logic_vector(to_unsigned(money_temp mod 10, 4));
            end if;
        end if;
    end process;

    -- Display controllers
    DISP0: seven_segment
        port map (
            number => digit0,
            seg    => display0
        );

    DISP1: seven_segment
        port map (
            number => digit1,
            seg    => display1
        );

    DISP2: seven_segment
        port map (
            number => digit2,
            seg    => display2
        );

    DISP3: seven_segment
        port map (
            number => digit3,
            seg    => display3
        );

end Behavioral;