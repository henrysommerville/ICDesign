----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/15/2025 09:02:44 PM
-- Design Name: 
-- Module Name: time_date_module - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;



entity time_date_module is
    Port(
        de_set : in  STD_LOGIC;
        de_dow : in  STD_LOGIC_VECTOR (2 downto 0);
        de_day : in  STD_LOGIC_VECTOR (5 downto 0);
        de_month : in  STD_LOGIC_VECTOR (4 downto 0);
        de_year : in  STD_LOGIC_VECTOR (7 downto 0);
        de_hour : in  STD_LOGIC_VECTOR (5 downto 0);
        de_min : in  STD_LOGIC_VECTOR (6 downto 0);
        mode : in STD_LOGIC_VECTOR (2 downto 0);
        reset : in  STD_LOGIC;
        clk_10K : in STD_LOGIC;
        td_dcf_show: out STD_LOGIC;
        td_dow : out  STD_LOGIC_VECTOR (7 downto 0);
        td_day : out  STD_LOGIC_VECTOR (7 downto 0);
        td_month : out  STD_LOGIC_VECTOR (7 downto 0);
        td_year : out  STD_LOGIC_VECTOR (7 downto 0);
        td_hour : out  STD_LOGIC_VECTOR (7 downto 0);
        td_min : out  STD_LOGIC_VECTOR (7 downto 0);
        td_sec : out  STD_LOGIC_VECTOR (7 downto 0);
        td_date_status : out STD_LOGIC
    );
end time_date_module;


architecture Behavioral of time_date_module is

begin

syncunit : entity work.time_date_SyncUnit
     PORT MAP(
        de_dow => de_dow,
        de_day => de_day,
        de_month => de_month,
        de_year => de_year,
        de_hour => de_hour,
        de_min => de_min,
        de_set => de_set,
        reset => reset,
        clk_10K => clk_10K,
        td_dcf_show => td_dcf_show,
        td_dow => td_dow,
        td_day => td_day,
        td_month => td_month,
        td_year => td_year,
        td_hour => td_hour,
        td_min => td_min,
        td_sec => td_sec
    );

datemodetimer : entity work.time_date_DateModeTimer
    PORT MAP(
        reset => reset,
        mode => mode,
        clk_10K => clk_10K,
        td_date_status => td_date_status
    );
end Behavioral;



