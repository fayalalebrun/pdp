-- Cache controller

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;
use work.cpu_pack.all;

entity cache_cntrl is
    generic (
        -- cpu params
        cpu_addr_width       : integer := 32;
        cpu_data_width       : integer := 32;
        -- cache params       
        cache_way_width      : integer := 1;            -- # blocks per cache line; associativity = 2^cache_way_width
        cache_index_width    : integer := 4;            -- # of cache lines = 2^cache_index_width
        cache_offset_width   : integer := 3;            -- # of bytes per block = 2^cache_offset_width
        cache_address_width  : integer := 16;           -- address width for cacheable range
        cache_replace_policy : string := "RR"           -- replacement policy when cache miss: "RR"
    );               
    port ( 
        aclk                 : in  std_logic;
        aresetn              : in  std_logic;
        cpu_next_address     : in  std_logic_vector(cpu_addr_width-1 downto 0);
        cpu_wr_data          : in  std_logic_vector(cpu_data_width-1 downto 0);
        cpu_wr_byte_en       : in  std_logic_vector(cpu_data_width/8-1 downto 0);
        cpu_rd_data          : out std_logic_vector(cpu_data_width-1 downto 0) := (others=>'0');
        cpu_pause            : out std_logic;
        mem_wr_en            : out std_logic;
        mem_wr_addr          : out std_logic_vector(cpu_addr_width-1 downto 0) := (others=>'0');
        mem_wr_data          : out std_logic_vector(cpu_data_width-1 downto 0) := (others=>'0');
        mem_wr_byte_en       : out std_logic_vector(cpu_data_width/8-1 downto 0) := (others=>'0');
        mem_wr_ready         : in  std_logic;
        mem_wr_valid         : out std_logic;
        mem_rd_en            : out std_logic;
        mem_rd_addr          : out std_logic_vector(cpu_addr_width-1 downto 0) := (others=>'0');
        mem_rd_data          : in  std_logic_vector(cpu_data_width-1 downto 0);
        mem_rd_ready         : out std_logic;
        mem_rd_valid         : in  std_logic;
        mem_cache_line       : out std_logic
    ); 
end cache_cntrl;

architecture Behavioral of cache_cntrl is
    constant tag_width           : integer := cache_address_width-cache_index_width-cache_offset_width;
    constant word_bits_per_line    : integer := cache_offset_width-clogb2(cpu_data_width/8);   
    constant lfsr_width          : integer := 16;
    constant block_ram_depth     : integer := 2**cache_index_width*2**cache_way_width*2**word_bits_per_line;
    type tag_rows_type           is array(0 to 2**cache_index_width-1) of std_logic_vector(2**cache_way_width*tag_width-1 downto 0);
    type valid_rows_type         is array(0 to 2**cache_index_width-1) of std_logic_vector(2**cache_way_width-1 downto 0);
    type memory_access_mode_type is (READ_BLOCK,WRITE_BLOCK,EXCHANGE_BLOCK,WRITE_WORD,READ_WORD);
    signal block_rd_addr            : std_logic_vector((clogb2(block_ram_depth)-1) downto 0);
    signal block_wr_addr            : std_logic_vector((clogb2(block_ram_depth)-1) downto 0);
    signal block_rd_data         : std_logic_vector(cpu_data_width-1 downto 0);
    signal block_wr_data         : std_logic_vector(cpu_data_width-1 downto 0);
    signal block_we              : std_logic_vector(cpu_data_width/8-1 downto 0);
    signal tag_rows              : tag_rows_type := (others=>(others=>'0'));
    signal valid_rows            : valid_rows_type := (others=>(others=>'0'));
    signal cpu_tag               : std_logic_vector(tag_width-1 downto 0) := (others=>'0');
    signal cpu_index             : integer range 0 to 2**cache_index_width-1 := 0;
    signal cpu_offset            : integer range 0 to 2**cache_offset_width-1 := 0;
    signal cpu_way               : integer range 0 to 2**cache_way_width-1 := 0;
    signal cache_hit             : Boolean := False;
    signal cacheable_range       : Boolean := False;
    signal cpu_pause_buff        : std_logic := '0';
    signal replace_way           : integer range 0 to 2**cache_way_width-1 := 0;
    signal replace_write_enables : std_logic_vector(cpu_data_width/8-1 downto 0) := (others=>'0');
    signal replace_write_data    : std_logic_vector(cpu_data_width-1 downto 0) := (others=>'0');
    signal replace_offset        : integer range 0 to 2**cache_offset_width-1 := 0;
    signal mem_prepared          : Boolean := False;
    signal mem_way               : integer range 0 to 2**cache_way_width-1 := 0;
    signal mem_access_needed     : Boolean := False;
    signal mem_access_mode       : memory_access_mode_type := READ_BLOCK;
    signal memory_wr_count       : integer range 0 to 2**word_bits_per_line-1 := 0;
    signal memory_rd_count       : integer range 0 to 2**word_bits_per_line-1 := 0;
    signal mem_wr_en_buff        : std_logic := '0';
    signal mem_rd_en_buff        : std_logic := '0';
    signal mem_wr_valid_buff     : std_logic := '0';
    signal mem_rd_ready_buff     : std_logic := '0';
    signal mem_index             : integer range 0 to 2**cache_index_width-1 := 0;
    signal lfsr                  : std_logic_vector(lfsr_width-1 downto 0) := X"ace1";
    signal axi_finished_read     : Boolean := False;
    signal axi_finished_write    : Boolean := False;
    type cpu_rd_source_type is (MEM, CACHE);
    signal cpu_rd_source: cpu_rd_source_type;

    impure function CacheAddr(
       index: integer;
       way: integer;
       offset: integer) return std_logic_vector is
    begin
       return std_logic_vector(to_unsigned(index*2**word_bits_per_line + way * 2**cache_index_width * 2**word_bits_per_line + offset, block_rd_addr'length));
    end function;

begin

   block_mem: entity work.bytewrite_sdp_ram_wf(byte_wr_ram_wf)
      generic map (
         NB_COL => 4,
         COL_WIDTH => 8,
         SIZE => block_ram_depth
         )
      port map(
         addra => block_wr_addr,
         addrb => block_rd_addr,
         dia => block_wr_data,
         clka => aclk,
         wea => block_we,
         dob => block_rd_data,
         enb => '1'
         );
   
    cpu_pause       <= cpu_pause_buff;
    cpu_tag         <= cpu_next_address(cache_address_width-1 downto cache_offset_width+cache_index_width);
    cpu_index       <= to_integer(unsigned(cpu_next_address(cache_offset_width+cache_index_width-1 downto cache_offset_width)));
    cpu_offset      <= to_integer(unsigned(cpu_next_address(cache_offset_width-1 downto 0)));
    cacheable_range <= True when (cpu_next_address(cpu_addr_width-1 downto cpu_addr_width-4) = "0001" and or_reduce(cpu_next_address(cpu_addr_width-5 downto cache_address_width))='0') else False;
    
    mem_wr_en       <= mem_wr_en_buff;
    mem_wr_valid    <= mem_wr_valid_buff;
    mem_rd_ready    <= mem_rd_ready_buff;
    mem_rd_en       <= mem_rd_en_buff;
    
    process(cpu_index, cpu_tag ,tag_rows ,valid_rows)
        variable cpu_hit_buff : Boolean;
        variable cpu_way_buff : integer range 0 to 2**cache_way_width-1 := 0;
        variable tag_buff     : std_logic_vector(tag_width-1 downto 0);
    begin
        cpu_hit_buff := False;
        cpu_way_buff := 0;
        for each_way in 0 to 2**cache_way_width-1 loop
            tag_buff := tag_rows(cpu_index)((each_way+1)*tag_width-1 downto each_way*tag_width);
            if tag_buff=cpu_tag and valid_rows(cpu_index)(each_way)='1' then
                cpu_hit_buff := True;
                cpu_way_buff := each_way;
                exit;
            end if;
        end loop;
        cache_hit <= cpu_hit_buff;
        cpu_way   <= cpu_way_buff;
    end process; 
    
    generate_replace_policy_RR:
    if cache_replace_policy= "RR" generate
        process (aclk)
            variable lfsr_buff_0 : unsigned(lfsr_width-1 downto 0);
            variable lfsr_buff_1 : unsigned(lfsr_width-1 downto 0);
            variable lfsr_buff_2 : unsigned(lfsr_width-1 downto 0);
        begin
            if rising_edge(aclk) then
                lfsr_buff_0 := unsigned(lfsr);
                lfsr_buff_1 := ((lfsr_buff_0 srl 0) xor (lfsr_buff_0 srl 2) xor (lfsr_buff_0 srl 3) xor (lfsr_buff_0 srl 5)) and to_unsigned(1,lfsr_width);
                lfsr_buff_2 := (lfsr_buff_0 srl 1) or (lfsr_buff_1 sll 15);
                lfsr <= std_logic_vector(lfsr_buff_2);
            end if;
        end process;
        process (lfsr)
        begin
            if cache_way_width/=0 then
                replace_way <= to_integer(unsigned(lfsr(cache_way_width-1 downto 0)));
            else
                replace_way <= 0;
            end if; 
        end process;
    end generate
    generate_replace_policy_RR;

    process (aclk, cpu_rd_source, block_rd_data, mem_rd_data, mem_wr_valid_buff, mem_wr_ready,
             mem_rd_valid, mem_rd_ready_buff, mem_access_mode, cpu_index, cpu_way, cpu_offset,
             mem_access_needed, mem_way, memory_wr_count, mem_index, replace_offset)
        variable mem_wr_handshake         : Boolean;
        variable mem_rd_handshake         : Boolean;
        variable mem_access_exread_block  : Boolean;
        variable mem_access_exwrite_block : Boolean;
        variable mem_access_word          : Boolean;
        variable memory_rd_count_next: integer range 0 to 2**word_bits_per_line-1;
        variable cpu_pause_var : std_logic;
    begin

       mem_wr_handshake         := mem_wr_valid_buff='1' and mem_wr_ready='1';
       mem_rd_handshake         := mem_rd_valid='1' and mem_rd_ready_buff='1';
       mem_access_exread_block  := mem_access_mode=READ_BLOCK or mem_access_mode=EXCHANGE_BLOCK;
       mem_access_exwrite_block := mem_access_mode=WRITE_BLOCK or mem_access_mode=EXCHANGE_BLOCK;
       mem_access_word          := mem_access_mode=READ_WORD or mem_access_mode=WRITE_WORD;

       if cache_hit and not mem_access_needed then
          block_rd_addr <= CacheAddr(cpu_index, cpu_way, cpu_offset/4);
       elsif not mem_access_needed then
          block_rd_addr <= CacheAddr(mem_index, mem_way, 0);
       elsif mem_wr_handshake and mem_access_exwrite_block and memory_wr_count<2**word_bits_per_line-1 then
          block_rd_addr <= CacheAddr(mem_index, mem_way, memory_wr_count);
       else
          block_rd_addr <= CacheAddr(mem_index, mem_way, replace_offset/4);
       end if;

       if mem_access_needed and mem_rd_handshake and mem_access_exread_block then
          block_we <= (others=>'1');
          block_wr_addr <= CacheAddr(mem_index, mem_way, memory_rd_count);
          block_wr_data <= mem_rd_data;
       elsif mem_access_needed and mem_access_exread_block and (memory_rd_count=2**word_bits_per_line-1) then
          block_we <= replace_write_enables;
          block_wr_data <= replace_write_data;
          block_wr_addr <= CacheAddr(mem_index, mem_way, replace_offset/4);
       elsif cache_hit and not mem_access_needed and cpu_pause_buff='0' then
          block_we <= cpu_wr_byte_en;
          block_wr_data <= cpu_wr_data;
          block_wr_addr <= CacheAddr(cpu_index, cpu_way, cpu_offset/4);
       else
          block_we <= (others=>'0');
          block_wr_data <= (others=>'0');
          block_wr_addr <= (others=>'0');
       end if;

       if cacheable_range then
          mem_wr_data <= block_rd_data;
       else
          mem_wr_data <= cpu_wr_data;
       end if;

       case cpu_rd_source is
          when CACHE =>
             cpu_rd_data <= block_rd_data;
          when MEM =>
             cpu_rd_data <= mem_rd_data;
       end case;
       
        if rising_edge(aclk) then
            if aresetn='0' then
                mem_prepared      <= False;
                mem_access_needed <= False;
                mem_wr_en_buff    <= '0';
                mem_wr_valid_buff <= '0';
                mem_rd_ready_buff <= '0';
                mem_rd_en_buff    <= '0';
                cpu_pause_buff    <= '0';
                valid_rows        <= (others=>(others=>'0'));
                cpu_rd_source <= CACHE;
            else
               cpu_pause_var := '0';

                ------------------------------------------
                -- Memory access 
                ------------------------------------------
               if mem_access_needed then
                   cpu_pause_var := '1';
                    if (mem_rd_handshake) then 
                        axi_finished_read <= True;
                    end if;
                    if (mem_wr_handshake) then
                        axi_finished_write <= True;
                    end if;

                    if mem_rd_handshake and mem_access_mode=READ_WORD then
                       cpu_rd_source <= MEM;
                    end if;                   
                    if (mem_access_exwrite_block and memory_wr_count=2**word_bits_per_line-1 and word_bits_per_line/=0) or (mem_access_exwrite_block and mem_wr_handshake and word_bits_per_line=0) or (mem_access_mode=WRITE_WORD and mem_wr_handshake) then
                        mem_wr_en_buff <= '0';
                    end if;
                    if (mem_access_exread_block and memory_rd_count=2**word_bits_per_line-1 and word_bits_per_line/=0) or (mem_access_exread_block and mem_rd_handshake and word_bits_per_line=0) or (mem_access_mode=READ_WORD and mem_rd_handshake) then
                        mem_rd_en_buff <= '0';
                    end if;                   
                    if (mem_access_exwrite_block and memory_wr_count/=2**word_bits_per_line-1 and word_bits_per_line/=0) or (mem_access_exwrite_block and not mem_wr_handshake and not axi_finished_write and word_bits_per_line=0) or (mem_access_mode=WRITE_WORD and not mem_wr_handshake) then
                        mem_wr_valid_buff <= '1';
                    else
                        mem_wr_valid_buff <= '0';
                    end if;
                    if ((mem_access_mode=READ_BLOCK or (mem_access_mode=EXCHANGE_BLOCK and memory_rd_count/=memory_wr_count)) and memory_rd_count/=2**word_bits_per_line-1 and word_bits_per_line/=0) or (mem_access_mode=READ_BLOCK and not mem_rd_handshake and word_bits_per_line=0  and not axi_finished_read) or (mem_access_mode=EXCHANGE_BLOCK and not mem_rd_handshake and word_bits_per_line=0  and not axi_finished_read) or (mem_access_mode=READ_WORD and not mem_rd_handshake) then
                        mem_rd_ready_buff <= '1';
                    else
                        mem_rd_ready_buff <= '0';
                    end if;                    
                    if mem_access_exwrite_block and mem_wr_handshake and memory_wr_count/=2**word_bits_per_line-1 then
                        memory_wr_count <= memory_wr_count+1;
                    end if;
                    if (mem_access_mode=READ_BLOCK or (mem_access_mode=EXCHANGE_BLOCK and memory_rd_count/=memory_wr_count)) and mem_rd_handshake and memory_rd_count/=2**word_bits_per_line-1 then
                        memory_rd_count <= memory_rd_count+1;
                    end if;
                    -- Prepare the read right before the transaction finishes
                    if mem_access_exread_block and (memory_rd_count=2**word_bits_per_line-1-1 or word_bits_per_line=0) then
                       if replace_offset/4 = 2**word_bits_per_line-1 then
                          cpu_rd_source <= MEM;
                       else
                          -- block_rd_addr set combinatorially
                          cpu_rd_source <= CACHE;
                       end if;
                    end if;
                    if ((mem_access_exwrite_block or mem_access_exread_block) and mem_wr_en_buff='0' and mem_rd_en_buff='0') or (mem_access_word and (mem_wr_handshake or mem_rd_handshake)) then
                        mem_access_needed <= False;
                        cpu_pause_var    := '0';
                    end if;
                ------------------------------------------
                -- Address is not in the cacheable range
                ------------------------------------------    
                elsif not cacheable_range then
                    cpu_pause_var    := '1';
                    mem_access_needed <= True;
                    mem_cache_line    <= '0';
                    if or_reduce(cpu_wr_byte_en)='1' then
                        mem_access_mode <= WRITE_WORD;
                        mem_wr_addr     <= cpu_next_address;
                        mem_wr_byte_en  <= cpu_wr_byte_en;
                        memory_wr_count <= 0;
                        mem_wr_en_buff  <= '1';
                    else
                        mem_access_mode <= READ_WORD;
                        mem_rd_addr     <= cpu_next_address;
                        memory_rd_count <= 0;
                        mem_rd_en_buff  <= '1';
                    end if;
                ------------------------------------------
                -- Cache hit
                ------------------------------------------ 
                elsif cache_hit then
                   -- Read address set combinatorially
                   cpu_rd_source <= CACHE;
                ------------------------------------------
                -- Cache miss
                ------------------------------------------ 
                elsif not cache_hit then
                    cpu_pause_var := '1';
                    if not mem_prepared then
                        mem_prepared          <= True;
                        replace_write_enables <= cpu_wr_byte_en;
                        mem_way            <= replace_way;
                        mem_index          <= cpu_index;
                        -- Read address set combinatorially
                    else
                        mem_access_needed  <= True;
                        mem_prepared       <= False;
                        mem_cache_line     <= '1';
                        replace_write_data <= cpu_wr_data;
                        replace_offset     <= cpu_offset;
                        tag_rows(mem_index)((1+mem_way)*tag_width-1 downto mem_way*tag_width) <= cpu_tag;
                        if valid_rows(mem_index)(mem_way)='1' then
                            mem_access_mode <= EXCHANGE_BLOCK;
                            mem_wr_addr(cpu_addr_width-1 downto cpu_addr_width-4)        <= "0001";
                            mem_wr_addr(cpu_addr_width-5 downto cache_address_width)     <= (others => '0');
                            mem_wr_addr(cache_address_width-1 downto cache_offset_width + cache_index_width) <= tag_rows(mem_index)((mem_way+1)*tag_width-1 downto mem_way*tag_width);
                            mem_wr_addr(cache_offset_width + cache_index_width - 1 downto cache_offset_width) <= std_logic_vector(to_unsigned(mem_index,cache_index_width));
                            mem_wr_addr(cache_offset_width-1 downto 0)                   <= (others=>'0');
                            memory_wr_count    <= 0;
                            mem_wr_byte_en     <= (others=>'1');
                            mem_wr_en_buff     <= '1';
                            axi_finished_write <= False;
                        else
                            valid_rows(mem_index)(mem_way) <= '1';
                            mem_access_mode                    <= READ_BLOCK;
                        end if;
                        mem_rd_addr(cpu_addr_width-1 downto cpu_addr_width-4)        <= "0001";
                        mem_rd_addr(cpu_addr_width-5 downto cache_address_width)     <= (others => '0');
                        mem_rd_addr(cache_address_width-1 downto cache_offset_width) <= cpu_tag & std_logic_vector(to_unsigned(mem_index,cache_index_width));
                        mem_rd_addr(cache_offset_width-1 downto 0)                   <= (others=>'0');
                        memory_rd_count   <= 0;
                        mem_rd_en_buff    <= '1';
                        axi_finished_read <= False;
                    end if;
                end if;
               cpu_pause_buff <= cpu_pause_var;
            end if;
        end if;

    end process;


    
end Behavioral;
