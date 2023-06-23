library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

entity fulladder is
port(	a :		in 	std_logic;
		b :		in	std_logic;
		cin : 	in	std_logic;
		s :		out std_logic;
		cout : 	out std_logic
		);
end fulladder;

architecture behavioral of fulladder is
signal A_B: std_logic;
begin
	s <= a xor b xor cin;
	cout <= (cin and (a or b)) or (a and b); 

end behavioral;