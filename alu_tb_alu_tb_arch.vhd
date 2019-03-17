library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

use work.rv32i.all;

ENTITY alu_tb IS
END ENTITY alu_tb;

--
ARCHITECTURE alu_tb_arch OF alu_tb IS
  file test_cases : text open read_mode is "alu_test_cases.txt";
  
  signal op0, op1, op2 : std_ulogic_vector(31 downto 0);
  signal opcode : rv32i_op;
  
  signal clk : std_ulogic;
  
  signal exp_alu_out : std_ulogic_vector(31 downto 0);
  signal exp_status : std_ulogic;
  
  signal alu_out : std_ulogic_vector(31 downto 0);
  signal status : std_ulogic;
  
  signal test_no : natural := 1;

BEGIN
  alu : entity work.alu(alu_arch)
    port map(op0 => op0,
      op1 => op1,
      op2 => op2,
      opcode => opcode,
      alu_out => alu_out,
      status => status);
      
  stimuli : process
    -- file pointer for line reads
    variable fp : line;
    
    variable tc_op0, tc_op1, tc_op2 : std_ulogic_vector(31 downto 0);
    
    variable opcode_mnem : func_name;
    variable tc_opcode : rv32i_op;
    
    variable tc_alu_out : std_ulogic_vector(31 downto 0);
    variable tc_status : std_ulogic;
    
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
            read(fp, opcode_mnem);
            tc_opcode := ftype(opcode_mnem);
            opcode <= tc_opcode;

            -- read the test case operands and place it on the input
            hread(fp, tc_op0);
            op0 <= tc_op0;
            
            hread(fp, tc_op1);
            op1 <= tc_op1;
            
            hread(fp, tc_op2);
            op2 <= tc_op2;
            
            -- read the test case outputs
            hread(fp, tc_alu_out);
            exp_alu_out <= tc_alu_out;
          
            read(fp, tc_status);
            exp_status <= tc_status;
            
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
          assert exp_alu_out = alu_out
            report "incorrect output for test case " & to_string(test_no) & lf
            & "(line no: " & to_string(test_no + 1) & ")" & lf
            & "out: " & to_hstring(alu_out) & lf
            & "expected: " & to_hstring(exp_alu_out) 
            severity warning;
            
          assert exp_status = alu_status
            report "incorrect output for test case " & to_string(test_no) & lf
            & "(line no: " & to_string(test_no + 1) & ")" & lf
            & "status: " & to_string(status) & lf
            & "expected: " & to_string(exp_status)
            severity warning;
      end if;
  end process;

END ARCHITECTURE alu_tb_arch;

