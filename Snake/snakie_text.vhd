
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity snakie_text is
 port(
      clk, reset: in std_logic;
      pixel_x, pixel_y: in std_logic_vector(9 downto 0);
      dig0, dig1: in std_logic_vector(3 downto 0);
      ball: in std_logic_vector(1 downto 0);
      text_on: out std_logic_vector(3 downto 0);
      text_rgb: out std_logic_vector(2 downto 0)
		);
end snakie_text;

architecture Behavioral of snakie_text is
 signal pix_x, pix_y: unsigned(9 downto 0);
   signal rom_addr: std_logic_vector(10 downto 0);
   signal char_addr, char_addr_s, char_addr_l, char_addr_r,
          char_addr_o: std_logic_vector(6 downto 0);
   signal row_addr, row_addr_s, row_addr_l,row_addr_r,
          row_addr_o: std_logic_vector(3 downto 0);
   signal bit_addr, bit_addr_s, bit_addr_l,bit_addr_r,
          bit_addr_o: std_logic_vector(2 downto 0);
   signal font_word: std_logic_vector(7 downto 0);
   signal font_bit: std_logic;
   signal score_on, logo_on, rule_on, over_on: std_logic;
   signal rule_rom_addr: unsigned(5 downto 0);
   type rule_rom_type is array (0 to 69) of
       std_logic_vector (6 downto 0);
   -- rull text ROM definition
   constant RULE_ROM: rule_rom_type :=
   (
      -- row 1
      "1010010", -- R
      "1010101", -- U
      "1001100", -- L
      "1000101", -- E
      "0111010", -- :
      "1010101", -- U
      "1110011", -- s
      "1100101", -- e
      "0000000", --
		"1000010", --B
		"1010100", --T
		"1001110", --N
		"1010101", --U
      "0000000", --
      "1100110", --f
		"1101111", --o
		"1110010", -- r
      "0000000", --
      "1010101", --u
		"1110000", --p
      "0101100", --,
      "0000000", --
      "1000010", --B
		"1010100", --T
		"1001110", --N
		"1010010", --R
      "0000000", -- 
      "1100110", --f
		"1101111", --o
		"1110010", -- r
      "0000000", -- 
      "1010010", --R
		"1101001",--i
		"1100111",--g
		"1101000",--h
		"1110100",--t
      "0101100", --,
      "0000000", --
      "1000010", --B
		"1010100",--T
		"1001110",--N
		"1001100",--L
      "0000000", -- 
       "1100110", --f
		"1101111", --o
		"1110010", -- r
      "0000000", --
      "1001100", --l
		"1100101", --e
		"1100110", --f
		"1110100",--t
      "0000000", -- 
      "1100001", --a
		"1101110",--n
		"1100100",-- d
      "0000000", -- 
      "1000010", -- B
		"1010100", --T
		"1001110", --N
		"1000100",--D
      "0000000", --
      "1100110", --f
		"1101111", --o
		"1110010", -- r
		"0000000",
		"1000100",-- d
		"1101111",-- o
		"1110111",--w
		"1101110",--n
		"0101110" -- .
   );
begin
   pix_x <= unsigned(pixel_x);
   pix_y <= unsigned(pixel_y);
   -- instantiate font rom
   font_unit: entity work.font_rom
      port map(clk=>clk, addr=>rom_addr, data=>font_word);

   ---------------------------------------------
   -- score region
   --  - display two-digit score, ball on top left
   --  - scale to 16-by-32 font
   --  - line 1, 16 chars: "Score:DD Ball:D"
   ---------------------------------------------
   score_on <=
      '1' when pix_y(9 downto 4)=0 and
               pix_x(9 downto 7)=0 else
      '0';
   row_addr_s <= std_logic_vector(pix_y(3 downto 0));
   bit_addr_s <= std_logic_vector(pix_x(2 downto 0));
   with pix_x(6 downto 3) select
     char_addr_s <=
			"0000000" when "0000", -- 
			"0000000" when "0001", --
			"0000000" when "0010", -- 
        "1010011" when "0011", -- S x53
        "1100011" when "0100", -- c x63
        "1101111" when "0101", -- o x6f
        "1110010" when "0110", -- r x72
        "1100101" when "0111", -- e x65
        "0111010" when "1000", -- : x3a
        "011" & dig1 when "1001", -- digit 10
        "011" & dig0 when "1010", -- digit 1
        "0000000" when others;

   ---------------------------------------------
   -- logo region:
   --   - display logo "PONG" on top center
   --   - used as background
   --   - scale to 64-by-128 font
   ---------------------------------------------
--   logo_on <=
--      '1' when pix_y(9 downto 7)=2 and
--         (3<= pix_x(9 downto 6) and pix_x(9 downto 6)<=6) else
--      '0';
--   row_addr_l <= std_logic_vector(pix_y(6 downto 3));
--   bit_addr_l <= std_logic_vector(pix_x(5 downto 3));
--   with pix_x(8 downto 6) select
--     char_addr_l <=
--        "1010000" when "011", -- P x50
--        "1001111" when "100", -- O x4f
--        "1001110" when "101", -- N x4e
--        "1000111" when others; --G x47
--   ---------------------------------------------
--   -- rule region
--   --   - display rule (4-by-16 tiles)on center
--   --   - rule text:
--   --        Rule:
--   --        Use two buttons
--   --        to move paddle
--   --        up and down
--   ---------------------------------------------
  rule_on <= '1' when 0 <= pix_x(9 downto 5) and pix_x(9 downto 5) < 30 and --= "000" and
                       pix_y(9 downto 4)=  29 else --"011111"  else
              '0';
   row_addr_r <= std_logic_vector(pix_y(3 downto 0));
   bit_addr_r <= std_logic_vector(pix_x(2 downto 0));
   --rule_rom_addr <= pix_y(5 downto 3) & pix_x(6 downto 3);
 with pix_x(9 downto 3) select 
   char_addr_r <= 
		"0000000" when "0000000",
		"0000000" when "0000001",
		"0000000" when "0000010",
		"0000000" when "0000011",
		"1010010" when "0000100", -- R
      "1010101" when "0000101", -- U
      "1001100" when "0000110", -- L
      "1000101" when "0000111", -- E
      "0111010" when "0001000", -- :
      "0000000" when "0001001", --
      "1010101" when "0001010", -- U
      "1110011" when "0001011", -- S
      "1100101" when "0001100", -- E
      "0000000" when "0001101", --
      "1000010" when "0001110", -- B
      "1010100" when "0001111", -- T
      "1001110" when "0010000", -- N
      "1010101" when "0010001", -- U
      "0000000" when "0010010", -- 
      "1100110" when "0010011", -- f
      "1101111" when "0010100", -- o
      "1110010" when "0010101", -- r
      "0000000" when "0010110", -- 
      "1110101" when "0010111", -- U
      "1110000" when "0011000", -- p
      "0101100" when "0011001", -- ,
      "0000000" when "0011010", -- 
      "1000010" when "0011011", -- B
      "1010100" when "0011100", -- T
      "1001110" when "0011101", -- N
      "1010010" when "0011110", -- R
      "0000000" when "0011111", -- 
      "1100110" when "0100000", -- f
      "1101111" when "0100001", -- o
      "1110010" when "0100010", -- r
      "0000000" when "0100011", -- 
      "1010010" when "0100100", -- R
      "1101001" when "0100101", -- i
      "1100111" when "0100110", -- g
      "1101000" when "0100111", -- h
      "1110100" when "0101000", -- t
      "0101100" when "0101001", -- ,
      "0000000" when "0101010", -- 
      "1000010" when "0101011", -- B
      "1010100" when "0101100", -- T
      "1001110" when "0101101", -- N
      "1001100" when "0101110", -- L
      "0000000" when "0101111", -- 
      "1100110" when "0110000", -- f
      "1101111" when "0110001", -- o
      "1110010" when "0110010", -- r
      "0000000" when "0110011", -- 
      "1001100" when "0110100", -- L
      "1100101" when "0110101", -- e
      "1100110" when "0110110", -- f
      "1110100" when "0110111", -- t
      "0101100" when "0111000", -- ,
      "0000000" when "0111001", -- 
      "1100001" when "0111010", -- a
      "1101110" when "0111011", -- n
      "1100100" when "0111100", -- d
      "0000000" when "0111101", -- 
      "1000010" when "0111110", -- B
      "1010100" when "0111111", -- T
      "1001110" when "1000000", -- N
      "1000100" when "1000001", -- D
      "0000000" when "1000010", --
      "1100110" when "1000011", -- f
      "1101111" when "1000100",  -- o
      "1110010" when "1000101",  -- r
      "0000000" when "1000110",  -- 
      "1100100" when "1000111",  -- D
      "1101111" when "1001000",  -- o
      "1110111" when "1001001",  -- w
      "1101110" when "1001010", -- n
		"0101110" when "1001011",
      "0000000" when others; 
--   ---------------------------------------------
--   -- you won region
--   --  - display you won " on center
--   --  - scale to 32-by-64 fonts
--   ---------------------------------------------
   over_on <=
      '1' when pix_y(9 downto 6)=3 and
         5<= pix_x(9 downto 5) and pix_x(9 downto 5)<=13 else
      '0';
   row_addr_o <= std_logic_vector(pix_y(5 downto 2));
   bit_addr_o <= std_logic_vector(pix_x(4 downto 2));
   with pix_x(8 downto 5) select
     char_addr_o <=
        "1011001" when "0101", -- Y 
        "1101111" when "0110", -- o 
        "1110101" when "0111", -- u 
        "0000000" when "1000", --   
        "1010111" when "1001", -- W
        "1101111" when "1010", -- o 
        "1101110" when "1011", -- n 
        "0100001" when "1100", -- ! 
        "0000000" when others; --
   ---------------------------------------------
   -- mux for font ROM addresses and rgb
   ---------------------------------------------
   process(score_on,logo_on,rule_on,pix_x,pix_y,font_bit,
           char_addr_s,char_addr_l,char_addr_r,char_addr_o,
           row_addr_s,row_addr_l,row_addr_r,row_addr_o,
           bit_addr_s,bit_addr_l,bit_addr_r,bit_addr_o)
   begin
      text_rgb <= "111";  -- background
      if score_on='1' then
         char_addr <= char_addr_s;
         row_addr <= row_addr_s;
         bit_addr <= bit_addr_s;
         if font_bit='1' then
            text_rgb <= "000";
         end if;
      elsif rule_on='1' then
         char_addr <= char_addr_r;
         row_addr <= row_addr_r;
         bit_addr <= bit_addr_r;
         if font_bit='1' then
            text_rgb <= "000";
         end if;
      else -- game over
         char_addr <= char_addr_o;
         row_addr <= row_addr_o;
         bit_addr <= bit_addr_o;
         if font_bit='1' then
            text_rgb <= "010";
         end if;
      end if;
   end process;
   text_on <= score_on & logo_on & rule_on & over_on;
   ---------------------------------------------
   -- font rom interface
   ---------------------------------------------
   rom_addr <= char_addr & row_addr;
   font_bit <= font_word(to_integer(unsigned(not bit_addr)));

end Behavioral;

