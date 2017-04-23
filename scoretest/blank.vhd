process
	begin
	hit <= '0';
		 if (head_y_t <= dyb1) and (dyt1 <= head_y_b) and (head_x_l <= dxr1) and (dxl1 <= head_x_r) then
			hit <= '1';
			drd1 <= '0';
			elsif (head_y_t <= dyb2) and (dyt2 <= head_y_b) and (head_x_l <= dxr2) and (dxl2 <= head_x_r) then
			hit <= '1';
			drd1 <= '0';
			elsif (head_y_t <= dyb3) and (dyt3 <= head_y_b) 
	  and (head_x_l <= dxr3) and (dxl3 <= head_x_r) then
			hit <='1';
			drd1 <= '0';
			elsif (head_y_t <= dyb4) and (dyt4 <= head_y_b) 
	  and (head_x_l <= dxr4) and (dxl4 <= head_x_r) then
			hit <= '1';
			drd1 <= '0';
			elsif (head_y_t <= dyb5) and (dyt5 <= head_y_b) 
	  and (head_x_l <= dxr5) and (dxl5 <= head_x_r) then
		  hit <= '1';
		  drd1 <= '0';
	  elsif (head_y_t <= dyb6) and (dyt6 <= head_y_b) 
	  and (head_x_l <= dxr6) and (dxl6 <= head_x_r) then
		  hit <= '1';
		  drd1 <= '0';
	  elsif (head_y_t <= dyb7) and (dyt7 <= head_y_b) 
	  and (head_x_l <= dxr7) and (dxl7 <= head_x_r) then
		  hit <= '1';
		  drd1 <= '0';
	  elsif (head_y_t <= dyb8) and (dyt8 <= head_y_b) 
	  and (head_x_l <= dxr8) and (dxl8 <= head_x_r) then 
		  hit <= '1';
		  drd1 <= '0';
	  else 
		hit <= '0';
	end if;
end process;

process
begin
	if (d_on1='1') and (drom1='1') and (de1 = '0') and (dc1 = "00") then
		drd1 <= '1';
	elsif (d_on2='1') and (drom2='1') and (de2 = '0') and (dc2 = "00") then
		drd2 <= '1';
	elsif (d_on3='1') and (drom3='1') and (de3 = '0') and (dc3 = "00") then
		drd3 <= '1';
	elsif (d_on4='1') and (drom4='1') and (de4 = '0') and (dc4 = "00") then
		drd4 <= '1';
	elsif (d_on5='1') and (drom5='1') and (de5 = '0') and (dc5 = "00") then
		drd5 <= '1';
	elsif (d_on6='1') and (drom6='1') and (de6 = '0') and (dc6 = "00") then
		drd6 <= '1';
	elsif (d_on7='1') and (drom7='1') and (de7 = '0') and (dc7 = "00") then
		drd7 <= '1';
	elsif (d_on8='1') and (drom8='1') and (de8 = '0') and (dc8 = "00") then
		drd8 <= '1';
	end if;
end process;