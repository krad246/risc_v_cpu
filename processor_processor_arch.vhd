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
  signal rf2d_rs1_data, rf2d_rs2_data : std_ulogic_vector(4 downto 0);
  
  -- regtracker <-> decode interaction
  signal rt2d_stall : std_ulogic;
  signal d2rt_reada, d2rt_readb, d2rt_rfwa: std_ulogic;
  signal d2rt_rfraa, d2rt_rfrab, d2rt_rfwadecd : std_ulogic_vector(4 downto 0);
  
  
  -- decode outputs
  signal d_rs1, d_rs2, d_rd : std_ulogic_vector(4 downto 0);
  signal d_rs1v, d_rs2v, d_rdv : std_ulogic;
  signal d_op0, d_op1, d_op2 : std_ulogic_vector(31 downto 0);
  signal d_opcode : rv32i_op;
  
  -- deco
  
begin
  fetch : entity work.instruction_fetch(if_arch)
    port map(
      
      -- arbiter <-> fetch interactions  
      if_delay_flag => arb2f_fetchdelay,
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
      
      -- stall from register tracker
      stall => rt2d_stall,
      
      -- rs1 and rs2 contents from register file
      rs1_data => rf2d_rs1_data,
      rs2_data => rf2d_rs2_data,
      
      -- register addresses to register tracker and file
      rs1 => d_rs1,
      rs2 => d_rs2,
      rd => d_rd,
      
      --
      -- rd => ,
      
      -- register valid bits to tracker and execute
      rs1_used => d_rs1v,
      rs2_used => d_rs2v,
      rd_used => d_rdv,
      
      op0 => d_op0,
      op1 => d_op1,
      op2 => d_op2,
      opcode => d_opcode
      
    );
    
    d2rt_reada <= d_rs1v;
    d2rt_readb <= d_rs2v;
    d2rt_rfwa <= d_rdv;
    
    d2rt_rfraa <= d_rs1;
    d2rt_rfrab <= d_rs2;
    d2rt_rfwadecd <= d_rd;
      
  execute : entity work.execute_stage(execute_stage_arch)
    port map();
      
  memory : entity work.mem_stage(mem_stage_arch)
    port map();
      
  writeback : entity work.writeback_stage(writeback_stage_arch)
    port map();
  
  ram : entity work.MemorySystem(Behavior)
    port map();
      
  arbiter : entity work.arbiter(arbiter_arch)
    port map();
  
  regfile : entity work.regfile(regfile_arch)
    port map();
  
  regtracker : entity regtracker(regtracker_arch)
    port map(stall => rt2d_stall,
      rfra_a => d2rt_rfraa,
      rfra_b => d2rt_rfrab,
      rfwa_decd => d2rt_rfwadecd,
      read_a => d2rt_reada,
      read_b => d2rt_readb,
      reserve => d2rt_rfwa,
      clock => clock
     -- free =>
      );  

end architecture processor_arch;

