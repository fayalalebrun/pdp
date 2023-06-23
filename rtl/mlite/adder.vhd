library ieee;
use ieee.std_logic_1164.all;
use work.mlite_pack.all;

entity adder is
    port(a_in     : in std_logic_vector(31 downto 0);
         b_in     : in std_logic_vector(31 downto 0);
         alu_func : in alu_function_type;
         sum      : out std_logic_vector(32 downto 0));
end; 
architecture logic of adder is
   signal do_add : std_logic;
   signal bb     : std_logic_vector(31 downto 0);
   signal g      : std_logic_vector(31 downto 0);
   signal p      : std_logic_vector(31 downto 0);
   signal c      : std_logic_vector(8 downto 0);
begin
   G1: for i in 0 to 7 generate
      cla: cla4 port map(
         a    => a_in(i*4+3 downto i*4),
         b    => bb(i*4+3 downto i*4),
         cin  => c(i),
         g    => g(i*4+3 downto i*4),
         p    => p(i*4+3 downto i*4),
         cout => c(i+1),
         sum  => sum(i*4+3 downto i*4));
   end generate;
process(a_in, b_in, bb, alu_func, c, do_add)
begin
   if alu_func = ALU_ADD then
      bb <= b_in;
      c(0) <= '0';
      do_add <= '1';
   else
      bb <= not b_in;
      c(0) <= '1';
      do_add <= '0';
   end if;

   -- carry out is not used
   sum(32) <= c(8) xnor do_add;
end process;
end;
