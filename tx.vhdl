-----------------------------------
-- GEORGE SAMAN

library IEEE;
use IEEE.numeric_std.all;

entity Tx is
  port (
		clk		: in bit;				    -- frequency of baudrate
		send	: in bit;  					-- a flag to start sending
		DATA_IN : in bit_vector(7 downto 0);-- loaded from fifo
		DATA_OUT: out bit					-- to the outside world
		);
end entity;

architecture behave of Tx is
 ---------------------------Declaring States
 type States is (wait_for_send,start,B0,B1,B2,B3,B4,B5,B6,B7,stop);
 signal pstate, nstate : states;
 
 ---------------------------internal Signals
 signal  send_start, send_stop, sending_started : bit; 
 														
 ---------------------------Shift Register
 signal shift_register : bit_vector (7 downto 0) := "00000000";
 
begin

 ---------------------------State Transition
State_Transition : process(clk)
				begin
				if clk'event and clk ='1' then 
				pstate <= nstate;
				end if;
				end process;

 ---------------------------State machine
State_machine: process(pstate,send)
				begin
				
				send_start <= '0';	 
				send_stop <= '0';
				
				case pstate is 
				when wait_for_send =>				
									if send = '1' then 
										nstate <= start; 
										send_start <= '1'; 
									else
										nstate <= wait_for_send;
										
									end if;	
		
							
				when start =>  nstate <= B0;
														
				when B0 => nstate <= B1;	
				when B1 => nstate <= B2;
				when B2 => nstate <= B3;
				when B3 => nstate <= B4;
				when B4 => nstate <= B5;
				when B5 => nstate <= B6;
				when B6 => nstate <= B7;
				when B7 => nstate <= stop; 
						 send_stop <= '1';
						  							
				when stop =>
							nstate <= wait_for_send; 
			
				end case;

			end process;				 
			
 ---------------------------Shift Register

 Shift_registr : process(send_start,send_stop,clk)
 begin														
	 if clk'event and clk = '1' then	
		 			
					if  send_start = '1' then		-- when sending just started
						DATA_OUT <= '0';			-- Send start bit;						  
						shift_register <=(7=>DATA_IN(0),
										6=>DATA_IN(1),
										5 => DATA_IN(2) ,
										4=>DATA_IN(3),
										3=>DATA_IN(4) , 
										2 =>DATA_IN(5), 
										1 => DATA_IN(6) , 
										0 =>DATA_IN(7) 
										);	--- LOAD DATA into shift Register  
						sending_started <= '1';	  	-- A signal to know that sending has started
				
					elsif sending_started = '1' and send_stop = '0' then		   -- if still sending bits 
						DATA_OUT <= shift_register(7);							   -- set output to the MSB in register
						shift_register(7 downto 1) <= shift_register(6 downto 0);  -- shift left
						shift_register(0) <= '0';	  
				  
					elsif send_stop = '1' then 		-- when done, pull output to high and clear sending_started
						DATA_OUT <= '1';
						sending_started <= '0';	 
				
					elsif sending_started = '0' then -- when idle, Keep output high as an idle state
						DATA_OUT <= '1';
					
					end if;	  
				end if;
						
 
 end process;
 

end behave;
