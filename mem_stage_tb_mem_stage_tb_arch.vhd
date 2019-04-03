--
-- VHDL Architecture my_project1_lib.decoder_tb.decoder_tb_arch
--
-- Created:
--          by - krad2.UNKNOWN (DESKTOP-UOAIPLA)
--          at - 11:41:44 02/20/2019
--
-- using Mentor Graphics HDL Designer(TM) 2015.1b (Build 4)
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.rv32i.all;

entity mem_stage_tb is
end entity mem_stage_tb;

--
architecture mem_stage_tb_arch of mem_stage_tb is
    -- open the file of test cases
    file test_cases : text open read_mode is "mem_stage_test_cases.txt";
    
    -- clock signal (not useful)
    signal clk : std_ulogic;
    
    -- inputs to the execute stage
    signal data_in, addr_in : std_ulogic_vector(31 downto 0);
    signal rd_in : std_ulogic_vector(4 downto 0);
    signal op_in : rv32i_op;
    signal read_data_in : std_ulogic_vector(31 downto 0);
    signal delay : std_ulogic;
    
    -- outputs of the execute stage
    signal addr_out, write_data_out, data_out : std_ulogic_vector(31 downto 0);
    signal m_type_out : std_ulogic_vector(1 downto 0);
    signal read_out, write_out, stall : std_ulogic;
    signal rd_out : std_ulogic_vector(4 downto 0);
    signal op_out : rv32i_op;
  
    -- expected outputs
    signal e_addr_out, e_write_data_out, e_data_out : std_ulogic_vector(31 downto 0);
    signal e_m_type_out : std_ulogic_vector(1 downto 0);
    signal e_read_out, e_write_out, e_stall : std_ulogic;
    signal e_rd_out : std_ulogic_vector(4 downto 0);
    signal e_op_out : rv32i_op;
    
    -- test case number
    signal test_no : natural := 1;

begin
    mem_stage : entity work.mem_stage(mem_stage_arch)
      port map(data_in => data_in, 
        addr_in => addr_in,
        rd_in => rd_in,
        op_in => op_in,
        addr_out => addr_out, 
        write_data => write_data_out,
        read_data => read_data_in,
        m_type => m_type_out,
        read => read_out, 
        write => write_out,
        delay => delay, 
        stall => stall,
        data_out => data_out,
        rd_out => rd_out,
        op_out => op_out,
        clock => clk);
  
    -- create a stimulus process that reads the test cases
    stimuli : process
        -- file pointer for line reads
        variable fp : line;
        
        -- test case string mnemonic for opcode
        variable opcode_mnem : func_name;
        variable tc_opcode : rv32i_op;
        
        -- test case inputs  
        variable tc_data_in, tc_addr_in : std_ulogic_vector(31 downto 0);
        variable tc_rd_in : std_ulogic_vector(4 downto 0);
        variable tc_read_data_in : std_ulogic_vector(31 downto 0);
        variable tc_delay : std_ulogic;
        
        -- test case outputs
        variable tc_addr_out, tc_write_data_out, tc_data_out : std_ulogic_vector(31 downto 0);
        variable tc_m_type_out : std_ulogic_vector(1 downto 0);
        variable tc_read_out, tc_write_out, tc_stall : std_ulogic;
        variable tc_rd_out : std_ulogic_vector(4 downto 0);
        variable tc_op_out : rv32i_op;
    
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
            
            hread(fp, tc_addr_in);
            addr_in <= tc_addr_in;
            
            hread(fp, tc_rd_in);
            rd_in <= tc_rd_in;
            
            hread(fp, tc_read_data_in);
            read_data_in <= tc_read_data_in;
            
            read(fp, tc_delay);
            delay <= tc_delay;
            
            -- set expected outputs
            hread(fp, tc_addr_out);
            e_addr_out <= tc_addr_out;
            
            hread(fp, tc_write_data_out);
            e_write_data_out <= tc_write_data_out;
            
            hread(fp, tc_data_out);
            e_data_out <= tc_data_out;
            
            hread(fp, tc_m_type_out);
            e_m_type_out <= tc_m_type_out;
            
            read(fp, tc_read_out);
            e_read_out <= tc_read_out;
            
            read(fp, tc_write_out);
            e_write_out <= tc_write_out;
            
            read(fp, tc_stall);
            e_stall <= tc_stall;
            
            hread(fp, tc_rd_out);
            e_rd_out <= tc_rd_out;
            
            e_op_out <= tc_opcode;
            
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
          
          assert e_write_data_out = write_data_out
            report "write data wrong" severity warning;
          
          assert e_data_out = data_out
            report "data out wrong" severity warning;
            
          assert e_m_type_out = m_type_out   
            report "mem type wrong" severity warning;
          
          assert e_read_out = read_out
            report "read wrong" severity warning;
          
          assert e_write_out = write_out
            report "write wrong" severity warning;
          
          assert e_stall = stall
            report "stall wrong" severity warning;
          
          assert e_rd_out = rd_out
            report "rd wrong" severity warning;
          
          assert e_op_out = op_out
            report "opcode wrong" severity warning;
            
          test_no <= test_no + 1;
        end if;
    end process;
end architecture mem_stage_tb_arch;