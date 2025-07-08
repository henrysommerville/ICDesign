library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity global_fsm is
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
	sw_reset            : out std_logic
);
end global_fsm;

architecture Behavioral of global_fsm is

    type state_type is ( NORMAL, DATE, STOPWATCH_S1, RESET_ST,
	DALR_SNOOZE, DALR_OFF, ALARM_S1, NALR_SNOOZE, NALR_OFF,
	SW_STRT, SW_PAUSE, SALR_SNOOZE, SALR_OFF, S1_SWRST,
	ALARM_INC, ALARM_DEC, ALARM_SWITCH, AALR_SNOOZE, AALR_OFF,
	SW_LAP, SWALR_SNOOZE, SWALR_OFF, INTSW_RST
    );

signal current_state, next_state : state_type;

    -- Internal output registers
    signal mode_reg : std_logic_vector(1 downto 0);
    signal alarm_set_incr_min_reg : std_logic;
    signal alarm_set_decr_min_reg : std_logic;
    signal alarm_toggle_active_reg : std_logic;
    signal alarm_snoozed_reg : std_logic;
    signal alarm_off_reg : std_logic;
    signal sw_start_reg : std_logic;
    signal sw_lap_toggle_reg : std_logic;
    signal sw_reset_reg : std_logic;
    signal td_date_status_reg : std_logic;
    signal falling_edge_detected : std_logic;

begin

mode <= mode_reg ;
alarm_set_incr_min <= alarm_set_incr_min_reg ;
alarm_set_decr_min <= alarm_set_decr_min_reg ;
alarm_toggle_active <= alarm_toggle_active_reg ;
alarm_snoozed <= alarm_snoozed_reg ;
alarm_off <= alarm_off_reg ;
sw_start <= sw_start_reg ;
sw_lap_toggle <= sw_lap_toggle_reg;
sw_reset <= sw_reset_reg;


--falling edge detector
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                td_date_status_reg <= '0';
            else
                td_date_status_reg <= td_date_status;
            end if;
        end if;
    end process;

    falling_edge_detected <= '1' when (td_date_status_reg = '1' and td_date_status = '0') else '0';


    process(clk)
    begin

	if rising_edge(clk) then
            if reset = '1' then
                current_state <= RESET_ST;
            else
                current_state <= next_state;
            end if;
        end if;

    end process;

process(key_enable,key_action_impulse, key_action_long, key_mode_impulse,key_minus_impulse,key_plus_impulse, td_date_status)
begin
case current_state is
            when RESET_ST =>
                next_state <= NORMAL;

            when NORMAL =>
                if key_mode_impulse = '1' then
                    next_state <= DATE;
		elsif key_action_impulse = '1' then
		    next_state <= NALR_SNOOZE;
		elsif key_action_long = '1' then
		    next_state <= NALR_OFF;
		elsif (key_plus_impulse = '1' or key_minus_impulse = '1') then
		    next_state <= STOPWATCH_S1;
                end if;

            when NALR_SNOOZE =>
                next_state <= NORMAL;

            when AALR_SNOOZE =>
                next_state <= ALARM_S1;

            when NALR_OFF =>
                next_state <= NORMAL;

            when DALR_SNOOZE =>
                next_state <= DATE;

            when DALR_OFF =>
                next_state <= DATE;

            when ALARM_SWITCH =>
                next_state <= ALARM_S1;

            when AALR_OFF =>
                next_state <= ALARM_S1;

            when ALARM_INC =>
                next_state <= ALARM_S1;

            when ALARM_DEC =>
                next_state <= ALARM_S1;

            when SWALR_OFF =>
                next_state <= SW_STRT;

            when SWALR_SNOOZE =>
                next_state <= SW_STRT;

            when SALR_OFF =>
                next_state <= STOPWATCH_S1;

            when SALR_SNOOZE =>
                next_state <= STOPWATCH_S1;

            when S1_SWRST =>
                next_state <= STOPWATCH_S1;

            when SW_PAUSE =>
                next_state <= STOPWATCH_S1;

            when INTSW_RST =>
                next_state <= STOPWATCH_S1;

            when STOPWATCH_S1 =>  
		if (key_action_impulse = '1' and alarm_ring = '1') then
		    next_state <= SALR_SNOOZE;
                elsif key_action_impulse = '1' then
                    next_state <= SW_STRT;
                elsif key_action_long = '1' then
                    next_state <= SALR_OFF;
		elsif key_plus_impulse = '1' then
		    next_state <= S1_SWRST;
                end if;

            when ALARM_S1 =>
                if (key_plus_minus = '1' or key_plus_impulse = '1') then
                    next_state <= ALARM_INC;
                elsif (key_plus_minus = '0' or key_minus_impulse = '0') then
                    next_state <= ALARM_DEC;
		elsif (key_action_impulse = '1' and alarm_ring = '1') then
		    next_state <= AALR_SNOOZE;
		elsif key_action_impulse = '1' then
		    next_state <= ALARM_SWITCH;
		elsif key_action_long = '1' then
		    next_state <= AALR_OFF;
		elsif key_mode_impulse = '1' then
		    next_state <= NORMAL;
                end if;

            when SW_STRT =>
                if key_mode_impulse = '1' then
                    next_state <= NORMAL;
                elsif key_minus_impulse = '1' then
                    next_state <= SW_LAP;
		elsif (key_action_impulse = '1' and alarm_ring = '1') then
		    next_state <= SWALR_SNOOZE;
		elsif key_action_impulse = '1' then
		    next_state <= SW_PAUSE;
		elsif key_action_long = '1' then
		    next_state <= SWALR_OFF;
		elsif key_plus_impulse = '1' then
		    next_state <= INTSW_RST;
                end if;

            when SW_LAP =>
                if key_minus_impulse = '1' then
                    next_state <= SW_LAP;
                else
                    next_state <= SW_STRT;
                end if;

            when DATE =>
                if key_action_impulse = '1' then
                    next_state <= DALR_SNOOZE;
		elsif key_action_long = '1' then
		    next_state <= DALR_OFF;
		elsif key_mode_impulse = '1' then
		    next_state <= ALARM_S1;
		elsif falling_edge_detected = '1' then    --falling edge logic 
		    next_state <= NORMAL;
                end if;

end case;
end process;

    -- Output logic 
    process(current_state)
    begin
if rising_edge(clk) then
        case current_state is
            when RESET_ST =>
                mode_reg <= (others => '0') ;
                alarm_set_incr_min_reg <= '0' ;
                alarm_set_decr_min_reg <= '0' ;
                alarm_toggle_active_reg <= '0' ;
                alarm_snoozed_reg <= '0' ;
                alarm_off_reg <= '0' ;
                sw_start_reg <= '0' ;
                sw_lap_toggle_reg <= '0';
                sw_reset_reg <= '0';

            when NORMAL =>
	mode_reg 		    <= "00";
	alarm_off_reg           <= '0';
	alarm_snoozed_reg       <= '0';

            when DATE =>
	mode_reg 		    <= "01";
	alarm_off_reg           <= '0';
	alarm_snoozed_reg       <= '0';	
 

            when STOPWATCH_S1 =>
	mode_reg 		    <= "11";
	sw_reset_reg            <= '0';
	alarm_off_reg           <= '0';
	alarm_snoozed_reg       <= '0';

            when DALR_SNOOZE =>
	alarm_snoozed_reg       <= '1';

            when SWALR_SNOOZE =>
	alarm_snoozed_reg       <= '1';

            when SALR_SNOOZE =>
	alarm_snoozed_reg       <= '1';


            when DALR_OFF =>
	alarm_off_reg           <= '1';

            when ALARM_S1 =>
	mode_reg 		    <= "10";
	alarm_set_incr_min_reg  <= '0';
	alarm_set_decr_min_reg  <= '0';
	alarm_off_reg           <= '0';
	alarm_snoozed_reg       <= '0';


            when NALR_SNOOZE =>
	alarm_snoozed_reg       <= '1';


            when NALR_OFF =>
	alarm_off_reg           <= '1';

            when SW_STRT =>
	sw_start_reg            <= '1';
	sw_reset_reg            <= '0';
	alarm_off_reg           <= '0';
	alarm_snoozed_reg       <= '0';

            when SW_PAUSE =>
	sw_start_reg            <= '0';


            when SALR_OFF =>
	alarm_off_reg           <= '1';


            when S1_SWRST =>
	sw_start_reg            <= '0';
	sw_lap_toggle_reg       <= '0';
	sw_reset_reg            <= '1';

            when ALARM_INC =>
	alarm_set_incr_min_reg  <= '1';

            when ALARM_DEC =>
	alarm_set_incr_min_reg  <= '1';

            when ALARM_SWITCH =>
	alarm_toggle_active_reg <= not alarm_toggle_active_reg;


            when AALR_OFF =>
	alarm_off_reg           <= '1';


            when SW_LAP =>
	sw_lap_toggle_reg       <= not sw_lap_toggle_reg;


            when SWALR_OFF =>
	alarm_off_reg           <= '1';


            when INTSW_RST =>
	sw_start_reg            <= '0';
	sw_lap_toggle_reg       <= '0';
	sw_reset_reg            <= '1';
	
	       when others =>
                mode_reg <= (others => '0') ;
                alarm_set_incr_min_reg <= '0' ;
                alarm_set_decr_min_reg <= '0' ;
                alarm_toggle_active_reg <= '0' ;
                alarm_snoozed_reg <= '0' ;
                alarm_off_reg <= '0' ;
                sw_start_reg <= '0' ;
                sw_lap_toggle_reg <= '0';
                sw_reset_reg <= '0';	       

        end case;
      end if;
    end process;

end Behavioral; 
