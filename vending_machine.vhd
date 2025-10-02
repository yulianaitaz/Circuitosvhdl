-- vending_machine.vhd CORREGIDO
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
    signal total_money_int : integer range 0 to 9999 := 0;
    signal product_price   : STD_LOGIC_VECTOR(7 downto 0);
    signal enough_money    : STD_LOGIC;
    signal no_stock        : STD_LOGIC;
    signal delivering      : STD_LOGIC;
    signal valid_buy       : STD_LOGIC;
    signal change_amount   : STD_LOGIC_VECTOR(11 downto 0);
    signal show_change     : STD_LOGIC;
    signal change_display_timer : integer range 0 to 10 := 0;
    
    -- Señales para displays
    signal digit0, digit1, digit2, digit3 : STD_LOGIC_VECTOR(3 downto 0);
    
    -- Divisor de frecuencia para 1 Hz
    signal clk_1hz : STD_LOGIC;
    signal counter_1hz : integer range 0 to 25000000 := 0;
    constant DIVIDER_1HZ : integer := 25000000; -- Para 50 MHz -> 1 Hz
    
    -- Timer de entrega
    signal delivery_timer : integer range 0 to 31 := 0;
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
            total_out : out integer range 0 to 9999
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

    component change_calculator
        Port (
            clk        : in  std_logic;
            reset      : in  std_logic;
            money_in   : in  std_logic_vector(11 downto 0);
            price      : in  std_logic_vector(7 downto 0);
            change_out : out std_logic_vector(11 downto 0)
        );
    end component;

    -- Función para convertir número a dígitos BCD
    function to_bcd(number : integer) return std_logic_vector is
        variable temp : integer;
        variable bcd : std_logic_vector(15 downto 0);
    begin
        temp := number;
        bcd := (others => '0');
        
        for i in 0 to 3 loop
            bcd((i+1)*4-1 downto i*4) := std_logic_vector(to_unsigned(temp mod 10, 4));
            temp := temp / 10;
        end loop;
        
        return bcd;
    end function;

begin

    -- Divisor de frecuencia para 1 Hz
    process(clk, reset)
    begin
        if reset = '1' then
            counter_1hz <= 0;
            clk_1hz <= '0';
        elsif rising_edge(clk) then
            if counter_1hz = DIVIDER_1HZ - 1 then
                counter_1hz <= 0;
                clk_1hz <= not clk_1hz;
            else
                counter_1hz <= counter_1hz + 1;
            end if;
        end if;
    end process;

    -- Lógica de compra válida
    valid_buy <= btn_buy and enough_money and not no_stock;

    -- Mapeo de componentes
    U1: coin_detector
        port map (
            sw_coin500  => btn_coin500,
            sw_coin1000 => btn_coin1000,
            coin_out    => coin_value
        );

    U2: coin_counter
        port map (
            clk       => clk_1hz,
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
            clk        => clk_1hz,
            reset      => reset,
            product_id => sw_product,
            valid_buy  => valid_buy,
            no_stock   => no_stock
        );

    -- Calculador de cambio
    U7: change_calculator
        port map (
            clk        => clk_1hz,
            reset      => reset,
            money_in   => std_logic_vector(to_unsigned(total_money_int, 12)),
            price      => product_price,
            change_out => change_amount
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

    -- Lógica de entrega CORREGIDA
	 -- Lógica de entrega CORREGIDA - REEMPLAZA EL PROCESO ACTUAL CON ESTE:
process(clk_1hz, reset)
begin
    if reset = '1' then
        delivering <= '0';
        delivery_timer <= 0;
        door <= '0';
        show_change <= '0';
        change_display_timer <= 0;
    elsif rising_edge(clk_1hz) then
        if valid_buy = '1' and delivering = '0' and show_change = '0' then
            -- Iniciar entrega
            delivering <= '1';
            delivery_timer <= DELIVERY_TIME;
            door <= '1';
            show_change <= '0';
        elsif delivering = '1' then
            if delivery_timer > 0 then
                delivery_timer <= delivery_timer - 1;
            else
                -- Terminar entrega
                delivering <= '0';
                door <= '0';
                if to_integer(unsigned(change_amount)) > 0 then
                    show_change <= '1';
                    change_display_timer <= 10; -- Mostrar cambio por 10 segundos
                end if;
            end if;
        elsif show_change = '1' then
            if change_display_timer > 0 then
                change_display_timer <= change_display_timer - 1;
            else
                show_change <= '0';
            end if;
        end if;
    end if;
end process;
    

    -- Lógica de display CORREGIDA
      -- Lógica de display CORREGIDA - REEMPLAZA EL PROCESO ACTUAL CON ESTE:
process(clk_1hz, reset)
    variable bcd_value : std_logic_vector(15 downto 0);
    variable display_number : integer;
begin
    if reset = '1' then
        digit0 <= "0000";
        digit1 <= "0000";
        digit2 <= "0000";
        digit3 <= "0000";
    elsif rising_edge(clk_1hz) then
        if delivering = '1' then
            -- Mostrar tiempo restante de entrega (30, 29, 28...)
            display_number := delivery_timer;
            bcd_value := to_bcd(display_number);
            digit3 <= bcd_value(15 downto 12); -- Millares (siempre 0)
            digit2 <= bcd_value(11 downto 8);  -- Centenas (siempre 0)
            digit1 <= bcd_value(7 downto 4);   -- Decenas
            digit0 <= bcd_value(3 downto 0);   -- Unidades
        elsif show_change = '1' then
            -- Mostrar cambio
            display_number := to_integer(unsigned(change_amount));
            bcd_value := to_bcd(display_number);
            digit3 <= bcd_value(15 downto 12); -- Millares
            digit2 <= bcd_value(11 downto 8);  -- Centenas
            digit1 <= bcd_value(7 downto 4);   -- Decenas
            digit0 <= bcd_value(3 downto 0);   -- Unidades
        else
            -- Mostrar dinero acumulado
            display_number := total_money_int;
            bcd_value := to_bcd(display_number);
            digit3 <= bcd_value(15 downto 12); -- Millares
            digit2 <= bcd_value(11 downto 8);  -- Centenas
            digit1 <= bcd_value(7 downto 4);   -- Decenas
            digit0 <= bcd_value(3 downto 0);   -- Unidades
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