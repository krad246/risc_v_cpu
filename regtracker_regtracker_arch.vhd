--
-- vhdl architecture my_project1_lib.regtracker.regtracker_arch
--
-- created:
--          by - krad2.unknown (desktop-uoaipla)
--          at - 15:39:06 04/11/2019
--
-- using mentor graphics hdl designer(tm) 2015.1b (build 4)
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity regtracker is
  port(rfra_a, rfra_b, rfwa_decd, rfwa_wb : in std_ulogic_vector(4 downto 0);
    reserve, read_a, read_b, free, clock : in std_ulogic;
    stall : out std_ulogic;
    resvec : out std_ulogic_vector(31 downto 0));
end entity regtracker;

--
architecture regtracker_arch of regtracker is
  signal reserve_state : std_ulogic_vector(31 downto 0) := x"00000000";
  
begin
  update_tracker : process(clock, rfwa_decd, rfwa_wb, reserve, free)
  begin    
    if rising_edge(clock) then
      if reserve then
        reserve_state(to_integer(unsigned(rfwa_decd))) <= '1';
      end if;
      
      if free then
        reserve_state(to_integer(unsigned(rfwa_wb))) <= '0';
      end if; 
    end if;
  end process;
  
  check_stall : process(reserve_state, rfra_a, rfra_b, read_a, read_b, rfwa_decd, reserve)
    variable stall_count : natural := 0;
  begin
    stall <= '0';
    
    if reserve_state(to_integer(unsigned(rfra_a))) and read_a then
      stall <= '1';
    end if;
    
    if reserve_state(to_integer(unsigned(rfra_b))) and read_b  then
      stall <= '1';
    end if;
    
    if reserve_state(to_integer(unsigned(rfwa_decd))) and reserve then
      stall <= '1';
    end if;
  end process;
  
  resvec <= reserve_state;
end architecture regtracker_arch;

