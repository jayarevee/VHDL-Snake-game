library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity rectangle is
   port(
        clk, reset: std_logic;
        btn: std_logic_vector(3 downto 0);
        video_on: in std_logic;
        pixel_x,pixel_y: in std_logic_vector(9 downto 0);
        graph_rgb: out std_logic_vector(2 downto 0)
   );
end rectangle;

architecture arch of rectangle is
   signal refr_tick: std_logic;
   -- x, y coordinates (0,0) to (639,479)
   signal pix_x, pix_y: unsigned(9 downto 0);
   constant MAX_X: integer:=640;
   constant MAX_Y: integer:=480;
  ----------------------------------------
   -- right paddle rec
   ----------------------------------------------
   -- rec top, bottom, left, right boundary
   signal rec_y_b: unsigned(9 downto 0); --:= "0101010100"; --340
   signal rec_y_t: unsigned(9 downto 0); --:= "0010001100"; --140
	signal rec_x_l: unsigned(9 downto 0); --:= "0001111000"; --120
	signal rec_x_r: unsigned(9 downto 0); --:= "0101000000"; --320
   constant rec_Y_SIZE: integer:=72;
   constant rec_X_SIZE: integer:=300;
   -- reg to track left, top boundary
   signal rec_x_reg, rec_x_next: unsigned(9 downto 0);
   signal rec_y_reg, rec_y_next: unsigned(9 downto 0);
	-- reg to track rec speed. signals for the constant vel
   signal x_delta_reg, x_delta_next: unsigned(9 downto 0);
   signal y_delta_reg, y_delta_next: unsigned(9 downto 0);
  
   -- rec moving velocity when the button are pressed
   constant rec_V_P: unsigned(9 downto 0)
            :=to_unsigned(2,10);
   constant rec_V_N: unsigned(9 downto 0)
            :=unsigned(to_signed(-2,10));
   constant rec_V: integer:=4;
   ----------------------------------------------
   -- object output signals
   ----------------------------------------------
   signal wall_on, rec_on, sq_rec_on, rd_rec_on: std_logic;
   signal wall_rgb, rec_rgb : std_logic_vector(2 downto 0);
begin
   -- registers
   process (clk,reset)
   begin
      if reset='1' then
         rec_y_reg <=  "0011011100"; --320 now 220
         rec_x_reg <=  "0010110100"; --240 now 120
      elsif (clk'event and clk='1') then
			y_delta_reg <= y_delta_next;
         rec_y_reg <= rec_y_next;
			x_delta_reg <= x_delta_next;
			rec_x_reg <= rec_x_next;
      end if;
   end process;
   pix_x <= unsigned(pixel_x);
   pix_y <= unsigned(pixel_y);
   -- refr_tick: 1-clock tick asserted at start of v-sync
   --       i.e., when the screen is refreshed (60 Hz)
   refr_tick <= '1' when (pix_y=481) and (pix_x=0) else
                '0';
  
   ----------------------------------------------
   -- right vertical rec
   ----------------------------------------------
   -- boundary
   rec_y_t <= rec_y_reg;
   rec_y_b <= rec_y_t + rec_Y_SIZE - 1;
   rec_x_l <= rec_x_reg; --
   rec_x_r <= rec_x_l + rec_x_SIZE - 1;
   -- pixel within rec
   rec_on <=
      '1' when (rec_X_L<=pix_x) and (pix_x<=rec_X_R) and
               (rec_y_t<=pix_y) and (pix_y<=rec_y_b) else
      '0';

   -- rec rgb output
   rec_rgb <= "100"; --red
   -- new rec y-position
   process(rec_y_reg,rec_y_b,rec_y_t,refr_tick,btn,rec_x_reg,rec_x_r,rec_x_l)
   begin
      rec_y_next <= rec_y_reg; -- no move
		rec_x_next <= rec_x_reg;
      if refr_tick='1' then
         if (y_delta_reg = rec_v_n) and (rec_y_t > rec_v_p) then
			  rec_y_next <= rec_y_reg + y_delta_reg; -- move up
			elsif ((y_delta_reg = rec_v_p) and (rec_y_b < (Max_y - 1 - rec_v_p))) then
				rec_y_next <= rec_y_reg + y_delta_reg; 
			elsif( x_delta_reg = rec_v_p) and (rec_x_r <(MAX_X-1 - rec_v_p)) then
			  rec_x_next <= rec_x_reg + x_delta_reg; -- move right
			elsif(x_delta_reg = rec_v_n) and (rec_x_l > (rec_v_p)) then
			  rec_x_next <= rec_x_reg + x_delta_reg; -- move left
         end if;
      end if;
   end process;
-------------------------------
  
	--speed determines buttons
	process
	begin
	y_delta_next <= y_delta_reg;
	x_delta_next <= x_delta_reg;
	--if(btn(0) = '1') and (rec_y_t < rec_v_n) then
	if(btn(0) = '1') and (rec_y_t < rec_v_n) then --up
		y_delta_next <= rec_v_n;
		x_delta_next <= (others => '0');
	elsif(btn(1) = '1') and (rec_y_b < MAX_Y-1 - rec_v_p) then --down
		y_delta_next <= rec_v_p;
		x_delta_next <= (others => '0');
	elsif(btn(2) = '1') and (rec_x_l > rec_v_p) then --left
		x_delta_next <= rec_v_n;
		y_delta_next <= (others => '0');
	elsif(btn(3) = '1') and (rec_x_r < MAX_X-1 - rec_v_n) then	--right	
		x_delta_next <= rec_v_p;
		y_delta_next <= (others => '0');
	end if;
	end process;
	
	----------------------
--	rec_x_next <= rec_x_reg + x_delta_reg
--                     when refr_tick='1' else
--                  rec_x_reg ;
--   rec_y_next <= rec_y_reg + y_delta_reg
--                     when refr_tick='1' else
--                  rec_y_reg ;
	

   ----------------------------------------------
   -- rgb multiplexing circuit
   ----------------------------------------------
   process(video_on,rec_on, rec_rgb)
   begin
      if video_on='0' then
          graph_rgb <= "000"; --cyan
      else
       if rec_on='1' then
            graph_rgb <= rec_rgb;
       else
            graph_rgb <= "011"; -- cyan
         end if;
      end if;
   end process;
end arch;


