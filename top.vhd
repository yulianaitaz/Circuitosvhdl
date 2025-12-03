library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top_system is
    Port (
        address_in   : in  std_logic_vector(7 downto 0);
        data_in      : in  std_logic_vector(7 downto 0);
        write_enable : in  std_logic;
        sys_clock    : in  std_logic;
        sys_reset    : in  std_logic; 
        switch_00    : in  std_logic;
        switch_01    : in  std_logic;
        
        led_00       : out std_logic;
        led_01       : out std_logic;
        display_1    : out std_logic_vector(6 downto 0);
        display_2    : out std_logic_vector(6 downto 0);
        display_3    : out std_logic_vector(6 downto 0);
        display_4    : out std_logic_vector(6 downto 0)
    );
end top_system;


architecture structural of top_system is
    signal internal_data_out : std_logic_vector(7 downto 0);
    signal port_input_00     : std_logic_vector(7 downto 0);
    signal port_input_01     : std_logic_vector(7 downto 0);

begin
    port_input_00 <= (7 downto 1 => '0') & switch_00;
    port_input_01 <= (7 downto 1 => '0') & switch_01;

    MAIN_MEMORY : entity work.memory_system
        port map(
            clock         => sys_clock,
            reset         => sys_reset,
            write_enable  => write_enable,
            address       => address_in,
            data_in       => data_in,
            data_out      => internal_data_out,
            port_in_00    => port_input_00,
            port_in_01    => port_input_01,
            port_out_00   => open,
            port_out_01   => open
        );
    
    led_00 <= '1' when 
                (address_in = x"E0" and write_enable = '1' and data_in /= x"00")
                else '0';

    led_01 <= '1' when 
                (address_in = x"E1" and write_enable = '1' and data_in /= x"00")
                else '0';
    
    DISPLAY_UNIT_1 : entity work.seven_segment_decoder port map(
        hex_input => address_in(7 downto 4),
        seg_output => display_1
    );

    DISPLAY_UNIT_2 : entity work.seven_segment_decoder port map(
        hex_input => address_in(3 downto 0),
        seg_output => display_2
    );

    DISPLAY_UNIT_3 : entity work.seven_segment_decoder port map(
        hex_input => internal_data_out(7 downto 4),
        seg_output => display_3
    );

    DISPLAY_UNIT_4 : entity work.seven_segment_decoder port map(
        hex_input => internal_data_out(3 downto 0),
        seg_output => display_4
    );

end structural;