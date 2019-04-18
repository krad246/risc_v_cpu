--
-- VHDL Architecture my_project1_lib.instruction_fetch.if_arch
--
-- Created:
--          by - krad2.UNKNOWN (DESKTOP-UOAIPLA)
--          at - 14:52:31 02/04/2019
--
-- using Mentor Graphics HDL Designer(TM) 2015.1b (Build 4)
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity instruction_fetch is
  port(if_jmp_addr, if_mem_data : in std_ulogic_vector(31 downto 0);
    if_addr_out, if_instruction : out std_ulogic_vector(31 downto 0);
    if_clk, if_jmp_flag, if_rst, if_delay_flag : in std_ulogic;
    if_read_out : out std_ulogic);
end entity instruction_fetch;
--
architecture if_arch of instruction_fetch is
  signal pc_reset_val : std_ulogic_vector(31 downto 0);
  signal pc_address : std_ulogic_vector(31 downto 0);
  
  constant nullptr : std_ulogic_vector(31 downto 0) := x"00000000";
  constant nop : std_ulogic_vector(31 downto 0) := x"00000013";
  
begin
  program_counter : entity work.counter(var_counter_desc)
    generic map(counter_width => 32)
    port map(counter_clk => if_clk, 
      counter_rst => if_rst or if_jmp_flag, 
      counter_en => not (if_delay_flag or if_jmp_flag or if_rst),
      counter_step => (2 => '1', others => '0'),
      counter_in => pc_reset_val,
      counter_out => pc_address);
  
  instruction_mux : entity work.mux_2x1(mux_2x1_desc)
    generic map(mux_width => 32)
    port map(mux_in_0 => if_mem_data, 
      mux_in_1 => nop, 
      mux_sel => if_delay_flag or if_jmp_flag or if_rst, 
      mux_out => if_instruction);
  
  pc_reset_mux : entity work.mux_2x1(mux_2x1_desc)
    generic map(mux_width => 32)
    port map(mux_in_0 => if_jmp_addr,
      mux_in_1 => nullptr,
      mux_sel => if_rst,
      mux_out => pc_reset_val);
  
  if_addr_out <= pc_address;
  if_read_out <= if_rst or not (if_jmp_flag and if_delay_flag);
end architecture if_arch;

architecture if_arch_behavioral of instruction_fetch is
  signal pc_reset_val : std_ulogic_vector(31 downto 0);
  
  constant nullptr : std_ulogic_vector(31 downto 0) := x"00000000";
  constant nop : std_ulogic_vector(31 downto 0) := x"00000013";
  
begin
  pc_reset_mux : process(if_rst, if_jmp_addr)
  begin
    if (if_rst) then
      pc_reset_val <= nullptr;
    else
      pc_reset_val <= if_jmp_addr;
    end if;
  end process;
  
  program_counter : process(if_clk, if_rst, if_jmp_flag, if_delay_flag, pc_reset_val)
    variable pc_address : unsigned(31 downto 0) := (others => '0');
    
  begin
    if (rising_edge(if_clk)) then
      if (if_rst) then
        pc_address := unsigned(nullptr);
       elsif (if_jmp_flag) then
        pc_address := unsigned(if_jmp_addr);
      elsif (not if_delay_flag) then
        pc_address := unsigned(pc_address) + 4;
      end if;
    end if;
    
    if_addr_out <= std_ulogic_vector(pc_address);
    if_read_out <= if_rst or not (if_jmp_flag and if_delay_flag);
  end process;
  
  instruction_mux : process(if_delay_flag, if_rst, if_jmp_flag, if_mem_data)
  begin
    if (if_delay_flag or if_rst or if_jmp_flag) then
      if_instruction <= nop;
    else 
      if_instruction <= if_mem_data;
    end if;
  end process;
end architecture if_arch_behavioral;


