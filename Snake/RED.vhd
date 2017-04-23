
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity RED is
port(clk,reset:in STD_LOGIC;
	level: in STD_LOGIC;
	tick: out STD_LOGIC
	);
end RED;

architecture moore_arch of RED is
	type state_type is (zero,edge,one);
	signal state_reg, state_next: state_type;
begin
	--state register
	process(clk,reset)
	begin
		if (reset = '1') then
			state_reg <= zero;
		elsif (clk'event and clk = '1') then
			state_reg <= state_next;
		end if;
	end process;
	-- next-state
	process(state_reg,level)
	begin
		state_next <= state_reg;
		tick <= '0';
		case state_reg is
			when zero => 
				if level = '1' then
					state_next <= one;
				else
					state_next <= zero;
				end if;
			when one =>
				if level = '0' then
					state_next <= zero;
				end if;
		end case;
	end process;
end moore_arch;



--Listing
architecture mealy_arch of RED is
	type state_type is (zero, one);
   signal state_reg, state_next: state_type;
begin
   -- state register
   process(clk,reset)
   begin
      if (reset='1') then
         state_reg <= zero;
      elsif (clk'event and clk='1') then
         state_reg <= state_next;
      end if;
   end process;
   -- next-state/output logic
   process(state_reg,level)
   begin
      state_next <= state_reg;
      tick <= '0';
      case state_reg is
         when zero=>
            if level= '1' then
               state_next <= one;
               tick <= '1';
            end if;
         when one =>
            if level= '0' then
               state_next <= zero;
            end if;
      end case;
   end process;
end mealy_arch;


architecture gate_level_arch of RED is
	 signal delay_reg: std_logic;
begin
   -- delay register
   process(clk,reset)
   begin
      if (reset='1') then
         delay_reg <= '0';
      elsif (clk'event and clk='1') then
         delay_reg <= level;
      end if;
   end process;
   -- decoding logic
   tick <= (not delay_reg) and level;
end gate_level_arch;