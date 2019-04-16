--
-- vhdl architecture my_project1_lib.regtracker_tb.regtracker_tb
--
-- created:
--          by - krad2.unknown (desktop-uoaipla)
--          at - 13:42:30 04/12/2019
--
-- using mentor graphics hdl designer(tm) 2015.1b (build 4)
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity regtracker_tb is
end entity regtracker_tb;

--
architecture regtracker_tb_arch of regtracker_tb is
    file test_cases : text open read_mode is "regtracker_test_cases.txt";
    
    -- inputs
    signal rfra_a, rfra_b, rfwa_decd, rfwa_wb : std_ulogic_vector(4 downto 0);
    signal reserve, read_a, read_b, free, clock : std_ulogic;
 
    
    -- outpus
    signal stall : std_ulogic;
      
    -- expected outputs
    signal estall : std_ulogic;
    
begin
    regtracker : entity work.regtracker(regtracker_arch)
    port map(rfra_a => rfra_a, 
      rfra_b => rfra_b,
      rfwa_decd => rfwa_decd,
      rfwa_wb => rfwa_wb,
      reserve => reserve,
      read_a => read_a,
      read_b => read_b,
      free => free,
      clock => clock,
      stall => stall);
      
    stimuli : process
      variable fp : line;
      variable trfra_a, trfra_b, trfwa_decd, trfwa_wb : std_ulogic_vector(4 downto 0);
      variable treserve, tread_a, tread_b, tfree : std_ulogic;
      variable tstall : std_ulogic;
      
    begin
        clock <= '0';
        wait for 40 ns;
        
        -- remove the useless line header
        readline(test_cases, fp);
        
        -- loop through the test case lines
        while not endfile(test_cases) loop
            -- read the whole line
            readline(test_cases, fp);

            hread(fp, trfra_a);
            rfra_a <= trfra_a;

            hread(fp, trfra_b);
            rfra_b <= trfra_b;
            
            hread(fp, trfwa_decd);
            rfwa_decd <= trfwa_decd;  

            hread(fp, trfwa_wb);
            rfwa_wb <= trfwa_wb;

            read(fp, treserve);
            reserve <= treserve;
            
            read(fp, tread_a);
            read_a <= tread_a;
            
            read(fp, tread_b);
            read_b <= tread_b;
            
            read(fp, tfree);
            free <= tfree;
            
            read(fp, tstall);
            estall <= tstall;
            
            
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
        assert estall = stall
          report "stall wrong" severity warning;
      end if;
    end process;
  
end architecture regtracker_tb_arch;


