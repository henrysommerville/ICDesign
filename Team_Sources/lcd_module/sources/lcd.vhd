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
    type state_t is (ST_RESET, ST_WAIT, ST_TIME, ST_DATE, ST_ALARM, ST_SW);
    
    -- Type declarations
    subtype command_lcd is std_logic_vector(9 downto 0);
    
    -- Buffer declarations
    constant MAX : integer := 1000; -- Data buffer is updated at 10Hz speed, and outputed at 10kHz, 
    type data_buffer is array (0 to MAX-1) of command_lcd;
    
    -- Signal declarations
    signal current_state : state_t := ST_RESET;
    signal init_done : std_logic := '0';
    signal lcd_buffer_update : std_logic := '0';
    signal lcd_buffer_update_sw : std_logic := '0';
    signal lcd_buffer_cnt : integer range 0 to MAX -1 := 0;
    signal lcd_buffer_cnt_init : integer range 0 to MAX -1 := 0;
    signal lcd_buffer_cnt_sw : integer range 0 to MAX -1 := 0;
    signal lcd_buffer : data_buffer := (others=>(others => '0'));
    signal lcd_buffer_init : data_buffer := (others=>(others => '0'));
    signal lcd_buffer_sw : data_buffer := (others=>(others => '0'));
    signal lcd_buffer_empty : data_buffer := (others=>(others => '0'));
    signal lcd_en_sg : std_logic := '1';
    signal lcd_rs_sg : std_logic := '0';
    signal lcd_rw_sg : std_logic := '0';
    signal lcd_data_sg : std_logic_vector(7 downto 0) := (others => '0');

begin
        
    buffer_data_update : process(clk, reset)
        variable internal_buffer_index : integer range 0 to MAX -1;
        variable internal_buffer_index_sw : integer range 0 to MAX -1;
        variable internal_buffer : data_buffer;
        variable internal_buffer_sw : data_buffer;

        procedure append(
            variable in_buffer : inout data_buffer;
            variable in_buffer_index : inout integer;
            constant new_input : in command_lcd
        ) is
        begin
            in_buffer(in_buffer_index) := new_input;
            in_buffer_index := in_buffer_index + 1;
        end procedure;
        
    begin
        if reset = '1' then
            internal_buffer_index := 0;
            internal_buffer_index_sw := 0;
            internal_buffer := (others=>(others => '0'));
            internal_buffer_sw := (others=>(others => '0'));
        elsif rising_edge(clk) then
            if init_done = '1' then
                if en_10 = '1' then
                    -- Clear display
                    append(internal_buffer, internal_buffer_index, CMD_DISPLAY_CLEAR);
                    -- Always on display
                    append(internal_buffer, internal_buffer_index, SET_ADDRESS_PREFIX & ALARM_A_ADDR);
                    append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & LETTER_A_may);
                    append(internal_buffer, internal_buffer_index, SET_ADDRESS_PREFIX & ALARM_ACTIVE_ADDR);
                    if alarm_snooze = '1' then
                        append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & LETTER_Z_may);
                    elsif alarm_act = '1' then
                        append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & ASTERISK);
                    end if;
                    append(internal_buffer, internal_buffer_index, SET_ADDRESS_PREFIX & S_ADDR);
                    append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & LETTER_S_may);
                    if current_state = ST_TIME then
                        -- Output time information
                        append(internal_buffer, internal_buffer_index, SET_ADDRESS_PREFIX & TIME_ADDR);
                        append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & LETTER_T_may);
                        append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & LETTER_i);
                        append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & LETTER_m);
                        append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & LETTER_e);
                        append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & COLON);
                        append(internal_buffer, internal_buffer_index, SET_ADDRESS_PREFIX & TIME_HOUR_ADDR);
                        append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & NUMBER_PREFIX & td_hour(7 downto 4));
                        append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & NUMBER_PREFIX & td_hour(3 downto 0));
                        append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & COLON);
                        append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & NUMBER_PREFIX & td_min(7 downto 4));
                        append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & NUMBER_PREFIX & td_min(3 downto 0));
                        append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & COLON);
                        append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & NUMBER_PREFIX & td_sec(7 downto 4));
                        append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & NUMBER_PREFIX & td_sec(3 downto 0));
                        if td_dcf_show = '1' then
                            append(internal_buffer, internal_buffer_index, SET_ADDRESS_PREFIX & DCF_ADDR);
                            append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & LETTER_D_may);
                            append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & LETTER_C_may);
                            append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & LETTER_F_may);
                        end if;

                    elsif current_state = ST_DATE then
                        -- Output time information
                        append(internal_buffer, internal_buffer_index, SET_ADDRESS_PREFIX & TIME_ADDR);
                        append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & LETTER_T_may);
                        append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & LETTER_i);
                        append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & LETTER_m);
                        append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & LETTER_e);
                        append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & COLON);
                        append(internal_buffer, internal_buffer_index, SET_ADDRESS_PREFIX & TIME_HOUR_ADDR);
                        append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & NUMBER_PREFIX & td_hour(7 downto 4));
                        append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & NUMBER_PREFIX & td_hour(3 downto 0));
                        append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & COLON);
                        append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & NUMBER_PREFIX & td_min(7 downto 4));
                        append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & NUMBER_PREFIX & td_min(3 downto 0));
                        append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & COLON);
                        append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & NUMBER_PREFIX & td_sec(7 downto 4));
                        append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & NUMBER_PREFIX & td_sec(3 downto 0));
                        if td_dcf_show = '1' then
                            append(internal_buffer, internal_buffer_index, SET_ADDRESS_PREFIX & DCF_ADDR);
                            append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & LETTER_D_may);
                            append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & LETTER_C_may);
                            append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & LETTER_F_may);
                        end if;
                        -- Output date information
                        -- Date word
                        append(internal_buffer, internal_buffer_index, SET_ADDRESS_PREFIX & DATE_ADDR);
                        append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & LETTER_D_may);
                        append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & LETTER_a);
                        append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & LETTER_t);
                        append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & LETTER_e);
                        append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & COLON);
                        -- Actual date
                        case td_dow is
                            when "000" => append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & LETTER_M_may); append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & LETTER_o);
                            when "001" => append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & LETTER_D_may); append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & LETTER_i);
                            when "010" => append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & LETTER_M_may); append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & LETTER_i);
                            when "011" => append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & LETTER_D_may); append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & LETTER_o);
                            when "100" => append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & LETTER_F_may); append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & LETTER_r);
                            when "101" => append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & LETTER_S_may); append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & LETTER_a);
                            when "111" => append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & LETTER_S_may); append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & LETTER_o);
                            when others => null;
                        end case;
                        append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & BLANK_SPACE);
                        append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & NUMBER_PREFIX & td_day(7 downto 4));
                        append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & NUMBER_PREFIX & td_day(3 downto 0));
                        append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & BACKSLASH);
                        append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & NUMBER_PREFIX & td_month(7 downto 4));
                        append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & NUMBER_PREFIX & td_month(3 downto 0));
                        append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & BACKSLASH);
                        append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & NUMBER_PREFIX & td_year(7 downto 4));
                        append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & NUMBER_PREFIX & td_year(3 downto 0));
                    
                    elsif current_state = ST_ALARM then
                        -- Output time information
                        append(internal_buffer, internal_buffer_index, SET_ADDRESS_PREFIX & TIME_ADDR);
                        append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & LETTER_T_may);
                        append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & LETTER_i);
                        append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & LETTER_m);
                        append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & LETTER_e);
                        append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & COLON);
                        append(internal_buffer, internal_buffer_index, SET_ADDRESS_PREFIX & TIME_HOUR_ADDR);
                        append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & NUMBER_PREFIX & td_hour(7 downto 4));
                        append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & NUMBER_PREFIX & td_hour(3 downto 0));
                        append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & COLON);
                        append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & NUMBER_PREFIX & td_min(7 downto 4));
                        append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & NUMBER_PREFIX & td_min(3 downto 0));
                        append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & COLON);
                        append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & NUMBER_PREFIX & td_sec(7 downto 4));
                        append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & NUMBER_PREFIX & td_sec(3 downto 0));
                        if td_dcf_show = '1' then
                            append(internal_buffer, internal_buffer_index, SET_ADDRESS_PREFIX & DCF_ADDR);
                            append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & LETTER_D_may);
                            append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & LETTER_C_may);
                            append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & LETTER_F_may);
                        end if;
                        -- Output alarm information
                        -- Alarm word
                        append(internal_buffer, internal_buffer_index, SET_ADDRESS_PREFIX & ALARM_ADDR);
                        append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & LETTER_A);
                        append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & LETTER_l);
                        append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & LETTER_a);
                        append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & LETTER_r);
                        append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & LETTER_m);
                        append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & COLON);
                        -- Alarm time
                        append(internal_buffer, internal_buffer_index, SET_ADDRESS_PREFIX & ALARM_TIME_ADDR);
                        append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & NUMBER_PREFIX & alarm_hour(7 downto 4));
                        append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & NUMBER_PREFIX & alarm_hour(3 downto 0));
                        append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & COLON);
                        append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & NUMBER_PREFIX & alarm_min(7 downto 4));
                        append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & NUMBER_PREFIX & alarm_min(3 downto 0));
                    elsif current_state = ST_SW then
                        -- Output time information
                        append(internal_buffer, internal_buffer_index, SET_ADDRESS_PREFIX & TIME_ADDR);
                        append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & LETTER_T_may);
                        append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & LETTER_i);
                        append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & LETTER_m);
                        append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & LETTER_e);
                        append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & COLON);
                        append(internal_buffer, internal_buffer_index, SET_ADDRESS_PREFIX & TIME_HOUR_ADDR);
                        append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & NUMBER_PREFIX & td_hour(7 downto 4));
                        append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & NUMBER_PREFIX & td_hour(3 downto 0));
                        append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & COLON);
                        append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & NUMBER_PREFIX & td_min(7 downto 4));
                        append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & NUMBER_PREFIX & td_min(3 downto 0));
                        append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & COLON);
                        append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & NUMBER_PREFIX & td_sec(7 downto 4));
                        append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & NUMBER_PREFIX & td_sec(3 downto 0));
                        if td_dcf_show = '1' then
                            append(internal_buffer, internal_buffer_index, SET_ADDRESS_PREFIX & DCF_ADDR);
                            append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & LETTER_D_may);
                            append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & LETTER_C_may);
                            append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & LETTER_F_may);
                        end if;
                        -- Output SW information
                        -- Output SW word
                        append(internal_buffer, internal_buffer_index, SET_ADDRESS_PREFIX & SW_ADDR);
                        append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & LETTER_S_may);
                        append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & LETTER_t);
                        append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & LETTER_o);
                        append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & LETTER_p);
                        append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & BLANK_SPACE);
                        append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & LETTER_W_may);
                        append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & LETTER_a);
                        append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & LETTER_t);
                        append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & LETTER_c);
                        append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & LETTER_h);
                        append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & COLON);
                        -- Output LAP word
                        if sw_lap = '1' then
                            append(internal_buffer, internal_buffer_index, SET_ADDRESS_PREFIX & SW_LAP_ADDR);
                            append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & LETTER_L);
                            append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & LETTER_a);
                            append(internal_buffer, internal_buffer_index, WRITE_DATA_PREFIX & LETTER_p);
                        end if;
                    end if;
                    lcd_buffer <= internal_buffer;
                    lcd_buffer_cnt <= internal_buffer_index;
                    lcd_buffer_update <= not lcd_buffer_update;
                end if;
                if en_100 = '1' then
                    if current_state = ST_SW then
                        -- Output sw info
                        append(internal_buffer_sw, internal_buffer_index_sw, SET_ADDRESS_PREFIX & SW_TIME_ADDR);
                        append(internal_buffer_sw, internal_buffer_index_sw, WRITE_DATA_PREFIX & NUMBER_PREFIX & sw_hour(7 downto 4));
                        append(internal_buffer_sw, internal_buffer_index_sw, WRITE_DATA_PREFIX & NUMBER_PREFIX & sw_hour(3 downto 0));
                        append(internal_buffer_sw, internal_buffer_index_sw, WRITE_DATA_PREFIX & COLON);
                        append(internal_buffer_sw, internal_buffer_index_sw, WRITE_DATA_PREFIX & NUMBER_PREFIX & sw_min(7 downto 4));
                        append(internal_buffer_sw, internal_buffer_index_sw, WRITE_DATA_PREFIX & NUMBER_PREFIX & sw_min(3 downto 0));
                        append(internal_buffer_sw, internal_buffer_index_sw, WRITE_DATA_PREFIX & COLON);
                        append(internal_buffer_sw, internal_buffer_index_sw, WRITE_DATA_PREFIX & NUMBER_PREFIX & sw_sec(7 downto 4));
                        append(internal_buffer_sw, internal_buffer_index_sw, WRITE_DATA_PREFIX & NUMBER_PREFIX & sw_sec(3 downto 0));
                        append(internal_buffer_sw, internal_buffer_index_sw, WRITE_DATA_PREFIX & DOT);
                        append(internal_buffer_sw, internal_buffer_index_sw, WRITE_DATA_PREFIX & NUMBER_PREFIX & sw_hsec(7 downto 4));
                        append(internal_buffer_sw, internal_buffer_index_sw, WRITE_DATA_PREFIX & NUMBER_PREFIX & sw_hsec(3 downto 0));
                    end if;
                    lcd_buffer_sw <= internal_buffer_sw;
                    lcd_buffer_cnt_sw <= internal_buffer_index_sw;
                    lcd_buffer_update_sw <= not lcd_buffer_update_sw;
                end if;
            else
                lcd_buffer <= lcd_buffer_init;
                lcd_buffer_cnt <= lcd_buffer_cnt_init;
                lcd_buffer_update <= '1';
            end if;
        end if;
        
    end process buffer_data_update;
    
    lcd_send_data : process(clk, reset)
        variable internal_output : command_lcd := (others => '0');
        variable internal_en : std_logic := '1';
        variable prev_buffer_update : std_logic := '0';
        variable prev_buffer_update_sw : std_logic := '0';
        variable internal_buffer_index : integer := 0;
        variable internal_buffer_index_sw : integer := 0;
    begin
        if reset = '1' then
            internal_output := (others => '0');
            internal_en := '1';
            prev_buffer_update := '0';
            prev_buffer_update_sw := '0';
            internal_buffer_index := 0;
            internal_buffer_index_sw := 0;
            lcd_en_sg <= '1';
            lcd_rs_sg <= '0';
            lcd_rw_sg <= '0';
            lcd_data_sg <= (others => '0');
        elsif rising_edge(clk) then
            if prev_buffer_update /= lcd_buffer_update then
                prev_buffer_update := not prev_buffer_update;
                internal_buffer_index := 0;
            end if;
            if prev_buffer_update_sw /= lcd_buffer_update_sw then
                prev_buffer_update_sw := not prev_buffer_update_sw;
                internal_buffer_index_sw := 0;
            end if;
            if internal_en = '1' then
                internal_en := '0';
            elsif internal_buffer_index_sw < lcd_buffer_cnt_sw then
                internal_en := '1';
                internal_output := lcd_buffer_sw(internal_buffer_index_sw);
                internal_buffer_index_sw := internal_buffer_index_sw + 1;
            elsif internal_buffer_index < lcd_buffer_cnt then
                internal_en := '1';
                internal_output := lcd_buffer(internal_buffer_index);
                internal_buffer_index := internal_buffer_index + 1;
            end if;
            lcd_en_sg <= internal_en;
            lcd_rs_sg <= internal_output(9);
            lcd_rw_sg <= internal_output(8);
            lcd_data_sg <= internal_output(7 downto 0);
        end if;
        
    end process lcd_send_data;
            

    -- LCD State Machine Process
    lcd_state_machine_proc : process(clk, reset)
        variable init_counter : integer := 0;
        constant wait_cycles : integer := 700;
        variable internal_buffer_index : integer range 0 to MAX -1;
        variable internal_buffer : data_buffer;
        constant all_zeros : command_lcd := (others => '0');

        procedure append(
            variable in_buffer : inout data_buffer;
            variable in_buffer_index : inout integer;
            constant new_input : in command_lcd
        ) is
        begin
            in_buffer(in_buffer_index) := new_input;
            in_buffer_index := in_buffer_index + 1;
        end procedure;
    begin
        if reset = '1' then
            init_counter := 0;
            internal_buffer_index := 0;
            internal_buffer := (others=>(others => '0'));
            current_state <= ST_RESET;
            init_done <= '0';
            lcd_buffer_update <= '0';
            
        elsif rising_edge(clk) then
            
            case current_state is
                
                when ST_RESET =>
                    if lcd_buffer_update = '0' then
                        -- Append init commands
                        for i in 0 to 149 loop
                            append(internal_buffer, internal_buffer_index, all_zeros);
                        end loop;
                        for i in 0 to 439 loop
                            append(internal_buffer, internal_buffer_index,  CMD_FUNCTION_SET);
                        end loop;
                        append(internal_buffer, internal_buffer_index, CMD_DISPLAY_OFF);
                        for i in 0 to 15 loop
                            append(internal_buffer, internal_buffer_index, CMD_DISPLAY_CLEAR);
                        end loop;
                        append(internal_buffer, internal_buffer_index, CMD_ENTRY_MODE);
                        append(internal_buffer, internal_buffer_index, CMD_DISPLAY_ON);
                        lcd_buffer_init <= internal_buffer;
                        lcd_buffer_cnt_init <= internal_buffer_index;
                    end if;
                    if init_counter > wait_cycles then
                        current_state <= ST_WAIT;
                        init_done <= '1';
                        init_counter := 0;
                    end if;
                    
                when ST_WAIT =>
                    case mode is
                        when "00" =>
                            current_state <= ST_TIME;
                        when "01" =>
                            current_state <= ST_DATE;
                        when "10" =>
                            current_state <= ST_ALARM;
                        when "11" =>
                            current_state <= ST_SW;
                    end case;

                when ST_TIME =>
                    case mode is
                        when "00" =>
                            current_state <= ST_TIME;
                        when "01" =>
                            current_state <= ST_DATE;
                        when "10" =>
                            current_state <= ST_ALARM;
                        when "11" =>
                            current_state <= ST_SW;
                        when others =>
                            current_state <= ST_WAIT;
                    end case;
                
                when ST_DATE =>
                    case mode is
                        when "00" =>
                            current_state <= ST_TIME;
                        when "01" =>
                            current_state <= ST_DATE;
                        when "10" =>
                            current_state <= ST_ALARM;
                        when "11" =>
                            current_state <= ST_SW;
                        when others =>
                            current_state <= ST_WAIT;
                    end case;

                when ST_ALARM =>
                    case mode is
                        when "00" =>
                            current_state <= ST_TIME;
                        when "01" =>
                            current_state <= ST_DATE;
                        when "10" =>
                            current_state <= ST_ALARM;
                        when "11" =>
                            current_state <= ST_SW;
                        when others =>
                            current_state <= ST_WAIT;
                    end case;
                
                when ST_SW =>
                    case mode is
                        when "00" =>
                            current_state <= ST_TIME;
                        when "01" =>
                            current_state <= ST_DATE;
                        when "10" =>
                            current_state <= ST_ALARM;
                        when "11" =>
                            current_state <= ST_SW;
                        when others =>
                            current_state <= ST_WAIT;
                    end case;

            end case;
        end if;
    end process lcd_state_machine_proc;

end architecture rtl;