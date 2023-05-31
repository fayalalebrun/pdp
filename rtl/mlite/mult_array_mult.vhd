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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mult_array_mult is
    Port ( a : in STD_LOGIC_VECTOR (31 downto 0);
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

signal a_input, b_input: std_logic_vector(31 downto 0);
signal results: std_logic_vector(64 downto 0);

type row_col is array (0 to 31, 0 to 30) of std_logic;
signal sum_array: row_col := (others => (others => '0'));
signal carry_array: row_col := (others => (others => '0'));

signal a_and_b: row_col := (others => (others => '0'));

type row_or_col is array(0 to 30) of std_logic;
signal column_mux: row_or_col := (others => '0');
signal row_mux: row_or_col := (others => '0'); 

signal baugh_wooley_col, baugh_wooley_row: std_logic_vector(30 downto 0);

signal bw1, bw2 : std_logic;

begin

AB_gen_row: for i in 0 to 30 generate   -- row
     AB_gen_col: for j in 0 to 30 generate  -- column
        a_and_b(i, j) <= a_input(j) and b_input(i);
     end generate;
end generate;

-- Signal assignment of Baugh-Wooley related signals 
baugh_w: for index in 0 to 30 generate
    baugh_wooley_col(index) <= a_input(31) and b_input(index);
    baugh_wooley_row(index) <= a_input(index) and b_input(31);
end generate;  

-- Generating 2 x 30 (inverter) mux's for signed operation
-- for the 31st row and 31 column
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

-- Final missing (a AND b) term
a_and_b(31, 31) <= a_input(31) and b_input(31);

FA_first_row: for i in 1 to 31 generate
    FULL_ADDER_t: fulladder port map (
        a => a_and_b(0, i),
        b => a_and_b(1, i-1),
        cin => '0',
        s => sum_array(0, i-1),
        cout => carry_array(0, i-1)
    );
end generate;

FA_middle_rows: for i in 1 to 30 generate   -- rows
    FA_middle_cols: for j in 0 to 29 generate               -- columns
        FULL_ADDER_m: fulladder port map(
            a => carry_array(i-1, j),
            b => sum_array(i-1, j+1),
            cin => a_and_b(i, j),
            s => sum_array(i, j),
            cout => sum_array(i, j)
        ); 
    end generate;
end generate;

FA_last_col: for i in 1 to 30 generate
    FULL_ADDER_L: fulladder port map (
        a => a_and_b(i, 31),
        b => a_and_b(i+1, 30),
        cin => carry_array(i-1, 30),
        s => sum_array(i, 30),
        cout => carry_array(i, 30)
    );
end generate;

F1: fulladder port map(
    a => carry_array(30, 0),
    b => sum_array(30, 1),
    cin => sel_signed,
    s => sum_array(31, 0),
    cout => carry_array(31, 0)
);

F2: fulladder port map(
    a => carry_array(31, 30),
    b => sel_signed,
    cin => '0',
    s => results(63),
    cout => results(64)
);

FA_last_row: for j in 1 to 29 generate
    FULL_ADDER_b: fulladder port map(
        a => carry_array(30, j),
        b => sum_array(30, j+1),
        cin => carry_array(31, j-1),
        s => results(j + 32),
        cout => carry_array(31, j)
    );
end generate;

FA_LL: fulladder port map(
    a => carry_array(30, 30),
    b => a_and_b(31, 31),
    cin => carry_array(31, 29),
    s => results(62),
    cout => carry_array(31, 30)
);

-- TODO: Add Code to assign the sums to 'results' vector 

    a_input <= a;
    b_input <= b;
    c_res <= results(63 downto 0);
    
end Behavioral;
