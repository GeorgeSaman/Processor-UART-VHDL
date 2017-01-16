-- Clock generator
-- 100 Mhz input, 

entity clkgen is
  port (clk100mhz : in bit;
        reset : in bit;
        baudclk_16x : out bit;
        baudclk : out bit );
end entity;


architecture behave of clkgen is

  signal count : integer range 0 to 54;
  signal bclk_16x, bclk_8x, bclk_4x, bclk_2x, bclk : bit; 

begin

  baudclk <= bclk;
  baudclk_16x <= bclk_16x;

  process(clk100mhz, reset)
  begin
    if (reset = '1') then
      count <= 0;
      bclk_16x <= '0';
    elsif (clk100mhz'event and clk100mhz = '1') then
      if (count = 26) then
        count <= 0;
        bclk_16x <= not bclk_16x;
      else
        count <= count + 1;
      end if;
    end if;
  end process;

  process(bclk_16x,reset)
  begin
    if (reset = '1') then
      bclk_8x <= '0';
    elsif (bclk_16x'event and bclk_16x = '1') then
      bclk_8x <= not bclk_8x;
    end if;
  end process;

  process(bclk_8x,reset)
  begin
    if (reset = '1') then
      bclk_4x <= '0';
    elsif (bclk_8x'event and bclk_8x = '1') then
      bclk_4x <= not bclk_4x;
    end if;
  end process;

  process(bclk_4x,reset)
  begin
    if (reset = '1') then
      bclk_2x <= '0';
    elsif (bclk_4x'event and bclk_4x = '1') then
      bclk_2x <= not bclk_2x;
    end if;
  end process;

  process(bclk_2x,reset)
  begin
    if (reset = '1') then
      bclk <= '0';
    elsif (bclk_2x'event and bclk_2x = '1') then
      bclk <= not bclk;
    end if;
  end process;


end behave;



