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
		address, data, jmp_addr : out std_ulogic_vector(31 downto 0);
		jmp : out std_ulogic);
end entity execute_stage;

--
architecture execute_stage_arch of execute_stage is
	signal op0_val, op1_val, op2_val : std_ulogic_vector(31 downto 0);
	signal rd_val : std_ulogic_vector(4 downto 0);

	signal alu_op0, alu_op1, alu_ret : std_ulogic_vector(31 downto 0);
	signal alu_control : alu_op;
	signal alu_zf, alu_cf, alu_of, alu_nf : std_ulogic;

	signal opcode_val : rv32i_op;

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
	op_reg : entity work.op_reg(op_reg_arch)
		port map(reg_in => opcode,
			reg_out => opcode_val,
			clock => clock,
			en => '1',
			rst => '0');

	-- alu object to do math
	alu : entity work.alu(alu_arch)
		port map(op0 => alu_op0,
			op1 => alu_op1,
			opcode => alu_control,
			zero_flag => alu_zf,
			carry_flag => alu_cf,
			overflow_flag => alu_of,
			neg_flag => alu_nf,
			alu_out => alu_ret);

	-- function to convert opcode to alu control code and populate inputs accordingly
	alu_op_decomp_param_pass : process(op0_val, op1_val, op2_val, opcode_val)
		constant zero : std_ulogic_vector(31 downto 0) := x"00000000";

	begin
		alu_op0 <= zero;
		alu_op1 <= zero;
		
		-- check what the opcode is and set the control
		case opcode_val is
			-- if it uses an addition
			when auipc | jal | jalr | lb | lh | lw | lbu | lhu | sb | sh | sw | addi | addr =>
				-- set the control to addition
				alu_control <= alu_add;

				-- correctly pass in the parameters
				alu_op0 <= op0_val;
				if opcode_val = addr then
					alu_op1 <= op1_val;
				else
					alu_op1 <= op2_val;
				end if;

			-- if it uses an int subtraction
			when beq | bne | blt | bge | slti | subr | sltr =>
				-- set the control to subtraction
				alu_control <= alu_sub;

				-- correctly pass in the parameters
				alu_op0 <= op0_val;
				if opcode_val = slti then
					alu_op1 <= op2_val;
				else 
					alu_op1 <= op1_val;
				end if;

			-- if it uses an unsigned subtraction
			when bltu | bgeu | sltiu | sltur =>
				-- set to unsigned subtraction
				alu_control <= alu_subu;
				
				-- pass in parameters
				alu_op0 <= op0_val;
				if opcode_val = sltiu then
					alu_op1 <= op2_val;
				else 
					alu_op1 <= op1_val;
				end if;

			-- if it uses an xor
			when xori | xorr =>
				-- set to xor
				alu_control <= alu_xor;
				
				-- pass in params
				alu_op0 <= op0_val;
				if opcode_val = xori then
					alu_op1 <= op2_val;
				else
					alu_op1 <= op1_val;
				end if;

			-- if it uses an or
			when ori | orr =>
				-- pass in or
				alu_control <= alu_or;
				
				-- pass in params
				alu_op0 <= op0_val;
				if opcode_val = ori then
					alu_op1 <= op2_val;
				else
					alu_op1 <= op1_val;
				end if;

			-- if it uses an and
			when andi | andr =>
				-- pass in and
				alu_control <= alu_and;
				
				-- pass in params
				alu_op0 <= op0_val;
				if opcode_val = andi then
					alu_op1 <= op2_val;
				else
					alu_op1 <= op1_val;
				end if;
			-- if it uses a left shift
			when slli | sllr =>
				-- pass in sl
				alu_control <= alu_sl;
				
				-- pass in params
				alu_op0 <= op0_val;
				if opcode_val = slli then
					alu_op1 <= op2_val;
				else
					alu_op1 <= op1_val;
				end if;
			-- if it uses a logical right shift
			when srli | srlr =>
				-- pass in srl
				alu_control <= alu_srl;
				
				-- pass in params
				alu_op0 <= op0_val;
				if opcode_val = srli then
					alu_op1 <= op2_val;
				else
					alu_op1 <= op1_val;
				end if;
			-- if it uses an arithmetic right shift
			when srai | srar =>
				-- pass in sra
				alu_control <= alu_sra;
				
				-- pass in params
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
	
	-- pass the destination and function code as is
	rd_out <= rd_val;
	opcode_out <= opcode_val;
	
	-- execution block using the alu
	execute : process(alu_ret, alu_zf, alu_cf, alu_nf, alu_of, opcode_val, op0_val, op1_val, op2_val)
		constant zero : std_ulogic_vector(31 downto 0) := x"00000000";
		constant one : std_ulogic_vector(31 downto 0) := x"00000001";

	begin
		-- default is all = 0
		jmp <= '0';      
		jmp_addr <= zero;
		address <= zero;
		data <= zero;

		case opcode_val is
			-- rd <= imm
			when lui => data <= op2_val;
			
			-- rd <= pc + imm
			when auipc => data <= alu_ret;
			
			-- jump = true, addr = xxx
			when jal | jalr =>
				jmp <= '1';
				jmp_addr <= alu_ret;
				data <= op1_val;
			
			-- rs1 - rs2 = 0
			when beq =>
				if alu_zf then
					jmp <= '1';
					jmp_addr <= op2_val;
				end if;

			-- rs1 - rs2 =/= 0
			when bne =>
				if not alu_zf then
					jmp <= '1';
					jmp_addr <= op2_val;
				end if;

			-- rs1 - rs2 < 0
			when blt =>
				if alu_nf then
					jmp <= '1';
					jmp_addr <= op2_val;
				end if;
			
			-- rs1 - rs2 >= 0
			when bge => 
				if not alu_nf then
					jmp <= '1';
					jmp_addr <= op2_val;
				end if;

			-- rs1 - rs2 < 0
			when bltu =>				
				if alu_cf then
					jmp <= '1';
					jmp_addr <= op2_val;
				end if;

			-- rs1 - rs2 >= 0
			when bgeu =>
				if not alu_cf then
					jmp <= '1';
					jmp_addr <= op2_val;
				end if;
			
			-- calculate rs1 + offset
			when lb | lh | lw | lbu | lhu => address <= alu_ret;

			-- calculate rs1 + offset, mov data, rs2
			when sb | sh | sw => --
				address <= alu_ret;
				data <= op1_val;
			
			-- perform the same tests as blt
			when slti | sltr => --
				if alu_nf then
					data <= one;
				else
					data <= zero;
				end if;

			-- perform the sme tests as bltu
			when sltiu | sltur => --
				if alu_cf then
					data <= one;
				else
					data <= zero;
				end if;
			
			-- pure math only requires the return from the alu
			when addi | xori | ori | andi | slli | srli | srai => data <= alu_ret;
			when addr | subr | xorr | orr | andr | sllr | srlr | srar => data <= alu_ret;
			
			-- do nothing
			when nop =>
			when bad =>  
		end case;
	end process;
end architecture execute_stage_arch;