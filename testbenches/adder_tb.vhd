library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.mlite_pack.all;

entity adder_tb is
end adder_tb;

architecture Behavioral of adder_tb is
   signal a, b: std_logic_vector(31 downto 0);
   signal sum:  std_logic_vector(32 downto 0);
   begin
      add: entity work.adder(logic)
         port map(
            a_in => a,
            b_in => b,
            alu_func => ALU_ADD,
            sum => sum);

    process begin
      a <= x"0000000c";
      b <= x"00000004";
      wait for 1ns;

      a <= x"000000c0";
      b <= x"00000040";
      wait for 1ns;
    end process;

end Behavioral;
