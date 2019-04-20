--
-- vhdl architecture my_project1_lib.processor.processor_arch
--
-- created:
--          by - krad2.unknown (desktop-uoaipla)
--          at - 12:27:20 04/15/2019
--
-- using mentor graphics hdl designer(tm) 2015.1b (build 4)
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.rv32i.all;

entity processor is
  port(clock : in std_ulogic);
end entity processor;

--
architecture processor_arch of processor is
  
  -- fetch <-> arbiter interaction signals
  signal f2arb_fetchaddr : std_ulogic_vector(31 downto 0);
  signal f2arb_read : std_ulogic;
  signal arb2f_fetchdelay : std_ulogic;
  signal arb2f_instdata : std_ulogic_vector(31 downto 0);
  
  -- fetch <-> decode interaction signals
  signal f2d_inst : std_ulogic_vector(31 downto 0);
  signal f2d_pc : std_ulogic_vector(31 downto 0);
  
  -- fetch <-> execute interaction signals
  signal ex2f_jmp : std_ulogic;
  signal ex2f_jmp_addr : std_ulogic_vector(31 downto 0);
  
  -- fetch outputs for multiple drivers
  signal f_inst, f_pc : std_ulogic_vector(31 downto 0);
  signal f_read : std_ulogic;
  
  -- regfile <-> decode interaction signals
  signal rf2d_rs1_data, rf2d_rs2_data : std_ulogic_vector(31 downto 0);
  
  -- regtracker <-> decode interaction
  signal rt2d_stall : std_ulogic;
  signal d2rt_reada, d2rt_readb, d2rt_rfwa: std_ulogic;
  signal d2rt_rfraa, d2rt_rfrab, d2rt_rfwadecd : std_ulogic_vector(4 downto 0);
  
  -- arbiter <-> memory stage interaction
  signal mem2arb_addr, mem2arb_writedata, arb2mem_readdata : std_ulogic_vector(31 downto 0);
  signal mem2arb_re, mem2arb_we : std_ulogic;
  signal arb2mem_delay : std_ulogic;
  
  -- arbiter <-> ram interaction
  signal arb2ram_addr, arb2ram_data : std_ulogic_vector(31 downto 0);
  signal arb2ram_we, arb2ram_re : std_ulogic;
  signal ram2arb_delay : std_ulogic;
  
  -- decode outputs
  signal d_rs1, d_rs2, d_rd : std_ulogic_vector(4 downto 0);
  signal d_rs1v, d_rs2v, d_rdv : std_ulogic;
  signal d_op0, d_op1, d_op2 : std_ulogic_vector(31 downto 0);
  signal d_opcode : rv32i_op;
  
  -- execute outputs
  signal d2e_rd : std_ulogic_vector(4 downto 0);
  signal e_addr, e_data : std_ulogic_vector(31 downto 0);
  signal e_rd : std_ulogic_vector(4 downto 0);
  signal e_opc : rv32i_op;
  
  -- memory stage outputs
  signal m_wbdata : std_ulogic_vector(31 downto 0);
  signal m_rd : std_ulogic_vector(4 downto 0);
  signal m_opc : rv32i_op;
  signal m_stall : std_ulogic;
  
  -- writeback outputs
  signal wb_write : std_ulogic;
  signal wb_writedata : std_ulogic_vector(31 downto 0);
  signal wb_rd : std_ulogic_vector(4 downto 0);
  
  -- arbiter outputs
  signal arb_data : std_ulogic_vector(31 downto 0);
  
  -- ram output
  signal ram_data : std_ulogic_vector(31 downto 0);
  
  signal resvec : std_ulogic_vector(31 downto 0);
  
begin
  fetch : entity work.instruction_fetch(if_arch_behavioral)
    port map(
      
      -- arbiter <-> fetch interactions  
      if_delay_flag => arb2f_fetchdelay or m_stall or rt2d_stall,
      if_mem_data => arb2f_instdata, 
      if_addr_out => f_pc,
      if_read_out => f_read,
      
      -- default to start but dont reset
      if_rst => '0',
      
      -- connect clock
      if_clk => clock,
      
      -- connect inst to decode and pc to decode
      if_instruction => f_inst,
      
      -- connect fetch inputs to execute outputs
      if_jmp_addr => ex2f_jmp_addr,
      if_jmp_flag => ex2f_jmp);
  
  -- set inputs to arbiter
  f2arb_fetchaddr <= f_pc;
  f2arb_read <= f_read;
  
  -- set inputs to decode
  f2d_inst <= f_inst;
  f2d_pc <= f_pc;
  
  decode : entity work.decode_stage(decode_stage_arch)
    port map(
      
      -- input to decode from fetch
      instruction => f2d_inst,
      pc => f2d_pc,
      
      -- clock
      clock => clock,
      
      -- stall from register tracker or memory stage
      stall => rt2d_stall or m_stall,
      
      -- jmp for exec
      jmp => ex2f_jmp,
      
      -- rs1 and rs2 contents from register file
      rs1_data => rf2d_rs1_data,
      rs2_data => rf2d_rs2_data,
      
      -- register addresses to register tracker and file
      rs1 => d_rs1,
      rs2 => d_rs2,
      rd => d_rd,
      
      -- register valid bits to tracker and execute
      rs1_used => d_rs1v,
      rs2_used => d_rs2v,
      rd_used => d_rdv,
      
      op0 => d_op0,
      op1 => d_op1,
      op2 => d_op2,
      opcode => d_opcode  
    );
    
    -- register tracker register reservations come from decode stage valid bits
    d2rt_reada <= d_rs1v;
    d2rt_readb <= d_rs2v;
    d2rt_rfwa <= d_rdv;
    
    -- register tracker register addresses come from decode stage addresses
    d2rt_rfraa <= d_rs1;
    d2rt_rfrab <= d_rs2;
    d2rt_rfwadecd <= d_rd;
      
  execute : entity work.execute_stage(execute_stage_arch)
    port map(
      
      -- input operands of execute come from decode
      op0 => d_op0, 
      op1 => d_op1, 
      op2 => d_op2,
      
      -- clock
		  clock => clock,
		  
		  -- decode stage rd goes to execute stage
		  rd_in => d2e_rd,
		  
		  -- execute stage rd output for mem
		  rd_out => e_rd,
		  
		  -- input opcode comes from decode stage
		  opcode => d_opcode,
		  
		  -- execute stage opcode output from execute stage
		  opcode_out => e_opc,
		  
		  -- address, data output from execute stage goes to memeory
		  address => e_addr,
		  data => e_data, 
		  
		  -- execute stage jmp and jaddr go to fetch
		  jmp_addr => ex2f_jmp_addr,
		  jmp => ex2f_jmp,
		  
		  -- mem stage freezes execute
		  stall => m_stall
		);
	
	-- execute stage gets rd from decode
	d2e_rd <= d_rd;
      
  writeback : entity work.writeback_stage(writeback_stage_arch)
    port map(
      
      -- take the inputs from memory
      data_in => m_wbdata,
      rd_in => m_rd,
      op_in => m_opc,
      
      -- writeback data, enable, and register address goes to register file
      data_out => wb_writedata,
      rd_out => wb_rd,
      write => wb_write,
      
      -- clock
      clock => clock
    );
      
    memory : entity work.mem_stage(mem_stage_arch)
    port map(
      
      -- mem stage inputs come from execute stage
      data_in => e_data, 
      addr_in => e_addr,
      rd_in => e_rd,
      op_in => e_opc,
      
      -- addr, write and read data interface with memory system
      -- plus enable bits
      addr_out => mem2arb_addr, 
      write_data => mem2arb_writedata,
      read_data => arb2mem_readdata,
      read => mem2arb_re, 
      write => mem2arb_we,
      
      -- m_type : out std_ulogic_vector(1 downto 0);

      -- delay comes from arbiter
      delay => arb2mem_delay,

      -- stall output freezes all stages before
      stall => m_stall,

      -- mem stage outputs go to writeback
      data_out => m_wbdata,
      rd_out => m_rd,
      op_out => m_opc,
      
      -- clock
      clock => clock
    );    
   
  ram : entity work.MemorySystem(Behavior)
  port map(Addr => arb2ram_addr, DataIn => arb2ram_data,
      clock => clock, we => arb2ram_we, re => arb2ram_re,
      mdelay => ram2arb_delay,
      DataOut => ram_data);
  
  arbiter : entity work.arbiter(arbiter_arch)
    port map(
      fetch_addr => f2arb_fetchaddr, 
      mem_addr => mem2arb_addr, 
      data_in_ram => ram_data,
      data_in_mem => mem2arb_writedata,
      data_out_mem => arb2ram_data,
      fetch_read => f2arb_read,
      mem_read => mem2arb_re, 
      write_in => mem2arb_we, 
      delay_in => ram2arb_delay,
      data_out_ram => arb_data,
      addr_out => arb2ram_addr,
      fetch_delay => arb2f_fetchdelay,
      mem_delay => arb2mem_delay,
      write_out => arb2ram_we, 
      read_out => arb2ram_re
    ); 
  
  arb2f_instdata <= arb_data;
  arb2mem_readdata <= arb_data;
  
  regfile : entity work.regfile(regfile_arch)
    port map(
      -- register file write data comes from writeback
      data_in => wb_writedata,
      
      -- register file reg addresses come from decode stage
      read_addr_1 => d_rs1, 
      read_addr_2 => d_rs2,
      write_addr => wb_rd,
      
      -- writeback write output enables write for register
      write => wb_write,
      
      -- clock
      clock => clock,
      
      -- register contents go to decode
      read_data_1 => rf2d_rs1_data,
      read_data_2 => rf2d_rs2_data
    );
  
  track : entity work.regtracker(regtracker_arch)
    port map(
      -- stall comes to decode stage
      stall => rt2d_stall,
      
      -- register addresses come from decode stage + valid bits
      rfra_a => d2rt_rfraa,
      rfra_b => d2rt_rfrab,
      rfwa_decd => d2rt_rfwadecd,
      read_a => d2rt_reada,
      read_b => d2rt_readb,
      reserve => d2rt_rfwa,
      
      -- clock
      clock => clock,
      
      -- write signal from writeback frees register
      rfwa_wb => wb_rd,
      free => wb_write,
      
      resvec => resvec
    );  

end architecture processor_arch;

