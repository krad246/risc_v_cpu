--
-- VHDL Architecture my_project1_lib.instruction_fetch_tb.instruction_fetch_tb_arch
--
-- Created:
--          by - krad2.UNKNOWN (DESKTOP-UOAIPLA)
--          at - 14:01:56 02/06/2019
--
-- using Mentor Graphics HDL Designer(TM) 2015.1b (Build 4)
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity instruction_fetch_tb is
end entity instruction_fetch_tb;

--
architecture instruction_fetch_tb_arch of instruction_fetch_tb is
  file test_cases : text open read_mode is "if_test_cases.txt";
  
  signal jmp_addr, mem_data : std_ulogic_vector(31 downto 0);
  signal clk, jmp, rst, delay : std_ulogic;
  
  signal expected_addr, expected_inst : std_ulogic_vector(31 downto 0);
  signal expected_read : std_ulogic;
  
  signal true_addr, true_inst : std_ulogic_vector(31 downto 0);
  signal true_read : std_ulogic;
    
  signal test_no : natural := 1;
  
begin
  inst_fetch : entity work.instruction_fetch(if_arch)
    port map(if_jmp_addr => jmp_addr,
      if_mem_data => mem_data,
      if_clk => clk,
      if_jmp_flag => jmp,
      if_rst => rst,
      if_delay_flag => delay,
      if_addr_out => true_addr,
      if_instruction => true_inst,
      if_read_out => true_read);
      
  stimuli : process
    variable fp : line;
    
    variable tc_jmp_addr, tc_mem_data : std_ulogic_vector(31 downto 0);
    variable tc_jmp, tc_rst, tc_delay : std_ulogic;
    
    variable tc_addr_out, tc_inst_out : std_ulogic_vector(31 downto 0);
    variable tc_read : std_ulogic;
    
  begin
    clk <= '0';
    wait for 40 ns;
    readline(test_cases, fp);
   
    while not endfile(test_cases) loop
      readline(test_cases, fp);
      
      hread(fp, tc_jmp_addr);
      jmp_addr <= tc_jmp_addr;
      
      hread(fp, tc_mem_data);
      mem_data <= tc_mem_data;
      
      read(fp, tc_jmp);
      jmp <= tc_jmp;
      
      read(fp, tc_rst);
      rst <= tc_rst;
      
      read(fp, tc_delay);
      delay <= tc_delay;
      
      hread(fp, tc_addr_out);
      expected_addr <= tc_addr_out;
      
      hread(fp, tc_inst_out);
      expected_inst <= tc_inst_out;
      
      read(fp, tc_read);
      expected_read <= tc_read;
      
      wait for 10 ns;
      clk <= '1';
      
      wait for 50 ns;
      clk <= '0';
      wait for 40 ns;
    end loop;
  end process;
  
  checker : process(clk)
  begin
    if (falling_edge(clk)) then
      assert true_addr = expected_addr
        report "error: incorrect output for test case " & to_string(test_no) & lf
        & "(line no: " & to_string(test_no + 1) & ")" & lf
        & "address output: " & to_string(true_addr) & lf
        & "expected: " & to_string(expected_addr) 
        severity warning;
        
      assert true_inst = expected_inst
        report "error: incorrect output for test case " & to_string(test_no) & lf
        & "(line no: " & to_string(test_no + 1) & ")" & lf
        & "instruction output: " & to_string(true_inst) & lf
        & "expected: " & to_string(expected_inst)
        severity warning;
        
      assert true_read = expected_read
        report "error: incorrect output for test case " & to_string(test_no) & lf
        & "(line no: " & to_string(test_no + 1) & ")" & lf
        & "read output: " & to_string(true_read) & lf
        & "expected: " & to_string(expected_read)
        severity warning;
        
      test_no <= test_no + 1;
    end if;
  end process;
end architecture instruction_fetch_tb_arch;

architecture instruction_fetch_tb_arch_behavioral of instruction_fetch_tb is
  file test_cases : text open read_mode is "if_test_cases.txt";
  
  signal jmp_addr, mem_data : std_ulogic_vector(31 downto 0);
  signal clk, jmp, rst, delay : std_ulogic;
  
  signal expected_addr, expected_inst : std_ulogic_vector(31 downto 0);
  signal expected_read : std_ulogic;
  
  signal true_addr, true_inst : std_ulogic_vector(31 downto 0);
  signal true_read : std_ulogic;
    
  signal test_no : natural := 1;
  
begin
  inst_fetch : entity work.instruction_fetch(if_arch_behavioral)
    port map(if_jmp_addr => jmp_addr,
      if_mem_data => mem_data,
      if_clk => clk,
      if_jmp_flag => jmp,
      if_rst => rst,
      if_delay_flag => delay,
      if_addr_out => true_addr,
      if_instruction => true_inst,
      if_read_out => true_read);
      
  stimuli : process
    variable fp : line;
    
    variable tc_jmp_addr, tc_mem_data : std_ulogic_vector(31 downto 0);
    variable tc_jmp, tc_rst, tc_delay : std_ulogic;
    
    variable tc_addr_out, tc_inst_out : std_ulogic_vector(31 downto 0);
    variable tc_read : std_ulogic;
    
  begin
    clk <= '0';
    wait for 40 ns;
    readline(test_cases, fp);
   
    while not endfile(test_cases) loop
      readline(test_cases, fp);
      
      hread(fp, tc_jmp_addr);
      jmp_addr <= tc_jmp_addr;
      
      hread(fp, tc_mem_data);
      mem_data <= tc_mem_data;
      
      read(fp, tc_jmp);
      jmp <= tc_jmp;
      
      read(fp, tc_rst);
      rst <= tc_rst;
      
      read(fp, tc_delay);
      delay <= tc_delay;
      
      hread(fp, tc_addr_out);
      expected_addr <= tc_addr_out;
      
      hread(fp, tc_inst_out);
      expected_inst <= tc_inst_out;
      
      read(fp, tc_read);
      expected_read <= tc_read;
      
      wait for 10 ns;
      clk <= '1';
      
      wait for 50 ns;
      clk <= '0';
      wait for 40 ns;
    end loop;
  end process;
  
  checker : process(clk)
  begin
    if (falling_edge(clk)) then
      assert true_addr = expected_addr
        report "error: incorrect output for test case " & to_string(test_no) & lf
        & "(line no: " & to_string(test_no + 1) & ")" & lf
        & "address output: " & to_string(true_addr) & lf
        & "expected: " & to_string(expected_addr) 
        severity warning;
        
      assert true_inst = expected_inst
        report "error: incorrect output for test case " & to_string(test_no) & lf
        & "(line no: " & to_string(test_no + 1) & ")" & lf
        & "instruction output: " & to_string(true_inst) & lf
        & "expected: " & to_string(expected_inst)
        severity warning;
        
      assert true_read = expected_read
        report "error: incorrect output for test case " & to_string(test_no) & lf
        & "(line no: " & to_string(test_no + 1) & ")" & lf
        & "read output: " & to_string(true_read) & lf
        & "expected: " & to_string(expected_read)
        severity warning;
        
      test_no <= test_no + 1;
    end if;
  end process;
end architecture instruction_fetch_tb_arch_behavioral;