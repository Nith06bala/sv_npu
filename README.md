CNN-Based Neural Processing Unit (NPU)

Project Overview

This repository contains a Verilog implementation of a CNN-based Neural Processing Unit (NPU) capable of accelerating convolution operations using dedicated Processing Elements (PEs), local memories, and FSM-based control logic.

The architecture performs convolution using INT8 activations and weights with INT16 accumulation. Following the convolution stage, ReLU activation and Max Pooling are performed before storing the final output.

The NPU implements a 1D convolution engine with:

## Architecture Specifications

CNN Type  1D CNN 
Number of Layers  1 
Number of Filters  3 
Kernel Size  3 
Stride  1 
Activations  16 
Weights  9 (3 per filter) 
Processing Elements  3 
Activation Precision  INT8 
Weight Precision  INT8 
Accumulator Precision  INT16 
