---George Saman

library IEEE;
use IEEE.numeric_bit.all;


entity Rx is
	port(baudx16 :in bit;
		 Rx_line : in bit;
		 Data_recieved : out bit_vector(7 downto 0);
		 D_valid	   : out bit
	);
	
end entity;


architecture behave of Rx is
----------------------Declaring States
type states is (idle,Scount7,start,Scount15,B0,B1,B2,B3,B4,B5,B6,B7,Stop);
signal Pstate, Nstate : states;

----------------------Counters
signal counter7, bit_number : unsigned (2 downto 0);  
signal counter15 : unsigned (3 downto 0);

----------------------Internal Signals
signal start_counter7, start_counter15, Data_valid, enable_Data_valid  , transmit_done  : bit;	 

----------------------Shift Regsiter
signal shift_register : bit_vector (7 downto 0);

begin
----------------------------------Connections

	D_valid <= Data_valid; -- connect internal signal data_valid to the outside world
	Data_recieved <= shift_register;

----------------------------------State_transition

	State_transition : process(baudx16)
					begin
						if baudx16'event and baudx16 = '1' then
							Pstate <= Nstate;
						end if;
					end process;
					
	
----------------------------------State_Machine

	State_Machine : process(pstate,counter7,counter15,Rx_line)
					begin
						case pstate is
						
						when idle => Transmit_done <= '1';	  		-- reset
																	   
									Data_valid <= enable_data_valid; -- when data_valid goes low disable enable_data
								 
									if falling_edge(Rx_line) then 
										nstate <= Scount7;
										start_counter7 <= '1';
									else 
										nstate <= idle;
									end if;
						
						when Scount7 =>	Data_valid <= enable_data_valid;
								
									if counter7  = "111" then  		
										start_counter7 <= '0';		-- stop count7
										nstate <= start;
										
									else
										start_counter7 <= '1';
										nstate <= Scount7;
									end if;
									
						when start => data_valid <= '0';		-- indicate that the data in shift reg is dirty
									if Rx_line = '0' then
										nstate <= Scount15;
										start_counter15 <= '1';
										transmit_done <= '0';
									else
										nstate <= idle;
										start_counter15 <= '0';
									end if;	 
									
						when Scount15   =>  
									if counter15  = "1111" then  	
										start_counter15 <= '0';		-- stop count15	 
										
										if transmit_done = '1' then -- check if next state is stop or a bit
											nstate <= stop;
										else
											case bit_number is	    -- Determine what is next state 
												when "000" => nstate <= B0;
												when "001" => nstate <= B1;
											    when "010" => nstate <= B2;
												when "011" => nstate <= B3;	
												when "100" => nstate <= B4;
												when "101" => nstate <= B5;
											    when "110" => nstate <= B6;
												when "111" => nstate <= B7; bit_number <= "000"; -- reset 
											end case;  
											bit_number <= bit_number + 1;
										end if;				   
									else
										start_counter15 <= '1';
										nstate <= Scount15;
									end if;	
									
						when B0   => shift_register(0) <= Rx_line;		-- Load value into shift reg
									 start_counter15 <= '1';		 	-- start counting for next bit
									 nstate <= Scount15;				-- count state
							
						when B1   => shift_register(1) <= Rx_line;		-- Load value into shift reg
									 start_counter15 <= '1';		 	-- start counting for next bit	
									 nstate <= Scount15;
									 
						when B2   => shift_register(2) <= Rx_line;		-- Load value into shift reg
									 start_counter15 <= '1';		 	-- start counting for next bit 
									 nstate <= Scount15;
									 
						when B3   => shift_register(3) <= Rx_line;		-- Load value into shift reg
									 start_counter15 <= '1';		 	-- start counting for next bit
									 nstate <= Scount15;
									 
						when B4   => shift_register(4) <= Rx_line;		-- Load value into shift reg
									 start_counter15 <= '1';		 	-- start counting for next bit 
									 nstate <= Scount15;
									 
						when B5   => shift_register(5) <= Rx_line;		-- Load value into shift reg
									 start_counter15 <= '1';		 	-- start counting for next bit 
									 nstate <= Scount15;
									 
						when B6   => shift_register(6) <= Rx_line;		-- Load value into shift reg
									 start_counter15 <= '1';		 	-- start counting for next 
									 nstate <= Scount15;
									
						when B7   => shift_register(7) <= Rx_line;		-- Load value into shift reg
								     start_counter15 <= '1';		 	-- start counting for next bit
									 transmit_done <= '1';				-- a flag for count16 to know what is nstate
									 nstate <= Scount15;
									 
						when stop => nstate <= idle;
									 data_valid <= Rx_line; 		-- if Rx =1 then valid =1 and vice versa.
												 
						end case;
	
					end process;
					
					
					
					
----------------------------------Count7

		count7 :	process(baudx16,start_counter7)
					begin
						if baudx16'event and baudx16 = '1' then
							if start_counter7 = '1' then 
								counter7 <= counter7 + 1;
							else
								counter7 <= "000";
							end if;
							
						end if;
						
					end process;
					
----------------------------------Count15

		count15 :	process(baudx16,start_counter15,enable_data_valid)
					begin
						if baudx16'event and baudx16 = '1' then
							if start_counter15 = '1' then 
								counter15 <= counter15 + 1;
							else
								counter15 <= "0000";
							end if;	 
							-- For the data_valid , keep it on for 1 bit_time
							if data_valid = '1' then
								if counter15 = "1111" then
									counter15 <= "0000";
									enable_data_valid <= '0';
								else
									counter15 <= counter15 + 1;	 
									enable_data_valid <= '1';
								end if;
							end if;
							
						end if;
						
					end process;
					
end architecture;
