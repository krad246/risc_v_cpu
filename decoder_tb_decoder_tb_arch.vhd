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

entity decoder_tb is
end entity decoder_tb;

--
architecture decoder_tb_arch of decoder_tb is
    -- open the file of test cases
    file test_cases : text open read_mode is "decoder_test_cases.txt";

    -- input to the decoder
    signal in_instruction : std_ulogic_vector(31 downto 0);
    
    -- clock signal (not useful)
    signal clk : std_ulogic;
    
    -- expected output signals
    signal exp_opcode : rv32i_op;
    signal exp_rs1, exp_rs2, exp_rd : std_ulogic_vector(4 downto 0);
    signal exp_rs1_used, exp_rs2_used, exp_rd_used : std_ulogic;
    signal exp_imm : std_ulogic_vector(31 downto 0); 

    -- output signals from the decoder
    signal out_opcode : rv32i_op;
    signal out_rs1, out_rs2, out_rd : std_ulogic_vector(4 downto 0);
    signal out_rs1_used, out_rs2_used, out_rd_used : std_ulogic;
    signal out_imm : std_ulogic_vector(31 downto 0); 

    -- test case number
    signal test_no : natural := 1;

begin
    -- instantiate a decoder
    decoder : entity work.decoder(decoder_arch)
        -- map the 'instruction' port to the input instruction signal
        -- map all the outputs to the output signals
        port map(instruction => in_instruction,
            opcode => out_opcode,
            rs1 => out_rs1,
            rs2 => out_rs2,
            rd => out_rd,
            rs1_used => out_rs1_used,
            rs2_used => out_rs2_used,
            rd_used => out_rd_used,
            imm => out_imm);

    -- create a stimulus process that reads the test cases
    stimuli : process
        -- file pointer for line reads
        variable fp : line;
        
        -- test case instruction binary
        variable tc_instruction : std_ulogic_vector(31 downto 0);
        
        -- test case string mnemonic for opcode
        variable opcode_mnem : func_name;

        -- test case binary for all test outputs
        variable tc_opcode : rv32i_op;
        variable tc_rs1, tc_rs2, tc_rd : std_ulogic_vector(4 downto 0);
        variable tc_rs1_used, tc_rs2_used, tc_rd_used : std_ulogic;
        variable tc_imm : std_ulogic_vector(31 downto 0);
    
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
            exp_opcode <= tc_opcode;

            -- read the test case instruction and place it on the input
            hread(fp, tc_instruction);
            in_instruction <= tc_instruction;

            -- read the test case register outputs
            hread(fp, tc_rs1);
            exp_rs1 <= tc_rs1;

            hread(fp, tc_rs2);
            exp_rs2 <= tc_rs2;

            hread(fp, tc_rd);
            exp_rd <= tc_rd;

            -- read the test case register flags
            read(fp, tc_rs1_used);
            exp_rs1_used <= tc_rs1_used;
            
            read(fp, tc_rs2_used);
            exp_rs2_used <= tc_rs2_used;

            read(fp, tc_rd_used);
            exp_rd_used <= tc_rd_used;

            -- read the immediate output
            hread(fp, tc_imm);
            exp_imm <= tc_imm;
            
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
            assert out_opcode = exp_opcode
                report "incorrect output for test case " & to_string(test_no) & lf
                & "(line no: " & to_string(test_no + 1) & ")" & lf
                & "opcode: " & to_string(out_opcode) & lf
                & "expected: " & to_string(exp_opcode) 
                severity warning;

            assert out_rs1 = exp_rs1
                report "incorrect output for test case " & to_string(test_no) & lf
                & "(line no: " & to_string(test_no + 1) & ")" & lf
                & "rs1 " & to_string(out_rs1) & lf
                & "expected: " & to_string(exp_rs1) 
                severity warning;

            assert out_rs2 = exp_rs2
                report "incorrect output for test case " & to_string(test_no) & lf
                & "(line no: " & to_string(test_no + 1) & ")" & lf
                & "rs2 " & to_string(out_rs2) & lf
                & "expected: " & to_string(exp_rs2) 
                severity warning;

            assert out_rd = exp_rd
                report "incorrect output for test case " & to_string(test_no) & lf
                & "(line no: " & to_string(test_no + 1) & ")" & lf
                & "rd " & to_string(out_rd) & lf
                & "expected: " & to_string(exp_rd) 
                severity warning;

            assert out_rs1_used = exp_rs1_used
                report "incorrect output for test case " & to_string(test_no) & lf
                & "(line no: " & to_string(test_no + 1) & ")" & lf
                & "rs1_used " & to_string(out_rs1_used) & lf
                & "expected: " & to_string(exp_rs1_used) 
                severity warning;

            assert out_rs2_used = exp_rs2_used
                report "incorrect output for test case " & to_string(test_no) & lf
                & "(line no: " & to_string(test_no + 1) & ")" & lf
                & "rs2_used " & to_string(out_rs2_used) & lf
                & "expected: " & to_string(exp_rs2_used) 
                severity warning;

            assert out_rd_used = exp_rd_used
                report "incorrect output for test case " & to_string(test_no) & lf
                & "(line no: " & to_string(test_no + 1) & ")" & lf
                & "rd_used " & to_string(out_rd_used) & lf
                & "expected: " & to_string(exp_rd_used) 
                severity warning;

            assert out_imm = exp_imm
                report "incorrect output for test case " & to_string(test_no) & lf
                & "(line no: " & to_string(test_no + 1) & ")" & lf
                & "imm: " & to_string(out_imm) & lf
                & "expected: " & to_string(exp_imm) 
                severity warning;
                
            test_no <= test_no + 1;
        end if;
    end process;
end architecture decoder_tb_arch;