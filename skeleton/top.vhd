----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    23:31:29 08/26/2014 
-- Design Name: 
-- Module Name:    top - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top is
    Port ( clk : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           en_1K : in  STD_LOGIC;
           en_100 : in  STD_LOGIC;
           en_10 : in  STD_LOGIC;
           en_1 : in  STD_LOGIC;
           key_action : in  STD_LOGIC;
           key_mode : in  STD_LOGIC;
           key_minus : in  STD_LOGIC;
           key_plus : in  STD_LOGIC;
           dcf_data : in  STD_LOGIC;
           led_alarm_act : out  STD_LOGIC;
           led_alarm_ring : out  STD_LOGIC;
           led_countdown_act : out  STD_LOGIC;
           led_countdown_ring : out  STD_LOGIC;
           led_switch_act : out  STD_LOGIC;
           led_switch_on : out  STD_LOGIC;	  
           lcd_en : out std_logic;
           lcd_rw : out std_logic;
           lcd_rs : out std_logic;
           lcd_data : out std_logic_vector(7 downto 0)
	);
end top;

architecture Behavioral of top is
	signal key_action_imp       : STD_LOGIC := '0';
	signal key_action_long      : STD_LOGIC := '0';
	signal key_mode_imp         : STD_LOGIC := '0';
	signal key_minus_imp        : STD_LOGIC := '0';
	signal key_plus_imp         : STD_LOGIC := '0';
	signal key_plus_minus       : STD_LOGIC := '0';
	signal key_enable           : STD_LOGIC := '0';

	signal de_set               : STD_LOGIC := '0';
	signal de_dow               : STD_LOGIC_VECTOR (2 downto 0) := (others => '0');
	signal de_day               : STD_LOGIC_VECTOR (5 downto 0) := (others => '0');
	signal de_month             : STD_LOGIC_VECTOR (4 downto 0) := (others => '0');
	signal de_year              : STD_LOGIC_VECTOR (7 downto 0) := (others => '0');
	signal de_hour              : STD_LOGIC_VECTOR (5 downto 0) := (others => '0');
	signal de_min               : STD_LOGIC_VECTOR (6 downto 0) := (others => '0');

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

    -- Stopwatch Module
    signal o_sw_time_hs         : STD_LOGIC_VECTOR(7 downto 0) := (others => '0'); 
    signal o_sw_time_s          : STD_LOGIC_VECTOR(7 downto 0) := (others => '0'); 
    signal o_sw_time_min        : STD_LOGIC_VECTOR(7 downto 0) := (others => '0'); 
    signal o_sw_time_h          : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal o_sw_lap             : STD_LOGIC := (others => '0');                 


begin
	-- Key module
	key_control : entity work.key_control
		port map(
			clk => clk,
			reset => reset,
			en_10 => en_10,
			en_100 => en_100,
			btn_action => key_action,
			btn_mode => key_mode,
			btn_minus => key_minus,
			btn_plus => key_plus,
			action_imp => key_action_imp,
			action_long => key_action_long,
			mode_imp => key_mode_imp,
			minus_imp => key_minus_imp,
			plus_imp => key_plus_imp,
			plus_minus => key_plus_minus,
			enable => key_enable
		);

	-- DCF Decode
	dcf_decode : entity work.dcf_decode
		port map(
			clk => clk,
			reset => reset,
			en_100 => en_100,
			dcf => dcf_data,
			de_set => de_set,
			de_dow => de_dow,
			de_day => de_day,
			de_month => de_month,
			de_year => de_year,
			de_hour => de_hour,
			de_min => de_min
		);

	-- Clock Main Module
	clock_module : entity work.clock_module
		port map(
			clk => clk,
			reset => reset,
			en_1K => en_1K,
			en_100 => en_100,
			en_10 => en_10,
			en_1 => en_1,
			key_action_imp => key_action_imp,
			key_action_long => key_action_long,
			key_mode_imp => key_mode_imp,
			key_minus_imp => key_minus_imp,
			key_plus_imp => key_plus_imp,
			key_plus_minus => key_plus_minus,
			key_enable => key_enable,
			de_set => de_set,
			de_dow => de_dow,
			de_day => de_day,
			de_month => de_month,
			de_year => de_year,
			de_hour => de_hour,
			de_min => de_min,
			led_alarm_act => led_alarm_act,
			led_alarm_ring => led_alarm_ring,
			led_countdown_act => led_countdown_act,
			led_countdown_ring => led_countdown_ring,
			led_switch_act => led_switch_act,
			led_switch_on => led_switch_on,
			lcd_en => lcd_en,
			lcd_rw => lcd_rw,
			lcd_rs => lcd_rs,
			lcd_data => lcd_data
		);
		
		
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

	 -- LCD Main Module
	lcd_module : entity work.lcd_tb
		port map(
		            -- System signals
                    clk             => clk,
                    reset           => reset,
                    en_100          => en_100,
                    en_10           => en_10,
                    
                    -- Time display inputs
                    time_start      =>,
                    td_hour         => td_hour,
                    td_min          => td_min,
                    td_sec          => td_sec,
                    td_dcf_show     => td_dcf_show,
                    
                    -- Date display inputs
                    date_start      =>,
                    td_dow          => td_dow,
                    td_day          => td_day,
                    td_month        => td_month,
                    td_year         => td_year,
                    
                    -- Alarm inputs
                    alarm_start     =>,
                    alarm_act       =>,
                    alarm_snooze    => alarm_snoozed,
                    alarm_hour      => ,
                    alarm_min       => ,
                    
                    -- Stopwatch inputs
                    sw_start        => sw_start,
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

end Behavioral;
