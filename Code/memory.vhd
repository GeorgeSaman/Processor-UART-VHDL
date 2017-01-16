---George Saman

library IEEE;
use IEEE.numeric_bit.all;  

entity memory is 
	port(
		baud	: in bit;
		read	: in bit;
		write	: in bit;
		Data_in	: in bit_vector (7 downto 0);
		Address : in bit_vector (3 downto 0);
		Data_out: out bit_vector(7 downto 0);
		send	: out bit	
		);
end entity;

architecture behave of memory is

--------------------------------Declaring Memory 16X8
type memory_type is array (0 to 15) of bit_vector ( 7 downto 0);
signal main_memory : memory_type;

--------------------------------Declaring States
type states is (idle,Sread,Swrite);
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

	State_Machine : process(pstate,read,write)
					begin
					send <= '0';
						case pstate is
							when idle => 
										if read = '1' and write = '0' then
											nstate <= Sread;
										elsif write ='1' and read = '0' then
											nstate <= Swrite;
										else
											nstate <= idle;
										end if;
										
							when Sread => Data_out <= main_memory(to_integer(unsigned(Address)));
										  send <= '1';
										  nstate <= idle;
							when Swrite=> main_memory(to_integer(unsigned(Address))) <= Data_in;
										  nstate <= idle;
										  
						end case;				 
					end process;
					
					
					
					
					
					
					
					
					
					
					
					
					
					
					
					
					
end architecture;