--
-- VHDL Architecture my_project1_lib.mux3x1.mux3x1arch
--
-- Created:
--          by - krad2.UNKNOWN (DESKTOP-UOAIPLA)
--          at - 12:38:59 01/28/2019
--
-- using Mentor Graphics HDL Designer(TM) 2015.1b (Build 4)
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

ENTITY mux3x1 IS
  generic(width : natural range 1 to 64 := 8);
  port(in0, in1, in2 : in std_ulogic_vector(width - 1 downto 0);
        dataout : out std_ulogic_vector(width - 1 downto 0);
        selector : in std_ulogic_vector(1 downto 0)
  );       
END ENTITY mux3x1;

--
ARCHITECTURE mux3x1arch OF mux3x1 IS
BEGIN
  process(in0, in1, in2, selector)
  begin
    case selector is
    when "00" => dataout <= in0;
    when "01" => dataout <= in1;
    when "10" => dataout <= in2;
    when others => dataout <= (others => 'X');
    end case;
  end process;
END ARCHITECTURE mux3x1arch;

