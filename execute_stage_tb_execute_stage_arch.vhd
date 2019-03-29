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

entity execute_stage_tb is
end entity execute_stage_tb;

--
architecture execute_stage_tb_arch of execute_stage_tb is
    -- open the file of test cases
    file test_cases : text open read_mode is "execute_stage_test_cases.txt";
    
    -- clock signal (not useful)
    signal clk : std_ulogic;
    
    -- inputs to the execute stage
    signal op0, op1, op2 : std_ulogic_vector(31 downto 0);
    signal rd : std_ulogic_vector(4 downto 0);
    signal opcode : rv32i_op;
    
    -- outputs of the execute stage
    signal rd_out : std_ulogic_vector(4 downto 0);
    signal addr_out, data_out, j_addr_out : std_ulogic_vector(31 downto 0);
    signal j_out : std_ulogic;
    signal opcode_out : rv32i_op;
  
    -- expected outputs
    signal e_rd_out : std_ulogic_vector(4 downto 0);
    signal e_addr_out, e_data_out, e_j_addr_out : std_ulogic_vector(31 downto 0);
    signal e_j_out : std_ulogic;
    signal e_opcode_out : rv32i_op;
  
    -- test case number
    signal test_no : natural := 1;

begin
    execute_stage : entity work.execute_stage(execute_stage_arch)
      port map(op0 => op0,
        op1 => op1,
        op2 => op2,
        rd_in => rd,
        rd_out => rd_out,
        opcode => opcode,
        opcode_out => opcode_out,
        address => addr_out,
        data => data_out,
        jmp => j_out,
        jmp_addr => j_addr_out,
        clock => clk);
  
    -- create a stimulus process that reads the test cases
    stimuli : process
        -- file pointer for line reads
        variable fp : line;
        
        -- test case string mnemonic for opcode
        variable opcode_mnem : func_name;
        variable tc_opcode : rv32i_op;
        
        -- test case inputs  
        variable tc_op0, tc_op1, tc_op2 : std_ulogic_vector(31 downto 0);
        variable tc_rd : std_ulogic_vector(4 downto 0);
        
        -- test case outputs
        variable tc_rd_out : std_ulogic_vector(4 downto 0);
        variable tc_addr_out, tc_data_out, tc_j_addr_out : std_ulogic_vector(31 downto 0);
        variable tc_j_out : std_ulogic;
    
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
            opcode <= tc_opcode;
            hread(fp, tc_op0);
            op0 <= tc_op0;
            hread(fp, tc_op1);
            op1 <= tc_op1;
            hread(fp, tc_op2);
            op2 <= tc_op2;
            hread(fp, tc_rd);
            rd <= tc_rd;
            
            -- set expected outputs
            hread(fp, tc_rd_out);
            e_rd_out <= tc_rd_out;
            e_opcode_out <= tc_opcode;
            hread(fp, tc_addr_out);
            e_addr_out <= tc_addr_out;
            hread(fp, tc_data_out);
            e_data_out <= tc_data_out;
            hread(fp, tc_j_addr_out);
            e_j_addr_out <= tc_j_addr_out;
            read(fp, tc_j_out);
            e_j_out <= tc_j_out;
            
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
			assert rd_out = e_rd_out 
				report "rd wrong, line " & to_string(test_no)
				severity warning;
			assert opcode_out = e_opcode_out
				report "opcode wrong, line " & to_string(test_no)
				severity warning;
			assert addr_out = e_addr_out
				report "addr wrong, line " & to_string(test_no)
				severity warning;
			assert data_out = e_data_out
				report "data wrong, line" & to_string(test_no)
				severity warning;
			assert j_addr_out = e_j_addr_out
				report "jmp_addr wrong, line" & to_string(test_no)
				severity warning;
			assert j_out = e_j_out
				report "jmp wrong, line" & to_string(test_no)
				severity warning;
      test_no <= test_no + 1;
        end if;
    end process;
end architecture execute_stage_tb_arch;