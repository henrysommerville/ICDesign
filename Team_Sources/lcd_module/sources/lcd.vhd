--------------------------------------------------------------------------------
-- Author       : Pablo Morales  
-- Create Date  : 26/06/2025
-- Module Name  : lcd.vhd
-- Description  : LCD Controller for Digital Clock Display
--                Manages display of time, date, alarm, and stopwatch information
--                Uses internal buffer for command queuing and display updates
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lcd is
    port (
        -- System signals
        clk   : in std_logic;
        reset : in std_logic;
        en_100    : in std_logic;
        en_10    : in std_logic;

        -- Mode signal
        mode         : in std_logic_vector(1 downto 0);
        
        -- Time display inputs
        td_hour      : in std_logic_vector(7 downto 0);
        td_min       : in std_logic_vector(7 downto 0);
        td_sec       : in std_logic_vector(7 downto 0);
        td_dcf_show  : in std_logic;
        
        -- Date display inputs
        td_dow       : in std_logic_vector(2 downto 0);  -- Day of week
        td_day       : in std_logic_vector(7 downto 0);
        td_month     : in std_logic_vector(7 downto 0);
        td_year      : in std_logic_vector(7 downto 0);
        
        -- Alarm inputs
        alarm_act    : in std_logic;
        alarm_snooze : in std_logic;
        alarm_hour   : in std_logic_vector(7 downto 0);
        alarm_min    : in std_logic_vector(7 downto 0);
        
        -- Stopwatch inputs
        sw_lap       : in std_logic;
        sw_hour      : in std_logic_vector(7 downto 0);
        sw_min       : in std_logic_vector(7 downto 0);
        sw_sec       : in std_logic_vector(7 downto 0);
        sw_hsec      : in std_logic_vector(7 downto 0);  -- Hundredths of seconds
        
        -- LCD hardware interface
        lcd_en       : out std_logic;
        lcd_rw       : out std_logic;
        lcd_rs       : out std_logic;
        lcd_data     : out std_logic_vector(7 downto 0)
    );
end entity lcd;

architecture rtl of lcd is

    -- LCD Command Constants
    constant CMD_FUNCTION_SET  : std_logic_vector(9 downto 0) := "0000111000";  -- 8-bit, 2-line
    constant CMD_DISPLAY_OFF   : std_logic_vector(9 downto 0) := "0000001000";  -- Display off
    constant CMD_DISPLAY_CLEAR : std_logic_vector(9 downto 0) := "0000000001";  -- Clear display
    constant CMD_ENTRY_MODE    : std_logic_vector(9 downto 0) := "0000000110";  -- Auto increment
    constant CMD_DISPLAY_ON    : std_logic_vector(9 downto 0) := "0000001100";  -- Display on
    
    -- Address prefixes
    constant SET_ADDRESS_PREFIX : std_logic_vector(1 downto 0) := "00";
    constant WRITE_DATA_PREFIX  : std_logic_vector(1 downto 0) := "10";
    
    -- LCD Display Addresses (HD44780 compatible)
    constant TIME_ADDR         : std_logic_vector(7 downto 0) := x"87";  -- "Time:" label
    constant TIME_HOUR_ADDR   : std_logic_vector(7 downto 0) := x"C5";  -- Time value position
    constant DCF_ADDR          : std_logic_vector(7 downto 0) := x"CF";  -- DCF indicator
    constant DATE_ADDR         : std_logic_vector(7 downto 0) := x"9B";  -- "Date:" label
    constant DATE_VALUE_ADDR   : std_logic_vector(7 downto 0) := x"D8";  -- Date value position
    constant ALARM_ADDR        : std_logic_vector(7 downto 0) := x"9A";  -- "Alarm:" label
    constant ALARM_ACTIVE_ADDR : std_logic_vector(7 downto 0) := x"94";  -- Alarm active indicator
    constant ALARM_A_ADDR      : std_logic_vector(7 downto 0) := x"C0";  -- Alarm A
    constant ALARM_TIME_ADDR   : std_logic_vector(7 downto 0) := x"DB";  -- Alarm time position
    constant S_ADDR            : std_logic_vector(7 downto 0) := x"D3";  -- Letter S
    constant SW_ADDR    : std_logic_vector(7 downto 0) := x"97";  -- "Stop Watch:" label
    constant SW_TIME_ADDR      : std_logic_vector(7 downto 0) := x"D8";  -- Stopwatch time
    constant SW_LAP_ADDR       : std_logic_vector(7 downto 0) := x"D4";  -- Lap indicator
    
    -- Character Constants (ASCII codes)
    -- Uppercase letters
    constant LETTER_T_may : std_logic_vector(7 downto 0) := x"54";  -- 'T'
    constant LETTER_S_may : std_logic_vector(7 downto 0) := x"53";  -- 'S'
    constant LETTER_W_may : std_logic_vector(7 downto 0) := x"57";  -- 'W'
    constant LETTER_D_may : std_logic_vector(7 downto 0) := x"44";  -- 'D'
    constant LETTER_L_may : std_logic_vector(7 downto 0) := x"4C";  -- 'L'
    constant LETTER_C_may : std_logic_vector(7 downto 0) := x"43";  -- 'C'
    constant LETTER_M_may : std_logic_vector(7 downto 0) := x"4D";  -- 'M'
    constant LETTER_F_may : std_logic_vector(7 downto 0) := x"46";  -- 'F'
    constant LETTER_A_may : std_logic_vector(7 downto 0) := x"41";  -- 'A'
    constant LETTER_Z_may : std_logic_vector(7 downto 0) := x"5A";  -- 'Z'
    
    -- Lowercase letters
    constant LETTER_i : std_logic_vector(7 downto 0) := x"69";  -- 'i'
    constant LETTER_m : std_logic_vector(7 downto 0) := x"6D";  -- 'm'
    constant LETTER_e : std_logic_vector(7 downto 0) := x"65";  -- 'e'
    constant LETTER_t : std_logic_vector(7 downto 0) := x"74";  -- 't'
    constant LETTER_o : std_logic_vector(7 downto 0) := x"6F";  -- 'o'
    constant LETTER_p : std_logic_vector(7 downto 0) := x"70";  -- 'p'
    constant LETTER_a : std_logic_vector(7 downto 0) := x"61";  -- 'a'
    constant LETTER_c : std_logic_vector(7 downto 0) := x"63";  -- 'c'
    constant LETTER_h : std_logic_vector(7 downto 0) := x"68";  -- 'h'
    constant LETTER_l : std_logic_vector(7 downto 0) := x"6C";  -- 'l'
    constant LETTER_r : std_logic_vector(7 downto 0) := x"72";  -- 'r'
    
    -- Special characters
    constant COLON     : std_logic_vector(7 downto 0) := x"3A";  -- ':'
    constant ASTERISK  : std_logic_vector(7 downto 0) := x"2A";  -- '*'
    constant BLANK_SPACE     : std_logic_vector(7 downto 0) := x"20";  -- ' '
    constant BACKSLASH     : std_logic_vector(7 downto 0) := x"2F";  -- '/'
    constant DOT       : std_logic_vector(7 downto 0) := x"2E";  -- '.'
    
    -- Number prefix for ASCII conversion
    constant NUMBER_PREFIX : std_logic_vector(3 downto 0) := x"3";  -- ASCII '0' = 0x30
    
    -- State machine type
    type state_t is (ST_RESET, ST_INIT_WAIT, ST_WAIT, ST_TIME, ST_DATE, ST_ALARM, ST_SW);
    
    -- Type declarations
    subtype command_lcd is std_logic_vector(9 downto 0);
    
    -- Buffer declarations - Reduce buffer size to be more synthesis-friendly
    constant MAX_BUFFER : integer := 128; -- Reduced from 1000 to save resources
    type data_buffer is array (0 to MAX_BUFFER-1) of command_lcd;
    
    -- Signal declarations
    signal current_state : state_t := ST_RESET;
    signal init_done : std_logic := '0';
    signal lcd_buffer_update : std_logic := '0';
    signal lcd_buffer_update_sw : std_logic := '0';
    signal lcd_buffer_cnt : integer range 0 to MAX_BUFFER-1 := 0;
    signal lcd_buffer_cnt_init : integer range 0 to MAX_BUFFER-1 := 0;
    signal lcd_buffer_cnt_sw : integer range 0 to MAX_BUFFER-1 := 0;
    signal lcd_buffer : data_buffer := (others=>(others => '0'));
    signal lcd_buffer_init : data_buffer := (others=>(others => '0'));
    signal lcd_buffer_sw : data_buffer := (others=>(others => '0'));
    
    -- LCD control signals (internal)
    signal lcd_en_sg : std_logic := '1';
    signal lcd_rs_sg : std_logic := '0';
    signal lcd_rw_sg : std_logic := '0';
    signal lcd_data_sg : std_logic_vector(7 downto 0) := (others => '0');
    
    -- Initialization signals
    signal init_counter : integer range 0 to 1023 := 0;
    constant INIT_WAIT_CYCLES : integer := 700;
    
    -- Command formatting function (synthesizable)
    function format_cmd(prefix: std_logic_vector(1 downto 0); data: std_logic_vector(7 downto 0)) 
    return std_logic_vector is
        variable result : std_logic_vector(9 downto 0);
    begin
        result := prefix & data;
        return result;
    end function;

begin
        
    -- Buffer update process - handles content creation for display
    buffer_data_update : process(clk, reset)
        variable buffer_index : integer range 0 to MAX_BUFFER-1;
        variable buffer_index_sw : integer range 0 to MAX_BUFFER-1;
        variable lcd_cmd : std_logic_vector(9 downto 0);
    begin
        if reset = '1' then
            buffer_index := 0;
            buffer_index_sw := 0;
            lcd_buffer_update <= '0';
            lcd_buffer_update_sw <= '0';
            lcd_buffer <= (others=>(others => '0'));
            lcd_buffer_sw <= (others=>(others => '0'));
            lcd_buffer_cnt <= 0;
            lcd_buffer_cnt_sw <= 0;
            
        elsif rising_edge(clk) then
            if init_done = '1' then
                -- Update main display at 10Hz
                if en_10 = '1' then
                    buffer_index := 0;
                    
                    -- Clear display - always first command
                    lcd_buffer(buffer_index) <= CMD_DISPLAY_CLEAR;
                    buffer_index := buffer_index + 1;
                    
                    -- Always visible items regardless of mode
                    lcd_buffer(buffer_index) <= format_cmd(SET_ADDRESS_PREFIX, ALARM_A_ADDR);
                    buffer_index := buffer_index + 1;
                    lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, LETTER_A_may);
                    buffer_index := buffer_index + 1;
                    
                    lcd_buffer(buffer_index) <= format_cmd(SET_ADDRESS_PREFIX, ALARM_ACTIVE_ADDR);
                    buffer_index := buffer_index + 1;
                    if alarm_snooze = '1' then
                        lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, LETTER_Z_may);
                        buffer_index := buffer_index + 1;
                    elsif alarm_act = '1' then
                        lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, ASTERISK);
                        buffer_index := buffer_index + 1;
                    end if;
                    
                    lcd_buffer(buffer_index) <= format_cmd(SET_ADDRESS_PREFIX, S_ADDR);
                    buffer_index := buffer_index + 1;
                    lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, LETTER_S_may);
                    buffer_index := buffer_index + 1;
                    
                    -- Time display appears in all modes
                    lcd_buffer(buffer_index) <= format_cmd(SET_ADDRESS_PREFIX, TIME_ADDR);
                    buffer_index := buffer_index + 1;
                    lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, LETTER_T_may);
                    buffer_index := buffer_index + 1;
                    lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, LETTER_i);
                    buffer_index := buffer_index + 1;
                    lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, LETTER_m);
                    buffer_index := buffer_index + 1;
                    lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, LETTER_e);
                    buffer_index := buffer_index + 1;
                    lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, COLON);
                    buffer_index := buffer_index + 1;
                    
                    lcd_buffer(buffer_index) <= format_cmd(SET_ADDRESS_PREFIX, TIME_HOUR_ADDR);
                    buffer_index := buffer_index + 1;
                    lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, NUMBER_PREFIX & td_hour(7 downto 4));
                    buffer_index := buffer_index + 1;
                    lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, NUMBER_PREFIX & td_hour(3 downto 0));
                    buffer_index := buffer_index + 1;
                    lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, COLON);
                    buffer_index := buffer_index + 1;
                    lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, NUMBER_PREFIX & td_min(7 downto 4));
                    buffer_index := buffer_index + 1;
                    lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, NUMBER_PREFIX & td_min(3 downto 0));
                    buffer_index := buffer_index + 1;
                    lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, COLON);
                    buffer_index := buffer_index + 1;
                    lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, NUMBER_PREFIX & td_sec(7 downto 4));
                    buffer_index := buffer_index + 1;
                    lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, NUMBER_PREFIX & td_sec(3 downto 0));
                    buffer_index := buffer_index + 1;
                    
                    if td_dcf_show = '1' then
                        lcd_buffer(buffer_index) <= format_cmd(SET_ADDRESS_PREFIX, DCF_ADDR);
                        buffer_index := buffer_index + 1;
                        lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, LETTER_D_may);
                        buffer_index := buffer_index + 1;
                        lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, LETTER_C_may);
                        buffer_index := buffer_index + 1;
                        lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, LETTER_F_may);
                        buffer_index := buffer_index + 1;
                    end if;
                    
                    -- Mode-specific display content
                    case current_state is
                        when ST_DATE =>
                            -- Date display
                            lcd_buffer(buffer_index) <= format_cmd(SET_ADDRESS_PREFIX, DATE_ADDR);
                            buffer_index := buffer_index + 1;
                            lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, LETTER_D_may);
                            buffer_index := buffer_index + 1;
                            lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, LETTER_a);
                            buffer_index := buffer_index + 1;
                            lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, LETTER_t);
                            buffer_index := buffer_index + 1;
                            lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, LETTER_e);
                            buffer_index := buffer_index + 1;
                            lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, COLON);
                            buffer_index := buffer_index + 1;
                            
                            -- Day of week
                            case td_dow is
                                when "000" => 
                                    lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, LETTER_M_may);
                                    buffer_index := buffer_index + 1;
                                    lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, LETTER_o);
                                    buffer_index := buffer_index + 1;
                                when "001" => 
                                    lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, LETTER_D_may);
                                    buffer_index := buffer_index + 1;
                                    lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, LETTER_i);
                                    buffer_index := buffer_index + 1;
                                when "010" => 
                                    lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, LETTER_M_may);
                                    buffer_index := buffer_index + 1;
                                    lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, LETTER_i);
                                    buffer_index := buffer_index + 1;
                                when "011" => 
                                    lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, LETTER_D_may);
                                    buffer_index := buffer_index + 1;
                                    lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, LETTER_o);
                                    buffer_index := buffer_index + 1;
                                when "100" => 
                                    lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, LETTER_F_may);
                                    buffer_index := buffer_index + 1;
                                    lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, LETTER_r);
                                    buffer_index := buffer_index + 1;
                                when "101" => 
                                    lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, LETTER_S_may);
                                    buffer_index := buffer_index + 1;
                                    lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, LETTER_a);
                                    buffer_index := buffer_index + 1;
                                when "111" => 
                                    lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, LETTER_S_may);
                                    buffer_index := buffer_index + 1;
                                    lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, LETTER_o);
                                    buffer_index := buffer_index + 1;
                                when others => 
                                    -- Default case for synthesis
                                    lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, BLANK_SPACE);
                                    buffer_index := buffer_index + 1;
                                    lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, BLANK_SPACE);
                                    buffer_index := buffer_index + 1;
                            end case;
                            
                            lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, BLANK_SPACE);
                            buffer_index := buffer_index + 1;
                            lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, NUMBER_PREFIX & td_day(7 downto 4));
                            buffer_index := buffer_index + 1;
                            lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, NUMBER_PREFIX & td_day(3 downto 0));
                            buffer_index := buffer_index + 1;
                            lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, BACKSLASH);
                            buffer_index := buffer_index + 1;
                            lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, NUMBER_PREFIX & td_month(7 downto 4));
                            buffer_index := buffer_index + 1;
                            lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, NUMBER_PREFIX & td_month(3 downto 0));
                            buffer_index := buffer_index + 1;
                            lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, BACKSLASH);
                            buffer_index := buffer_index + 1;
                            lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, NUMBER_PREFIX & td_year(7 downto 4));
                            buffer_index := buffer_index + 1;
                            lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, NUMBER_PREFIX & td_year(3 downto 0));
                            buffer_index := buffer_index + 1;
                            
                        when ST_ALARM =>
                            -- Alarm display
                            lcd_buffer(buffer_index) <= format_cmd(SET_ADDRESS_PREFIX, ALARM_ADDR);
                            buffer_index := buffer_index + 1;
                            lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, LETTER_A_may);
                            buffer_index := buffer_index + 1;
                            lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, LETTER_l);
                            buffer_index := buffer_index + 1;
                            lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, LETTER_a);
                            buffer_index := buffer_index + 1;
                            lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, LETTER_r);
                            buffer_index := buffer_index + 1;
                            lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, LETTER_m);
                            buffer_index := buffer_index + 1;
                            lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, COLON);
                            buffer_index := buffer_index + 1;
                            
                            -- Alarm time
                            lcd_buffer(buffer_index) <= format_cmd(SET_ADDRESS_PREFIX, ALARM_TIME_ADDR);
                            buffer_index := buffer_index + 1;
                            lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, NUMBER_PREFIX & alarm_hour(7 downto 4));
                            buffer_index := buffer_index + 1;
                            lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, NUMBER_PREFIX & alarm_hour(3 downto 0));
                            buffer_index := buffer_index + 1;
                            lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, COLON);
                            buffer_index := buffer_index + 1;
                            lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, NUMBER_PREFIX & alarm_min(7 downto 4));
                            buffer_index := buffer_index + 1;
                            lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, NUMBER_PREFIX & alarm_min(3 downto 0));
                            buffer_index := buffer_index + 1;
                            
                        when ST_SW =>
                            -- Stopwatch display
                            lcd_buffer(buffer_index) <= format_cmd(SET_ADDRESS_PREFIX, SW_ADDR);
                            buffer_index := buffer_index + 1;
                            lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, LETTER_S_may);
                            buffer_index := buffer_index + 1;
                            lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, LETTER_t);
                            buffer_index := buffer_index + 1;
                            lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, LETTER_o);
                            buffer_index := buffer_index + 1;
                            lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, LETTER_p);
                            buffer_index := buffer_index + 1;
                            lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, BLANK_SPACE);
                            buffer_index := buffer_index + 1;
                            lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, LETTER_W_may);
                            buffer_index := buffer_index + 1;
                            lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, LETTER_a);
                            buffer_index := buffer_index + 1;
                            lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, LETTER_t);
                            buffer_index := buffer_index + 1;
                            lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, LETTER_c);
                            buffer_index := buffer_index + 1;
                            lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, LETTER_h);
                            buffer_index := buffer_index + 1;
                            lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, COLON);
                            buffer_index := buffer_index + 1;
                            
                            -- LAP display
                            if sw_lap = '1' then
                                lcd_buffer(buffer_index) <= format_cmd(SET_ADDRESS_PREFIX, SW_LAP_ADDR);
                                buffer_index := buffer_index + 1;
                                lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, LETTER_L_may);
                                buffer_index := buffer_index + 1;
                                lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, LETTER_a);
                                buffer_index := buffer_index + 1;
                                lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, LETTER_p);
                                buffer_index := buffer_index + 1;
                            end if;
                            
                        when others =>
                            -- Default is time mode - no additional displays needed
                            null;
                    end case;
                    
                    -- Update buffer and signal update
                    lcd_buffer_cnt <= buffer_index;
                    lcd_buffer_update <= not lcd_buffer_update;
                end if;
                
                -- Update stopwatch display at 100Hz for smooth animation
                if en_100 = '1' and current_state = ST_SW then
                    buffer_index_sw := 0;
                    
                    -- Stopwatch time display (updated at higher rate)
                    lcd_buffer_sw(buffer_index_sw) := format_cmd(SET_ADDRESS_PREFIX, SW_TIME_ADDR);
                    buffer_index_sw := buffer_index_sw + 1;
                    lcd_buffer_sw(buffer_index_sw) := format_cmd(WRITE_DATA_PREFIX, NUMBER_PREFIX & sw_hour(7 downto 4));
                    buffer_index_sw := buffer_index_sw + 1;
                    lcd_buffer_sw(buffer_index_sw) := format_cmd(WRITE_DATA_PREFIX, NUMBER_PREFIX & sw_hour(3 downto 0));
                    buffer_index_sw := buffer_index_sw + 1;
                    lcd_buffer_sw(buffer_index_sw) := format_cmd(WRITE_DATA_PREFIX, COLON);
                    buffer_index_sw := buffer_index_sw + 1;
                    lcd_buffer_sw(buffer_index_sw) := format_cmd(WRITE_DATA_PREFIX, NUMBER_PREFIX & sw_min(7 downto 4));
                    buffer_index_sw := buffer_index_sw + 1;
                    lcd_buffer_sw(buffer_index_sw) := format_cmd(WRITE_DATA_PREFIX, NUMBER_PREFIX & sw_min(3 downto 0));
                    buffer_index_sw := buffer_index_sw + 1;
                    lcd_buffer_sw(buffer_index_sw) := format_cmd(WRITE_DATA_PREFIX, COLON);
                    buffer_index_sw := buffer_index_sw + 1;
                    lcd_buffer_sw(buffer_index_sw) := format_cmd(WRITE_DATA_PREFIX, NUMBER_PREFIX & sw_sec(7 downto 4));
                    buffer_index_sw := buffer_index_sw + 1;
                    lcd_buffer_sw(buffer_index_sw) := format_cmd(WRITE_DATA_PREFIX, NUMBER_PREFIX & sw_sec(3 downto 0));
                    buffer_index_sw := buffer_index_sw + 1;
                    lcd_buffer_sw(buffer_index_sw) := format_cmd(WRITE_DATA_PREFIX, DOT);
                    buffer_index_sw := buffer_index_sw + 1;
                    lcd_buffer_sw(buffer_index_sw) := format_cmd(WRITE_DATA_PREFIX, NUMBER_PREFIX & sw_hsec(7 downto 4));
                    buffer_index_sw := buffer_index_sw + 1;
                    lcd_buffer_sw(buffer_index_sw) := format_cmd(WRITE_DATA_PREFIX, NUMBER_PREFIX & sw_hsec(3 downto 0));
                    buffer_index_sw := buffer_index_sw + 1;
                    
                    lcd_buffer_cnt_sw <= buffer_index_sw;
                    lcd_buffer_update_sw <= not lcd_buffer_update_sw;
                end if;
            end if;
        end if;
    end process buffer_data_update;
    
    -- LCD data send process - handles the timing and output of commands
    lcd_send_data : process(clk, reset)
        variable prev_buffer_update : std_logic := '0';
        variable prev_buffer_update_sw : std_logic := '0';
        variable read_index : integer range 0 to MAX_BUFFER-1 := 0;
        variable read_index_sw : integer range 0 to MAX_BUFFER-1 := 0;
        variable current_cmd : std_logic_vector(9 downto 0) := (others => '0');
        variable lcd_toggle : std_logic := '0';
    begin
        if reset = '1' then
            prev_buffer_update := '0';
            prev_buffer_update_sw := '0';
            read_index := 0;
            read_index_sw := 0;
            lcd_toggle := '0';
            lcd_en_sg <= '1';
            lcd_rs_sg <= '0';
            lcd_rw_sg <= '0';
            lcd_data_sg <= (others => '0');
            
        elsif rising_edge(clk) then
            -- Check if any buffer has been updated
            if prev_buffer_update /= lcd_buffer_update then
                prev_buffer_update := lcd_buffer_update;
                read_index := 0;
            end if;
            
            if prev_buffer_update_sw /= lcd_buffer_update_sw then
                prev_buffer_update_sw := lcd_buffer_update_sw;
                read_index_sw := 0;
            end if;
            
            -- Toggle LCD enable for proper timing
            if lcd_toggle = '0' then
                lcd_toggle := '1';
                lcd_en_sg <= '1';
                
                -- Priority to stopwatch updates (more time-sensitive)
                if read_index_sw < lcd_buffer_cnt_sw then
                    current_cmd := lcd_buffer_sw(read_index_sw);
                    read_index_sw := read_index_sw + 1;
                elsif read_index < lcd_buffer_cnt then
                    current_cmd := lcd_buffer(read_index);
                    read_index := read_index + 1;
                end if;
                
                -- Set LCD control signals
                lcd_rs_sg <= current_cmd(9);
                lcd_rw_sg <= current_cmd(8);
                lcd_data_sg <= current_cmd(7 downto 0);
                
            else
                -- Complete the enable pulse cycle
                lcd_toggle := '0';
                lcd_en_sg <= '0';
            end if;
        end if;
    end process lcd_send_data;
            
    -- LCD State Machine Process - controls the display mode
    lcd_state_machine_proc : process(clk, reset)
        variable init_buffer_index : integer range 0 to MAX_BUFFER-1;
    begin
        if reset = '1' then
            current_state <= ST_RESET;
            init_done <= '0';
            init_counter <= 0;
            init_buffer_index := 0;
            lcd_buffer_init <= (others=>(others => '0'));
            lcd_buffer_cnt_init <= 0;
            
        elsif rising_edge(clk) then
            case current_state is
                when ST_RESET =>
                    -- Prepare LCD initialization sequence
                    init_buffer_index := 0;
                    
                    -- Initial delay commands (NOP commands)
                    for i in 0 to 15 loop
                        lcd_buffer_init(init_buffer_index) := (others => '0');
                        init_buffer_index := init_buffer_index + 1;
                    end loop;
                    
                    -- Function set command repeated for stability
                    for i in 0 to 2 loop
                        lcd_buffer_init(init_buffer_index) := CMD_FUNCTION_SET;
                        init_buffer_index := init_buffer_index + 1;
                    end loop;
                    
                    -- Basic configuration commands
                    lcd_buffer_init(init_buffer_index) := CMD_DISPLAY_OFF;
                    init_buffer_index := init_buffer_index + 1;
                    
                    lcd_buffer_init(init_buffer_index) := CMD_DISPLAY_CLEAR;
                    init_buffer_index := init_buffer_index + 1;
                    
                    lcd_buffer_init(init_buffer_index) := CMD_ENTRY_MODE;
                    init_buffer_index := init_buffer_index + 1;
                    
                    lcd_buffer_init(init_buffer_index) := CMD_DISPLAY_ON;
                    init_buffer_index := init_buffer_index + 1;
                    
                    lcd_buffer_cnt_init <= init_buffer_index;
                    current_state <= ST_INIT_WAIT;
                    
                when ST_INIT_WAIT =>
                    -- Wait for initialization to complete
                    if init_counter < INIT_WAIT_CYCLES then
                        init_counter <= init_counter + 1;
                    else
                        init_done <= '1';
                        current_state <= ST_WAIT;
                    end if;
                    
                when ST_WAIT =>
                    -- Determine next state based on mode input
                    case mode is
                        when "00" => current_state <= ST_TIME;
                        when "01" => current_state <= ST_DATE;
                        when "10" => current_state <= ST_ALARM;
                        when "11" => current_state <= ST_SW;
                        when others => current_state <= ST_TIME; -- Default for synthesis
                    end case;

                -- For all display states, handle mode changes
                when ST_TIME | ST_DATE | ST_ALARM | ST_SW =>
                    -- Change state based on mode input
                    case mode is
                        when "00" => current_state <= ST_TIME;
                        when "01" => current_state <= ST_DATE;
                        when "10" => current_state <= ST_ALARM;
                        when "11" => current_state <= ST_SW;
                        when others => current_state <= ST_TIME; -- Default for synthesis
                    end case;
            end case;
        end if;
    end process lcd_state_machine_proc;
    
    -- Connect internal signals to outputs
    lcd_en <= lcd_en_sg;
    lcd_rs <= lcd_rs_sg;
    lcd_rw <= lcd_rw_sg;
    lcd_data <= lcd_data_sg;

end architecture rtl;