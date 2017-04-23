
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity snakie is
port(  clk, reset: std_logic;
        btn: std_logic_vector(3 downto 0);
        video_on: in std_logic;
		  sw1,sw2,blank: in std_logic;
        pixel_x,pixel_y: in std_logic_vector(9 downto 0);
        graph_rgb: out std_logic_vector(2 downto 0);
		  hitter,finish: out std_logic;
		  mode: out std_logic_vector(1 downto 0)
);

end snakie;

architecture Behavioral of snakie is
	signal refr_tick: std_logic;
   -- x, y coordinates (0,0) to (639,479)
   signal pix_x, pix_y: unsigned(9 downto 0);
   constant MAX_X: integer:=640;
   constant MAX_Y: integer:=480;

	----------------------------------------------
   -- square ball
   ----------------------------------------------
   constant BALL_SIZE: integer:=15; -- 15
   -- ball left, right boundary
   signal body1_x_l, body1_x_r: unsigned(9 downto 0);
   signal body2_x_l, body2_x_r: unsigned(9 downto 0);
   signal head_x_l, head_x_r: unsigned(9 downto 0);
   -- ball top, bottom boundary
   signal body1_y_t, body1_y_b: unsigned(9 downto 0);
   signal body2_y_t, body2_y_b: unsigned(9 downto 0);
   signal head_y_t, head_y_b: unsigned(9 downto 0);
   -- reg to track left, top boundary
   signal body1_x_reg, body1_x_next: unsigned(9 downto 0);
   signal body1_y_reg, body1_y_next: unsigned(9 downto 0);
   signal body2_y_reg, body2_y_next: unsigned(9 downto 0);
   signal body2_x_reg, body2_x_next: unsigned(9 downto 0);
   signal head_y_reg, head_y_next: unsigned(9 downto 0);
   signal head_x_reg, head_x_next: unsigned(9 downto 0);
   -- reg to track ball speed
   signal x_delta_reg, x_delta_next: unsigned(9 downto 0);
   signal y_delta_reg, y_delta_next: unsigned(9 downto 0);
	-----------------------------------
	--boundary limits
	signal L_y_b,R_y_b,T_y_b,B_y_b: unsigned(9 downto 0);
   signal L_y_t,R_y_t,T_y_t,B_y_t: unsigned(9 downto 0);
	signal L_x_l,R_x_l,T_x_l,B_x_l: unsigned(9 downto 0);
	signal L_x_r,R_x_r,T_x_r,B_x_r: unsigned(9 downto 0);
---loading
	signal Load_y_b: unsigned(9 downto 0);
   signal Load_y_t: unsigned(9 downto 0);
	signal Load_x_l: unsigned(9 downto 0);
	signal Load_x_r: unsigned(9 downto 0);
	
	signal L1_y_b,R1_y_b,T1_y_b,B1_y_b: unsigned(9 downto 0);
   signal L1_y_t,R1_y_t,T1_y_t,B1_y_t: unsigned(9 downto 0);
	signal L1_x_l,R1_x_l,T1_x_l,B1_x_l: unsigned(9 downto 0);
	signal L1_x_r,R1_x_r,T1_x_r,B1_x_r: unsigned(9 downto 0);
	
	signal L1_y_reg, L1_y_next, L1_x_reg, L1_x_next: unsigned(9 downto 0);
	signal R1_y_reg, R1_y_next, R1_x_reg, R1_x_next: unsigned(9 downto 0);
	signal T1_y_reg, T1_y_next, T1_x_reg, T1_x_next: unsigned(9 downto 0);
	signal B1_y_reg, B1_y_next, B1_x_reg, B1_x_next: unsigned(9 downto 0);
------
	signal L_y_reg, L_y_next, L_x_reg, L_x_next: unsigned(9 downto 0);
	signal R_y_reg, R_y_next, R_x_reg, R_x_next: unsigned(9 downto 0);
	signal T_y_reg, T_y_next, T_x_reg, T_x_next: unsigned(9 downto 0);
	signal B_y_reg, B_y_next, B_x_reg, B_x_next: unsigned(9 downto 0);
	signal outmode:std_logic_vector(1 downto 0);
	signal Load_y_reg, Load_y_next, Load_x_reg, Load_x_next: unsigned(9 downto 0);
	-- left/right bound
	constant LR_Y_SIZE: integer:=20;
   constant LR_X_SIZE: integer:=2;
	constant loading_y: integer:=16;
	signal Loading_x: integer:= 0;
	--top/bot bound
	constant TB_Y_SIZE: integer:=2;
   constant TB_X_SIZE: integer:=150;
	type rom_type is array (0 to 14)
        of std_logic_vector(0 to 14);
   -- ROM definition
   constant BALL_BODY: rom_type :=
   (
      "000011111110000", --   ******
      "001111111111100", --   ******
      "011111111111110", --  *******
      "011111111111110", -- ********
      "111111111111111", -- ********
      "111111111111111", -- ********
      "111111111111111", -- ********
      "111111111111111", -- ********
      "111111111111111", -- ********
      "111111111111111", -- ********
      "111111111111111", -- ********
      "011111111111110", -- ********
      "011111111111110", -- ********
      "001111111111100", -- ********
      "000011111110000"  -- ********
   );
	constant BALL_HEAD: rom_type :=
   (
      "000011111110000", --   ******
      "001000000000100", --   ******
      "010000000000010", --  *******
      "010000000000010", -- ********
      "100000000000001", -- ********
      "100000000000001", -- ********
      "100000000000001", -- ********
      "100000000000001", -- ********
      "100000000000001", -- ********
      "100000000000001", -- ********
      "100000000000001", -- ********
      "010000000000010", -- ********
      "010000000000010", -- ********
      "001000000000100", -- ********
      "000011111110000"  -- ********
   );
	 
   signal rom_addr1, rom_col1,rom_addr2, rom_col2,rom_addr3, rom_col3: unsigned(3 downto 0);
   signal rom_data1,rom_data2,rom_data3: std_logic_vector(14 downto 0);
   signal rom_bit1,rom_bit2,rom_bit3: std_logic;
	signal Lbar_on,Rbar_on, Tbar_on,Bbar_on,sq_head_on, rd_head_on,sq_body1_on, rd_body1_on,sq_body2_on, rd_body2_on: std_logic;
	signal head_rgb,body_rgb,bar_rgb: std_logic_vector(2 downto 0);
	signal  Loadbar_on,L1bar_on,R1bar_on, T1bar_on,B1bar_on:std_logic;
	--diamondz
	signal dmnd_rgb1,dmnd_rgb2,dmnd_rgb3 : std_logic_vector(2 downto 0);
	signal dmnd_rgb4,dmnd_rgb5,dmnd_rgb6,dmnd_rgb7,dmnd_rgb8: std_logic_vector(2 downto 0);
	signal D_on1,D_on2,D_on3,D_on4,D_on5,D_on6,D_on7,D_on8: std_logic;

	 signal de:std_logic_vector(7 downto 0);
	 signal dyt1,dyt2,dyt3,dyt4,dyt5,dyt6,dyt7,dyt8: unsigned(9 downto 0);
	 signal dyb1,dyb2,dyb3,dyb4,dyb5,dyb6,dyb7,dyb8: unsigned(9 downto 0);
	 signal dxr1,dxr2,dxr3,dxr4,dxr5,dxr6,dxr7,dxr8: unsigned(9 downto 0);
	 signal dxl1,dxl2,dxl3,dxl4,dxl5,dxl6,dxl7,dxl8: unsigned(9 downto 0);
	 signal drom1,drom2,drom3,drom4,drom5,drom6,drom7,drom8: std_logic;
	 signal drd1,drd2,drd3,drd4,drd5,drd6,drd7,drd8: std_logic;
	 signal dc1,dc2,dc3,dc4,dc5,dc6,dc7,dc8: std_logic_vector(1 downto 0);
	 shared variable dy1,dx1,dy2,dx2,dy3,dx3,dy4,dx4,dy5,dx5,dy6,dx6,dy7,dx7,dy8,dx8: integer;
	signal hit:std_logic;
	signal off:std_logic_vector(7 downto 0);
	 -- head moving velocity when the button are pressed
   shared variable S_V_P: unsigned(9 downto 0)
            :=to_unsigned(1,10);
   shared variable S_V_N: unsigned(9 downto 0)
            :=unsigned(to_signed(-1,10));
	signal count: unsigned(3 downto 0);
	signal flagcount: std_logic;
begin

 -- registers
   process (clk,reset)
   begin
      if reset='1' then
         --bar_y_reg <= (others=>'0');
         head_y_reg <= "0011101000";--232
         head_x_reg <= "0100110110"; --310
			body1_x_reg <= "0100110110";
			body1_y_reg <= "0011110111";--247
			body2_x_reg <=	"0100110110";
			body2_y_reg <= "0100000110";--262
			L_x_reg <= "0000010100";
			L_y_reg <= "0000010100";
			R_x_reg <= "1001101011";
			R_y_reg <= "0000010100";
			T_x_reg <= "0000010100";
			T_y_reg <= "0000010100";
			B_x_reg <= "0000010100";
			B_y_reg <= "0111001011";
			L1_x_reg <= "0011110101";--245
			L1_y_reg <= "0100101100";--300
			R1_x_reg <= "0110001011";--395
			R1_y_reg <= "0100101100";--300
			T1_x_reg <= "0011110101";--245
			T1_y_reg <= "0100101100";--300
			B1_x_reg <= "0011110101";--245
			B1_y_reg <= "0101000000";--320
			
			Load_y_reg <= "0100101110";--302
			Load_x_reg <= "0011110111";--247
         x_delta_reg <= ("0000000000");
         y_delta_reg <= ("0000000000");
      elsif (clk'event and clk='1') then
         head_x_reg <= head_x_next;
         head_y_reg <= head_y_next;
			body1_x_reg <= body1_x_next;
         body1_y_reg <= body1_y_next;
			body2_x_reg <= body2_x_next;
         body2_y_reg <= body2_y_next;
         x_delta_reg <= x_delta_next;
         y_delta_reg <= y_delta_next;
			mode <= outmode;
			hitter <= hit;
			finish <= flagcount;
      end if;
   end process;
   pix_x <= unsigned(pixel_x);
   pix_y <= unsigned(pixel_y);
   -- refr_tick: 1-clock tick asserted at start of v-sync
   --       i.e., when the screen is refreshed (60 Hz)
   refr_tick <= '1' when (pix_y=481) and (pix_x=0) else
                '0';
					 
	 -------------------------------------------------load				 
	Load_y_t <= Load_y_reg;
	Load_x_l <= Load_x_reg; 
   Load_y_b <= Load_y_t + loading_y - 1;
   Load_x_r <= Load_x_l + Loading_x - 1;
   -- pixel within bar
   Loadbar_on <=
      '1' when (Load_X_L<=pix_x) and (pix_x<=Load_X_R) and
               (Load_y_t<=pix_y) and (pix_y<=Load_y_b) else
      '0';
-------------------------------------------------load left bound				 
	L1_y_t <= L1_y_reg;
	L1_x_l <= L1_x_reg; 
   L1_y_b <= L1_y_t + LR_Y_SIZE - 1;
   L1_x_r <= L1_x_l + LR_X_SIZE - 1;
   -- pixel within bar
   L1bar_on <=
      '1' when (L1_X_L<=pix_x) and (pix_x<=L1_X_R) and
               (L1_y_t<=pix_y) and (pix_y<=L1_y_b) else
      '0';

   -- bar rgb output
   bar_rgb <= "000"; --black				 
	-------------------------------------------------load	right bound			 
	R1_y_t <= R1_y_reg;
	R1_x_l <= R1_x_reg; 
   R1_y_b <= R1_y_t + LR_Y_SIZE - 1;
   R1_x_r <= R1_x_l + LR_X_SIZE - 1;
   -- pixel within bar
   R1bar_on <=
      '1' when (R1_X_L<=pix_x) and (pix_x<=R1_X_R) and
               (R1_y_t<=pix_y) and (pix_y<=R1_y_b) else
      '0';

   -- bar rgb output
   bar_rgb <= "000"; --black				 
	-------------------------------------------------load	top bound			 
	T1_y_t <= T1_y_reg;
	T1_x_l <= T1_x_reg; 
   T1_y_b <= T1_y_t + TB_Y_SIZE - 1;
   T1_x_r <= T1_x_l + TB_X_SIZE - 1;
   -- pixel within bar
   T1bar_on <=
      '1' when (T1_X_L<=pix_x) and (pix_x<=T1_X_R) and
               (T1_y_t<=pix_y) and (pix_y<=T1_y_b) else
      '0';

   -- bar rgb output
   bar_rgb <= "000"; --black				 
	-------------------------------------------------load	bot bound			 
	B1_y_t <= B1_y_reg;
	B1_x_l <= B1_x_reg; 
   B1_y_b <= B1_y_t + TB_Y_SIZE - 1;
   B1_x_r <= B1_x_l + TB_X_SIZE - 1;
   -- pixel within bar
   B1bar_on <=
      '1' when (B1_X_L<=pix_x) and (pix_x<=B1_X_R) and
               (B1_y_t<=pix_y) and (pix_y<=B1_y_b) else
      '0';

   -- bar rgb output
   bar_rgb <= "000"; --black	
	-------------------------------------------------left bound				 
	L_y_t <= L_y_reg;
	L_x_l <= L_x_reg; 
   L_y_b <= L_y_t + LR_Y_SIZE - 1;
   L_x_r <= L_x_l + LR_X_SIZE - 1;
   -- pixel within bar
   Lbar_on <=
      '1' when (L_X_L<=pix_x) and (pix_x<=L_X_R) and
               (L_y_t<=pix_y) and (pix_y<=L_y_b) else
      '0';

   -- bar rgb output
   bar_rgb <= "000"; --black				 
	-------------------------------------------------	right bound			 
	R_y_t <= R_y_reg;
	R_x_l <= R_x_reg; 
   R_y_b <= R_y_t + LR_Y_SIZE - 1;
   R_x_r <= R_x_l + LR_X_SIZE - 1;
   -- pixel within bar
   Rbar_on <=
      '1' when (R_X_L<=pix_x) and (pix_x<=R_X_R) and
               (R_y_t<=pix_y) and (pix_y<=R_y_b) else
      '0';

   -- bar rgb output
   bar_rgb <= "000"; --black				 
	-------------------------------------------------	top bound			 
	T_y_t <= T_y_reg;
	T_x_l <= T_x_reg; 
   T_y_b <= T_y_t + TB_Y_SIZE - 1;
   T_x_r <= T_x_l + TB_X_SIZE - 1;
   -- pixel within bar
   Tbar_on <=
      '1' when (T_X_L<=pix_x) and (pix_x<=T_X_R) and
               (T_y_t<=pix_y) and (pix_y<=T_y_b) else
      '0';

   -- bar rgb output
   bar_rgb <= "000"; --black				 
	-------------------------------------------------	top bound			 
	B_y_t <= B_y_reg;
	B_x_l <= B_x_reg; 
   B_y_b <= B_y_t + TB_Y_SIZE - 1;
   B_x_r <= B_x_l + TB_X_SIZE - 1;
   -- pixel within bar
   Bbar_on <=
      '1' when (B_X_L<=pix_x) and (pix_x<=B_X_R) and
               (B_y_t<=pix_y) and (pix_y<=B_y_b) else
      '0';

   -- bar rgb output
   bar_rgb <= "000"; --black				 
	----------------------------------------------
   -- head ball
   ----------------------------------------------
   -- boundary
   head_x_l <= head_x_reg;
   head_y_t <= head_y_reg;
   head_x_r <= head_x_l + BALL_SIZE - 1;
   head_y_b <= head_y_t + BALL_SIZE - 1;
   -- pixel within ball
   sq_head_on <=
      '1' when (head_x_l<=pix_x) and (pix_x<=head_x_r) and
               (head_y_t<=pix_y) and (pix_y<=head_y_b) else
      '0';
   -- map current pixel location to ROM addr/col
   rom_addr1 <= pix_y(3 downto 0) - head_y_t(3 downto 0);
   rom_col1 <= pix_x(3 downto 0) - head_x_l(3 downto 0);
   rom_data1 <= BALL_HEAD(to_integer(rom_addr1));
   rom_bit1 <= rom_data1(to_integer(rom_col1));
   -- pixel within ball
   rd_head_on <=
      '1' when (sq_head_on='1') and (rom_bit1='1') else
      '0';
   -- ball rgb output
   head_rgb <= "100";   -- red

	------------------------------------
	--body ball 1
	------------------------------------
	  -- boundary
   body1_x_l <= body1_x_reg;
   body1_y_t <= body1_y_reg;
   body1_x_r <= body1_x_l + BALL_SIZE - 1;
   body1_y_b <= body1_y_t + BALL_SIZE - 1;
   -- pixel within ball
   sq_body1_on <=
      '1' when (body1_x_l<=pix_x) and (pix_x<=body1_x_r) and
               (body1_y_t<=pix_y) and (pix_y<=body1_y_b) else
      '0';
   -- map current pixel location to ROM addr/col
   rom_addr2 <= pix_y(3 downto 0) - body1_y_t(3 downto 0);
   rom_col2 <= pix_x(3 downto 0) - body1_x_l(3 downto 0);
   rom_data2 <= BALL_BODY(to_integer(rom_addr2));
   rom_bit2 <= rom_data2(to_integer(rom_col2));
   -- pixel within ball
   rd_body1_on <=
      '1' when (sq_body1_on='1') and (rom_bit2='1') else
      '0';
   -- ball rgb output
   body_rgb <= "000";   -- black

	------------------------------------
	--body ball 2
	------------------------------------
	   ---boundary
   body2_x_l <= body2_x_reg;
   body2_y_t <= body2_y_reg;
   body2_x_r <= body2_x_l + BALL_SIZE - 1;
   body2_y_b <= body2_y_t + BALL_SIZE - 1;
--    pixel within ball
   sq_body2_on <=
      '1' when (body2_x_l<=pix_x) and (pix_x<=body2_x_r) and
               (body2_y_t<=pix_y) and (pix_y<=body2_y_b) else
      '0';
---    map current pixel location to ROM addr/col
   rom_addr3 <= pix_y(3 downto 0) - body2_y_t(3 downto 0);
   rom_col3 <= pix_x(3 downto 0) - body2_x_l(3 downto 0);
   rom_data3 <= BALL_BODY(to_integer(rom_addr3));
   rom_bit3 <= rom_data3(to_integer(rom_col3));
    --pixel within ball
   rd_body2_on <=
      '1' when (sq_body2_on='1') and (rom_bit3='1') else
      '0';
    --ball rgb output
   body_rgb <= "000";   -- black

	------------------------------
	--movement
	  
	
	   process(head_y_reg,head_y_b,head_y_t,refr_tick,btn,head_x_reg,head_x_r,head_x_l)
   begin
      head_y_next <= head_y_reg; -- no move
		head_x_next <= head_x_reg;
		body1_y_next <= body1_y_reg; -- no move
		body1_x_next <= body1_x_reg;
		body2_y_next <= body2_y_reg; -- no move
		body2_x_next <= body2_x_reg;
      if refr_tick='1' then
			outmode<="00";
         if (y_delta_reg = S_V_N) and (head_y_t > S_V_P+T_Y_B) then
				if(head_x_reg /= body1_x_reg) then
					head_x_next <= body1_x_reg;
					head_y_next <= body1_y_reg - 15;
				elsif(body2_x_reg /= body1_x_reg) then
					body2_x_next <= body1_x_reg;
					body2_y_next <= body1_y_reg + 15;
				else 
					head_y_next <= head_y_reg + y_delta_reg; -- move up
					body1_y_next <= body1_y_reg  +  y_delta_reg;
					body2_y_next <= body2_y_reg  +  y_delta_reg;
				end if;
			elsif ((y_delta_reg = S_V_P) and (head_y_b < (B_Y_T + S_V_P))) then
				if(head_x_reg /= body1_x_reg) then
					head_x_next <= body1_x_reg;
					head_y_next <= body1_y_reg + 15;
				elsif(body2_x_reg /= body1_x_reg) then
					body2_x_next <= body1_x_reg;
					body2_y_next <= body1_y_reg - 15;
				else 
					head_y_next <= head_y_reg + y_delta_reg; -- move down
					body1_y_next <= body1_y_reg  +  y_delta_reg;
					body2_y_next <= body2_y_reg  +  y_delta_reg;
				end if;
			elsif( x_delta_reg = S_V_P) and (head_x_r <(R_X_L + S_V_N)) then
				if(head_y_reg /= body1_y_reg) then
					head_y_next <= body1_y_reg;
					head_x_next <= body1_x_reg + 15;
				elsif (body2_y_reg /= body1_y_reg) then
					body2_y_next <= body1_y_reg;
					body2_x_next <= body1_x_reg -15;
				else
					head_x_next <= head_x_reg + x_delta_reg; -- move right
					body1_x_next <= body1_x_reg  +  x_delta_reg;
					body2_x_next <= body2_x_reg  +  x_delta_reg;
				end if;
			elsif(x_delta_reg = S_V_N) and (head_x_l > (S_V_P+L_X_R)) then
				if(head_y_reg /= body1_y_reg) then
					head_y_next <= body1_y_reg;
					head_x_next <= body1_x_reg - 15;
				elsif (body2_y_reg /= body1_y_reg) then
					body2_y_next <= body1_y_reg;
					body2_x_next <= body1_x_reg + 15;
				else
					head_x_next <= head_x_reg + x_delta_reg; -- move left
					body1_x_next <= body1_x_reg  +  x_delta_reg;
					body2_x_next <= body2_x_reg  +  x_delta_reg;
				end if;
			else
				head_y_next <= "0011101000";--232 reset
				head_x_next <= "0100110110"; --310
				body1_x_next <= "0100110110";
				body1_y_next <= "0011110111";--247
				body2_x_next <=	"0100110110";
				body2_y_next <= "0100000110";--262
				outmode(0)<='1';
				dc1 <= "00"; dc2 <="00"; dc3 <= "00"; dc4 <= "00"; dc5 <="00";
				dc6 <= "00"; dc7 <= "00"; dc8 <= "00"; 
				off <= (others =>'0');
				count <= "0000";
         end if;
			if rising_edge(clk) then
				if de(0) = '1' then dc1 <= "01"; off(0) <= '1';outmode(1) <= '1'; count <= count +"0001";loading_x <= loading_x + 10; else outmode(1) <= '0';  end if;
				if de(1) = '1' then dc2 <= "01"; off(1) <= '1';outmode(1) <= '1'; count <= count +"0001";loading_x <= loading_x + 10;else outmode(1) <= '0'; end if;
				if de(2) = '1' then dc3 <= "01";  off(2) <= '1';outmode(1) <= '1'; count <= count +"0001";loading_x <= loading_x + 10;loading_x <= loading_x + 10;else outmode(1) <= '0'; end if;
				if de(3) = '1' then dc4 <= "01";  off(3) <= '1';outmode(1) <= '1';count <= count +"0001"; loading_x <= loading_x + 10;else outmode(1) <= '0'; end if;
				if de(4) = '1' then dc5 <= "01";  off(4) <= '1';outmode(1) <= '1';count <= count +"0001"; loading_x <= loading_x + 10;else outmode(1) <= '0'; end if;
				if de(5) = '1' then dc6 <= "01"; off(5) <= '1';outmode(1) <= '1'; count <= count +"0001";loading_x <= loading_x + 10;else outmode(1) <= '0';end if;
				if de(6) = '1' then dc7 <= "01"; off(6) <= '1';outmode(1) <= '1'; count <= count +"0001";loading_x <= loading_x + 10;else outmode(1) <= '0'; end if;
				if de(7) = '1' then dc8 <= "01";  off(7) <= '1'; outmode(1) <= '1'; count <= count +"0001";loading_x <= loading_x + 10;else outmode(1) <= '0';end if;
			end if;
			if count = "1000" then
				flagcount <= '1';
			else
				flagcount <= '0';
			end if;
      end if;
   end process;
-------------------------------
  
	--speed determines buttons
	process
	begin
	y_delta_next <= y_delta_reg;
	x_delta_next <= x_delta_reg;
	if(btn(0) = '1') and (y_delta_reg /= S_V_P) then --and (head_y_reg < body2_y_reg) then --up
		y_delta_next <= S_V_N;
		x_delta_next <= (others => '0');
	elsif(btn(1) = '1') and (y_delta_reg /= S_V_N) and (head_y_reg >= body2_y_reg)  then --down
		y_delta_next <= S_V_P;
		x_delta_next <= (others => '0');
	elsif(btn(2) = '1') and (x_delta_reg /= S_V_P) then --and (head_x_reg < body2_x_reg) then --left
		x_delta_next <= S_V_N;
		y_delta_next <= (others => '0');
	elsif(btn(3) = '1') and (x_delta_reg /= S_V_N) then --and (head_x_reg > body2_x_reg) then	--right	
		x_delta_next <= S_V_P;
		y_delta_next <= (others => '0');
	elsif (head_y_t <= S_V_P+T_Y_B) or (head_y_b >= (459 - 1 - S_V_P)) or (head_x_r >= (619-1 - S_V_P)) or (head_x_l <= (S_V_P+L_X_R)) then
		x_delta_next <= (others => '0');
		y_delta_next <= (others => '0');
	end if;
	end process;
	
	
-- ----------------------
-- --Diamonds
-------------------------
 
	 D1: entity work.dmnd
		generic map(Y => 120, X => 220)
		port map(clk => clk,
			reset => reset, 
			video_on => video_on,
			pixel_x => pixel_x,
			pixel_y => pixel_y,
			dmnd_on => d_on1,
			drom => drom1,
			dxr => dxr1,
			dxl => dxl1,
			dyt => dyt1,
			dyb => dyb1,
			d_rgb => dmnd_rgb1,
			off => off(0)
			);
	 
	 D2: entity work.dmnd
		generic map(Y => 200, X => 100)
		port map(clk => clk,
			reset => reset, 
			video_on => video_on,
			pixel_x => pixel_x,
			pixel_y => pixel_y,
			dmnd_on => d_on2,
			drom => drom2,
			dxr => dxr2,
			dxl => dxl2, 
			dyt => dyt2,
			dyb => dyb2,
			d_rgb => dmnd_rgb2,
			off => off(1) );
			
	 D3: entity work.dmnd
		generic map(Y => 300, X => 100)
		port map(clk => clk,
			reset => reset, 
			video_on => video_on,
			pixel_x => pixel_x,
			pixel_y => pixel_y,
			drom => drom3,
			dxr => dxr3,
			dxl => dxl3,
			dyt => dyt3,
			dyb => dyb3,
			dmnd_on => d_on3,
			d_rgb => dmnd_rgb3,
			off => off(2) );
			
	 D4: entity work.dmnd
		generic map(Y => 400, X => 220)
		port map(clk => clk,
			reset => reset, 
			video_on => video_on,
			pixel_x => pixel_x,
			pixel_y => pixel_y,
			dxr => dxr4,
			dxl => dxl4,
			dyt => dyt4,
			dyb => dyb4,
			dmnd_on => d_on4,
			drom => drom4,
			d_rgb => dmnd_rgb4,
			off => off(3) );
			
	 D5: entity work.dmnd
		generic map(Y => 120, X => 420)
		port map(clk => clk,
			reset => reset, 
			video_on => video_on,
			pixel_x => pixel_x,
			pixel_y => pixel_y,
			dmnd_on => d_on5,
			drom => drom5,
			dxr => dxr5,
			dxl => dxl5,
			dyt => dyt5,
			dyb => dyb5,
			d_rgb => dmnd_rgb5,
			off => off(4) );
	 
	 D6: entity work.dmnd
		generic map(Y => 200, X => 500)
		port map(clk => clk,
			reset => reset, 
			video_on => video_on,
			pixel_x => pixel_x,
			pixel_y => pixel_y,
			dmnd_on => d_on6,
			drom => drom6,
			dxr => dxr6,
			dxl => dxl6,
			dyt => dyt6,
			dyb => dyb6,
			d_rgb => dmnd_rgb6,
			off => off(5) );
	 D7: entity work.dmnd
		generic map(Y => 300, X => 500)
		port map(clk => clk,
			reset => reset, 
			video_on => video_on,
			pixel_x => pixel_x,
			pixel_y => pixel_y,
			dmnd_on => d_on7,
			drom => drom7,
			dyt => dyt7,
			dyb => dyb7,
			dxr => dxr7,
			dxl => dxl7,
			d_rgb => dmnd_rgb7,
			off => off(6) );
			
	 D8: entity work.dmnd
		generic map(Y => 400, X => 420)
		port map(clk => clk,
			reset => reset, 
			video_on => video_on,
			pixel_x => pixel_x,
			pixel_y => pixel_y,
			dmnd_on => d_on8,
			drom => drom8,
			dyt => dyt8,
			dyb => dyb8,
			dxr => dxr8,
			dxl => dxl8,
			d_rgb => dmnd_rgb8,
			off => off(7) );
						
	process----snake speed toggle
		begin
			if sw1 = '1' and sw2 = '0' then
				S_V_P:=to_unsigned(4,10);
				S_V_N:=to_unsigned(-4,10);
			elsif sw2 = '1' and sw1 = '0' then 
				S_V_P:=to_unsigned(8,10);
				S_V_N:=to_unsigned(-8,10);
			else 
				S_V_P:=to_unsigned(1,10);
				S_V_N:=to_unsigned(-1,10);
			end if;
		end process;
	
	------------------------------------------------
--Diamond control signaaal
----------------------------------------------
	drd1 <= '1' when (d_on1='1') and (drom1='1') and (de(0) = '0') and (dc1 = "00")
      else
      '0'; 
	 de(0) <= '1' when (head_y_t <= dyb1) and (dyt1 <= head_y_b) 
	  and (head_x_l <= dxr1) and (dxl1 <= head_x_r) else
	  '0';

	 --
	 drd2 <='1' when (d_on2='1') and (drom2='1') and (de(1) = '0') and (dc2 = "00")
			else
			'0'; 
	 de(1) <= '1' when (head_y_t <= dyb2) and (dyt2 <= head_y_b) 
	  and (head_x_l <= dxr2) and (dxl2 <= head_x_r) else
	  '0';
	 --- 
	 drd3 <= '1' when (d_on3='1') and (drom3='1') and (de(2) = '0') and (dc3 = "00")
			else
			'0'; 
	 de(2) <= '1' when (head_y_t <= dyb3) and (dyt3 <= head_y_b) 
	  and (head_x_l <= dxr3) and (dxl3 <= head_x_r) else
	  '0';

	 --
	 drd4 <= '1' when (d_on4='1') and (drom4='1') and (de(3) = '0') and (dc4 = "00")
			else
			'0'; 
	 de(3) <= '1' when (head_y_t <= dyb4) and (dyt4 <= head_y_b) 
	  and (head_x_l <= dxr4) and (dxl4 <= head_x_r) else
	  '0';
	 --
	 drd5 <= '1' when (d_on5='1') and (drom5='1') and (de(4) = '0') and (dc5 = "00")
			else
			'0'; 
	 de(4) <= '1' when (head_y_t <= dyb5) and (dyt5 <= head_y_b) 
	  and (head_x_l <= dxr5) and (dxl5 <= head_x_r) else
	  '0';
	 --
	 drd6 <= '1' when (d_on6='1') and (drom6='1') and (de(5) = '0') and (dc6 = "00")
			else
			'0'; 
	 de(5) <= '1' when (head_y_t <= dyb6) and (dyt6 <= head_y_b) 
	  and (head_x_l <= dxr6) and (dxl6 <= head_x_r) else
	  '0';
	 --
	 drd7 <= '1' when (d_on7='1') and (drom7='1') and (de(6) = '0') and (dc7 = "00")
			else
			'0'; 
	 de(6) <= '1' when (head_y_t <= dyb7) and (dyt7 <= head_y_b) 
	  and (head_x_l <= dxr7) and (dxl7 <= head_x_r) else
	  '0';
	 --
	 drd8 <= '1' when (d_on8='1') and (drom8='1') and (de(7) = '0') and (dc8 = "00")
			else
			'0'; 
	 de(7) <= '1' when (head_y_t <= dyb8) and (dyt8 <= head_y_b) 
	  and (head_x_l <= dxr8) and (dxl8 <= head_x_r) else
	  '0';
	
	with de select hit <= 
		'0' when "00000000",
		'1' when others;
  ----------------------------------------------
   -- rgb multiplexing circuit
   ----------------------------------------------
   process(video_on,rd_head_on, rd_body1_on,head_rgb,body_rgb)
   begin
      if video_on='0' then
          graph_rgb <= "000"; --blank
      else
         if rd_head_on='1' and blank = '0' then
            graph_rgb <=  head_rgb;
			elsif rd_body1_on = '1' and blank = '0' then
				graph_rgb <= body_rgb;
			elsif rd_body2_on = '1' and blank = '0' then
				graph_rgb <= body_rgb;
			elsif Lbar_on = '1' or Rbar_on = '1' or Tbar_on = '1' or Bbar_on = '1' then
				graph_rgb <= bar_rgb;
			elsif drd1='1' and blank = '0' then 
				graph_rgb <= dmnd_rgb1;
			elsif drd2='1' and blank = '0' then 
				graph_rgb <= dmnd_rgb2;
			elsif drd3='1' and blank = '0' then 
				graph_rgb <= dmnd_rgb3;
			elsif drd4='1' and blank = '0' then 
				graph_rgb <= dmnd_rgb4;
			elsif drd5='1' and blank = '0' then 
				graph_rgb <= dmnd_rgb5;
			elsif drd6='1' and blank = '0' then 
				graph_rgb <= dmnd_rgb6;
			elsif drd7='1' and blank = '0' then 
				graph_rgb <= dmnd_rgb7;
			elsif drd8='1' and blank = '0' then 
				graph_rgb <= dmnd_rgb8;
         else
            graph_rgb <= "111"; -- white background
         end if;
      end if;
   end process;
	
end Behavioral;

