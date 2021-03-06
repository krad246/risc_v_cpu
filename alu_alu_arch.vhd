library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.rv32i.all;

entity alu is
  port(op0, op1 : in std_ulogic_vector(31 downto 0);
    opcode : in alu_op;
    alu_out : out std_ulogic_vector(31 downto 0);
    zero_flag : out std_ulogic;
    carry_flag : out std_ulogic;
    overflow_flag : out std_ulogic;
    neg_flag : out std_ulogic);
end entity alu;

--
architecture alu_arch of alu is
  constant zero : std_ulogic_vector(31 downto 0) := x"00000000";
begin
  process(op0, op1, opcode)
    variable ret : std_ulogic_vector(31 downto 0);
    
  begin
    overflow_flag <= '0';
    carry_flag <= '0';
    zero_flag <= '0';
    neg_flag <= '0';
    
    -- once the alu operation is determined, carry it out
    case opcode is
        -- interpret op0 and op1 as signed and return their sum
        when alu_add =>
          ret := std_ulogic_vector(signed(op0) + signed(op1));
          
          if op0(31) = op1(31) and op0(31) /= ret(31) then
            overflow_flag <= '1';
          end if;
          
          if ret(31) then
            neg_flag <= '1';
          end if;
        
        -- interpret op0 and op1 as signed and return op0 - op1
        when alu_sub =>
          ret := std_ulogic_vector(signed(op0) - signed(op1));
          
          if op0(31) = op1(31) and op0(31) /= ret(31) then
            overflow_flag <= '1';
          end if;
          
          if ret(31) then
            neg_flag <= '1';
          end if;
          
        -- interpret op0 and op1 as unsigned and return op0 - op1
        when alu_subu =>
          ret := std_ulogic_vector(unsigned(op0) - unsigned(op1));
          
          if unsigned(op0) < unsigned(op1) then
            carry_flag <= '1';
          end if;
          
        -- return the xor of op0 and op1
        when alu_xor =>
          ret := op0 xor op1;
          
        -- return the or of op0 and op1
        when alu_or =>
          ret := op0 or op1;
          
        -- return the and of op0 and op1
        when alu_and =>
          ret := op0 and op1;
        
        -- return op0 << op1 if sl else op0 >> op1
        when alu_sl =>
          ret := op0 sll to_integer(unsigned(op1));
        when alu_srl =>
          ret := op0 srl to_integer(unsigned(op1));
        when alu_sra => 
          ret := std_ulogic_vector(signed(op0) sra to_integer(unsigned(op1)));
          if ret(31) then
            neg_flag <= '1';
          end if;
        
        when others => ret := zero;
    end case;
    
    if ret = zero then
      zero_flag <= '1';
    end if;
    
    alu_out <= ret;
  end process;
end architecture alu_arch;

