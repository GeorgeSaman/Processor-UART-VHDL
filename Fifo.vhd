library IEEE;
use IEEE.numeric_bit.all;

entity fifo is
	port(
	write,read : in bit;
	clk		   : in bit;
	data_in	   : in bit_vector (7 downto 0);
	full,empty : buffer bit;
	data_out   : out bit_vector ( 7 downto 0)	);
end entity;

architecture behave of fifo is
type fifo_buffer is array(3 downto 0) of bit_vector(7 downto 0);
signal fifo : fifo_buffer;
signal write_ptr,read_ptr : unsigned (2 downto 0) := "000";
begin
	data_out <= fifo(to_integer(read_ptr(1 downto 0)));	 
	
readAndwrite:	process(clk)
	begin
		if ( clk'event and clk ='1') then 						-- at positive edge
			if (write ='1' and full ='0') then					-- if not full , write data in and inc ptr
				fifo(to_integer(write_ptr(1 downto 0))) <= data_in;
				write_ptr <= write_ptr + 1;	
			end if;
			if ( read = '1' and empty = '0') then			  -- if not empty , read data and inc ptr	  
				read_ptr <= read_ptr + 1;
			end if;
		end if;
	
	end process;
		

	empty <= '1' when (write_ptr = read_ptr) else '0'; 

	full <= '1' when ( (write_ptr(2) /= read_ptr(2)) and (write_ptr(1 downto 0) = read_ptr(1 downto 0)) ) else '0';
																							 

end behave;
