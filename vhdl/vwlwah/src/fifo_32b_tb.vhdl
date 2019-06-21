library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--  A testbench has no ports.
entity fifo_tb is
    end fifo_tb;

architecture behav of fifo_tb is

    -- found this function implementation at: https://stackoverflow.com/questions/15406887/vhdl-convert-vector-to-string
    function to_string ( a: std_logic_vector) return string is
        variable b : string (1 to a'length) := (others => NUL);
        variable stri : integer := 1; 
    begin
        for i in a'range loop
            b(stri) := std_logic'image(a((i)))(2);
            stri := stri+1;
        end loop;
        return b;
    end function;

    -- Declaration of the components that will be instantiated.
    component fifo
        Generic (
                    constant Addrbreite: natural := 3;
                    constant Wortbreite: natural := 5
                );
        Port ( Din   : in  STD_LOGIC_VECTOR (31 downto 0);
               Wr    : in  STD_LOGIC;
               Dout  : out STD_LOGIC_VECTOR (Wortbreite-1 downto 0);
               Rd    : in  STD_LOGIC;
               Empty : out STD_LOGIC;
               Full  : out STD_LOGIC;
               Final_in:  in  STD_LOGIC;
               Final_out: out STD_LOGIC;
               Reset: in STD_LOGIC;
               CLK   : in  STD_LOGIC
           );
    end component;

    --  Specifies which entity is bound with the component.
    for fifo_0: fifo use entity work.fifo_32b;

    -- outer signals
    signal outer_clk:      std_logic;
    signal final_in:       std_logic;
    signal final_out:      std_logic;
    signal outer_input:    std_logic_vector(31 downto 0);
    signal outer_wr_en:    std_logic;
    signal outer_rd_en:    std_logic;
    signal outer_output:   std_logic_vector(4 downto 0);
    signal outer_empty:    std_logic;
    signal outer_full:     std_logic;
    signal outer_reset:    std_logic;

    begin
        --  Component instantiation.
        fifo_0: fifo
        port map (CLK => outer_clk,
                  Final_in => final_in,
                  Final_out => final_out,
                  Din => outer_input,
                  Wr => outer_wr_en,
                  Dout => outer_output,
                  Rd => outer_rd_en,
                  Empty => outer_empty,
                  Full => outer_full,
                  Reset => outer_reset);

        --  This process does the real job.
        process
        type pattern_type is record
            --  The inputs of the fifo.
            outer_reset: std_logic;
            final_in:    std_logic;
            outer_input: std_logic_vector(31 downto 0);
            outer_wr_en: std_logic;
            outer_rd_en: std_logic;
            --  The expected outputs of the fifo.
            outer_output: std_logic_vector(4 downto 0);
            outer_empty: std_logic;
            final_out:   std_logic;
        end record;
        --  The patterns to apply.
        type pattern_array is array (natural range <>) of pattern_type;
        constant patterns : pattern_array :=
        (('0', '0', "00001000100010001000100000000100", '1', '1', "UUUUU", '0', '0'),  -- 00
         ('0', '0', "01000100010001000000001000100010", '1', '1', "00001", '0', '0'),  -- 01
         ('0', '0', "00000000000000000000000000000000", '1', '1', "00010", '0', '0'),  -- 02
         ('0', '0', "00000000000000000000000000000000", '1', '1', "00100", '0', '0'),  -- 03
         ('0', '1', "11111111111111111111111111111111", '1', '1', "01000", '0', '0'),  -- 04
         ('0', '0', "00000000000000000000000000000000", '0', '1', "10000", '0', '0'),  -- 05
         ('0', '0', "00000000000000000000000000000000", '0', '1', "00001", '0', '0'),  -- 06
         ('0', '0', "00000000000000000000000000000000", '0', '1', "00010", '0', '0'),  -- 07
         ('0', '0', "00000000000000000000000000000000", '0', '1', "00100", '0', '0'),  -- 08
         ('0', '0', "00000000000000000000000000000000", '0', '1', "01000", '0', '0'),  -- 09
         ('0', '0', "00000000000000000000000000000000", '0', '1', "10000", '0', '0'),  -- 10
         ('0', '0', "00000000000000000000000000000000", '0', '1', "00001", '0', '0'),  -- 11
         ('0', '0', "00000000000000000000000000000000", '0', '1', "00010", '0', '0'),  -- 12
         ('0', '0', "00000000000000000000000000000000", '0', '1', "00100", '0', '0'),  -- 13
         ('0', '0', "00000000000000000000000000000000", '0', '1', "00000", '0', '0'),  -- 14
         ('0', '0', "00000000000000000000000000000000", '0', '1', "00000", '0', '0'),  -- 15
         ('0', '0', "00000000000000000000000000000000", '0', '1', "00000", '0', '0'),  -- 16
         ('0', '0', "00000000000000000000000000000000", '0', '1', "00000", '0', '0'),  -- 17
         ('0', '0', "00000000000000000000000000000000", '0', '1', "00000", '0', '0'),  -- 18
         ('0', '0', "00000000000000000000000000000000", '0', '1', "00000", '0', '0'),  -- 19
         ('0', '0', "00000000000000000000000000000000", '0', '1', "00000", '0', '0'),  -- 20
         ('0', '0', "00000000000000000000000000000000", '0', '1', "00000", '0', '0'),  -- 21
         ('0', '0', "00000000000000000000000000000000", '0', '1', "00000", '0', '0'),  -- 22
         ('0', '0', "00000000000000000000000000000000", '0', '1', "00000", '0', '0'),  -- 23
         ('0', '0', "00000000000000000000000000000000", '0', '1', "00000", '0', '0'),  -- 24
         ('0', '0', "00000000000000000000000000000000", '0', '1', "00000", '0', '0'),  -- 25
         ('0', '0', "00000000000000000000000000000000", '0', '1', "00011", '0', '0'),  -- 26
         ('0', '0', "00000000000000000000000000000000", '0', '1', "11111", '0', '0'),  -- 27
         ('0', '0', "00000000000000000000000000000000", '0', '1', "11111", '0', '0'),  -- 28
         ('0', '0', "00000000000000000000000000000000", '0', '1', "11111", '0', '0'),  -- 29
         ('0', '0', "00000000000000000000000000000000", '0', '1', "11111", '0', '0'),  -- 30
         ('0', '0', "00000000000000000000000000000000", '0', '1', "11111", '0', '0'),  -- 31
         ('0', '0', "00000000000000000000000000000000", '0', '1', "11111", '1', '1'),  -- 32
         ('1', '0', "00000000000000000000000000000000", '0', '1', "11111", '1', '0'),  -- 33
         ('0', '0', "10000100011001010011101001010110", '1', '1', "11111", '0', '0'),  -- 34
         ('0', '0', "00000000000000000000000000000000", '0', '1', "10000", '0', '0'),  -- 35
         ('0', '0', "00000000000000000000000000000000", '0', '1', "10001", '0', '0'),  -- 36
         ('0', '0', "00000000000000000000000000000000", '0', '1', "10010", '0', '0'),  -- 37
         ('0', '0', "00000000000000000000000000000000", '0', '1', "10011", '0', '0'),  -- 38
         ('0', '0', "00000000000000000000000000000000", '0', '1', "10100", '0', '0'),  -- 39
         ('0', '0', "00000000000000000000000000000000", '0', '1', "10101", '1', '0'),  -- 40
         ('0', '0', "00000000000000000000000000000000", '0', '1', "10101", '1', '0'),  -- 41
         ('0', '1', "11010111110001100111010110110000", '1', '1', "10101", '0', '0'),  -- 42
         ('0', '0', "00000000000000000000000000000000", '0', '1', "10110", '0', '0'),  -- 43
         ('0', '0', "00000000000000000000000000000000", '0', '1', "10111", '0', '0'),  -- 44
         ('0', '0', "00000000000000000000000000000000", '0', '1', "11000", '0', '0'),  -- 45
         ('0', '0', "00000000000000000000000000000000", '0', '1', "11001", '0', '0'),  -- 46
         ('0', '0', "00000000000000000000000000000000", '0', '1', "11010", '0', '0'),  -- 47
         ('0', '0', "00000000000000000000000000000000", '0', '1', "11011", '1', '1'),  -- 48
         ('0', '0', "00000000000000000000000000000000", '0', '1', "11011", '1', '1'),  -- 49
         ('0', '0', "00000000000000000000000000000000", '0', '1', "11011", '1', '1'),  -- 50
         ('0', '0', "00000000000000000000000000000000", '0', '1', "11011", '1', '1'),  -- 51
         ('0', '0', "00000000000000000000000000000000", '0', '1', "11011", '1', '1'),  -- 52
         ('0', '0', "00000000000000000000000000000000", '0', '1', "11011", '1', '1'),  -- 53
         ('0', '0', "00000000000000000000000000000000", '0', '1', "11011", '1', '1'),  -- 54
         ('0', '0', "00000000000000000000000000000000", '0', '1', "11011", '1', '1'),  -- 55
         ('0', '0', "00000000000000000000000000000000", '0', '1', "11011", '1', '1'),  -- 56
         ('0', '0', "00000000000000000000000000000000", '0', '1', "11011", '1', '1'),  -- 57
         ('0', '0', "00000000000000000000000000000000", '0', '1', "11011", '1', '1'),  -- 58
         ('0', '0', "00000000000000000000000000000000", '0', '1', "11011", '1', '1'),  -- 59
         ('0', '0', "00000000000000000000000000000000", '0', '1', "11011", '1', '1'),  -- 60
         ('0', '0', "00000000000000000000000000000000", '0', '1', "11011", '1', '1'),  -- 61
         ('0', '0', "00000000000000000000000000000000", '0', '1', "11011", '1', '1'),  -- 62
         ('0', '0', "00000000000000000000000000000000", '0', '1', "11011", '1', '1'),  -- 63
         ('0', '0', "00000000000000000000000000000000", '0', '1', "11011", '1', '1')); -- 64

        begin
            assert false report "begin of test" severity note;

            --  Check each pattern.
            for i in patterns'range loop
                --  Set the inputs.
                outer_wr_en <= patterns(i).outer_wr_en;
                outer_input <= patterns(i).outer_input;
                outer_rd_en <= patterns(i).outer_rd_en;
                final_in <= patterns(i).final_in;
                outer_reset <= patterns(i).outer_reset;

                -- simulate the clock
                outer_clk <= '0';
                wait for 1 ns;
                outer_clk <= '1';

                --  Wait for the results.
                wait for 1 ns;

                --  Check the outputs.
                assert outer_empty = patterns(i).outer_empty
                report "empty state incorrect in test " & integer'image(i) & ". Expected: " & std_logic'image(patterns(i).outer_empty) & " but found " & std_logic'image(outer_empty) severity error;

                assert outer_output = patterns(i).outer_output
                report "bad encoding in test " & integer'image(i) & ". Expected: " & to_string(patterns(i).outer_output) & " but found " & to_string(outer_output) severity error;

                assert final_out = patterns(i).final_out
                report "bad final state in test " & integer'image(i) & ". Expected: " & std_logic'image(patterns(i).final_out) & " but found " & std_logic'image(final_out) severity error;
            end loop;

            assert false report "end of test" severity note;
            --  Wait forever; this will finish the simulation.
            wait;
        end process;
    end behav;
