# HardHeat

![HardHeat simulation](http://www.dgkelectronics.com/storage/electronics/induction_heater/hardheat/github/hardheat_epdm.png)

HardHeat is an FPGA-based induction heater controller made with VHDL. The heart of it is an all-digital phase-locked loop (ADPLL).

HardHeat currently consists of:
  - Phase-frequency detector based on [*1*] which is much more robust when locking to resonant circuits
  - Time-to-digital converter converting the PFD output to a time value for the loop filter
  - PI-controller working as the loop filter, simple model with bitshifted coefficients
  - Phase accumulator working as the digitally controlled oscillator
  - Deadtime generator (static deadtime value)
  - Enchanced pulse density modulator based on [*2*] for adjusting power level
    - For power factor correction, not implemented yet

This GitHub repository contains all the required components and the associated test benches for each component. Also ModelSim project files and waveform setup scripts are included.

The controller has not been tested yet with actual hardware (work in progress).

Thanks to Anders M. for pointing out [1] and to jahonen for help with VHDL!

Kalle Hyvönen - [DGKelectronics.com](http://www.dgkelectronics.com)

---
1. *H. Karaca, "Phase detector for tuning circuit of resonant inverters", Electronics Letters Vol. 36 No. 11, 25th May 2000*
2. *V. Esteve, "Enhanced Pulse-Density-Modulated Power Control for High-Frequency Induction Heating Inverters", IEEE Transactions on Industrial Electronics, Vol. 62, No. 11, November 2015*
