library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.mlite_pack.all;

entity shifter_tb is
end shifter_tb;

architecture Behavioral of shifter_tb is
   signal value:  std_logic_vector(31 downto 0);
   signal shift_amount: std_logic_vector(4 downto 0);
   signal shift_func: shift_function_type;
   signal c_shift, t_c_shift: std_logic_vector(31 downto 0);
   begin
      dut: entity work.shifter(logic)
         generic map (shifter_type => "MUX")
         port map(
            VALUE => value,
            shift_amount => shift_amount,
            shift_func => shift_func,
            c_shift => c_shift
            );
      ground_truth: entity work.shifter(logic)
         generic map (shifter_type => "DEFAULT")
         port map(
            VALUE => value,
            shift_amount => shift_amount,
            shift_func => shift_func,
            c_shift => t_c_shift
            );

stimulus:
      process begin
      for v in 0 to 31 loop
         for sa in 0 to 31 loop
            for f in 1 to 3 loop
               shift_amount <= std_logic_vector(to_unsigned(sa,5));
               shift_func <= std_logic_vector(to_unsigned(f,2));
               VALUE <= (v=>'1', others=>'0');
               wait for 1 ps;
               assert c_shift = t_c_shift report "Mismatch" severity Failure;
            end loop;
         end loop;
      end loop ;
      end process stimulus;
      
end Behavioral;
