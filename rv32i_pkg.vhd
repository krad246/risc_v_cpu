--
-- VHDL Package Header my_project1_lib.rv32i
--
-- Created:
--          by - krad2.UNKNOWN (DESKTOP-UOAIPLA)
--          at - 19:39:59 02/18/2019
--
-- using Mentor Graphics HDL Designer(TM) 2015.1b (Build 4)
--
library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;

package rv32i is
  type instype is (r, i, s, sb, u, uj);
  attribute enum_encoding : string;
  attribute enum_encoding of instype : type is "000 001 010 011 100 101";
  
  -- the attribute "enum_encoding" tells the synthesis tool how to encode the
  -- values of an enumerated type. in this case, the encoding is straight binary
  
  type rv32i_op is (lui, auipc, jal, jalr, beq, bne, blt, bge, bltu, bgeu,
  lb, lh, lw, lbu, lhu, sb, sh, sw,
  addi, slti, sltiu, xori, ori, andi, slli, srli, srai,
  addr, subr, sllr, sltr, sltur, xorr, srlr, srar, orr, andr,
  nop, bad);
  
  attribute enum_encoding of rv32i_op : type is "000000 000001 000010 000011 000100 000101 000110 000111 001000 001001 001010 001011 001100 001101 001110 001111 010000 010001 010010 010011 010100 010101 010110 010111 011000 011001 011010 011011 011100 011101 011110 011111 100000 100001 100010 100011 100100 100101 100110";
  
  subtype func_name is string(5 downto 1);
  
  subtype rv32i_opfield is std_ulogic_vector(4 downto 0);
  subtype rv32i_funct3 is std_ulogic_vector(2 downto 0);
  subtype rv32i_funct7 is std_ulogic_vector(6 downto 0);
  
  constant rv32i_op_lui : rv32i_opfield := "01101";
  constant rv32i_op_auipc : rv32i_opfield := "00101";
  constant rv32i_op_jal : rv32i_opfield := "11011";
  constant rv32i_op_jalr : rv32i_opfield := "11001";
  constant rv32i_op_branch : rv32i_opfield := "11000";
  constant rv32i_op_load : rv32i_opfield := "00000";
  constant rv32i_op_store : rv32i_opfield := "01000";
  constant rv32i_op_alui : rv32i_opfield := "00100";
  constant rv32i_op_alu : rv32i_opfield := "01100";
  
  constant rv32i_fn3_jalr : rv32i_funct3 := "000";
  
  constant rv32i_fn3_branch_eq : rv32i_funct3 := "000";
  constant rv32i_fn3_branch_ne : rv32i_funct3 := "001";
  constant rv32i_fn3_branch_lt : rv32i_funct3 := "100";
  constant rv32i_fn3_branch_ge : rv32i_funct3 := "101";
  constant rv32i_fn3_branch_ltu : rv32i_funct3 := "110";
  constant rv32i_fn3_branch_geu : rv32i_funct3 := "111";
  
  constant rv32i_fn3_load_b : rv32i_funct3 := "000";
  constant rv32i_fn3_load_h : rv32i_funct3 := "001";
  constant rv32i_fn3_load_w : rv32i_funct3 := "010";
  constant rv32i_fn3_load_bu : rv32i_funct3 := "100";
  constant rv32i_fn3_load_hu : rv32i_funct3 := "101";
  
  constant rv32i_fn3_store_b : rv32i_funct3 := "000";
  constant rv32i_fn3_store_h : rv32i_funct3 := "001";
  constant rv32i_fn3_store_w : rv32i_funct3 := "010";
  
  constant rv32i_fn3_alu_add : rv32i_funct3 := "000";
  constant rv32i_fn3_alu_slt : rv32i_funct3 := "010";
  constant rv32i_fn3_alu_sltu : rv32i_funct3 := "011";
  constant rv32i_fn3_alu_xor : rv32i_funct3 := "100";
  constant rv32i_fn3_alu_or : rv32i_funct3 := "110";
  constant rv32i_fn3_alu_and : rv32i_funct3 := "111";
  constant rv32i_fn3_alu_sll : rv32i_funct3 := "001";
  constant rv32i_fn3_alu_srl : rv32i_funct3 := "101";
  constant rv32i_fn3_alu_sra : rv32i_funct3 := "101";
  constant rv32i_fn3_alu_sub : rv32i_funct3 := "000";
  
  constant rv32i_fn7_alu : rv32i_funct7 := "0000000";
  constant rv32i_fn7_alu_sra : rv32i_funct7 := "0100000";
  constant rv32i_fn7_alu_sub : rv32i_funct7 := "0100000";
  
  constant nop_inst : std_ulogic_vector(31 downto 0) := "00000000000000000000000000010011";
  constant zeros_32 : std_ulogic_vector(31 downto 0) := (others => '0');
  
  constant xlen : positive := 32;
  
  function ftype(func : func_name) return rv32i_op;
  
  type alu_op is (alu_add, alu_sub, alu_and, alu_or, alu_xor, alu_sl, alu_srl, alu_sra,
    alu_subu, alu_bad);
  
  attribute enum_encoding of alu_op : type is "0000 0001 0010 0011 0100 0101 0110 0111 1000 1001";
  
  function alutype(func : func_name) return alu_op;
end rv32i;