<div align="center">

# 🚀 Synthesizable UART Core (50 MHz, 8N1)

[![Verilog](https://img.shields.io/badge/Language-Verilog_HDL-blue.svg)](https://en.wikipedia.org/wiki/Verilog)
[![EDA](https://img.shields.io/badge/Simulation-QuestaSim-orange.svg)]()
[![Status](https://img.shields.io/badge/Design_Status-Verified_✓-brightgreen.svg)]()
[![Protocol](https://img.shields.io/badge/UART-8N1_16x_Oversampling-red.svg)]()

A modular, hardware-tested **UART Core (TX/RX/Baud Generator)** built with synthesizable Verilog and verified with an exhaustive self-checking testbench.

---

### 📌 Architecture Overview
<img src="docs/uart_arch.jpg" alt="UART Architecture" width="850"/>

</div>

---

## ⚡ Key Highlights & Specs

| Feature | Specification | Description |
| :--- | :--- | :--- |
| **System Clock** | `50 MHz` | Base system frequency |
| **Data Frame** | `8N1` | 1 Start bit, 8 Data bits, No parity, 1 Stop bit |
| **Oversampling**| `16x` | 16 sample ticks per bit for robust noise rejection & mid-bit capture |
| **Architecture**| Modular FSM | Independent TX & RX state machines (`IDLE`, `START`, `DATA`, `STOP`) |
| **Verification**| Self-Checking TB | Automated checks with zero-assertion tolerance |

---

## 🔄 Dataflow & Modular Structure

```mermaid
flowchart LR
    %% Styles
    classDef clk fill:#2d3748,stroke:#cbd5e0,stroke-width:1px,color:#fff;
    classDef core fill:#1a365d,stroke:#3182ce,stroke-width:2px,color:#fff;
    classDef port fill:#276749,stroke:#48bb78,stroke-width:1px,color:#fff;

    CLK["clk (50MHz) / rst_n"]:::clk --> BG["Baud Generator"]:::core
    
    BG -- "s_tick (16x)" --> TX["UART TX<br/>(Transmitter)"]:::core
    BG -- "s_tick (16x)" --> RX["UART RX<br/>(Receiver)"]:::core

    TX_IN["tx_start<br/>tx_data[7:0]"]:::port --> TX
    TX -- "tx_done" --> DONE1["tx_done"]:::port
    
    TX -. "tx_out (Loopback)" .-> RX
    
    RX -- "rx_data[7:0]" --> DATA_OUT["rx_data[7:0]"]:::port
    RX -- "rx_done" --> DONE2["rx_done"]:::port
```

---

## 🧪 Verification & Simulation Results

The core was validated using **QuestaSim** via directed test cases covering reset assertion, frame synchronization, and **back-to-back concurrent transmission** using non-blocking TB threads (`fork ... join`).

<div align="center">
  <img src="docs/All.png" alt="Simulation Results" width="900"/>
</div>

```text
[40 ns]       : Reset Verification -> PASSED ✓
[988050 ns]   : Single Byte Loopback -> PASSED ✓
[2028050 ns]  : Back-to-Back (Byte 1: 0x35) -> PASSED ✓
[3068050 ns]  : Back-to-Back (Byte 2: 0xFF) -> PASSED ✓
======================================================
>> ALL TESTCASES COMPLETED SUCCESSFULLY [0 ERRORS] <<
```

---

## 📂 Project Structure

```bash
├── RTL/          # Synthesizable RTL source files (top, tx, rx, baud)
├── tb/           # Self-checking testbench (tb.v)
├── sim/          # QuestaSim / ModelSim execution script (run.do)
├── docs/         # Architectural diagrams & simulation wave captures
└── README.md     # Project documentation
```
