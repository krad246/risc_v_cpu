--
-- vhdl architecture my_project1_lib.arbiter_tb.arbiter_tb_arch
--
-- created:
--          by - krad2.unknown (desktop-uoaipla)
--          at - 15:38:42 04/07/2019
--
-- using mentor graphics hdl designer(tm) 2015.1b (build 4)
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.rv32i.all;

entity arbiter_tb is
end entity arbiter_tb;

--
architecture arbiter_tb_arch of arbiter_tb is
  -- test case list
  file test_cases : text open read_mode is "arbiter_test_cases.txt";
  
  -- clock signal (not useful)
  signal clk : std_ulogic;
    
  -- inputs
  signal fetch_addr, mem_addr, data_in : std_ulogic_vector(31 downto 0);
  signal fetch_read, mem_read, write_in, delay_in : std_ulogic;
  
  -- outputs
  signal data_out, addr_out : std_ulogic_vector(31 downto 0);
  signal fetch_delay, mem_delay, write_out, read_out : std_ulogic;
  
  -- expected outputs
  signal e_data_out, e_addr_out : std_ulogic_vector(31 downto 0);
  signal e_fetch_delay, e_mem_delay, e_write_out, e_read_out : std_ulogic;
    
  -- test number
  signal test_no : natural := 1;
  
begin
  arbiter : entity work.arbiter(arbiter_arch)
    port map(fetch_addr => fetch_addr,
      mem_addr => mem_addr,
      data_in => data_in,
      fetch_read => fetch_read,
      mem_read => mem_read,
      write_in => write_in,
      delay_in => delay_in,
      data_out => data_out,
      addr_out => addr_out,
      fetch_delay => fetch_delay,
      mem_delay => mem_delay,
      write_out => write_out,
      read_out => read_out);
      
    stimuli : process
      -- file pointer
      variable fp : line;
      
      -- test case inputs
      variable tc_fetch_addr, tc_mem_addr, tc_data_in : std_ulogic_vector(31 downto 0);
      variable tc_fetch_read, tc_mem_read, tc_write_in, tc_delay_in : std_ulogic;
      
      -- test case outputs (expected)
      variable tc_data_out, tc_addr_out : std_ulogic_vector(31 downto 0);
      variable tc_fetch_delay, tc_mem_delay, tc_write_out, tc_read_out : std_ulogic;
      
    begin
          -- start fresh
        clk <= '0';
        wait for 40 ns;
        
        -- remove the useless line header
        readline(test_cases, fp);
        
        -- loop through the test case lines
        while not endfile(test_cases) loop
            -- read the whole line
            readline(test_cases, fp);
            
            hread(fp, tc_fetch_addr);
            fetch_addr <= tc_fetch_addr;
            
            hread(fp, tc_mem_addr);
            mem_addr <= tc_mem_addr;
            
            hread(fp, tc_data_in);
            data_in <= tc_data_in;
            
            read(fp, tc_fetch_read);
            fetch_read <= tc_fetch_read;
            
            read(fp, tc_mem_read);
            mem_read <= tc_mem_read;
            
            read(fp, tc_write_in);
            write_in <= tc_write_in;
            
            read(fp, tc_delay_in);
            delay_in <= tc_delay_in;
            
            -- set expected outputs
            hread(fp, tc_data_out);
            e_data_out <= tc_data_out;
            
            hread(fp, tc_addr_out);
            e_addr_out <= tc_addr_out;
            
            read(fp, tc_fetch_delay);
            e_fetch_delay <= tc_fetch_delay;
            
            read(fp, tc_mem_delay);
            e_mem_delay <= tc_mem_delay;
            
            read(fp, tc_write_out);
            e_write_out <= tc_write_out;
            
            read(fp, tc_read_out);
            e_read_out <= tc_read_out;
            
            -- new cycle
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
        assert e_addr_out = addr_out
          report "addr wrong" severity warning;
        assert e_data_out = data_out 
          report "data wrong" severity warning;
        assert e_fetch_delay = fetch_delay
          report "fetch delay wrong" severity warning;
        assert e_mem_delay = mem_delay
          report "mem delay wrong" severity warning;
        assert e_write_out = write_out
          report "write_out wrong" severity warning;
        assert e_read_out = read_out
          report "read_out wrong" severity warning;
      end if;
    end process;
end architecture arbiter_tb_arch;