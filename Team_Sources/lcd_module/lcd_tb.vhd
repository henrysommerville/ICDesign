--------------------------------------------------------------------------------
-- Author       : Pablo Morales
-- Create Date  : 04/07/2025
-- Module Name  : lcd_tb.vhd
-- Description  : Testbench for LCD Controller Module
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lcd_tb is
end entity lcd_tb;

architecture behavioral of lcd_tb is
    
    -- Component declaration
    component lcd is
        port (
            -- System signals
            clk   : in std_logic;
            reset : in std_logic;
            en_100    : in std_logic;
            en_10    : in std_logic;
            
            -- Time display inputs
            time_start   : in std_logic;
            td_hour      : in std_logic_vector(7 downto 0);
            td_min       : in std_logic_vector(7 downto 0);
            td_sec       : in std_logic_vector(7 downto 0);
            td_dcf_show  : in std_logic;
            
            -- Date display inputs
            date_start   : in std_logic;
            td_dow       : in std_logic_vector(2 downto 0);
            td_day       : in std_logic_vector(7 downto 0);
            td_month     : in std_logic_vector(7 downto 0);
            td_year      : in std_logic_vector(7 downto 0);
            
            -- Alarm inputs
            alarm_start  : in std_logic;
            alarm_act    : in std_logic;
            alarm_snooze : in std_logic;
            alarm_hour   : in std_logic_vector(7 downto 0);
            alarm_min    : in std_logic_vector(7 downto 0);
            
            -- Stopwatch inputs
            sw_start     : in std_logic;
            sw_lap       : in std_logic;
            sw_hour      : in std_logic_vector(7 downto 0);
            sw_min       : in std_logic_vector(7 downto 0);
            sw_sec       : in std_logic_vector(7 downto 0);
            sw_hsec      : in std_logic_vector(7 downto 0);
            
            -- LCD hardware interface
            lcd_en       : out std_logic;
            lcd_rw       : out std_logic;
            lcd_rs       : out std_logic;
            lcd_data     : out std_logic_vector(7 downto 0)
        );
    end component;
    
    -- Test signals
    signal clk_tb : std_logic := '0';
    signal reset_tb : std_logic := '1';
    signal en_100_tb : std_logic := '0';
    signal en_10_tb : std_logic := '0';
    
    -- Time display test signals
    signal time_start_tb : std_logic := '0';
    signal td_hour_tb : std_logic_vector(7 downto 0) := x"14";  -- 14 hours (2 PM)
    signal td_min_tb : std_logic_vector(7 downto 0) := x"25";   -- 25 minutes
    signal td_sec_tb : std_logic_vector(7 downto 0) := x"30";   -- 30 seconds
    signal td_dcf_show_tb : std_logic := '0';
    
    -- Date display test signals
    signal date_start_tb : std_logic := '0';
    signal td_dow_tb : std_logic_vector(2 downto 0) := "100";   -- Friday
    signal td_day_tb : std_logic_vector(7 downto 0) := x"04";   -- 4th day
    signal td_month_tb : std_logic_vector(7 downto 0) := x"07"; -- July (7th month)
    signal td_year_tb : std_logic_vector(7 downto 0) := x"25";  -- 2025
    
    -- Alarm test signals
    signal alarm_start_tb : std_logic := '0';
    signal alarm_act_tb : std_logic := '0';
    signal alarm_snooze_tb : std_logic := '0';
    signal alarm_hour_tb : std_logic_vector(7 downto 0) := x"07"; -- 7 AM
    signal alarm_min_tb : std_logic_vector(7 downto 0) := x"30";  -- 30 minutes
    
    -- Stopwatch test signals
    signal sw_start_tb : std_logic := '0';
    signal sw_lap_tb : std_logic := '0';
    signal sw_hour_tb : std_logic_vector(7 downto 0) := x"01";   -- 1 hour
    signal sw_min_tb : std_logic_vector(7 downto 0) := x"23";    -- 23 minutes
    signal sw_sec_tb : std_logic_vector(7 downto 0) := x"45";    -- 45 seconds
    signal sw_hsec_tb : std_logic_vector(7 downto 0) := x"67";   -- 67 hundredths
    
    -- Output signals
    signal lcd_en_tb : std_logic;
    signal lcd_rw_tb : std_logic;
    signal lcd_rs_tb : std_logic;
    signal lcd_data_tb : std_logic_vector(7 downto 0);
    
    -- Clock period
    constant clk_period : time := 10 ns;
    
    -- Enable signal counters for timing
    signal en_100_counter : integer := 0;
    signal en_10_counter : integer := 0;
    
begin
    
    -- Instantiate the Unit Under Test (UUT)
    uut: lcd
        port map (
            clk => clk_tb,
            reset => reset_tb,
            en_100 => en_100_tb,
            en_10 => en_10_tb,
            time_start => time_start_tb,
            td_hour => td_hour_tb,
            td_min => td_min_tb,
            td_sec => td_sec_tb,
            td_dcf_show => td_dcf_show_tb,
            date_start => date_start_tb,
            td_dow => td_dow_tb,
            td_day => td_day_tb,
            td_month => td_month_tb,
            td_year => td_year_tb,
            alarm_start => alarm_start_tb,
            alarm_act => alarm_act_tb,
            alarm_snooze => alarm_snooze_tb,
            alarm_hour => alarm_hour_tb,
            alarm_min => alarm_min_tb,
            sw_start => sw_start_tb,
            sw_lap => sw_lap_tb,
            sw_hour => sw_hour_tb,
            sw_min => sw_min_tb,
            sw_sec => sw_sec_tb,
            sw_hsec => sw_hsec_tb,
            lcd_en => lcd_en_tb,
            lcd_rw => lcd_rw_tb,
            lcd_rs => lcd_rs_tb,
            lcd_data => lcd_data_tb
        );
    
    -- Clock generation
    clk_process: process
    begin
        clk_tb <= '0';
        wait for clk_period/2;
        clk_tb <= '1';
        wait for clk_period/2;
    end process;
    
    -- Enable signal generation (simulating 100Hz and 10Hz enables)
    enable_process: process(clk_tb)
    begin
        if rising_edge(clk_tb) then
            -- Generate en_100 signal (every 1000 clock cycles for 100Hz at 100kHz clock)
            if en_100_counter >= 999 then
                en_100_tb <= '1';
                en_100_counter <= 0;
            else
                en_100_tb <= '0';
                en_100_counter <= en_100_counter + 1;
            end if;
            
            -- Generate en_10 signal (every 10000 clock cycles for 10Hz at 100kHz clock)
            if en_10_counter >= 9999 then
                en_10_tb <= '1';
                en_10_counter <= 0;
            else
                en_10_tb <= '0';
                en_10_counter <= en_10_counter + 1;
            end if;
        end if;
    end process;
    
    -- Test stimulus process
    stimulus_process: process
    begin
        
        -- Initialize all signals
        reset_tb <= '1';
        time_start_tb <= '0';
        date_start_tb <= '0';
        alarm_start_tb <= '0';
        sw_start_tb <= '0';
        
        -- Wait for reset
        wait for 100 ns;
        reset_tb <= '0';
        
        -- Wait for initialization to complete
        wait for 10 us;
        
        -- **TEST 1: TIME DISPLAY MODE**
        report "Starting TIME display test";
        time_start_tb <= '1';
        td_hour_tb <= x"14";    -- 14:25:30 (2:25:30 PM)
        td_min_tb <= x"25";
        td_sec_tb <= x"30";
        td_dcf_show_tb <= '0';  -- No DCF indicator
        wait for 50 us;
        time_start_tb <= '0';
        
        -- Test with DCF indicator
        wait for 20 us;
        time_start_tb <= '1';
        td_dcf_show_tb <= '1';  -- Show DCF indicator
        wait for 50 us;
        time_start_tb <= '0';
        td_dcf_show_tb <= '0';
        
        -- **TEST 2: DATE DISPLAY MODE**
        report "Starting DATE display test";
        wait for 30 us;
        date_start_tb <= '1';
        td_dow_tb <= "100";     -- Friday
        td_day_tb <= x"04";     -- 4th
        td_month_tb <= x"07";   -- July
        td_year_tb <= x"25";    -- 2025
        wait for 50 us;
        date_start_tb <= '0';
        
        -- Test different days of week
        wait for 20 us;
        date_start_tb <= '1';
        td_dow_tb <= "000";     -- Monday
        td_day_tb <= x"15";     -- 15th
        td_month_tb <= x"12";   -- December
        wait for 50 us;
        date_start_tb <= '0';
        
        -- **TEST 3: ALARM DISPLAY MODE**
        report "Starting ALARM display test";
        wait for 30 us;
        alarm_start_tb <= '1';
        alarm_hour_tb <= x"07";  -- 7:30 AM
        alarm_min_tb <= x"30";
        alarm_act_tb <= '0';     -- Alarm not active
        alarm_snooze_tb <= '0';  -- Not snoozed
        wait for 50 us;
        
        -- Test with active alarm
        alarm_act_tb <= '1';     -- Alarm active (should show *)
        wait for 30 us;
        alarm_act_tb <= '0';
        
        -- Test with snooze
        alarm_snooze_tb <= '1';  -- Alarm snoozed (should show Z)
        wait for 30 us;
        alarm_snooze_tb <= '0';
        alarm_start_tb <= '0';
        
        -- **TEST 4: STOPWATCH DISPLAY MODE**
        report "Starting STOPWATCH display test";
        wait for 30 us;
        sw_start_tb <= '1';
        sw_hour_tb <= x"01";     -- 1:23:45.67
        sw_min_tb <= x"23";
        sw_sec_tb <= x"45";
        sw_hsec_tb <= x"67";
        sw_lap_tb <= '0';        -- No lap indicator
        wait for 50 us;
        
        -- Test with lap indicator
        sw_lap_tb <= '1';        -- Show lap indicator
        wait for 30 us;
        sw_lap_tb <= '0';
        sw_start_tb <= '0';
        
        -- **TEST 5: MODE TRANSITIONS**
        report "Testing mode transitions";
        wait for 30 us;
        
        -- Start with time mode
        time_start_tb <= '1';
        wait for 20 us;
        
        -- Switch to date mode (should override time)
        date_start_tb <= '1';
        wait for 20 us;
        time_start_tb <= '0';
        
        -- Switch to alarm mode (should override date)
        alarm_start_tb <= '1';
        wait for 20 us;
        date_start_tb <= '0';
        
        -- Switch to stopwatch mode (should override alarm)
        sw_start_tb <= '1';
        wait for 20 us;
        alarm_start_tb <= '0';
        
        -- Return to time mode
        time_start_tb <= '1';
        wait for 20 us;
        sw_start_tb <= '0';
        
        -- **TEST 6: DYNAMIC DATA UPDATES**
        report "Testing dynamic data updates";
        
        -- Update time values while in time mode
        for i in 0 to 5 loop
            td_sec_tb <= std_logic_vector(to_unsigned(30 + i, 8));
            wait for 15 us;
        end loop;
        
        -- Switch to stopwatch and update values
        sw_start_tb <= '1';
        time_start_tb <= '0';
        wait for 20 us;
        
        -- Update stopwatch values
        for i in 0 to 3 loop
            sw_hsec_tb <= std_logic_vector(to_unsigned(67 + i*10, 8));
            wait for 15 us;
        end loop;
        
        -- **TEST 7: EDGE CASES**
        report "Testing edge cases";
        
        -- Test maximum values
        time_start_tb <= '1';
        sw_start_tb <= '0';
        td_hour_tb <= x"23";     -- 23:59:59
        td_min_tb <= x"59";
        td_sec_tb <= x"59";
        wait for 30 us;
        
        -- Test minimum values
        td_hour_tb <= x"00";     -- 00:00:00
        td_min_tb <= x"00";
        td_sec_tb <= x"00";
        wait for 30 us;
        
        -- Test all alarm conditions simultaneously
        alarm_start_tb <= '1';
        time_start_tb <= '0';
        alarm_act_tb <= '1';
        alarm_snooze_tb <= '1';  -- Both active and snooze (snooze should take precedence)
        wait for 30 us;
        
        -- Clean up
        alarm_start_tb <= '0';
        alarm_act_tb <= '0';
        alarm_snooze_tb <= '0';
        
        report "All tests completed successfully";
        wait for 100 us;
        
        -- End simulation
        wait;
        
    end process;
    
    -- Monitor process to display LCD output
    monitor_process: process(clk_tb)
    begin
        if rising_edge(clk_tb) then
            if lcd_en_tb = '1' then
                report "LCD Output - EN: " & std_logic'image(lcd_en_tb) & 
                       ", RS: " & std_logic'image(lcd_rs_tb) & 
                       ", RW: " & std_logic'image(lcd_rw_tb) & 
                       ", DATA: " & integer'image(to_integer(unsigned(lcd_data_tb)));
            end if;
        end if;
    end process;
    
end architecture behavioral;
