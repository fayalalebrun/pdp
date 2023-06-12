---------------------------------------------------------------------
-- TITLE: Shifter Unit
-- AUTHOR: Steve Rhoads (rhoadss@yahoo.com)
--         Matthias Gruenewald
-- DATE CREATED: 2/2/01
-- FILENAME: shifter.vhd
-- PROJECT: Plasma CPU core
-- COPYRIGHT: Software placed into the public domain by the author.
--    Software 'as is' without warranty.  Author liable for nothing.
-- DESCRIPTION:
--    Implements the 32-bit shifter unit.
---------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
use work.mlite_pack.all;

entity shifter is
   generic(shifter_type : string := "MUX");
   port(value        : in  std_logic_vector(31 downto 0);
        shift_amount : in  std_logic_vector(4 downto 0);
        shift_func   : in  shift_function_type;
        c_shift      : out std_logic_vector(31 downto 0));
end; --entity shifter

architecture logic of shifter IS
   constant padding     : STD_LOGIC_VECTOR (23 downto 0) := (others => '0');
--   type shift_function_type is (
--      shift_nothing, shift_left_unsigned, 
--      shift_right_signed, shift_right_unsigned);

   signal shift1L, shift2L, shift4L, shift8L, shift16L : std_logic_vector(31 downto 0);
   signal shift1R, shift2R, shift4R, shift8R, shift16R : std_logic_vector(31 downto 0);
   signal fills : std_logic_vector(31 downto 16);
   signal direction: std_logic;

   signal shift_amount_norm_1: std_logic_vector(3 downto 0);
   signal shift_amount_norm_2: std_logic_vector(4 downto 0);
   signal mask: std_logic_vector(31 downto 0);
   signal mask_val: std_logic;
   signal zero_result: std_logic;

begin
   fills <= "1111111111111111" when shift_func = SHIFT_RIGHT_SIGNED 
	                            and value(31) = '1' 
										 else "0000000000000000";
   shift1L  <= value(30 downto 0) & '0' when shift_amount(0) = '1' else value;
   shift2L  <= shift1L(29 downto 0) & "00" when shift_amount(1) = '1' else shift1L;
   shift4L  <= shift2L(27 downto 0) & "0000" when shift_amount(2) = '1' else shift2L;
   shift8L  <= shift4L(23 downto 0) & "00000000" when shift_amount(3) = '1' else shift4L;
   shift16L <= shift8L(15 downto 0) & ZERO(15 downto 0) when shift_amount(4) = '1' else shift8L;

   shift1R  <= fills(31) & value(31 downto 1) when shift_amount(0) = '1' else value;
   shift2R  <= fills(31 downto 30) & shift1R(31 downto 2) when shift_amount(1) = '1' else shift1R;
   shift4R  <= fills(31 downto 28) & shift2R(31 downto 4) when shift_amount(2) = '1' else shift2R;
   shift8R  <= fills(31 downto 24) & shift4R(31 downto 8)  when shift_amount(3) = '1' else shift4R;
   shift16R <= fills(31 downto 16) & shift8R(31 downto 16) when shift_amount(4) = '1' else shift8R;


MUX_SHIFTER: IF shifter_type = "MUX" generate

   direction <= shift_func(1); -- '0' is left and '1' is right

   -- We calculate the first 32 minus the first 4 bits (Equivalent to taking
   -- two's complement), in order to perform left shift if needed.
   shift_amount_norm_1 <= std_logic_vector(unsigned(not shift_amount(3 downto 0)) + 1) when direction = '0'
                          else shift_amount(3 downto 0);

   -- Same as above, but for next step.
   shift_amount_norm_2 <= std_logic_vector(unsigned(not shift_amount) + 1) when direction = '0'
                          else shift_amount;

   zero_result <= '1' when shift_func = SHIFT_NOTHING
                  else '0';

   process(shift_amount, direction, shift_func, zero_result, shift_amount)
   begin
      for i in 0 to 31 loop
         if zero_result = '1' then
            mask(i) <= '1';
         else
              if (natural(i) < (32 - unsigned('0' & shift_amount)) and direction = '1') or (natural(i) >= unsigned(shift_amount) and direction = '0') then
                 mask(i) <= '0';
              else
                 mask(i) <= '1';
              end if;
         end if;
      end loop;
      if zero_result = '1' then
         mask_val <= '0';
      elsif shift_func = SHIFT_RIGHT_SIGNED then
         mask_val <= value(31);
      else
         mask_val <= '0';
      end if;
   end process;




   process(value, shift_amount, shift_func, direction, mask, mask_val, shift_amount_norm_1, shift_amount_norm_2, zero_result)
      variable inter1: std_logic_vector(31 downto 0);
      variable inter2: std_logic_vector(31 downto 0);
      variable inter3: std_logic_vector(31 downto 0);
   begin
      for i in 0 to 31 loop
         -- Rotate by 0 to 3 with given direction
         case direction & shift_amount(1 downto 0) is
            when "000" => inter1(i) := value(i);
            when "001" => inter1(i) := value((i + 3) mod 32);
            when "010" => inter1(i) := value((i + 2) mod 32);
            when "011" => inter1(i) := value((i + 1) mod 32);
            when "100" => inter1(i) := value(i);
            when "101" => inter1(i) := value((i + 1) mod 32);
            when "110" => inter1(i) := value((i + 2) mod 32);
            when "111" => inter1(i) := value((i + 3) mod 32);
            when others => report "Unexpected input step 1";
         end case;
      end loop;

      for i in 0 to 31 loop
         case shift_amount_norm_1(3 downto 2) is
            when "00" => inter2(i) := inter1(i);
            when "01" => inter2(i) := inter1((i + 4) mod 32);
            when "10" => inter2(i) := inter1((i + 8) mod 32);
            when "11" => inter2(i) := inter1((i + 12) mod 32);
            when others => report "Unexpected input step 2";
         end case;
      end loop;

      for i in 0 to 31 loop
         case shift_amount_norm_2(4 downto 4) & mask(i) is
            when "00" => inter3(i) := inter2(i);
            when "01" => inter3(i) := mask_val;
            when "10" => inter3(i) := inter2((i + 16) mod 32);
            when "11" => inter3(i) := mask_val;
            when others => report "Unexpected input step 3";
         end case;
      end loop;

      c_shift <= inter3;
   end process;


END generate;

GENERIC_SHIFTER: if shifter_type = "DEFAULT" generate
   c_shift <= shift16L when shift_func = SHIFT_LEFT_UNSIGNED else 
              shift16R when shift_func = SHIFT_RIGHT_UNSIGNED or 
				                shift_func = SHIFT_RIGHT_SIGNED else
              ZERO;
end generate;
                 
AREA_OPTIMIZED_SHIFTER: if shifter_type= "AREA" generate
   c_shift <= shift16L when shift_func = SHIFT_LEFT_UNSIGNED else (others => 'Z');
   c_shift <= shift16R when shift_func = SHIFT_RIGHT_UNSIGNED or 
                            shift_func = SHIFT_RIGHT_SIGNED else (others => 'Z');
   c_shift <= ZERO     when shift_func = SHIFT_NOTHING else (others => 'Z');
end generate;

end; --architecture logic

