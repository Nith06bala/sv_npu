# INT8 Neural Processing Unit (1-D CNN)

A small neural processing unit in SystemVerilog that runs one convolutional layer of a 1-D CNN. It takes INT8 activations and weights, accumulates in 16 bits, and finishes each result with ReLU and max-pooling. Control is a three-level FSM, and the design uses three processing elements, one per filter.

I built it to study how a CNN accelerator moves data cycle by cycle: how the control FSM sequences loading, computing and pooling, and how weight reuse and zero-skipping cut memory traffic and switching activity.

## What it does

- Network: 1 convolution layer, 3 filters, kernel size 3, stride 1
- Inputs: 16 activations and 9 weights (3 per filter)
- Precision: INT8 for activations and weights, INT16 for accumulation
- Processing elements: 3, running in parallel, one filter each

## How the control works

The FSM has three levels. The top level picks the layer, the middle level picks the operation, and the bottom level picks what is happening right now.


layer          rst_lay   ->  l1
operation      rst_op    ->  conv   ->  max_pool
sub-operation  rst_subop ->  al  ->  wl  ->  mac


al loads activations, wl loads weights, and mac does the multiply-accumulate. While reset is asserted, all three levels sit in their reset states. When reset is released and start goes high, the NPU begins. When pooling is done, it raises stop.

## How the compute works

**Weights stay put.** In the mac step, each PE gets the weights of its own filter. Activations are loaded over the first three clock cycles. After that, the weights are held fixed and the activations slide through one position at a time with a window of three. Each activation is loaded once and reused across the window, instead of being fetched again for every output.

**Zero-skipping.** Each PE checks its two inputs before multiplying. If the weight or the activation is zero, the multiplication is skipped and the PE returns zero directly. This saves switching activity and power when the data is sparse, which is common after ReLU.

**ReLU and max-pool in one stage.** In max_pool, two successive MAC outputs are compared after ReLU and the larger one is written back to the memory location that held the MAC result. No separate storage is needed for the pooled output.

## Verification

I checked the design with SystemVerilog Assertions and simulation, and reached **100% functional coverage**. 

## Limitations

This is a functional and timing model, built to study FSM control and cycle-accurate data movement. It has not been trained, and it has not been tested against real AI data. It is not benchmarked for classification accuracy.

---

Nithish Kanna B 
