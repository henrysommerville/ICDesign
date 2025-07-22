----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Design Name: 
-- Module Name: stopwatch_lap_reg - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity stopwatch_top_tb is
end stopwatch_top_tb;

architecture Behavioral of stopwatch_top_tb is

    -- Component under test
    component stopwatch_top is 
        Port (
            clk              : in STD_LOGIC;                     -- 10kHz clock
            reset            : in STD_LOGIC;                     -- System hard reset
    
            -- Input
            i_sw_enable       : in STD_LOGIC;                     -- enables stopwatch counting
            i_sw_lap_toggle   : in STD_LOGIC;                     -- Toggles lap display on/off
            i_sw_reset        : in STD_LOGIC;                     -- Soft reset for stopwatch clock 
    
    
            -- Output
            o_sw_time_hs      : out STD_LOGIC_VECTOR(7 downto 0); -- Time to display in hundredth of a second (BCD format)
            o_sw_time_s       : out STD_LOGIC_VECTOR(7 downto 0); -- Time to display in seconds (BCD format)
            o_sw_time_min     : out STD_LOGIC_VECTOR(7 downto 0); -- Time to display in mins (BCD format)
            o_sw_time_h       : out STD_LOGIC_VECTOR(6 downto 0); -- Time to display in hours (BCD format)
            o_sw_lap          : out STD_LOGIC                     -- Lap time toggle
        );
    end component;

    -- DUT ports
        signal clk              : STD_LOGIC := '0';
        signal reset            : STD_LOGIC := '0';
        signal i_sw_enable      : STD_LOGIC := '0';
        signal i_sw_lap_toggle  : STD_LOGIC := '0';
        signal i_sw_reset       : STD_LOGIC := '0';
    
        signal o_sw_time_hs     : STD_LOGIC_VECTOR(7 downto 0);
        signal o_sw_time_s      : STD_LOGIC_VECTOR(7 downto 0);
        signal o_sw_time_min    : STD_LOGIC_VECTOR(7 downto 0);
        signal o_sw_time_h      : STD_LOGIC_VECTOR(7 downto 0);
        signal o_sw_lap         : STD_LOGIC;

    -- Clock period definition
    constant c_CLK_PERIOD : time := 10 ns;

begin

    -- Instantiate DUT
    uut: entity work.stopwatch_top
        port map (
            clk              => clk,
            reset            => reset,
            i_sw_enable      => i_sw_enable,
            i_sw_lap_toggle  => i_sw_lap_toggle,
            i_sw_reset       => i_sw_reset,
            o_sw_time_hs     => o_sw_time_hs,
            o_sw_time_s      => o_sw_time_s,
            o_sw_time_min    => o_sw_time_min,
            o_sw_time_h      => o_sw_time_h,
            o_sw_lap         => o_sw_lap
        );

    -- Clock generation
    clk_process : process
    begin
        while true loop
            wait for 50 us;
            clk <= '1';
            wait for 50 us;
            clk <= '0';
        end loop;
    end process;

    -- Stimulus process
    stim_proc : process
    begin
        --------------------------------------------------------------------
        -- SYSTEM RESET
        --------------------------------------------------------------------
        reset <= '1';
        wait for 200 us;
        reset <= '0';
        wait for 1 ms;

        --------------------------------------------------------------------
        -- PHASE 1: START and STOP
        --------------------------------------------------------------------
        report "Start and Stop Stopwatch";

        -- Press Action to start
        i_sw_enable <= '1';
        wait for 2sec;
        i_sw_enable <= '0';

        wait for 10 ms;

        -- Press Action to stop
        i_sw_enable <= '1';
        wait for 122 sec;
        i_sw_enable <= '0';
        
        wait for 5 sec;

        --------------------------------------------------------------------
        -- PHASE 2: START, LAP ON, LAP OFF
        --------------------------------------------------------------------
        report "Start + Lap On/Off";

        -- Start again
        i_sw_enable <= '1';
        wait for 60 * 2 sec;
        
        i_sw_enable <= '0';

        wait for 5 sec;

        -- Press Lap toggle ON
        i_sw_lap_toggle <= '1';
        wait for 20 sec;
        i_sw_lap_toggle <= '0';

        wait for 10 sec;

        -- Press Lap toggle OFF
        i_sw_lap_toggle <= '1';
        wait for 5 sec;
        i_sw_lap_toggle <= '0';

        wait for 5 sec;

        -- Pause stopwatch
        i_sw_enable <= '0';
        wait for 10 sec;
        i_sw_enable <= '0';

        wait for 10 ms;

        --------------------------------------------------------------------
        -- PHASE 3: Reset from PAUSED
        --------------------------------------------------------------------
        report "Reset from Paused State";

        i_sw_reset <= '1';
        wait for 10 ms;
        i_sw_reset <= '0';

        wait for 5 ms;

        --------------------------------------------------------------------
        -- PHASE 4: Start + Lap ON, then Reset
        --------------------------------------------------------------------
        report "Start + Lap ON + Reset";

        -- Start stopwatch
        i_sw_enable <= '1';
        wait for 60 * 60 * 2 sec;
        i_sw_enable <= '0';

        wait for 10 sec;

        -- Enable lap
        i_sw_lap_toggle <= '1';
        wait for 2 sec;
        i_sw_lap_toggle <= '0';

        wait for 10 sec;
        
        i_sw_enable <= '1';
        wait for 20 sec;
        i_sw_lap_toggle <= '1';


        -- Reset while lap is active
        i_sw_reset <= '1';
        wait for 1 sec;
        i_sw_reset <= '0';

        wait for 15 sec;

        --------------------------------------------------------------------
        -- END SIMULATION
        --------------------------------------------------------------------
        report "Test complete";
        wait;
    end process;
end behavioral;
