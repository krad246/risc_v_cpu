--
-- vhdl architecture my_project1_lib.n2n_decoder.n2n_arch
--
-- created:
--          by - krad2.unknown (desktop-uoaipla)
--          at - 12:23:35 04/08/2019
--
-- using mentor graphics hdl designer(tm) 2015.1b (build 4)
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity n2n_decoder is
    generic(bits : natural);
    port(selector : in std_ulogic_vector(bits - 1 downto 0);
      addr_line : out std_ulogic_vector((2**bits) - 1 downto 0));
end entity n2n_decoder;

--
architecture n2n_arch of n2n_decoder is
begin
  one_hot : process(selector)
  begin
    addr_line <= (others => '0');
    addr_line(to_integer(unsigned(selector))) <= '1';
  end process;
end architecture n2n_arch;

