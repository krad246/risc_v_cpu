--
-- vhdl architecture my_project1_lib.arbiter.arbiter_arch
--
-- created:
--          by - krad2.unknown (desktop-uoaipla)
--          at - 15:20:17 04/07/2019
--
-- using mentor graphics hdl designer(tm) 2015.1b (build 4)
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.rv32i.all;

entity arbiter is
  port(fetch_addr, mem_addr, data_in_mem, data_in_ram : in std_ulogic_vector(31 downto 0);
    fetch_read, mem_read, write_in, delay_in : in std_ulogic;
    data_out_mem, data_out_ram, addr_out : out std_ulogic_vector(31 downto 0);
    fetch_delay, mem_delay, write_out, read_out : out std_ulogic);
end entity arbiter;

--
architecture arbiter_arch of arbiter is
begin
  arbiter : process(fetch_addr, mem_addr, fetch_read, mem_read, write_in, delay_in, data_in_mem, data_in_ram)
  begin
    if (mem_read or write_in) then
      addr_out <= mem_addr;
      fetch_delay <= '1';
      mem_delay <= delay_in;
      write_out <= write_in;
      read_out <= mem_read;
    else
      addr_out <= fetch_addr;
      fetch_delay <= delay_in;
      mem_delay <= delay_in;
      write_out <= '0';
      read_out <= fetch_read;
    end if;
    
  data_out_mem <= data_in_mem;
  data_out_ram <= data_in_ram;
  end process;
end architecture arbiter_arch;

