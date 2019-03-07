--
-- VHDL Architecture my_project1_lib.entity_name.arch_name
--
-- Created:
--          by - krad2.UNKNOWN (DESKTOP-UOAIPLA)
--          at - 12:22:36 01/23/2019
--
-- using Mentor Graphics HDL Designer(TM) 2015.1b (Build 4)
--
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;

ENTITY SimpleMux2 IS
  PORT ( Data_In_0, Data_In_1 : IN std_ulogic_vector(3 DOWNTO 0);
Data_Out : OUT std_ulogic_vector(3 DOWNTO 0);
control : IN std_ulogic); 
END ENTITY SimpleMux2;

--
ARCHITECTURE Behavior OF SimpleMux2 IS
BEGIN
  PROCESS(Data_In_0, Data_In_1, control)
  BEGIN
    IF (control = '0') THEN
Data_Out <= Data_In_0;
    ELSIF (control = '1') THEN
Data_Out <= Data_In_1;
    ELSE 
Data_Out <= "XXXX";
    END IF;
  END PROCESS;
END ARCHITECTURE Behavior;

