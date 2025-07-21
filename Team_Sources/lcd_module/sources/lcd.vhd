--------------------------------------------------------------------------------
-- Author       : Pablo Morales  
-- Create Date  : 26/06/2025
-- Module Name  : lcd.vhd
-- Description  : LCD Controller for Digital Clock Display
--------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lcd is
    port (
        -- System signals
        clk   : in std_logic;
        reset : in std_logic;
        en_100    : in std_logic;  -- 100Hz enable pulse
        en_10    : in std_logic;   -- 10Hz enable pulse

        -- Mode selection
        mode         : in std_logic_vector(2 downto 0);
        
        -- Time inputs
        td_hour      : in std_logic_vector(7 downto 0);
        td_min       : in std_logic_vector(7 downto 0);
        td_sec       : in std_logic_vector(7 downto 0);
        td_dcf_show  : in std_logic;  -- DCF signal reception indicator
        
        -- Date inputs
        td_dow       : in std_logic_vector(7 downto 0);  -- Day of week
        td_day       : in std_logic_vector(7 downto 0);
        td_month     : in std_logic_vector(7 downto 0);
        td_year      : in std_logic_vector(7 downto 0);
        
        -- Alarm inputs
        alarm_act    : in std_logic;  -- Alarm active
        alarm_snooze : in std_logic;  -- Snooze active
        alarm_hour   : in std_logic_vector(7 downto 0);
        alarm_min    : in std_logic_vector(7 downto 0);
        
        -- Stopwatch inputs
        sw_lap       : in std_logic;  -- Lap time display mode
        sw_hour      : in std_logic_vector(7 downto 0);
        sw_min       : in std_logic_vector(7 downto 0);
        sw_sec       : in std_logic_vector(7 downto 0);
        sw_hsec      : in std_logic_vector(7 downto 0);  -- 1/100 seconds

        -- Time switch inputs
        ts_hour_off : in std_logic_vector(7 downto 0);
        ts_min_off  : in std_logic_vector(7 downto 0);
        ts_sec_off  : in std_logic_vector(7 downto 0);
        ts_hour_on  : in std_logic_vector(7 downto 0);
        ts_min_on   : in std_logic_vector(7 downto 0);
        ts_sec_on   : in std_logic_vector(7 downto 0);
        ts_on       : in std_logic;
        ts_select   : in std_logic;
        -- Countdown inputs
        cd_hour      : in std_logic_vector(7 downto 0);
        cd_min       : in std_logic_vector(7 downto 0);
        cd_sec       : in std_logic_vector(7 downto 0);
        cd_on        : in std_logic;

        -- LCD interface
        lcd_en       : out std_logic;  -- Enable signal
        lcd_rw       : out std_logic;  -- Read/Write (0: write)
        lcd_rs       : out std_logic;  -- Register select (0: cmd, 1: data)
        lcd_data     : out std_logic_vector(7 downto 0)  -- Data bus
    );
end entity lcd;

architecture rtl of lcd is

    -- LCD Commands
    constant CMD_FUNCTION_SET  : std_logic_vector(9 downto 0) := "0000111000";  -- 8-bit, 2-line
    constant CMD_DISPLAY_OFF   : std_logic_vector(9 downto 0) := "0000001000";
    constant CMD_DISPLAY_CLEAR : std_logic_vector(9 downto 0) := "0000000001";
    constant CMD_ENTRY_MODE    : std_logic_vector(9 downto 0) := "0000000110";  -- Auto increment
    constant CMD_DISPLAY_ON    : std_logic_vector(9 downto 0) := "0000001100";
    
    -- Command prefixes
    constant SET_ADDRESS_PREFIX : std_logic_vector(1 downto 0) := "00";  -- DDRAM address command
    constant WRITE_DATA_PREFIX  : std_logic_vector(1 downto 0) := "10";  -- Data write command
    
    -- LCD Display Addresses (HD44780)
    constant TIME_ADDR         : std_logic_vector(7 downto 0) := x"87";
    constant TIME_HOUR_ADDR    : std_logic_vector(7 downto 0) := x"C5";
    constant TIME_ON_ADDR      : std_logic_vector(7 downto 0) := x"C4";
    constant DCF_ADDR          : std_logic_vector(7 downto 0) := x"CF";
    constant DATE_ADDR         : std_logic_vector(7 downto 0) := x"9B";
    constant DATE_VALUE_ADDR   : std_logic_vector(7 downto 0) := x"D8";
    constant ALARM_ADDR        : std_logic_vector(7 downto 0) := x"9A";
    constant ALARM_ACTIVE_ADDR : std_logic_vector(7 downto 0) := x"94";
    constant ALARM_A_ADDR      : std_logic_vector(7 downto 0) := x"C0";
    constant ALARM_TIME_ADDR   : std_logic_vector(7 downto 0) := x"DB";
    constant S_ADDR            : std_logic_vector(7 downto 0) := x"D3";
    constant SW_ADDR           : std_logic_vector(7 downto 0) := x"97";
    constant SW_TIME_ADDR      : std_logic_vector(7 downto 0) := x"D8";
    constant SW_LAP_ADDR       : std_logic_vector(7 downto 0) := x"D4";
    constant TS_ADDR           : std_logic_vector(7 downto 0) := x"A7";
    
    -- Character codes (ASCII)
    -- Uppercase letters
    constant LETTER_T_may : std_logic_vector(7 downto 0) := x"54";
    constant LETTER_S_may : std_logic_vector(7 downto 0) := x"53";
    constant LETTER_W_may : std_logic_vector(7 downto 0) := x"57";
    constant LETTER_D_may : std_logic_vector(7 downto 0) := x"44";
    constant LETTER_L_may : std_logic_vector(7 downto 0) := x"4C";
    constant LETTER_C_may : std_logic_vector(7 downto 0) := x"43";
    constant LETTER_M_may : std_logic_vector(7 downto 0) := x"4D";
    constant LETTER_F_may : std_logic_vector(7 downto 0) := x"46";
    constant LETTER_A_may : std_logic_vector(7 downto 0) := x"41";
    constant LETTER_Z_may : std_logic_vector(7 downto 0) := x"5A";
    constant LETTER_O_may : std_logic_vector(7 downto 0) := x"4F";
    
    -- Lowercase letters
    constant LETTER_i : std_logic_vector(7 downto 0) := x"69";
    constant LETTER_m : std_logic_vector(7 downto 0) := x"6D";
    constant LETTER_e : std_logic_vector(7 downto 0) := x"65";
    constant LETTER_t : std_logic_vector(7 downto 0) := x"74";
    constant LETTER_o : std_logic_vector(7 downto 0) := x"6F";
    constant LETTER_p : std_logic_vector(7 downto 0) := x"70";
    constant LETTER_a : std_logic_vector(7 downto 0) := x"61";
    constant LETTER_c : std_logic_vector(7 downto 0) := x"63";
    constant LETTER_h : std_logic_vector(7 downto 0) := x"68";
    constant LETTER_l : std_logic_vector(7 downto 0) := x"6C";
    constant LETTER_r : std_logic_vector(7 downto 0) := x"72";
    constant LETTER_f : std_logic_vector(7 downto 0) := x"66";
    constant LETTER_n : std_logic_vector(7 downto 0) := x"6E";
    
    -- Special characters
    constant COLON       : std_logic_vector(7 downto 0) := x"3A";
    constant ASTERISK    : std_logic_vector(7 downto 0) := x"2A";
    constant BLANK_SPACE : std_logic_vector(7 downto 0) := x"20";
    constant BACKSLASH   : std_logic_vector(7 downto 0) := x"2F";
    constant DOT         : std_logic_vector(7 downto 0) := x"2E";
    
    -- ASCII number prefix (0x3 for digits 0-9)
    constant NUMBER_PREFIX : std_logic_vector(3 downto 0) := x"3";
    
    -- Controller states
    type state_t is (ST_RESET, ST_FUNCTION, ST_OFF, ST_ON, ST_ENTRY, ST_CLEAR, ST_EN_LOW, ST_WAIT, ST_SEND, ST_SEND_SW);
    
    -- Buffer definitions
    constant MAX_BUFFER : integer := 128;
    type data_buffer is array (0 to MAX_BUFFER-1) of std_logic_vector(9 downto 0);
    
    -- State and buffer control
    signal current_state : state_t := ST_RESET;
    signal lcd_buffer_cnt : integer range 0 to MAX_BUFFER-1 := 0;
    signal lcd_buffer_cnt_sw : integer range 0 to MAX_BUFFER-1 := 0;
    
    -- Command buffers
    signal lcd_buffer : data_buffer := (others=>(others => '0'));  -- Main display buffer
    signal lcd_buffer_sw : data_buffer := (others=>(others => '0'));  -- Stopwatch updates
    
    -- LCD control signals
    signal lcd_en_sg : std_logic := '1';
    signal lcd_rs_sg : std_logic := '0';
    signal lcd_rw_sg : std_logic := '0';
    signal lcd_data_sg : std_logic_vector(7 downto 0) := (others => '0');
    
    -- Initialization counter
    constant RST_WAIT_CYCLES : integer := 150;
    constant MODE1_WAIT_CYCLES : integer := 41;
    constant MODE2_WAIT_CYCLES : integer := 1;
    constant CLEAR_WAIT_CYCLES : integer := 16;
    
    -- Command formatting function
    function format_cmd(prefix: std_logic_vector(1 downto 0); data: std_logic_vector(7 downto 0)) 
    return std_logic_vector is
    begin
        return prefix & data;
    end function;

begin
        
    -- Buffer update process - Creates display content
    buffer_data_update : process(clk, reset)
        variable buffer_index : integer range 0 to MAX_BUFFER-1;
        variable buffer_index_sw : integer range 0 to MAX_BUFFER-1;
    begin
        if reset = '1' then
            buffer_index := 0;
            buffer_index_sw := 0;
            lcd_buffer <= (others=>(others => '0'));
            lcd_buffer_sw <= (others=>(others => '0'));
            lcd_buffer_cnt <= 0;
            lcd_buffer_cnt_sw <= 0;
            
        elsif rising_edge(clk) then
            -- Main display update at 10Hz
            if en_10 = '1' then
                buffer_index := 0;
                
                -- Common elements (always shown)
                lcd_buffer(buffer_index) <= format_cmd(SET_ADDRESS_PREFIX, ALARM_A_ADDR);
                buffer_index := buffer_index + 1;
                lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, LETTER_A_may);
                buffer_index := buffer_index + 1;
                
                -- Alarm indicators
                lcd_buffer(buffer_index) <= format_cmd(SET_ADDRESS_PREFIX, ALARM_ACTIVE_ADDR);
                buffer_index := buffer_index + 1;
                if alarm_snooze = '1' then
                    lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, LETTER_Z_may);
                    buffer_index := buffer_index + 1;
                elsif alarm_act = '1' then
                    lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, ASTERISK);
                    buffer_index := buffer_index + 1;
                else 
                    lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, BLANK_SPACE);
                    buffer_index := buffer_index + 1;
                end if;

                -- TS active
                lcd_buffer(buffer_index) <= format_cmd(SET_ADDRESS_PREFIX, TS_ADDR);
                buffer_index := buffer_index + 1;
                if ts_on = '1' then
                    lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, ASTERISK);
                    buffer_index := buffer_index + 1;
                else 
                    lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, BLANK_SPACE);
                    buffer_index := buffer_index + 1;
                end if;
                
                -- S indicator
                lcd_buffer(buffer_index) <= format_cmd(SET_ADDRESS_PREFIX, S_ADDR);
                buffer_index := buffer_index + 1;
                lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, LETTER_S_may);
                buffer_index := buffer_index + 1;
                if mode /="101" then
                    -- Time display (shown in all modes)
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
                    
                    -- Time value (HH:MM:SS)
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
                end if;
                
                -- DCF reception indicator
                lcd_buffer(buffer_index) <= format_cmd(SET_ADDRESS_PREFIX, DCF_ADDR);
                if td_dcf_show = '1' then
                    buffer_index := buffer_index + 1;
                    lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, LETTER_D_may);
                    buffer_index := buffer_index + 1;
                    lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, LETTER_C_may);
                    buffer_index := buffer_index + 1;
                    lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, LETTER_F_may);
                    buffer_index := buffer_index + 1;
                else
                    buffer_index := buffer_index + 1;
                    lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, BLANK_SPACE);
                    buffer_index := buffer_index + 1;
                    lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, BLANK_SPACE);
                    buffer_index := buffer_index + 1;
                    lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, BLANK_SPACE);
                    buffer_index := buffer_index + 1;
                end if;
                
                -- Mode-specific content
                case mode is
                    when "000" =>
                        lcd_buffer(buffer_index) <= format_cmd(SET_ADDRESS_PREFIX, SW_LAP_ADDR);
                        buffer_index := buffer_index + 1;
                        lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, BLANK_SPACE);
                        buffer_index := buffer_index + 1;
                        lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, BLANK_SPACE);
                        buffer_index := buffer_index + 1;
                        lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, BLANK_SPACE);
                        buffer_index := buffer_index + 1;
                        lcd_buffer(buffer_index) <= format_cmd(SET_ADDRESS_PREFIX, SW_ADDR);
                        buffer_index := buffer_index + 1;
                        lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, BLANK_SPACE);
                        buffer_index := buffer_index + 1;
                        lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, BLANK_SPACE);
                        buffer_index := buffer_index + 1;
                        lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, BLANK_SPACE);
                        buffer_index := buffer_index + 1;
                        lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, BLANK_SPACE);
                        buffer_index := buffer_index + 1;
                        lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, BLANK_SPACE);
                        buffer_index := buffer_index + 1;
                        lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, BLANK_SPACE);
                        buffer_index := buffer_index + 1;
                        lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, BLANK_SPACE);
                        buffer_index := buffer_index + 1;
                        lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, BLANK_SPACE);
                        buffer_index := buffer_index + 1;
                        lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, BLANK_SPACE);
                        buffer_index := buffer_index + 1;
                        lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, BLANK_SPACE);
                        buffer_index := buffer_index + 1;
                        lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, BLANK_SPACE);
                        buffer_index := buffer_index + 1;
                        lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, BLANK_SPACE);
                        buffer_index := buffer_index + 1;

                        -----------------------------
                        
                        lcd_buffer(buffer_index) <= format_cmd(SET_ADDRESS_PREFIX, SW_TIME_ADDR);
                        buffer_index := buffer_index + 1;
                        lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, BLANK_SPACE);
                        buffer_index := buffer_index + 1;
                        lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, BLANK_SPACE);
                        buffer_index := buffer_index + 1;
                        lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, BLANK_SPACE);
                        buffer_index := buffer_index + 1;
                        lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, BLANK_SPACE);
                        buffer_index := buffer_index + 1;
                        lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, BLANK_SPACE);
                        buffer_index := buffer_index + 1;
                        lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, BLANK_SPACE);
                        buffer_index := buffer_index + 1;
                        lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, BLANK_SPACE);
                        buffer_index := buffer_index + 1;
                        lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, BLANK_SPACE);
                        buffer_index := buffer_index + 1;
                        lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, BLANK_SPACE);
                        buffer_index := buffer_index + 1;
                        lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, BLANK_SPACE);
                        buffer_index := buffer_index + 1;
                        lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, BLANK_SPACE);
                        buffer_index := buffer_index + 1;
                        lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, BLANK_SPACE);
                        buffer_index := buffer_index + 1;
                        lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, BLANK_SPACE);
                        buffer_index := buffer_index + 1;
                        lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, BLANK_SPACE);
                        buffer_index := buffer_index + 1;
                        lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, BLANK_SPACE);
                        buffer_index := buffer_index + 1;


                    when "001" =>
                        -- Date display
                        lcd_buffer(buffer_index) <= format_cmd(SET_ADDRESS_PREFIX, SW_ADDR);
                        buffer_index := buffer_index + 1;
                        lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, BLANK_SPACE);
                        buffer_index := buffer_index + 1;
                        lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, BLANK_SPACE);
                        buffer_index := buffer_index + 1;
                        lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, BLANK_SPACE);
                        buffer_index := buffer_index + 1;
                        lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, BLANK_SPACE);
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
                        lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, BLANK_SPACE);
                        buffer_index := buffer_index + 1;
                        lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, BLANK_SPACE);
                        buffer_index := buffer_index + 1;
                        lcd_buffer(buffer_index) <= format_cmd(SET_ADDRESS_PREFIX, DATE_VALUE_ADDR);
                        buffer_index := buffer_index + 1;
                        
                        -- Day of week abbreviation
                        case td_dow(2 downto 0) is
                            when "000" => -- Monday
                                lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, LETTER_M_may);
                                buffer_index := buffer_index + 1;
                                lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, LETTER_o);
                                buffer_index := buffer_index + 1;
                            when "001" => -- Tuesday
                                lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, LETTER_D_may);
                                buffer_index := buffer_index + 1;
                                lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, LETTER_i);
                                buffer_index := buffer_index + 1;
                            when "010" => -- Wednesday
                                lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, LETTER_M_may);
                                buffer_index := buffer_index + 1;
                                lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, LETTER_i);
                                buffer_index := buffer_index + 1;
                            when "011" => -- Thursday
                                lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, LETTER_D_may);
                                buffer_index := buffer_index + 1;
                                lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, LETTER_o);
                                buffer_index := buffer_index + 1;
                            when "100" => -- Friday
                                lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, LETTER_F_may);
                                buffer_index := buffer_index + 1;
                                lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, LETTER_r);
                                buffer_index := buffer_index + 1;
                            when "101" => -- Saturday
                                lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, LETTER_S_may);
                                buffer_index := buffer_index + 1;
                                lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, LETTER_a);
                                buffer_index := buffer_index + 1;
                            when "111" => -- Sunday
                                lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, LETTER_S_may);
                                buffer_index := buffer_index + 1;
                                lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, LETTER_o);
                                buffer_index := buffer_index + 1;
                            when others => 
                                lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, BLANK_SPACE);
                                buffer_index := buffer_index + 1;
                                lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, BLANK_SPACE);
                                buffer_index := buffer_index + 1;
                        end case;
                        
                        -- Date value (DD/MM/YY)
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
                        lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, BLANK_SPACE);
                        buffer_index := buffer_index + 1;
                        lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, BLANK_SPACE);
                        buffer_index := buffer_index + 1;
                        
                    when "010" =>
                        -- Alarm display
                        lcd_buffer(buffer_index) <= format_cmd(SET_ADDRESS_PREFIX, SW_ADDR);
                        buffer_index := buffer_index + 1;
                        lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, BLANK_SPACE);
                        buffer_index := buffer_index + 1;
                        lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, BLANK_SPACE);
                        buffer_index := buffer_index + 1;
                        lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, BLANK_SPACE);
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
                        lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, BLANK_SPACE);
                        buffer_index := buffer_index + 1;
                        lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, BLANK_SPACE);
                        buffer_index := buffer_index + 1;
                        
                        -- Alarm time (HH:MM)
                        lcd_buffer(buffer_index) <= format_cmd(SET_ADDRESS_PREFIX, SW_TIME_ADDR);
                        buffer_index := buffer_index + 1;
                        lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, BLANK_SPACE);
                        buffer_index := buffer_index + 1;
                        lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, BLANK_SPACE);
                        buffer_index := buffer_index + 1;
                        lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, BLANK_SPACE);
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
                        lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, BLANK_SPACE);
                        buffer_index := buffer_index + 1;
                        lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, BLANK_SPACE);
                        buffer_index := buffer_index + 1;
                        lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, BLANK_SPACE);
                        buffer_index := buffer_index + 1;
                        lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, BLANK_SPACE);
                        buffer_index := buffer_index + 1;
                        lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, BLANK_SPACE);
                        buffer_index := buffer_index + 1;
                        lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, BLANK_SPACE);
                        buffer_index := buffer_index + 1;
                        
                    when "011" =>
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
                        
                        -- Lap indicator
                        lcd_buffer(buffer_index) <= format_cmd(SET_ADDRESS_PREFIX, SW_LAP_ADDR);
                        buffer_index := buffer_index + 1;
                        if sw_lap = '1' then
                            lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, LETTER_L_may);
                            buffer_index := buffer_index + 1;
                            lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, LETTER_a);
                            buffer_index := buffer_index + 1;
                            lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, LETTER_p);
                            buffer_index := buffer_index + 1;
                        else
                            lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, BLANK_SPACE);
                            buffer_index := buffer_index + 1;
                            lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, BLANK_SPACE);
                            buffer_index := buffer_index + 1;
                            lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, BLANK_SPACE);
                            buffer_index := buffer_index + 1;
                        end if;
                    
                    when "100" =>
                            -- Countdown
                        lcd_buffer(buffer_index) <= format_cmd(SET_ADDRESS_PREFIX, SW_ADDR);
                        buffer_index := buffer_index + 1;
                        lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, BLANK_SPACE);
                        buffer_index := buffer_index + 1;
                        lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, BLANK_SPACE);
                        buffer_index := buffer_index + 1;
                        lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, BLANK_SPACE);
                        buffer_index := buffer_index + 1;
                        lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, LETTER_T_may);
                        buffer_index := buffer_index + 1;
                        lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, LETTER_i);
                        buffer_index := buffer_index + 1;
                        lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, LETTER_m);
                        buffer_index := buffer_index + 1;
                        lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, LETTER_e);
                        buffer_index := buffer_index + 1;
                        lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, LETTER_r);
                        buffer_index := buffer_index + 1;
                        lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, COLON);
                        buffer_index := buffer_index + 1;
                        lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, BLANK_SPACE);
                        buffer_index := buffer_index + 1;
                        lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, BLANK_SPACE);
                        buffer_index := buffer_index + 1;
                        -- Countdown time
                        lcd_buffer(buffer_index) <= format_cmd(SET_ADDRESS_PREFIX, SW_TIME_ADDR);
                        buffer_index := buffer_index + 1;
                        lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, BLANK_SPACE);
                        buffer_index := buffer_index + 1;
                        lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, BLANK_SPACE);
                        buffer_index := buffer_index + 1;
                        lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, NUMBER_PREFIX & cd_hour(7 downto 4));
                        buffer_index := buffer_index + 1;
                        lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, NUMBER_PREFIX & cd_hour(3 downto 0));
                        buffer_index := buffer_index + 1;
                        lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, COLON);
                        buffer_index := buffer_index + 1;
                        lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, NUMBER_PREFIX & cd_min(7 downto 4));
                        buffer_index := buffer_index + 1;
                        lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, NUMBER_PREFIX & cd_min(3 downto 0));
                        buffer_index := buffer_index + 1;
                        lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, COLON);
                        buffer_index := buffer_index + 1;
                        lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, NUMBER_PREFIX & cd_sec(7 downto 4));
                        buffer_index := buffer_index + 1;
                        lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, NUMBER_PREFIX & cd_sec(3 downto 0));
                        buffer_index := buffer_index + 1;
                        lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, BLANK_SPACE);
                        buffer_index := buffer_index + 1;
                        if cd_select = '0' then
                            lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, LETTER_O_may);
                            buffer_index := buffer_index + 1;
                            lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, LETTER_f);
                            buffer_index := buffer_index + 1;
                            lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, LETTER_f);
                            buffer_index := buffer_index + 1;
                        else
                            lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, LETTER_O_may);
                            buffer_index := buffer_index + 1;
                            lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, LETTER_n);
                            buffer_index := buffer_index + 1;
                            lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, BLANK_SPACE);
                            buffer_index := buffer_index + 1;
                        end if;
                    when "101" =>
                            --On
                            lcd_buffer(buffer_index) <= format_cmd(SET_ADDRESS_PREFIX, TIME_ADDR);
                            buffer_index := buffer_index + 1;
                            lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, BLANK_SPACE);
                            buffer_index := buffer_index + 1;
                            lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, LETTER_O_may);
                            buffer_index := buffer_index + 1;
                            lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, LETTER_n);
                            buffer_index := buffer_index + 1;
                            lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, COLON);
                            buffer_index := buffer_index + 1;
                            lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, BLANK_SPACE);
                            buffer_index := buffer_index + 1;
                            --On time
                            lcd_buffer(buffer_index) <= format_cmd(SET_ADDRESS_PREFIX, TIME_ON_ADDR);
                            buffer_index := buffer_index + 1;
                            if ts_select = '0' then
                                lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, ASTERISK);
                                buffer_index := buffer_index + 1;
                            else
                                lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, BLANK_SPACE);
                                buffer_index := buffer_index + 1;
                            end if;
                            lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, NUMBER_PREFIX & ts_hour_on(7 downto 4));
                            buffer_index := buffer_index + 1;
                            lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, NUMBER_PREFIX & ts_hour_on(3 downto 0));
                            buffer_index := buffer_index + 1;
                            lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, COLON);
                            buffer_index := buffer_index + 1;
                            lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, NUMBER_PREFIX & ts_min_on(7 downto 4));
                            buffer_index := buffer_index + 1;
                            lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, NUMBER_PREFIX & ts_min_on(3 downto 0));
                            buffer_index := buffer_index + 1;
                            lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, COLON);
                            buffer_index := buffer_index + 1;
                            lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, NUMBER_PREFIX & ts_sec_on(7 downto 4));
                            buffer_index := buffer_index + 1;
                            lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, NUMBER_PREFIX & ts_sec_on(3 downto 0));
                            buffer_index := buffer_index + 1;
                            -- Off
                            lcd_buffer(buffer_index) <= format_cmd(SET_ADDRESS_PREFIX, SW_ADDR);
                            buffer_index := buffer_index + 1;
                            lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, BLANK_SPACE);
                            buffer_index := buffer_index + 1;
                            lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, BLANK_SPACE);
                            buffer_index := buffer_index + 1;
                            lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, BLANK_SPACE);
                            buffer_index := buffer_index + 1;
                            lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, BLANK_SPACE);
                            buffer_index := buffer_index + 1;
                            lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, BLANK_SPACE);
                            buffer_index := buffer_index + 1;
                            lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, LETTER_O_may);
                            buffer_index := buffer_index + 1;
                            lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, LETTER_f);
                            buffer_index := buffer_index + 1;
                            lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, LETTER_f);
                            buffer_index := buffer_index + 1;
                            lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, COLON);
                            buffer_index := buffer_index + 1;
                            lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, BLANK_SPACE);
                            buffer_index := buffer_index + 1;
                            lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, BLANK_SPACE);
                            buffer_index := buffer_index + 1;
                            -- Countdown time
                            lcd_buffer(buffer_index) <= format_cmd(SET_ADDRESS_PREFIX, SW_TIME_ADDR);
                            buffer_index := buffer_index + 1;
                            if ts_select = '0' then
                                lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, BLANK_SPACE);
                                buffer_index := buffer_index + 1;
                            else
                                lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, ASTERISK);
                                buffer_index := buffer_index + 1;
                            end if;
                            buffer_index := buffer_index + 1;
                            lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, NUMBER_PREFIX & ts_hour_off(7 downto 4));
                            buffer_index := buffer_index + 1;
                            lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, NUMBER_PREFIX & ts_hour_off(3 downto 0));
                            buffer_index := buffer_index + 1;
                            lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, COLON);
                            buffer_index := buffer_index + 1;
                            lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, NUMBER_PREFIX & ts_min_off(7 downto 4));
                            buffer_index := buffer_index + 1;
                            lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, NUMBER_PREFIX & ts_min_off(3 downto 0));
                            buffer_index := buffer_index + 1;
                            lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, COLON);
                            buffer_index := buffer_index + 1;
                            lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, NUMBER_PREFIX & ts_sec_off(7 downto 4));
                            buffer_index := buffer_index + 1;
                            lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, NUMBER_PREFIX & ts_sec_off(3 downto 0));
                            buffer_index := buffer_index + 1;
                            lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, BLANK_SPACE);
                            buffer_index := buffer_index + 1;
                            lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, BLANK_SPACE);
                            buffer_index := buffer_index + 1;
                            lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, BLANK_SPACE);
                            buffer_index := buffer_index + 1;
                            lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, BLANK_SPACE);
                            buffer_index := buffer_index + 1;
                            lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, BLANK_SPACE);
                            buffer_index := buffer_index + 1;
                    when others =>
                        null;
                end case;
                
                -- Update buffer and notify command processor
                lcd_buffer_cnt <= buffer_index;
            end if;
            
            -- Fast update for stopwatch (100Hz)
            if en_100 = '1' and mode = "011" then
                buffer_index_sw := 0;
                
                -- Stopwatch time (HH:MM:SS.xx)
                lcd_buffer_sw(buffer_index_sw) <= format_cmd(SET_ADDRESS_PREFIX, SW_TIME_ADDR);
                buffer_index_sw := buffer_index_sw + 1;
                lcd_buffer_sw(buffer_index_sw) <= format_cmd(WRITE_DATA_PREFIX, NUMBER_PREFIX & sw_hour(7 downto 4));
                buffer_index_sw := buffer_index_sw + 1;
                lcd_buffer_sw(buffer_index_sw) <= format_cmd(WRITE_DATA_PREFIX, NUMBER_PREFIX & sw_hour(3 downto 0));
                buffer_index_sw := buffer_index_sw + 1;
                lcd_buffer_sw(buffer_index_sw) <= format_cmd(WRITE_DATA_PREFIX, COLON);
                buffer_index_sw := buffer_index_sw + 1;
                lcd_buffer_sw(buffer_index_sw) <= format_cmd(WRITE_DATA_PREFIX, NUMBER_PREFIX & sw_min(7 downto 4));
                buffer_index_sw := buffer_index_sw + 1;
                lcd_buffer_sw(buffer_index_sw) <= format_cmd(WRITE_DATA_PREFIX, NUMBER_PREFIX & sw_min(3 downto 0));
                buffer_index_sw := buffer_index_sw + 1;
                lcd_buffer_sw(buffer_index_sw) <= format_cmd(WRITE_DATA_PREFIX, COLON);
                buffer_index_sw := buffer_index_sw + 1;
                lcd_buffer_sw(buffer_index_sw) <= format_cmd(WRITE_DATA_PREFIX, NUMBER_PREFIX & sw_sec(7 downto 4));
                buffer_index_sw := buffer_index_sw + 1;
                lcd_buffer_sw(buffer_index_sw) <= format_cmd(WRITE_DATA_PREFIX, NUMBER_PREFIX & sw_sec(3 downto 0));
                buffer_index_sw := buffer_index_sw + 1;
                lcd_buffer_sw(buffer_index_sw) <= format_cmd(WRITE_DATA_PREFIX, DOT);
                buffer_index_sw := buffer_index_sw + 1;
                lcd_buffer_sw(buffer_index_sw) <= format_cmd(WRITE_DATA_PREFIX, NUMBER_PREFIX & sw_hsec(7 downto 4));
                buffer_index_sw := buffer_index_sw + 1;
                lcd_buffer_sw(buffer_index_sw) <= format_cmd(WRITE_DATA_PREFIX, NUMBER_PREFIX & sw_hsec(3 downto 0));
                buffer_index_sw := buffer_index_sw + 1;
                lcd_buffer_sw(buffer_index_sw) <= format_cmd(WRITE_DATA_PREFIX, BLANK_SPACE);
                buffer_index_sw := buffer_index_sw + 1;
                lcd_buffer_sw(buffer_index_sw) <= format_cmd(WRITE_DATA_PREFIX, BLANK_SPACE);
                buffer_index_sw := buffer_index_sw + 1;
                lcd_buffer_sw(buffer_index_sw) <= format_cmd(WRITE_DATA_PREFIX, BLANK_SPACE);
                buffer_index_sw := buffer_index_SW + 1;
                lcd_buffer(buffer_index) <= format_cmd(WRITE_DATA_PREFIX, BLANK_SPACE);
                buffer_index := buffer_index + 1;
                
                lcd_buffer_cnt_sw <= buffer_index_sw;
            end if;
        end if;
    end process buffer_data_update;
    
    
    -- State machine
    lcd_state_machine_proc : process(clk, reset)
        variable prev_buffer_update : std_logic := '0';
        variable prev_buffer_update_sw : std_logic := '0';
        variable read_index : integer range 0 to MAX_BUFFER-1 := 0;
        variable read_index_sw : integer range 0 to MAX_BUFFER-1 := 0;
        variable current_cmd : std_logic_vector(9 downto 0) := (others => '0');
        variable prev_cmd : std_logic_vector(9 downto 0) := (others => '0');
        variable prev_mode : std_logic_vector(2 downto 0) := (others => '0');
        variable internal_counter : integer := 0;
        variable cmd_counter : integer := 0;
        variable init_done : boolean := false;
        variable internal_en : std_logic := '1';
    begin
        if reset = '1' then
            current_state <= ST_RESET;
            internal_counter := 0;
            prev_buffer_update := '0';
            prev_buffer_update_sw := '0';
            read_index := 0;
            read_index_sw := 0;
            lcd_en_sg <= '1';
            lcd_rs_sg <= '0';
            lcd_rw_sg <= '0';
            lcd_data_sg <= (others => '0');
            current_cmd := (others => '0');
            prev_cmd := (others => '0');
            prev_mode := (others => '0');
            init_done := false;
            internal_en := '1';
            cmd_counter := 0;
        elsif rising_edge(clk) then
            case current_state is
                when ST_RESET =>
                    internal_counter := RST_WAIT_CYCLES;
                    current_state <= ST_FUNCTION;
                when ST_FUNCTION =>
                    if internal_counter > 0 then
                        internal_counter := internal_counter - 1;
                    else
                        current_cmd := CMD_FUNCTION_SET;
                        prev_cmd := CMD_FUNCTION_SET;
                        current_state <= ST_EN_LOW;
                        internal_en := '1';
                    end if;
                when ST_CLEAR =>
                    if internal_counter > 0 then
                        internal_counter := internal_counter - 1;
                    else
                        current_cmd := CMD_DISPLAY_CLEAR;
                        prev_cmd := CMD_DISPLAY_CLEAR;
                        current_state <= ST_EN_LOW;
                        internal_en := '1';
                    end if;
                when ST_OFF =>
                    if internal_counter > 0 then
                        internal_counter := internal_counter - 1;
                    else
                        current_cmd := CMD_DISPLAY_OFF;
                        prev_cmd := CMD_DISPLAY_OFF;
                        current_state <= ST_EN_LOW;
                        internal_en := '1';
                    end if;
                when ST_ON =>
                    if internal_counter > 0 then
                        internal_counter := internal_counter - 1;
                    else
                        current_cmd := CMD_DISPLAY_ON;
                        prev_cmd := CMD_DISPLAY_ON;
                        current_state <= ST_EN_LOW;
                        internal_en := '1';
                    end if;
                when ST_ENTRY =>
                    if internal_counter > 0 then
                        internal_counter := internal_counter - 1;
                    else
                        current_cmd := CMD_ENTRY_MODE;
                        prev_cmd := CMD_ENTRY_MODE;
                        current_state <= ST_EN_LOW;
                        internal_en := '1';
                    end if;
                when ST_EN_LOW =>
                    if init_done = false then
                        case cmd_counter is
                            when 0 =>
                                internal_counter := MODE1_WAIT_CYCLES;
                                current_state <= ST_FUNCTION;
                            when 1 =>
                                internal_counter := MODE2_WAIT_CYCLES;
                                current_state <= ST_FUNCTION;
                            when 2 =>
                                internal_counter := 0;
                                current_state <= ST_OFF;
                            when 3 =>
                                internal_counter := 0;
                                current_state <= ST_CLEAR;
                            when 4 =>
                                internal_counter := CLEAR_WAIT_CYCLES;
                                current_state <= ST_ENTRY;
                            when 5 =>
                                internal_counter := 0;
                                current_state <= ST_ON;
                            when others =>
                                internal_counter := 0;
                                current_state <= ST_WAIT;
                                init_done := true;
                        end case;
                        cmd_counter := cmd_counter + 1;
                    elsif read_index < lcd_buffer_cnt then
                        internal_counter := CLEAR_WAIT_CYCLES;
                        current_state <= ST_SEND;
                    elsif read_index_sw < lcd_buffer_cnt_sw then
                        current_state <= ST_SEND_SW;
                    else
                        current_state <= ST_WAIT;
                    end if;
                    current_cmd := prev_cmd;
                    internal_en := '0';
                when ST_WAIT =>
                    if en_10 = '1' then
                        read_index := 0;
                        current_state <= ST_SEND;
                    elsif en_100 = '1' and mode = "011" then
                        read_index_sw := 0;
                        current_state <= ST_SEND_SW;
                    end if;
                    current_cmd := (others => '0');
                    internal_en := '1';
                when ST_SEND =>
                    if internal_counter > 0 then
                        internal_counter := internal_counter - 1;
                    elsif read_index < lcd_buffer_cnt then
                        current_cmd := lcd_buffer(read_index);
                        prev_cmd := lcd_buffer(read_index);
                        read_index := read_index + 1;
                        current_state <= ST_EN_LOW;
                        internal_en := '1';
                    else
                        current_state <= ST_WAIT;
                    end if;
                when ST_SEND_SW =>
                    if read_index_sw < lcd_buffer_cnt_sw then
                        current_cmd := lcd_buffer_sw(read_index_sw);
                        prev_cmd := lcd_buffer_sw(read_index_sw);
                        read_index_sw := read_index_sw + 1;
                        current_state <= ST_EN_LOW;
                        internal_en := '1';
                    else
                        current_state <= ST_WAIT;
                    end if;
                when others =>
                    null;  -- No other states defined
                    
            end case;
        end if;
        lcd_en_sg <= internal_en;
        lcd_rs_sg <= current_cmd(9);
        lcd_rw_sg <= current_cmd(8);
        lcd_data_sg <= current_cmd(7 downto 0);
    end process lcd_state_machine_proc;
    
    -- Output connections
    lcd_en <= lcd_en_sg;
    lcd_rs <= lcd_rs_sg;
    lcd_rw <= lcd_rw_sg;
    lcd_data <= lcd_data_sg;

end architecture rtl;