# RISCForge

**RTL-to-GDSII ASIC Implementation of a 5-Stage Pipelined RV32I RISC-V Processor with Adaptive Branch Prediction, Data Cache & Physical Memory Protection**

Independent Project — VLSI Design | Digital IC Design | ASIC Physical Design

---

## Overview

This project implements the complete design flow of a 5-stage pipelined RV32I RISC-V processor, from architectural specification through RTL design, functional and gate-level verification, static timing analysis, design-for-test, and physical design — ending in a tapeout-ready GDSII file.

Three original architectural extensions were added on top of the baseline pipeline:
- **Adaptive Branch Predictor** — runs a 2-bit and a 1-bit predictor in parallel, auto-switches to whichever performs better every 256 resolved branches
- **PMP Security Monitor** — flags unauthorized memory accesses by comparing every address against a protected base/bound range while not in machine mode
- **Direct-Mapped Data Cache** — 8-line cache sitting between the CPU and data memory, with hit/miss counters

## Architecture

5-stage pipeline: **IF → ID → EX → MEM → WB**, with hazard detection/forwarding, and the three extensions hooked into the fetch, memory, and cache stages respectively.

## Tools Used

Verilog HDL, SystemVerilog (UVM), Visual Studio Code, WSL2 (Ubuntu), Icarus Verilog, GTKWave, Yosys, OpenSTA, OpenLane2, OpenROAD, Magic, Netgen, KLayout, Sky130 PDK, EDA Playground (Riviera-PRO)

## Design Flow

1. Specification / Architecture — draw.io
2. RTL Design (11 core modules) — VS Code, Verilog
3. Functional Simulation — Icarus Verilog, GTKWave
4. Adaptive Branch Predictor (RTL extension) — Icarus Verilog, GTKWave
5. PMP Security Monitor (RTL extension) — Icarus Verilog, GTKWave
6. Direct-Mapped Data Cache (RTL extension) — Icarus Verilog, GTKWave
7. Logic Synthesis (full design) — Yosys
8. Gate-Level Verification (UVM testbench) — EDA Playground, Riviera-PRO
9. Functional Coverage — EDA Playground, Riviera-PRO
10. Static Timing Analysis — OpenSTA, Sky130
11. DFT — Scan Chain Insertion — Icarus Verilog, GTKWave
12. Physical Design (Floorplan → P&R) — OpenLane2, OpenROAD
13. Physical Verification (DRC + LVS) — Magic, Netgen
14. GDSII (tapeout-ready) — KLayout

## Results

**Logic Synthesis (Yosys, synth -top riscv_top)**
- Total cells: 25,062 (baseline) → 28,007 (enhanced) → +2,945 (+11.8%)
- Flip-flops: 9,579 (baseline) → 10,115 (enhanced) → +536 (+5.6%)
- Baseline = 11 core modules. Enhanced = baseline + adaptive_branch_predictor.v + pmp_unit.v + data_cache.v.

**Verification**
- Gate-level UVM testbench passed with 0 errors, 0 fatals.
- Functional coverage: 80.56% overall — branch predictor 41.67%, cache 100%, PMP 100%.

**Static Timing Analysis**
- Ran with OpenSTA and Sky130 standard cells at a 20 ns clock constraint. The reported worst negative slack (WNS ≈ -284 ns) reflects this specific constraint and cell mapping, not yet re-optimized for maximum Fmax — noted as a known follow-up rather than finished timing closure.

**DFT — Scan Chain**

- Scan flip-flop (scan_dff.v, W=32 parameterized shift-register style) verified via scan_chain_tb.v.
- Result: Scan chain integrity PASS (32/32 bits match), confirmed in both terminal log and GTKWave waveform.

**Physical Verification**
- DRC (Magic): 0 violations.
- LVS (Netgen): clean, no net/device/pin mismatches.

**Physical Design**
- OpenLane2 interactive flow completed — synthesis, floorplan, placement, CTS, routing, GDSII — 0 DRC violations after detailed routing.

## Repository Structure

rtl/            - core Verilog design modules
  riscv_top.v, pc.v, register_file.v, alu.v, alu_control.v,
  control_unit.v, imm_gen.v, hazard_unit.v, forwarding_unit.v,
  instruction_memory.v, data_memory.v,
  adaptive_branch_predictor.v, pmp_unit.v, data_cache.v,
  scan_dff.v, riscv_top_tb.v

testbench/      - testbench source + verification result screenshots
  riscv_tb.v (source for simulation/riscv_wave.vcd)
  scan_chain_tb.v (source for scan chain PASS result)
  scan_chain_result.png, scan_chain_waveform.png
  functional_coverage_report.png
  uvm_gate_level_verification.png, uvm_gate_level_waveform.png

simulation/     - raw waveform dumps
  riscv_wave.vcd
  Combined_waveform_ABP_PMP_DC.png

output/         - synthesis, STA, physical design & sign-off deliverables
  synth.ys, netlist.v, program.hex
  logic_gates_count_table.png, sta_report.png
  openLane_run_log1.jpeg, openLane_run_log2.jpeg, physical_design_config.jpeg
  drc_lvs_report.png
  gds_layout.jpeg, gds_layout(clear).jpeg,
  gds_layout_overview_cells.jpeg, gds_layout_midzoom_layers.jpeg

## Author

**Monika P**
BTech VLSI Design Engineering, Presidency University, Bengaluru (Batch of 2027)
GitHub: https://github.com/Monika-25-web
LinkedIn: https://linkedin.com/in/monika-p-b5ba5b400
Email: monikapgowda11@gmail.com



