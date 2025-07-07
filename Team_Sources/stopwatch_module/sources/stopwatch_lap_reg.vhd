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

entity stopwatch_lap_reg is 
    Port (
        clk     : in STD_LOGIC;
        reset   : in STD_LOGIC;

        -- Time values stored in BCD format
        i_hs    : in STD_LOGIC_VECTOR(7 downto 0); 
        i_s     : in STD_LOGIC_VECTOR(7 downto 0);
        i_min   : in STD_LOGIC_VECTOR(7 downto 0);
        i_h     : in STD_LOGIC_VECTOR(7 downto 0);

        
        o_lap_hs    : out STD_LOGIC_VECTOR(7 downto 0); 
        o_lap_s     : out STD_LOGIC_VECTOR(7 downto 0);
        o_lap_min   : out STD_LOGIC_VECTOR(7 downto 0);
        o_lap_h     : out STD_LOGIC_VECTOR(7 downto 0)

     );
end stopwatch_lap_reg;


architecture Behavioral of stopwatch_lap_reg is

    signal reg_lap_hs    :  STD_LOGIC_VECTOR(7 downto 0); 
    signal reg_lap_s     :  STD_LOGIC_VECTOR(7 downto 0);
    signal reg_lap_min   :  STD_LOGIC_VECTOR(7 downto 0);
    signal reg_lap_h     :  STD_LOGIC_VECTOR(7 downto 0);
begin
        
process(clk)
    begin
        if rising_edge(clk) then 
            if reset = '1' then 
                reg_lap_hs  <= (others => '0');
                reg_lap_s   <= (others => '0');
                reg_lap_min <= (others => '0');
                reg_lap_h   <= (others => '0');
            else
                reg_lap_hs  <= i_hs;
                reg_lap_s   <= i_s;
                reg_lap_min <= i_min;
                reg_lap_h   <= i_h;
            end if;
    
            -- Outputs
            o_lap_hs    <= reg_lap_hs;
            o_lap_s     <= reg_lap_s;
            o_lap_min   <= reg_lap_min;
            o_lap_h     <= reg_lap_h;
        end if;
    end process;

end Behavioral;
