interface pec_f_inf(input logic clk);
logic rst;
logic start;
logic [1:0]cu_lay;
logic [2:0]cu_op,cu_subop;
logic al_done,wl_done,max_pool_done,mac_done; 
  logic stop;
endinterface

module sva(pec_f_inf vif);
  property reset;
    @(posedge vif.clk)
    vif.rst |-> (vif.cu_lay==rst_lay) && (vif.cu_op==rst_op) && (vif.cu_subop==rst_subop);
  endproperty
  
  sequence stat1;
    vif.rst ##1 !vif.rst & vif.start;
  endsequence
  
  sequence stat2;
    (vif.cu_lay==l1) ##1 (vif.cu_op==rst_op) ##1 (vif.cu_subop==conv) ##1 (vif.cu_subop==rst_subop);
  endsequence
  
  
  property stat;
    @(posedge vif.clk)
    stat1 |=> vif.cu_lay==l1;
  endproperty
  
    property initialising_al;
       @(posedge vif.clk)
    stat2 |=>(vif.cu_subop==al);
  endproperty
  
  property aldone;
      @(posedge vif.clk)
    (vif.cu_subop==al) |-> ##16 vif.al_done;
  endproperty
  
      property initialising_wl;
       @(posedge vif.clk)
         $rose(vif.al_done) |=> (vif.cu_subop == wl);
  endproperty
  
  property wldone;
      @(posedge vif.clk)
    (vif.cu_subop==wl) |-> ##10 vif.wl_done;
  endproperty
  
        property initialising_mac;
       @(posedge vif.clk)
          $rose(vif.wl_done) |=> (vif.cu_subop == mac);
  endproperty
  
    property macdone;
      @(posedge vif.clk)
      (vif.cu_subop==mac) |-> (##19 vif.mac_done |=> !vif.mac_done);
  endproperty
  
   property initialising_maxpool;
       @(posedge vif.clk)
     $rose(vif.mac_done) |=> (vif.cu_op == max_pool);
  endproperty
  
     property maxpool_done;
       @(posedge vif.clk)
       $rose(vif.mac_done) |-> ##9 vif.max_pool_done;
  endproperty
  
  property stop_done;
           @(posedge vif.clk)
    $rose(vif.max_pool_done) |=>  vif.stop;
  endproperty
  
  assert property(reset)
    else
      $error("reset operation failed");
    
    assert property(stat)
    else
      $error("stat operation failed");  
      
    assert property(initialising_al)
    else
      $error("initialising_al operation failed");
      
      assert property(aldone)
    else
      $error("aldone operation failed");
        
        assert property(initialising_wl)
    else
      $error("initialising_wl operation failed");
      
          assert property(wldone)
    else
      $error("wldone operation failed");
      
      
            
            assert property(initialising_mac)
    else
      $error("initialising_mac operation failed");
      
              assert property(macdone)
    else
      $error("macdone operation failed");
      
      
                
    assert property(initialising_maxpool)
    else
      $error("initialising_maxpool operation failed");
      
              assert property(maxpool_done)
    else
      $error("maxpool_done operation failed");
                
                assert property (stop_done)
                      else
                        $error("stop_done operation failed");
      
      endmodule
            
            module fc(pec_f_inf vif);
              
covergroup cg @(posedge vif.clk);
cp_rst: coverpoint vif.rst;
cp_start: coverpoint vif.start;
   cp_cu_lay: coverpoint vif.cu_lay{
    bins rst_lay1 ={rst_lay};
    bins l1_cp={l1};
    bins rst1_path=(rst_lay => l1);
  }
 cp_cu_op: coverpoint vif.cu_op{
    bins rst_op1={rst_op};
    bins conv_cp={conv};
    bins max_pool_cp={max_pool};
    bins rst2_path=(rst_op => conv);
    bins conv_path=(conv => max_pool);
    
  }
   cp_cu_subop: coverpoint vif.cu_subop{
    bins rst_subop1={rst_subop};
    bins al_cp={al};
    bins wl_cp={wl};
    bins mac_cp={mac};
    bins rst3_path=(rst_subop => al);
    bins al_path=(al => wl);
    bins wl_path=(wl => mac);
  }

cp_al_done: coverpoint vif.al_done;
cp_wl_done  : coverpoint vif.wl_done;
cp_max_pool_done   : coverpoint vif.max_pool_done;
cp_mac_done  : coverpoint vif.mac_done; 
cp_stop : coverpoint vif.stop;               
endgroup
              cg cg1;
              initial begin
                cg1=new();
              end
              final begin
    $display("Coverage = %0.2f%%", cg1.get_inst_coverage());
end

              
            endmodule
      
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
