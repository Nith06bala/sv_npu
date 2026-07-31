module pe_f(wt,ac,res,mode,st,start1,start2,clk);
input logic clk;
input logic st;
input logic mode;
input logic [15:0]wt,ac;
logic [7:0]counter;
logic [15:0]w0,w1,w2,a0,a1,a2;
output logic [15:0]res;
logic [15:0]k1,k2,k3;
output logic start2,start1;
always_ff@(posedge clk or posedge st)begin
if(st==1'b1)begin
counter=7'b0;
w0=16'b0;
w1=16'b0;
w2=16'b0;
a0=16'b0;
a1=16'b0;
a2=16'b0;
end
else counter<=counter+1'b1;

if(start1==1'b0 && mode==1'b1 && st!=1'b1)begin
w0<=wt;
w1<=w0;
w2<=w1;
a0<=ac;
a1<=a0;
a2<=a1;
end
else if(start1==1'b1 && mode==1'b1 && st!=1'b1) begin
a0<=ac;
a1<=a0;
a2<=a1;
end

if(mode==1'b0 && st!=1'b1)begin
a0<=wt;
a1<=ac;
end
end

always_comb begin

if(mode==1'b1)begin
if(counter<7'd3)start1=1'b0;
else start1=1'b1;
end

else begin
if(counter<7'd2)start2=1'b0;
else start2=1'b1;
end

end

always_comb begin
if(start1==1'b1)begin
if(a0==16'b0 || w0==16'b0)
k1=16'b0;
else k1=a0*w0;

if(a1==16'b0 || w1==16'b0)
k2=16'b0;
else k2=a1*w1;

if(a2==16'b0 || w2==16'b0)
k3=16'b0;
else k3=a2*w2;


res=k1+k2+k3;

end
else if(mode==1'b0)begin
res=(a1>=a0)?a1:a0;
end
end


endmodule
