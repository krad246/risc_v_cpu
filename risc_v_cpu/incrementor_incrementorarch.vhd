--
-- VHDL Architecture my_project1_lib.incrementor.incrementorarch
--
-- Created:
--          by - krad2.UNKNOWN (DESKTOP-UOAIPLA)
--          at - 16:51:39 01/28/2019
--
-- using Mentor Graphics HDL Designer(TM) 2015.1b (Build 4)
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity incrementer is
  generic (incrementer_width : natural range 1 to 64 := 8);
  port (
    incrementer_in : in std_ulogic_vector(incrementer_width - 1 downto 0);
    incrementer_out : out std_ulogic_vector(incrementer_width - 1 downto 0);
    incrementer_enable : in std_ulogic_vector(incrementer_width - 1 downto 0)
  );
end entity incrementer;

--
architecture var_incrementer_desc of incrementer is
begin
  process (incrementer_in, incrementer_enable)
    variable sum : unsigned(incrementer_width - 1 downto 0);
    
  begin
    sum := unsigned(incrementer_in) + unsigned(incrementer_enable);
    incrementer_out <= std_ulogic_vector(sum);
  end process; 
end architecture var_incrementer_desc;
