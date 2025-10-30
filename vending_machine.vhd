library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity vending_machine is
    Port (
        clk          : in  STD_LOGIC;
        reset        : in  STD_LOGIC;
        ir_sensor_500  : in  STD_LOGIC;
        ir_sensor_1000 : in  STD_LOGIC;
        btn_buy      : in  STD_LOGIC;
        btn_reload_500   : in  STD_LOGIC;
        btn_reload_1000  : in  STD_LOGIC;
        keypad_rows  : in  STD_LOGIC_VECTOR(3 downto 0);
        keypad_cols  : out STD_LOGIC_VECTOR(3 downto 0);
        -- Displays FPGA internos
        display0     : out STD_LOGIC_VECTOR(6 downto 0);
        display1     : out STD_LOGIC_VECTOR(6 downto 0);
        display2     : out STD_LOGIC_VECTOR(6 downto 0);
        display3     : out STD_LOGIC_VECTOR(6 downto 0);
        -- Displays externos 5161BS
        display0_ext     : out STD_LOGIC_VECTOR(6 downto 0);
        display1_ext     : out STD_LOGIC_VECTOR(6 downto 0);
        display2_ext     : out STD_LOGIC_VECTOR(6 downto 0);
        display3_ext     : out STD_LOGIC_VECTOR(6 downto 0);
        led_red      : out STD_LOGIC;
        buzzer       : out STD_LOGIC;
        servo_pwm    : out STD_LOGIC;
        servo_change_500_pwm  : out STD_LOGIC;
        servo_change_1000_pwm : out STD_LOGIC;
        motor_product_3  : out STD_LOGIC;
        motor_product_11 : out STD_LOGIC
    );
end vending_machine;

architecture Behavioral of vending_machine is

    -- Señales de detección de monedas
    signal coin500_pulse   : STD_LOGIC := '0';
    signal coin1000_pulse  : STD_LOGIC := '0';
    signal pulse_500_counter  : integer range 0 to 50000000 := 0;
    signal pulse_1000_counter : integer range 0 to 50000000 := 0;
    constant PULSE_WIDTH : integer := 50000000;
    
    -- Señales de debounce para sensores IR
    signal ir_500_stable   : STD_LOGIC := '1';
    signal ir_1000_stable  : STD_LOGIC := '1';
    signal ir_500_prev     : STD_LOGIC := '1';
    signal ir_1000_prev    : STD_LOGIC := '1';
    signal debounce_counter_500  : integer range 0 to 1000000 := 0;
    signal debounce_counter_1000 : integer range 0 to 1000000 := 0;
    constant DEBOUNCE_TIME : integer := 1000000;

    -- Señales de control de servo de puerta
    signal servo_position : STD_LOGIC_VECTOR(1 downto 0) := "00";
    signal pwm_counter : integer range 0 to 1000000 := 0;
    signal pwm_duty : integer range 0 to 1000000 := 0;
    constant PWM_PERIOD : integer := 1000000;
    constant SERVO_CLOSED : integer := 50000;
    constant SERVO_OPEN : integer := 100000;

    -- Señales de cambio
    signal coin_500_available  : integer range 0 to 255;
    signal coin_1000_available : integer range 0 to 255;
    signal start_change        : STD_LOGIC := '0';
    signal change_done         : STD_LOGIC;
    signal change_dispensing   : STD_LOGIC;
    signal change_error        : STD_LOGIC;
    signal update_500          : STD_LOGIC;
    signal update_1000         : STD_LOGIC;
    signal update_500_count    : integer range 0 to 3;
    signal update_1000_count   : integer range 0 to 3;
    signal servo_change_500    : STD_LOGIC;
    signal servo_change_1000   : STD_LOGIC;

    -- Señales de máquina de estados
    signal coin_value      : STD_LOGIC_VECTOR(3 downto 0);
    signal total_money_int : integer range 0 to 9999 := 2000;
    signal product_price   : STD_LOGIC_VECTOR(12 downto 0);
    signal enough_money    : STD_LOGIC;
    signal no_stock        : STD_LOGIC;
    signal delivering      : STD_LOGIC;
    signal valid_buy       : STD_LOGIC;
    signal change_amount   : integer range 0 to 9999 := 0;
    signal show_change     : STD_LOGIC;
    signal showing_change_amount : STD_LOGIC := '0';
    signal change_amount_timer : integer range 0 to 5 := 0;
    signal reset_money     : STD_LOGIC := '0';
    signal sw_product      : STD_LOGIC_VECTOR(3 downto 0) := "0000";
    signal digit0, digit1, digit2, digit3 : STD_LOGIC_VECTOR(3 downto 0);
    
    -- Señales para detección de tecla D
    signal keypad_output : STD_LOGIC_VECTOR(3 downto 0);
    signal keypad_output_prev : STD_LOGIC_VECTOR(3 downto 0) := "0000";
    signal d_key_pressed : STD_LOGIC := '0';
    signal buy_trigger : STD_LOGIC := '0';
    
    -- Señales de displays
    signal display0_internal, display1_internal, display2_internal, display3_internal : STD_LOGIC_VECTOR(6 downto 0);
    
    -- Señales de temporización
    signal clk_1hz : STD_LOGIC;
    signal counter_1hz : integer range 0 to 25000000 := 0;
    constant DIVIDER_1HZ : integer := 25000000;
    signal delivery_timer : integer range 0 to 50 := 0;
    signal door_timer : integer range 0 to 10 := 0;
    signal motor_timer_3 : integer range 0 to 10 := 0;
    signal motor_timer_11 : integer range 0 to 10 := 0;
    signal use_motor_product_3 : STD_LOGIC := '0';
    signal use_motor_product_11 : STD_LOGIC := '0';
    constant DELIVERY_TIME : integer := 30;
    constant DOOR_OPEN_TIME : integer := 10;
    constant CHANGE_DISPLAY_TIME : integer := 5;
    constant MOTOR_RUN_TIME : integer := 3;

    -- Componentes
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

    component keypad_controller
        Port (
            clk         : in  STD_LOGIC;
            reset       : in  STD_LOGIC;
            rows        : in  STD_LOGIC_VECTOR(3 downto 0);
            cols        : out STD_LOGIC_VECTOR(3 downto 0);
            product_out : out STD_LOGIC_VECTOR(3 downto 0)
        );
    end component;

    component product_selector
        Port (
            sw_product : in  STD_LOGIC_VECTOR(3 downto 0);
            price      : out STD_LOGIC_VECTOR(12 downto 0)
        );
    end component;

    component price_checker
        Port (
            total_money   : in  STD_LOGIC_VECTOR(13 downto 0);
            product_price : in  STD_LOGIC_VECTOR(12 downto 0);
            enough_money  : out STD_LOGIC
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

    component seven_segment_5161bs
        Port (
            number : in  STD_LOGIC_VECTOR(3 downto 0);
            seg    : out STD_LOGIC_VECTOR(6 downto 0)
        );
    end component;

    component coin_memory
        Port (
            clk            : in  STD_LOGIC;
            reset          : in  STD_LOGIC;
            add_500        : in  STD_LOGIC;
            add_1000       : in  STD_LOGIC;
            sub_500        : in  STD_LOGIC;
            sub_1000       : in  STD_LOGIC;
            sub_500_count  : in  integer range 0 to 3;
            sub_1000_count : in  integer range 0 to 3;
            coin_500_avail  : out integer range 0 to 255;
            coin_1000_avail : out integer range 0 to 255;
            no_change      : out STD_LOGIC
        );
    end component;

    component change_dispenser
        Port (
            clk             : in  STD_LOGIC;
            reset           : in  STD_LOGIC;
            start_dispense  : in  STD_LOGIC;
            change_amount   : in  integer range 0 to 9999;
            coin_500_avail  : in  integer range 0 to 255;
            coin_1000_avail : in  integer range 0 to 255;
            servo_500_pwm   : out STD_LOGIC;
            servo_1000_pwm  : out STD_LOGIC;
            done_dispense   : out STD_LOGIC;
            dispensing      : out STD_LOGIC;
            used_500        : out STD_LOGIC;
            used_1000       : out STD_LOGIC;
            used_500_count  : out integer range 0 to 3;
            used_1000_count : out integer range 0 to 3;
            no_change       : out STD_LOGIC
        );
    end component;

    -- Función de conversión a BCD
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

    -- ========================================
    -- PROCESO: Detección de tecla D
    -- ========================================
    process(clk, reset)
    begin
        if reset = '1' then
            keypad_output_prev <= "0000";
            d_key_pressed <= '0';
        elsif rising_edge(clk) then
            -- Detectar flanco de subida en la tecla D (valor "1101")
            if keypad_output = "1101" and keypad_output_prev /= "1101" then
                d_key_pressed <= '1';
            else
                d_key_pressed <= '0';
            end if;
            
            keypad_output_prev <= keypad_output;
        end if;
    end process;

    -- ========================================
    -- PROCESO: Actualización de producto seleccionado
    -- ========================================
    process(clk, reset)
    begin
        if reset = '1' then
            sw_product <= "0000";
        elsif rising_edge(clk) then
            -- Solo actualizar si NO es la tecla D
            if keypad_output /= "1101" and keypad_output /= keypad_output_prev then
                sw_product <= keypad_output;
            end if;
        end if;
    end process;

    -- ========================================
    -- PROCESO: Control PWM del servo de puerta
    -- ========================================
    process(clk, reset)
    begin
        if reset = '1' then
            pwm_counter <= 0;
            servo_pwm <= '0';
            pwm_duty <= SERVO_CLOSED;
        elsif rising_edge(clk) then
            -- Selección de duty cycle según posición
            case servo_position is
                when "00" => pwm_duty <= SERVO_CLOSED;
                when "01" => pwm_duty <= SERVO_OPEN;
                when others => pwm_duty <= SERVO_CLOSED;
            end case;
            
            -- Generación de PWM
            if pwm_counter < pwm_duty then
                servo_pwm <= '1';
            else
                servo_pwm <= '0';
            end if;
            
            -- Contador de PWM
            if pwm_counter >= PWM_PERIOD - 1 then
                pwm_counter <= 0;
            else
                pwm_counter <= pwm_counter + 1;
            end if;
        end if;
    end process;

    -- ========================================
    -- PROCESO: Detección y debounce de monedas
    -- ========================================
    process(clk, reset)
        variable coin_detected_500  : STD_LOGIC := '0';
        variable coin_detected_1000 : STD_LOGIC := '0';
    begin
        if reset = '1' then
            ir_500_stable <= '1';
            ir_1000_stable <= '1';
            ir_500_prev <= '1';
            ir_1000_prev <= '1';
            debounce_counter_500 <= 0;
            debounce_counter_1000 <= 0;
            coin500_pulse <= '0';
            coin1000_pulse <= '0';
            pulse_500_counter <= 0;
            pulse_1000_counter <= 0;
            coin_detected_500 := '0';
            coin_detected_1000 := '0';
            
        elsif rising_edge(clk) then
            coin_detected_500 := '0';
            coin_detected_1000 := '0';
            
            -- Debounce sensor 500
            if ir_sensor_500 /= ir_500_stable then
                if debounce_counter_500 < DEBOUNCE_TIME then
                    debounce_counter_500 <= debounce_counter_500 + 1;
                else
                    ir_500_stable <= ir_sensor_500;
                    debounce_counter_500 <= 0;
                    if ir_500_prev = '1' and ir_sensor_500 = '0' then
                        coin_detected_500 := '1';
                    end if;
                    ir_500_prev <= ir_sensor_500;
                end if;
            else
                debounce_counter_500 <= 0;
            end if;
            
            -- Debounce sensor 1000
            if ir_sensor_1000 /= ir_1000_stable then
                if debounce_counter_1000 < DEBOUNCE_TIME then
                    debounce_counter_1000 <= debounce_counter_1000 + 1;
                else
                    ir_1000_stable <= ir_sensor_1000;
                    debounce_counter_1000 <= 0;
                    if ir_1000_prev = '1' and ir_sensor_1000 = '0' then
                        coin_detected_1000 := '1';
                    end if;
                    ir_1000_prev <= ir_sensor_1000;
                end if;
            else
                debounce_counter_1000 <= 0;
            end if;
            
            -- Generación de pulsos de moneda 500
            if coin_detected_500 = '1' then
                coin500_pulse <= '1';
                pulse_500_counter <= PULSE_WIDTH;
            elsif pulse_500_counter > 0 then
                pulse_500_counter <= pulse_500_counter - 1;
                coin500_pulse <= '1';
            else
                coin500_pulse <= '0';
            end if;
            
            -- Generación de pulsos de moneda 1000
            if coin_detected_1000 = '1' then
                coin1000_pulse <= '1';
                pulse_1000_counter <= PULSE_WIDTH;
            elsif pulse_1000_counter > 0 then
                pulse_1000_counter <= pulse_1000_counter - 1;
                coin1000_pulse <= '1';
            else
                coin1000_pulse <= '0';
            end if;
        end if;
    end process;

    -- ========================================
    -- PROCESO: Divisor de reloj a 1Hz
    -- ========================================
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

    -- ========================================
    -- Lógica de compra válida
    -- ========================================
    buy_trigger <= d_key_pressed or btn_buy;
    valid_buy <= buy_trigger and enough_money and not no_stock;

    -- ========================================
    -- INSTANCIACIÓN DE COMPONENTES
    -- ========================================
    U1: coin_detector
        port map (
            sw_coin500  => coin500_pulse,
            sw_coin1000 => coin1000_pulse,
            coin_out    => coin_value
        );

    U2: coin_counter
        port map (
            clk       => clk_1hz,
            reset     => reset or reset_money,
            coin_in   => coin_value,
            total_out => total_money_int
        );

    U_KEYPAD: keypad_controller
        port map (
            clk         => clk,
            reset       => reset,
            rows        => keypad_rows,
            cols        => keypad_cols,
            product_out => keypad_output
        );

    U3: product_selector
        port map (
            sw_product => sw_product,
            price      => product_price
        );

    U4: price_checker
        port map (
            total_money   => std_logic_vector(to_unsigned(total_money_int, 14)),
            product_price => product_price,
            enough_money  => enough_money
        );

    U6: stock_manager
        port map (
            clk        => clk_1hz,
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
            error      => change_error,
            led_red    => led_red,
            buzzer     => buzzer
        );

    U_COIN_MEM: coin_memory
        port map (
            clk            => clk,
            reset          => reset,
            add_500        => btn_reload_500,
            add_1000       => btn_reload_1000,
            sub_500        => update_500,
            sub_1000       => update_1000,
            sub_500_count  => update_500_count,
            sub_1000_count => update_1000_count,
            coin_500_avail  => coin_500_available,
            coin_1000_avail => coin_1000_available,
            no_change      => open
        );

    U_DISPENSER: change_dispenser
        port map (
            clk             => clk,
            reset           => reset,
            start_dispense  => start_change,
            change_amount   => change_amount,
            coin_500_avail  => coin_500_available,
            coin_1000_avail => coin_1000_available,
            servo_500_pwm   => servo_change_500,
            servo_1000_pwm  => servo_change_1000,
            done_dispense   => change_done,
            dispensing      => change_dispensing,
            used_500        => update_500,
            used_1000       => update_1000,
            used_500_count  => update_500_count,
            used_1000_count => update_1000_count,
            no_change       => change_error
        );
    
    servo_change_500_pwm <= servo_change_500;
    servo_change_1000_pwm <= servo_change_1000;

    -- ========================================
    -- PROCESO: Máquina de estados principal
    -- ========================================
    process(clk_1hz, reset)
    begin
        if reset = '1' then
            delivering <= '0';
            delivery_timer <= 0;
            door_timer <= 0;
            motor_timer_3 <= 0;
            motor_timer_11 <= 0;
            servo_position <= "00";
            show_change <= '0';
            showing_change_amount <= '0';
            change_amount_timer <= 0;
            change_amount <= 0;
            reset_money <= '0';
            start_change <= '0';
            motor_product_3 <= '0';
            motor_product_11 <= '0';
            use_motor_product_3 <= '0';
            use_motor_product_11 <= '0';
            
        elsif rising_edge(clk_1hz) then
            -- Reset temporal de dinero
            if reset_money = '1' then
                reset_money <= '0';
            end if;
            
            -- Estado: INICIO DE COMPRA
            if valid_buy = '1' and delivering = '0' and show_change = '0' and showing_change_amount = '0' then
                -- Calcular cambio
                if total_money_int >= to_integer(unsigned(product_price)) then
                    change_amount <= total_money_int - to_integer(unsigned(product_price));
                else
                    change_amount <= 0;
                end if;
                
                -- Determinar qué motor usar
                if sw_product = "0011" then
                    use_motor_product_3 <= '1';
                    use_motor_product_11 <= '0';
                elsif sw_product = "1011" then
                    use_motor_product_3 <= '0';
                    use_motor_product_11 <= '1';
                else
                    use_motor_product_3 <= '0';
                    use_motor_product_11 <= '0';
                end if;
                
                -- Iniciar entrega
                delivering <= '1';
                delivery_timer <= DELIVERY_TIME;
                motor_timer_3 <= MOTOR_RUN_TIME;
                motor_timer_11 <= MOTOR_RUN_TIME;
                servo_position <= "00";
                show_change <= '0';
                showing_change_amount <= '0';
                start_change <= '0';
                
                -- Activar motor correspondiente
                if sw_product = "0011" then
                    motor_product_3 <= '1';
                    motor_product_11 <= '0';
                elsif sw_product = "1011" then
                    motor_product_3 <= '0';
                    motor_product_11 <= '1';
                else
                    motor_product_3 <= '0';
                    motor_product_11 <= '0';
                end if;
            
            -- Estado: ENTREGANDO PRODUCTO
            elsif delivering = '1' then
                -- Reset dinero al inicio de la entrega
                if delivery_timer = DELIVERY_TIME then
                    reset_money <= '1';
                end if;
                
                -- Control del motor producto 3
                if use_motor_product_3 = '1' then
                    if motor_timer_3 > 0 then
                        motor_timer_3 <= motor_timer_3 - 1;
                        motor_product_3 <= '1';
                    else
                        motor_product_3 <= '0';
                    end if;
                else
                    motor_product_3 <= '0';
                end if;
                
                -- Control del motor producto 11
                if use_motor_product_11 = '1' then
                    if motor_timer_11 > 0 then
                        motor_timer_11 <= motor_timer_11 - 1;
                        motor_product_11 <= '1';
                    else
                        motor_product_11 <= '0';
                    end if;
                else
                    motor_product_11 <= '0';
                end if;
                
                -- Control de la puerta
                if delivery_timer > 20 then
                    servo_position <= "00";
                else
                    servo_position <= "01";
                end if;
                
                -- Cuenta regresiva
                if delivery_timer > 0 then
                    delivery_timer <= delivery_timer - 1;
                else
                    delivering <= '0';
                    show_change <= '1';
                    door_timer <= DOOR_OPEN_TIME;
                    motor_product_3 <= '0';
                    motor_product_11 <= '0';
                end if;
            
            -- Estado: DISPENSANDO CAMBIO
            elsif show_change = '1' then
                servo_position <= "01";
                motor_product_3 <= '0';
                motor_product_11 <= '0';
                
                -- Iniciar dispensación de cambio
                if door_timer = DOOR_OPEN_TIME and change_amount > 0 then
                    start_change <= '1';
                end if;
                
                -- Cuenta regresiva
                if door_timer > 0 then
                    door_timer <= door_timer - 1;
                else
                    show_change <= '0';
                    showing_change_amount <= '1';
                    change_amount_timer <= CHANGE_DISPLAY_TIME;
                end if;
            
            -- Estado: MOSTRANDO MONTO DE CAMBIO
            elsif showing_change_amount = '1' then
                servo_position <= "01";
                motor_product_3 <= '0';
                motor_product_11 <= '0';
                
                -- Cuenta regresiva
                if change_amount_timer > 0 then
                    change_amount_timer <= change_amount_timer - 1;
                else
                    showing_change_amount <= '0';
                    servo_position <= "00";
                    change_amount <= 0;
                    start_change <= '0';
                end if;
            
            -- Estado: REPOSO
            else
                servo_position <= "00";
                motor_product_3 <= '0';
                motor_product_11 <= '0';
            end if;
        end if;
    end process;
    
    -- ========================================
    -- PROCESO: Control de displays
    -- ========================================
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
            -- Selección de valor a mostrar
            if delivering = '1' then
                display_number := delivery_timer;
            elsif show_change = '1' then
                display_number := door_timer;
            elsif showing_change_amount = '1' then
                display_number := change_amount;
            else
                display_number := total_money_int;
            end if;
            
            -- Conversión a BCD
            bcd_value := to_bcd(display_number);
            digit3 <= bcd_value(15 downto 12);
            digit2 <= bcd_value(11 downto 8);
            digit1 <= bcd_value(7 downto 4);
            digit0 <= bcd_value(3 downto 0);
        end if;
    end process;

    -- ========================================
    -- INSTANCIACIÓN DE DISPLAYS INTERNOS
    -- ========================================
    DISP0: seven_segment
        port map (number => digit0, seg => display0_internal);

    DISP1: seven_segment
        port map (number => digit1, seg => display1_internal);

    DISP2: seven_segment
        port map (number => digit2, seg => display2_internal);

    DISP3: seven_segment
        port map (number => digit3, seg => display3_internal);
    
    display0 <= display0_internal;
    display1 <= display1_internal;
    display2 <= display2_internal;
    display3 <= display3_internal;
    
    -- ========================================
    -- INSTANCIACIÓN DE DISPLAYS EXTERNOS 5161BS
    -- ========================================
    DISP0_EXT: seven_segment_5161bs
        port map (number => digit0, seg => display0_ext);

    DISP1_EXT: seven_segment_5161bs
        port map (number => digit1, seg => display1_ext);

    DISP2_EXT: seven_segment_5161bs
        port map (number => digit2, seg => display2_ext);

    DISP3_EXT: seven_segment_5161bs
        port map (number => digit3, seg => display3_ext);

end Behavioral;