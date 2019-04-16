--
-- vhdl architecture my_project1_lib.mem_stage.mem_stage_arch
--
-- created:
--          by - krad2.unknown (desktop-uoaipla)
--          at - 11:58:25 04/01/2019
--
-- using mentor graphics hdl designer(tm) 2015.1b (build 4)
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use work.rv32i.all;

entity mem_stage is
  port(data_in, addr_in : in std_ulogic_vector(31 downto 0);
    rd_in : in std_ulogic_vector(4 downto 0);
    op_in : in rv32i_op;
    addr_out, write_data : out std_ulogic_vector(31 downto 0);
    read_data : in std_ulogic_vector(31 downto 0);
    m_type : out std_ulogic_vector(1 downto 0);
    read, write : out std_ulogic;
    delay : in std_ulogic;
    stall : out std_ulogic;
    data_out : out std_ulogic_vector(31 downto 0);
    rd_out : out std_ulogic_vector(4 downto 0);
    op_out : out rv32i_op;
    clock : in std_ulogic);
end entity mem_stage;

--
architecture mem_stage_arch of mem_stage is
  signal op_val : rv32i_op;
  signal rd_val : std_ulogic_vector(4 downto 0);
  signal data_val, addr_val : std_ulogic_vector(31 downto 0);
  
begin
  -- register to latch addr
	data_reg : entity work.reg(pos_clk_desc)
	generic map(reg_width => 32)
		port map(reg_in => data_in,
		reg_clk => clock,
		reg_en => not delay,
		reg_rst => '0',
		reg_out => data_val);
  
 	-- register to latch addr
	addr_reg : entity work.reg(pos_clk_desc)
	generic map(reg_width => 32)
		port map(reg_in => addr_in,
		reg_clk => clock,
		reg_en => not delay,
		reg_rst => '0',
		reg_out => addr_val);
  
 	-- register to latch rd
	rd_reg : entity work.reg(pos_clk_desc)
	generic map(reg_width => 5)
		port map(reg_in => rd_in,
		reg_clk => clock,
		reg_en => not delay,
		reg_rst => '0',
		reg_out => rd_val);

	-- register to latch opcode
	op_reg : entity work.op_reg(op_reg_arch)
		port map(reg_in => op_in,
			reg_out => op_val,
			clock => clock,
			en => '1',
			rst => '0');
  
  -- short rd -> rd and opcode -> opcode and stall -> delay
  rd_out <= rd_val;
  op_out <= op_val;
  stall <= delay;
  
  -- pick what to put on the rest of the inputs
  controller : process(op_val, addr_val, data_val, read_data)
    -- memory sizes
    constant byte : std_ulogic_vector(1 downto 0) := "00";
    constant halfword : std_ulogic_vector(1 downto 0) := "01";
    constant word : std_ulogic_vector(1 downto 0) := "10";
    constant undef : std_ulogic_vector(1 downto 0) := "11";
    
    -- constant for default values
    constant zero : std_ulogic_vector(31 downto 0) := x"00000000";
    
  begin
    -- by default, r/w = 0/0
    read <= '0';
    write <= '0';
    
    -- we aren't specifying any memory by default either
    m_type <= undef;
    
    -- by default we are not sending data out or in
    write_data <= zero;
    
    -- send the input pointer to the output, assuming that the input is a load/store
    addr_out <= addr_val;
    
    -- set write data to zero on the output, assuming that the input is a load/store
    data_out <= zero;
    
    -- if the opcode is a load or store, set the appropriate type flag and direction bit
    case op_val is
      
    -- write_data = 0, addr_out = addr, data_out = read_data
    when lb | lbu => 
      data_out <= read_data;
      m_type <= byte;
      read <= '1';
    when lh | lhu =>
      data_out <= read_data;
      m_type <= halfword;
      read <= '1';
    when lw => 
      data_out <= read_data;
      m_type <= word;
      read <= '1';
      
    -- write_data = data_in, addr_out = addr
    when sb =>
      write_data <= data_val;
      m_type <= byte;
      write <= '1';
    when sh =>
      write_data <= data_val;
      m_type <= halfword;
      write <= '1';
    when sw =>  
      write_data <= data_val;
      m_type <= word;
      write <= '1'; 
      
    -- else the address is null and data_out = data_in because we didn't get a load / store
    when others =>
      addr_out <= zero;
      data_out <= data_val;
    end case;
  end process;
end architecture mem_stage_arch;

