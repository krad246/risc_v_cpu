--
-- vhdl architecture my_project1_lib.regfile_tb.regfile_tb_arch
--
-- created:
--          by - krad2.unknown (desktop-uoaipla)
--          at - 21:06:18 04/11/2019
--
-- using mentor graphics hdl designer(tm) 2015.1b (build 4)
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity regfile_tb is
end entity regfile_tb;

--
architecture regfile_tb_arch of regfile_tb is
    file test_cases : text open read_mode is "regfile_test_cases.txt";
    
    -- inputs
    signal data_in : std_ulogic_vector(31 downto 0);
    signal read_addr_1, read_addr_2 : std_ulogic_vector(4 downto 0);
    signal write_addr : std_ulogic_vector(4 downto 0);
    signal write : std_ulogic;
    signal clock : std_ulogic;
    
    -- outpus
    signal read_data_1, read_data_2 : std_ulogic_vector(31 downto 0);
      
    -- expected outputs
    signal exp_read_1, exp_read_2 : std_ulogic_vector(31 downto 0);
    
begin
    regfile : entity work.regfile(regfile_arch)
    port map(data_in => data_in, 
      read_addr_1 => read_addr_1,
      read_addr_2 => read_addr_2,
      write_addr => write_addr,
      write => write,
      clock => clock,
      read_data_1 => read_data_1,
      read_data_2 => read_data_2);
      
    stimuli : process
      variable fp : line;
      variable tcdata_in : std_ulogic_vector(31 downto 0);
      variable tcread_addr_1, tcread_addr_2 : std_ulogic_vector(4 downto 0);
      variable tcwrite_addr : std_ulogic_vector(4 downto 0);
      variable tcwrite : std_ulogic;
      variable tcread_data_1, tcread_data_2 : std_ulogic_vector(31 downto 0);
    begin
        clock <= '0';
        wait for 40 ns;
        
        -- remove the useless line header
        readline(test_cases, fp);
        
        -- loop through the test case lines
        while not endfile(test_cases) loop
            -- read the whole line
            readline(test_cases, fp);

            hread(fp, tcdata_in);
            data_in <= tcdata_in;

            hread(fp, tcread_addr_1);
            read_addr_1 <= tcread_addr_1;
            
            hread(fp, tcread_addr_2);
            read_addr_2 <= tcread_addr_2;  

            hread(fp, tcwrite_addr);
            write_addr <= tcwrite_addr;

            read(fp, tcwrite);
            write <= tcwrite;
            
            hread(fp, tcread_data_1);
            exp_read_1 <= tcread_data_1;
            
            hread(fp, tcread_data_2);
            exp_read_2 <= tcread_data_2;
            
            -- new cycle
            wait for 10 ns;
            clock <= '1';
      
            wait for 50 ns;
            clock <= '0';
            wait for 40 ns;
        end loop;
    end process;
    
    checker : process(clock)
    begin
      if falling_edge(clock) then
        assert exp_read_1 = read_data_1
          report "read1 wrong" severity warning;
        assert exp_read_2 = read_data_2
          report "read2 wrong" severity warning;
      end if;
    end process;
  
end architecture regfile_tb_arch;

