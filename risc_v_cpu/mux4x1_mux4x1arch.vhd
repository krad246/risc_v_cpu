--
-- VHDL Architecture my_project1_lib.mux4x1.mux4x1arch
--
-- Created:
--          by - krad2.UNKNOWN (DESKTOP-UOAIPLA)
--          at - 12:50:50 01/28/2019
--
-- using Mentor Graphics HDL Designer(TM) 2015.1b (Build 4)
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity mux_4x1 is
  generic(mux_width : natural range 1 to 64 := 8);
  port(mux_in_0, 
    mux_in_1, 
    mux_in_2, 
    mux_in_3 : in std_ulogic_vector(mux_width - 1 downto 0);
    mux_out : out std_ulogic_vector(mux_width - 1 downto 0);
    mux_sel : in std_ulogic_vector(1 downto 0));
end entity mux_4x1;
--

architecture mux_4x1_desc of mux_4x1 is
begin
  process(mux_in_0, mux_in_1, mux_in_2, mux_in_3, mux_sel)
  begin
      case mux_sel is
        when "00" => mux_out <= mux_in_0;
        when "01" => mux_out <= mux_in_1;
        when "10" => mux_out <= mux_in_2;
        when "11" => mux_out <= mux_in_3;
        when others => mux_out <= (others => 'X');
      end case;
  end process;
end architecture mux_4x1_desc;


