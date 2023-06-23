----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/28/2023 11:09:28 AM
-- Design Name: 
-- Module Name: mux4x1 - Behavioral
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

entity mux4x1 is
    Port ( a_single : in STD_LOGIC_VECTOR (31 downto 0);
           a_double : in STD_LOGIC_VECTOR (32 downto 0);
           a_triple : in STD_LOGIC_VECTOR (33 downto 0);
           selA : in STD_LOGIC_VECTOR (1 downto 0);
           a_out : out STD_LOGIC_VECTOR (33 downto 0));
end mux4x1;

architecture Behavioral of mux4x1 is

begin
    with selA select a_out <=
        a_single(31) & a_single(31) & a_single when "01",
        a_double(32) & a_double when "10",
        a_triple when "11",
        (others => '0') when others;

end Behavioral;
