
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity Debounce is
port( clk,reset: in STD_LOGIC;
	btn: in STD_LOGIC;
	db: out STD_LOGIC
	);
end Debounce;

architecture Behavioral of Debounce is
	constant N: integer := 19;
	signal q_reg,q_next:unsigned(N-1 downto 0);
	signal m_tick: STD_LOGIC;
	type eg_state_type is (zero, wait1_1, wait1_2,wait1_3,
									one,wait0_1,wait0_2,wait0_3);
	signal state_reg,state_next:eg_state_type;
begin
	process(clk,reset)
	begin
		if (clk'event and clk='1') then
			q_reg <= q_next;
		end if;
	end process;
	--next state logic
	q_next <= q_reg +1;
	--output tick
	m_tick <= '1' when q_reg = 0 else '0';
	
	--debounce
	
	process(clk,reset)
	begin
		if (reset = '1') then
			state_reg <= zero;
		elsif (clk'event and clk ='1') then
			state_reg <= state_next;
		end if;
	end process;
	
	--next-state
	
	process(state_reg,btn,m_tick)
	begin
		state_next <= state_reg;
		db <= '0';
		case state_reg is 
			when zero => if btn ='1' then
				state_next <=wait1_1;
			end if;
			when wait1_1 => if btn = '0' then 
									state_next <= zero;
								else
									if m_tick ='1' then
										state_next <= wait1_2;
									end if;
								end if;
			when wait1_2 => if btn = '0' then 
									state_next <= zero;
								else
									if m_tick = '1' then
										state_next <= wait1_3;
									end if;
								end if;
			when wait1_3 => if btn = '0' then
									state_next <= zero;
								else
									if m_tick = '1' then 
										state_next <= one;
									end if;
								end if;
			when one => 
				db <= '1';
				if btn ='0' then
					state_next <= wait0_1;
				end if;
			when wait0_1 =>
				db <= '1';
				if btn ='1' then
					state_next <= one;
				else 
					if m_tick = '1' then
						state_next <= wait0_2;
					end if;
				end if;
			when wait0_2 =>
            db <='1';
            if btn='1' then
               state_next <= one;
            else
               if m_tick='1' then
                  state_next <= wait0_3;
               end if;
            end if;
			when wait0_3 =>
            db <='1';
            if btn='1' then
               state_next <= one;
            else
               if m_tick='1' then
                  state_next <= zero;
               end if;
            end if;
		end case;
	end process;
end Behavioral;

