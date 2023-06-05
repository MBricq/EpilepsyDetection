library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity FullDisplay is
    port (
        clk : in std_logic;
        nReset : in std_logic;

        -- Internal interface (i.e. Avalon slave).
        -- For the address, we have 2 bits, so we can have 4 registers.
        address : in std_logic_vector(1 downto 0);
        write : in std_logic;
        writedata : in std_logic_vector(7 downto 0);

        -- 3 external interfaces to the 7-segment displays.
        OutDisp0 : out std_logic_vector(6 downto 0);
        OutDisp1 : out std_logic_vector(6 downto 0);
        OutDisp2 : out std_logic_vector(6 downto 0)
    );
end entity FullDisplay;

architecture comp of FullDisplay is
    
    -- Internal signals.
    signal iEnable : std_logic;
    -- The digits to display.
    signal iDigit0 : std_logic_vector(3 downto 0);
    signal iDigit1 : std_logic_vector(3 downto 0);
    signal iDigit2 : std_logic_vector(3 downto 0);

    component Segment7 is
        port(
            clk         : in std_logic;
            enable      : in std_logic;
            display     : in std_logic_vector(3 downto 0);
            -- External interface (i.e. conduit).
            out_disp    : out std_logic_vector(6 downto 0)
        );
    end component Segment7;

begin
    
    -- Instantiate the 3 7-segment displays.
    disp0 : component Segment7
        port map (
            clk         => clk,
            enable      => iEnable,
            display     => iDigit0,
            out_disp    => OutDisp0
        );

    disp1 : component Segment7
        port map (
            clk         => clk,
            enable      => iEnable,
            display     => iDigit1,
            out_disp    => OutDisp1
        );

    disp2 : component Segment7
        port map (
            clk         => clk,
            enable      => iEnable,
            display     => iDigit2,
            out_disp    => OutDisp2
        );


    -- Avalon slave write to registers.
    process(clk, nReset)
    begin
        if nReset = '0' then
            -- Reset the registers.
            iEnable <= '0';
            iDigit0 <= (others => '0');
            iDigit1 <= (others => '0');
            iDigit2 <= (others => '0');
        elsif rising_edge(clk) then
            -- Write to the registers.
            if write = '1' then
                -- Address 0 is the enable. The three next are for the digits
                case Address is
                    when "00" =>
                        iEnable <= writedata(0);
                    when "01" =>
                        iDigit0 <= writedata(3 downto 0);
                    when "10" =>
                        iDigit1 <= writedata(3 downto 0);
                    when "11" =>
                        iDigit2 <= writedata(3 downto 0);
                    when others =>
                        null;
                end case;
            end if;
        end if;
    end process;
    
end architecture comp;