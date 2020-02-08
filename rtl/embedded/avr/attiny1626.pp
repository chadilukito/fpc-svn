unit ATtiny1626;

{$goto on}
interface

type
  TAC = object //Analog Comparator
    CTRLA: byte;  //Control A
    Reserved1: byte;
    MUXCTRLA: byte;  //Mux Control A
    Reserved3: byte;
    DACREF: byte;  //Referance scale control
    Reserved5: byte;
    INTCTRL: byte;  //Interrupt Control
    STATUS: byte;  //Status
  const
    // Enable
    ENABLEbm = $01;
    // AC_HYSMODE
    HYSMODEmask = $06;
    HYSMODE_OFF = $00;
    HYSMODE_10mV = $02;
    HYSMODE_25mV = $04;
    HYSMODE_50mV = $06;
    // AC_INTMODE
    INTMODEmask = $30;
    INTMODE_BOTHEDGE = $00;
    INTMODE_NEGEDGE = $20;
    INTMODE_POSEDGE = $30;
    // AC_LPMODE
    LPMODEmask = $08;
    LPMODE_DIS = $00;
    LPMODE_EN = $08;
    // Output Buffer Enable
    OUTENbm = $40;
    // Run in Standby Mode
    RUNSTDBYbm = $80;
    // DAC voltage reference
    DATA0bm = $01;
    DATA1bm = $02;
    DATA2bm = $04;
    DATA3bm = $08;
    DATA4bm = $10;
    DATA5bm = $20;
    DATA6bm = $40;
    DATA7bm = $80;
    // Analog Comparator 0 Interrupt Enable
    CMPbm = $01;
    // Invert AC Output
    INVERTbm = $80;
    // AC_MUXNEG
    MUXNEGmask = $03;
    MUXNEG_PIN0 = $00;
    MUXNEG_PIN1 = $01;
    MUXNEG_PIN2 = $02;
    MUXNEG_DACREF = $03;
    // AC_MUXPOS
    MUXPOSmask = $18;
    MUXPOS_PIN0 = $00;
    MUXPOS_PIN1 = $08;
    MUXPOS_PIN2 = $10;
    MUXPOS_PIN3 = $18;
    // Analog Comparator State
    STATEbm = $10;
  end;

  TADC = object //Analog to Digital Converter
    CTRLA: byte;  //Control A
    CTRLB: byte;  //Control B
    CTRLC: byte;  //Control C
    CTRLD: byte;  //Control D
    INTCTRL: byte;  //Interrupt Control
    INTFLAGS: byte;  //Interrupt Flags
    STATUS: byte;  //Status register
    DBGCTRL: byte;  //Debug Control
    CTRLE: byte;  //Control E
    CTRLF: byte;  //Control F
    COMMAND: byte;  //Command register
    PGACTRL: byte;  //PGA Control
    MUXPOS: byte;  //Positive mux input
    MUXNEG: byte;  //Negative mux input
    Reserved14: byte;
    Reserved15: byte;
    RESULT: dword;  //Result
    SAMPLE: word;  //Sample
    Reserved22: byte;
    Reserved23: byte;
    TEMP0: byte;  //Temporary Data 0
    TEMP1: byte;  //Temporary Data 1
    TEMP2: byte;  //Temporary Data 2
    Reserved27: byte;
    WINLT: word;  //Window Low Threshold
    WINHT: word;  //Window High Threshold
  const
    // Differential mode
    DIFFbm = $80;
    // ADC_MODE
    MODEmask = $70;
    MODE_SINGLE_8BIT = $00;
    MODE_SINGLE_12BIT = $10;
    MODE_SERIES = $20;
    MODE_SERIES_TRUNCATION = $30;
    MODE_BURST = $40;
    MODE_BURST_TRUNCATION = $50;
    // ADC_START
    STARTmask = $07;
    START_STOP = $00;
    START_IMMEDIATE = $01;
    START_MUXPOS_WRITE = $02;
    START_MUXNEG_WRITE = $03;
    START_EVENT_TRIGGER = $04;
    // ADC Enable
    ENABLEbm = $01;
    // ADC Low latency mode
    LOWLATbm = $20;
    // Run standby mode
    RUNSTDBYbm = $80;
    // ADC_PRESC
    PRESCmask = $0F;
    PRESC_DIV2 = $00;
    PRESC_DIV4 = $01;
    PRESC_DIV6 = $02;
    PRESC_DIV8 = $03;
    PRESC_DIV10 = $04;
    PRESC_DIV12 = $05;
    PRESC_DIV14 = $06;
    PRESC_DIV16 = $07;
    PRESC_DIV20 = $08;
    PRESC_DIV24 = $09;
    PRESC_DIV28 = $0A;
    PRESC_DIV32 = $0B;
    PRESC_DIV40 = $0C;
    PRESC_DIV48 = $0D;
    PRESC_DIV56 = $0E;
    PRESC_DIV64 = $0F;
    // ADC_REFSEL
    REFSELmask = $07;
    REFSEL_VDD = $00;
    REFSEL_VREFA = $02;
    REFSEL_1024MV = $04;
    REFSEL_2048MV = $05;
    REFSEL_2500MV = $06;
    REFSEL_4096MV = $07;
    // Reference Selection
    TIMEBASE0bm = $08;
    TIMEBASE1bm = $10;
    TIMEBASE2bm = $20;
    TIMEBASE3bm = $40;
    TIMEBASE4bm = $80;
    // ADC_WINCM
    WINCMmask = $07;
    WINCM_NONE = $00;
    WINCM_BELOW = $01;
    WINCM_ABOVE = $02;
    WINCM_INSIDE = $03;
    WINCM_OUTSIDE = $04;
    // ADC_WINSRC
    WINSRCmask = $08;
    WINSRC_RESULT = $00;
    WINSRC_SAMPLE = $08;
    // Sampling time
    SAMPDUR0bm = $01;
    SAMPDUR1bm = $02;
    SAMPDUR2bm = $04;
    SAMPDUR3bm = $08;
    SAMPDUR4bm = $10;
    SAMPDUR5bm = $20;
    SAMPDUR6bm = $40;
    SAMPDUR7bm = $80;
    // Free running mode
    FREERUNbm = $20;
    // Left adjust
    LEFTADJbm = $10;
    // ADC_SAMPNUM
    SAMPNUMmask = $0F;
    SAMPNUM_NONE = $00;
    SAMPNUM_ACC2 = $01;
    SAMPNUM_ACC4 = $02;
    SAMPNUM_ACC8 = $03;
    SAMPNUM_ACC16 = $04;
    SAMPNUM_ACC32 = $05;
    SAMPNUM_ACC64 = $06;
    SAMPNUM_ACC128 = $07;
    SAMPNUM_ACC256 = $08;
    SAMPNUM_ACC512 = $09;
    SAMPNUM_ACC1024 = $0A;
    // Debug run
    DBGRUNbm = $01;
    // Result Overwritten Interrupt Enable
    RESOVRbm = $08;
    // Result Ready Interrupt Enable
    RESRDYbm = $01;
    // Sample Overwritten Interrupt Enable
    SAMPOVRbm = $10;
    // Sample Ready Interrupt Enable
    SAMPRDYbm = $02;
    // Trigger Overrun Interrupt Enable
    TRIGOVRbm = $20;
    // Window Comparator Interrupt Enable
    WCMPbm = $04;
    // ADC_MUXNEG
    MUXNEGmask = $3F;
    MUXNEG_AIN1 = $01;
    MUXNEG_AIN2 = $02;
    MUXNEG_AIN3 = $03;
    MUXNEG_AIN4 = $04;
    MUXNEG_AIN5 = $05;
    MUXNEG_AIN6 = $06;
    MUXNEG_AIN7 = $07;
    MUXNEG_GND = $30;
    MUXNEG_VDDDIV10 = $31;
    MUXNEG_DAC = $33;
    // ADC_VIA
    VIAmask = $C0;
    VIA_ADC = $00;
    VIA_PGA = $40;
    // ADC_MUXPOS
    MUXPOSmask = $3F;
    MUXPOS_AIN1 = $01;
    MUXPOS_AIN2 = $02;
    MUXPOS_AIN3 = $03;
    MUXPOS_AIN4 = $04;
    MUXPOS_AIN5 = $05;
    MUXPOS_AIN6 = $06;
    MUXPOS_AIN7 = $07;
    MUXPOS_AIN8 = $08;
    MUXPOS_AIN9 = $09;
    MUXPOS_AIN10 = $0A;
    MUXPOS_AIN11 = $0B;
    MUXPOS_AIN12 = $0C;
    MUXPOS_AIN13 = $0D;
    MUXPOS_AIN14 = $0E;
    MUXPOS_AIN15 = $0F;
    MUXPOS_GND = $30;
    MUXPOS_VDDDIV10 = $31;
    MUXPOS_TEMPSENSE = $32;
    MUXPOS_DAC = $33;
    // ADC_ADCPGASAMPDUR
    ADCPGASAMPDURmask = $06;
    ADCPGASAMPDUR_6CLK = $00;
    ADCPGASAMPDUR_15CLK = $02;
    ADCPGASAMPDUR_20CLK = $04;
    ADCPGASAMPDUR_32CLK = $06;
    // ADC_GAIN
    GAINmask = $E0;
    GAIN_1X = $00;
    GAIN_2X = $20;
    GAIN_4X = $40;
    GAIN_8X = $60;
    GAIN_16X = $80;
    // ADC_PGABIASSEL
    PGABIASSELmask = $18;
    PGABIASSEL_1X = $00;
    PGABIASSEL_3_4X = $08;
    PGABIASSEL_1_2X = $10;
    PGABIASSEL_1_4X = $18;
    // PGA Enable
    PGAENbm = $01;
    // ADC Busy
    ADCBUSYbm = $01;
    // Temporary
    TEMP0bm = $01;
    TEMP1bm = $02;
    TEMP2bm = $04;
    TEMP3bm = $08;
    TEMP4bm = $10;
    TEMP5bm = $20;
    TEMP6bm = $40;
    TEMP7bm = $80;
  end;

  TBOD = object //Bod interface
    CTRLA: byte;  //Control A
    CTRLB: byte;  //Control B
    Reserved2: byte;
    Reserved3: byte;
    Reserved4: byte;
    Reserved5: byte;
    Reserved6: byte;
    Reserved7: byte;
    VLMCTRLA: byte;  //Voltage level monitor Control
    INTCTRL: byte;  //Voltage level monitor interrupt Control
    INTFLAGS: byte;  //Voltage level monitor interrupt Flags
    STATUS: byte;  //Voltage level monitor status
  const
    // BOD_ACTIVE
    ACTIVEmask = $0C;
    ACTIVE_DIS = $00;
    ACTIVE_ENABLED = $04;
    ACTIVE_SAMPLED = $08;
    ACTIVE_ENWAKE = $0C;
    // BOD_SAMPFREQ
    SAMPFREQmask = $10;
    SAMPFREQ_1KHZ = $00;
    SAMPFREQ_125HZ = $10;
    // BOD_SLEEP
    SLEEPmask = $03;
    SLEEP_DIS = $00;
    SLEEP_ENABLED = $01;
    SLEEP_SAMPLED = $02;
    // BOD_LVL
    LVLmask = $07;
    LVL_BODLEVEL0 = $00;
    LVL_BODLEVEL2 = $02;
    LVL_BODLEVEL7 = $07;
    // BOD_VLMCFG
    VLMCFGmask = $06;
    VLMCFG_BELOW = $00;
    VLMCFG_ABOVE = $02;
    VLMCFG_CROSS = $04;
    // voltage level monitor interrrupt enable
    VLMIEbm = $01;
    // Voltage level monitor interrupt flag
    VLMIFbm = $01;
    // Voltage level monitor status
    VLMSbm = $01;
    // BOD_VLMLVL
    VLMLVLmask = $03;
    VLMLVL_5ABOVE = $00;
    VLMLVL_15ABOVE = $01;
    VLMLVL_25ABOVE = $02;
  end;

  TCCL = object //Configurable Custom Logic
    CTRLA: byte;  //Control Register A
    SEQCTRL0: byte;  //Sequential Control 0
    SEQCTRL1: byte;  //Sequential Control 1
    Reserved3: byte;
    Reserved4: byte;
    INTCTRL0: byte;  //Interrupt Control 0
    Reserved6: byte;
    INTFLAGS: byte;  //Interrupt Flags
    LUT0CTRLA: byte;  //LUT Control 0 A
    LUT0CTRLB: byte;  //LUT Control 0 B
    LUT0CTRLC: byte;  //LUT Control 0 C
    TRUTH0: byte;  //Truth 0
    LUT1CTRLA: byte;  //LUT Control 1 A
    LUT1CTRLB: byte;  //LUT Control 1 B
    LUT1CTRLC: byte;  //LUT Control 1 C
    TRUTH1: byte;  //Truth 1
    LUT2CTRLA: byte;  //LUT Control 2 A
    LUT2CTRLB: byte;  //LUT Control 2 B
    LUT2CTRLC: byte;  //LUT Control 2 C
    TRUTH2: byte;  //Truth 2
    LUT3CTRLA: byte;  //LUT Control 3 A
    LUT3CTRLB: byte;  //LUT Control 3 B
    LUT3CTRLC: byte;  //LUT Control 3 C
    TRUTH3: byte;  //Truth 3
  const
    // Enable
    ENABLEbm = $01;
    // Run in Standby
    RUNSTDBYbm = $40;
    // CCL_INTMODE0
    INTMODE0mask = $03;
    INTMODE0_INTDISABLE = $00;
    INTMODE0_RISING = $01;
    INTMODE0_FALLING = $02;
    INTMODE0_BOTH = $03;
    // CCL_INTMODE1
    INTMODE1mask = $0C;
    INTMODE1_INTDISABLE = $00;
    INTMODE1_RISING = $04;
    INTMODE1_FALLING = $08;
    INTMODE1_BOTH = $0C;
    // CCL_INTMODE2
    INTMODE2mask = $30;
    INTMODE2_INTDISABLE = $00;
    INTMODE2_RISING = $10;
    INTMODE2_FALLING = $20;
    INTMODE2_BOTH = $30;
    // CCL_INTMODE3
    INTMODE3mask = $C0;
    INTMODE3_INTDISABLE = $00;
    INTMODE3_RISING = $40;
    INTMODE3_FALLING = $80;
    INTMODE3_BOTH = $C0;
    // Interrupt Flags
    INT0bm = $01;
    INT1bm = $02;
    INT2bm = $04;
    INT3bm = $08;
    // CCL_CLKSRC
    CLKSRCmask = $0E;
    CLKSRC_CLKPER = $00;
    CLKSRC_IN2 = $02;
    CLKSRC_OSC20M = $08;
    CLKSRC_OSCULP32K = $0A;
    CLKSRC_OSCULP1K = $0C;
    // CCL_EDGEDET
    EDGEDETmask = $80;
    EDGEDET_DIS = $00;
    EDGEDET_EN = $80;
    // CCL_FILTSEL
    FILTSELmask = $30;
    FILTSEL_DISABLE = $00;
    FILTSEL_SYNCH = $10;
    FILTSEL_FILTER = $20;
    // Output Enable
    OUTENbm = $40;
    // CCL_INSEL0
    INSEL0mask = $0F;
    INSEL0_MASK = $00;
    INSEL0_FEEDBACK = $01;
    INSEL0_LINK = $02;
    INSEL0_EVENTA = $03;
    INSEL0_EVENTB = $04;
    INSEL0_IO = $05;
    INSEL0_AC0 = $06;
    INSEL0_USART0 = $08;
    INSEL0_SPI0 = $09;
    INSEL0_TCA0 = $0A;
    INSEL0_TCB0 = $0C;
    // CCL_INSEL1
    INSEL1mask = $F0;
    INSEL1_MASK = $00;
    INSEL1_FEEDBACK = $10;
    INSEL1_LINK = $20;
    INSEL1_EVENTA = $30;
    INSEL1_EVENTB = $40;
    INSEL1_IO = $50;
    INSEL1_AC0 = $60;
    INSEL1_USART1 = $80;
    INSEL1_SPI0 = $90;
    INSEL1_TCA0 = $A0;
    INSEL1_TCB1 = $C0;
    // CCL_INSEL2
    INSEL2mask = $0F;
    INSEL2_MASK = $00;
    INSEL2_FEEDBACK = $01;
    INSEL2_LINK = $02;
    INSEL2_EVENTA = $03;
    INSEL2_EVENTB = $04;
    INSEL2_IO = $05;
    INSEL2_AC0 = $06;
    INSEL2_SPI0 = $09;
    INSEL2_TCA0 = $0A;
    // CCL_SEQSEL0
    SEQSEL0mask = $07;
    SEQSEL0_DISABLE = $00;
    SEQSEL0_DFF = $01;
    SEQSEL0_JK = $02;
    SEQSEL0_LATCH = $03;
    SEQSEL0_RS = $04;
    // CCL_SEQSEL1
    SEQSEL1mask = $07;
    SEQSEL1_DISABLE = $00;
    SEQSEL1_DFF = $01;
    SEQSEL1_JK = $02;
    SEQSEL1_LATCH = $03;
    SEQSEL1_RS = $04;
  end;

  TCLKCTRL = object //Clock controller
    MCLKCTRLA: byte;  //MCLK Control A
    MCLKCTRLB: byte;  //MCLK Control B
    MCLKLOCK: byte;  //MCLK Lock
    MCLKSTATUS: byte;  //MCLK Status
    Reserved4: byte;
    Reserved5: byte;
    Reserved6: byte;
    Reserved7: byte;
    Reserved8: byte;
    Reserved9: byte;
    Reserved10: byte;
    Reserved11: byte;
    Reserved12: byte;
    Reserved13: byte;
    Reserved14: byte;
    Reserved15: byte;
    OSC20MCTRLA: byte;  //OSC20M Control A
    OSC20MCALIBA: byte;  //OSC20M Calibration A
    OSC20MCALIBB: byte;  //OSC20M Calibration B
    Reserved19: byte;
    Reserved20: byte;
    Reserved21: byte;
    Reserved22: byte;
    Reserved23: byte;
    OSC32KCTRLA: byte;  //OSC32K Control A
    Reserved25: byte;
    Reserved26: byte;
    Reserved27: byte;
    XOSC32KCTRLA: byte;  //XOSC32K Control A
  const
    // System clock out
    CLKOUTbm = $80;
    // CLKCTRL_CLKSEL
    CLKSELmask = $03;
    CLKSEL_OSC20M = $00;
    CLKSEL_OSCULP32K = $01;
    CLKSEL_XOSC32K = $02;
    CLKSEL_EXTCLK = $03;
    // CLKCTRL_PDIV
    PDIVmask = $1E;
    PDIV_2X = $00;
    PDIV_4X = $02;
    PDIV_8X = $04;
    PDIV_16X = $06;
    PDIV_32X = $08;
    PDIV_64X = $0A;
    PDIV_6X = $10;
    PDIV_10X = $12;
    PDIV_12X = $14;
    PDIV_24X = $16;
    PDIV_48X = $18;
    // Prescaler enable
    PENbm = $01;
    // lock ebable
    LOCKENbm = $01;
    // External Clock status
    EXTSbm = $80;
    // 20MHz oscillator status
    OSC20MSbm = $10;
    // 32KHz oscillator status
    OSC32KSbm = $20;
    // System Oscillator changing
    SOSCbm = $01;
    // 32.768 kHz Crystal Oscillator status
    XOSC32KSbm = $40;
    // Calibration
    CAL20M0bm = $01;
    CAL20M1bm = $02;
    CAL20M2bm = $04;
    CAL20M3bm = $08;
    CAL20M4bm = $10;
    CAL20M5bm = $20;
    CAL20M6bm = $40;
    // Lock
    LOCKbm = $80;
    // Oscillator temperature coefficient
    TEMPCAL20M0bm = $01;
    TEMPCAL20M1bm = $02;
    TEMPCAL20M2bm = $04;
    TEMPCAL20M3bm = $08;
    // Run standby
    RUNSTDBYbm = $02;
    // CLKCTRL_CSUT
    CSUTmask = $30;
    CSUT_1K = $00;
    CSUT_16K = $10;
    CSUT_32K = $20;
    CSUT_64K = $30;
    // Enable
    ENABLEbm = $01;
    // Select
    SELbm = $04;
  end;

  TCPU = object //CPU
    Reserved0: byte;
    Reserved1: byte;
    Reserved2: byte;
    Reserved3: byte;
    CCP: byte;  //Configuration Change Protection
    Reserved5: byte;
    Reserved6: byte;
    Reserved7: byte;
    Reserved8: byte;
    Reserved9: byte;
    Reserved10: byte;
    RAMPZ: byte;  //Extended Z-pointer Register
    Reserved12: byte;
    SPL: byte;  //Stack Pointer Low
    SPH: byte;  //Stack Pointer High
    SREG: byte;  //Status Register
  const
    // CPU_CCP
    CCPmask = $FF;
    CCP_SPM = $9D;
    CCP_IOREG = $D8;
    // Carry Flag
    Cbm = $01;
    // Half Carry Flag
    Hbm = $20;
    // Global Interrupt Enable Flag
    Ibm = $80;
    // Negative Flag
    Nbm = $04;
    // N Exclusive Or V Flag
    Sbm = $10;
    // Transfer Bit
    Tbm = $40;
    // Two's Complement Overflow Flag
    Vbm = $08;
    // Zero Flag
    Zbm = $02;
  end;

  TCPUINT = object //Interrupt Controller
    CTRLA: byte;  //Control A
    STATUS: byte;  //Status
    LVL0PRI: byte;  //Interrupt Level 0 Priority
    LVL1VEC: byte;  //Interrupt Level 1 Priority Vector
  const
    // Compact Vector Table
    CVTbm = $20;
    // Interrupt Vector Select
    IVSELbm = $40;
    // Round-robin Scheduling Enable
    LVL0RRbm = $01;
    // Interrupt Level Priority
    LVL0PRI0bm = $01;
    LVL0PRI1bm = $02;
    LVL0PRI2bm = $04;
    LVL0PRI3bm = $08;
    LVL0PRI4bm = $10;
    LVL0PRI5bm = $20;
    LVL0PRI6bm = $40;
    LVL0PRI7bm = $80;
    // Interrupt Vector with High Priority
    LVL1VEC0bm = $01;
    LVL1VEC1bm = $02;
    LVL1VEC2bm = $04;
    LVL1VEC3bm = $08;
    LVL1VEC4bm = $10;
    LVL1VEC5bm = $20;
    LVL1VEC6bm = $40;
    LVL1VEC7bm = $80;
    // Level 0 Interrupt Executing
    LVL0EXbm = $01;
    // Level 1 Interrupt Executing
    LVL1EXbm = $02;
    // Non-maskable Interrupt Executing
    NMIEXbm = $80;
  end;

  TCRCSCAN = object //CRCSCAN
    CTRLA: byte;  //Control A
    CTRLB: byte;  //Control B
    STATUS: byte;  //Status
  const
    // Enable CRC scan
    ENABLEbm = $01;
    // Enable NMI Trigger
    NMIENbm = $02;
    // Reset CRC scan
    RESETbm = $80;
    // CRCSCAN_SRC
    SRCmask = $03;
    SRC_FLASH = $00;
    SRC_APPLICATION = $01;
    SRC_BOOT = $02;
    // CRC Busy
    BUSYbm = $01;
    // CRC Ok
    OKbm = $02;
  end;

  TEVSYS = object //Event System
    SWEVENTA: byte;  //Software Event A
    Reserved1: byte;
    Reserved2: byte;
    Reserved3: byte;
    Reserved4: byte;
    Reserved5: byte;
    Reserved6: byte;
    Reserved7: byte;
    Reserved8: byte;
    Reserved9: byte;
    Reserved10: byte;
    Reserved11: byte;
    Reserved12: byte;
    Reserved13: byte;
    Reserved14: byte;
    Reserved15: byte;
    CHANNEL0: byte;  //Multiplexer Channel 0
    CHANNEL1: byte;  //Multiplexer Channel 1
    CHANNEL2: byte;  //Multiplexer Channel 2
    CHANNEL3: byte;  //Multiplexer Channel 3
    CHANNEL4: byte;  //Multiplexer Channel 4
    CHANNEL5: byte;  //Multiplexer Channel 5
    Reserved22: byte;
    Reserved23: byte;
    Reserved24: byte;
    Reserved25: byte;
    Reserved26: byte;
    Reserved27: byte;
    Reserved28: byte;
    Reserved29: byte;
    Reserved30: byte;
    Reserved31: byte;
    USERCCLLUT0A: byte;  //User CCL LUT0 Event A
    USERCCLLUT0B: byte;  //User CCL LUT0 Event B
    USERCCLLUT1A: byte;  //User CCL LUT1 Event A
    USERCCLLUT1B: byte;  //User CCL LUT1 Event B
    USERCCLLUT2A: byte;  //User CCL LUT2 Event A
    USERCCLLUT2B: byte;  //User CCL LUT2 Event B
    USERCCLLUT3A: byte;  //User CCL LUT3 Event A
    USERCCLLUT3B: byte;  //User CCL LUT3 Event B
    USERADC0START: byte;  //User ADC0
    USEREVSYSEVOUTA: byte;  //User EVOUT Port A
    USEREVSYSEVOUTB: byte;  //User EVOUT Port B
    USEREVSYSEVOUTC: byte;  //User EVOUT Port C
    USERUSART0IRDA: byte;  //User USART0
    USERUSART1IRDA: byte;  //User USART1
    USERTCA0CNTA: byte;  //User TCA0 count event
    USERTCA0CNTB: byte;  //User TCA0 Restart event
    USERTCB0CAPT: byte;  //User TCB0 Event in A
    USERTCB0COUNT: byte;  //User TCB0 Event in B
    USERTCB1CAPT: byte;  //User TCB1 Event in A
    USERTCB1COUNT: byte;  //User TCB1 Event in B
  const
    // EVSYS_CHANNEL0
    CHANNEL0mask = $FF;
    CHANNEL0_OFF = $00;
    CHANNEL0_UPDI = $01;
    CHANNEL0_RTC_OVF = $06;
    CHANNEL0_RTC_CMP = $07;
    CHANNEL0_RTC_PIT_DIV8192 = $08;
    CHANNEL0_RTC_PIT_DIV4096 = $09;
    CHANNEL0_RTC_PIT_DIV2048 = $0A;
    CHANNEL0_RTC_PIT_DIV1024 = $0B;
    CHANNEL0_CCL_LUT0 = $10;
    CHANNEL0_CCL_LUT1 = $11;
    CHANNEL0_CCL_LUT2 = $12;
    CHANNEL0_CCL_LUT3 = $13;
    CHANNEL0_AC0_OUT = $20;
    CHANNEL0_ADC0_RES = $24;
    CHANNEL0_ADC0_SAMP = $25;
    CHANNEL0_ADC0_WCMP = $26;
    CHANNEL0_PORTA_PIN0 = $40;
    CHANNEL0_PORTA_PIN1 = $41;
    CHANNEL0_PORTA_PIN2 = $42;
    CHANNEL0_PORTA_PIN3 = $43;
    CHANNEL0_PORTA_PIN4 = $44;
    CHANNEL0_PORTA_PIN5 = $45;
    CHANNEL0_PORTA_PIN6 = $46;
    CHANNEL0_PORTA_PIN7 = $47;
    CHANNEL0_PORTB_PIN0 = $48;
    CHANNEL0_PORTB_PIN1 = $49;
    CHANNEL0_PORTB_PIN2 = $4A;
    CHANNEL0_PORTB_PIN3 = $4B;
    CHANNEL0_PORTB_PIN4 = $4C;
    CHANNEL0_PORTB_PIN5 = $4D;
    CHANNEL0_PORTB_PIN6 = $4E;
    CHANNEL0_PORTB_PIN7 = $4F;
    CHANNEL0_USART0_XCK = $60;
    CHANNEL0_USART1_XCK = $61;
    CHANNEL0_SPI0_SCK = $68;
    CHANNEL0_TCA0_OVF_LUNF = $80;
    CHANNEL0_TCA0_HUNF = $81;
    CHANNEL0_TCA0_CMP0_LCMP0 = $84;
    CHANNEL0_TCA0_CMP1_LCMP1 = $85;
    CHANNEL0_TCA0_CMP2_LCMP2 = $86;
    CHANNEL0_TCB0_CAPT = $A0;
    CHANNEL0_TCB0_OVF = $A1;
    CHANNEL0_TCB1_CAPT = $A2;
    CHANNEL0_TCB1_OVF = $A3;
    // EVSYS_CHANNEL1
    CHANNEL1mask = $FF;
    CHANNEL1_OFF = $00;
    CHANNEL1_UPDI = $01;
    CHANNEL1_RTC_OVF = $06;
    CHANNEL1_RTC_CMP = $07;
    CHANNEL1_RTC_PIT_DIV512 = $08;
    CHANNEL1_RTC_PIT_DIV256 = $09;
    CHANNEL1_RTC_PIT_DIV128 = $0A;
    CHANNEL1_RTC_PIT_DIV64 = $0B;
    CHANNEL1_CCL_LUT0 = $10;
    CHANNEL1_CCL_LUT1 = $11;
    CHANNEL1_CCL_LUT2 = $12;
    CHANNEL1_CCL_LUT3 = $13;
    CHANNEL1_AC0_OUT = $20;
    CHANNEL1_ADC0_RES = $24;
    CHANNEL1_ADC0_SAMP = $25;
    CHANNEL1_ADC0_WCMP = $26;
    CHANNEL1_PORTA_PIN0 = $40;
    CHANNEL1_PORTA_PIN1 = $41;
    CHANNEL1_PORTA_PIN2 = $42;
    CHANNEL1_PORTA_PIN3 = $43;
    CHANNEL1_PORTA_PIN4 = $44;
    CHANNEL1_PORTA_PIN5 = $45;
    CHANNEL1_PORTA_PIN6 = $46;
    CHANNEL1_PORTA_PIN7 = $47;
    CHANNEL1_PORTB_PIN0 = $48;
    CHANNEL1_PORTB_PIN1 = $49;
    CHANNEL1_PORTB_PIN2 = $4A;
    CHANNEL1_PORTB_PIN3 = $4B;
    CHANNEL1_PORTB_PIN4 = $4C;
    CHANNEL1_PORTB_PIN5 = $4D;
    CHANNEL1_PORTB_PIN6 = $4E;
    CHANNEL1_PORTB_PIN7 = $4F;
    CHANNEL1_USART0_XCK = $60;
    CHANNEL1_USART1_XCK = $61;
    CHANNEL1_SPI0_SCK = $68;
    CHANNEL1_TCA0_OVF_LUNF = $80;
    CHANNEL1_TCA0_HUNF = $81;
    CHANNEL1_TCA0_CMP0_LCMP0 = $84;
    CHANNEL1_TCA0_CMP1_LCMP1 = $85;
    CHANNEL1_TCA0_CMP2_LCMP2 = $86;
    CHANNEL1_TCB0_CAPT = $A0;
    CHANNEL1_TCB0_OVF = $A1;
    CHANNEL1_TCB1_CAPT = $A2;
    CHANNEL1_TCB1_OVF = $A3;
    // EVSYS_CHANNEL2
    CHANNEL2mask = $FF;
    CHANNEL2_OFF = $00;
    CHANNEL2_UPDI = $01;
    CHANNEL2_RTC_OVF = $06;
    CHANNEL2_RTC_CMP = $07;
    CHANNEL2_RTC_PIT_DIV8192 = $08;
    CHANNEL2_RTC_PIT_DIV4096 = $09;
    CHANNEL2_RTC_PIT_DIV2048 = $0A;
    CHANNEL2_RTC_PIT_DIV1024 = $0B;
    CHANNEL2_CCL_LUT0 = $10;
    CHANNEL2_CCL_LUT1 = $11;
    CHANNEL2_CCL_LUT2 = $12;
    CHANNEL2_CCL_LUT3 = $13;
    CHANNEL2_AC0_OUT = $20;
    CHANNEL2_ADC0_RES = $24;
    CHANNEL2_ADC0_SAMP = $25;
    CHANNEL2_ADC0_WCMP = $26;
    CHANNEL2_PORTC_PIN0 = $40;
    CHANNEL2_PORTC_PIN1 = $41;
    CHANNEL2_PORTC_PIN2 = $42;
    CHANNEL2_PORTC_PIN3 = $43;
    CHANNEL2_PORTC_PIN4 = $44;
    CHANNEL2_PORTC_PIN5 = $45;
    CHANNEL2_PORTC_PIN6 = $46;
    CHANNEL2_PORTC_PIN7 = $47;
    CHANNEL2_PORTA_PIN0 = $48;
    CHANNEL2_PORTA_PIN1 = $49;
    CHANNEL2_PORTA_PIN2 = $4A;
    CHANNEL2_PORTA_PIN3 = $4B;
    CHANNEL2_PORTA_PIN4 = $4C;
    CHANNEL2_PORTA_PIN5 = $4D;
    CHANNEL2_PORTA_PIN6 = $4E;
    CHANNEL2_PORTA_PIN7 = $4F;
    CHANNEL2_USART0_XCK = $60;
    CHANNEL2_USART1_XCK = $61;
    CHANNEL2_SPI0_SCK = $68;
    CHANNEL2_TCA0_OVF_LUNF = $80;
    CHANNEL2_TCA0_HUNF = $81;
    CHANNEL2_TCA0_CMP0_LCMP0 = $84;
    CHANNEL2_TCA0_CMP1_LCMP1 = $85;
    CHANNEL2_TCA0_CMP2_LCMP2 = $86;
    CHANNEL2_TCB0_CAPT = $A0;
    CHANNEL2_TCB0_OVF = $A1;
    CHANNEL2_TCB1_CAPT = $A2;
    CHANNEL2_TCB1_OVF = $A3;
    // EVSYS_CHANNEL3
    CHANNEL3mask = $FF;
    CHANNEL3_OFF = $00;
    CHANNEL3_UPDI = $01;
    CHANNEL3_RTC_OVF = $06;
    CHANNEL3_RTC_CMP = $07;
    CHANNEL3_RTC_PIT_DIV512 = $08;
    CHANNEL3_RTC_PIT_DIV256 = $09;
    CHANNEL3_RTC_PIT_DIV128 = $0A;
    CHANNEL3_RTC_PIT_DIV64 = $0B;
    CHANNEL3_CCL_LUT0 = $10;
    CHANNEL3_CCL_LUT1 = $11;
    CHANNEL3_CCL_LUT2 = $12;
    CHANNEL3_CCL_LUT3 = $13;
    CHANNEL3_AC0_OUT = $20;
    CHANNEL3_ADC0_RES = $24;
    CHANNEL3_ADC0_SAMP = $25;
    CHANNEL3_ADC0_WCMP = $26;
    CHANNEL3_PORTC_PIN0 = $40;
    CHANNEL3_PORTC_PIN1 = $41;
    CHANNEL3_PORTC_PIN2 = $42;
    CHANNEL3_PORTC_PIN3 = $43;
    CHANNEL3_PORTC_PIN4 = $44;
    CHANNEL3_PORTC_PIN5 = $45;
    CHANNEL3_PORTC_PIN6 = $46;
    CHANNEL3_PORTC_PIN7 = $47;
    CHANNEL3_PORTA_PIN0 = $48;
    CHANNEL3_PORTA_PIN1 = $49;
    CHANNEL3_PORTA_PIN2 = $4A;
    CHANNEL3_PORTA_PIN3 = $4B;
    CHANNEL3_PORTA_PIN4 = $4C;
    CHANNEL3_PORTA_PIN5 = $4D;
    CHANNEL3_PORTA_PIN6 = $4E;
    CHANNEL3_PORTA_PIN7 = $4F;
    CHANNEL3_USART0_XCK = $60;
    CHANNEL3_USART1_XCK = $61;
    CHANNEL3_SPI0_SCK = $68;
    CHANNEL3_TCA0_OVF_LUNF = $80;
    CHANNEL3_TCA0_HUNF = $81;
    CHANNEL3_TCA0_CMP0_LCMP0 = $84;
    CHANNEL3_TCA0_CMP1_LCMP1 = $85;
    CHANNEL3_TCA0_CMP2_LCMP2 = $86;
    CHANNEL3_TCB0_CAPT = $A0;
    CHANNEL3_TCB0_OVF = $A1;
    CHANNEL3_TCB1_CAPT = $A2;
    CHANNEL3_TCB1_OVF = $A3;
    // EVSYS_CHANNEL4
    CHANNEL4mask = $FF;
    CHANNEL4_OFF = $00;
    CHANNEL4_UPDI = $01;
    CHANNEL4_RTC_OVF = $06;
    CHANNEL4_RTC_CMP = $07;
    CHANNEL4_RTC_PIT_DIV8192 = $08;
    CHANNEL4_RTC_PIT_DIV4096 = $09;
    CHANNEL4_RTC_PIT_DIV2048 = $0A;
    CHANNEL4_RTC_PIT_DIV1024 = $0B;
    CHANNEL4_CCL_LUT0 = $10;
    CHANNEL4_CCL_LUT1 = $11;
    CHANNEL4_CCL_LUT2 = $12;
    CHANNEL4_CCL_LUT3 = $13;
    CHANNEL4_AC0_OUT = $20;
    CHANNEL4_ADC0_RES = $24;
    CHANNEL4_ADC0_SAMP = $25;
    CHANNEL4_ADC0_WCMP = $26;
    CHANNEL4_PORTB_PIN0 = $40;
    CHANNEL4_PORTB_PIN1 = $41;
    CHANNEL4_PORTB_PIN2 = $42;
    CHANNEL4_PORTB_PIN3 = $43;
    CHANNEL4_PORTB_PIN4 = $44;
    CHANNEL4_PORTB_PIN5 = $45;
    CHANNEL4_PORTB_PIN6 = $46;
    CHANNEL4_PORTB_PIN7 = $47;
    CHANNEL4_PORTC_PIN0 = $48;
    CHANNEL4_PORTC_PIN1 = $49;
    CHANNEL4_PORTC_PIN2 = $4A;
    CHANNEL4_PORTC_PIN3 = $4B;
    CHANNEL4_PORTC_PIN4 = $4C;
    CHANNEL4_PORTC_PIN5 = $4D;
    CHANNEL4_PORTC_PIN6 = $4E;
    CHANNEL4_PORTC_PIN7 = $4F;
    CHANNEL4_USART0_XCK = $60;
    CHANNEL4_USART1_XCK = $61;
    CHANNEL4_SPI0_SCK = $68;
    CHANNEL4_TCA0_OVF_LUNF = $80;
    CHANNEL4_TCA0_HUNF = $81;
    CHANNEL4_TCA0_CMP0_LCMP0 = $84;
    CHANNEL4_TCA0_CMP1_LCMP1 = $85;
    CHANNEL4_TCA0_CMP2_LCMP2 = $86;
    CHANNEL4_TCB0_CAPT = $A0;
    CHANNEL4_TCB0_OVF = $A1;
    CHANNEL4_TCB1_CAPT = $A2;
    CHANNEL4_TCB1_OVF = $A3;
    // EVSYS_CHANNEL5
    CHANNEL5mask = $FF;
    CHANNEL5_OFF = $00;
    CHANNEL5_UPDI = $01;
    CHANNEL5_RTC_OVF = $06;
    CHANNEL5_RTC_CMP = $07;
    CHANNEL5_RTC_PIT_DIV512 = $08;
    CHANNEL5_RTC_PIT_DIV256 = $09;
    CHANNEL5_RTC_PIT_DIV128 = $0A;
    CHANNEL5_RTC_PIT_DIV64 = $0B;
    CHANNEL5_CCL_LUT0 = $10;
    CHANNEL5_CCL_LUT1 = $11;
    CHANNEL5_CCL_LUT2 = $12;
    CHANNEL5_CCL_LUT3 = $13;
    CHANNEL5_AC0_OUT = $20;
    CHANNEL5_ADC0_RES = $24;
    CHANNEL5_ADC0_SAMP = $25;
    CHANNEL5_ADC0_WCMP = $26;
    CHANNEL5_PORTB_PIN0 = $40;
    CHANNEL5_PORTB_PIN1 = $41;
    CHANNEL5_PORTB_PIN2 = $42;
    CHANNEL5_PORTB_PIN3 = $43;
    CHANNEL5_PORTB_PIN4 = $44;
    CHANNEL5_PORTB_PIN5 = $45;
    CHANNEL5_PORTB_PIN6 = $46;
    CHANNEL5_PORTB_PIN7 = $47;
    CHANNEL5_PORTC_PIN0 = $48;
    CHANNEL5_PORTC_PIN1 = $49;
    CHANNEL5_PORTC_PIN2 = $4A;
    CHANNEL5_PORTC_PIN3 = $4B;
    CHANNEL5_PORTC_PIN4 = $4C;
    CHANNEL5_PORTC_PIN5 = $4D;
    CHANNEL5_PORTC_PIN6 = $4E;
    CHANNEL5_PORTC_PIN7 = $4F;
    CHANNEL5_USART0_XCK = $60;
    CHANNEL5_USART1_XCK = $61;
    CHANNEL5_SPI0_SCK = $68;
    CHANNEL5_TCA0_OVF_LUNF = $80;
    CHANNEL5_TCA0_HUNF = $81;
    CHANNEL5_TCA0_CMP0_LCMP0 = $84;
    CHANNEL5_TCA0_CMP1_LCMP1 = $85;
    CHANNEL5_TCA0_CMP2_LCMP2 = $86;
    CHANNEL5_TCB0_CAPT = $A0;
    CHANNEL5_TCB0_OVF = $A1;
    CHANNEL5_TCB1_CAPT = $A2;
    CHANNEL5_TCB1_OVF = $A3;
    // EVSYS_SWEVENTA
    SWEVENTAmask = $FF;
    SWEVENTA_CH0 = $01;
    SWEVENTA_CH1 = $02;
    SWEVENTA_CH2 = $04;
    SWEVENTA_CH3 = $08;
    SWEVENTA_CH4 = $10;
    SWEVENTA_CH5 = $20;
    // EVSYS_USER
    USERmask = $FF;
    USER_OFF = $00;
    USER_CHANNEL0 = $01;
    USER_CHANNEL1 = $02;
    USER_CHANNEL2 = $03;
    USER_CHANNEL3 = $04;
    USER_CHANNEL4 = $05;
    USER_CHANNEL5 = $06;
  end;

  TFUSE = object //Fuses
    WDTCFG: byte;  //Watchdog Configuration
    BODCFG: byte;  //BOD Configuration
    OSCCFG: byte;  //Oscillator Configuration
    Reserved3: byte;
    Reserved4: byte;
    SYSCFG0: byte;  //System Configuration 0
    SYSCFG1: byte;  //System Configuration 1
    APPEND: byte;  //Application Code Section End
    BOOTEND: byte;  //Boot Section End
  const
    // FUSE_ACTIVE
    ACTIVEmask = $0C;
    ACTIVE_DIS = $00;
    ACTIVE_ENABLED = $04;
    ACTIVE_SAMPLED = $08;
    ACTIVE_ENWAKE = $0C;
    // FUSE_LVL
    LVLmask = $E0;
    LVL_BODLEVEL0 = $00;
    LVL_BODLEVEL2 = $40;
    LVL_BODLEVEL7 = $E0;
    // FUSE_SAMPFREQ
    SAMPFREQmask = $10;
    SAMPFREQ_1KHZ = $00;
    SAMPFREQ_125HZ = $10;
    // FUSE_SLEEP
    SLEEPmask = $03;
    SLEEP_DIS = $00;
    SLEEP_ENABLED = $01;
    SLEEP_SAMPLED = $02;
    // FUSE_FREQSEL
    FREQSELmask = $03;
    FREQSEL_16MHZ = $01;
    FREQSEL_20MHZ = $02;
    // Oscillator Lock
    OSCLOCKbm = $80;
    // FUSE_CRCSRC
    CRCSRCmask = $C0;
    CRCSRC_FLASH = $00;
    CRCSRC_BOOT = $40;
    CRCSRC_BOOTAPP = $80;
    CRCSRC_NOCRC = $C0;
    // EEPROM Save
    EESAVEbm = $01;
    // FUSE_RSTPINCFG
    RSTPINCFGmask = $0C;
    RSTPINCFG_GPIO = $00;
    RSTPINCFG_UPDI = $04;
    RSTPINCFG_RST = $08;
    RSTPINCFG_PDIRST = $0C;
    // FUSE_SUT
    SUTmask = $07;
    SUT_0MS = $00;
    SUT_1MS = $01;
    SUT_2MS = $02;
    SUT_4MS = $03;
    SUT_8MS = $04;
    SUT_16MS = $05;
    SUT_32MS = $06;
    SUT_64MS = $07;
    // FUSE_PERIOD
    PERIODmask = $0F;
    PERIOD_OFF = $00;
    PERIOD_8CLK = $01;
    PERIOD_16CLK = $02;
    PERIOD_32CLK = $03;
    PERIOD_64CLK = $04;
    PERIOD_128CLK = $05;
    PERIOD_256CLK = $06;
    PERIOD_512CLK = $07;
    PERIOD_1KCLK = $08;
    PERIOD_2KCLK = $09;
    PERIOD_4KCLK = $0A;
    PERIOD_8KCLK = $0B;
    // FUSE_WINDOW
    WINDOWmask = $F0;
    WINDOW_OFF = $00;
    WINDOW_8CLK = $10;
    WINDOW_16CLK = $20;
    WINDOW_32CLK = $30;
    WINDOW_64CLK = $40;
    WINDOW_128CLK = $50;
    WINDOW_256CLK = $60;
    WINDOW_512CLK = $70;
    WINDOW_1KCLK = $80;
    WINDOW_2KCLK = $90;
    WINDOW_4KCLK = $A0;
    WINDOW_8KCLK = $B0;
  end;

  TGPIO = object //General Purpose IO
    GPIOR0: byte;  //General Purpose IO Register 0
    GPIOR1: byte;  //General Purpose IO Register 1
    GPIOR2: byte;  //General Purpose IO Register 2
    GPIOR3: byte;  //General Purpose IO Register 3
  end;

  TLOCKBIT = object //Lockbit
    LOCKBIT: byte;  //Lock Bits
  const
    // LOCKBIT_LB
    LBmask = $FF;
    LB_RWLOCK = $3A;
    LB_NOLOCK = $C5;
  end;

  TNVMBIST = object //BIST in the NVMCTRL module
    CTRLA: byte;  //Control A
    ADDRPAT: byte;  //Address pattern
    DATAPAT: byte;  //Data pattern
    STATUS: byte;  //Status
    CNT: word;
    END_: dword;
  const
    // NVMBIST_AMODE
    AMODEmask = $70;
    AMODE_NORMAL = $00;
    AMODE_COMPLEMENT = $40;
    // NVMBIST_XMODE
    XMODEmask = $03;
    XMODE_STATIC = $00;
    XMODE_CARRY = $01;
    XMODE_INC = $02;
    XMODE_DEC = $03;
    // NVMBIST_YMODE
    YMODEmask = $0C;
    YMODE_STATIC = $00;
    YMODE_CARRY = $04;
    YMODE_INC = $08;
    YMODE_DEC = $0C;
    // Faults counter
    CNT0bm = $01;
    CNT1bm = $02;
    CNT2bm = $04;
    CNT3bm = $08;
    CNT4bm = $10;
    CNT5bm = $20;
    CNT6bm = $40;
    CNT7bm = $80;
    // NVMBIST_CMD
    CMDmask = $07;
    CMD_NOCMD = $00;
    CMD_START = $01;
    CMD_RESTART = $02;
    CMD_BREAK = $03;
    // Stop at fault
    SAFbm = $08;
    // NVMBIST_PATTERN
    PATTERNmask = $03;
    PATTERN_ZEROES = $00;
    PATTERN_CHECK = $01;
    PATTERN_INVCHECK = $02;
    PATTERN_ONES = $03;
    // 
    END0bm = $01;
    END1bm = $02;
    END2bm = $04;
    END3bm = $08;
    END4bm = $10;
    END5bm = $20;
    END6bm = $40;
    END7bm = $80;
    // NVMBIST_STATE
    STATEmask = $0F;
    STATE_IDLE = $00;
    STATE_BREAK = $01;
    STATE_FAILED0 = $04;
    STATE_FAILED1 = $05;
    STATE_FAILED2 = $06;
    STATE_SUCCESS = $07;
    STATE_START0 = $08;
    STATE_START1 = $09;
    STATE_RESTART0 = $0A;
    STATE_RESTART1 = $0B;
    STATE_RUNNING = $0C;
    STATE_FINISH0 = $0E;
    STATE_FINISH1 = $0F;
  end;

  TNVMCTRL = object //Non-volatile Memory Controller
    CTRLA: byte;  //Control A
    CTRLB: byte;  //Control B
    STATUS: byte;  //Status
    INTCTRL: byte;  //Interrupt Control
    INTFLAGS: byte;  //Interrupt Flags
    Reserved5: byte;
    DATA: word;  //Data
    ADDR: word;  //Address
  const
    // NVMCTRL_CMD
    CMDmask = $07;
    CMD_NONE = $00;
    CMD_PAGEWRITE = $01;
    CMD_PAGEERASE = $02;
    CMD_PAGEERASEWRITE = $03;
    CMD_PAGEBUFCLR = $04;
    CMD_CHIPERASE = $05;
    CMD_EEERASE = $06;
    CMD_FUSEWRITE = $07;
    // Application code write protect
    APCWPbm = $01;
    // Boot Lock
    BOOTLOCKbm = $02;
    // EEPROM Ready
    EEREADYbm = $01;
    // EEPROM busy
    EEBUSYbm = $02;
    // Flash busy
    FBUSYbm = $01;
    // Write error
    WRERRORbm = $04;
  end;

  TPORT = object //I/O Ports
    DIR: byte;  //Data Direction
    DIRSET: byte;  //Data Direction Set
    DIRCLR: byte;  //Data Direction Clear
    DIRTGL: byte;  //Data Direction Toggle
    OUT_: byte;  //Output Value
    OUTSET: byte;  //Output Value Set
    OUTCLR: byte;  //Output Value Clear
    OUTTGL: byte;  //Output Value Toggle
    IN_: byte;  //Input Value
    INTFLAGS: byte;  //Interrupt Flags
    PORTCTRL: byte;  //Port Control
    Reserved11: byte;
    Reserved12: byte;
    Reserved13: byte;
    Reserved14: byte;
    Reserved15: byte;
    PIN0CTRL: byte;  //Pin 0 Control
    PIN1CTRL: byte;  //Pin 1 Control
    PIN2CTRL: byte;  //Pin 2 Control
    PIN3CTRL: byte;  //Pin 3 Control
    PIN4CTRL: byte;  //Pin 4 Control
    PIN5CTRL: byte;  //Pin 5 Control
    PIN6CTRL: byte;  //Pin 6 Control
    PIN7CTRL: byte;  //Pin 7 Control
  const
    // Pin Interrupt
    INT0bm = $01;
    INT1bm = $02;
    INT2bm = $04;
    INT3bm = $08;
    INT4bm = $10;
    INT5bm = $20;
    INT6bm = $40;
    INT7bm = $80;
    // Inverted I/O Enable
    INVENbm = $80;
    // PORT_ISC
    ISCmask = $07;
    ISC_INTDISABLE = $00;
    ISC_BOTHEDGES = $01;
    ISC_RISING = $02;
    ISC_FALLING = $03;
    ISC_INPUT_DISABLE = $04;
    ISC_LEVEL = $05;
    // Pullup enable
    PULLUPENbm = $08;
    // Slew Rate Limit Enable
    SRLbm = $01;
  end;

  TPORTMUX = object //Port Multiplexer
    EVSYSROUTEA: byte;  //Port Multiplexer EVSYS
    CCLROUTEA: byte;  //Port Multiplexer CCL
    USARTROUTEA: byte;  //Port Multiplexer USART register A
    SPIROUTEA: byte;  //Port Multiplexer TWI and SPI
    TCAROUTEA: byte;  //Port Multiplexer TCA
    TCBROUTEA: byte;  //Port Multiplexer TCB
  const
    // CCL LUT0
    LUT0bm = $01;
    // CCL LUT1
    LUT1bm = $02;
    // CCL LUT2
    LUT2bm = $04;
    // CCL LUT3
    LUT3bm = $08;
    // Event Output 0
    EVOUT0bm = $01;
    // Event Output 1
    EVOUT1bm = $02;
    // Event Output 2
    EVOUT2bm = $04;
    // Event Output 3
    EVOUT3bm = $08;
    // Event Output 4
    EVOUT4bm = $10;
    // Event Output 5
    EVOUT5bm = $20;
    // PORTMUX_SPI0
    SPI0mask = $03;
    SPI0_DEFAULT = $00;
    SPI0_ALT1 = $01;
    SPI0_ALT2 = $02;
    SPI0_NONE = $03;
    // PORTMUX_TWI0
    TWI0mask = $30;
    TWI0_DEFAULT = $00;
    TWI0_ALT1 = $10;
    TWI0_ALT2 = $20;
    TWI0_NONE = $30;
    // PORTMUX_TCA0
    TCA0mask = $07;
    TCA0_PORTA = $00;
    TCA0_PORTB = $01;
    TCA0_PORTC = $02;
    TCA0_PORTD = $03;
    TCA0_PORTE = $04;
    TCA0_PORTF = $05;
    // Port Multiplexer TCB0
    TCB0bm = $01;
    // Port Multiplexer TCB1
    TCB1bm = $02;
    // Port Multiplexer TCB2
    TCB2bm = $04;
    // Port Multiplexer TCB3
    TCB3bm = $08;
    // PORTMUX_USART0
    USART0mask = $03;
    USART0_DEFAULT = $00;
    USART0_ALT1 = $01;
    USART0_NONE = $03;
    // PORTMUX_USART1
    USART1mask = $0C;
    USART1_DEFAULT = $00;
    USART1_ALT1 = $04;
    USART1_NONE = $0C;
  end;

  TRSTCTRL = object //Reset controller
    RSTFR: byte;  //Reset Flags
    SWRR: byte;  //Software Reset
  const
    // Brown out detector Reset flag
    BORFbm = $02;
    // External Reset flag
    EXTRFbm = $04;
    // Power on Reset flag
    PORFbm = $01;
    // Software Reset flag
    SWRFbm = $10;
    // UPDI Reset flag
    UPDIRFbm = $20;
    // Watch dog Reset flag
    WDRFbm = $08;
    // Software reset enable
    SWREbm = $01;
  end;

  TRTC = object //Real-Time Counter
    CTRLA: byte;  //Control A
    STATUS: byte;  //Status
    INTCTRL: byte;  //Interrupt Control
    INTFLAGS: byte;  //Interrupt Flags
    TEMP: byte;  //Temporary
    DBGCTRL: byte;  //Debug control
    CALIB: byte;  //Calibration
    CLKSEL: byte;  //RTC Clock
    CNT: word;  //Counter
    PER: word;  //Period
    CMP: word;  //Compare
    Reserved14: byte;
    Reserved15: byte;
    PITCTRLA: byte;  //PIT Control A
    PITSTATUS: byte;  //PIT Status
    PITINTCTRL: byte;  //PIT Interrupt Control
    PITINTFLAGS: byte;  //PIT Interrupt Flags
    Reserved20: byte;
    PITDBGCTRL: byte;  //PIT Debug control
  const
    // Error Correction Value
    ERROR0bm = $01;
    ERROR1bm = $02;
    ERROR2bm = $04;
    ERROR3bm = $08;
    ERROR4bm = $10;
    ERROR5bm = $20;
    ERROR6bm = $40;
    // Error Correction Sign Bit
    SIGNbm = $80;
    // RTC_CLKSEL
    CLKSELmask = $03;
    CLKSEL_INT32K = $00;
    CLKSEL_INT1K = $01;
    CLKSEL_TOSC32K = $02;
    CLKSEL_EXTCLK = $03;
    // Correction enable
    CORRENbm = $04;
    // RTC_PRESCALER
    PRESCALERmask = $78;
    PRESCALER_DIV1 = $00;
    PRESCALER_DIV2 = $08;
    PRESCALER_DIV4 = $10;
    PRESCALER_DIV8 = $18;
    PRESCALER_DIV16 = $20;
    PRESCALER_DIV32 = $28;
    PRESCALER_DIV64 = $30;
    PRESCALER_DIV128 = $38;
    PRESCALER_DIV256 = $40;
    PRESCALER_DIV512 = $48;
    PRESCALER_DIV1024 = $50;
    PRESCALER_DIV2048 = $58;
    PRESCALER_DIV4096 = $60;
    PRESCALER_DIV8192 = $68;
    PRESCALER_DIV16384 = $70;
    PRESCALER_DIV32768 = $78;
    // Enable
    RTCENbm = $01;
    // Run In Standby
    RUNSTDBYbm = $80;
    // Run in debug
    DBGRUNbm = $01;
    // Compare Match Interrupt enable
    CMPbm = $02;
    // Overflow Interrupt enable
    OVFbm = $01;
    // RTC_PERIOD
    PERIODmask = $78;
    PERIOD_OFF = $00;
    PERIOD_CYC4 = $08;
    PERIOD_CYC8 = $10;
    PERIOD_CYC16 = $18;
    PERIOD_CYC32 = $20;
    PERIOD_CYC64 = $28;
    PERIOD_CYC128 = $30;
    PERIOD_CYC256 = $38;
    PERIOD_CYC512 = $40;
    PERIOD_CYC1024 = $48;
    PERIOD_CYC2048 = $50;
    PERIOD_CYC4096 = $58;
    PERIOD_CYC8192 = $60;
    PERIOD_CYC16384 = $68;
    PERIOD_CYC32768 = $70;
    // Enable
    PITENbm = $01;
    // Periodic Interrupt
    PIbm = $01;
    // CTRLA Synchronization Busy Flag
    CTRLBUSYbm = $01;
    // Comparator Synchronization Busy Flag
    CMPBUSYbm = $08;
    // Count Synchronization Busy Flag
    CNTBUSYbm = $02;
    // CTRLA Synchronization Busy Flag
    CTRLABUSYbm = $01;
    // Period Synchronization Busy Flag
    PERBUSYbm = $04;
  end;

  TSIGROW = object //Signature row
    DEVICEID0: byte;  //Device ID Byte 0
    DEVICEID1: byte;  //Device ID Byte 1
    DEVICEID2: byte;  //Device ID Byte 2
    SERNUM0: byte;  //Serial Number Byte 0
    SERNUM1: byte;  //Serial Number Byte 1
    SERNUM2: byte;  //Serial Number Byte 2
    SERNUM3: byte;  //Serial Number Byte 3
    SERNUM4: byte;  //Serial Number Byte 4
    SERNUM5: byte;  //Serial Number Byte 5
    SERNUM6: byte;  //Serial Number Byte 6
    SERNUM7: byte;  //Serial Number Byte 7
    SERNUM8: byte;  //Serial Number Byte 8
    SERNUM9: byte;  //Serial Number Byte 9
    Reserved13: byte;
    Reserved14: byte;
    Reserved15: byte;
    Reserved16: byte;
    Reserved17: byte;
    Reserved18: byte;
    Reserved19: byte;
    OSCCAL32K: byte;  //Oscillator Calibration for 32kHz ULP
    Reserved21: byte;
    Reserved22: byte;
    Reserved23: byte;
    OSCCAL16M0: byte;  //Oscillator Calibration 16 MHz Byte 0
    OSCCAL16M1: byte;  //Oscillator Calibration 16 MHz Byte 1
    OSCCAL20M0: byte;  //Oscillator Calibration 20 MHz Byte 0
    OSCCAL20M1: byte;  //Oscillator Calibration 20 MHz Byte 1
    Reserved28: byte;
    Reserved29: byte;
    Reserved30: byte;
    Reserved31: byte;
    TEMPSENSE0: byte;  //Temperature Sensor Calibration Byte 0
    TEMPSENSE1: byte;  //Temperature Sensor Calibration Byte 1
    OSC16ERR3V: byte;  //OSC16 error at 3V
    OSC16ERR5V: byte;  //OSC16 error at 5V
    OSC20ERR3V: byte;  //OSC20 error at 3V
    OSC20ERR5V: byte;  //OSC20 error at 5V
    Reserved38: byte;
    Reserved39: byte;
    Reserved40: byte;
    Reserved41: byte;
    Reserved42: byte;
    Reserved43: byte;
    Reserved44: byte;
    Reserved45: byte;
    Reserved46: byte;
    CHECKSUM1: byte;  //CRC Checksum Byte 1
  end;

  TSLPCTRL = object //Sleep Controller
    CTRLA: byte;  //Control
  const
    // Sleep enable
    SENbm = $01;
    // SLPCTRL_SMODE
    SMODEmask = $06;
    SMODE_IDLE = $00;
    SMODE_STDBY = $02;
    SMODE_PDOWN = $04;
  end;

  TSPI = object //Serial Peripheral Interface
    CTRLA: byte;  //Control A
    CTRLB: byte;  //Control B
    INTCTRL: byte;  //Interrupt Control
    INTFLAGS: byte;  //Interrupt Flags
    DATA: byte;  //Data
  const
    // Enable Double Speed
    CLK2Xbm = $10;
    // Data Order Setting
    DORDbm = $40;
    // Enable Module
    ENABLEbm = $01;
    // Master Operation Enable
    MASTERbm = $20;
    // SPI_PRESC
    PRESCmask = $06;
    PRESC_DIV4 = $00;
    PRESC_DIV16 = $02;
    PRESC_DIV64 = $04;
    PRESC_DIV128 = $06;
    // Buffer Mode Enable
    BUFENbm = $80;
    // Buffer Mode Wait for Receive
    BUFWRbm = $40;
    // SPI_MODE
    MODEmask = $03;
    MODE_0 = $00;
    MODE_1 = $01;
    MODE_2 = $02;
    MODE_3 = $03;
    // Slave Select Disable
    SSDbm = $04;
    // Data Register Empty Interrupt Enable
    DREIEbm = $20;
    // Interrupt Enable
    IEbm = $01;
    // Receive Complete Interrupt Enable
    RXCIEbm = $80;
    // Slave Select Trigger Interrupt Enable
    SSIEbm = $10;
    // Transfer Complete Interrupt Enable
    TXCIEbm = $40;
    // Buffer Overflow
    BUFOVFbm = $01;
    // Data Register Empty Interrupt Flag
    DREIFbm = $20;
    // Receive Complete Interrupt Flag
    RXCIFbm = $80;
    // Slave Select Trigger Interrupt Flag
    SSIFbm = $10;
    // Transfer Complete Interrupt Flag
    TXCIFbm = $40;
    // Interrupt Flag
    IFbm = $80;
    // Write Collision
    WRCOLbm = $40;
  end;

  TSYSCFG = object //System Configuration Registers
    Reserved0: byte;
    REVID: byte;  //Revision ID
    EXTBRK: byte;  //External Break
    Reserved3: byte;
    Reserved4: byte;
    Reserved5: byte;
    Reserved6: byte;
    Reserved7: byte;
    Reserved8: byte;
    Reserved9: byte;
    Reserved10: byte;
    Reserved11: byte;
    Reserved12: byte;
    Reserved13: byte;
    Reserved14: byte;
    Reserved15: byte;
    Reserved16: byte;
    Reserved17: byte;
    Reserved18: byte;
    Reserved19: byte;
    Reserved20: byte;
    Reserved21: byte;
    Reserved22: byte;
    Reserved23: byte;
    OCDM: byte;  //OCD Message Register
    OCDMS: byte;  //OCD Message Status
  const
    // External break enable
    ENEXTBRKbm = $01;
    // OCD Message Read
    OCDMRbm = $01;
  end;

  TTCA_SINGLE = object //16-bit Timer/Counter Type A - Single Mode
    CTRLA: byte;  //Control A
    CTRLB: byte;  //Control B
    CTRLC: byte;  //Control C
    CTRLD: byte;  //Control D
    CTRLECLR: byte;  //Control E Clear
    CTRLESET: byte;  //Control E Set
    CTRLFCLR: byte;  //Control F Clear
    CTRLFSET: byte;  //Control F Set
    Reserved8: byte;
    EVCTRL: byte;  //Event Control
    INTCTRL: byte;  //Interrupt Control
    INTFLAGS: byte;  //Interrupt Flags
    Reserved12: byte;
    Reserved13: byte;
    DBGCTRL: byte;  //Degbug Control
    TEMP: byte;  //Temporary data for 16-bit Access
    Reserved16: byte;
    Reserved17: byte;
    Reserved18: byte;
    Reserved19: byte;
    Reserved20: byte;
    Reserved21: byte;
    Reserved22: byte;
    Reserved23: byte;
    Reserved24: byte;
    Reserved25: byte;
    Reserved26: byte;
    Reserved27: byte;
    Reserved28: byte;
    Reserved29: byte;
    Reserved30: byte;
    Reserved31: byte;
    CNT: word;  //Count
    Reserved34: byte;
    Reserved35: byte;
    Reserved36: byte;
    Reserved37: byte;
    PER: word;  //Period
    CMP0: word;  //Compare 0
    CMP1: word;  //Compare 1
    CMP2: word;  //Compare 2
    Reserved46: byte;
    Reserved47: byte;
    Reserved48: byte;
    Reserved49: byte;
    Reserved50: byte;
    Reserved51: byte;
    Reserved52: byte;
    Reserved53: byte;
    PERBUF: word;  //Period Buffer
    CMP0BUF: word;  //Compare 0 Buffer
    CMP1BUF: word;  //Compare 1 Buffer
    CMP2BUF: word;  //Compare 2 Buffer
  const
    // TCA_SINGLE_CLKSEL
    SINGLE_CLKSELmask = $0E;
    SINGLE_CLKSEL_DIV1 = $00;
    SINGLE_CLKSEL_DIV2 = $02;
    SINGLE_CLKSEL_DIV4 = $04;
    SINGLE_CLKSEL_DIV8 = $06;
    SINGLE_CLKSEL_DIV16 = $08;
    SINGLE_CLKSEL_DIV64 = $0A;
    SINGLE_CLKSEL_DIV256 = $0C;
    SINGLE_CLKSEL_DIV1024 = $0E;
    // Module Enable
    ENABLEbm = $01;
    // Run in Standby
    RUNSTDBYbm = $80;
    // Auto Lock Update
    ALUPDbm = $08;
    // Compare 0 Enable
    CMP0ENbm = $10;
    // Compare 1 Enable
    CMP1ENbm = $20;
    // Compare 2 Enable
    CMP2ENbm = $40;
    // TCA_SINGLE_WGMODE
    SINGLE_WGMODEmask = $07;
    SINGLE_WGMODE_NORMAL = $00;
    SINGLE_WGMODE_FRQ = $01;
    SINGLE_WGMODE_SINGLESLOPE = $03;
    SINGLE_WGMODE_DSTOP = $05;
    SINGLE_WGMODE_DSBOTH = $06;
    SINGLE_WGMODE_DSBOTTOM = $07;
    // Compare 0 Waveform Output Value
    CMP0OVbm = $01;
    // Compare 1 Waveform Output Value
    CMP1OVbm = $02;
    // Compare 2 Waveform Output Value
    CMP2OVbm = $04;
    // Split Mode Enable
    SPLITMbm = $01;
    // TCA_SINGLE_CMD
    SINGLE_CMDmask = $0C;
    SINGLE_CMD_NONE = $00;
    SINGLE_CMD_UPDATE = $04;
    SINGLE_CMD_RESTART = $08;
    SINGLE_CMD_RESET = $0C;
    // Direction
    DIRbm = $01;
    // Lock Update
    LUPDbm = $02;
    // Compare 0 Buffer Valid
    CMP0BVbm = $02;
    // Compare 1 Buffer Valid
    CMP1BVbm = $04;
    // Compare 2 Buffer Valid
    CMP2BVbm = $08;
    // Period Buffer Valid
    PERBVbm = $01;
    // Debug Run
    DBGRUNbm = $01;
    // Count on Event Input A
    CNTAEIbm = $01;
    // Count on Event Input B
    CNTBEIbm = $10;
    // TCA_SINGLE_EVACTA
    SINGLE_EVACTAmask = $0E;
    SINGLE_EVACTA_CNT_POSEDGE = $00;
    SINGLE_EVACTA_CNT_ANYEDGE = $02;
    SINGLE_EVACTA_CNT_HIGHLVL = $04;
    SINGLE_EVACTA_UPDOWN = $06;
    // TCA_SINGLE_EVACTB
    SINGLE_EVACTBmask = $E0;
    SINGLE_EVACTB_UPDOWN = $60;
    SINGLE_EVACTB_RESTART_POSEDGE = $80;
    SINGLE_EVACTB_RESTART_ANYEDGE = $A0;
    SINGLE_EVACTB_RESTART_HIGHLVL = $C0;
    // Compare 0 Interrupt
    CMP0bm = $10;
    // Compare 1 Interrupt
    CMP1bm = $20;
    // Compare 2 Interrupt
    CMP2bm = $40;
    // Overflow Interrupt
    OVFbm = $01;
  end;

  TTCA_SPLIT = object //16-bit Timer/Counter Type A - Split Mode
    CTRLA: byte;  //Control A
    CTRLB: byte;  //Control B
    CTRLC: byte;  //Control C
    CTRLD: byte;  //Control D
    CTRLECLR: byte;  //Control E Clear
    CTRLESET: byte;  //Control E Set
    Reserved6: byte;
    Reserved7: byte;
    Reserved8: byte;
    Reserved9: byte;
    INTCTRL: byte;  //Interrupt Control
    INTFLAGS: byte;  //Interrupt Flags
    Reserved12: byte;
    Reserved13: byte;
    DBGCTRL: byte;  //Degbug Control
    Reserved15: byte;
    Reserved16: byte;
    Reserved17: byte;
    Reserved18: byte;
    Reserved19: byte;
    Reserved20: byte;
    Reserved21: byte;
    Reserved22: byte;
    Reserved23: byte;
    Reserved24: byte;
    Reserved25: byte;
    Reserved26: byte;
    Reserved27: byte;
    Reserved28: byte;
    Reserved29: byte;
    Reserved30: byte;
    Reserved31: byte;
    LCNT: byte;  //Low Count
    HCNT: byte;  //High Count
    Reserved34: byte;
    Reserved35: byte;
    Reserved36: byte;
    Reserved37: byte;
    LPER: byte;  //Low Period
    HPER: byte;  //High Period
    LCMP0: byte;  //Low Compare
    HCMP0: byte;  //High Compare
    LCMP1: byte;  //Low Compare
    HCMP1: byte;  //High Compare
    LCMP2: byte;  //Low Compare
    HCMP2: byte;  //High Compare
  const
    // TCA_SPLIT_CLKSEL
    SPLIT_CLKSELmask = $0E;
    SPLIT_CLKSEL_DIV1 = $00;
    SPLIT_CLKSEL_DIV2 = $02;
    SPLIT_CLKSEL_DIV4 = $04;
    SPLIT_CLKSEL_DIV8 = $06;
    SPLIT_CLKSEL_DIV16 = $08;
    SPLIT_CLKSEL_DIV64 = $0A;
    SPLIT_CLKSEL_DIV256 = $0C;
    SPLIT_CLKSEL_DIV1024 = $0E;
    // Module Enable
    ENABLEbm = $01;
    // Run in Standby
    RUNSTDBYbm = $80;
    // High Compare 0 Enable
    HCMP0ENbm = $10;
    // High Compare 1 Enable
    HCMP1ENbm = $20;
    // High Compare 2 Enable
    HCMP2ENbm = $40;
    // Low Compare 0 Enable
    LCMP0ENbm = $01;
    // Low Compare 1 Enable
    LCMP1ENbm = $02;
    // Low Compare 2 Enable
    LCMP2ENbm = $04;
    // High Compare 0 Output Value
    HCMP0OVbm = $10;
    // High Compare 1 Output Value
    HCMP1OVbm = $20;
    // High Compare 2 Output Value
    HCMP2OVbm = $40;
    // Low Compare 0 Output Value
    LCMP0OVbm = $01;
    // Low Compare 1 Output Value
    LCMP1OVbm = $02;
    // Low Compare 2 Output Value
    LCMP2OVbm = $04;
    // Split Mode Enable
    SPLITMbm = $01;
    // TCA_SPLIT_CMD
    SPLIT_CMDmask = $0C;
    SPLIT_CMD_NONE = $00;
    SPLIT_CMD_UPDATE = $04;
    SPLIT_CMD_RESTART = $08;
    SPLIT_CMD_RESET = $0C;
    // TCA_SPLIT_CMDEN
    SPLIT_CMDENmask = $03;
    SPLIT_CMDEN_NONE = $00;
    SPLIT_CMDEN_BOTH = $03;
    // Debug Run
    DBGRUNbm = $01;
    // High Underflow Interrupt Enable
    HUNFbm = $02;
    // Low Compare 0 Interrupt Enable
    LCMP0bm = $10;
    // Low Compare 1 Interrupt Enable
    LCMP1bm = $20;
    // Low Compare 2 Interrupt Enable
    LCMP2bm = $40;
    // Low Underflow Interrupt Enable
    LUNFbm = $01;
  end;

  TTCA = record //16-bit Timer/Counter Type A
    case byte of
      0: (SINGLE: TTCA_SINGLE);
      1: (SPLIT: TTCA_SPLIT);
  end;

  TTCB = object //16-bit Timer Type B
    CTRLA: byte;  //Control A
    CTRLB: byte;  //Control Register B
    Reserved2: byte;
    Reserved3: byte;
    EVCTRL: byte;  //Event Control
    INTCTRL: byte;  //Interrupt Control
    INTFLAGS: byte;  //Interrupt Flags
    STATUS: byte;  //Status
    DBGCTRL: byte;  //Debug Control
    TEMP: byte;  //Temporary Value
    CNT: word;  //Count
    CCMP: word;  //Compare or Capture
  const
    // Cascade two timers
    CASCADEbm = $20;
    // TCB_CLKSEL
    CLKSELmask = $0E;
    CLKSEL_DIV1 = $00;
    CLKSEL_DIV2 = $02;
    CLKSEL_TCA0 = $04;
    CLKSEL_EVENT = $0E;
    // Enable
    ENABLEbm = $01;
    // Run Standby
    RUNSTDBYbm = $40;
    // Synchronize Update
    SYNCUPDbm = $10;
    // Asynchronous Enable
    ASYNCbm = $40;
    // Pin Output Enable
    CCMPENbm = $10;
    // Pin Initial State
    CCMPINITbm = $20;
    // TCB_CNTMODE
    CNTMODEmask = $07;
    CNTMODE_INT = $00;
    CNTMODE_TIMEOUT = $01;
    CNTMODE_CAPT = $02;
    CNTMODE_FRQ = $03;
    CNTMODE_PW = $04;
    CNTMODE_FRQPW = $05;
    CNTMODE_SINGLE = $06;
    CNTMODE_PWM8 = $07;
    // Debug Run
    DBGRUNbm = $01;
    // Event Input Enable
    CAPTEIbm = $01;
    // Event Edge
    EDGEbm = $10;
    // Input Capture Noise Cancellation Filter
    FILTERbm = $40;
    // Capture or Timeout
    CAPTbm = $01;
    // Overflow
    OVFbm = $02;
    // Run
    RUNbm = $01;
  end;

  TTWI = object //Two-Wire Interface
    CTRLA: byte;  //Control A
    Reserved1: byte;
    DBGCTRL: byte;  //Debug Control Register
    MCTRLA: byte;  //Master Control A
    MCTRLB: byte;  //Master Control B
    MSTATUS: byte;  //Master Status
    MBAUD: byte;  //Master Baud Rate Control
    MADDR: byte;  //Master Address
    MDATA: byte;  //Master Data
    SCTRLA: byte;  //Slave Control A
    SCTRLB: byte;  //Slave Control B
    SSTATUS: byte;  //Slave Status
    SADDR: byte;  //Slave Address
    SDATA: byte;  //Slave Data
    SADDRMASK: byte;  //Slave Address Mask
  const
    // FM Plus Enable
    FMPENbm = $02;
    // TWI_DEFAULT_SDAHOLD
    DEFAULT_SDAHOLDmask = $0C;
    DEFAULT_SDAHOLD_OFF = $00;
    DEFAULT_SDAHOLD_50NS = $04;
    DEFAULT_SDAHOLD_300NS = $08;
    DEFAULT_SDAHOLD_500NS = $0C;
    // TWI_DEFAULT_SDASETUP
    DEFAULT_SDASETUPmask = $10;
    DEFAULT_SDASETUP_4CYC = $00;
    DEFAULT_SDASETUP_8CYC = $10;
    // Debug Run
    DBGRUNbm = $01;
    // Enable TWI Master
    ENABLEbm = $01;
    // Quick Command Enable
    QCENbm = $10;
    // Read Interrupt Enable
    RIENbm = $80;
    // Smart Mode Enable
    SMENbm = $02;
    // TWI_TIMEOUT
    TIMEOUTmask = $0C;
    TIMEOUT_DISABLED = $00;
    TIMEOUT_50US = $04;
    TIMEOUT_100US = $08;
    TIMEOUT_200US = $0C;
    // Write Interrupt Enable
    WIENbm = $40;
    // TWI_ACKACT
    ACKACTmask = $04;
    ACKACT_ACK = $00;
    ACKACT_NACK = $04;
    // Flush
    FLUSHbm = $08;
    // TWI_MCMD
    MCMDmask = $03;
    MCMD_NOACT = $00;
    MCMD_REPSTART = $01;
    MCMD_RECVTRANS = $02;
    MCMD_STOP = $03;
    // Arbitration Lost
    ARBLOSTbm = $08;
    // Bus Error
    BUSERRbm = $04;
    // TWI_BUSSTATE
    BUSSTATEmask = $03;
    BUSSTATE_UNKNOWN = $00;
    BUSSTATE_IDLE = $01;
    BUSSTATE_OWNER = $02;
    BUSSTATE_BUSY = $03;
    // Clock Hold
    CLKHOLDbm = $20;
    // Read Interrupt Flag
    RIFbm = $80;
    // Received Acknowledge
    RXACKbm = $10;
    // Write Interrupt Flag
    WIFbm = $40;
    // Address Enable
    ADDRENbm = $01;
    // Address Mask
    ADDRMASK0bm = $02;
    ADDRMASK1bm = $04;
    ADDRMASK2bm = $08;
    ADDRMASK3bm = $10;
    ADDRMASK4bm = $20;
    ADDRMASK5bm = $40;
    ADDRMASK6bm = $80;
    // Address/Stop Interrupt Enable
    APIENbm = $40;
    // Data Interrupt Enable
    DIENbm = $80;
    // Stop Interrupt Enable
    PIENbm = $20;
    // Permissive Mode Enable
    PMENbm = $04;
    // TWI_SCMD
    SCMDmask = $03;
    SCMD_NOACT = $00;
    SCMD_COMPTRANS = $02;
    SCMD_RESPONSE = $03;
    // TWI_AP
    APmask = $01;
    AP_STOP = $00;
    AP_ADR = $01;
    // Address/Stop Interrupt Flag
    APIFbm = $40;
    // Collision
    COLLbm = $08;
    // Data Interrupt Flag
    DIFbm = $80;
    // Read/Write Direction
    DIRbm = $02;
  end;

  TUSART = object //Universal Synchronous and Asynchronous Receiver and Transmitter
    RXDATAL: byte;  //Receive Data Low Byte
    RXDATAH: byte;  //Receive Data High Byte
    TXDATAL: byte;  //Transmit Data Low Byte
    TXDATAH: byte;  //Transmit Data High Byte
    STATUS: byte;  //Status
    CTRLA: byte;  //Control A
    CTRLB: byte;  //Control B
    CTRLC: byte;  //Control C
    BAUD: word;  //Baud Rate
    CTRLD: byte;  //Control D
    DBGCTRL: byte;  //Debug Control
    EVCTRL: byte;  //Event Control
    TXPLCTRL: byte;  //IRCOM Transmitter Pulse Length Control
    RXPLCTRL: byte;  //IRCOM Receiver Pulse Length Control
  const
    // Auto-baud Error Interrupt Enable
    ABEIEbm = $04;
    // Data Register Empty Interrupt Enable
    DREIEbm = $20;
    // Loop-back Mode Enable
    LBMEbm = $08;
    // USART_RS485
    RS485mask = $01;
    RS485_DISABLE = $00;
    RS485_ENABLE = $01;
    // Receive Complete Interrupt Enable
    RXCIEbm = $80;
    // Receiver Start Frame Interrupt Enable
    RXSIEbm = $10;
    // Transmit Complete Interrupt Enable
    TXCIEbm = $40;
    // Multi-processor Communication Mode
    MPCMbm = $01;
    // Open Drain Mode Enable
    ODMEbm = $08;
    // Reciever enable
    RXENbm = $80;
    // USART_RXMODE
    RXMODEmask = $06;
    RXMODE_NORMAL = $00;
    RXMODE_CLK2X = $02;
    RXMODE_GENAUTO = $04;
    RXMODE_LINAUTO = $06;
    // Start Frame Detection Enable
    SFDENbm = $10;
    // Transmitter Enable
    TXENbm = $40;
    // USART_MSPI_CMODE
    MSPI_CMODEmask = $C0;
    MSPI_CMODE_ASYNCHRONOUS = $00;
    MSPI_CMODE_SYNCHRONOUS = $40;
    MSPI_CMODE_IRCOM = $80;
    MSPI_CMODE_MSPI = $C0;
    // SPI Master Mode, Clock Phase
    UCPHAbm = $02;
    // SPI Master Mode, Data Order
    UDORDbm = $04;
    // USART_NORMAL_CHSIZE
    NORMAL_CHSIZEmask = $07;
    NORMAL_CHSIZE_5BIT = $00;
    NORMAL_CHSIZE_6BIT = $01;
    NORMAL_CHSIZE_7BIT = $02;
    NORMAL_CHSIZE_8BIT = $03;
    NORMAL_CHSIZE_9BITL = $06;
    NORMAL_CHSIZE_9BITH = $07;
    // USART_NORMAL_CMODE
    NORMAL_CMODEmask = $C0;
    NORMAL_CMODE_ASYNCHRONOUS = $00;
    NORMAL_CMODE_SYNCHRONOUS = $40;
    NORMAL_CMODE_IRCOM = $80;
    NORMAL_CMODE_MSPI = $C0;
    // USART_NORMAL_PMODE
    NORMAL_PMODEmask = $30;
    NORMAL_PMODE_DISABLED = $00;
    NORMAL_PMODE_EVEN = $20;
    NORMAL_PMODE_ODD = $30;
    // USART_NORMAL_SBMODE
    NORMAL_SBMODEmask = $08;
    NORMAL_SBMODE_1BIT = $00;
    NORMAL_SBMODE_2BIT = $08;
    // USART_ABW
    ABWmask = $C0;
    ABW_WDW0 = $00;
    ABW_WDW1 = $40;
    ABW_WDW2 = $80;
    ABW_WDW3 = $C0;
    // Autobaud majority voter bypass
    ABMBPbm = $80;
    // Debug Run
    DBGRUNbm = $01;
    // IrDA Event Input Enable
    IREIbm = $01;
    // Buffer Overflow
    BUFOVFbm = $40;
    // Receiver Data Register
    DATA8bm = $01;
    // Frame Error
    FERRbm = $04;
    // Parity Error
    PERRbm = $02;
    // Receive Complete Interrupt Flag
    RXCIFbm = $80;
    // RX Data
    DATA0bm = $01;
    DATA1bm = $02;
    DATA2bm = $04;
    DATA3bm = $08;
    DATA4bm = $10;
    DATA5bm = $20;
    DATA6bm = $40;
    DATA7bm = $80;
    // Receiver Pulse Lenght
    RXPL0bm = $01;
    RXPL1bm = $02;
    RXPL2bm = $04;
    RXPL3bm = $08;
    RXPL4bm = $10;
    RXPL5bm = $20;
    RXPL6bm = $40;
    // Break Detected Flag
    BDFbm = $02;
    // Data Register Empty Flag
    DREIFbm = $20;
    // Inconsistent Sync Field Interrupt Flag
    ISFIFbm = $08;
    // Receive Start Interrupt
    RXSIFbm = $10;
    // Transmit Interrupt Flag
    TXCIFbm = $40;
    // Wait For Break
    WFBbm = $01;
    // Transmit pulse length
    TXPL0bm = $01;
    TXPL1bm = $02;
    TXPL2bm = $04;
    TXPL3bm = $08;
    TXPL4bm = $10;
    TXPL5bm = $20;
    TXPL6bm = $40;
    TXPL7bm = $80;
  end;

  TUSERROW = object //User Row
    USERROW0: byte;  //User Row Byte 0
    USERROW1: byte;  //User Row Byte 1
    USERROW2: byte;  //User Row Byte 2
    USERROW3: byte;  //User Row Byte 3
    USERROW4: byte;  //User Row Byte 4
    USERROW5: byte;  //User Row Byte 5
    USERROW6: byte;  //User Row Byte 6
    USERROW7: byte;  //User Row Byte 7
    USERROW8: byte;  //User Row Byte 8
    USERROW9: byte;  //User Row Byte 9
    USERROW10: byte;  //User Row Byte 10
    USERROW11: byte;  //User Row Byte 11
    USERROW12: byte;  //User Row Byte 12
    USERROW13: byte;  //User Row Byte 13
    USERROW14: byte;  //User Row Byte 14
    USERROW15: byte;  //User Row Byte 15
    USERROW16: byte;  //User Row Byte 16
    USERROW17: byte;  //User Row Byte 17
    USERROW18: byte;  //User Row Byte 18
    USERROW19: byte;  //User Row Byte 19
    USERROW20: byte;  //User Row Byte 20
    USERROW21: byte;  //User Row Byte 21
    USERROW22: byte;  //User Row Byte 22
    USERROW23: byte;  //User Row Byte 23
    USERROW24: byte;  //User Row Byte 24
    USERROW25: byte;  //User Row Byte 25
    USERROW26: byte;  //User Row Byte 26
    USERROW27: byte;  //User Row Byte 27
    USERROW28: byte;  //User Row Byte 28
    USERROW29: byte;  //User Row Byte 29
    USERROW30: byte;  //User Row Byte 30
    USERROW31: byte;  //User Row Byte 31
    USERROW32: byte;  //User Row Byte 32
    USERROW33: byte;  //User Row Byte 33
    USERROW34: byte;  //User Row Byte 34
    USERROW35: byte;  //User Row Byte 35
    USERROW36: byte;  //User Row Byte 36
    USERROW37: byte;  //User Row Byte 37
    USERROW38: byte;  //User Row Byte 38
    USERROW39: byte;  //User Row Byte 39
    USERROW40: byte;  //User Row Byte 40
    USERROW41: byte;  //User Row Byte 41
    USERROW42: byte;  //User Row Byte 42
    USERROW43: byte;  //User Row Byte 43
    USERROW44: byte;  //User Row Byte 44
    USERROW45: byte;  //User Row Byte 45
    USERROW46: byte;  //User Row Byte 46
    USERROW47: byte;  //User Row Byte 47
    USERROW48: byte;  //User Row Byte 48
    USERROW49: byte;  //User Row Byte 49
    USERROW50: byte;  //User Row Byte 50
    USERROW51: byte;  //User Row Byte 51
    USERROW52: byte;  //User Row Byte 52
    USERROW53: byte;  //User Row Byte 53
    USERROW54: byte;  //User Row Byte 54
    USERROW55: byte;  //User Row Byte 55
    USERROW56: byte;  //User Row Byte 56
    USERROW57: byte;  //User Row Byte 57
    USERROW58: byte;  //User Row Byte 58
    USERROW59: byte;  //User Row Byte 59
    USERROW60: byte;  //User Row Byte 60
    USERROW61: byte;  //User Row Byte 61
    USERROW62: byte;  //User Row Byte 62
    USERROW63: byte;  //User Row Byte 63
  end;

  TVPORT = object //Virtual Ports
    DIR: byte;  //Data Direction
    OUT_: byte;  //Output Value
    IN_: byte;  //Input Value
    INTFLAGS: byte;  //Interrupt Flags
  const
    // Pin Interrupt
    INT0bm = $01;
    INT1bm = $02;
    INT2bm = $04;
    INT3bm = $08;
    INT4bm = $10;
    INT5bm = $20;
    INT6bm = $40;
    INT7bm = $80;
  end;

  TVREF = object //Voltage reference
    CTRLA: byte;  //Control A
    CTRLB: byte;  //Control B
  const
    // VREF_AC0REFSEL
    AC0REFSELmask = $07;
    AC0REFSEL_1V024 = $00;
    AC0REFSEL_2V048 = $01;
    AC0REFSEL_2V5 = $02;
    AC0REFSEL_4V096 = $03;
    AC0REFSEL_AVDD = $07;
    // AC0 DACREF reference enable
    AC0REFENbm = $01;
    // ADC0 reference enable
    ADC0REFENbm = $02;
    // NVM reference enable
    NVMREFENbm = $04;
  end;

  TWDT = object //Watch-Dog Timer
    CTRLA: byte;  //Control A
    STATUS: byte;  //Status
  const
    // WDT_PERIOD
    PERIODmask = $0F;
    PERIOD_OFF = $00;
    PERIOD_8CLK = $01;
    PERIOD_16CLK = $02;
    PERIOD_32CLK = $03;
    PERIOD_64CLK = $04;
    PERIOD_128CLK = $05;
    PERIOD_256CLK = $06;
    PERIOD_512CLK = $07;
    PERIOD_1KCLK = $08;
    PERIOD_2KCLK = $09;
    PERIOD_4KCLK = $0A;
    PERIOD_8KCLK = $0B;
    // WDT_WINDOW
    WINDOWmask = $F0;
    WINDOW_OFF = $00;
    WINDOW_8CLK = $10;
    WINDOW_16CLK = $20;
    WINDOW_32CLK = $30;
    WINDOW_64CLK = $40;
    WINDOW_128CLK = $50;
    WINDOW_256CLK = $60;
    WINDOW_512CLK = $70;
    WINDOW_1KCLK = $80;
    WINDOW_2KCLK = $90;
    WINDOW_4KCLK = $A0;
    WINDOW_8KCLK = $B0;
    // Lock enable
    LOCKbm = $80;
    // Syncronization busy
    SYNCBUSYbm = $01;
  end;


const
 Pin0idx = 0;  Pin0bm = 1;
 Pin1idx = 1;  Pin1bm = 2;
 Pin2idx = 2;  Pin2bm = 4;
 Pin3idx = 3;  Pin3bm = 8;
 Pin4idx = 4;  Pin4bm = 16;
 Pin5idx = 5;  Pin5bm = 32;
 Pin6idx = 6;  Pin6bm = 64;
 Pin7idx = 7;  Pin7bm = 128;

var
  VPORTA: TVPORT absolute $0000;
  VPORTB: TVPORT absolute $0004;
  VPORTC: TVPORT absolute $0008;
  GPIO: TGPIO absolute $001C;
  CPU: TCPU absolute $0030;
  RSTCTRL: TRSTCTRL absolute $0040;
  SLPCTRL: TSLPCTRL absolute $0050;
  CLKCTRL: TCLKCTRL absolute $0060;
  BOD: TBOD absolute $0080;
  VREF: TVREF absolute $00A0;
  NVMBIST: TNVMBIST absolute $00C0;
  WDT: TWDT absolute $0100;
  CPUINT: TCPUINT absolute $0110;
  CRCSCAN: TCRCSCAN absolute $0120;
  RTC: TRTC absolute $0140;
  EVSYS: TEVSYS absolute $0180;
  CCL: TCCL absolute $01C0;
  PORTA: TPORT absolute $0400;
  PORTB: TPORT absolute $0420;
  PORTC: TPORT absolute $0440;
  PORTMUX: TPORTMUX absolute $05E0;
  ADC0: TADC absolute $0600;
  AC0: TAC absolute $0680;
  USART0: TUSART absolute $0800;
  USART1: TUSART absolute $0820;
  TWI0: TTWI absolute $08A0;
  SPI0: TSPI absolute $08C0;
  TCA0: TTCA absolute $0A00;
  TCB0: TTCB absolute $0A80;
  TCB1: TTCB absolute $0A90;
  SYSCFG: TSYSCFG absolute $0F00;
  NVMCTRL: TNVMCTRL absolute $1000;
  SIGROW: TSIGROW absolute $1100;
  FUSE: TFUSE absolute $1280;
  LOCKBIT: TLOCKBIT absolute $128A;
  USERROW: TUSERROW absolute $1300;

implementation

{$i avrcommon.inc}

procedure CRCSCAN_NMI_ISR; external name 'CRCSCAN_NMI_ISR'; // Interrupt 1 
procedure BOD_VLM_ISR; external name 'BOD_VLM_ISR'; // Interrupt 2 
procedure RTC_CNT_ISR; external name 'RTC_CNT_ISR'; // Interrupt 3 
procedure RTC_PIT_ISR; external name 'RTC_PIT_ISR'; // Interrupt 4 
procedure CCL_CCL_ISR; external name 'CCL_CCL_ISR'; // Interrupt 5 
procedure PORTA_PORT_ISR; external name 'PORTA_PORT_ISR'; // Interrupt 6 
procedure PORTB_PORT_ISR; external name 'PORTB_PORT_ISR'; // Interrupt 7 
procedure TCA0_LUNF_ISR; external name 'TCA0_LUNF_ISR'; // Interrupt 8 
//procedure TCA0_OVF_ISR; external name 'TCA0_OVF_ISR'; // Interrupt 8 
procedure TCA0_HUNF_ISR; external name 'TCA0_HUNF_ISR'; // Interrupt 9 
procedure TCA0_CMP0_ISR; external name 'TCA0_CMP0_ISR'; // Interrupt 10 
//procedure TCA0_LCMP0_ISR; external name 'TCA0_LCMP0_ISR'; // Interrupt 10 
procedure TCA0_CMP1_ISR; external name 'TCA0_CMP1_ISR'; // Interrupt 11 
//procedure TCA0_LCMP1_ISR; external name 'TCA0_LCMP1_ISR'; // Interrupt 11 
procedure TCA0_CMP2_ISR; external name 'TCA0_CMP2_ISR'; // Interrupt 12 
//procedure TCA0_LCMP2_ISR; external name 'TCA0_LCMP2_ISR'; // Interrupt 12 
procedure TCB0_INT_ISR; external name 'TCB0_INT_ISR'; // Interrupt 13 
procedure TWI0_TWIS_ISR; external name 'TWI0_TWIS_ISR'; // Interrupt 14 
procedure TWI0_TWIM_ISR; external name 'TWI0_TWIM_ISR'; // Interrupt 15 
procedure SPI0_INT_ISR; external name 'SPI0_INT_ISR'; // Interrupt 16 
procedure USART0_RXC_ISR; external name 'USART0_RXC_ISR'; // Interrupt 17 
procedure USART0_DRE_ISR; external name 'USART0_DRE_ISR'; // Interrupt 18 
procedure USART0_TXC_ISR; external name 'USART0_TXC_ISR'; // Interrupt 19 
procedure AC0_AC_ISR; external name 'AC0_AC_ISR'; // Interrupt 20 
procedure ADC0_ERROR_ISR; external name 'ADC0_ERROR_ISR'; // Interrupt 21 
procedure ADC0_RESRDY_ISR; external name 'ADC0_RESRDY_ISR'; // Interrupt 22 
procedure ADC0_SAMPRDY_ISR; external name 'ADC0_SAMPRDY_ISR'; // Interrupt 23 
procedure PORTC_PORT_ISR; external name 'PORTC_PORT_ISR'; // Interrupt 24 
procedure TCB1_INT_ISR; external name 'TCB1_INT_ISR'; // Interrupt 25 
procedure USART1_RXC_ISR; external name 'USART1_RXC_ISR'; // Interrupt 26 
procedure USART1_DRE_ISR; external name 'USART1_DRE_ISR'; // Interrupt 27 
procedure USART1_TXC_ISR; external name 'USART1_TXC_ISR'; // Interrupt 28 
procedure NVMCTRL_EE_ISR; external name 'NVMCTRL_EE_ISR'; // Interrupt 29 

procedure _FPC_start; assembler; nostackframe;
label
  _start;
asm
  .init
  .globl _start

  jmp _start
  jmp CRCSCAN_NMI_ISR
  jmp BOD_VLM_ISR
  jmp RTC_CNT_ISR
  jmp RTC_PIT_ISR
  jmp CCL_CCL_ISR
  jmp PORTA_PORT_ISR
  jmp PORTB_PORT_ISR
  jmp TCA0_LUNF_ISR
//  jmp TCA0_OVF_ISR
  jmp TCA0_HUNF_ISR
  jmp TCA0_CMP0_ISR
//  jmp TCA0_LCMP0_ISR
  jmp TCA0_CMP1_ISR
//  jmp TCA0_LCMP1_ISR
  jmp TCA0_CMP2_ISR
//  jmp TCA0_LCMP2_ISR
  jmp TCB0_INT_ISR
  jmp TWI0_TWIS_ISR
  jmp TWI0_TWIM_ISR
  jmp SPI0_INT_ISR
  jmp USART0_RXC_ISR
  jmp USART0_DRE_ISR
  jmp USART0_TXC_ISR
  jmp AC0_AC_ISR
  jmp ADC0_ERROR_ISR
  jmp ADC0_RESRDY_ISR
  jmp ADC0_SAMPRDY_ISR
  jmp PORTC_PORT_ISR
  jmp TCB1_INT_ISR
  jmp USART1_RXC_ISR
  jmp USART1_DRE_ISR
  jmp USART1_TXC_ISR
  jmp NVMCTRL_EE_ISR

  {$i start.inc}

  .weak CRCSCAN_NMI_ISR
  .weak BOD_VLM_ISR
  .weak RTC_CNT_ISR
  .weak RTC_PIT_ISR
  .weak CCL_CCL_ISR
  .weak PORTA_PORT_ISR
  .weak PORTB_PORT_ISR
  .weak TCA0_LUNF_ISR
//  .weak TCA0_OVF_ISR
  .weak TCA0_HUNF_ISR
  .weak TCA0_CMP0_ISR
//  .weak TCA0_LCMP0_ISR
  .weak TCA0_CMP1_ISR
//  .weak TCA0_LCMP1_ISR
  .weak TCA0_CMP2_ISR
//  .weak TCA0_LCMP2_ISR
  .weak TCB0_INT_ISR
  .weak TWI0_TWIS_ISR
  .weak TWI0_TWIM_ISR
  .weak SPI0_INT_ISR
  .weak USART0_RXC_ISR
  .weak USART0_DRE_ISR
  .weak USART0_TXC_ISR
  .weak AC0_AC_ISR
  .weak ADC0_ERROR_ISR
  .weak ADC0_RESRDY_ISR
  .weak ADC0_SAMPRDY_ISR
  .weak PORTC_PORT_ISR
  .weak TCB1_INT_ISR
  .weak USART1_RXC_ISR
  .weak USART1_DRE_ISR
  .weak USART1_TXC_ISR
  .weak NVMCTRL_EE_ISR

  .set CRCSCAN_NMI_ISR, Default_IRQ_handler
  .set BOD_VLM_ISR, Default_IRQ_handler
  .set RTC_CNT_ISR, Default_IRQ_handler
  .set RTC_PIT_ISR, Default_IRQ_handler
  .set CCL_CCL_ISR, Default_IRQ_handler
  .set PORTA_PORT_ISR, Default_IRQ_handler
  .set PORTB_PORT_ISR, Default_IRQ_handler
  .set TCA0_LUNF_ISR, Default_IRQ_handler
//  .set TCA0_OVF_ISR, Default_IRQ_handler
  .set TCA0_HUNF_ISR, Default_IRQ_handler
  .set TCA0_CMP0_ISR, Default_IRQ_handler
//  .set TCA0_LCMP0_ISR, Default_IRQ_handler
  .set TCA0_CMP1_ISR, Default_IRQ_handler
//  .set TCA0_LCMP1_ISR, Default_IRQ_handler
  .set TCA0_CMP2_ISR, Default_IRQ_handler
//  .set TCA0_LCMP2_ISR, Default_IRQ_handler
  .set TCB0_INT_ISR, Default_IRQ_handler
  .set TWI0_TWIS_ISR, Default_IRQ_handler
  .set TWI0_TWIM_ISR, Default_IRQ_handler
  .set SPI0_INT_ISR, Default_IRQ_handler
  .set USART0_RXC_ISR, Default_IRQ_handler
  .set USART0_DRE_ISR, Default_IRQ_handler
  .set USART0_TXC_ISR, Default_IRQ_handler
  .set AC0_AC_ISR, Default_IRQ_handler
  .set ADC0_ERROR_ISR, Default_IRQ_handler
  .set ADC0_RESRDY_ISR, Default_IRQ_handler
  .set ADC0_SAMPRDY_ISR, Default_IRQ_handler
  .set PORTC_PORT_ISR, Default_IRQ_handler
  .set TCB1_INT_ISR, Default_IRQ_handler
  .set USART1_RXC_ISR, Default_IRQ_handler
  .set USART1_DRE_ISR, Default_IRQ_handler
  .set USART1_TXC_ISR, Default_IRQ_handler
  .set NVMCTRL_EE_ISR, Default_IRQ_handler
end;

end.
