---------------------------------------------------------------------
-- TITLE: Multiplication and Division Unit
-- AUTHORS: Steve Rhoads (rhoadss@yahoo.com)
-- DATE CREATED: 1/31/01
-- FILENAME: mult.vhd
-- PROJECT: Plasma CPU core
-- COPYRIGHT: Software placed into the public domain by the author.
--    Software 'as is' without warranty.  Author liable for nothing.
-- DESCRIPTION:
--    Implements the multiplication and division unit in 32 clocks.
--
--    To reduce space, compile your code using the flag "-mno-mul" which 
--    will use software base routines in math.c if USE_SW_MULT is defined.
--    Then remove references to the entity mult in mlite_cpu.vhd.
--
-- MULTIPLICATION
-- long64 answer = 0;
-- for(i = 0; i < 32; ++i)
-- {
--    answer = (answer >> 1) + (((b&1)?a:0) << 31);
--    b = b >> 1;
-- }
--
-- DIVISION
-- long upper=a, lower=0;
-- a = b << 31;
-- for(i = 0; i < 32; ++i)
-- {
--    lower = lower << 1;
--    if(upper >= a && a && b < 2)
--    {
--       upper = upper - a;
--       lower |= 1;
--    }
--    a = ((b&2) << 30) | (a >> 1);
--    b = b >> 1;
-- }
---------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.mlite_pack.all;

entity mult is
   generic(mult_type  : string := "FULL_ARRAY");
   port(clk       : in std_logic;
        reset_in  : in std_logic;
        a, b      : in std_logic_vector(31 downto 0);
        mult_func : in mult_function_type;
        c_mult    : out std_logic_vector(31 downto 0);
        pause_out : out std_logic);
end; --entity mult

architecture logic of mult is
   component mux4x1 is
      port(
         a_single : in STD_LOGIC_VECTOR (31 downto 0);
         a_double : in STD_LOGIC_VECTOR (32 downto 0);
         a_triple : in STD_LOGIC_VECTOR (33 downto 0);
         selA : in STD_LOGIC_VECTOR (1 downto 0);
         a_out : out STD_LOGIC_VECTOR (33 downto 0)
      ); 
   end component;

    component mult_array_mult is
        Port ( clk : in std_logic;
               reset : in std_logic;
               enable: in std_logic;
               a : in STD_LOGIC_VECTOR (31 downto 0);
               b : in STD_LOGIC_VECTOR (31 downto 0);
               sel_signed : in STD_LOGIC;
               c_res : out STD_LOGIC_VECTOR (63 downto 0));
    end component;
       
   
   constant MODE_MULT : std_logic := '1';
   constant MODE_DIV  : std_logic := '0';

   signal mode_reg    : std_logic;
   signal negate_reg_LO  : std_logic;
   signal negate_reg_HI  : std_logic;
   signal sign_reg    : std_logic;
   signal sign2_reg   : std_logic;
   signal count_reg   : std_logic_vector(5 downto 0);
   signal aa_reg      : std_logic_vector(31 downto 0);
   signal bb_reg      : std_logic_vector(31 downto 0);
   signal upper_reg   : std_logic_vector(31 downto 0);
   signal lower_reg   : std_logic_vector(31 downto 0);

   signal a_neg       : std_logic_vector(31 downto 0);
   signal b_neg       : std_logic_vector(31 downto 0);
   signal sum         : std_logic_vector(32 downto 0);
   
   -- radix_4 related signals  
   signal aa_reg_r4   : std_logic_vector(31 downto 0);
   signal a_double	  : std_logic_vector(32 downto 0);
   signal a_triple    : std_logic_vector(33 downto 0);
   signal temp_register: std_logic_vector(33 downto 0);

   signal upper_reg_r4 : std_logic_vector(33 downto 0);
   
   signal sum_radix_4 : std_logic_vector(34 downto 0);
   
   signal bb_old      : std_logic_vector(1 downto 0);
   signal a_select: std_logic_vector(1 downto 0);
   
   -- Full array related signals
      -- signal for debugging full array multiplier
   signal enable_array_mult: std_logic;
   signal sign_or_unsigned: std_logic := '0';
   signal upper_fa_res, lower_fa_res: std_logic_vector(31 downto 0);
   
   signal fa_res: std_logic_vector(63 downto 0);
begin
    -- mux for radix-4
   m1: mux4x1 
      port map(a_single => aa_reg_r4,
               a_double => a_double,
               a_triple => a_triple,
               selA => a_select,
               a_out => temp_register );
               
   fa: mult_array_mult 
    port  map( 
        clk => clk,
        reset => reset_in,
        enable => enable_array_mult,
        a => aa_reg,
        b => bb_reg,
        sel_signed => sign_or_unsigned,
        c_res => fa_res);
 
    upper_fa_res <= fa_res(63 downto 32);
    lower_fa_res <= fa_res(31 downto 0);

   -- Result
   c_mult <= lower_reg when mult_func = MULT_READ_LO and negate_reg_LO = '0' else 
             bv_negate(lower_reg) when mult_func = MULT_READ_LO and negate_reg_LO = '1' else
             upper_reg when mult_func = MULT_READ_HI and negate_reg_HI = '0' else 
             bv_negate(upper_reg) when mult_func = MULT_READ_HI and negate_reg_HI = '1' else
             ZERO;
   pause_out <= '1' when ( (count_reg /= "000000") ) and 
             (mult_func = MULT_READ_LO or mult_func = MULT_READ_HI) else '0';

   -- ABS and remainder signals
   a_neg <= bv_negate(a);
   b_neg <= bv_negate(b);
   sum <= bv_adder(upper_reg, aa_reg, mode_reg);
    
   -- Extra summation for radix-4 multiplication
   r4: if mult_type = "radix_4" generate    
        sum_radix_4 <= bv_adder(upper_reg_r4, temp_register, mode_reg);
   end generate; 
   
   --multiplication/division unit
   mult_proc: process(clk, reset_in, a, b, mult_func,
      a_neg, b_neg, sum, sign_reg, mode_reg, negate_reg_LO, 
      count_reg, aa_reg, bb_reg, upper_reg, lower_reg
      , sum_radix_4, upper_reg_r4
      , a_double, a_triple, temp_register, a_select, bb_old
      , upper_fa_res, lower_fa_res)
      variable count : std_logic_vector(2 downto 0);
   begin
      -- Default
       count := "001";

      if reset_in = '1' then
         mode_reg <= '0';
         negate_reg_LO <= '0';
         negate_reg_HI <= '0';
         sign_reg <= '0';
         sign2_reg <= '0';
         count_reg <= "000000";
         aa_reg <= ZERO;
         bb_reg <= ZERO;
         upper_reg <= ZERO;
         lower_reg <= ZERO;
         -- New signal assignment for radix-4
	     aa_reg_r4 <= (others => '0');
         a_double <= (others => '0');
         a_triple <= (others => '0');
         upper_reg_r4 <= (others => '0');
         bb_old <= "00";
         a_select <= "00";            
         sign_or_unsigned <= '0';
         enable_array_mult <= '0';

      elsif rising_edge(clk) then
         case mult_func is
            when MULT_WRITE_LO =>
               lower_reg <= a;
               negate_reg_LO <= '0';
               negate_reg_HI <= '0';
               -- for Full array mult
               enable_array_mult <= '0';

            when MULT_WRITE_HI =>
               upper_reg <= a;
               negate_reg_LO <= '0';
               negate_reg_HI <= '0';
               -- for Full array mult
               enable_array_mult <= '0';
               
            when MULT_MULT =>
               mode_reg <= MODE_MULT;
               aa_reg <= a;
               bb_reg <= b;
               upper_reg <= ZERO;
               -- CHANGES:
               if mult_type = "DEFAULT" then
                   count_reg <= "100000";
               elsif mult_type = "radix_4" then
                   count_reg <= "010010"; 
               elsif mult_type = "FULL_ARRAY" then
                   count_reg <= "000100";
               end if;   
               negate_reg_LO <= '0';
               negate_reg_HI <= '0';
               sign_reg <= '0';
               sign2_reg <= '0';
               -- New signal assignment for radix-4
			   aa_reg_r4 <= a;
               a_double <= a & '0';
               upper_reg_r4 <= (others => '0');
               bb_old <= "00";
               
               -- for Full array mult
               sign_or_unsigned <= '0';
               enable_array_mult <= '1';
               
            when MULT_SIGNED_MULT =>
               mode_reg <= MODE_MULT;
               if b(31) = '0' then
                  aa_reg <= a;
                  bb_reg <= b;
                  -- New signal assignment for radix-4
				  aa_reg_r4 <= a;
			      a_double <= a & '0';
               else
                  aa_reg <= a_neg;
                  bb_reg <= b_neg;
                  -- New Signal assignment for radix-4
				  aa_reg_r4 <= a_neg;
                  a_double <= a_neg & '0';
               end if;
               if a /= ZERO then
                  sign_reg <= a(31) xor b(31);
               else
                  sign_reg <= '0';
               end if;
               sign2_reg <= '0';
               upper_reg <= ZERO;
               -- CHANGES:
               if mult_type = "DEFAULT" then
                   count_reg <= "100000";
               elsif mult_type = "radix_4" then
                   count_reg <= "010010"; 
               elsif mult_type = "FULL_ARRAY" then
                   count_reg <= "000100";
               end if;               
               negate_reg_LO <= '0';
               negate_reg_HI <= '0';
               
               upper_reg_r4 <= (others => '0');
               bb_old <= "00";
                                
               -- New Signal assignment for radix-4
               sign_or_unsigned <= '1';
               enable_array_mult <= '1';
               
            when MULT_DIVIDE =>
               mode_reg <= MODE_DIV;
               aa_reg <= b(0) & ZERO(30 downto 0);
               bb_reg <= b;
               upper_reg <= a;
               count_reg <= "100000";
               negate_reg_LO <= '0';
               negate_reg_HI <= '0';
            when MULT_SIGNED_DIVIDE =>
               mode_reg <= MODE_DIV;
               if b(31) = '0' then
                  aa_reg(31) <= b(0);
                  bb_reg <= b;
               else
                  aa_reg(31) <= b_neg(0);
                  bb_reg <= b_neg;
               end if;
               if a(31) = '0' then
                  upper_reg <= a;
               else
                  upper_reg <= a_neg;
               end if;
               aa_reg(30 downto 0) <= ZERO(30 downto 0);
               count_reg <= "100000";
               negate_reg_LO <= a(31) xor b(31);
               negate_reg_HI <= a(31);
            
            when others =>
               if count_reg /= "000000" then
                  if mode_reg = MODE_MULT then
                     -- Multiplication
                      if mult_type = "DEFAULT" then
                         if bb_reg(0) = '1' then
                            upper_reg <= (sign_reg xor sum(32)) & sum(31 downto 1);
                            lower_reg <= sum(0) & lower_reg(31 downto 1);
                            sign2_reg <= sign2_reg or sign_reg;
                            sign_reg <= '0';
                            bb_reg <= '0' & bb_reg(31 downto 1);
                         -- The following six lines are optional for speedup
                         --elsif bb_reg(3 downto 0) = "0000" and sign2_reg = '0' and 
                         --      count_reg(5 downto 2) /= "0000" then
                         --   upper_reg <= "0000" & upper_reg(31 downto 4);
                         --   lower_reg <=  upper_reg(3 downto 0) & lower_reg(31 downto 4);
                         --   count := "100";
                         --   bb_reg <= "0000" & bb_reg(31 downto 4);
                         else
                            upper_reg <= sign2_reg & upper_reg(31 downto 1);
                            lower_reg <= upper_reg(0) & lower_reg(31 downto 1);
                            bb_reg <= '0' & bb_reg(31 downto 1);
                         end if;
                      elsif mult_type = "radix_4" then 
                          -- NEW: Radix-4 MULTIPLICATION
                           -- Calculating 3xa once
                         if count_reg <= "010001" then
                             if count_reg = "010001" then
                                 a_triple <= bv_adder(a_double, aa_reg_r4(31) & aa_reg_r4, mode_reg);
                             end if;
                              -- Starting the multiplication after 3xa is caluclated
                             if count_reg < "010001" then
                                 -- Register used as output c_mult
                                 -- THIS MAY BE THE CAUSE OF THE PROBLEM !!!
                                 lower_reg <= sum_radix_4(1 downto 0) & lower_reg(31 downto 2);
                                 upper_reg <= sum_radix_4(33 downto 2);
                                
                                 -- Shifting the upper register and sign extending it
                                 if bb_old = "00" then
                                    upper_reg_r4 <= sign2_reg & sign2_reg & sum_radix_4(33 downto 2);
                                 else
                                    upper_reg_r4 <= (sign_reg xor sum_radix_4(34)) & (sign_reg xor sum_radix_4(34)) & sum_radix_4(33 downto 2);
                                    sign2_reg <= sign2_reg or sign_reg;
                                    sign_reg <= '0';
                                 end if; 
                             end if;
                             -- Last cycle doesn't require shifting and selection of bb_old
                             if count_reg > "000001" then
                                if bb_reg(1 downto 0) = "00" then 
                                    a_select <= "00";
                                elsif bb_reg(1 downto 0) = "01" then
                                    a_select <= "01";
                                elsif bb_reg(1 downto 0) = "10" then
                                    a_select <= "10";
                                else 
                                    a_select <= "11";
                                end if;
                             
                                bb_reg <= "00" & bb_reg(31 downto 2);
                                bb_old <= bb_reg(1 downto 0);
                                -- lower_reg <= sum_radix_4(1 downto 0) & lower_reg(31 downto 2);
                             -- The last cycle is when the upper_reg is saved to
                             else
                             -- upper_reg <= upper_reg_r4(31 downto 0);
                                    a_select <= "00";                    
                             end if;
                         end if;
                      elsif mult_type = "FULL_ARRAY" then
                          upper_reg <= upper_fa_res;
                          lower_reg <= lower_fa_res;
                          if count_reg = "000001" then
                             enable_array_mult <= '0';
--                             upper_reg <= upper_reg;
--                             lower_reg <= lower_reg;
                          end if;
                      end if;
                  else   
                     -- Division
                     if sum(32) = '0' and aa_reg /= ZERO and 
                           bb_reg(31 downto 1) = ZERO(31 downto 1) then
                        upper_reg <= sum(31 downto 0);
                        lower_reg(0) <= '1';
                     else
                        lower_reg(0) <= '0';
                     end if;
                     aa_reg <= bb_reg(1) & aa_reg(31 downto 1);
                     lower_reg(31 downto 1) <= lower_reg(30 downto 0);
                     bb_reg <= '0' & bb_reg(31 downto 1);
                  end if;
                  count_reg <= std_logic_vector(unsigned(count_reg) - unsigned(count));
               else
                  a_select <= "00";
               end if; --count

         end case;
         
      end if;

   end process;
    
end; --architecture logic
