library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_global_fsm is
end tb_global_fsm;

architecture Behavioral of tb_global_fsm is

    -- Component Declaration
    component global_fsm
        Port (
        clk                 : in  std_logic;
        reset               : in  std_logic;
	
        key_enable	    : in  std_logic;
        key_action_impulse  : in  std_logic;
        key_action_long     : in  std_logic;
        key_mode_impulse    : in  std_logic;
        key_minus_impulse   : in  std_logic;
        key_plus_impulse    : in  std_logic;
        key_plus_minus      : in  std_logic;
        td_date_status	    : in  std_logic;  -- this stays up for 3 seconds and i have to detect falling edge
        alarm_ring          : in  std_logic;
       
        -- mode = 00(normal), 01(date), 10(alarm), 11(stopwatch)
        mode 		    : out std_logic_vector(1 downto 0);
        alarm_set_incr_min  : out std_logic;
        alarm_set_decr_min  : out std_logic;
        alarm_toggle_active : out std_logic;
        alarm_snoozed       : out std_logic;
        alarm_off           : out std_logic; 
        sw_start            : out std_logic;
        sw_lap_toggle       : out std_logic;
        sw_reset            : out std_logic;
        current_state_out   : out std_logic
        );
    end component;

    -- Signals
    signal clk                 : std_logic := '0';
    signal reset               : std_logic := '0';
    signal key_enable          : std_logic := '0';
    signal key_action_impulse  : std_logic := '0';
    signal key_action_long     : std_logic := '0';
    signal key_mode_impulse    : std_logic := '0';
    signal key_minus_impulse   : std_logic := '0';
    signal key_plus_impulse    : std_logic := '0';
    signal key_plus_minus      : std_logic := '0';
    signal td_date_status      : std_logic := '0';
    signal alarm_ring          : std_logic := '0';

    signal mode                : std_logic_vector(1 downto 0);
    signal alarm_set_incr_min  : std_logic;
    signal alarm_set_decr_min  : std_logic;
    signal alarm_toggle_active : std_logic;
    signal alarm_snoozed       : std_logic;
    signal alarm_off           : std_logic;
    signal sw_start            : std_logic;
    signal sw_lap_toggle       : std_logic;
    signal sw_reset            : std_logic;
    signal current_state_out   : std_logic;
    constant clk_period : time := 100 us;

begin

    -- Instantiate the DUT (Device Under Test)
    uut: global_fsm
        port map (
            clk                 => clk,
            reset               => reset,
            key_enable          => key_enable,
            key_action_impulse  => key_action_impulse,
            key_action_long     => key_action_long,
            key_mode_impulse    => key_mode_impulse,
            key_minus_impulse   => key_minus_impulse,
            key_plus_impulse    => key_plus_impulse,
            key_plus_minus      => key_plus_minus,
            td_date_status      => td_date_status,
            alarm_ring          => alarm_ring,
            mode                => mode,
            alarm_set_incr_min  => alarm_set_incr_min,
            alarm_set_decr_min  => alarm_set_decr_min,
            alarm_toggle_active => alarm_toggle_active,
            alarm_snoozed       => alarm_snoozed,
            alarm_off           => alarm_off,
            sw_start            => sw_start,
            sw_lap_toggle       => sw_lap_toggle,
            sw_reset            => sw_reset,
            current_state_out   => current_state_out
        );

    -- Clock Generation
    clk_process :process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- Stimulus Process
    stim_proc: process
    begin
        -- Initial reset
        reset <= '1';
        wait for 2*clk_period;
        reset <= '0';
        wait for clk_period;

        ----------------------------------------------------------
        -- 1. NORMAL to DATE via key_mode_impulse
        ----------------------------------------------------------
        key_mode_impulse <= '1';
        wait for clk_period;
        key_mode_impulse <= '0';
        wait for clk_period;

        ----------------------------------------------------------
        -- 2. DATE to NORMAL via falling edge of td_date_status
        ----------------------------------------------------------
        td_date_status <= '1';     -- High for 3 seconds (simulate)
        wait for 3000 ns;
        td_date_status <= '0';     -- Falling edge
        wait for clk_period;

        ----------------------------------------------------------
        -- 3. NORMAL to STOPWATCH via key_plus_impulse
        ----------------------------------------------------------
        key_plus_impulse <= '1';
        wait for clk_period;
        key_plus_impulse <= '0';
        wait for clk_period;

        ----------------------------------------------------------
        -- 4. STOPWATCH to START via key_action_impulse
        ----------------------------------------------------------
        key_action_impulse <= '1';
        wait for clk_period;
        key_action_impulse <= '0';
        wait for clk_period;

        ----------------------------------------------------------
        -- 5. Start to Lap mode via key_minus_impulse
        ----------------------------------------------------------
        key_minus_impulse <= '1';
        wait for clk_period;
        key_minus_impulse <= '0';
        wait for clk_period;
        
        wait for 10 sec;

        ----------------------------------------------------------
        -- 6. STOPWATCH to SALR_OFF via long press
        ----------------------------------------------------------
        key_action_long <= '1';
        wait for clk_period;
        key_action_long <= '0';
        wait for clk_period;

        ----------------------------------------------------------
        -- 7. NORMAL to NALR_SNOOZE via action impulse
        ----------------------------------------------------------
        key_mode_impulse <= '1';  -- Back to NORMAL first
        wait for clk_period;
        key_mode_impulse <= '0';
        wait for clk_period;

        key_action_impulse <= '1';
        wait for clk_period;
        key_action_impulse <= '0';
        wait for clk_period;

        ----------------------------------------------------------
        wait for 10*clk_period;
        assert false report "Testbench simulation complete" severity note;
        wait;
    end process;

end Behavioral;
