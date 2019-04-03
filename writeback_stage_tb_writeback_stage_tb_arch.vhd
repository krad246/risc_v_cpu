--
-- vhdl architecture my_project1_lib.writeback_stage_tb.writeback_stage_tb_arch
--
-- created:
--          by - krad2.unknown (desktop-uoaipla)
--          at - 00:01:36 04/03/2019
--
-- using mentor graphics hdl designer(tm) 2015.1b (build 4)
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.rv32i.all;

entity writeback_stage_tb is
end entity writeback_stage_tb;

--
architecture writeback_stage_tb_arch of writeback_stage_tb is
-- open the file of test cases
    file test_cases : text open read_mode is "writeback_stage_test_cases.txt";
    
    -- clock signal (not useful)
    signal clk : std_ulogic;
    
    -- inputs to the execute stage
    signal data_in : std_ulogic_vector(31 downto 0);
    signal rd_in : std_ulogic_vector(4 downto 0);
    signal op_in : rv32i_op;
    
    -- outputs of the execute stage
    signal data_out : std_ulogic_vector(31 downto 0);
    signal rd_out : std_ulogic_vector(4 downto 0);
    signal write : std_ulogic;
  
    -- expected outputs
    signal e_data_out : std_ulogic_vector(31 downto 0);
    signal e_rd_out : std_ulogic_vector(4 downto 0);
    signal e_write : std_ulogic;
    
    -- test case number
    signal test_no : natural := 1;

begin
    writeback_stage : entity work.writeback_stage(writeback_stage_arch)
      port map(data_in => data_in,
        rd_in => rd_in,
        op_in => op_in,
        data_out => data_out,
        rd_out => rd_out,
        write => write,
        clock => clk);
  
    -- create a stimulus process that reads the test cases
    stimuli : process
        -- file pointer for line reads
        variable fp : line;
        
        -- test case string mnemonic for opcode
        variable opcode_mnem : func_name;
        variable tc_opcode : rv32i_op;
        
        -- test case inputs  
        variable tc_data_in : std_ulogic_vector(31 downto 0);
        variable tc_rd_in : std_ulogic_vector(4 downto 0);
        
        -- test case outputs
        variable tc_data_out : std_ulogic_vector(31 downto 0);
        variable tc_rd_out : std_ulogic_vector(4 downto 0);
        variable tc_write : std_ulogic;
    
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

            -- set inputs
            read(fp, opcode_mnem);
            tc_opcode := ftype(opcode_mnem);
            op_in <= tc_opcode;
            
            hread(fp, tc_data_in);
            data_in <= tc_data_in;
            
            hread(fp, tc_rd_in);
            rd_in <= tc_rd_in;
            
            -- set expected outputs          
            hread(fp, tc_data_out);
            e_data_out <= tc_data_out;
            
            hread(fp, tc_rd_out);
            e_rd_out <= tc_rd_out;
            
            read(fp, tc_write);
            e_write <= tc_write;
            
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
          assert e_data_out = data_out
            report "data out wrong" severity warning;   
          
          assert e_write = write
            report "write wrong" severity warning;
          
          assert e_rd_out = rd_out
            report "rd wrong" severity warning;
          
          test_no <= test_no + 1;
        end if;
    end process;
end architecture writeback_stage_tb_arch;

