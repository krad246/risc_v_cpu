--
-- vhdl architecture my_project1_lib.op_reg.op_reg_arch
--
-- created:
--          by - krad2.unknown (desktop-uoaipla)
--          at - 12:43:26 03/28/2019
--
-- using mentor graphics hdl designer(tm) 2015.1b (build 4)
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use work.rv32i.all;

entity op_reg is
  port(reg_in : in rv32i_op;
    clock, en, rst : in std_ulogic;
    reg_out : out rv32i_op);
end entity op_reg;

architecture op_reg_arch of op_reg is
begin 
  process (reg_in, clock, en, rst)
  begin
    if (rst = '1') then
      reg_out <= bad;
    else
      if (rising_edge(clock) and en = '1') then
        reg_out <= reg_in;
      end if;
    end if;
  end process;
end architecture op_reg_arch;

