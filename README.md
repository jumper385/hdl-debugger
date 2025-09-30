# HDL Debugger

An RLE (Run-Length Encoding) based drop-in logic analyzer implemented in HDL.

## Features

- **RLE-based compression**: Efficiently captures and stores logic state changes using run-length encoding
- **High-speed sampling**: Samples digital signals at 100 MHz
- **Memory management**: Supports "run to memory full" operation mode
- **UART interface**: Communicates via 115200 baud UART
- **Keyboard control**: Can be controlled through keyboard commands via UART
- **Drop-in design**: Easy to integrate into existing HDL projects

## Communication

The logic analyzer communicates over UART at 115200 baud, allowing for real-time control and data retrieval. The UART interface supports keyboard-based commands for interactive operation.

## Architecture

The project includes:
- VHDL implementation of the core logic analyzer components
- UART communication modules for control and data transfer
- RLE sampling cells for efficient data compression
- Block RAM (BRAM) for sample storage
- Clock divider and debouncing circuits

## Usage

Configure the logic analyzer through UART commands and start sampling. The device will capture signal transitions and compress them using RLE encoding until memory is full or stopped by user command.