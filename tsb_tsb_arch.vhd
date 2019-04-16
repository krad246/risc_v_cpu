--
-- vhdl architecture my_project1_lib.tsb.tsb_arch
--
-- created:
--          by - krad2.unknown (desktop-uoaipla)
--          at - 13:03:39 04/08/2019
--
-- using mentor graphics hdl designer(tm) 2015.1b (build 4)
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity tsb is
  generic(width : natural);
  port(data_in : in std_ulogic_vector(width - 1 downto 0);
    enable : in std_ulogic;
    data_out : out std_ulogic_vector(width - 1 downto 0));
end entity tsb;

--
architecture tsb_arch of tsb is
begin
  tri_state_buffer : process(data_in, enable)
  begin
    if (enable) then
      data_out <= data_in;
    else
      data_out <= (others => 'Z');
    end if;
  end process;
end architecture tsb_arch;

