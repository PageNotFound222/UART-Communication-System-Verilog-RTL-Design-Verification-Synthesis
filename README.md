# UART Communication System — Verilog RTL

A synthesizable **UART (Universal Asynchronous Receiver/Transmitter) communication system** designed from scratch using **Verilog RTL**.

The project focuses on understanding and implementing the complete RTL design flow of a UART, from baud-rate generation and finite-state-machine-based transmission/reception to simulation, waveform analysis, and logic synthesis.

> **Status:** 🚧 In Development

---

## Overview

UART is a simple asynchronous serial communication protocol commonly used for communication between microcontrollers, embedded systems, sensors, and other digital devices.

This project implements an **8N1 UART architecture**, consisting of:

- UART Transmitter (TX)
- UART Receiver (RX)
- Configurable baud-rate generator
- FSM-based control
- RX input synchronization
- Self-checking verification
- Simulation and waveform analysis
- RTL synthesis using Yosys

The final goal is to take the design from **Verilog RTL → simulation → synthesized gate-level netlist**.

---

## Current Progress

### Completed

- [x] Project structure
- [x] Parameterized baud-rate generator
- [x] Baud-rate counter
- [x] Synchronous reset handling
- [x] Baud tick generation
- [x] Initial simulation testbench

### In Progress

- [ ] UART transmitter
- [ ] UART TX verification
- [ ] UART receiver
- [ ] RX synchronizer
- [ ] RX verification
- [ ] TX ↔ RX loopback
- [ ] Self-checking testbench
- [ ] GTKWave waveform analysis
- [ ] Verilator verification
- [ ] Yosys synthesis
- [ ] Gate-level netlist analysis
- [ ] Final documentation

---

## UART Configuration

The initial implementation targets an **8N1 UART configuration**.

| Parameter | Value |
|---|---|
| Data bits | 8 |
| Parity | None |
| Stop bits | 1 |
| Data order | LSB first |
| Initial baud rate | 9600 baud |
| System clock | 50 MHz |

### UART Frame

```text
        START        DATA BITS                    STOP
          │       ┌───────────────┐                │
          ▼       ▼               ▼                ▼

Idle ──── 0 ──── D0 D1 D2 D
