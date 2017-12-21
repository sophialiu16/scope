----------------------------------------------------------------------------
--
--  VRAM state machine
--
--  This is an implementation of a Moore state machine for the VRAM controller
--  VHDL.  The inputs to the system are the clock, reset, address, chip select,
--  transfer, and write enable signals.  The outputs are the RAS, CAS, OE,
--  address selecting, acknowledge, CPU wait, serial clock enable, and WE
--  signals for the VRAM.
--
--
--
--  Revision History:
--     02/17/2017    Sophia Liu    Initial Revision
--     09/24/2017    Sophia Liu    Edited comments
----------------------------------------------------------------------------


-- bring in the necessary packages
library  ieee;
use  ieee.std_logic_1164.all;


--
--  VRAM controller FSM entity declaration
--

entity  VRAM_FSM  is
    port (
        CS         :  in  std_logic;      -- chip select
        WE_in      :  in  std_logic;      -- write enable
		  Transfer   :  in  std_logic;      -- row transfer
        clk        :  in  std_logic;      -- clock
        Reset      :  in  std_logic;      -- reset the system
        RAS        :  out  std_logic;     -- row address strobe
        CAS        :  out  std_logic;     -- column address strobe
		  Row1       :  out  std_logic;     -- 10 = row address, 11 = column address
		  Row0       :  out  std_logic;     -- 01 = sam start, 00 = current row
		  WE         :  out  std_logic;     -- write enable
        OE         :  out  std_logic;     -- output enable/data transfer
		  Acknowledge : out  std_logic;     -- finished row transfer
		  CPU_Wait   : out  std_logic;      -- wait signal to cpu, 1 on last state
		                                    --     of read/write/transfer/refresh
		  SC         : out std_logic 	     -- serial clock enabled if 1, off if 0
    );
end  VRAM_FSM;



--
--  Oscilloscope Digital Trigger Moore State Machine
--     State Assignment Architecture
--
--  This architecture just shows the basic state machine syntax when the state
--  assignments are made manually.  This is useful for minimizing output
--  decoding logic and avoiding glitches in the output (due to the decoding
--  logic).
--

architecture  assign_statebits  of  VRAM_FSM  is

    subtype  states  is  std_logic_vector(8 downto 0);     -- state type

    -- define the actual states as constants
    constant  IDLE      : states := "110011000";  -- Waiting

	 constant  ROW_1     : states := "110011001";  -- Row transfer states
	 constant  ROW_2     : states := "010010000";  --
	 constant  ROW_3     : states := "010111000";  --
	 constant  ROW_4     : states := "000111000";  --
	 constant  ROW_5     : states := "000111001";  --
	 constant  ROW_6     : states := "110111000";  --
	 constant  ROW_7     : states := "110111001";  --

	 constant  READ_1    : states := "111011010";  -- Read cycle states
    constant  READ_2    : states := "011011000";  --
	 constant  READ_3    : states := "011111000";  --
	 constant  READ_4    : states := "001110100";  -- wait state
	 constant  READ_5    : states := "001110001";  --
	 constant  READ_6    : states := "111111000";  --
	 constant  READ_7    : states := "111111010";  --

	 constant  WRITE_1    : states := "111011011";  -- write cycle states
    constant  WRITE_2    : states := "011011101";  -- wait state
	 constant  WRITE_3    : states := "001101000";  --
	 constant  WRITE_4    : states := "001101001";  --
	 constant  WRITE_5    : states := "001101010";  --
	 constant  WRITE_6    : states := "111111001";  --
	 constant  WRITE_7    : states := "111111011";  --

	 constant  REFRESH_1    : states := "110011010";  -- refresh cycle states
    constant  REFRESH_2    : states := "100011000";  --
	 constant  REFRESH_3    : states := "000011000";  --
	 constant  REFRESH_4    : states := "000011001";  --
	 constant  REFRESH_5    : states := "001011011";  --
	 constant  REFRESH_6    : states := "111011000";  --
	 constant  REFRESH_7    : states := "101011000";  --
	 constant  REFRESH_8    : states := "001011000";  --
	 constant  REFRESH_9    : states := "001011001";  --
	 constant  REFRESH_10    : states := "001111000";  --
	 constant  REFRESH_11    : states := "100011011";  --
	 constant  REFRESH_12    : states := "100011001";  --
	 constant  REFRESH_13    : states := "000011011";  --
	 constant  REFRESH_14    : states := "110011011";  --

    signal  CurrentState  :  states;    -- current state
    signal  NextState     :  states;    -- next state

begin


    -- output is state bits
    RAS <= CurrentState(8);
	 CAS <= CurrentState(7);
	 ROW1 <= CurrentState(6);
	 ROW0 <= CurrentState(5);
	 WE  <= CurrentState(4);
	 OE  <= CurrentState(3);
	 CPU_Wait <= CurrentState(2);
	 Acknowledge <= '1'  when  (CurrentState = ROW_7)
                        else  '0';
	 SC <= '0' when (CurrentState = ROW_2 or CurrentState = Row_3 or CurrentState = Row_4
	                  or CurrentState = Row_5)
					else '1';

    transition:  process (CS, WE_in, Transfer, Reset, CurrentState)
    begin

        case  CurrentState  is          -- do the state transition/output

            when  IDLE =>               -- in idle state, do transition
                if  (Transfer = '1')  then
                    NextState <= ROW_1;      -- prioritize row transfer
                elsif  (CS = '0' and WE_in = '0') then
                    NextState <= WRITE_1;    -- begin write
                elsif  (CS = '0' and WE_in = '1') then
                    NextState <= READ_1;     -- begin read
					 else
					     NextState <= REFRESH_1;   -- if not doing anything else then refresh
                end if;

				when  ROW_1 =>           -- Row cycle
                NextState <= ROW_2;

				when  ROW_2 =>           -- Row cycle
                NextState <= ROW_3;

				when  ROW_3 =>           -- Row cycle
                NextState <= ROW_4;

				when  ROW_4 =>           -- Row cycle
                NextState <= ROW_5;

				when  ROW_5 =>           -- Row cycle
                NextState <= ROW_6;

				when  ROW_6 =>           -- Row cycle
                NextState <= ROW_7;

				when  ROW_7 =>           -- End row cycle
                NextState <= IDLE;

				when  READ_1 =>           -- Read cycle
                NextState <= READ_2;

				when  READ_2 =>           -- Read cycle
                NextState <= READ_3;

				when  READ_3 =>           -- Read cycle
                NextState <= READ_4;

				when  READ_4 =>           -- Read cycle
                NextState <= READ_5;

				when  READ_5 =>           -- Read cycle
                NextState <= READ_6;

				when  READ_6 =>           -- Read cycle
                NextState <= READ_7;

				when  READ_7 =>           -- End read cycle
                NextState <= IDLE;

				when  WRITE_1 =>           -- Write cycle
                NextState <= WRITE_2;

				when  WRITE_2 =>           -- Write cycle
                NextState <= WRITE_3;

				when  WRITE_3 =>           -- Write cycle
                NextState <= WRITE_4;

				when  WRITE_4 =>           -- Write cycle
                NextState <= WRITE_5;

				when  WRITE_5 =>           -- Write cycle
                NextState <= WRITE_6;

				when  WRITE_6 =>           -- Write cycle
                NextState <= WRITE_7;

				when  WRITE_7 =>           -- End write cycle
                NextState <= IDLE;

				when  REFRESH_1 =>           -- Refresh cycle
                NextState <= REFRESH_2;

				when  REFRESH_2 =>           -- Refresh cycle
                NextState <= REFRESH_3;

				when  REFRESH_3 =>           -- Refresh cycle
                NextState <= REFRESH_4;

				when  REFRESH_4 =>           -- Refresh cycle
                NextState <= REFRESH_5;

				when  REFRESH_5 =>           -- Refresh cycle
                NextState <= REFRESH_6;

				when  REFRESH_6 =>           -- Refresh cycle
                NextState <= REFRESH_7;

				when  REFRESH_7 =>           -- Refresh cycle
                NextState <= REFRESH_8;

				when  REFRESH_8 =>           -- Refresh cycle
                NextState <= REFRESH_9;

				when  REFRESH_9 =>           -- Refresh cycle
                NextState <= REFRESH_10;

				when  REFRESH_10 =>           -- Refresh cycle
                NextState <= REFRESH_11;

				when  REFRESH_11 =>           -- Refresh cycle
                NextState <= REFRESH_12;

				when  REFRESH_12 =>           -- Refresh cycle
                NextState <= REFRESH_13;

				when  REFRESH_13 =>           -- Refresh cycle
                NextState <= REFRESH_14;

				when  REFRESH_14 =>           -- End refresh cycle
                NextState <= IDLE;

			   when others =>
				    NextState <= IDLE;

        end case;

        if  Reset = '1'  then           -- reset overrides everything
            NextState <= IDLE;          --   go to idle on reset
        end if;

    end process transition;


    -- storage of current state (loads the next state on the clock)

    process (clk)
    begin

        if  clk = '1'  then             -- only change on rising edge of clock
            CurrentState <= NextState;  -- save the new state information
        end if;

    end process;


end  assign_statebits;
