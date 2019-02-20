--
-- VHDL Package Body my_project1_lib.rv32i
--
-- Created:
--          by - krad2.UNKNOWN (DESKTOP-UOAIPLA)
--          at - 19:43:56 02/18/2019
--
-- using Mentor Graphics HDL Designer(TM) 2015.1b (Build 4)
--
package body rv32i is
  function ftype(func : func_name) return rv32i_op is
    variable ret : rv32i_op;
  begin
    case func is
      when "lui--" => ret := lui;
      when "auipc" => ret := auipc;
      when "jal--" => ret := jal;
      when "jalr-" => ret := jalr;
      when "beq--" => ret := beq;
      when "bne--" => ret := bne;
      when "blt--" => ret := blt;
      when "bge--" => ret := bge;
      when "bltu-" => ret := bltu;
      when "bgeu-" => ret := bgeu;
      when "lb---" => ret := lb;
      when "lh---" => ret := lh;
      when "lw---" => ret := lw;
      when "lbu--" => ret := lbu;
      when "lhu--" => ret := lhu;
      when "sb---" => ret := sb;
      when "sh---" => ret := sh;
      when "sw---" => ret := sw;
      when "addi-" => ret := addi;
      when "slti-" => ret := slti;
      when "sltiu" => ret := sltiu;
      when "xori-" => ret := xori;
      when "ori--" => ret := ori;
      when "andi-" => ret := andi;
      when "slli-" => ret := slli;
      when "srli-" => ret := srli;
      when "srai-" => ret := srai;
      when "addr-" => ret := addr;
      when "subr-" => ret := subr;
      when "sllr-" => ret := sllr;
      when "sltr-" => ret := sltr;
      when "sltur" => ret := sltur;
      when "xorr-" => ret := xorr;
      when "srlr-" => ret := srlr;
      when "srar-" => ret := srar;
      when "orr--" => ret := orr;
      when "andr-" => ret := andr;
      when others => ret := bad;
    end case;
  return ret;
  end;
end rv32i;
