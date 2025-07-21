-- Author : Pablo Morales Escandon
-- Create Date : 09/07/2025
-- Module Name : lcd_tb.vhd
-- Description : LCD Controller Testbench
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lcd_tb is
end entity lcd_tb;

architecture behavior of lcd_tb is

-- Component declaration
component lcd is
port (
    clk : in std_logic;
    reset : in std_logic;
    en_100 : in std_logic;
    en_10 : in std_logic;
    mode : in std_logic_vector(2 downto 0);
    td_hour : in std_logic_vector(7 downto 0);
    td_min : in std_logic_vector(7 downto 0);
    td_sec : in std_logic_vector(7 downto 0);
    td_dcf_show : in std_logic;
    td_dow : in std_logic_vector(7 downto 0);
    td_day : in std_logic_vector(7 downto 0);
    td_month : in std_logic_vector(7 downto 0);
    td_year : in std_logic_vector(7 downto 0);
    alarm_act : in std_logic;
    alarm_snooze : in std_logic;
    alarm_hour : in std_logic_vector(7 downto 0);
    alarm_min : in std_logic_vector(7 downto 0);
    sw_lap : in std_logic;
    sw_hour : in std_logic_vector(7 downto 0);
    sw_min : in std_logic_vector(7 downto 0);
    sw_sec : in std_logic_vector(7 downto 0);
    sw_hsec : in std_logic_vector(7 downto 0);
    -- Missing inputs that need to be added
    ts_hour_off : in std_logic_vector(7 downto 0);
    ts_min_off : in std_logic_vector(7 downto 0);
    ts_sec_off : in std_logic_vector(7 downto 0);
    ts_hour_on : in std_logic_vector(7 downto 0);
    ts_min_on : in std_logic_vector(7 downto 0);
    ts_sec_on : in std_logic_vector(7 downto 0);
    ts_on : in std_logic;
    ts_select : in std_logic;
    cd_hour : in std_logic_vector(7 downto 0);
    cd_min : in std_logic_vector(7 downto 0);
    cd_sec : in std_logic_vector(7 downto 0);
    cd_on : in std_logic;
    lcd_en : out std_logic;
    lcd_rw : out std_logic;
    lcd_rs : out std_logic;
    lcd_data : out std_logic_vector(7 downto 0)
);
end component;

-- Clock period definition
constant clk_period : time := 10 ns; -- 100MHz clock

-- Test signals
signal clk : std_logic := '0';
signal reset : std_logic := '1';
signal en_100 : std_logic := '0';
signal en_10 : std_logic := '0';
signal mode : std_logic_vector(2 downto 0) := "000";
signal td_hour : std_logic_vector(7 downto 0) := x"14";
signal td_min : std_logic_vector(7 downto 0) := x"35";
signal td_sec : std_logic_vector(7 downto 0) := x"42";
signal td_dcf_show : std_logic := '1';
signal td_dow : std_logic_vector(7 downto 0) := x"01";
signal td_day : std_logic_vector(7 downto 0) := x"09";
signal td_month : std_logic_vector(7 downto 0) := x"07";
signal td_year : std_logic_vector(7 downto 0) := x"25";
signal alarm_act : std_logic := '1';
signal alarm_snooze : std_logic := '0';
signal alarm_hour : std_logic_vector(7 downto 0) := x"07";
signal alarm_min : std_logic_vector(7 downto 0) := x"30";
signal sw_lap : std_logic := '0';
signal sw_hour : std_logic_vector(7 downto 0) := x"01";
signal sw_min : std_logic_vector(7 downto 0) := x"23";
signal sw_sec : std_logic_vector(7 downto 0) := x"45";
signal sw_hsec : std_logic_vector(7 downto 0) := x"67";

-- Missing signals that need to be added
signal ts_hour_off : std_logic_vector(7 downto 0) := x"22"; -- 22:00:00 off time
signal ts_min_off : std_logic_vector(7 downto 0) := x"00";
signal ts_sec_off : std_logic_vector(7 downto 0) := x"00";
signal ts_hour_on : std_logic_vector(7 downto 0) := x"06"; -- 06:30:00 on time
signal ts_min_on : std_logic_vector(7 downto 0) := x"30";
signal ts_sec_on : std_logic_vector(7 downto 0) := x"00";
signal ts_on : std_logic := '0'; -- Timer switch inactive
signal ts_select : std_logic := '0'; -- Selecting off time
signal cd_hour : std_logic_vector(7 downto 0) := x"01"; -- 01:15:30 countdown
signal cd_min : std_logic_vector(7 downto 0) := x"15";
signal cd_sec : std_logic_vector(7 downto 0) := x"30";
signal cd_on : std_logic := '0'; -- Countdown inactive

-- Output signals
signal lcd_en : std_logic;
signal lcd_rw : std_logic;
signal lcd_rs : std_logic;
signal lcd_data : std_logic_vector(7 downto 0);

-- Enable pulse generators
signal en_100_counter : integer := 0;
signal en_10_counter : integer := 0;

begin

-- Instantiate the Unit Under Test (UUT)
uut: lcd
port map (
    clk => clk,
    reset => reset,
    en_100 => en_100,
    en_10 => en_10,
    mode => mode,
    td_hour => td_hour,
    td_min => td_min,
    td_sec => td_sec,
    td_dcf_show => td_dcf_show,
    td_dow => td_dow,
    td_day => td_day,
    td_month => td_month,
    td_year => td_year,
    alarm_act => alarm_act,
    alarm_snooze => alarm_snooze,
    alarm_hour => alarm_hour,
    alarm_min => alarm_min,
    sw_lap => sw_lap,
    sw_hour => sw_hour,
    sw_min => sw_min,
    sw_sec => sw_sec,
    sw_hsec => sw_hsec,
    -- Missing port mappings added
    ts_hour_off => ts_hour_off,
    ts_min_off => ts_min_off,
    ts_sec_off => ts_sec_off,
    ts_hour_on => ts_hour_on,
    ts_min_on => ts_min_on,
    ts_sec_on => ts_sec_on,
    ts_on => ts_on,
    ts_select => ts_select,
    cd_hour => cd_hour,
    cd_min => cd_min,
    cd_sec => cd_sec,
    cd_on => cd_on,
    lcd_en => lcd_en,
    lcd_rw => lcd_rw,
    lcd_rs => lcd_rs,
    lcd_data => lcd_data
);

-- Clock generation
clk_process: process
begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
end process;

-- Enable pulse generation (100Hz and 10Hz)
enable_gen: process(clk, reset)
begin
    if reset = '1' then
        en_100_counter <= 0;
        en_10_counter <= 0;
        en_100 <= '0';
        en_10 <= '0';
    elsif rising_edge(clk) then
        -- Generate 100Hz enable (every 1000 clock cycles at 100MHz)
        if en_100_counter >= 999 then
            en_100_counter <= 0;
            en_100 <= '1';
        else
            en_100_counter <= en_100_counter + 1;
            en_100 <= '0';
        end if;
        
        -- Generate 10Hz enable (every 10000 clock cycles at 100MHz)
        if en_10_counter >= 9999 then
            en_10_counter <= 0;
            en_10 <= '1';
        else
            en_10_counter <= en_10_counter + 1;
            en_10 <= '0';
        end if;
    end if;
end process;

-- Main test stimulus process
stim_proc: process
begin
    -- Initial reset
    reset <= '1';
    wait for 100 ns;
    reset <= '0';
    
    -- Wait for initialization
    wait for 10 us;
    
    -- Test Mode 000 (Time)
    mode <= "000";
    wait for 200 us;
    
    -- Test Mode 001 (Date)
    mode <= "001";
    wait for 200 us;
    
    -- Test Mode 010 (Alarm)
    mode <= "010";
    wait for 200 us;
    
    -- Test Mode 011 (Stopwatch)
    mode <= "011";
    wait for 200 us;
    
    -- Test Mode 100 (Timer/Countdown)
    mode <= "100";
    cd_on <= '1'; -- Enable countdown
    wait for 200 us;
    
    -- Test Mode 101 (Time Switch On/Off)
    mode <= "101";
    ts_on <= '1'; -- Enable time switch
    wait for 200 us;
    
    -- Test time switch selection
    ts_select <= '1'; -- Select on time
    wait for 100 us;
    ts_select <= '0'; -- Select off time
    wait for 100 us;
    
    -- Test some signal variations
    td_dcf_show <= '0';
    wait for 50 us;
    td_dcf_show <= '1';
    wait for 50 us;
    
    alarm_snooze <= '1';
    wait for 50 us;
    alarm_snooze <= '0';
    wait for 50 us;
    
    sw_lap <= '1';
    wait for 50 us;
    sw_lap <= '0';
    wait for 50 us;
    
    -- Test countdown timer
    cd_on <= '0';
    wait for 50 us;
    cd_on <= '1';
    wait for 50 us;
    
    -- Test time switch off
    ts_on <= '0';
    wait for 50 us;
    
    -- End simulation
    wait;
end process;

end architecture behavior;
 2