function [xf1,val,hznumA, hzdenA,hznumB, hzdenB,hznumC, hzdenC,hznumD, hzdenD] = F_trapz_filter_digital_1(Dat,tclk,M,taupk,taupk_top)
data=Dat';

[Max_val,Index]=max(data);
expp=data(Index:end);
%M=max(find(expp>=Max_val*0.3678));



%% filter parameters

%clock period [usec]
Tclk = 1./tclk;
%Tclkn = Tclk*1e-6;
%high pass filter differentiation constant
%Taud = taud;
Taupk = taupk;
Taupk_top = taupk_top;
%val=Tclk/Taud;
T_decay = -242.7;
%val = 1/M;
val=M;
%b10 = exp(-1/T_decay);
b10 = exp(-val);
na = (Taupk/Tclk);
%nad = na-3;
nb = (Taupk_top+Taupk)/Tclk;
%nbd = nb-3;
z = tf('z', Tclk);
% Trapezoidal filter Z-transfer function
A=(1-b10*z^-1);
B=( (1-z^-na)/(1-z^-1));
C=( (1-z^-nb)/(1-z^-1));
D=z^-1/na;
hz1=A*B*C*D;
%[hznum1, hzden1, ~] = tfdata(hz1,'v');
[hznumA, hzdenA, ~] = tfdata(A,'v');
[hznumB, hzdenB, ~] = tfdata(B,'v');
[hznumC, hzdenC, ~] = tfdata(C,'v');
[hznumD, hzdenD, ~] = tfdata(D,'v');
xfA=filter(hznumA,hzdenA,data);
xfB=filter(hznumB,hzdenB,xfA);
xfC=filter(hznumC,hzdenC,xfB);
xf1=filter(hznumD,hzdenD,xfC);

end

