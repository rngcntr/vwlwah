library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity AXIS2FIFO_v1_0_S00_AXIS is
    generic (
                -- Users to add parameters here

                -- User parameters ends
                -- Do not modify the parameters beyond this line

                -- AXI4Stream sink: Data Width
                C_S_AXIS_TDATA_WIDTH	: integer	:= 32
            );
    port (
             -- Users to add ports here

             inputData: out std_logic_vector (C_S_AXIS_TDATA_WIDTH-1 downto 0);
             inputWren: out std_logic;
             inputFull: in std_logic;
             inputAlmostFull: in std_logic;
             inputFinal: out std_logic;

             -- User ports ends
             -- Do not modify the ports beyond this line

             -- AXI4Stream sink: Clock
             S_AXIS_ACLK	: in std_logic;
             -- AXI4Stream sink: Reset
             S_AXIS_ARESETN	: in std_logic;
             -- Ready to accept data in
             S_AXIS_TREADY	: out std_logic;
             -- Data in
             S_AXIS_TDATA	: in std_logic_vector(C_S_AXIS_TDATA_WIDTH-1 downto 0);
             -- Byte qualifier
             --S_AXIS_TSTRB	: in std_logic_vector((C_S_AXIS_TDATA_WIDTH/8)-1 downto 0);
             -- Indicates boundary of last packet
             S_AXIS_TLAST	: in std_logic;
             -- Data is in valid
             S_AXIS_TVALID	: in std_logic
         );
end AXIS2FIFO_v1_0_S00_AXIS;

architecture arch_imp of AXIS2FIFO_v1_0_S00_AXIS is

-- Total number of input data.
-- constant NUMBER_OF_INPUT_WORDS  : integer := 8; -- (TODO): size of fifo
-- bit_num gives the minimum number of bits needed to address 'NUMBER_OF_INPUT_WORDS' size of FIFO.
-- constant bit_num  : integer := clogb2(NUMBER_OF_INPUT_WORDS-1); -- (TODO): bits for fifo size
-- Define the states of state machine
-- The control state machine oversees the writing of input streaming data to the FIFO,
-- and outputs the streaming data from the FIFO
type state is ( IDLE,        -- This is the initial/idle state 
WRITE_FIFO); -- In this state FIFO is written with the
             -- input stream data S_AXIS_TDATA 
signal axis_tready	: std_logic;
-- State variable
signal  mst_exec_state : state;  
-- FIFO implementation signals
--signal  byte_index : integer;    -- (TODO): this should not be needed
-- FIFO write enable
signal fifo_wren : std_logic;    -- TODO: use this as output
                                 -- FIFO full flag
signal fifo_full_flag : std_logic; -- TODO: read this from input
                                   -- FIFO write pointer
--signal write_pointer : integer range 0 to bit_num-1 ; --(TODO): this should not be needed (diff to byte_index?)
-- sink has accepted all the streaming data and stored in FIFO
signal writes_done : std_logic; -- TODO: what does this do?

--type BYTE_FIFO_TYPE is array (0 to (NUMBER_OF_INPUT_WORDS-1)) of std_logic_vector(((C_S_AXIS_TDATA_WIDTH/4)-1)downto 0); -- (TODO): drop this, it's the fifo
begin
    -- I/O Connections assignments

    S_AXIS_TREADY	<= axis_tready;
    -- Control state machine implementation
    process(S_AXIS_ACLK)
    begin
        if (rising_edge (S_AXIS_ACLK)) then
            if(S_AXIS_ARESETN = '0') then
                -- Synchronous reset (active low)
                mst_exec_state      <= IDLE;
            else
                case (mst_exec_state) is
                    when IDLE     => 
                        -- The sink starts accepting tdata when 
                        -- there tvalid is asserted to mark the
                        -- presence of valid streaming data 
                        if (S_AXIS_TVALID = '1')then
                            mst_exec_state <= WRITE_FIFO;
                        else
                            mst_exec_state <= IDLE;
                        end if;

                    when WRITE_FIFO => 
                        -- When the sink has accepted all the streaming input data,
                        -- the interface swiches functionality to a streaming master
                        if (writes_done = '1') then
                            mst_exec_state <= IDLE;
                        else
                            -- The sink accepts and stores tdata 
                            -- into FIFO
                            mst_exec_state <= WRITE_FIFO;
                        end if;
                end case;
            end if;  
        end if;
    end process;
    -- AXI Streaming Sink 
    -- 
    -- The example design sink is always ready to accept the S_AXIS_TDATA  until
    -- the FIFO is not filled with NUMBER_OF_INPUT_WORDS number of input words.
    -- axis_tready <= '1' when ((mst_exec_state = WRITE_FIFO) and (write_pointer <= NUMBER_OF_INPUT_WORDS-1)) else '0';
    axis_tready <= '1' when ((mst_exec_state = WRITE_FIFO) and (inputFull = '0')) else '0';

    process(S_AXIS_ACLK)
    begin
        if (rising_edge (S_AXIS_ACLK)) then
            if(S_AXIS_ARESETN = '0') then
                -- write_pointer <= 0;
                writes_done <= '0';
            else
                if (inputFull = '0') then
                    if (fifo_wren = '1') then
                        -- write pointer is incremented after every write to the FIFO
                        -- when FIFO write signal is enabled.
                        -- write_pointer <= write_pointer + 1;
                        writes_done <= '0';
                        -- (TODO): set write enable, set data
                        inputData <= S_AXIS_TDATA;
                    end if;
                    inputWren <= fifo_wren;
                    if (inputAlmostFull = '1') then
                        -- (TODO): find out if fifo will be full on next write
                        -- reads_done is asserted when NUMBER_OF_INPUT_WORDS numbers of streaming data 
                        -- has been written to the FIFO which is also marked by S_AXIS_TLAST(kept for optional usage).
                        writes_done <= '1';
                    end if;
                    if (S_AXIS_TLAST = '1') then
                        inputFinal <= '0';
                        writes_done <= '1';
                    end if;
                end if;
            end if;
        end if;
    end process;

    -- FIFO write enable generation
    fifo_wren <= S_AXIS_TVALID and axis_tready;

    -- TODO: All this should be irrelevant
    -- FIFO Implementation
    --FIFO_GEN: for byte_index in 0 to (C_S_AXIS_TDATA_WIDTH/8-1) generate

    --signal stream_data_fifo : BYTE_FIFO_TYPE;
    --begin   
    ---- Streaming input data is stored in FIFO
    --process(S_AXIS_ACLK)
    --begin
    --if (rising_edge (S_AXIS_ACLK)) then
    --if (fifo_wren = '1') then
    --stream_data_fifo(write_pointer) <= S_AXIS_TDATA((byte_index*8+7) downto (byte_index*8));
    --end if;  
    --end  if;
    --end process;

    --end generate FIFO_GEN;

    -- Add user logic here

    inputFinal <= '0'; -- TODO use tlast as final signal

    process (S_AXIS_ACLK)
    begin
        if (rising_edge (S_AXIS_ACLK)) then
            if (S_AXIS_TVALID = '1') then
                inputData <= S_AXIS_TDATA;
                inputWren <= '1';
            else
                inputWren <= '0';
            end if;
        end if;
    end process;
-- TODO: until here

-- User logic ends

end arch_imp;
