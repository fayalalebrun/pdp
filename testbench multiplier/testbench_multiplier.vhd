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

use IEEE.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity testbench_multiplier is
     generic( mult_type       : string  := "FULL_ARRAY" --AREA_OPTIMIZED / DEFAULT / radix_4 / FULL_ARRAY
);
--  Port ( );
end testbench_multiplier;

architecture Behavioral of testbench_multiplier is
    component mult is
        generic(mult_type  : string := "DEFAULT"); 
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
        signal p_out, default_p_out: std_logic;
        signal a_sig, b_sig: std_logic_vector(31 downto 0) := (others => '0');
        signal c_res, default_c_res: std_logic_vector(31 downto 0);
        signal mult_function: mult_function_type:= MULT_NOTHING;
        
        signal lower_fa, lower_def, upper_fa, upper_def: std_logic_vector(31 downto 0);
        
        -- Signals to hold test values
        type test_input is array(0 to 201) of std_logic_vector(31 downto 0);
        signal a_test, b_test: test_input;
        type mult_functions is array(0 to 5) of std_logic_vector(3 downto 0);
        signal mult_mode: mult_functions := (others => (others => '0'));
        
        signal counter: std_logic_vector(7 downto 0) := (others => '0');
begin
    u1_mult: mult 
    generic map (mult_type => mult_type)
    port map (
        clk => clk, 
        reset_in => reset, 
        a => a_sig, 
        b => b_sig,
        mult_func => mult_function,
        c_mult => c_res, 
        pause_out => p_out
        );
    
    u2_mult_default: mult 
    generic map (mult_type => "DEFAULT")
    port map (
        clk => clk, 
        reset_in => reset, 
        a => a_sig, 
        b => b_sig,
        mult_func => mult_function,
        c_mult => default_c_res, 
        pause_out => default_p_out
        );
        
    mult_mode(0) <= "0000";     -- do nothing
    mult_mode(1) <= "0001";     -- read low
    mult_mode(2) <= "0010";     -- read high
    mult_mode(3) <= "0101";     -- unsigned mult
    mult_mode(4) <= "0110";     -- signed mult
  
    
a_test(0) <= std_logic_vector(to_signed(1531906111, 32));
a_test(1) <= std_logic_vector(to_signed(-342759428, 32));
a_test(2) <= std_logic_vector(to_signed(2074936804, 32));
a_test(3) <= std_logic_vector(to_signed(2075430923, 32));
a_test(4) <= std_logic_vector(to_signed(1143470520, 32));
a_test(5) <= std_logic_vector(to_signed(1474430254, 32));
a_test(6) <= std_logic_vector(to_signed(-1148296374, 32));
a_test(7) <= std_logic_vector(to_signed(-881928863, 32));
a_test(8) <= std_logic_vector(to_signed(1541127096, 32));
a_test(9) <= std_logic_vector(to_signed(-488896634, 32));
a_test(10) <= std_logic_vector(to_signed(635709440, 32));
a_test(11) <= std_logic_vector(to_signed(-445098758, 32));
a_test(12) <= std_logic_vector(to_signed(-1049321702, 32));
a_test(13) <= std_logic_vector(to_signed(313015976, 32));
a_test(14) <= std_logic_vector(to_signed(1265336850, 32));
a_test(15) <= std_logic_vector(to_signed(-945520808, 32));
a_test(16) <= std_logic_vector(to_signed(-1127948185, 32));
a_test(17) <= std_logic_vector(to_signed(-987569609, 32));
a_test(18) <= std_logic_vector(to_signed(1673500103, 32));
a_test(19) <= std_logic_vector(to_signed(-1616078049, 32));
a_test(20) <= std_logic_vector(to_signed(582680307, 32));
a_test(21) <= std_logic_vector(to_signed(-2038387354, 32));
a_test(22) <= std_logic_vector(to_signed(1661186268, 32));
a_test(23) <= std_logic_vector(to_signed(1451183069, 32));
a_test(24) <= std_logic_vector(to_signed(1416490585, 32));
a_test(25) <= std_logic_vector(to_signed(-926883384, 32));
a_test(26) <= std_logic_vector(to_signed(1550195985, 32));
a_test(27) <= std_logic_vector(to_signed(-1210983854, 32));
a_test(28) <= std_logic_vector(to_signed(1048699813, 32));
a_test(29) <= std_logic_vector(to_signed(1461653981, 32));
a_test(30) <= std_logic_vector(to_signed(566743055, 32));
a_test(31) <= std_logic_vector(to_signed(26811467, 32));
a_test(32) <= std_logic_vector(to_signed(204307944, 32));
a_test(33) <= std_logic_vector(to_signed(1390528848, 32));
a_test(34) <= std_logic_vector(to_signed(-1214045600, 32));
a_test(35) <= std_logic_vector(to_signed(1737092350, 32));
a_test(36) <= std_logic_vector(to_signed(2063513443, 32));
a_test(37) <= std_logic_vector(to_signed(728453800, 32));
a_test(38) <= std_logic_vector(to_signed(-561740412, 32));
a_test(39) <= std_logic_vector(to_signed(-156109019, 32));
a_test(40) <= std_logic_vector(to_signed(1775317038, 32));
a_test(41) <= std_logic_vector(to_signed(-1273333184, 32));
a_test(42) <= std_logic_vector(to_signed(-492133586, 32));
a_test(43) <= std_logic_vector(to_signed(1230531645, 32));
a_test(44) <= std_logic_vector(to_signed(-899422235, 32));
a_test(45) <= std_logic_vector(to_signed(-303005073, 32));
a_test(46) <= std_logic_vector(to_signed(-168012202, 32));
a_test(47) <= std_logic_vector(to_signed(653970521, 32));
a_test(48) <= std_logic_vector(to_signed(-121613794, 32));
a_test(49) <= std_logic_vector(to_signed(601439724, 32));
a_test(50) <= std_logic_vector(to_signed(1741911779, 32));
a_test(51) <= std_logic_vector(to_signed(1380516687, 32));
a_test(52) <= std_logic_vector(to_signed(-1293995141, 32));
a_test(53) <= std_logic_vector(to_signed(-1429235596, 32));
a_test(54) <= std_logic_vector(to_signed(-1165953498, 32));
a_test(55) <= std_logic_vector(to_signed(267800031, 32));
a_test(56) <= std_logic_vector(to_signed(-487290182, 32));
a_test(57) <= std_logic_vector(to_signed(1633831658, 32));
a_test(58) <= std_logic_vector(to_signed(-33609771, 32));
a_test(59) <= std_logic_vector(to_signed(-729351946, 32));
a_test(60) <= std_logic_vector(to_signed(-1512778659, 32));
a_test(61) <= std_logic_vector(to_signed(811268237, 32));
a_test(62) <= std_logic_vector(to_signed(262760463, 32));
a_test(63) <= std_logic_vector(to_signed(1070012544, 32));
a_test(64) <= std_logic_vector(to_signed(821212530, 32));
a_test(65) <= std_logic_vector(to_signed(1527141373, 32));
a_test(66) <= std_logic_vector(to_signed(-1138646301, 32));
a_test(67) <= std_logic_vector(to_signed(741118577, 32));
a_test(68) <= std_logic_vector(to_signed(-1371155707, 32));
a_test(69) <= std_logic_vector(to_signed(-16645518, 32));
a_test(70) <= std_logic_vector(to_signed(-1993900492, 32));
a_test(71) <= std_logic_vector(to_signed(1316854044, 32));
a_test(72) <= std_logic_vector(to_signed(-1694032610, 32));
a_test(73) <= std_logic_vector(to_signed(-28225428, 32));
a_test(74) <= std_logic_vector(to_signed(1511333271, 32));
a_test(75) <= std_logic_vector(to_signed(-1329377925, 32));
a_test(76) <= std_logic_vector(to_signed(-476875233, 32));
a_test(77) <= std_logic_vector(to_signed(214356697, 32));
a_test(78) <= std_logic_vector(to_signed(1304583993, 32));
a_test(79) <= std_logic_vector(to_signed(472730935, 32));
a_test(80) <= std_logic_vector(to_signed(1846492897, 32));
a_test(81) <= std_logic_vector(to_signed(131056784, 32));
a_test(82) <= std_logic_vector(to_signed(1032554744, 32));
a_test(83) <= std_logic_vector(to_signed(1024427009, 32));
a_test(84) <= std_logic_vector(to_signed(-1622308604, 32));
a_test(85) <= std_logic_vector(to_signed(-1812573767, 32));
a_test(86) <= std_logic_vector(to_signed(-1384589780, 32));
a_test(87) <= std_logic_vector(to_signed(-1905357118, 32));
a_test(88) <= std_logic_vector(to_signed(1761236867, 32));
a_test(89) <= std_logic_vector(to_signed(-483944078, 32));
a_test(90) <= std_logic_vector(to_signed(86717225, 32));
a_test(91) <= std_logic_vector(to_signed(1631877370, 32));
a_test(92) <= std_logic_vector(to_signed(1111837674, 32));
a_test(93) <= std_logic_vector(to_signed(-611940845, 32));
a_test(94) <= std_logic_vector(to_signed(-718077303, 32));
a_test(95) <= std_logic_vector(to_signed(118289666, 32));
a_test(96) <= std_logic_vector(to_signed(-2037153384, 32));
a_test(97) <= std_logic_vector(to_signed(-1308904290, 32));
a_test(98) <= std_logic_vector(to_signed(-1502504454, 32));
a_test(99) <= std_logic_vector(to_signed(525828425, 32));
a_test(100) <= std_logic_vector(to_signed(1432971531, 32));
a_test(101) <= "11111111101000010101100000110111"; 
a_test(102) <= "10111110010110010101100110101010"; 
a_test(103) <= "01010010100011111101001101011111"; 
a_test(104) <= "10111100011010101100001100011110"; 
a_test(105) <= "01011100011010100010010101110011"; 
a_test(106) <= "10100111100000100111110101010010"; 
a_test(107) <= "00101010011000111010110100101011"; 
a_test(108) <= "11101110111111000000000101010111"; 
a_test(109) <= "01110000100101111000110001000100"; 
a_test(110) <= "01101011001100011000110101100000"; 
a_test(111) <= "11111111100010110101000101001001"; 
a_test(112) <= "01100100010111101111001001010000"; 
a_test(113) <= "11001110001101100001110000111111"; 
a_test(114) <= "01010011000001101000110010101100"; 
a_test(115) <= "01101110011001001000101011011000"; 
a_test(116) <= "00101110001011111011000101010101"; 
a_test(117) <= "10010101101110010011010010001101"; 
a_test(118) <= "10011010101100001011101001011100"; 
a_test(119) <= "11010111100111101101101000001000"; 
a_test(120) <= "01010111000111110101001111110010"; 
a_test(121) <= "11100011101111010001010000000100"; 
a_test(122) <= "01000101010111011100100000010011"; 
a_test(123) <= "11011001011111101100110000111111"; 
a_test(124) <= "10111001101111100101000011000010"; 
a_test(125) <= "11101011001111000010110110001000"; 
a_test(126) <= "10011010010000101100010100111101"; 
a_test(127) <= "10111011001011110100000101000011"; 
a_test(128) <= "10110101100100000001001110111101"; 
a_test(129) <= "00011001110010000100101010000011"; 
a_test(130) <= "10000101001010101011010010101111"; 
a_test(131) <= "10001011010001010111101001000000"; 
a_test(132) <= "10111011100001111100110110100111"; 
a_test(133) <= "11010111101001111001000010111001"; 
a_test(134) <= "10110000010001101001001010111000"; 
a_test(135) <= "01101110100001100101000110010101"; 
a_test(136) <= "00110100111110111101000011110101"; 
a_test(137) <= "00110011111101011011011101001110"; 
a_test(138) <= "10000001010001101101010011110011"; 
a_test(139) <= "00011110001000001000111010101111"; 
a_test(140) <= "11000101001001001110111000110010"; 
a_test(141) <= "00011100010001001011010010111001"; 
a_test(142) <= "01100011010100000010001100110000"; 
a_test(143) <= "01010001110000111010000010100001"; 
a_test(144) <= "11011111011010111111110101110010"; 
a_test(145) <= "10001111000110001001000111010011"; 
a_test(146) <= "10100111111001100010110111011011"; 
a_test(147) <= "11001010010100110000101010001010"; 
a_test(148) <= "10000011011101101100100010010001"; 
a_test(149) <= "11100010111101110110110010000001"; 
a_test(150) <= "10000111101010101111000101010010"; 
a_test(151) <= "10110011111110001001111010110111"; 
a_test(152) <= "10100100111111100111000011000110"; 
a_test(153) <= "01010011101100010111011000010100"; 
a_test(154) <= "01010010101010000100111111100101"; 
a_test(155) <= "10010111101011111011101010010000"; 
a_test(156) <= "01011100001011001010010010001011"; 
a_test(157) <= "10111001101101001111111011110010"; 
a_test(158) <= "10010010011011100101111010010001"; 
a_test(159) <= "01001111101101000101110011111100"; 
a_test(160) <= "00001110100010100110001101111100"; 
a_test(161) <= "10111011011100000111101000000100"; 
a_test(162) <= "11111011110010101010011101110100"; 
a_test(163) <= "11011100011111011011000100110001"; 
a_test(164) <= "10101111111100101100111100000100"; 
a_test(165) <= "10111011011010001011111001100010"; 
a_test(166) <= "00111000110101111111111011100010"; 
a_test(167) <= "01010001010000101000000001001000"; 
a_test(168) <= "00101001110010101101011011011001"; 
a_test(169) <= "10110100000010000011001111110000"; 
a_test(170) <= "01111110101010011110100010100011"; 
a_test(171) <= "00000011111101101111101100011111"; 
a_test(172) <= "11111110111000011001111001011011"; 
a_test(173) <= "01000010010001110011100100010110"; 
a_test(174) <= "00100100000011000100010110101110"; 
a_test(175) <= "01000001011101100001100011100001"; 
a_test(176) <= "10100111111000111101100000000010"; 
a_test(177) <= "01011110011000111010010011101110"; 
a_test(178) <= "11011001001011110000011000110011"; 
a_test(179) <= "10011011001011100110101111101110"; 
a_test(180) <= "00000110111101100111011100011110"; 
a_test(181) <= "00110111110110110110110001100000"; 
a_test(182) <= "11001111011101100111111100010110"; 
a_test(183) <= "01110000101001101111100111101100"; 
a_test(184) <= "00111001110010000000110001000011"; 
a_test(185) <= "11101110101101010110011101000001"; 
a_test(186) <= "00111000010000001000111111110000"; 
a_test(187) <= "11110101011101110000011111101010"; 
a_test(188) <= "10110000111100011000011011011100"; 
a_test(189) <= "10110111011101011000100000001100"; 
a_test(190) <= "00100111101011100001100011110011"; 
a_test(191) <= "10111010000001101000010001000000"; 
a_test(192) <= "01110010010101101100001111111000"; 
a_test(193) <= "11100110010100110100100111100111"; 
a_test(194) <= "11000011011110001011111000100101"; 
a_test(195) <= "00010101010001011100101010010101"; 
a_test(196) <= "10001110000000010100110100010111"; 
a_test(197) <= "01000100110000011110001001011101"; 
a_test(198) <= "00101100110000010000100101100011"; 
a_test(199) <= "10011110000101001001001111110100"; 
a_test(200) <= "10111011111110000000100001001010"; 
a_test(201) <= "01011110010100111111010101010110"; 

b_test(0) <= std_logic_vector(to_signed(1985068231, 32));
b_test(1) <= std_logic_vector(to_signed(1244174902, 32));
b_test(2) <= std_logic_vector(to_signed(490171750, 32));
b_test(3) <= std_logic_vector(to_signed(-1018077290, 32));
b_test(4) <= std_logic_vector(to_signed(-329003954, 32));
b_test(5) <= std_logic_vector(to_signed(1359008453, 32));
b_test(6) <= std_logic_vector(to_signed(-1657101200, 32));
b_test(7) <= std_logic_vector(to_signed(-1636024770, 32));
b_test(8) <= std_logic_vector(to_signed(143743920, 32));
b_test(9) <= std_logic_vector(to_signed(-1553325716, 32));
b_test(10) <= std_logic_vector(to_signed(1179573211, 32));
b_test(11) <= std_logic_vector(to_signed(1883157780, 32));
b_test(12) <= std_logic_vector(to_signed(-1791334494, 32));
b_test(13) <= std_logic_vector(to_signed(-1585626676, 32));
b_test(14) <= std_logic_vector(to_signed(519958425, 32));
b_test(15) <= std_logic_vector(to_signed(-1148065132, 32));
b_test(16) <= std_logic_vector(to_signed(-269567108, 32));
b_test(17) <= std_logic_vector(to_signed(2061831575, 32));
b_test(18) <= std_logic_vector(to_signed(1081306416, 32));
b_test(19) <= std_logic_vector(to_signed(-2038235902, 32));
b_test(20) <= std_logic_vector(to_signed(1038369425, 32));
b_test(21) <= std_logic_vector(to_signed(866552942, 32));
b_test(22) <= std_logic_vector(to_signed(-2050590238, 32));
b_test(23) <= std_logic_vector(to_signed(-697083371, 32));
b_test(24) <= std_logic_vector(to_signed(-2129186203, 32));
b_test(25) <= std_logic_vector(to_signed(1271697404, 32));
b_test(26) <= std_logic_vector(to_signed(-1972494657, 32));
b_test(27) <= std_logic_vector(to_signed(1117791187, 32));
b_test(28) <= std_logic_vector(to_signed(1170017484, 32));
b_test(29) <= std_logic_vector(to_signed(986227163, 32));
b_test(30) <= std_logic_vector(to_signed(-945820659, 32));
b_test(31) <= std_logic_vector(to_signed(1577775731, 32));
b_test(32) <= std_logic_vector(to_signed(859622529, 32));
b_test(33) <= std_logic_vector(to_signed(440330290, 32));
b_test(34) <= std_logic_vector(to_signed(956236781, 32));
b_test(35) <= std_logic_vector(to_signed(-487987134, 32));
b_test(36) <= std_logic_vector(to_signed(-1834273615, 32));
b_test(37) <= std_logic_vector(to_signed(-1747989687, 32));
b_test(38) <= std_logic_vector(to_signed(-1438899040, 32));
b_test(39) <= std_logic_vector(to_signed(-925145802, 32));
b_test(40) <= std_logic_vector(to_signed(-1156753365, 32));
b_test(41) <= std_logic_vector(to_signed(-1267666170, 32));
b_test(42) <= std_logic_vector(to_signed(-751548054, 32));
b_test(43) <= std_logic_vector(to_signed(1400873173, 32));
b_test(44) <= std_logic_vector(to_signed(2103862226, 32));
b_test(45) <= std_logic_vector(to_signed(-99557523, 32));
b_test(46) <= std_logic_vector(to_signed(1929700178, 32));
b_test(47) <= std_logic_vector(to_signed(-39773042, 32));
b_test(48) <= std_logic_vector(to_signed(1105096398, 32));
b_test(49) <= std_logic_vector(to_signed(45660380, 32));
b_test(50) <= std_logic_vector(to_signed(1177487204, 32));
b_test(51) <= std_logic_vector(to_signed(1871078538, 32));
b_test(52) <= std_logic_vector(to_signed(1700150828, 32));
b_test(53) <= std_logic_vector(to_signed(-537863204, 32));
b_test(54) <= std_logic_vector(to_signed(986891155, 32));
b_test(55) <= std_logic_vector(to_signed(-2090045865, 32));
b_test(56) <= std_logic_vector(to_signed(1216328037, 32));
b_test(57) <= std_logic_vector(to_signed(-2083045256, 32));
b_test(58) <= std_logic_vector(to_signed(1786304807, 32));
b_test(59) <= std_logic_vector(to_signed(-1818741148, 32));
b_test(60) <= std_logic_vector(to_signed(885269825, 32));
b_test(61) <= std_logic_vector(to_signed(-1501866280, 32));
b_test(62) <= std_logic_vector(to_signed(-109879842, 32));
b_test(63) <= std_logic_vector(to_signed(-942054116, 32));
b_test(64) <= std_logic_vector(to_signed(260118661, 32));
b_test(65) <= std_logic_vector(to_signed(-43457991, 32));
b_test(66) <= std_logic_vector(to_signed(1115216360, 32));
b_test(67) <= std_logic_vector(to_signed(319034437, 32));
b_test(68) <= std_logic_vector(to_signed(-1132996319, 32));
b_test(69) <= std_logic_vector(to_signed(1889883171, 32));
b_test(70) <= std_logic_vector(to_signed(2110480241, 32));
b_test(71) <= std_logic_vector(to_signed(-178902492, 32));
b_test(72) <= std_logic_vector(to_signed(-174350531, 32));
b_test(73) <= std_logic_vector(to_signed(890272786, 32));
b_test(74) <= std_logic_vector(to_signed(-808832560, 32));
b_test(75) <= std_logic_vector(to_signed(1305164799, 32));
b_test(76) <= std_logic_vector(to_signed(-669129759, 32));
b_test(77) <= std_logic_vector(to_signed(-391335777, 32));
b_test(78) <= std_logic_vector(to_signed(929419687, 32));
b_test(79) <= std_logic_vector(to_signed(138765989, 32));
b_test(80) <= std_logic_vector(to_signed(355327044, 32));
b_test(81) <= std_logic_vector(to_signed(985047814, 32));
b_test(82) <= std_logic_vector(to_signed(-1108006413, 32));
b_test(83) <= std_logic_vector(to_signed(-295350290, 32));
b_test(84) <= std_logic_vector(to_signed(-1466921143, 32));
b_test(85) <= std_logic_vector(to_signed(190133822, 32));
b_test(86) <= std_logic_vector(to_signed(-846070399, 32));
b_test(87) <= std_logic_vector(to_signed(342060331, 32));
b_test(88) <= std_logic_vector(to_signed(811917545, 32));
b_test(89) <= std_logic_vector(to_signed(-254423426, 32));
b_test(90) <= std_logic_vector(to_signed(485770261, 32));
b_test(91) <= std_logic_vector(to_signed(-956008335, 32));
b_test(92) <= std_logic_vector(to_signed(615463819, 32));
b_test(93) <= std_logic_vector(to_signed(-1365002515, 32));
b_test(94) <= std_logic_vector(to_signed(1080916043, 32));
b_test(95) <= std_logic_vector(to_signed(-1850019526, 32));
b_test(96) <= std_logic_vector(to_signed(106473351, 32));
b_test(97) <= std_logic_vector(to_signed(2036392726, 32));
b_test(98) <= std_logic_vector(to_signed(-1847746838, 32));
b_test(99) <= std_logic_vector(to_signed(429640058, 32));
b_test(100) <= std_logic_vector(to_signed(-1402538013, 32));
b_test(101) <= "10110100110000100101101001001111"; 
b_test(102) <= "00101001000110000010010001110001"; 
b_test(103) <= "01110010110111001010011100100111"; 
b_test(104) <= "10011101110001010101010111001011"; 
b_test(105) <= "11000011111010111001001010100001"; 
b_test(106) <= "01110000100001111010100001111101"; 
b_test(107) <= "10001001010111010101011101101001"; 
b_test(108) <= "10010000000101101011000100011110"; 
b_test(109) <= "11011000100010001110011001001000"; 
b_test(110) <= "01000101011100100100000101111010"; 
b_test(111) <= "00101111001000011111000011101011"; 
b_test(112) <= "01100100110010001101101100001111"; 
b_test(113) <= "00111110111100010010010110100001"; 
b_test(114) <= "10000101111111101011110001000011"; 
b_test(115) <= "00111100100010001110101011000011"; 
b_test(116) <= "10111101011001100010001110010011"; 
b_test(117) <= "00001010110100111000111001110001"; 
b_test(118) <= "11100101111100100100011110010100"; 
b_test(119) <= "00011100101010110111110101100101"; 
b_test(120) <= "10110000001101111000101111101010"; 
b_test(121) <= "11101100000000010000101111011000"; 
b_test(122) <= "01010010010011100101001101001101"; 
b_test(123) <= "11001101110110011000011101010111"; 
b_test(124) <= "10101110111101100000011000000110"; 
b_test(125) <= "00100111101100101110000111111111"; 
b_test(126) <= "01101111011001111110010010100100"; 
b_test(127) <= "01101110011011110001110011101001"; 
b_test(128) <= "10111110011101010111100100001110"; 
b_test(129) <= "11000010010001011010101111000011"; 
b_test(130) <= "10011010001100111111001000101001"; 
b_test(131) <= "11100101101101110110111110101001"; 
b_test(132) <= "11000111011000000110000100001011"; 
b_test(133) <= "01110010000011110110100011110000"; 
b_test(134) <= "11010000100000110100001011000101"; 
b_test(135) <= "01101111000110000101100101101110"; 
b_test(136) <= "10111110010011010101001000100111"; 
b_test(137) <= "10101010111100110101111010101101"; 
b_test(138) <= "10111011100000001101011111010011"; 
b_test(139) <= "10011011001000000001100001011011"; 
b_test(140) <= "01101110111101001000111110011110"; 
b_test(141) <= "01011000011001101001101011011010"; 
b_test(142) <= "10110100000011010101111001110111"; 
b_test(143) <= "01001001011110101001010110000101"; 
b_test(144) <= "01011011000001011001100100011000"; 
b_test(145) <= "01011111111101100010101101011001"; 
b_test(146) <= "11100001101011101011111111100000"; 
b_test(147) <= "11101011110111111100010101100000"; 
b_test(148) <= "10001010100100001001110010111000"; 
b_test(149) <= "10100100101101110110111110101110"; 
b_test(150) <= "10111000110011010000110101000000"; 
b_test(151) <= "01101011000011111011101110101100"; 
b_test(152) <= "00001010100100100110110000011101"; 
b_test(153) <= "10101000001110001010011110010000"; 
b_test(154) <= "00000001000010010001001010000111"; 
b_test(155) <= "11101100001001011011000110101001"; 
b_test(156) <= "01000111110010101001010000001010"; 
b_test(157) <= "00110010000111010101001101110000"; 
b_test(158) <= "00111110011101010111010101111101"; 
b_test(159) <= "10000100011000111011010000010000"; 
b_test(160) <= "11000110010001101111011011011100"; 
b_test(161) <= "01100000101011101011111011110110"; 
b_test(162) <= "00001011110010110101001010010000"; 
b_test(163) <= "11101100101110000010111010001000"; 
b_test(164) <= "00000001001100110010101001011010"; 
b_test(165) <= "11011110100100010111101001110110"; 
b_test(166) <= "10101100001001100101010101010110"; 
b_test(167) <= "01101101101000110001010101100111"; 
b_test(168) <= "10100110000111111100000011010100"; 
b_test(169) <= "01100100101010000001101000111110"; 
b_test(170) <= "00000000101101101011010001001110"; 
b_test(171) <= "00111110101011101001011110100100"; 
b_test(172) <= "01001000011110101011010010100011"; 
b_test(173) <= "10110000100001101101001011110010"; 
b_test(174) <= "11011110100010110100101100101000"; 
b_test(175) <= "00100110111111001000111011000101"; 
b_test(176) <= "00001001000011010001001010010110"; 
b_test(177) <= "11000001000110001011101100111101"; 
b_test(178) <= "10110110010010100101100110100011"; 
b_test(179) <= "10011001000011101101110011001101"; 
b_test(180) <= "00000100101010010111110111110001"; 
b_test(181) <= "10001001011111110000010010101101"; 
b_test(182) <= "10110011100011000100110101111010"; 
b_test(183) <= "00001000011110110101111001011011"; 
b_test(184) <= "00100111000010111100111101001000"; 
b_test(185) <= "01001111001000100010000010000101"; 
b_test(186) <= "00101111110011010111010010110101"; 
b_test(187) <= "11011100111111101110011111010100"; 
b_test(188) <= "00100010001010011011110111000011"; 
b_test(189) <= "10101101000111001010010101000001"; 
b_test(190) <= "00110000110011110000001110011000"; 
b_test(191) <= "10101011001001010011101100000100"; 
b_test(192) <= "01110000011111110110111010011101"; 
b_test(193) <= "11001110111010110010011001010001"; 
b_test(194) <= "01000011110000100010110001010010"; 
b_test(195) <= "00110100011101001000001111001000"; 
b_test(196) <= "11010100011000001010111011101100"; 
b_test(197) <= "01010111110101110000110001011101"; 
b_test(198) <= "11111010100001011110000000011100"; 
b_test(199) <= "11110011100111000000101000110110"; 
b_test(200) <= "00111010001100101111001110111001"; 
b_test(201) <= "10001001100111101100011011100100"; 

    
    clk <= not clk after 10 ns;
    reset <= '0' after 100 ns;
    
            
--    a_test(0) <= std_logic_vector(to_signed(5, 32));    
--    a_test(1) <= std_logic_vector(to_signed(-2147483647, 32));    
--    a_test(2) <= std_logic_vector(to_signed(5, 32));    
--    a_test(3) <= std_logic_vector(to_signed(-5, 32));    
--    a_test(4) <= std_logic_vector(to_signed(69, 32));    
--    a_test(5) <= std_logic_vector(to_signed(-120, 32));    
--    a_test(6) <= std_logic_vector(to_signed(5, 32));    
--    a_test(7) <= std_logic_vector(to_signed(5, 32));    
--    a_test(8) <= std_logic_vector(to_signed(5, 32));    
--    a_test(9) <= std_logic_vector(to_signed(5, 32));    
--    a_test(10) <= std_logic_vector(to_signed(5, 32));    
    
--    b_test(0) <= std_logic_vector(to_signed(13, 32));
--    b_test(1) <= std_logic_vector(to_signed(-2147483648, 32));    
--    b_test(2) <= std_logic_vector(to_signed(-13, 32));    
--    b_test(3) <= std_logic_vector(to_signed(-13, 32));    
--    b_test(4) <= std_logic_vector(to_signed(13, 32));    
--    b_test(5) <= std_logic_vector(to_signed(-2147483647, 32));    
--    b_test(6) <= std_logic_vector(to_signed(5, 32));    
--    b_test(7) <= std_logic_vector(to_signed(5, 32));    
--    b_test(8) <= std_logic_vector(to_signed(5, 32));    
--    b_test(9) <= std_logic_vector(to_signed(5, 32));    
--    b_test(10) <= std_logic_vector(to_signed(5, 32));  

--    a_sig <= (others => '0') after 0 ns,
--             std_logic_vector(to_signed(5, 32)) after 100 ns, -- 5
--             (others => '0') after 280 ns,
--             std_logic_vector(to_signed(-2147483647, 32)) after 1000 ns, -- -5
--             (others => '0') after 1180 ns,
--             std_logic_vector(to_signed(5, 32)) after 2000 ns, -- 5
--             (others => '0') after 2180 ns,
--             std_logic_vector(to_signed(-5, 32)) after 3000 ns, -- -5
--             (others => '0') after 3180 ns,
--             std_logic_vector(to_unsigned(69, 32)) after 4000 ns,
--             (others => '0') after 4180 ns,
--             std_logic_vector(to_signed(-120, 32)) after 5000 ns,
--             (others => '0') after 5180 ns;
             
--    b_sig <= (others => '0') after 0 ns,
--             std_logic_vector(to_signed(13, 32)) after 100 ns, -- 13
--             (others => '0') after 280 ns,
--             std_logic_vector(to_signed(-2147483648, 32)) after 1000 ns, -- 13
--             (others => '0') after 1180 ns,
--             std_logic_vector(to_signed(-13, 32)) after 2000 ns, -- -13
--             (others => '0') after 2180 ns,
--             std_logic_vector(to_signed(-13, 32)) after 3000 ns, -- -13
--             (others => '0') after 3180 ns,
--             std_logic_vector(to_unsigned(13, 32)) after 4000ns,
--             (others => '0') after 4180 ns,
--             std_logic_vector(to_unsigned(2147483647, 32)) after 5000ns,
--             (others => '0') after 5180 ns;
             
             
    
--    mult_function <= MULT_MULT after 140 ns, -- first
--                     MULT_NOTHING after 260 ns,
--                     MULT_READ_LO after 280 ns,
--                     MULT_NOTHING after 900 ns,
--                     MULT_SIGNED_MULT after 1040 ns, -- second
--                     MULT_NOTHING after 1160 ns,
--                     MULT_READ_LO after 1180 ns,
--                     MULT_NOTHING after 1900 ns,
--                     MULT_SIGNED_MULT after 2040 ns, -- third
--                     MULT_NOTHING after 2160 ns,
--                     MULT_READ_LO after 2180 ns,
--                     MULT_NOTHING after 2900 ns,
--                     MULT_SIGNED_MULT after 3040 ns, -- forth
--                     MULT_NOTHING after 3160 ns,
--                     MULT_READ_LO after 3180 ns,
--                     MULT_NOTHING after 3900 ns,
--                     MULT_MULT after 4040 ns, -- FIFTH
--                     MULT_NOTHING after 4160 ns,
--                     MULT_READ_LO after 4180 ns,
--                     MULT_NOTHING after 4900 ns,
--                     MULT_SIGNED_MULT after 5040 ns, -- SIXTH
--                     MULT_NOTHING after 5160 ns,
--                     MULT_READ_HI after 5180 ns,
--                     MULT_NOTHING after 5900 ns
--                     ;

simul: 
    process 
    begin
    wait for 100 ns;
    for j in 0 to 1 loop
        for index in 0 to 100 loop
            mult_function <= mult_mode(0);
            a_sig <= a_test(index + j * 101);
            b_sig <= b_test(index + j * 101);
            wait for 40 ns;
            mult_function <= mult_mode(4-j);
            wait for 20 ns;
            mult_function <= mult_mode(0);
            a_sig <= (others => '0');
            b_sig <= (others => '0');
            wait for 20 ns;
            mult_function <= mult_mode(1);
            
            wait for 660 ns;
            assert c_res = default_c_res report "Mismatch low reg" severity Failure;
            mult_function <= mult_mode(2);
            wait for 20 ns;
            assert c_res = default_c_res report "Mismatch upper reg" severity Failure;
            wait for 20 ns;
            mult_function <= mult_mode(0);
            
            wait for 220 ns;
            counter <= counter + "00000001";
        end loop;
    end loop; 
    end process;
    
end Behavioral;
