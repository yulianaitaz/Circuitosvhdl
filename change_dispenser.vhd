library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity change_dispenser is
    Port (
        clk             : in  STD_LOGIC;
        reset           : in  STD_LOGIC;
        -- Control
        start_dispense  : in  STD_LOGIC;
        change_amount   : in  integer range 0 to 9999;
        -- Disponibilidad de monedas
        coin_500_avail  : in  integer range 0 to 255;
        coin_1000_avail : in  integer range 0 to 255;
        -- Salidas PWM para servos
        servo_500_pwm   : out STD_LOGIC;
        servo_1000_pwm  : out STD_LOGIC;
        -- Estado y control
        done_dispense   : out STD_LOGIC;
        dispensing      : out STD_LOGIC;
        -- Monedas usadas (para actualizar memoria)
        used_500        : out STD_LOGIC;
        used_1000       : out STD_LOGIC;
        used_500_count  : out integer range 0 to 3;
        used_1000_count : out integer range 0 to 3;
        -- Error
        no_change       : out STD_LOGIC
    );
end change_dispenser;

architecture Behavioral of change_dispenser is
    
    -- Estados de la máquina de estados
    type state_type is (IDLE, CHECK_CHANGE, DISPENSE_1000, WAIT_1000, 
                        DISPENSE_500, WAIT_500, DONE, ERROR_STATE);
    signal state : state_type := IDLE;
    
    -- Generador de clock 1Hz para delays
    signal clk_1hz : STD_LOGIC := '0';
    signal counter_1hz : integer range 0 to 25000000 := 0;
    constant DIVIDER_1HZ : integer := 25000000;  -- Ajustar según tu frecuencia
    
    -- Contadores
    signal coins_1000_to_dispense : integer range 0 to 3 := 0;
    signal coins_500_to_dispense  : integer range 0 to 3 := 0;
    signal delay_counter : integer range 0 to 3 := 0;
    constant DELAY_TICKS : integer := 2;  -- 2 segundos de delay por moneda
    
    -- Variables temporales para contar monedas usadas
    signal total_used_500  : integer range 0 to 3 := 0;
    signal total_used_1000 : integer range 0 to 3 := 0;
    
    -- Control PWM para servos
    signal pwm_counter_500  : integer range 0 to 1000000 := 0;
    signal pwm_counter_1000 : integer range 0 to 1000000 := 0;
    signal servo_500_pos    : STD_LOGIC_VECTOR(1 downto 0) := "00";
    signal servo_1000_pos   : STD_LOGIC_VECTOR(1 downto 0) := "00";
    
    constant PWM_PERIOD : integer := 1000000;     -- 20ms a 50MHz
    constant SERVO_CLOSED : integer := 50000;     -- 1ms (0°)
    constant SERVO_OPEN : integer := 100000;      -- 2ms (90°)
    
begin

    -- ============================================
    -- GENERADOR DE CLOCK 1Hz
    -- ============================================
    process(clk, reset)
    begin
        if reset = '1' then
            counter_1hz <= 0;
            clk_1hz <= '0';
        elsif rising_edge(clk) then
            if counter_1hz >= DIVIDER_1HZ - 1 then
                counter_1hz <= 0;
                clk_1hz <= not clk_1hz;
            else
                counter_1hz <= counter_1hz + 1;
            end if;
        end if;
    end process;

    -- ============================================
    -- GENERADOR PWM PARA SERVO 500
    -- ============================================
    process(clk, reset)
        variable pwm_duty : integer range 0 to 1000000;
    begin
        if reset = '1' then
            pwm_counter_500 <= 0;
            servo_500_pwm <= '0';
        elsif rising_edge(clk) then
            -- Determinar duty cycle
            if servo_500_pos = "01" then
                pwm_duty := SERVO_OPEN;
            else
                pwm_duty := SERVO_CLOSED;
            end if;
            
            -- Generar PWM
            if pwm_counter_500 < pwm_duty then
                servo_500_pwm <= '1';
            else
                servo_500_pwm <= '0';
            end if;
            
            if pwm_counter_500 >= PWM_PERIOD - 1 then
                pwm_counter_500 <= 0;
            else
                pwm_counter_500 <= pwm_counter_500 + 1;
            end if;
        end if;
    end process;

    -- ============================================
    -- GENERADOR PWM PARA SERVO 1000
    -- ============================================
    process(clk, reset)
        variable pwm_duty : integer range 0 to 1000000;
    begin
        if reset = '1' then
            pwm_counter_1000 <= 0;
            servo_1000_pwm <= '0';
        elsif rising_edge(clk) then
            -- Determinar duty cycle
            if servo_1000_pos = "01" then
                pwm_duty := SERVO_OPEN;
            else
                pwm_duty := SERVO_CLOSED;
            end if;
            
            -- Generar PWM
            if pwm_counter_1000 < pwm_duty then
                servo_1000_pwm <= '1';
            else
                servo_1000_pwm <= '0';
            end if;
            
            if pwm_counter_1000 >= PWM_PERIOD - 1 then
                pwm_counter_1000 <= 0;
            else
                pwm_counter_1000 <= pwm_counter_1000 + 1;
            end if;
        end if;
    end process;

    -- ============================================
    -- MÁQUINA DE ESTADOS PRINCIPAL
    -- ============================================
    process(clk_1hz, reset)
    begin
        if reset = '1' then
            state <= IDLE;
            coins_1000_to_dispense <= 0;
            coins_500_to_dispense <= 0;
            delay_counter <= 0;
            servo_500_pos <= "00";
            servo_1000_pos <= "00";
            done_dispense <= '0';
            dispensing <= '0';
            used_500 <= '0';
            used_1000 <= '0';
            used_500_count <= 0;
            used_1000_count <= 0;
            total_used_500 <= 0;
            total_used_1000 <= 0;
            no_change <= '0';
            
        elsif rising_edge(clk_1hz) then
            
            -- Reset de señales de pulso por defecto
            used_500 <= '0';
            used_1000 <= '0';
            
            case state is
                
                -- ==================== ESTADO IDLE ====================
                when IDLE =>
                    done_dispense <= '0';
                    dispensing <= '0';
                    servo_500_pos <= "00";
                    servo_1000_pos <= "00";
                    used_500_count <= 0;
                    used_1000_count <= 0;
                    total_used_500 <= 0;
                    total_used_1000 <= 0;
                    
                    if start_dispense = '1' and change_amount > 0 then
                        state <= CHECK_CHANGE;
                    end if;
                
                -- ==================== CALCULAR CAMBIO ====================
                when CHECK_CHANGE =>
                    dispensing <= '1';
                    
                    -- Algoritmo de cambio optimizado
                    if change_amount >= 1000 then
                        coins_1000_to_dispense <= change_amount / 1000;
                        coins_500_to_dispense <= (change_amount mod 1000) / 500;
                    else
                        coins_1000_to_dispense <= 0;
                        coins_500_to_dispense <= change_amount / 500;
                    end if;
                    
                    -- Limitar máximo a 3 monedas de cada tipo
                    if coins_1000_to_dispense > 3 then
                        coins_1000_to_dispense <= 3;
                    end if;
                    if coins_500_to_dispense > 3 then
                        coins_500_to_dispense <= 3;
                    end if;
                    
                    state <= DISPENSE_1000;
                
                -- ==================== DISPENSAR MONEDA 1000 ====================
                when DISPENSE_1000 =>
                    if coins_1000_to_dispense > 0 and coin_1000_avail > 0 then
                        servo_1000_pos <= "01";  -- Abrir servo
                        delay_counter <= DELAY_TICKS;
                        coins_1000_to_dispense <= coins_1000_to_dispense - 1;
                        total_used_1000 <= total_used_1000 + 1;
                        used_1000 <= '1';  -- Señal de actualización
                        state <= WAIT_1000;
                    else
                        -- Pasar a monedas de 500
                        state <= DISPENSE_500;
                    end if;
                
                -- ==================== ESPERAR DESPUÉS DE 1000 ====================
                when WAIT_1000 =>
                    if delay_counter > 0 then
                        delay_counter <= delay_counter - 1;
                        if delay_counter > 1 then
                            servo_1000_pos <= "01";  -- Mantener abierto
                        else
                            servo_1000_pos <= "00";  -- Cerrar
                        end if;
                    else
                        servo_1000_pos <= "00";
                        
                        if coins_1000_to_dispense > 0 then
                            state <= DISPENSE_1000;  -- Dispensar otra
                        else
                            state <= DISPENSE_500;  -- Pasar a 500
                        end if;
                    end if;
                
                -- ==================== DISPENSAR MONEDA 500 ====================
                when DISPENSE_500 =>
                    if coins_500_to_dispense > 0 and coin_500_avail > 0 then
                        servo_500_pos <= "01";  -- Abrir servo
                        delay_counter <= DELAY_TICKS;
                        coins_500_to_dispense <= coins_500_to_dispense - 1;
                        total_used_500 <= total_used_500 + 1;
                        used_500 <= '1';  -- Señal de actualización
                        state <= WAIT_500;
                    else
                        -- Terminar
                        state <= DONE;
                    end if;
                
                -- ==================== ESPERAR DESPUÉS DE 500 ====================
                when WAIT_500 =>
                    if delay_counter > 0 then
                        delay_counter <= delay_counter - 1;
                        if delay_counter > 1 then
                            servo_500_pos <= "01";  -- Mantener abierto
                        else
                            servo_500_pos <= "00";  -- Cerrar
                        end if;
                    else
                        servo_500_pos <= "00";
                        
                        if coins_500_to_dispense > 0 then
                            state <= DISPENSE_500;  -- Dispensar otra
                        else
                            state <= DONE;  -- Terminar
                        end if;
                    end if;
                
                -- ==================== FINALIZADO ====================
                when DONE =>
                    servo_500_pos <= "00";
                    servo_1000_pos <= "00";
                    done_dispense <= '1';
                    dispensing <= '0';
                    used_500_count <= total_used_500;
                    used_1000_count <= total_used_1000;
                    
                    if start_dispense = '0' then
                        state <= IDLE;
                    end if;
                
                -- ==================== ERROR ====================
                when ERROR_STATE =>
                    no_change <= '1';
                    servo_500_pos <= "00";
                    servo_1000_pos <= "00";
                    dispensing <= '0';
                    
                    if start_dispense = '0' then
                        no_change <= '0';
                        state <= IDLE;
                    end if;
                    
                when others =>
                    state <= IDLE;
                    
            end case;
        end if;
    end process;

end Behavioral;