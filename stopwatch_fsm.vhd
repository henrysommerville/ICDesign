
------------------------------------------------------------------------------
-- IC Design 
-- Henry Sommerville
-- stopwatch_fsm.vhd 
--      fsm component for the stopwatch module
-----------------------------------------------------------------------------
-- Naming conventions:
--
-- i_Port: Input entity port
-- o_Port: Output entity port
-- b_Port: Bidirectional entity port
-- g_My_Generic: Generic entity port
--
-- c_My_Constant: Constant definition
-- t_My_Type: Custom type definition
--
-- sc_My_Signal : Signal between components
-- My_Signal_n: Active low signal
-- v_My_Variable: Variable
-- sm_My_Signal: FSM signal
-- pkg_Param: Element Param coming from a package
--
-- My_Signal_re: Rising edge detection of My_Signal
-- My_Signal_fe: Falling edge detection of My_Signal
-- My_Signal_rX: X times registered My_Signal signal
--
-- P_Process_Name: Process
-- reg_My_Register : Register
--
------------------------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity stopwatch_fsm is
    Port (
        clk             : in STD_LOGIC;
        reset           : in STD_LOGIC;

        i_sw_enable     : in STD_LOGIC;
        i_sw_lap_toggle : in STD_LOGIC;
        i_sw_reset      : in STD_LOGIC;
        
        o_counter_active : out STD_LOGIC;
        o_sw_reset       : out STD_LOGIC;
        o_lap_toggle     : out STD_LOGIC
     );


end stopwatch_fsm;

architecture Behavioral of stopwatch_fsm is 
    type t_SW_FSM_State is (
        S_RESET,
        COUNTING,
        PAUSE,
        LAP_DISPLAY
    );

    signal s_state : t_SW_FSM_STATE;

begin

    p_next_state_logic : process(clk)
    begin
        if rising_edge(clk) then    
            case s_state is 
                when S_RESET =>
                    if (i_sw_enable = '1') then 
                        s_state <= COUNTING;
                    end if;

                when COUNTING => 
                    if (i_sw_enable = '0') then
                        s_state <= PAUSE;
                    end if;
                    if (i_sw_lap_toggle = '1') then
                        s_state <= LAP_DISPLAY;
                    end if;

                when PAUSE =>
                    if (i_sw_enable = '1') then
                        s_state <= COUNTING;
                    end if;

                when LAP_DISPLAY =>
                    if (i_sw_lap_toggle = '0') then
                        s_state <= COUNTING;
                    end if;

                when others => 
                    s_state <= S_RESET;

            end case;

            if (reset = '1') then
                s_state <= S_RESET;
            end if;
        end if;
    end process;

    p_output_logic : process(s_state)
    begin
        case s_state is
            when S_RESET =>
                o_counter_active <= '0';
                o_sw_reset       <= '1';
                o_lap_toggle     <= '0';

            when COUNTING =>
                o_counter_active <= '1';
                o_sw_reset       <= '0';
                o_lap_toggle     <= '0';
                
            when PAUSE =>
                o_counter_active <= '0';
                o_sw_reset       <= '0';
                o_lap_toggle     <= '0';

            when LAP_DISPLAY =>
                o_counter_active <= '1';
                o_sw_reset       <= '0';
                o_lap_toggle     <= '1';
        end case;
    end process;
end Behavioral;
