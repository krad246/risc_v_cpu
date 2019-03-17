library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.rv32i.all;

entity alu is
  port(op0, op1 : in std_ulogic_vector(31 downto 0);
    opcode : in rv32i_op;
    alu_out : out std_ulogic_vector(31 downto 0);
    status : out std_ulogic);
end entity alu;

--
architecture alu_arch of alu is
  constant zero : std_ulogic_vector(31 downto 0) := x"00000000";
begin
  process(op0, op1, opcode)
    variable operation : alu_op;
    
  begin
    -- check what the opcode is
    case opcode is
        -- if it uses an addition
        when auipc | jal | jalr | lb | lh | lw | lbu | lhu | sb | sh | sw | addi | addr =>
          operation := alu_add;
          
        -- if it uses an int subtraction
        when beq | bne | blt | bge | slti | subr | sltr =>
          operation := alu_sub;
          
        -- if it uses an unsigned subtraction
        when bltu | bgeu | sltiu | sltur =>
          operation := alu_subu;
          
        -- if it uses an xor
        when xori | xorr =>
          operation := alu_xor;
          
        -- if it uses an or
        when ori | orr =>
          operation := alu_or;
          
        -- if it uses an and
        when andi | andr =>
          operation := alu_and;
          
        -- if it uses a left shift
        when slli | sllr =>
          operation := alu_sl;
          
        -- if it uses a logical right shift
        when srli | srlr =>
          operation := alu_srl;
          
        -- if it uses an arithmetic right shift
        when srai | srar =>
          operation := alu_sra;
        
        -- if it doesn't use the alu then ??
        when others =>
          operation := alu_add;
    end case;
    
    -- once the alu operation is determined, carry it out
    case operation is
        -- interpret op0 and op1 as signed and return their sum
        when alu_add =>
          alu_out <= std_ulogic_vector(signed(op0) + signed(op1));
        
        -- interpret op0 and op1 as signed and return op0 - op1
        when alu_sub =>
          alu_out <= std_ulogic_vector(signed(op0) - signed(op1));
          
        -- interpret op0 and op1 as unsigned and return op0 - op1
        when alu_subu =>
          alu_out <= std_ulogic_vector(unsigned(op0) - unsigned(op1));
        
        -- return the xor of op0 and op1
        when alu_xor =>
          alu_out <= op0 xor op1;
          
        -- return the or of op0 and op1
        when alu_or =>
          alu_out <= op0 or op1;
          
        -- return the and of op0 and op1
        when alu_and =>
          alu_out <= op0 and op1;
        
        -- return op0 << op1 if sl else op0 >> op1
        when alu_sl =>
          alu_out <= op0 sll to_integer(unsigned(op1));
        when alu_srl =>
          alu_out <= op0 srl to_integer(unsigned(op1));
        when alu_sra => 
          alu_out <= std_ulogic_vector(signed(op0) sra to_integer(unsigned(op1)));
    end case;
    
    if alu_out = zero then
      status <= '1';
    else
      status <= '0';
    end if;
  end process;
end architecture alu_arch;

