----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/30/2023 10:39:45 PM
-- Design Name: 
-- Module Name: mult_array_mult - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
use ieee.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mult_array_mult is
    Port ( clk : in std_logic;
           reset : in std_logic;
           enable: in std_logic;
           a : in STD_LOGIC_VECTOR (31 downto 0);
           b : in STD_LOGIC_VECTOR (31 downto 0);
           sel_signed : in STD_LOGIC;
           c_res : out STD_LOGIC_VECTOR (63 downto 0));
end mult_array_mult;

architecture Behavioral of mult_array_mult is

component mux2x1 is 
port(   a : in STD_LOGIC;
        selA : in STD_LOGIC;
        a_out : out STD_LOGIC
);
end component;

component fulladder is
port (  a :		in 	std_logic;
		b :		in	std_logic;
		cin : 	in	std_logic;
		s :		out std_logic;
		cout : 	out std_logic
		);
end component;

component flipflop is
    Port ( clk : in STD_LOGIC;
           ce : in STD_LOGIC;
           reset : in STD_LOGIC;
           D : in STD_LOGIC;
           Q : out STD_LOGIC);
end component;

type ff_pipeline is array (0 to 1) of std_logic_vector(30 downto 0);
signal ff_input_sum, ff_input_carry: ff_pipeline := (others => (others => '0'));
--signal ff_input_sum, ff_input_carry: std_logic_vector(30 downto 0) := (others => '0');
signal ff_out_res_lower: std_logic_vector(30 downto 0) := (others => '0');
signal ff_signed, temp: std_logic;
signal temp2: std_logic_vector(2 downto 0);
signal ff_upper_sum_2: std_logic_vector(30 downto 17);
signal ff_upper_carry_2: std_logic_vector(29 downto 16);

signal a_input, b_input: std_logic_vector(31 downto 0) := (others => '0');
signal results: std_logic_vector(64 downto 0);

-- NOTE: sum/carry array are in shape 31, 30), so (31, 31) is unused in them
type row_col is array (0 to 31, 0 to 31) of std_logic;
signal sum_array: row_col := (others => (others => '0'));
signal carry_array: row_col := (others => (others => '0'));

signal a_and_b: row_col := (others => (others => '0'));

type row_or_col is array(0 to 30) of std_logic;
signal column_mux: row_or_col := (others => '0');
signal row_mux: row_or_col := (others => '0'); 

signal baugh_wooley_col, baugh_wooley_row: std_logic_vector(30 downto 0);

--signal bw1, bw2 : std_logic;

-- For Debugging. Does not affect functionallity
--type fa_state is (idle, busy, waiting);
--signal fsm_state: fa_state;
--signal counter: std_logic_vector(1 downto 0) := "00";

begin
-- 1st: ASSIGN ALL (a and b) terms with flipflops and muxes when necessary
-- Final missing (a AND b) term
temp <= a_input(31) and b_input(31);
ff_ab_last: flipflop port map (
        clk => clk,
        ce => enable,
        reset => reset,
        D => temp,
        Q => a_and_b(31, 31)
    );
    
AB_gen_row: for i in 0 to 30 generate
     AB_gen_col: for j in 0 to 30 generate  
        a_and_b(i, j) <= a_input(i) and b_input(j);
     end generate;
end generate;

-- Signal assignment of Baugh-Wooley related signals 
baugh_w: for index in 0 to 30 generate
    baugh_wooley_col(index) <= a_input(31) and b_input(index);
    baugh_wooley_row(index) <= a_input(index) and b_input(31);
end generate;  

-- Generating 2 x 30 (inverter) mux's for signed operation
-- for the 31st row and 30th column
mux_gen: for i in 0 to 30 generate
        m1: mux2x1 port map(
            a => baugh_wooley_row(i),
            selA => sel_signed,
            a_out => a_and_b(i, 31)
            );
        m2: mux2x1 port map(
            a =>baugh_wooley_col(i),
            selA => sel_signed,
            a_out => a_and_b(31, i)
            );     
 end generate;

-- 2nd: Generate the Full Adders with correct connections to signals
FA_first_row: for i in 1 to 31 generate
    FULL_ADDERS_TOP: fulladder port map (
        a => a_and_b(i, 0),
        b => a_and_b(i - 1, 1),
        cin => '0',
        s => sum_array(0, i-1),
        cout => carry_array(0, i-1)
    );
end generate;

-- UNCOMMENT THIS FOR 2 CYCLE MODE and COMMENT THE OTHER ONE
FA_middle_rows: for i in 1 to 29 generate   -- rows
--FA_middle_rows_a: for i in 1 to 14 generate   -- rows
    FA_middle_cols_a: for j in 0 to 29 generate               -- columns
        FULL_ADDERS_MID_a: fulladder port map(
            a => carry_array(i-1, j),
            b => sum_array(i-1, j+1),
            cin => a_and_b(j, i + 1),
            s => sum_array(i, j),
            cout => carry_array(i, j)
        );
    end generate;
end generate;
-- COMMENT THESE BLOCKS IN 2 CYCLE MODE
--FA_middle_rows_b: for i in 16 to 29 generate   -- rows
--    FA_middle_cols_b: for j in 0 to 29 generate               -- columns
--        FULL_ADDERS_MID_b: fulladder port map(
--            a => carry_array(i-1, j),
--            b => sum_array(i-1, j+1),
--            cin => a_and_b(j, i + 1),
--            s => sum_array(i, j),
--            cout => carry_array(i, j)
--        );
--    end generate;
--end generate;
FA_row_with_ff: for j in 0 to 29 generate
    -- COMMENT THE FIRST 3 COMPONENTS IN 2 CYCLE MODE
--    FULL_ADDER_MID_BUF_1: fulladder port map(
--            a => carry_array(14, j),
--            b => sum_array(14, j+1),
--            cin => a_and_b(j, 16),
--            s => ff_input_sum(0)(j),
--            cout => ff_input_carry(0)(j)
--        );
--    ff_sum_1: flipflop port map (
--        clk => clk,
--        ce => enable,
--        reset => reset,
--        D => ff_input_sum(0)(j),
--        Q => sum_array(15, j)
--    );
--    ff_carry_1: flipflop port map (
--        clk => clk,
--        ce => enable,
--        reset => reset,
--        D => ff_input_carry(0)(j),
--        Q => carry_array(15, j)
--    );
    FULL_ADDER_MID_BUF_2: fulladder port map(
            a => carry_array(29, j),
            b => sum_array(29, j+1),
            cin => a_and_b(j, 31),
            s => ff_input_sum(1)(j),
            cout => ff_input_carry(1)(j)
        );
    ff_sum_2: flipflop port map (
        clk => clk,
        ce => enable,
        reset => reset,
        D => ff_input_sum(1)(j),
        Q => sum_array(30, j)
    );
    ff_carry_2: flipflop port map (
        clk => clk,
        ce => enable,
        reset => reset,
        D => ff_input_carry(1)(j),
        Q => carry_array(30, j)
    );
end generate;

-- UNCOMMENT THIS FOR 2 CYCLE MODE, and COMMENT THE OTHER ONE OUT
FA_last_col: for i in 1 to 29 generate
--FA_last_col_a: for i in 1 to 14 generate
    FULL_ADDER_LEFT_a: fulladder port map (
        a => a_and_b(31, i),
        b => a_and_b(30, i + 1),
        cin => carry_array(i-1, 30),
        s => sum_array(i, 30),
        cout => carry_array(i, 30)
    );
end generate;
--ff_sum_1_2: flipflop port map (
--    clk => clk,
--    ce => enable,
--    reset => reset,
--    D => ff_input_sum(0)(30),
--    Q => sum_array(15, 30)
--);
--ff_carry_1_2: flipflop port map (
--    clk => clk,
--    ce => enable,
--    reset => reset,
--    D => ff_input_carry(0)(30),
--    Q => carry_array(15, 30)
--);

--FULL_ADDER_LEFT_ff: fulladder port map (
--        a => a_and_b(31, 15),
--        b => a_and_b(30, 16),
--        cin => carry_array(14, 30),
--        s => ff_input_sum(0)(30),
--        cout => ff_input_carry(0)(30)
--    );
--FA_last_col_b: for i in 16 to 29 generate
--    FULL_ADDER_LEFT_b: fulladder port map (
--        a => a_and_b(31, i),
--        b => a_and_b(30, i + 1),
--        cin => carry_array(i-1, 30),
--        s => sum_array(i, 30),
--        cout => carry_array(i, 30)
--    );
--end generate;
---------------------

F3: fulladder port map(
    a => a_and_b(31, 30),
    b => a_and_b(30, 31),
    cin => carry_array(29, 30),
    s => ff_input_sum(1)(30),
    cout => ff_input_carry(1)(30)
);
ff1_sum: flipflop port map (
        clk => clk,
        ce => enable,
        reset => reset,
        D => ff_input_sum(1)(30),
        Q => sum_array(30, 30)
    );
ff1_carry: flipflop port map (
        clk => clk,
        ce => enable,
        reset => reset,
        D => ff_input_carry(1)(30),
        Q => carry_array(30, 30)
    );


-- bottom most right FA, i.e., start of ripple carry portion ------------------
ff_s: flipflop port map (
        clk => clk,
        ce => enable,
        reset => reset,
        D => sel_signed,
        Q => ff_signed
    );
F1: fulladder port map(
    a => carry_array(30, 0),
    b => sum_array(30, 1),
    cin => ff_signed,
    s => sum_array(31, 0),
    cout => carry_array(31, 0)
);
-- ----------------------------------------------------------------------------

-- bottom most left EXTRA FA for signed/unsigned addition ---------------------
FA_LL2: fulladder port map(
    a => ff_signed,
    b => '0',
    cin => carry_array(31, 30),
    s => results(63),
    cout => results(64)
);
-- ----------------------------------------------------------------------------

FA_LL1: fulladder port map(
    a => carry_array(30, 30),
    b => a_and_b(31, 31),
    cin => carry_array(31, 29),
    s => results(62),
    cout => carry_array(31, 30)
);

-- Last row of Full Adders with Carry-Ripple
-- UNCOMMENT THIS FOR 2 CYCLE MODE
FA_last_row_a: for j in 1 to 29 generate
    FULL_ADDER_b: fulladder port map(
        a => carry_array(30, j),
        b => sum_array(30, j+1),
        cin => carry_array(31, j-1),
        s => results(j + 32),
        cout => carry_array(31, j)
    );
end generate;
---- extra flip flop for reducing critical path
-- UNCOMMENT THIS BLOCK FOR 4 CYCLE MODE 
--FA_last_row_a: for j in 1 to 14 generate
--    FULL_ADDER_b: fulladder port map(
--        a => carry_array(30, j),
--        b => sum_array(30, j+1),
--        cin => carry_array(31, j-1),
--        s => results(j + 32),
--        cout => carry_array(31, j)
--    );
--end generate;
--ff_15_cin: flipflop port map (
--        clk => clk,
--        ce => enable,
--        reset => reset,
--        D => carry_array(31, 14),
--        Q => temp2(0)
--    );
--ff_15_a: flipflop port map (
--    clk => clk,
--        ce => enable,
--    reset => reset,
--    D => carry_array(30, 15),
--    Q => temp2(1)
--);
--ff_15_b: flipflop port map (
--    clk => clk,
--        ce => enable,
--    reset => reset,
--    D => sum_array(30, 16),
--    Q => temp2(2)
--);
--FULL_ADDER_b: fulladder port map(
--    a => temp2(1),
--    b => temp2(2),
--    cin => temp2(0),
--    s => results(47),
--    cout => carry_array(31, 15)
--);
--FA_last_row_b: for j in 16 to 29 generate
--    ff_sum_delayed: flipflop port map (
--        clk => clk,
--        ce => enable,
--        reset => reset,
--        D => sum_array(30, j + 1),
--        Q => ff_upper_sum_2(j + 1)
--    );
--    ff_carry_delayed: flipflop port map (
--        clk => clk,
--        ce => enable,
--        reset => reset,
--        D => carry_array(30, j),
--        Q => ff_upper_carry_2(j)
--    );
--    FULL_ADDER_b: fulladder port map(
--        a => ff_upper_sum_2(j + 1),
--        b => ff_upper_carry_2(j),
--        cin => carry_array(31, j-1),
--        s => results(j + 32),
--        cout => carry_array(31, j)
--    );
--end generate;

-- 3rd: ASSIGN THE SUM ARRAY TO THE RESULTS VECTOR
ff1_res: flipflop port map (
        clk => clk,
        ce => enable,
        reset => reset,
        D => a_and_b(0, 0),
        Q => ff_out_res_lower(0)
    );
    results(0) <= ff_out_res_lower(0);
sum_assign: for index in 1 to 30 generate
    ff1_res: flipflop port map (
        clk => clk,
        ce => enable,
        reset => reset,
        D => sum_array(index - 1, 0),
        Q => ff_out_res_lower(index)
    );    
    results(index) <= ff_out_res_lower(index);
end generate;
sum_assign2: for index in 31 to 32 generate
    results(index) <= sum_array(index - 1, 0);
end generate;
--    results(32) <= sum_array(31, 0);

--    results(0) <= a_and_b(0, 0);
--sum_assign: for index in 1 to 32 generate
--    results(index) <= sum_array(index - 1, 0);
--end generate;


c_res <= results(63 downto 0);

a_input <= a when enable ='1' else
           a_input;
b_input <= b when enable = '1' else
           b_input;
           
-- USED FOR DEBUGGING
--mult_process: process(clk, enable, a, b, sel_signed)
--      variable count : std_logic_vector(1 downto 0);
--begin
--    if reset = '1' then
----        results <= (others => '0');
----        a_input <= (others => '0');
----        b_input <= (others => '0');
--        fsm_state <= idle;
--    elsif rising_edge(clk) then    
--        count := "01";
----        c_res <= results(63 downto 0);
--        case fsm_state is
--            when idle => 
--                if enable = '1' then
----                    a_input <= a;
----                    b_input <= b;
--                    counter <= "01";
--                    fsm_state <= busy;
--                 else
----                    a_input <= a_input;
----                    b_input <= b_input;
--                    counter <= counter;
--                    fsm_state <= fsm_state;
--                 end if;
--            when busy =>
----                a_input <= a_input;
----                b_input <= b_input;
--                if counter /= "00" then
--                    fsm_state <= fsm_state;
--                    counter <= counter - count;
--                elsif enable = '0' then
--                    fsm_state <= idle;
--                    counter <= counter;
--                end if;              
--            when waiting =>
--                if enable = '0' then
--                    fsm_state <= idle;
--                else 
--                    fsm_state <= waiting;
--                end if;
--        end case;
--    end if;
    
--end process;
    
end Behavioral;
