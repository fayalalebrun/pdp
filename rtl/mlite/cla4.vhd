library ieee;
use ieee.std_logic_1164.all;
use work.mlite_pack.all;

-- 4-bit Carry-Lookahead Adder
entity cla4 is
    port(a    : in    std_logic_vector(3 downto 0);
         b    : in    std_logic_vector(3 downto 0);
         cin  : in    std_logic;
         g    : inout std_logic_vector(3 downto 0);
         p    : inout std_logic_vector(3 downto 0);
         cout : out   std_logic;
         sum  : out   std_logic_vector(3 downto 0));
end;
architecture logic of cla4 is
begin
process(a, b, cin, g, p)
    variable c      : std_logic_vector(3 downto 0);
begin
   for i in 0 to 3 loop
       g(i) <= a(i) and b(i);
       p(i) <= a(i) or b(i);
   end loop;

   c(0) := g(0) or (p(0) and cin);
   c(1) := g(1) or (g(0) and p(1)) or (p(0) and p(1) and cin);
   c(2) := g(2) or (g(1) and p(2)) or (g(0) and p(1) and p(2)) or (p(0) and p(1) and p(2) and cin);
   cout <= g(3) or (g(2) and p(3)) or (g(1) and p(2) and p(3)) or (g(0) and p(1) and p(2) and p(3)) or (p(0) and p(1) and p(2) and p(3) and cin);

   -- Full adder sum
   sum(0) <= a(0) xor b(0) xor cin;
   sum(1) <= a(1) xor b(1) xor c(0);
   sum(2) <= a(2) xor b(2) xor c(1);
   sum(3) <= a(3) xor b(3) xor c(2);
end process;
end;

