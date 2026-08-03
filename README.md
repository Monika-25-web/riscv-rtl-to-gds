#**RISCForge**
RTL-to-GDSII ASIC Implementation of a 5-Stage Pipelined RV32I RISC-V Processor with Adaptive Branch Prediction, Data Cache & Physical Memory Protection
Independent Project — VLSI Design | Digital IC Design | ASIC Physical Design
##Overview
This project implements the complete design flow of a 5-stage pipelined RV32I RISC-V processor, from architectural specification through RTL design, functional and gate-level verification, static timing analysis, design-for-test, and physical design — ending in a tapeout-ready GDSII file.
Three original architectural extensions were added on top of the baseline pipeline:
Adaptive Branch Predictor — runs a 2-bit and a 1-bit predictor in parallel, auto-switches to whichever performs better every 256 resolved branches
PMP Security Monitor — flags unauthorized memory accesses by comparing every address against a protected base/bound range while not in machine mode
Direct-Mapped Data Cache — 8-line cache sitting between the CPU and data memory, with hit/miss counters
##Architecture
5-stage pipeline: IF → ID → EX → MEM → WB, with hazard detection/forwarding, and the three extensions hooked into the fetch, memory, and cache stages respectively.
Tools Used
Verilog HDL, SystemVerilog (UVM), Visual Studio Code, WSL2 (Ubuntu), Icarus Verilog, GTKWave, Yosys, OpenSTA, OpenLane2, OpenROAD, Magic, Netgen, KLayout, Sky130 PDK, EDA Playground (Riviera-PRO)
Design Flow
Specification / Architecture — draw.io
RTL Design (11 core modules) — VS Code, Verilog
Functional Simulation — Icarus Verilog, GTKWave
Adaptive Branch Predictor (RTL extension) — Icarus Verilog, GTKWave
PMP Security Monitor (RTL extension) — Icarus Verilog, GTKWave
Direct-Mapped Data Cache (RTL extension) — Icarus Verilog, GTKWave
Logic Synthesis (full design) — Yosys
Gate-Level Verification (UVM testbench) — EDA Playground, Riviera-PRO
Functional Coverage — EDA Playground, Riviera-PRO
Static Timing Analysis — OpenSTA, Sky130
DFT — Scan Chain Insertion — Icarus Verilog, GTKWave
Physical Design (Floorplan → P&R) — OpenLane2, OpenROAD
Physical Verification (DRC + LVS) — Magic, Netgen
GDSII (tapeout-ready) — KLayout
Results
Logic Synthesis (Yosys, synth -top riscv_top)
Total cells: 25,062 (baseline) → 28,007 (enhanced) → +2,945 (+11.8%)
Flip-flops: 9,579 (baseline) → 10,115 (enhanced) → +536 (+5.6%)
Baseline = 11 core modules. Enhanced = baseline + adaptive_branch_predictor.v + pmp_unit.v + data_cache.v.
Verification
Gate-level UVM testbench passed with 0 errors, 0 fatals.
Functional coverage: 80.56% overall — branch predictor 41.67%, cache 100%, PMP 100%.
Static Timing Analysis
Ran with OpenSTA and Sky130 standard cells at a 20 ns clock constraint. The reported worst negative slack (WNS ≈ -284 ns) reflects this specific constraint and cell mapping, not yet re-optimized for maximum Fmax — noted as a known follow-up rather than finished timing closure.
DFT — Scan Chain
Scan flip-flop (scan_dff.v, W=32 parameterized shift-register style) verified via scan_chain_tb.v.
Result: Scan chain integrity PASS (32/32 bits match), confirmed in both terminal log and GTKWave waveform.
Physical Verification
DRC (Magic): 0 violations.
LVS (Netgen): clean, no net/device/pin mismatches.
Physical Design
OpenLane2 interactive flow completed — synthesis, floorplan, placement, CTS, routing, GDSII — 0 DRC violations after detailed routing.
Repository Structure



