library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity memory_system is
    Port (
        address     : in  std_logic_vector(7 downto 0);
        data_in     : in  std_logic_vector(7 downto 0);
        write_enable: in  std_logic;
        clock       : in  std_logic;
        reset       : in  std_logic;

        port_in_00  : in  std_logic_vector(7 downto 0);
        port_in_01  : in  std_logic_vector(7 downto 0);

        port_out_00 : out std_logic_vector(7 downto 0);
        port_out_01 : out std_logic_vector(7 downto 0);

        data_out    : out std_logic_vector(7 downto 0)
    );
end memory_system;

architecture structural of memory_system is

    signal rom_output_data : std_logic_vector(7 downto 0);
    signal ram_output_data : std_logic_vector(7 downto 0);
    
    component rom_128x8_sync is
        port (
            clock      : in  std_logic;
            address    : in  std_logic_vector(7 downto 0);
            data_out   : out std_logic_vector(7 downto 0)
        );
    end component;
    
    component ram_96x8_sync is
        port (
            clock      : in  std_logic;
            write_enable: in  std_logic;
            address    : in  std_logic_vector(7 downto 0);
            data_in    : in  std_logic_vector(7 downto 0);
            data_out   : out std_logic_vector(7 downto 0)
        );
    end component;
    
    component output_ports_controller is
        Port (
            clock       : in  STD_LOGIC;
            reset       : in  STD_LOGIC;                 
            write_enable: in  STD_LOGIC;
            address     : in  STD_LOGIC_VECTOR(7 downto 0);
            data_in     : in  STD_LOGIC_VECTOR(7 downto 0);
            port_out_00 : out STD_LOGIC_VECTOR(7 downto 0);
            port_out_01 : out STD_LOGIC_VECTOR(7 downto 0)
        );
    end component;
    
    component memory_address_decoder is
        Port (
            address      : in  STD_LOGIC_vector(7 downto 0);
            rom_data_out : in  STD_LOGIC_vector(7 downto 0);
            ram_data_out : in  STD_LOGIC_vector(7 downto 0);
            port_in_00   : in  STD_LOGIC_vector(7 downto 0);
            port_in_01   : in  STD_LOGIC_vector(7 downto 0);
            data_out     : out STD_LOGIC_vector(7 downto 0)
        );
    end component;
    
begin

    ROM_UNIT : rom_128x8_sync
        port map (
            address    => address,  
            clock      => clock,
            data_out   => rom_output_data
        );

    RAM_UNIT : ram_96x8_sync
        port map (
            clock         => clock,
            write_enable  => write_enable,
            address       => address,
            data_in       => data_in,
            data_out      => ram_output_data
        );

    OUTPUT_CONTROLLER : output_ports_controller
        port map(
            clock         => clock,
            reset         => reset,
            write_enable  => write_enable,      
            address       => address,
            data_in       => data_in,
            port_out_00   => port_out_00,
            port_out_01   => port_out_01
        );

    ADDRESS_DECODER : memory_address_decoder
        port map(
            address       => address,
            rom_data_out  => rom_output_data,
            ram_data_out  => ram_output_data,
            port_in_00    => port_in_00,
            port_in_01    => port_in_01,
            data_out      => data_out
        );

end structural;