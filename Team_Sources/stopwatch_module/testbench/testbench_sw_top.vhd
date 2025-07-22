----------------------------------------------------------------------------------
-- Engineer: Henry Sommerville 
-- 
-- Design Name: 
-- Module Name: stopwatch_top_tb
-- Project Name: Project Laboratory IC Design
-- Target Devices: Xilinx Zynq-7000 (XC7Z020-3CLG484)
-- Tool Versions: Vivado 2019.1 
-- Description: Test bench for stopwatch top module
-- 
-- Dependencies: IEEE, IEEE.STD_LOGIC_1164, IEEE.NUMERIC_STD.ALL
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
            o_sw_lap          : out STD_LOGIC;                    -- Lap time toggle
            o_sw_active       : out STD_LOGIC
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
        signal o_sw_active      : STD_LOGIC;

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
            o_sw_lap         => o_sw_lap,
            o_sw_active      => o_sw_active
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

    stim_proc : process
    begin
        -- RESET
        reset <= '1'; wait for 200 us; reset <= '0'; wait for 1 ms;

--        -- TEST 1: Start / Stop
        i_sw_enable <= '1'; wait for 50 ms;
        i_sw_enable <= '0'; wait for 15 ms;
        i_sw_enable <= '1'; wait for 3 sec;
        i_sw_enable <= '0'; wait for 10000 ms;
        
--        assert o_sw_active = '0' report "[TEST1] Stopwatch should not be running" severity note;
--        assert o_sw_time_hs = x"00" report "[TEST1] Check hs" severity note;
--        assert o_sw_time_s = x"05" report "[TEST1] Check seconds (placeholder)" severity note;
    --    assert o_sw_time_min = x"00" report "[TEST1] Check minutes" severity note;
  --      assert o_sw_time_h = x"00" report "[TEST1] Check Hours" severity note;
--        assert o_sw_lap = '0' report "[TEST1] Check Lap" severity note;
        
        -- RESET
        reset <= '1'; wait for 200 us; reset <= '0'; wait for 1 ms;

--         TEST 2: Lap Toggle While Running
        i_sw_enable <= '1'; wait for  4000 sec;
        i_sw_lap_toggle <= '1'; wait for 50 ms;
        i_sw_lap_toggle <= '0'; wait for 100 sec;
        i_sw_enable <= '0'; wait for 1 sec;
        
                
--        -- RESET
        reset <= '1'; wait for 200 us; reset <= '0'; wait for 1 ms;

----        -- TEST 3: Reset During Counting
        i_sw_enable <= '1'; wait for 2 sec;
        i_sw_enable <= '0';
        i_sw_reset <= '1'; wait for 10 ms; i_sw_reset <= '0'; wait for 2 sec;
        
        wait for 20 sec;

--        -- RESET
        reset <= '1'; wait for 200 us; reset <= '0'; wait for 1 ms;

----        -- TEST 4: Rollover Test (simulate up to 1 hour)
        i_sw_enable <= '1'; 
        wait for 60 sec; -- 1 min
        wait for 60 sec; -- 2 min
        wait for 60 sec; -- 3 min
        wait for 60 sec; -- 4 min
        wait for 60 sec; -- 5 min
        wait for 60 sec; -- 6 min
        wait for 60 sec; -- 7 min
        wait for 60 sec; -- 8 min
        wait for 60 sec; -- 9 min
        wait for 60 sec; -- 10 min
        wait for 60 sec; -- 11 min
        wait for 60 sec; -- 12 min
        wait for 60 sec; -- 13 min
        wait for 60 sec; -- 14 min
        wait for 60 sec; -- 15 min
        wait for 60 sec; -- 16 min
        wait for 60 sec; -- 17 min
        wait for 60 sec; -- 18 min
        wait for 60 sec; -- 19 min
        wait for 60 sec; -- 20 min
        wait for 60 sec; -- 21 min
        wait for 60 sec; -- 22 min
        wait for 60 sec; -- 23 min
        wait for 60 sec; -- 24 min
        wait for 60 sec; -- 25 min
        wait for 60 sec; -- 26 min
        wait for 60 sec; -- 27 min
        wait for 60 sec; -- 28 min
        wait for 60 sec; -- 29 min
        wait for 60 sec; -- 30 min
        wait for 60 sec; -- 31 min
        wait for 60 sec; -- 32 min
        wait for 60 sec; -- 33 min
        wait for 60 sec; -- 34 min
        wait for 60 sec; -- 35 min
        wait for 60 sec; -- 36 min
        wait for 60 sec; -- 37 min
        wait for 60 sec; -- 38 min
        wait for 60 sec; -- 39 min
        wait for 60 sec; -- 40 min
        wait for 60 sec; -- 41 min
        wait for 60 sec; -- 42 min
        wait for 60 sec; -- 43 min
        wait for 60 sec; -- 44 min
        wait for 60 sec; -- 45 min
        wait for 60 sec; -- 46 min
        wait for 60 sec; -- 47 min
        wait for 60 sec; -- 48 min
        wait for 60 sec; -- 49 min
        wait for 60 sec; -- 50 min
        wait for 60 sec; -- 51 min
        wait for 60 sec; -- 52 min
        wait for 60 sec; -- 53 min
        wait for 60 sec; -- 54 min
        wait for 60 sec; -- 55 min
        wait for 60 sec; -- 56 min
        wait for 60 sec; -- 57 min
        wait for 60 sec; -- 58 min
        wait for 60 sec; -- 59 min
        wait for 60 sec; -- 60 min (1 hour rollover)
        wait for 1 sec;
        i_sw_enable <= '0'; wait for 2 sec;

        -- TEST 5: Glitch Test - Short pulses
        i_sw_enable <= '1'; wait for 50 ms; i_sw_enable <= '0'; wait for 1 sec;
        i_sw_lap_toggle <= '1'; wait for 20 ms; i_sw_lap_toggle <= '0'; wait for 1 sec;
        i_sw_reset <= '1'; wait for 30 ms; i_sw_reset <= '0'; wait for 1 sec;

        report "Simulation complete";
        wait;
    end process;
end Behavioral;
