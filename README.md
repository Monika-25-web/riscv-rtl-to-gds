riscv-rtl-to-gds
5-stage Pipelined RV32I RISC-V Processor with Adaptive Branch Predictor, PMP Security Monitor and Data Cache | RTL to GDS | Sky130 130nm | OpenLane2
# RISC-V RV32I 5-Stage Pipelined Processor
**Adaptive Branch Predictor • PMP Security Unit • Direct-Mapped Data Cache**
A working 5-stage pipelined RV32I RISC-V core with hazard detection and forwarding, extended with three self-contained enhancement modules — each verified independently and together through simulation, with synthesis results quantifying their exact silicon cost.

- ✅ Full 5-stage pipeline: IF → ID → EX → MEM → WB
- ✅ Hazard detection + forwarding unit
- ✅ **Adaptive branch predictor** — dynamically switches between 1-bit and 2-bit predictors
- ✅ **PMP (Physical Memory Protection) security unit** — flags and counts unauthorized memory access
- ✅ **Direct-mapped data cache** — with hit/miss tracking
- ✅ Synthesized in Yosys — measured **+11.8% cell overhead** for all three features combined
- ✅ Verified in GTKWave with waveform captures for every module

# Waveform Results

| 1 | [Baseline Fetch](waveform1_baseline_fetch.png.jpeg)
| 2 | [Branch Predictor](docs/images/waveform2_branch_predictor.png.jpeg)
| 3 | [PMP Violation](docs/images/waveform3_pmp_violation.png.jpeg)
| 4 | [Cache Hit/Miss](docs/images/waveform4_cache.png.jpeg)
| 5 | [All Modules](docs/images/waveform5_all_modules.png.jpeg)

#  Logic Gate Count (Yosys Synthesis)
 Baseline = 11 core modules. Enhanced = baseline + `adaptive_branch_predictor.v` + `pmp_unit.v` + `data_cache.v`.
[Logic Gate Count Table](logic_gates_count_table.png.jpeg)

Summary:
- Total cells: 25,062 (baseline) → 28,007 (enhanced) → **+2,945 (+11.8%)**
- Flip-flops: 9,579 → 10,115 → **+536 (+5.6%)**


