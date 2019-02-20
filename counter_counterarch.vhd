--
-- VHDL Architecture my_project1_lib.counter.counterarch
--
-- Created:
--          by - krad2.UNKNOWN (DESKTOP-UOAIPLA)
--          at - 17:23:55 01/28/2019
--
-- using Mentor Graphics HDL Designer(TM) 2015.1b (Build 4)
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity counter is 
  generic (counter_width : natural range 1 to 64 := 8);
  port (
    counter_in : in std_ulogic_vector(counter_width - 1 downto 0);
    counter_step : in std_ulogic_vector(counter_width - 1 downto 0);
    counter_out : out std_ulogic_vector(counter_width - 1 downto 0);
    counter_clk, counter_en, counter_rst : in std_ulogic
  );
end entity counter;

--
architecture var_counter_desc of counter is
  signal reg_load : std_ulogic_vector(counter_width - 1 downto 0);
  signal reg_state : std_ulogic_vector(counter_width - 1 downto 0);
  signal adder_out : std_ulogic_vector(counter_width - 1 downto 0);
begin
  counter_reg : entity work.reg(pos_clk_desc)
    generic map(reg_width => counter_width)
    port map(reg_clk => counter_clk, reg_rst => '0', reg_en => counter_en or counter_rst, reg_out => reg_state, reg_in => reg_load);
      
  selector : entity work.mux_2x1(mux_2x1_desc)
    generic map(mux_width => counter_width)
    port map(mux_sel => counter_rst, mux_in_0 => adder_out, mux_in_1 => counter_in, mux_out => reg_load);
  
  adder : entity work.incrementer(var_incrementer_desc)
    generic map(incrementer_width => counter_width)
    port map(incrementer_in => reg_state, incrementer_enable => counter_step, incrementer_out => adder_out);
  
  counter_out <= reg_state;
end architecture var_counter_desc;

