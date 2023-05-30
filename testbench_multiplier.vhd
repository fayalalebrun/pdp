----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/27/2023 06:37:01 PM
-- Design Name: 
-- Module Name: testbench_multiplier - Behavioral
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
use work.mlite_pack.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity testbench_multiplier is
--  Port ( );
end testbench_multiplier;

architecture Behavioral of testbench_multiplier is
    component mult is
        port(clk       : in std_logic;
        reset_in  : in std_logic;
        a, b      : in std_logic_vector(31 downto 0);
        mult_func : in mult_function_type;
        c_mult    : out std_logic_vector(31 downto 0);
        pause_out : out std_logic
        );
        end component;
        signal clk: std_logic := '1';
        signal reset: std_logic := '1';
        signal p_out: std_logic;
        signal a_sig, b_sig: std_logic_vector(31 downto 0) := (others => '0');
        signal c_res: std_logic_vector(31 downto 0);
        signal mult_function: mult_function_type:= MULT_NOTHING;
begin
    u1_mult: mult 
    port map (
        clk => clk, 
        reset_in => reset, 
        a => a_sig, 
        b => b_sig,
        mult_func => mult_function,
        c_mult => c_res, 
        pause_out => p_out
        );
    
    
    clk <= not clk after 10 ns;
    reset <= '0' after 100 ns;
    
    a_sig <= (others => '0') after 0 ns,
             std_logic_vector(to_signed(-2147483647, 32)) after 100 ns, -- 5
             (others => '0') after 280 ns,
             std_logic_vector(to_signed(-5, 32)) after 1000 ns, -- -5
             (others => '0') after 1180 ns,
             std_logic_vector(to_signed(5, 32)) after 2000 ns, -- 5
             (others => '0') after 2180 ns,
             std_logic_vector(to_signed(-5, 32)) after 3000 ns, -- -5
             (others => '0') after 3180 ns,
             std_logic_vector(to_unsigned(69, 32)) after 4000 ns,
             (others => '0') after 4180 ns,
             std_logic_vector(to_signed(-120, 32)) after 5000 ns,
             (others => '0') after 5180 ns;
             
    b_sig <= (others => '0') after 0 ns,
             std_logic_vector(to_signed(-2147483648, 32)) after 100 ns, -- 13
             (others => '0') after 280 ns,
             std_logic_vector(to_signed(13, 32)) after 1000 ns, -- 13
             (others => '0') after 1180 ns,
             std_logic_vector(to_signed(-13, 32)) after 2000 ns, -- -13
             (others => '0') after 2180 ns,
             std_logic_vector(to_signed(-13, 32)) after 3000 ns, -- -13
             (others => '0') after 3180 ns,
             std_logic_vector(to_unsigned(13, 32)) after 4000ns,
             (others => '0') after 4180 ns,
             std_logic_vector(to_unsigned(2147483647, 32)) after 5000ns,
             (others => '0') after 5180 ns;
             
             
    
    mult_function <= MULT_SIGNED_MULT after 140 ns, -- first
                     MULT_NOTHING after 260 ns,
                     MULT_READ_LO after 280 ns,
                     MULT_NOTHING after 900 ns,
                     MULT_SIGNED_MULT after 1040 ns, -- second
                     MULT_NOTHING after 1160 ns,
                     MULT_READ_LO after 1180 ns,
                     MULT_NOTHING after 1900 ns,
                     MULT_SIGNED_MULT after 2040 ns, -- third
                     MULT_NOTHING after 2160 ns,
                     MULT_READ_LO after 2180 ns,
                     MULT_NOTHING after 2900 ns,
                     MULT_SIGNED_MULT after 3040 ns, -- forth
                     MULT_NOTHING after 3160 ns,
                     MULT_READ_LO after 3180 ns,
                     MULT_NOTHING after 3900 ns,
                     MULT_MULT after 4040 ns, -- FIFTH
                     MULT_NOTHING after 4160 ns,
                     MULT_READ_LO after 4180 ns,
                     MULT_NOTHING after 4900 ns,
                     MULT_SIGNED_MULT after 5040 ns, -- SIXTH
                     MULT_NOTHING after 5160 ns,
                     MULT_READ_HI after 5180 ns,
                     MULT_NOTHING after 5900 ns
                     ;

    
end Behavioral;
