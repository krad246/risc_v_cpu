--
-- vhdl architecture my_project1_lib.execute_stage.execute_stage_arch
--
-- created:
--          by - krad2.unknown (desktop-uoaipla)
--          at - 19:29:55 03/24/2019
--
-- using mentor graphics hdl designer(tm) 2015.1b (build 4)
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.rv32i.all;

entity execute_stage is
  port(op0, op1, op2 : in std_ulogic_vector(31 downto 0);
    clock : in std_ulogic;
    rd_in : in std_ulogic_vector(4 downto 0);
    rd_out : out std_ulogic_vector(4 downto 0);
    opcode : in rv32i_op;
    opcode_out : out rv32i_op;
    addr, mem_data : out std_ulogic_vector(31 downto 0));
end entity execute_stage;

--
architecture execute_stage_arch of execute_stage is
  signal op0_val, op1_val, op2_val : std_ulogic_vector(31 downto 0);
  signal rd_val : std_ulogic_vector(4 downto 0);
  signal opcode_val : rv32i_op;
  
  signal alu_op0, alu_op1, alu_ret : std_ulogic_vector(31 downto 0);
  signal alu_control : alu_op;
  signal alu_zf : std_ulogic;
  
begin
    -- register to latch op0
    op0_reg : entity work.reg(pos_clk_desc)
        generic map(reg_width => 32)
        port map(reg_in => op0,
            reg_clk => clock,
            reg_en => '1',
            reg_rst => '0',
            reg_out => op0_val);
            
    -- register to latch op1
    op1_reg : entity work.reg(pos_clk_desc)
        generic map(reg_width => 32)
        port map(reg_in => op1,
            reg_clk => clock,
            reg_en => '1',
            reg_rst => '0',
            reg_out => op1_val);
            
    -- register to latch op2
    op2_reg : entity work.reg(pos_clk_desc)
        generic map(reg_width => 32)
        port map(reg_in => op2,
            reg_clk => clock,
            reg_en => '1',
            reg_rst => '0',
            reg_out => op2_val);
            
    -- register to latch rd
    rd_reg : entity work.reg(pos_clk_desc)
        generic map(reg_width => 5)
        port map(reg_in => rd_in,
            reg_clk => clock,
            reg_en => '1',
            reg_rst => '0',
            reg_out => rd_val);
            
    -- register to latch opcode
    opcode_reg : entity work.reg(pos_clk_desc)
        generic map(reg_width => 6)
        port map(reg_in => opcode,
            reg_clk => clock,
            reg_en => '1',
            reg_rst => '0',
            reg_out => opcode_val);
    
    -- alu object to do math
    alu : entity work.alu(alu_arch)
        port map(op0 => alu_op0,
          op1 => alu_op1,
          opcode => alu_control,
          zero_flag => alu_zf,
          alu_out => alu_ret);
          
    -- function to convert opcode to alu control code and populate inputs accordingly
    alu_op_decomp_param_pass : process(op0_val, op1_val, op2_val, opcode_val)
    begin
       -- check what the opcode is and set the control
       case opcode_val is
           -- if it uses an addition
           when auipc | jal | jalr | lb | lh | lw | lbu | lhu | sb | sh | sw | addi | addr =>
             alu_control <= alu_add;
             
             alu_op0 <= op0_val;
             if opcode_val = addr then
                alu_op1 <= op1_val;
             else
                alu_op1 <= op2_val;
             end if;
            
           -- if it uses an int subtraction
           when beq | bne | blt | bge | slti | subr | sltr =>
             alu_control <= alu_sub;
            
              alu_op0 <= op0_val;
              if opcode_val = slti then
                alu_op1 <= op2_val;
              else 
                alu_op1 <= op1_val;
              end if;
              
           -- if it uses an unsigned subtraction
           when bltu | bgeu | sltiu | sltur =>
             alu_control <= alu_subu;
             
              alu_op0 <= op0_val;
              if opcode_val = sltiu then
                alu_op1 <= op2_val;
              else 
                alu_op1 <= op1_val;
              end if;
            
           -- if it uses an xor
           when xori | xorr =>
             alu_control <= alu_xor;
             
             alu_op0 <= op0_val;
             if opcode_val = xori then
               alu_op1 <= op2_val;
             else
               alu_op1 <= op1_val;
             end if;
            
           -- if it uses an or
           when ori | orr =>
             alu_control <= alu_or;
            
             alu_op0 <= op0_val;
             if opcode_val = ori then
               alu_op1 <= op2_val;
             else
               alu_op1 <= op1_val;
             end if;
           -- if it uses an and
           when andi | andr =>
             alu_control <= alu_and;
             
             alu_op0 <= op0_val;
             if opcode_val = andi then
               alu_op1 <= op2_val;
             else
               alu_op1 <= op1_val;
             end if;
           -- if it uses a left shift
           when slli | sllr =>
             alu_control <= alu_sl;
            
            alu_op0 <= op0_val;
             if opcode_val = slli then
               alu_op1 <= op2_val;
             else
               alu_op1 <= op1_val;
             end if;
           -- if it uses a logical right shift
           when srli | srlr =>
             alu_control <= alu_srl;
              
              alu_op0 <= op0_val;
             if opcode_val = srli then
               alu_op1 <= op2_val;
             else
               alu_op1 <= op1_val;
             end if;
           -- if it uses an arithmetic right shift
           when srai | srar =>
             alu_control <= alu_sra;
                       
            alu_op0 <= op0_val;
             if opcode_val = srai then
               alu_op1 <= op2_val;
             else
               alu_op1 <= op1_val;
             end if;
           -- if it doesn't use the alu then bad
           when others =>
             alu_control <= alu_bad;
       end case;
    end process;
end architecture execute_stage_arch;

