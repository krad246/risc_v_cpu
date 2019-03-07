--
-- VHDL Architecture my_project1_lib.reg.regarch
--
-- Created:
--          by - krad2.UNKNOWN (DESKTOP-UOAIPLA)
--          at - 17:06:00 01/28/2019
--
-- using Mentor Graphics HDL Designer(TM) 2015.1b (Build 4)
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity reg is
  generic (reg_width : natural range 1 to 64 := 8);
  port (
    reg_in : in std_ulogic_vector(reg_width - 1 downto 0);
    reg_out : out std_ulogic_vector(reg_width - 1 downto 0) := (others => '0');
    reg_clk, reg_en, reg_rst : in std_ulogic
  );
end entity reg;

--
architecture pos_clk_desc of reg is 
begin
  process (reg_in, reg_clk, reg_en, reg_rst)
  begin
    if (reg_rst = '1') then
      reg_out <= (others => '0');
    else
      if (rising_edge(reg_clk) and reg_en = '1') then
        reg_out <= reg_in;
      end if;
    end if;
  end process;
end architecture pos_clk_desc;