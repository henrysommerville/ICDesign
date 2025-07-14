----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:55:49 04/30/2013 
-- Design Name: 
-- Module Name:    clockMain - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
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
use IEEE.std_logic_ARITH.ALL;
use IEEE.std_logic_UNSIGNED.ALL;

entity clock_module is
    Port ( clk : in  std_logic;
           reset : in  std_logic;
           en_1K : in  std_logic;
           en_100 : in  std_logic;
           en_10 : in  std_logic;
           en_1 : in  std_logic;
			  
           key_action_imp : in  std_logic;
			  key_action_long : in std_logic;
           key_mode_imp : in  std_logic;
           key_minus_imp : in  std_logic;
           key_plus_imp : in  std_logic;
           key_plus_minus : in  std_logic;
           key_enable : in  std_logic;
			  
           de_set : in  std_logic;
           de_dow : in  std_logic_vector (2 downto 0);
           de_day : in  std_logic_vector (5 downto 0);
           de_month : in  std_logic_vector (4 downto 0);
           de_year : in  std_logic_vector (7 downto 0);
           de_hour : in  std_logic_vector (5 downto 0);
           de_min : in  std_logic_vector (6 downto 0);
			  
           led_alarm_act : out  std_logic;
           led_alarm_ring : out  std_logic;
           led_countdown_act : out  std_logic;
           led_countdown_ring : out  std_logic;
           led_switch_act : out  std_logic;
           led_switch_on : out  std_logic;
			  
			  lcd_en : out std_logic;
			  lcd_rw : out std_logic;
			  lcd_rs : out std_logic;
			  lcd_data : out std_logic_vector(7 downto 0)
			  
			  -- OLED signal only for development
			  --oled_en : out std_logic;
			  --oled_dc : out std_logic;
			  --oled_data : out std_logic;
			  --oled_reset : out std_logic;
			  --oled_vdd : out std_logic;
			  --oled_vbat : out std_logic
		);
end clock_module;

architecture Behavioral of clock_module is

	    -- global FSM
    signal mode                 : STD_LOGIC_VECTOR (1 downto 0) := (others => '0');
	signal alarm_set_incr_min   : STD_LOGIC := '0';
	signal alarm_set_decr_min   : STD_LOGIC  := '0';
	signal alarm_toggle_active  : STD_LOGIC  := '0';
	signal alarm_snoozed        : STD_LOGIC  := '0';
	signal alarm_off            : STD_LOGIC  := '0';
	signal sw_start             : STD_LOGIC  := '0';
	signal sw_lap_toggle        : STD_LOGIC  := '0';
	signal sw_reset             : STD_LOGIC  := '0';

    -- Time Date Module
    signal td_dcf_show          : STD_LOGIC  := '0';
    signal td_dow               : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
    signal td_day               : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
    signal td_month             : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
    signal td_year              : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
    signal td_hour              : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
    signal td_min               : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
    signal td_sec               : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
    signal td_date_status       : STD_LOGIC  := '0';
    
    -- Stopwatch Module
    signal o_sw_time_hs         : STD_LOGIC_VECTOR(7 downto 0) := (others => '0'); 
    signal o_sw_time_s          : STD_LOGIC_VECTOR(7 downto 0) := (others => '0'); 
    signal o_sw_time_min        : STD_LOGIC_VECTOR(7 downto 0) := (others => '0'); 
    signal o_sw_time_h          : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal o_sw_lap             : STD_LOGIC := '0';                 
    
    
    -- Alarm Module
    signal alarm_ring           : STD_LOGIC := '0';
    signal alarm_act            : STD_LOGIC := '0';
    signal alarm_snooze         : STD_LOGIC := '0';
    signal alarm_hour           : std_logic_vector(7 downto 0) := "00000000";
    signal alarm_min            : std_logic_vector(7 downto 0) := "00000000";
                        
begin
	
    -- Time Date Main Module
	time_date_module : entity work.time_date_module
		port map(
                    -- DCF Decoder
                    de_set          => de_set,
                    de_dow          => de_dow,
                    de_day          => de_day,
                    de_month        => de_month,
                    de_year         => de_year,
                    de_hour         => de_hour,
                    de_min          => de_min,

                    -- global inputs
                    mode            => mode,
                    reset           => reset,
                    clk_10K         => clk,
                    
                    -- global outputs
                    td_dcf_show     => td_dcf_show,
                    td_dow          => td_dow,
                    td_day          => td_day,
                    td_month        => td_month,
                    td_year         => td_year,
                    td_hour         => td_hour,
                    td_min          => td_min,
                    td_sec          => td_sec,
                    td_date_status  => td_date_status
        );
        	
	 -- Stopwatch Main Module
	stopwatch_module : entity work.stopwatch_top
		port map(
                    --Generic
                    clk             => clk,                     -- 10kHz clock
                    reset           => reset,                     -- System hard reset
            
                    -- Input
                    i_sw_enable     => sw_start,                     -- enables stopwatch counting
                    i_sw_lap_toggle => sw_lap_toggle,                     -- Toggles lap display on/off
                    i_sw_reset      => sw_reset,                     -- Soft reset for stopwatch clock 
            
                    -- Output
                    o_sw_time_hs    => o_sw_time_hs, -- Time to display in hundredth of a second (BCD format)
                    o_sw_time_s     => o_sw_time_s, -- Time to display in seconds (BCD format)
                    o_sw_time_min   => o_sw_time_min, -- Time to display in mins (BCD format)
                    o_sw_time_h     => o_sw_time_h, -- Time to display in hours (BCD format)
                    o_sw_lap        => o_sw_lap                 -- Lap time toggle
        );

--	 -- LCD Main Module with fixed inputs
--	lcd_module : entity work.lcd
--		port map(
--		            mode            => "01",
--		            -- System signals
--                    clk             => clk,
--                    reset           => reset,
--                    en_100          => en_100,
--                    en_10           => en_10,
                    
--                    -- Time display inputs
--                    td_hour         => "00010010",
--                    td_min          => "00100010",
--                    td_sec          => "00000010",
--                    td_dcf_show     => '0',
                    
--                    -- Date display inputs
--                    td_dow          => "00000000",
--                    td_day          => "00101000",
--                    td_month        => "00000100",
--                    td_year         => "00000011",
                    
--                    -- Alarm inputs
--                    alarm_act       => '0',
--                    alarm_snooze    => '0',
--                    alarm_hour      => "00000000",
--                    alarm_min       => "00000000",
                    
--                    -- Stopwatch inputs
--                    sw_lap          => '0',
--                    sw_hour         => "00000000",
--                    sw_min          => "00000000",
--                    sw_sec          => "00000000",
--                    sw_hsec         => "00000000",
                    
--                    -- LCD hardware interface
--                    lcd_en          => lcd_en,
--                    lcd_rw          => lcd_rw,
--                    lcd_rs          => lcd_rs,
--                    lcd_data        => lcd_data
--        );
	 -- LCD Main Module
	lcd_module : entity work.lcd
		port map(
		            mode            => mode,
		            -- System signals
                    clk             => clk,
                    reset           => reset,
                    en_100          => en_100,
                    en_10           => en_10,
                    
                    -- Time display inputs
                    td_hour         => td_hour,
                    td_min          => td_min,
                    td_sec          => td_sec,
                    td_dcf_show     => td_dcf_show,
                    
                    -- Date display inputs
                    td_dow          => td_dow,
                    td_day          => td_day,
                    td_month        => td_month,
                    td_year         => td_year,
                    
                    -- Alarm inputs
                    alarm_act       => alarm_act,
                    alarm_snooze    => alarm_snoozed,
                    alarm_hour      => alarm_hour,
                    alarm_min       => alarm_min,
                    
                    -- Stopwatch inputs
                    sw_lap          => o_sw_lap,
                    sw_hour         => o_sw_time_h,
                    sw_min          => o_sw_time_min,
                    sw_sec          => o_sw_time_s,
                    sw_hsec         => o_sw_time_hs,
                    
                    -- LCD hardware interface
                    lcd_en          => lcd_en,
                    lcd_rw          => lcd_rw,
                    lcd_rs          => lcd_rs,
                    lcd_data        => lcd_data
        );

	 -- Global FSM Module
	global_fsm_module : entity work.global_fsm
		port map(
		 clk                => clk, 
        reset              =>  reset, 
	
	key_enable	   =>  key_enable,  
	key_action_impulse =>  key_action_imp, 
	key_action_long    =>  key_action_long, 
	key_mode_impulse   =>  key_mode_imp, 
	key_minus_impulse  =>  key_minus_imp, 
	key_plus_impulse   =>  key_plus_imp, 
	key_plus_minus     =>  key_plus_minus, 
	td_date_status	   =>  td_date_status, 
	alarm_ring         =>  alarm_ring, 
	

    -- mode = 00(normal), 01(date), 10(alarm), 11(stopwatch)
	mode 		   =>  mode, 
	alarm_set_incr_min =>  alarm_set_incr_min, 
	alarm_set_decr_min =>  alarm_set_decr_min, 
	alarm_toggle_active=>  alarm_toggle_active, 
	alarm_snoozed      =>  alarm_snoozed, 
	alarm_off          =>  alarm_off, 
	sw_start           =>  sw_start, 
	sw_lap_toggle      =>  sw_lap_toggle, 
	sw_reset           =>  sw_reset
		);
end Behavioral;

