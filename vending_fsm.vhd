library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity vending_fsm is
    Port (
        clk           : in  STD_LOGIC;
        reset         : in  STD_LOGIC;
        total_money   : in  STD_LOGIC_VECTOR(7 downto 0);
        product_price : in  STD_LOGIC_VECTOR(7 downto 0);
        valid_buy     : in  STD_LOGIC;
        no_stock      : in  STD_LOGIC;
        change        : in  STD_LOGIC_VECTOR(7 downto 0);

        -- Display: opcional (no se usa en esta versión porque ya lo manejas en top)
        display_out   : out STD_LOGIC_VECTOR(7 downto 0);

        -- Entrada: señal del timer de entrega
        delivering    : in  STD_LOGIC;

        -- Salidas
        door          : out STD_LOGIC
    );
end vending_fsm;

architecture Behavioral of vending_fsm is
    type state_type is (IDLE, CHECK, DISPENSE, DONE);
    signal state, next_state : state_type;

begin

    --------------------------------------------------------------------
    -- STATE REGISTER
    --------------------------------------------------------------------
    process(clk, reset)
    begin
        if reset = '1' then
            state <= IDLE;
        elsif rising_edge(clk) then
            state <= next_state;
        end if;
    end process;

    --------------------------------------------------------------------
    -- NEXT STATE LOGIC
    --------------------------------------------------------------------
    process(state, valid_buy, no_stock, delivering)
    begin
        next_state <= state;  -- default
        case state is

            when IDLE =>
                if valid_buy = '1' and no_stock = '0' then
                    next_state <= CHECK;
                end if;

            when CHECK =>
                if valid_buy = '1' and no_stock = '0' then
                    next_state <= DISPENSE;
                else
                    next_state <= IDLE;
                end if;

            when DISPENSE =>
                -- Nos quedamos aquí mientras 'delivering' esté activo (timer)
                if delivering = '0' then
                    next_state <= DONE;
                end if;

            when DONE =>
                -- Una vez terminada la entrega, volvemos a IDLE
                next_state <= IDLE;

        end case;
    end process;

    --------------------------------------------------------------------
    -- OUTPUT LOGIC
    --------------------------------------------------------------------
    process(state)
    begin
        case state is
            when IDLE =>
                door <= '0';             -- puerta cerrada
                display_out <= (others => '0');

            when CHECK =>
                door <= '0';             -- aún no abrimos puerta
                display_out <= total_money;

            when DISPENSE =>
                door <= '1';             -- abrimos puerta durante la entrega
                display_out <= change;   -- o podrías mostrar producto

            when DONE =>
                door <= '0';             -- cerramos puerta
                display_out <= (others => '0');
        end case;
    end process;

end Behavioral;

