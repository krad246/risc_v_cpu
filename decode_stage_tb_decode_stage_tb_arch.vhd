library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

use work.rv32i.all;

entity decode_stage_tb is
end entity decode_stage_tb;

--
architecture decode_stage_tb_arch of decode_stage_tb is
    -- list of test cases 
    file test_cases : text open read_mode is "decode_stage_test_cases.txt";

    -- input to the decode stage
    signal in_instruction, in_pc, in_rs1_data, in_rs2_data : std_ulogic_vector(31 downto 0);
    
    -- clock signal (not useful)
    signal clk : std_ulogic;
    
    -- expected output signals
    signal exp_op0, exp_op1, exp_op2 : std_ulogic_vector(31 downto 0);

    -- output signals from the decode stage
    signal out_op0, out_op1, out_op2 : std_ulogic_vector(31 downto 0);

    -- test case number
    signal test_no : natural := 1;

begin
    -- instantiate a decode stage
    decode_stage : entity work.decode_stage(decode_stage_arch)
        port map(instruction => in_instruction,
            pc => in_pc,
            rs1_data => in_rs1_data,
            rs2_data => in_rs2_data,
            clock => clk,
            op0 => out_op0,
            op1 => out_op1,
            op2 => out_op2);

    -- create a stimulus process that reads the test cases
    stimuli : process
        -- file pointer for line reads
        variable fp : line;
        
        -- test case instruction binary
        variable tc_instruction, tc_pc, tc_rs1_data, tc_rs2_data : std_ulogic_vector(31 downto 0);
        
        -- test case string mnemonic for opcode
        variable opcode_mnem : func_name;
        variable tc_opcode : rv32i_op;

        -- test case binary for all test outputs
        variable tc_op0, tc_op1, tc_op2 : std_ulogic_vector(31 downto 0);
        
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

            -- first read the instruction string 
            -- then convert it to binary and read into tc_opcode
            -- set it as expected value
            read(fp, opcode_mnem);
            tc_opcode := ftype(opcode_mnem);

            -- read the test case instruction and place it on the input
            hread(fp, tc_instruction);
            in_instruction <= tc_instruction;
            
            -- read test case pc and place it on the input
            hread(fp, tc_pc);
            in_pc <= tc_pc;
            
            -- read test case rs1_data and place it on the input
            hread(fp, tc_rs1_data);
            in_rs1_data <= tc_rs1_data;
            
            -- read test case rs2_data and place it on the input
            hread(fp, tc_rs2_data);
            in_rs2_data <= tc_rs2_data;
            
            -- read the test case operand outputs
            hread(fp, tc_op0);
            exp_op0 <= tc_op0;

            hread(fp, tc_op1);
            exp_op1 <= tc_op1;

            hread(fp, tc_op2);
            exp_op2 <= tc_op2;
            
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
            -- check that each operand output is correct
            assert out_op0 = exp_op0
                report "incorrect output for test case " & to_string(test_no) & lf
                & "(line no: " & to_string(test_no + 1) & ")" & lf
                & "op0: " & to_hstring(out_op0) & lf
                & "expected: " & to_hstring(exp_op0) 
                severity warning;

            assert out_op1 = exp_op1
                report "incorrect output for test case " & to_string(test_no) & lf
                & "(line no: " & to_string(test_no + 1) & ")" & lf
                & "op1 " & to_hstring(out_op1) & lf
                & "expected: " & to_hstring(exp_op1) 
                severity warning;

            assert out_op2 = exp_op2
                report "incorrect output for test case " & to_string(test_no) & lf
                & "(line no: " & to_string(test_no + 1) & ")" & lf
                & "op2 " & to_hstring(out_op2) & lf
                & "expected: " & to_hstring(exp_op2) 
                severity warning;
                
            test_no <= test_no + 1;
        end if;
    end process;
end architecture decode_stage_tb_arch;