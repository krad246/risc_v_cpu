LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

LIBRARY std;
USE std.textio.all;

ENTITY MemorySystem IS
  PORT( Addr, DataIn : IN std_ulogic_vector(31 DOWNTO 0);
        clock, we, re : IN std_ulogic;
        mdelay : OUT std_ulogic;
        DataOut : OUT std_ulogic_vector(31 DOWNTO 0));
END ENTITY MemorySystem;

--
ARCHITECTURE Behavior OF MemorySystem IS
  CONSTANT Undef : std_ulogic := 'X';
  CONSTANT LoadFileName : string := "MemoryDivide.txt";
  
  SUBTYPE ST_MEM_ADDR IS std_ulogic_vector(29 DOWNTO 0);
  SUBTYPE ST_MEM_DATA IS std_ulogic_vector(31 DOWNTO 0);
  
  CONSTANT Undefined : ST_MEM_DATA := (others => Undef);
  
  TYPE T_MEM_PAGE IS ARRAY(0 TO 1023) OF ST_MEM_DATA; -- Memory Page
 
BEGIN
  
  MEM : PROCESS(Addr, clock)
    VARIABLE MemLoaded : BOOLEAN := false;
    VARIABLE page : T_MEM_PAGE;
    VARIABLE wordnumber : INTEGER RANGE 0 to 1023;
    VARIABLE pagenumber : NATURAL;
    VARIABLE maddr : ST_MEM_ADDR;
    VARIABLE mdata : ST_MEM_DATA;
    VARIABLE invalid_addr : BOOLEAN;
    VARIABLE findex : natural;
    VARIABLE L : LINE;
    VARIABLE BV : bit_vector(31 DOWNTO 0);
    VARIABLE IV : integer;
    FILE load_file : TEXT OPEN read_mode IS LoadFileName;
    
  BEGIN
    IF (NOT MemLoaded) THEN
      MemLoaded := true;
      FOR w IN T_MEM_PAGE'RANGE LOOP
        page(w) := Undefined; -- Mark data on page undefined
      END LOOP;
      findex := 0;
      WHILE ((NOT ENDFILE(load_file)) AND (findex < 1024)) LOOP -- Load page zero
        READLINE(load_file,L);
        READ(L,BV);
        page(findex) := To_StdLogicVector(BV);
        findex := findex + 1;
      END LOOP;
      -- Page zero initialized     
    END IF;
    
    maddr := Addr(31 DOWNTO 2);
    invalid_addr := IS_X(maddr);
    
    IF NOT invalid_addr THEN
      pagenumber := CONV_INTEGER(maddr(29 DOWNTO 10));
      wordnumber := CONV_INTEGER(maddr(9 DOWNTO 0));
    END IF;     
    
    IF (rising_edge(clock) AND (we = '1') AND NOT invalid_addr) THEN
      IF (pagenumber = 0) THEN
        mdata := DataIn;
        page(wordnumber) := mdata;
        report "Writing " & to_string(DataIn) & " to address " & to_string(Addr);
      ELSE
        report "Writing " & to_string(DataIn) & " to address " & to_string(Addr) & " ** NO MEMORY **";
      END IF;
    END IF;
    
    IF invalid_addr THEN
      DataOut <= Undefined;
    ELSE
      IF (pagenumber = 0) THEN
        DataOut <= page(wordnumber);
      ELSE
        DataOut <= Undefined;
      END IF;
    END IF;   
  END PROCESS;

  mdelay <= '0';
  
END ARCHITECTURE Behavior;

