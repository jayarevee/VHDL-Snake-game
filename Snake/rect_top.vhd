-- Listing 12.6
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_dat is
   port (
      clk: in std_logic;
		reset: in std_logic;
      btn: in std_logic_vector (3 downto 0);
		sw1,sw2: in std_logic;
      hsync, vsync: out std_logic;
      rgb: out std_logic_vector(2 downto 0)
   );
end top_dat;

architecture arch of top_dat is

	type state_type is (start, GG, QQ);
   signal pixel_x, pixel_y: std_logic_vector (9 downto 0);
   --signal video_on, pixel_tick: std_logic;
   signal rgb_reg, rgb_next: std_logic_vector(2 downto 0);
	signal video_on, pixel_tick,turnoff,blank: std_logic;
   --signal pixel_x, pixel_y: std_logic_vector (9 downto 0);
	signal graph_on, gra_still, hit, miss: std_logic;
   signal text_on: std_logic_vector(3 downto 0);
   signal graph_rgb, text_rgb: std_logic_vector(2 downto 0);
   --signal rgb_reg, rgb_next: std_logic_vector(2 downto 0);
   signal state_reg, state_next: state_type;
   signal dig0, dig1: std_logic_vector(3 downto 0);
	signal d_inc, d_clr: std_logic;
	signal count: std_logic_vector(3 downto 0);
 --  signal timer_tick, timer_start, timer_up: std_logic;
   signal cnt_reg, cnt_next: unsigned(3 downto 0);
   signal ball: std_logic_vector(1 downto 0);
	signal mode:std_logic_vector(1 downto 0);
	signal done: std_logic;
begin
   -- instantiate VGA sync
   vga_sync_unit: entity work.vga_sync
      port map(clk=>clk, reset=>reset,
               video_on=>video_on, p_tick=>pixel_tick,
               hsync=>hsync, vsync=>vsync,
               pixel_x=>pixel_x, pixel_y=>pixel_y);
   -- instantiate graphic generator
   snakie_unit: entity work.snakie
      port map (clk=>clk, reset=>reset,
                btn=>btn, video_on=>video_on,sw1=>sw1,sw2=>sw2,
                pixel_x=>pixel_x, pixel_y=>pixel_y,
                graph_rgb=>rgb_next,mode => mode,hitter=>hit,finish => done,blank => blank);
					 	 
	text_unit: entity work.snakie_text
      port map(clk=>clk, reset=>reset,
               pixel_x=>pixel_x, pixel_y=>pixel_y,
               dig0=>dig0, dig1=>dig1, ball=>ball,
               text_on=>text_on, text_rgb=>text_rgb);
	
	 -- instantiate 2-digit decade counter
   counter_unit: entity work.m100_counter
      port map(clk=>clk, reset=>reset,
               d_inc=>d_inc, d_clr=>d_clr,
               dig0=>dig0, dig1=>dig1);
					
	process--statez
		begin
		d_inc <= '0';
      d_clr <= '0';
		blank <= '0';
		turnoff <= '0';
		state_next <= state_reg;
		cnt_next <= cnt_reg;
			case state_reg is
				when start => 
					turnoff <= '0';
					blank <= '0';
					cnt_next <= "0000";
					d_clr <= '1';  
					if (btn /= "0000") then
						state_next <= QQ;
					end if;
				when QQ => 
					blank <= '0';
					if mode(0) = '1' then --hit bound
						state_next <= start;
					elsif done ='1' then
						state_next <= GG;
					elsif hit = '1' then
						d_inc <= '1';
						cnt_next <= cnt_reg + 1;
--						if (done = '1') then
--							state_next <= GG;
--						end if;
					end if;
				when GG =>
					blank <= '1';
					turnoff <= '1';
					state_next <= GG;
				when others =>
					state_next <= QQ;
				end case;
	end process;	


  -- registers
   process (clk,reset)
   begin
      if reset='1' then
         state_reg <= start;
			cnt_reg <= (others=>'0');
      elsif (clk'event and clk='1') then
         state_reg <= state_next;
			cnt_reg <= cnt_next;
			if (pixel_tick='1') then
            rgb_reg <= rgb_next;
			else
         -- display score, rule or game over
				if (text_on(3)='1' and turnoff = '0') or
					(state_reg=start and text_on(1)='1' and turnoff = '0') or -- rule
					(state_reg=GG and text_on(0)='1') then
					rgb_reg <= text_rgb;
				end if;
			end if;
        end if;
   end process;

	
   rgb <= rgb_reg;

end arch;					
 