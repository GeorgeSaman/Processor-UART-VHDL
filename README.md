# UART-VHDL
Command processor with UART interface -VHDL

## Index
* The Big Picture.
* Command Formats.
* How It Works.

## The Big Picture
This block diagram illustrates the connections between each functional unit.
![Command Processor](/Command_processor.png?row=true "Command_processor")

This block diagram shows the functional units of Rx_Top. 
![Rx_top](/Rx_top.png?row=true "Rx_top")

## Command Formats
* **$** indicates the beginning of a command.
* **W/R** the second character can be either W or R. W to Write to memory , R to Read.
* **Address** this is the memory address to write to or read from.
* **Data/Zero** if its a Write then this byte will carry the data to be writter, if its a read this must be zero.

## How It Work
* Using a serial termainal ( ex. Putty , minicom) a command is sent.
* After each character received, the receiver will set **D_Valid** high to indicate there is data present in the **RX register**.
* When all 4 characters are received, **FiFo** will be **Full** and the controller will set **FiFo_valid** and **FiFo_Read** both high for **Get_command** block to start decoding the command in FiFo.
* According to the command received, **Get_command** will issue appropriate signals to **Memory**.
* If its a Read command, **Memory** will load data on **TxData** and sets **TxSend** line high for **Transmitter** to start sending.

> At each clock cycle **Get_command** decodes a character.

