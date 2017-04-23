----------------------------------------------------------------------------------


----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity dmnd is
 generic(Y : integer:=0;
     X : integer:=0);
 port( 
    clk, reset: std_logic;
        video_on: in std_logic;
		  off: in std_logic;
        pixel_x,pixel_y: in std_logic_vector(9 downto 0);
			dxl, dxr, dyt, dyb: out unsigned(9 downto 0);
			dmnd_on, drom: out std_logic;
        d_rgb: out std_logic_vector(2 downto 0)
   ); 

end dmnd;

architecture arch of dmnd is
 signal hyreg: unsigned(9 downto 0);
 
 signal refr_tick: std_logic;
   -- x, y coordinates (0,0) to (639,479)
   signal pix_x, pix_y: unsigned(9 downto 0);
   constant MAX_X: integer:=640;
   constant MAX_Y: integer:=480;
 
 constant dmnd_size: integer :=15;
 
 signal dmnd_x_l, dmnd_x_r: unsigned(9 downto 0);
 signal dmnd_y_t, dmnd_y_b: unsigned(9 downto 0);
 signal dmnd_x_reg, dmnd_y_reg: unsigned(9 downto 0);
 
 signal sq_dmnd_on: std_logic;
 
 -------------------------
 ---ROM
 -------------------------
  type rom_type is array (0 to 14)
        of std_logic_vector(0 to 14);
     constant bod: rom_type :=
   (
      "000000010000000", --
      "000000111000000", --
      "000001111100000", --
      "000011111110000", --
      "000111111111000", --
      "001111111111100", --
      "011111111111110", --*
      "111111111111111",  -- ********
      "011111111111110",  -- ********
      "001111111111100",  -- ********
      "000111111111000",  -- ********
      "000011111110000",  -- ********
      "000001111100000",  -- ********
      "000000111000000",  -- ********
      "000000010000000"  -- ********
   );
 
 ------------------------------
 --rom head
 ------------------------------
   signal rom_addr, rom_col: unsigned(3 downto 0);
   signal rom_data: std_logic_vector(14 downto 0);
   signal rom_bit: std_logic;
 --signal to determine if scan coordinates are in round dmnd 
 signal rd_dmnd_on: std_logic;
 signal dmnd_rgb: std_logic_vector(2 downto 0);
 
begin 
 pix_x <= unsigned(pixel_x);
 pix_y <= unsigned(pixel_y);

 
 -- registers
   process (clk,reset)
   begin
--      if reset='1' then
--         dmnd_y_reg <=  to_unsigned(Y, 10); --217
--         dmnd_x_reg <=  to_unsigned(X,10); --312
--		end if;
		if off = '1' then
			dmnd_y_reg <=  to_unsigned(0, 10);
         dmnd_x_reg <=  to_unsigned(0,10);
		else
			dmnd_y_reg <=  to_unsigned(Y, 10); --217
         dmnd_x_reg <=  to_unsigned(X,10); --312
  end if;
   end process;
 
 ----------------------------------------------
   -- boundary
   dmnd_x_l <= dmnd_x_reg;
   dmnd_y_t <= dmnd_y_reg;
   dmnd_x_r <= dmnd_x_l + dmnd_SIZE - 1;
   dmnd_y_b <= dmnd_y_t + dmnd_SIZE - 1;
   -- pixel within dmnd
   sq_dmnd_on <=
      '1' when (dmnd_x_l<=pix_x) and (pix_x<=dmnd_x_r) and
               (dmnd_y_t<=pix_y) and (pix_y<=dmnd_y_b) else
      '0';
 
 
 rom_addr <= pix_y(3 downto 0) - dmnd_y_t(3 downto 0);
   rom_col <= pix_x(3 downto 0) - dmnd_x_l(3 downto 0);
   rom_data <= bod(to_integer(rom_addr));
   rom_bit <= rom_data(to_integer(rom_col));
 

 dmnd_on <= sq_dmnd_on; 
 drom <= rom_bit;
 dxl <= dmnd_x_l;
 dxr <= dmnd_x_r;
 dyt <= dmnd_y_t;
 dyb <= dmnd_y_b;

 d_rgb <= "100";
end arch;