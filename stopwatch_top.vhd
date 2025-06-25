------------------------------------------------------------------------------
-- IC Design 
-- Henry Sommerville
-- Stopwatch_top.vhd 
--      Top component for the stopwatch module
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

entity stopwatch_top is 
    Port (
        --Generic
        clk              : in STD_LOGIC;                     -- 10kHz clock
        reset            : in STD_LOGIC;                     -- System hard reset

        -- Input
        i_sw_enable       : in STD_LOGIC;                     -- enables stopwatch counting
        i_sw_lap_toggle   : in STD_LOGIC;                     -- Toggles lap display on/off
        i_sw_reset        : in STD_LOGIC;                     -- Soft reset for stopwatch clock 


        -- Output
        o_sw_time_hs      : out STD_LOGIC_VECTOR(7 downto 0); -- Time to display in hundredth of a second (BCD format)
        o_sw_time_s       : out STD_LOGIC_VECTOR(7 downto 0); -- Time to display in seconds (BCD format)
        o_sw_time_min     : out STD_LOGIC_VECTOR(7 downto 0); -- Time to display in mins (BCD format)
        o_sw_time_h       : out STD_LOGIC_VECTOR(7 downto 0); -- Time to display in hours (BCD format)
        o_sw_lap          : out STD_LOGIC                     -- Lap time toggle
    );

end stopwatch_top;

architecture Structural of stopwatch_top is

    signal s_combined_reset  : STD_LOGIC;

    signal sm_counter_active : STD_LOGIC;
    signal sm_reset          : STD_LOGIC;
    signal sm_lap_toggle     : STD_LOGIC;

    signal sc_time_hs        : STD_LOGIC_VECTOR(7 downto 0);
    signal sc_time_s         : STD_LOGIC_VECTOR(7 downto 0);
    signal sc_time_min       : STD_LOGIC_VECTOR(7 downto 0);
    signal sc_time_h         : STD_LOGIC_VECTOR(7 downto 0);

    signal sc_lap_time_hs    : STD_LOGIC_VECTOR(7 downto 0);
    signal sc_lap_time_s     : STD_LOGIC_VECTOR(7 downto 0);
    signal sc_lap_time_min   : STD_LOGIC_VECTOR(7 downto 0);
    signal sc_lap_time_h     : STD_LOGIC_VECTOR(7 downto 0);

    signal sc_mux_hs         : STD_LOGIC_VECTOR(7 downto 0);
    signal sc_mux_s          : STD_LOGIC_VECTOR(7 downto 0);
    signal sc_mux_min        : STD_LOGIC_VECTOR(7 downto 0);
    signal sc_mux_h          : STD_LOGIC_VECTOR(7 downto 0);
begin
    
    s_combined_reset <= reset or i_sw_reset;

    fsm_inst : entity work.stopwatch_fsm
        port map (
            clk             => clk,
            reset           => s_combined_reset,
            i_sw_enable     => i_sw_enable,
            i_sw_reset      => i_sw_reset,
            i_sw_lap_toggle => i_sw_lap_toggle,

            o_counter_active => sm_counter_active,
            o_sw_reset       => sm_reset,
            o_lap_toggle     => sm_lap_toggle
        );

    counter_inst : entity work.stopwatch_counter
        port map (
            clk     => clk,
            
            i_reset   => sm_reset,
            i_enable  => sm_counter_active,
            
            o_hs    => sc_time_hs,
            o_s     => sc_time_s,
            o_min   => sc_time_min,
            o_h     => sc_time_h
        );


    sc_mux_hs  <= sc_time_hs  when sm_lap_toggle = '0' else sc_lap_time_hs;
    sc_mux_s   <= sc_time_s   when sm_lap_toggle = '0' else sc_lap_time_s;
    sc_mux_min <= sc_time_min when sm_lap_toggle = '0' else sc_lap_time_min;
    sc_mux_h   <= sc_time_h   when sm_lap_toggle = '0' else sc_lap_time_h;

    lap_storage_inst : entity work.stopwatch_lap_reg
        port map (
            clk           => clk,
            reset         => sm_reset,
            i_hs          => sc_mux_hs,
            i_s           => sc_mux_s,
            i_min         => sc_mux_min,
            i_h           => sc_mux_h,
            o_lap_hs      => sc_lap_time_hs,
            o_lap_s       => sc_lap_time_s,
            o_lap_min     => sc_lap_time_min,
            o_lap_h       => sc_lap_time_h
        );


    
    o_sw_time_hs <= sc_lap_time_hs  when sm_lap_toggle = '1' else sc_time_hs;
    o_sw_time_s  <= sc_lap_time_s   when sm_lap_toggle = '1' else sc_time_s;
    o_sw_time_min<= sc_lap_time_min when sm_lap_toggle = '1' else sc_time_min;
    o_sw_time_h  <= sc_lap_time_h   when sm_lap_toggle = '1' else sc_time_h;
    o_sw_lap     <= sm_lap_toggle;
        


end Structural;
