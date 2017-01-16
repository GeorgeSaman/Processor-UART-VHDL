---George Saman

library IEEE;
use IEEE.numeric_bit.all;

entity command_processor is
	port(
		Rx_line : in bit;
		clk100mhz: in bit;
		Tx_line : out bit
		);
end entity;

architecture structure of command_processor is

component Rx_top
	port( baud : in bit; 
		  baudx16: in bit;
		  Rx_line: in bit;
		  Data_out_of_Rx_top: out bit_vector ( 7 downto 0);
		  Fifo_valid : out bit
	);
		 
end component;

component get_command
	port(
		baud	   : in bit;
		Fifo_valid : in bit;
		data_from_fifo : in bit_vector(7 downto 0);
		mem_write  : out bit;
		mem_read   : out bit;
		mem_data_to_write : out bit_vector (7 downto 0);
		mem_address: out bit_vector (3 downto 0)		
		);
end component;


component memory
	port(
		baud	: in bit;
		read	: in bit;
		write	: in bit;
		Data_in	: in bit_vector (7 downto 0);
		Address : in bit_vector (3 downto 0);
		Data_out: out bit_vector(7 downto 0);
		send	: out bit	
		);
end component;


component Tx
  port (
		clk		: in bit;				    -- frequency of baudrate
		send	: in bit;  					-- a flag to start sending
		DATA_IN : in bit_vector(7 downto 0);-- loaded from fifo
		DATA_OUT: out bit					-- to the outside world
		);
end component;

component clkgen is
  port (clk100mhz : in bit;
        reset : in bit;
        baudclk_16x : out bit;
        baudclk : out bit );
end component;

--------------------------------Signals
signal reset,baud,baudx16,FifoValid,MemWrite,MemRead,TxSend,Tx_out : bit;
signal Data_from_Rx_to_Get_command, MemData, TxData : bit_vector(7 downto 0);	  
signal MemAddress : bit_vector ( 3 downto 0);
begin


	clock_gen : clkgen port map (
			clk100mhz => clk100mhz,
			reset => reset,
			baudclk_16x => baudx16,
			baudclk => baud
			);

	RxTOP : Rx_top port map (
			Rx_line => Rx_line,
			baud => baud,
			baudx16 => baudx16,
			Data_out_of_Rx_top => Data_from_Rx_to_Get_command,
			Fifo_valid => FifoValid	
			);


	getCommand : get_command port map ( 
			baud => baud,
			Fifo_valid => FifoValid,
			Data_from_fifo => Data_from_Rx_to_Get_command,
			mem_write => MemWrite,
			mem_read => MemRead,
			mem_data_to_write => MemData,
			mem_address => MemAddress
			);

	Memory16X8 : memory port map (
			baud => baud,
			read => MemRead,
			write => MemWrite,
			Data_in => MemData,
			Address => MemAddress,
			Data_out => TxData,
			send => TxSend
			);
			
	Transmitter: Tx port map (
			clk => baud,
			send => TxSend,
			DATA_IN => TxData,
			DATA_OUT => Tx_line
			);
	  
end architecture;	