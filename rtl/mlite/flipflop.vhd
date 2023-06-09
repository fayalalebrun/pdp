----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/03/2023 09:32:07 PM
-- Design Name: 
-- Module Name: flipflop - Behavioral
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

entity flipflop is
    Port ( C : in STD_LOGIC;
--		   CE  : in STD_LOGIC;
           CLR : in STD_LOGIC;
           D : in STD_LOGIC;
           Q : out STD_LOGIC);
end flipflop;

architecture Behavioral of flipflop is

begin
process(C, CLR, D)
begin

    if CLR = '1' then
        Q <= '0';
    elsif rising_edge(C) then
        Q <= D;        
    end if;

end process;

end Behavioral;
