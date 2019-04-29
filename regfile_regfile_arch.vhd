--
-- vhdl architecture my_project1_lib.regfile.regfile_arch
--
-- created:
--          by - krad2.unknown (desktop-uoaipla)
--          at - 12:08:46 04/08/2019
--
-- using mentor graphics hdl designer(tm) 2015.1b (build 4)
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity regfile is
  port(data_in : in std_ulogic_vector(31 downto 0);
    read_addr_1, read_addr_2 : in std_ulogic_vector(4 downto 0);
    write_addr : in std_ulogic_vector(4 downto 0);
    write : in std_ulogic;
    clock : in std_ulogic;
    reset : in std_ulogic;
    read_data_1, read_data_2 : out std_logic_vector(31 downto 0));
end entity regfile;

--
architecture regfile_arch of regfile is
  signal reg_r_select_1, reg_r_select_2 : std_ulogic_vector(31 downto 0);
  signal w_select : std_ulogic_vector(31 downto 0);
  
begin
  read_decd_1 : entity work.n2n_decoder(n2n_arch)
    generic map(bits => 5)
    port map(selector => read_addr_1,
      addr_line => reg_r_select_1);
  
  read_decd_2 : entity work.n2n_decoder(n2n_arch)
    generic map(bits => 5)
    port map(selector => read_addr_2,
      addr_line => reg_r_select_2);
      
  write_select : entity work.n2n_decoder(n2n_arch)
    generic map(bits => 5)
    port map(selector => write_addr,
      addr_line => w_select);
      
  registers : for i in 0 to (32 - 1) generate
      signal reg_output : std_logic_vector(31 downto 0);
    
    begin
    regI : entity work.reg(pos_clk_desc)
      generic map(reg_width => 32)
      port map(reg_in => data_in,
        reg_clk => clock,
        reg_en => w_select(i) and write,
        reg_rst => reset,
        reg_out => reg_output);
        
    tsbI1 : entity work.tsb(tsb_arch)
      generic map(width => 32)
      port map(data_in => reg_output,
        enable => reg_r_select_1(i),
        data_out => read_data_1);
        
    tsbI2 : entity work.tsb(tsb_arch)
      generic map(width => 32)
      port map(data_in => reg_output,
        enable => reg_r_select_2(i),
        data_out => read_data_2);     
  end generate registers;
end architecture regfile_arch;

