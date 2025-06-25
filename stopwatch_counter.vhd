------------------------------------------------------------------------------
-- IC Design 
-- Henry Sommerville
-- stopwatch_counter.vhd
--      stopwatch counter module
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




entity stopwatch_counter is 
    generic (
            g_clk_to_hs   : integer := 99;
            g_hs_to_s     : integer := 99;
            g_s_to_min    : integer := 59;
            g_min_to_hr   : integer := 59;
            g_hr_rollover : integer := 99
    );
    
    Port (
            -- Generic
            clk     : in STD_LOGIC;

            -- input
            i_enable  : in STD_LOGIC;
            i_reset   : in STD_LOGIC;
            
            -- Output
            o_hs    : out STD_LOGIC_VECTOR(7 downto 0);
            o_s     : out STD_LOGIC_VECTOR(7 downto 0);
            o_min   : out STD_LOGIC_VECTOR(7 downto 0);
            o_h     : out STD_LOGIC_VECTOR(7 downto 0)
     );

end stopwatch_counter;

architecture Behavioural of stopwatch_counter is

    signal s_clk_to_hs_ctr   : integer range 0 to g_clk_to_hs; 
    signal s_hs              : integer range 0 to g_hs_to_s;
    signal s_s               : integer range 0 to g_s_to_min;
    signal s_min             : integer range 0 to g_min_to_hr;
    signal s_h               : integer range 0 to g_hr_rollover;
    
    signal bcd_hs, bcd_s, bcd_min, bcd_h : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal int_hs, int_s, int_min, int_h : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');


    
begin 
    int_hs  <= std_logic_vector(to_unsigned(s_hs, 8));
    int_s   <= std_logic_vector(to_unsigned(s_s, 8));
    int_min <= std_logic_vector(to_unsigned(s_min, 8));
    int_h   <= std_logic_vector(to_unsigned(s_h, 8));

    bcd_hs_enc_inst : entity work.stopwatch_bcd_encoder
        port map (
            bin_in  => int_hs,
            bcd_out => bcd_hs
        );

    bcd_s_enc_inst : entity work.stopwatch_bcd_encoder
        port map (
            bin_in  => int_s,
            bcd_out => bcd_s
        );

    bcd_min_enc_inst : entity work.stopwatch_bcd_encoder
        port map (
            bin_in  => int_min,
            bcd_out => bcd_min
        );

    bcd_h_enc_inst : entity work.stopwatch_bcd_encoder
        port map (
            bin_in  => int_h,
            bcd_out => bcd_h
        );

P_counter : process(clk)
begin
    if rising_edge(clk) then

        if (i_enable = '1') then
            
            s_clk_to_hs_ctr <= s_clk_to_hs_ctr + 1;

            if (g_clk_to_hs = s_clk_to_hs_ctr) then
                s_clk_to_hs_ctr <= 0;

                s_hs <= s_hs + 1;

                if (g_hs_to_s = s_hs) then
                    s_hs <= 0;

                    s_s <= s_s + 1;

                    if (g_s_to_min = s_s) then
                        s_s <= 0;

                        s_min <= s_min + 1;

                        if (g_min_to_hr = s_min) then
                            s_min <= 0;

                            s_h <= s_h + 1;

                            if (g_hr_rollover = s_h) then 
                                s_h <= 0;
                            end if;
                        end if;
                    end if;
                end if;
            end if;
        end if;

        if (i_reset = '1') then 
            s_hs    <= 0;
            s_s     <= 0;
            s_min   <= 0;
            s_h     <= 0;
        end if;

        
        o_hs  <= bcd_hs;
        o_s   <= bcd_s;
        o_min <= bcd_min;
        o_h   <= bcd_h;
        
    end if;


end process;


    

end Behavioural;
