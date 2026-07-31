 module tb;
        logic clk;
        always #5 clk=~clk;
        pec_f_inf vif(clk);
        pec_f dut(
          .rst(vif.rst),
          .start(vif.start),
          .clk(vif.clk),
          .cu_lay(vif.cu_lay),
          .cu_op(vif.cu_op),
          .cu_subop(vif.cu_subop),
          .al_done(vif.al_done),
          .wl_done(vif.wl_done),
          .max_pool_done(vif.max_pool_done),
          .mac_done(vif.mac_done),
           .stop(vif.stop)
        );
        initial begin
          clk=1'b0;
          vif.rst=1;
          vif.start=0;
          repeat(2) begin
          @(posedge clk);
          end
          vif.start=1;
          repeat(2) begin
          @(posedge clk);
          end
          vif.rst=0;
          repeat(63) begin
          @(posedge clk);
          end
          $finish;
        end
        sva sva1(vif);
         always @(posedge clk)
           $display("rst %b start %b cu_lay %b cu_op %b cu_subop %b al_done %b wl_done %b mac_done %b stop %b time %t",vif.rst,vif.start,vif.cu_lay,vif.cu_op,vif.cu_subop,vif.al_done,vif.wl_done,vif.mac_done,vif.stop,$time);
    fc fc1(vif);
    
      endmodule
