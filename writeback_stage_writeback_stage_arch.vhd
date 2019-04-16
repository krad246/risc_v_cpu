--
-- vhdl architecture my_project1_lib.writeback_stage.writeback_stage_arch
--
-- created:
--          by - krad2.unknown (desktop-uoaipla)
--          at - 15:27:50 04/01/2019
--
-- using mentor graphics hdl designer(tm) 2015.1b (build 4)
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use work.rv32i.all;

entity writeback_stage is
  port(data_in : in std_ulogic_vector(31 downto 0);
    rd_in : in std_ulogic_vector(4 downto 0);
    op_in : in rv32i_op;
    data_out : out std_ulogic_vector(31 downto 0);
    rd_out : out std_ulogic_vector(4 downto 0);
    write : out std_ulogic;
    clock : in std_ulogic);
end entity writeback_stage;

--
architecture writeback_stage_arch of writeback_stage is
  signal data_val : std_ulogic_vector(31 downto 0);
  signal op_val : rv32i_op;
  signal rd_val : std_ulogic_vector(4 downto 0);
  
begin
    -- register to latch addr
	data_reg : entity work.reg(pos_clk_desc)
	generic map(reg_width => 32)
		port map(reg_in => data_in,
		reg_clk => clock,
		reg_en => '1',
		reg_rst => '0',
		reg_out => data_val);
  
 	-- register to latch rd
	rd_reg : entity work.reg(pos_clk_desc)
	generic map(reg_width => 5)
		port map(reg_in => rd_in,
		reg_clk => clock,
		reg_en => '1',
		reg_rst => '0',
		reg_out => rd_val);

	-- register to latch opcode
	op_reg : entity work.op_reg(op_reg_arch)
		port map(reg_in => op_in,
			reg_out => op_val,
			clock => clock,
			en => '1',
			rst => '0');
	
	controller : process(op_val, rd_val, data_val)
	constant zero : std_ulogic_vector(31 downto 0) := x"00000000";
	begin
	  write <= '1';
	  rd_out <= rd_val;
	  data_out <= data_val;
	  
	  -- if the opcode is a branch or a store, we aren't writing to a register
	  case op_val is
	  when beq | bne | blt | bge | bltu | bgeu | sb | sh | sw | nop | bad => 
	   write <= '0';
	   rd_out <= zero(4 downto 0);
	   data_out <= zero;
	  when others =>
	  end case;
	end process;
end architecture writeback_stage_arch;

