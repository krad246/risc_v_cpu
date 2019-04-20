library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.rv32i.all;

-- decode stage entity
entity decode_stage is
    -- decode stage takes register input data, pc, and instruction as operands
    -- outputs for register / valid state are directly from the combinational decoder
    -- op0, op1, op2 are the operands from the instruction
    -- opcode is the function to execute
    port(instruction, pc, rs1_data, rs2_data : in std_ulogic_vector(31 downto 0);
        clock, stall, jmp : in std_ulogic;
        rs1, rs2, rd : out std_ulogic_vector(4 downto 0);
        rs1_used, rs2_used, rd_used : out std_ulogic;
        op0, op1, op2 : out std_ulogic_vector(31 downto 0);
        opcode : out rv32i_op);
end entity decode_stage;

-- decode stage declaration
architecture decode_stage_arch of decode_stage is
    -- stage register outputs for instruction and pc
    signal ir_val : std_ulogic_vector(31 downto 0);
    signal pc_val : std_ulogic_vector(31 downto 0);

    -- signal for opcode and immediate from combinational decoder
    signal cu_imm : std_ulogic_vector(31 downto 0);
    signal cu_opcode : rv32i_op;
    
    -- decoder registration
    signal rdv : std_ulogic;

begin
    -- combinational decoder 
    format_parse : entity work.decoder(decoder_arch)
        port map(instruction => ir_val,
            rs1 => rs1,
            rs2 => rs2,
            rd => rd,
            rs1_used => rs1_used,
            rs2_used => rs2_used,
            rd_used => rdv,
            opcode => cu_opcode,
            imm => cu_imm);
            
    rd_used <= (rdv and not stall) and (rdv and not jmp);

    -- register to latch the instruction
    inst_register : entity work.reg(pos_clk_desc)
        generic map(reg_width => 32)
        port map(reg_in => instruction,
            reg_clk => clock,
            reg_en => not stall,
            reg_rst => '0',
            reg_out => ir_val);

    -- register to latch the program counter
    pc_register : entity work.reg(pos_clk_desc)
        generic map(reg_width => 32)
        port map(reg_in => pc,
            reg_clk => clock,
            reg_en => not stall,
            reg_rst => '0',
            reg_out => pc_val);            

    -- control unit that populates the operand fields
    -- control unit listens in on the opcode, program counter, data inputs and immediate
    control_unit : process(cu_opcode, cu_imm, pc_val, rs1_data, rs2_data, stall, jmp)
        constant zero : std_ulogic_vector(31 downto 0) := x"00000000";
        variable pc_offset : unsigned(31 downto 0);

    begin
        -- directly set the opcode from the combinational decoder unless a stall or a jump has occurred
        if stall or jmp then
          opcode <= nop;
        else
          opcode <= cu_opcode;
        end if;

        -- populate the operands based on the opcode
        -- generally op2 is always the immediate
        -- if possible, op0 = rs1 and op1 = rs2
        -- set operands in ascending order
        case cu_opcode is

            -- when r-type instruction
            when addr | subr | sllr | sltr | sltur | xorr | srlr | srar | orr | andr =>
                -- set op0 = rs1 and op1 = rs2
                op0 <= rs1_data;
                op1 <= rs2_data;
                op2 <= zero;

            -- when r-type alternative
            when slli | srli | srai =>
                -- set immediate and op0 = rs1
                op0 <= rs1_data;
                op1 <= zero;
                op2 <= cu_imm; 

            -- when i-type
            when addi | slti | sltiu | xori | ori | andi | jalr =>
                -- set op0 = rs1
                op0 <= rs1_data;

                -- if opcode = jalr then set op1 = pc + 4
                if cu_opcode = jalr then
                  pc_offset := unsigned(pc_val) + 4;
                  op1 <= std_ulogic_vector(pc_offset);
                else
                  op1 <= zero;
                end if;

                -- set immediate
                op2 <= cu_imm; 

            -- when ls-type
            when lb | lh | lw | lbu | lhu | sb | sh | sw =>
                -- set op0 = rs1
                op0 <= rs1_data;

                -- if store type then op1 = rs2
                if cu_opcode = sb or cu_opcode = sh or cu_opcode = sw then
                  op1 <= rs2_data;
                else
                  op1 <= zero;
                end if;

                -- set immediate
                op2 <= cu_imm;

            -- when b-type
            when beq | bne | blt | bge | bltu | bgeu =>
                -- set op0, op1 = rs1, rs2
                op0 <= rs1_data;
                op1 <= rs2_data;

                -- set op2 = imm + pc
                pc_offset := unsigned(signed(pc_val) + to_integer(signed(cu_imm)));
                op2 <= std_ulogic_vector(pc_offset);

            -- when u-type
            when lui | auipc =>
                -- if lui then the only operand is imm
                -- else op0 = pc
                if cu_opcode = lui then
                  op0 <= zero;
                else
                  op0 <= pc_val;
                end if;

                -- op1 = 0, op2 = imm0
                op1 <= zero;
                op2 <= cu_imm;

            -- when j-type
            when jal =>
                -- set op0, op1 = pc, pc + 4
                op0 <= pc_val;
                pc_offset := unsigned(pc_val) + 4;
                op1 <= std_ulogic_vector(pc_offset);

                -- set op2 = imm
                op2 <= cu_imm;

            -- edge cases
            when nop | bad =>
                -- all zero
                op0 <= zero;
                op1 <= zero;
                op2 <= zero;
        end case;
    end process;
end architecture decode_stage_arch; 