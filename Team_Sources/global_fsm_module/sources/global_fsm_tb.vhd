


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_global_fsm is
end tb_global_fsm;

architecture behavior of tb_global_fsm is 
    -- Component Declaration
    component global_fsm
    Port (
        clk                 : in  std_logic;
        reset               : in  std_logic;
        key_enable          : in  std_logic;
        key_action_impulse  : in  std_logic;
        key_action_long     : in  std_logic;
        key_mode_impulse    : in  std_logic;
        key_minus_impulse   : in  std_logic;
        key_plus_impulse    : in  std_logic;
        key_plus_minus      : in  std_logic;
        td_date_status      : in  std_logic;
        alarm_ring          : in  std_logic;
        sw_active           : in  std_logic;
        mode                : out std_logic_vector(1 downto 0);
        alarm_set_incr_min  : out std_logic;
        alarm_set_decr_min  : out std_logic;
        alarm_toggle_active : out std_logic;
        alarm_snoozed       : out std_logic;
        alarm_off           : out std_logic;
        sw_start            : out std_logic;
        sw_lap_toggle       : out std_logic;
        sw_reset            : out std_logic
        
    );
    end component;
    
    -- Inputs
    signal clk               : std_logic := '0';
    signal reset             : std_logic := '1';
    signal key_enable        : std_logic := '0';
    signal key_action_impulse: std_logic := '0';
    signal key_action_long   : std_logic := '0';
    signal key_mode_impulse  : std_logic := '0';
    signal key_minus_impulse : std_logic := '0';
    signal key_plus_impulse  : std_logic := '0';
    signal key_plus_minus    : std_logic := '0';
    signal td_date_status    : std_logic := '0';
    signal alarm_ring        : std_logic := '0';
    
    -- Outputs
    signal mode              : std_logic_vector(1 downto 0);
    signal alarm_set_incr_min: std_logic;
    signal alarm_set_decr_min: std_logic;
    signal alarm_toggle_active: std_logic;
    signal alarm_snoozed     : std_logic;
    signal alarm_off         : std_logic;
    signal sw_start          : std_logic;
    signal sw_lap_toggle     : std_logic;
    signal sw_reset          : std_logic;
    signal sw_active         : std_logic;
    
    -- Clock period definitions (10 kHz -> 100 us period)
    constant clk_period : time := 100 us;
    
    -- Testbench control
    signal test_finished : boolean := false;
    
begin
    -- Instantiate Unit Under Test (UUT)
    uut: global_fsm port map (
        clk => clk,
        reset => reset,
        key_enable => key_enable,
        key_action_impulse => key_action_impulse,
        key_action_long => key_action_long,
        key_mode_impulse => key_mode_impulse,
        key_minus_impulse => key_minus_impulse,
        key_plus_impulse => key_plus_impulse,
        key_plus_minus => key_plus_minus,
        td_date_status => td_date_status,
        alarm_ring => alarm_ring,
        mode => mode,
        alarm_set_incr_min => alarm_set_incr_min,
        alarm_set_decr_min => alarm_set_decr_min,
        alarm_toggle_active => alarm_toggle_active,
        alarm_snoozed => alarm_snoozed,
        alarm_off => alarm_off,
        sw_start => sw_start,
        sw_lap_toggle => sw_lap_toggle,
        sw_reset => sw_reset,
        sw_active => sw_active
    );
    
    -- Clock generation
    clk_process: process
    begin
--        while not test_finished loop
            clk <= '0';
            wait for clk_period/2;
            clk <= '1';
            wait for clk_period/2;
--        end loop;
--        wait;
    end process;
    
   
    -- Stimulus process
    stim_proc: process
    begin
        -- Initial reset (hold for 2 clock cycles)
        reset <= '1';
        key_enable <= '1';  -- Enable key inputs
        wait for clk_period * 2;
        reset <= '0';
        
        -- Test 1: Reset to NORMAL mode
        wait for clk_period;
        assert mode = "00" report "Failed Test 1: Not in NORMAL mode after reset" severity error;
        
        -- Test 2: Transition to DATE mode
        key_mode_impulse <= '1';
        wait for clk_period;
        key_mode_impulse <= '0';
        wait for clk_period;
        assert mode = "01" report "Failed Test 2: Not in DATE mode" severity error;
        
        -- Test 3: Trigger DALR_SNOOZE in DATE mode
        alarm_ring <= '1';  -- Simulate alarm ringing
        key_action_impulse <= '1';
        wait for clk_period;
        key_action_impulse <= '0';
        wait for clk_period;
        assert alarm_snoozed = '1' report "Failed Test 3: Alarm not snoozed" severity error;
        
        -- Test 4: Return to NORMAL mode via falling edge detection
        td_date_status <= '1';
        wait for clk_period * 5;
        td_date_status <= '0';  -- Generate falling edge
        wait for clk_period;
        assert mode = "00" report "Failed Test 4: Not returned to NORMAL mode" severity error;
        
        -- Test 5: Enter STOPWATCH mode
        key_minus_impulse <= '1';
        wait for clk_period;
        key_minus_impulse <= '0';
        wait for clk_period;
        assert mode = "11" report "Failed Test 5: Not in STOPWATCH mode" severity error;
        
        -- Test 6: Start stopwatch
        key_action_impulse <= '1';
        wait for clk_period;
        key_action_impulse <= '0';
        wait for clk_period;
        assert sw_start = '1' report "Failed Test 6: Stopwatch not started" severity error;
        
        -- Test 7: Take lap in stopwatch
        
        key_minus_impulse <= '1';
         wait for clk_period;
         key_minus_impulse <= '0';
         wait for clk_period;
        key_action_impulse <= '1';
        sw_active <= '1';
        wait for clk_period;
        key_action_impulse <= '0';
        wait for clk_period;
        key_minus_impulse <= '1';
        wait for clk_period;
        key_minus_impulse <= '0';
        wait for clk_period;
        key_mode_impulse <= '1';
        wait for clk_period;
        key_mode_impulse <= '0';
        wait for clk_period;
        key_minus_impulse <= '1';
        wait for clk_period;
        key_minus_impulse <= '0';
        wait for clk_period;
        key_minus_impulse <= '1';
        wait for clk_period;
        key_minus_impulse <= '0';
        wait for clk_period;
        
        assert sw_lap_toggle = '0' report "Failed Test 7: Lap not recorded" severity error;
        
        -- Test 8: Handle alarm in stopwatch mode
        alarm_ring <= '1';
        key_action_impulse <= '1';  -- Snooze alarm
        wait for clk_period;
        key_action_impulse <= '0';
        wait for clk_period;
        assert alarm_snoozed = '1' report "Failed Test 8: Alarm not snoozed in stopwatch" severity error;
        alarm_ring <= '0';
        
        -- Test 9: Enter ALARM mode
        key_mode_impulse <= '1';
        wait for clk_period;
        key_mode_impulse <= '0';
        wait for clk_period;
        assert mode = "10" report "Failed Test 9: Not in ALARM mode" severity error;
        
        -- Test 10: Increment alarm time
        key_plus_impulse <= '1';
        wait for clk_period;
        key_plus_impulse <= '0';
        wait for clk_period;
        assert alarm_set_incr_min = '1' report "Failed Test 10: Alarm not incremented" severity error;
        
        -- Test 11: Toggle alarm active state
        key_action_impulse <= '1';
        wait for clk_period;
        key_action_impulse <= '0';
        wait for clk_period;
        assert alarm_toggle_active = '1' report "Failed Test 11: Alarm active state not toggled" severity error;
        
        -- Test 12: Handle ringing alarm in ALARM mode
        alarm_ring <= '1';
        key_action_impulse <= '1';  -- Snooze
        wait for clk_period;
        key_action_impulse <= '0';
        wait for clk_period;
        assert alarm_snoozed = '1' report "Failed Test 12: Alarm not snoozed in ALARM mode" severity error;
        
        -- Test 13: Long press to turn off alarm
        key_action_long <= '1';
        wait for clk_period * 2;  -- Long press duration
        key_action_long <= '0';
        wait for clk_period;
        assert alarm_off = '1' report "Failed Test 13: Alarm not turned off" severity error;
        
        -- Test 14: Reset stopwatch
        key_mode_impulse <= '1';  -- Back to NORMAL
        wait for clk_period;
        key_mode_impulse <= '0';
        wait for clk_period;
        
        key_minus_impulse <= '1';  -- Enter stopwatch
        wait for clk_period;
        key_minus_impulse <= '0';
        wait for clk_period;
        
        key_plus_impulse <= '1';  -- Reset
        wait for clk_period;
        key_plus_impulse <= '0';
        wait for clk_period;
        assert sw_reset = '1' report "Failed Test 14: Stopwatch not reset" severity error;
        
        -- Completion
        report "All tests completed successfully" severity note;
        test_finished <= true;
        wait;
    end process;
end behavior;


