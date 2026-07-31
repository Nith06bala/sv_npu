`include "pe_f.sv"
typedef enum logic[1:0]{rst_lay,l1}layers;
typedef enum logic[2:0]{rst_op,conv,max_pool}op;
typedef enum logic[2:0]{rst_subop,al,wl,mac}subop;
module pec_f(rst,start,clk,cu_lay,cu_op,cu_subop,al_done,wl_done,max_pool_done,mac_done,stop);
  input logic clk;

layers nxt_lay;
  output layers cu_lay;

op nxt_op;
 output op cu_op;

subop nxt_subop;
  output subop cu_subop;
logic [7:0]cnt,al_store_cnt,wl_store_cnt;
logic [7:0]data[32:0];
integer al_start,wl_start,al_stop,wl_stop;
logic wl_en,rd_en;
output logic wl_done,al_done,stop;
  logic stop1;
input logic start,rst;
logic [7:0]al_store[75:0];
logic [7:0]wl_store[8:0];
logic st,mode,start1a,start1b,start1c,start2a,start2b,start2c;
  output logic mac_done;//mac_operation
logic [7:0]al_store0,al_store1,al_store2,wl_pe0,wl_pe1,wl_pe2,al_pe0,al_max1,al_max2,al_max3;
logic [15:0]res0,res1,res2;
output logic max_pool_done;
logic [15:0]weight1,activation1,weight2,activation2,weight0,activation0;
pe_f pe0(.wt(weight0),.ac(activation0),.res(res0),.mode(mode),.st(st),.start1(start1a),.start2(start2a),.clk(clk));
pe_f pe1(.wt(weight1),.ac(activation1),.res(res1),.mode(mode),.st(st),.start1(start1b),.start2(start2b),.clk(clk));
pe_f pe2(.wt(weight2),.ac(activation2),.res(res2),.mode(mode),.st(st),.start1(start1c),.start2(start2c),.clk(clk));

always_ff@(posedge clk or posedge rst)begin
if(rst)begin
cu_lay<=rst_lay;
cu_op<=rst_op;
cu_subop<=rst_subop;
cnt<=7'd0;
al_store_cnt<=7'd0;
wl_store_cnt<=7'd0;

  al_done<=1'b0;
  wl_done<=1'b0;
  stop<=1'b0;
end
else begin
cu_lay<=nxt_lay;
cu_op<=nxt_op;
cu_subop<=nxt_subop;
end
  
  if(cu_lay==l1 && cu_op==conv && cu_subop==al)begin


if(cnt == al_stop)begin 
al_done<=1'b1;
al_store_cnt<=al_store_cnt;

end
else if(cnt != al_stop) begin
cnt<=cnt+1'b1;
al_store_cnt<=al_store_cnt+1'b1;

end
else if(cnt == al_stop+1'b1)begin 
cnt<=wl_start;
end
end
else if (cu_lay==l1 && cu_op==conv && cu_subop==wl)begin

if(cnt==al_stop)begin
cnt<=wl_start;
wl_store_cnt<=wl_store_cnt;
end

else if(cnt == wl_stop)begin 
wl_done<=1'b1;
st<=1'b1;
wl_store_cnt<=wl_store_cnt;
end

else if(cnt != wl_stop && cnt!=al_stop)begin 
cnt<=cnt+1'b1;
wl_store_cnt<=wl_store_cnt+1'b1;
end

end


else if (cu_lay==l1 && cu_op==conv && cu_subop==mac)begin


if(st==1'b1 && mac_done!=1'b1)begin
st<=1'b0;
wl_pe0<=7'd0;
wl_pe1<=7'd3;
wl_pe2<=7'd6;
al_pe0<=7'd0;
al_store0<=7'd25;
al_store1<=7'd39;
al_store2<=7'd53;
mode<=1'b1;
end

else  begin
st<=st;
wl_pe0<=wl_pe0+1'b1;
wl_pe1<=wl_pe1+1'b1;
wl_pe2<=wl_pe2+1'b1;
al_pe0<=al_pe0+1'b1;

if(al_pe0==7'd16) begin
 mac_done<=1'b1;
st<=1'b1;
end
else mac_done=1'b0;

if(start1a==1'b1 && start1b==1'b1 && start1c==1'b1)begin
al_store0<=al_store0+1'b1;
al_store1<=al_store1+1'b1;
al_store2<=al_store2+1'b1;
end

end
end

else if (cu_lay==l1 && cu_op==max_pool)begin

if(st==1'b1)begin
st<=1'b0;
wl_pe0<=8'd25;
wl_pe1<=8'd39;
wl_pe2<=8'd53;
al_store0<=7'd26;
al_store1<=7'd40;
al_store2<=7'd54;
mode<=1'b0;
al_max1<=8'd25;
al_max2<=8'd39;
al_max3<=8'd53;
end

else begin
st<=st;
wl_pe0<=wl_pe0+2'b10;
wl_pe1<=wl_pe1+2'b10;
wl_pe2<=wl_pe2+2'b10;
al_store0<=al_store0+2'b10;
al_store1<=al_store1+2'b10;
al_store2<=al_store2+2'b10;
al_max1<=al_max1+1'b1;
al_max2<=al_max2+1'b1;
al_max3<=al_max3+1'b1;

if(wl_pe0==7'd37 && wl_pe1==7'd51  && wl_pe2==8'd65 && al_store0==8'd38 && al_store1==8'd52 && al_store2==8'd66 )max_pool_done=1'b1;
else max_pool_done=1'b0;

end
end 
 
  if(start1a==1'b1 && start1b==1'b1 && start1c==1'b1 && mac_done==1'b0 && cu_op==conv)begin
al_store[al_store0]<=res0;
al_store[al_store1]<=res1;
al_store[al_store2]<=res2;
end

if(st==1'b0 && max_pool_done==1'b0 && cu_op==max_pool)begin
al_store[al_max1]<=res0;
al_store[al_max2]<=res1;
al_store[al_max3]<=res2;
end
  
  if(rd_en)begin
if(wl_en==1'b0) begin 
al_store[al_store_cnt]<=data[cnt];

end
else wl_store[wl_store_cnt]<=data[cnt];

end
  
if(stop1==1'b1)stop<=1'b1;
else stop<=1'b0;
end
always_comb begin
case(cu_lay)
rst_lay:begin
if(start)nxt_lay=l1;
else nxt_lay=rst_lay;
end
l1:begin
case(cu_op)
rst_op:nxt_op=conv;
conv:begin
case(cu_subop)
rst_subop:nxt_subop=al;

al: begin
al_start=7'd0;
al_stop=7'd15;
wl_en=1'b0;
rd_en=1'b1;


if(al_done==1'b1)begin
nxt_subop=wl;
end
else begin
nxt_subop=al;
end
end

wl: begin
wl_start=7'd16;
wl_stop=7'd24;
wl_en=1'b1;
rd_en=1'b1;
if(wl_done==1'b1)begin
nxt_subop=mac;
end
else begin
nxt_subop=wl;
end
end

mac:begin


if(mac_done==1'b1)
nxt_op=max_pool;
else
nxt_subop=mac;
end

default:nxt_subop=rst_subop;
endcase

end
max_pool:begin
if(max_pool_done==1'b1)stop1=1'b1;
else nxt_op=max_pool;

end
default:nxt_op=rst_op;
endcase
end
endcase
end

always_ff@(posedge clk)begin
//al_store[0:15]
data[0]  = 8'd0;
data[1]  = 8'd1;
data[2]  = 8'd2;
data[3]  = 8'd3;
data[4]  = 8'd4;
data[5]  = 8'd5;
data[6]  = 8'd6;
data[7]  = 8'd7;
data[8]  = 8'd8;
data[9]  = 8'd9;
data[10] = 8'd10;
data[11] = 8'd11;
data[12] = 8'd12;
data[13] = 8'd13;
data[14] = 8'd14;
data[15] = 8'd15;

// wl_store[0:8]
data[16] = 8'd0;
data[17] = 8'd1;
data[18] = 8'd2;
data[19] = 8'd3;
data[20] = 8'd4;
data[21] = 8'd5;
data[22] = 8'd6;
data[23] = 8'd7;
data[24] = 8'd8;

end



always_comb begin
case(cu_op)
conv:begin
weight0={8'b0,(wl_store[wl_pe0])};
weight1={8'b0,(wl_store[wl_pe1])};
weight2={8'b0,(wl_store[wl_pe2])};
activation0={8'b0,(al_store[al_pe0])};
activation1={8'b0,(al_store[al_pe0])};
activation2={8'b0,(al_store[al_pe0])};
end

max_pool:begin
activation0=al_store[al_store0];
activation1=al_store[al_store1];
activation2=al_store[al_store2];
weight0=al_store[wl_pe0];  
weight1=al_store[wl_pe1];
weight2=al_store[wl_pe2];
end
endcase

end

endmodule
