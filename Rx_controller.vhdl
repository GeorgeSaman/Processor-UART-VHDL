---George Saman

library IEEE;
use IEEE.numeric_bit.all;


entity Rx_controller is
	port(
		baud	: in bit;
		D_valid	: in bit;
		Fifo_full: in bit;
		Fifo_empty : in  bit;
		Fifo_write: out bit;
		Fifo_read : out bit;
		memory_write: out bit	 --- indicates FIFO contains a command ( This connects to Fifo_Valid )
		);
	
end entity;

architecture behave of Rx_controller is

--------------------------------Declaring States
type states is (idle, load_fifo,load_memory);
signal pstate, nstate : states;


begin
----------------------------------State_transition

	State_transition : process(baud)
					begin
						if baud'event and baud = '1' then
							Pstate <= Nstate;
						end if;
					end process;
					
					
----------------------------------State_Machine

	State_Machine : process(pstate,baud,D_valid, Fifo_full,Fifo_empty)
					begin
						case pstate is
							when idle =>  
								
							if baud'event and baud = '1' then
										if D_valid = '1' and Fifo_full = '0' then
											nstate <= load_fifo;
											Fifo_write <= '1';
										
										else
											nstate <= idle;
											Fifo_write <= '0';
										end if;
										
										
							end if;
							when load_fifo =>   
										if Fifo_full = '1' then
											nstate <= load_memory;
											Fifo_write <= '0';
											memory_write <= '1';
											Fifo_read  <= '1';	
										else
											nstate <= idle;
										end if;
										
											
							
							when load_memory =>  
																			
												if Fifo_empty = '1' then 
													nstate <= idle;
													Fifo_read  <= '0';
													memory_write <= '0';
												else
													Fifo_read  <= '1';	
													memory_write <= '1';
													nstate <= load_memory;
												end if;
						
											
						end case;
					end process;
			
end behave;
