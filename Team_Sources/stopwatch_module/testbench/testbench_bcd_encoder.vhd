library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_stopwatch_bcd_encoder is
end tb_stopwatch_bcd_encoder;

architecture test of tb_stopwatch_bcd_encoder is

    signal bin_in  : STD_LOGIC_VECTOR(7 downto 0);
    signal bcd_out : STD_LOGIC_VECTOR(7 downto 0);

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: entity work.stopwatch_bcd_encoder
        port map (
            bin_in  => bin_in,
            bcd_out => bcd_out
        );

    -- Stimulus process
    stim_proc: process
    begin
        -- Test 0
        bin_in <= x"00";  -- 0
        wait for 10 ns;
        
        -- Test 9
        bin_in <= x"09";  -- 9
        wait for 10 ns;

        -- Test 10
        bin_in <= x"0A";  -- 10
        wait for 10 ns;

        -- Test 15
        bin_in <= x"0F";  -- 15
        wait for 10 ns;

        -- Test 37
        bin_in <= std_logic_vector(to_unsigned(37, 8));
        wait for 10 ns;

        -- Test 59
        bin_in <= std_logic_vector(to_unsigned(59, 8));
        wait for 10 ns;

        -- Test 99
        bin_in <= std_logic_vector(to_unsigned(99, 8));
        wait for 10 ns;

        -- End simulation
        wait;
    end process;

end test;
