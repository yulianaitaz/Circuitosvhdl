library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity unidad_aritmetica_logica is
   port(
      -- Entradas
      entrada_A     : in  std_logic_vector(7 downto 0);
      entrada_B     : in  std_logic_vector(7 downto 0);
      selector      : in  std_logic; -- '0' suma, '1' resta
      
      -- Salidas
      resultado     : out std_logic_vector(7 downto 0);
      acarreo       : out std_logic;
      desbordamiento: out std_logic;
      negativo      : out std_logic;
      cero          : out std_logic;
      
      -- Displays 7-segmentos
      display_0     : out std_logic_vector(6 downto 0);  -- Resultado nibble bajo
      display_1     : out std_logic_vector(6 downto 0);  -- Resultado nibble alto
      display_2     : out std_logic_vector(6 downto 0);  -- B nibble bajo
      display_3     : out std_logic_vector(6 downto 0)   -- B nibble alto
   );
end entity;

architecture comportamiento of unidad_aritmetica_logica is

   signal resultado_suma  : unsigned(8 downto 0);  -- 9 bits para capturar acarreo
   signal resultado_int   : std_logic_vector(7 downto 0);
   signal A_sin_signo     : unsigned(8 downto 0);  -- 9 bits
   signal B_sin_signo     : unsigned(8 downto 0);  -- 9 bits
   signal A_con_signo     : signed(7 downto 0);
   signal B_con_signo     : signed(7 downto 0);
   signal resultado_con_signo : signed(7 downto 0);

   -- Función decodificador hexadecimal a 7 segmentos (activo bajo)
   function decodificar_7segmentos(dato_hex : std_logic_vector(3 downto 0)) return std_logic_vector is
      variable segmentos : std_logic_vector(6 downto 0);
   begin
      case dato_hex is
         when "0000" => segmentos := "1000000"; -- 0
         when "0001" => segmentos := "1111001"; -- 1
         when "0010" => segmentos := "0100100"; -- 2
         when "0011" => segmentos := "0110000"; -- 3
         when "0100" => segmentos := "0011001"; -- 4
         when "0101" => segmentos := "0010010"; -- 5
         when "0110" => segmentos := "0000010"; -- 6
         when "0111" => segmentos := "1111000"; -- 7
         when "1000" => segmentos := "0000000"; -- 8
         when "1001" => segmentos := "0010000"; -- 9
         when "1010" => segmentos := "0001000"; -- A
         when "1011" => segmentos := "0000011"; -- b
         when "1100" => segmentos := "1000110"; -- C
         when "1101" => segmentos := "0100001"; -- d
         when "1110" => segmentos := "0000110"; -- E
         when "1111" => segmentos := "0001110"; -- F
         when others => segmentos := "1111111"; -- blank
      end case;
      return segmentos;
   end function;

begin

   -- Extender A y B a 9 bits (sin signo) para evitar errores de tamaño
   A_sin_signo <= "0" & unsigned(entrada_A);
   B_sin_signo <= "0" & unsigned(entrada_B);

   -- Suma o resta según selector
   process(A_sin_signo, B_sin_signo, selector)
   begin
       if selector = '0' then
           -- Suma
           resultado_suma <= A_sin_signo + B_sin_signo;
       else
           -- Resta (A - B)
           resultado_suma <= A_sin_signo - B_sin_signo;
       end if;
   end process;

   -- Resultado de 8 bits
   resultado_int <= std_logic_vector(resultado_suma(7 downto 0));
   resultado <= resultado_int;

   -- Bit de acarreo (bit 8 del resultado)
   acarreo <= resultado_suma(8);

   -- Cálculo de desbordamiento usando aritmética con signo
   A_con_signo <= signed(entrada_A);
   B_con_signo <= signed(entrada_B);
   resultado_con_signo <= signed(resultado_int);

   -- Desbordamiento ocurre cuando:
   -- Suma: operandos del mismo signo dan resultado de signo opuesto
   -- Resta: operandos de signo opuesto dan resultado de signo opuesto a A
   process(selector, A_con_signo, B_con_signo, resultado_con_signo)
   begin
       if selector = '0' then
           -- Desbordamiento en suma
           if (A_con_signo(7) = B_con_signo(7)) and (resultado_con_signo(7) /= A_con_signo(7)) then
               desbordamiento <= '1';
           else
               desbordamiento <= '0';
           end if;
       else
           -- Desbordamiento en resta
           if (A_con_signo(7) /= B_con_signo(7)) and (resultado_con_signo(7) /= A_con_signo(7)) then
               desbordamiento <= '1';
           else
               desbordamiento <= '0';
           end if;
       end if;
   end process;

   -- Bandera NEGATIVO: se activa cuando el bit más significativo es 1
   negativo <= resultado_int(7);

   -- Bandera CERO: se activa cuando el resultado es exactamente cero
   cero <= '1' when resultado_int = "00000000" else '0';

   -- Displays 7-segmentos con la configuración corregida
   -- Muestra B en display_1:display_0 y Resultado en display_3:display_2
   display_0 <= decodificar_7segmentos(entrada_B(3 downto 0));
   display_1 <= decodificar_7segmentos(entrada_B(7 downto 4));
   display_2 <= decodificar_7segmentos(resultado_int(3 downto 0));
   display_3 <= decodificar_7segmentos(resultado_int(7 downto 4));

end architecture;