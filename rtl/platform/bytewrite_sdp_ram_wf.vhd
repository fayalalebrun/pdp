-- Simple-Dual-Port BRAM with Byte-wide Write Enable
-- Write First mode
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.cpu_pack.all;

entity bytewrite_sdp_ram_wf is
generic(
SIZE : integer := 2048;
COL_WIDTH : integer := 8;
NB_COL : integer := 4
);

port(
clka : in std_logic;
wea : in std_logic_vector(NB_COL - 1 downto 0);
addra : in std_logic_vector((clogb2(SIZE)-1) downto 0);
dia : in std_logic_vector(NB_COL * COL_WIDTH - 1 downto 0);
enb : in std_logic;
addrb : in std_logic_vector((clogb2(SIZE)-1) downto 0);
dob : out std_logic_vector(NB_COL * COL_WIDTH - 1 downto 0)
);

end bytewrite_sdp_ram_wf;

architecture byte_wr_ram_wf of bytewrite_sdp_ram_wf is
type ram_type is array (0 to SIZE - 1) of std_logic_vector(NB_COL * COL_WIDTH - 1 downto 0);
shared variable RAM : ram_type := (others => (others => '0'));
attribute ram_style: string;
attribute ram_style of RAM : variable is "block";

begin

------- Port A -------
process(clka)
begin
   if rising_edge(clka) then
      if enb = '1' then
         for i in 0 to NB_COL - 1 loop
            if wea(i) = '1' then
               RAM(conv_integer(addra))((i + 1) * COL_WIDTH - 1 downto i * COL_WIDTH) := dia((i + 1) * COL_WIDTH - 1 downto i * COL_WIDTH);
            end if;
         end loop;
      end if;
   end if;

end process;

------- Port B -------
process(clka)
begin
   if rising_edge(clka) then
      if enb = '1' then
         dob <= RAM(conv_integer(addrb));
      end if;
   end if;
end process;
end byte_wr_ram_wf;
