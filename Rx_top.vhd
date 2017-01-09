---George Saman

library IEEE;
use IEEE.numeric_bit.all;


entity Rx_top is 
	port( baud : in bit; 
		  baudx16: in bit;
		  Rx_line: in bit;
		  Data_out_of_Rx_top: out bit_vector ( 7 downto 0);
		  Fifo_valid : out bit
	);
		 
end entity;

architecture structure of Rx_top is 

component Rx 
	port(baudx16 :in bit;
		 Rx_line : in bit;
		 Data_recieved : out bit_vector(7 downto 0);
		 D_valid	   : out bit
	);
	
end component;


component Rx_controller
	port(
		baud	: in bit;
		D_valid	: in bit;
		Fifo_full: in bit;
		Fifo_empty : in  bit;
		Fifo_write: out bit;
		Fifo_read : out bit;
		memory_write: out bit
			);
end component;

component fifo is
	port(
	write,read : in bit;
	clk		   : in bit;
	data_in	   : in bit_vector (7 downto 0);
	full,empty : buffer bit;
	data_out   : out bit_vector ( 7 downto 0)	);
end component;




--------------------------unused signals
signal reset : bit;

--------------------------Data lines
signal Data_into_fifo, Data_out_fifo : bit_vector(7 downto 0);

-------------------------internal signals
signal Dta_valid, write, Read, empty, full : bit;



begin  
	Data_out_of_Rx_top <= Data_out_fifo;
	
	Reciever : Rx port map (
			baudx16 => baudx16,
			Rx_line => Rx_line,
			Data_recieved => Data_into_fifo,
			D_valid => Dta_valid	
				);
				
	Fifo_unit: fifo port map (
			write => write,
			read  => read,
			clk	  => baud,
			data_in => Data_into_fifo,
			full	=> full,
			empty	=> empty,
			data_out=> Data_out_fifo
				);
	
	RxController: Rx_controller port map (
			baud => baud,
			D_valid => Dta_valid,
			Fifo_full => full,
			Fifo_empty => empty,
			Fifo_write => write,
			Fifo_read => read,
			memory_write => Fifo_valid
			);					  



end structure;
