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
               CLK   : in  STD_LOGIC
           );
    end component;

    --  Specifies which entity is bound with the component.
    for fifo_0: fifo use entity work.fifo_32b;

    -- outer signals
    signal outer_clk:      std_logic;
    signal outer_input:    std_logic_vector(31 downto 0);
    signal outer_wr_en:    std_logic;
    signal outer_rd_en:    std_logic;
    signal outer_output:   std_logic_vector(4 downto 0);
    signal outer_empty:    std_logic;
    signal outer_full:     std_logic;

    begin
        --  Component instantiation.
        fifo_0: fifo
        port map (CLK => outer_clk,
                  Din => outer_input,
                  Wr => outer_wr_en,
                  Dout => outer_output,
                  Rd => outer_rd_en,
                  Empty => outer_empty,
                  Full => outer_full);

        --  This process does the real job.
        process
        type pattern_type is record
            --  The inputs of the fifo.
            outer_input: std_logic_vector(31 downto 0);
            outer_wr_en: std_logic;
            outer_rd_en: std_logic;
            --  The expected outputs of the fifo.
            outer_output: std_logic_vector(4 downto 0);
            outer_empty: std_logic;
        end record;
        --  The patterns to apply.
        type pattern_array is array (natural range <>) of pattern_type;
        constant patterns : pattern_array :=
        (("00001000100010001000100000000100", '1', '1', "UUUUU", '0'),  -- 00
         ("01000100010001000000001000100010", '1', '1', "00001", '0'),  -- 01
         ("00000000000000000000000000000000", '0', '1', "00010", '0'),  -- 02
         ("00000000000000000000000000000000", '0', '1', "00100", '0'),  -- 03
         ("00000000000000000000000000000000", '0', '1', "01000", '0'),  -- 04
         ("00000000000000000000000000000000", '0', '1', "10000", '0'),  -- 05
         ("00000000000000000000000000000000", '0', '1', "00001", '0'),  -- 06
         ("00000000000000000000000000000000", '0', '1', "00010", '0'),  -- 07
         ("00000000000000000000000000000000", '0', '1', "00100", '0'),  -- 08
         ("00000000000000000000000000000000", '0', '1', "01000", '0'),  -- 09
         ("00000000000000000000000000000000", '0', '1', "10000", '0'),  -- 10
         ("00000000000000000000000000000000", '0', '1', "00001", '0'),  -- 11
         ("00000000000000000000000000000000", '0', '1', "00010", '1'),  -- 12
         ("00000000000000000000000000000000", '0', '1', "00010", '1'),  -- 13
         ("00000000000000000000000000000000", '0', '1', "00010", '1'),  -- 14
         ("00000000000000000000000000000000", '0', '1', "00010", '1'),  -- 15
         ("00000000000000000000000000000000", '0', '1', "00010", '1'),  -- 16
         ("00000000000000000000000000000000", '0', '1', "00010", '1'),  -- 17
         ("00000000000000000000000000000000", '0', '1', "00010", '1'),  -- 18
         ("00000000000000000000000000000000", '0', '1', "00010", '1'),  -- 19
         ("00000000000000000000000000000000", '0', '1', "00010", '1')); -- 20

        begin
            assert false report "begin of test" severity note;

            --  Check each pattern.
            for i in patterns'range loop
                --  Set the inputs.
                outer_wr_en <= patterns(i).outer_wr_en;
                outer_input <= patterns(i).outer_input;
                outer_rd_en <= patterns(i).outer_rd_en;

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
            end loop;

            assert false report "end of test" severity note;
            --  Wait forever; this will finish the simulation.
            wait;
        end process;
    end behav;
