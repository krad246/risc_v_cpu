--
-- VHDL Architecture my_project1_lib.decoder.decoder_arch
--
-- Created:
--          by - krad2.UNKNOWN (DESKTOP-UOAIPLA)
--          at - 19:33:00 02/18/2019
--
-- using Mentor Graphics HDL Designer(TM) 2015.1b (Build 4)
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.rv32i.all;

entity decoder is
  port(instruction : in std_ulogic_vector(31 downto 0);
    opcode : out rv32i_op;
    rs1, rs2, rd : out std_ulogic_vector(4 downto 0);
    rs1_used, rs2_used, rd_used : out std_ulogic;
    imm : out std_ulogic_vector(31 downto 0)); 
end entity decoder;

--
architecture decoder_arch of decoder is
begin
  process(instruction)
    variable opfield : rv32i_opfield;
    variable func3 : rv32i_funct3;
    variable func7 : rv32i_funct7;
  begin
    -- extract the minimum bits to check for an instruction
    opfield := instruction(6 downto 2);
    func3 := instruction(14 downto 12);
    func7 := instruction(31 downto 25);
    
    -- consider all possible instruction types
    case opfield is
  
      -- when instruction is LUI
      when rv32i_op_lui =>
        -- set rd to used
        rs1_used <= '0';
        rs2_used <= '0';
        rd_used <= '1';
  
        -- set register number
        rs1 <= "00000";
        rs2 <= "00000";
        rd <= instruction(11 downto 7);
  
        -- set immediate
        imm(31 downto 12) <= instruction(31 downto 12);
        imm(11 downto 0) <= (others => '0');
        
        -- set opcode
        opcode <= lui;
  
      -- when instruction is AUIPC
      when rv32i_op_auipc => 
        -- set rd to used
        rs1_used <= '0';
        rs2_used <= '0';
        rd_used <= '1';
  
        -- set register number
        rs1 <= "00000";
        rs2 <= "00000";
        rd <= instruction(11 downto 7);
  
        -- set immediate
        imm(31 downto 12) <= instruction(31 downto 12);
        imm(11 downto 0) <= (others => '0');
        
        -- set opcode
        opcode <= auipc;
  
      -- when instruction is a jump and link
      when rv32i_op_jal => 
        -- set rd to used
        rs1_used <= '0';
        rs2_used <= '0';
        rd_used <= '1';
  
        -- set register number
        rs1 <= "00000";
        rs2 <= "00000";
        rd <= instruction(11 downto 7);
  
        -- set immediate
        imm(20 downto 1) <= instruction(31) & instruction(19 downto 12) & instruction(20) & instruction(30 downto 21);
        imm(31 downto 21) <= (others => '0');
        imm(0) <= '0';
    
        -- set opcode
        opcode <= jal;
        
      -- when instruction is a jump and link register
      when rv32i_op_jalr =>
        -- set rs1 and rd to used
        rs1_used <= '1';
        rs2_used <= '0';
        rd_used <= '1';
  
        -- set register numbers
        rs1 <= instruction(19 downto 15);
        rs2 <= "00000";
        rd <= instruction(11 downto 7);
  
        -- grab the immediate at the end
        imm(11 downto 0) <= instruction(31 downto 20);
        imm(31 downto 20) <= (others => '0');
  
        if func3 = rv32i_fn3_jalr then
          opcode <= jalr;
        else
          opcode <= bad;
        end if;
  
      -- when instruction is a branch
      when rv32i_op_branch =>
        -- set rs1 and rs2 to active
        rs1_used <= '1'; 
        rs2_used <= '1'; 
        rd_used <= '0';
  
        -- set the register numbers
        rs1 <= instruction(19 downto 15);
        rs2 <= instruction(24 downto 20);
        rd <= "00000";
  
        -- set immediate
        imm(12 downto 1) <= instruction(31) & instruction(7) & instruction(30 downto 25) & instruction(11 downto 8);
        imm(31 downto 13) <= (others => '0');
        imm(0) <= '0';
  
        -- set opcode based on func3
        case func3 is
          when rv32i_fn3_branch_eq => opcode <= beq;
          when rv32i_fn3_branch_ne => opcode <= bne;
          when rv32i_fn3_branch_lt => opcode <= blt;
          when rv32i_fn3_branch_ge => opcode <= bge;
          when rv32i_fn3_branch_ltu => opcode <= bltu;
          when rv32i_fn3_branch_geu => opcode <= bgeu;
          when others => opcode <= bad;
        end case;
  
      -- when instruction is a load type
      when rv32i_op_load =>
        -- set rs1 and rd to used
        rs1_used <= '1';
        rs2_used <= '0';
        rd_used <= '1';
  
        -- set register numbers
        rs1 <= instruction(19 downto 15);
        rs2 <= "00000";
        rd <= instruction(11 downto 7);
  
        -- grab the immediate at the end
        imm(11 downto 0) <= instruction(31 downto 20);
        imm(31 downto 12) <= (others => '0');
  
        -- set opcode based on func3
        case func3 is
          when rv32i_fn3_load_b => opcode <= lb;
          when rv32i_fn3_load_h => opcode <= lh;
          when rv32i_fn3_load_w => opcode <= lw;
          when rv32i_fn3_load_bu => opcode <= lbu;
          when rv32i_fn3_load_hu => opcode <= lhu;
          when others => opcode <= bad;
        end case;
  
      -- when instruction is a store type
      when rv32i_op_store =>
        -- set rs1 and rs2 to used
        rs1_used <= '1';
        rs2_used <= '1';
        rd_used <= '0';
  
        -- set register numbers
        rs1 <= instruction(19 downto 15);
        rs2 <= instruction(24 downto 20);
        rd <= "00000";
  
        -- set immediate output
        imm(11 downto 0) <= instruction(31 downto 25) & instruction(11 downto 7);
        imm(31 downto 12) <= (others => '0');
  
        -- set opcode based on func3
        case func3 is
          when rv32i_fn3_store_b => opcode <= sb;
          when rv32i_fn3_store_h => opcode <= sh;
          when rv32i_fn3_store_w => opcode <= sw;
          when others => opcode <= bad;
        end case;
  
      -- if the instruction is an ALU immediate type
      when rv32i_op_alui => 
        -- set rs1 and rd to active
        rs1_used <= '1'; 
        rs2_used <= '0'; 
        rd_used <= '1';
        
        -- set register numbers
        rs1 <= instruction(19 downto 15);
        rs2 <= "00000";
        rd <= instruction(11 downto 7);
  
        -- grab the immediate at the end
        imm(11 downto 0) <= instruction(31 downto 20);
        imm(31 downto 12) <= (others => '0');
  
        -- check which function specifically and assign opcode
        case func3 is 
          when rv32i_fn3_alu_add => opcode <= addi;
          when rv32i_fn3_alu_slt => opcode <= slti;
          when rv32i_fn3_alu_sltu => opcode <= sltiu;
          when rv32i_fn3_alu_xor => opcode <= xori;
          when rv32i_fn3_alu_or => opcode <= ori;
          when rv32i_fn3_alu_and => opcode <= andi;
          when rv32i_fn3_alu_sll => 
            opcode <= slli;
            imm(11 downto 5) <= (others => '0');
          when rv32i_fn3_alu_srl => 
            if func7 = rv32i_fn7_alu_sra then
              opcode <= srai;
              imm(11 downto 5) <= (others => '0');
            else  
              opcode <= srli;
              imm(11 downto 5) <= (others => '0');
            end if;
          when others => opcode <= bad;
        end case;
  
        -- if the instruction is an ALU register type
      when rv32i_op_alu =>
        -- set all registers to active
        rs1_used <= '1'; 
        rs2_used <= '1'; 
        rd_used <= '1';
  
        -- set the register numbers
        rs1 <= instruction(19 downto 15);
        rs2 <= instruction(24 downto 20);
        rd <= instruction(11 downto 7);
        
        -- null out the immediate
        imm <= x"00000000";
  
        -- grab the function specifiers (only two possible types)
        func7 := instruction(31 downto 25);
  
        -- check if it has either a 0 or a 1 bit
        case func7 is 
          -- if all zeros grab the func3 and assign opcode
          when rv32i_fn7_alu =>
            case func3 is 
              when rv32i_fn3_alu_add => opcode <= addr;
              when rv32i_fn3_alu_slt => opcode <= sltr;
              when rv32i_fn3_alu_sltu => opcode <= sltur;
              when rv32i_fn3_alu_xor => opcode <= xorr;
              when rv32i_fn3_alu_or => opcode <= orr;
              when rv32i_fn3_alu_and => opcode <= andr;
              when rv32i_fn3_alu_srl => opcode <= srlr;
              when rv32i_fn3_alu_sll => opcode <= sllr;
              when others => opcode <= bad;
            end case;
  
          -- if func7 has a 1
          when rv32i_fn7_alu_sra =>
            -- if the instruction is SRA or SUB then assign opcode
            if func3 = rv32i_fn3_alu_sra then
              opcode <= srar;
            elsif func3 = rv32i_fn3_alu_sub then
              opcode <= subr;
            else
              opcode <= bad;
            end if;

          -- all others are edge cases
          when others => opcode <= bad;
        end case;
      
        -- handle edge cases
      when others => opcode <= bad;
    end case;
  end process;
end architecture decoder_arch;