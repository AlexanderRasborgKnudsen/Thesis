function [xf1,M,val,z] = F_trapz_filter_digital_1(Dat,tclk,taupk,taupk_top)
data=Dat;
data=data';

[Max_val,Index]=max(data);
expp=data(Index:end);
M=max(find(expp>=Max_val*0.3678));



%filter parameters
%pulse period
%Tpprd = 100;
%clock period [usec]
Tclk = 1./tclk;
%Tclkn = Tclk*1e-6;
%high pass filter differentiation constant
%Taud = 40;
Taupk = taupk;
Taupk_top = taupk_top;
%val=Tclk/Taud;
val=1/M;
b10 = exp(-val);
na = (Taupk/Tclk);
%nad = na-3;
nb = (Taupk_top+Taupk)/Tclk;
%nbd = nb-3;
z = tf('z', Tclk);
% Trapezoidal filter Z-transfer function
A=(1-b10*z^-1);
B=( (1-z^-na)/(1-z^-1));
%AB=A*B;
C=( (1-z^-nb)/(1-z^-1));
%ABC=A*B*C;
D=z^-1/na;
hz1=A*B*C*D;
[hznum1, hzden1, ~] = tfdata(hz1,'v');

xf1=filter(hznum1,hzden1,data);

end

