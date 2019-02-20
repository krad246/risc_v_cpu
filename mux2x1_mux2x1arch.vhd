--
-- VHDL Architecture my_project1_lib.mux2x1.mux2x1arch
--
-- Created:
--          by - krad2.UNKNOWN (DESKTOP-UOAIPLA)
--          at - 12:21:01 01/28/2019
--
-- using Mentor Graphics HDL Designer(TM) 2015.1b (Build 4)
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity mux_2x1 is
  generic (mux_width : natural range 1 to 64 := 8);
  port (
    mux_in_0, mux_in_1 : in std_ulogic_vector(mux_width - 1 downto 0);
    mux_out : out std_ulogic_vector(mux_width - 1 downto 0);
    mux_sel : in std_ulogic
  );
end entity mux_2x1;

--
architecture mux_2x1_desc of mux_2x1 is
begin
  process(mux_in_0, mux_in_1, mux_sel)
  begin
    if (mux_sel = '0') then
      mux_out <= mux_in_0;
    elsif (mux_sel = '1') then
      mux_out <= mux_in_1;
    else
      mux_out <= (others => 'X');
    end if;
  end process;
end architecture mux_2x1_desc;
