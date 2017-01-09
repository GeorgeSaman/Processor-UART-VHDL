---George Saman

library IEEE;
use IEEE.numeric_bit.all;

entity get_command is 
	port(
		baud	   : in bit;
		Fifo_valid : in bit;
		data_from_fifo : in bit_vector(7 downto 0);
		mem_write  : out bit;
		mem_read   : out bit;
		mem_data_to_write : out bit_vector (7 downto 0);
		mem_address: out bit_vector (3 downto 0)			--- memory got 16 entries each 8 bits wide
		);
end entity;

architecture behave of get_command is

--------------------------------Declaring States
type states is (Sdollar,SreadORwrite,Saddr,Szero,SDatatoWrite,SMemRead,SMemWrite);
signal pstate, nstate : states;

-------------------------------Internal Signals
signal Read_detected, Write_detected : bit;

-------------------------------Store Regsiters
signal address_register, data_register : bit_vector ( 7 downto 0);

begin


----------------------------------State_transition

	State_transition : process(baud)
					begin
						if baud'event and baud = '1' then
							Pstate <= Nstate;
						end if;
					end process;
					
----------------------------------State_Machine

	State_Machine : process(pstate,Fifo_valid,data_from_fifo,Read_detected,write_detected)
					begin
						mem_write <= '0'; mem_read <= '0';
						case pstate is
							when Sdollar => 
						
										Read_detected <= '0'; write_detected <= '0';					-- Reset
										if Fifo_valid = '1' and data_from_fifo = "00100100" then		--- Dollar sign 
											nstate <= SreadORwrite;
										else
											nstate <= Sdollar;
										end if;	  
					
										
							when SreadORwrite =>
										if data_from_fifo = "01110010" then							--- Read
											nstate <= Saddr;
											Read_detected <= '1';
										elsif data_from_fifo = "01110111" then							--- Write
											nstate <= Saddr;
											write_detected <= '1';
										else
											nstate <= Sdollar;
										end if;
										
							when Saddr =>
										address_register <= data_from_fifo;										-- Store address						
										if read_detected = '1' and write_detected = '0' then
											nstate <= Szero;
										elsif write_detected = '1' and read_detected = '0' then
											nstate <= SDatatoWrite;
										else
											nstate <= Sdollar;				-- can never be here.
										end if;
										
							when Szero =>
										if data_from_fifo = "00000000" then
											nstate <= SMemRead;
										else
											nstate <= Sdollar;
										end if;
							
							when SDatatoWrite =>
										data_register <= data_from_fifo;											-- Store Data
										nstate <= SMemWrite;
							
							when SMemRead => 
										mem_read <= '1';
										mem_address <= address_register(3 downto 0);
										nstate <= Sdollar;
										
							when SMemWrite => 
										mem_write <= '1';
										mem_address <= address_register (3 downto 0);
										mem_data_to_write <= data_register;
										nstate <= Sdollar;
										
										
											
						
						end case;
						
					
					end process;
	

end architecture;
