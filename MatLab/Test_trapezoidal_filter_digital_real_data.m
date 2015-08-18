clc; close all; clear all;
load TPE_5_2.txt
data=TPE_5_2;
data=data';

SampleNo = 9000 ;
ts=linspace(0,SampleNo-1,SampleNo);

[Max_val,Index]=max(data);
expp=data(Index:end);
M=max(find(expp>=Max_val*0.3678));

figure(1)
subplot(2,1,1) % first subplot
plot(data)

%filter parameters
%pulse period
Tpprd = 0.1;
%clock period [usec]
Tclk = 1./125;
Tclkn = Tclk*1e-6;
%high pass filter differentiation constant
Taud = 3.5;
Taupk = 0.01;
Taupk_top = 50;
%val=Tclk/Taud;
val=1/M;
b10 = exp(-val);
na = (Taupk/Tclk);
nad = na-3;
nb = (Taupk_top+Taupk)/Tclk;
nbd = nb-3;
z = tf('z', Tclk);
% Trapezoidal filter Z-transfer function
A=(1-b10*z^-1);
B=( (1-z^-na)/(1-z^-1));
AB=A*B;
C=( (1-z^-nb)/(1-z^-1));
ABC=A*B*C;
D=z^-1/na;
hz1=A*B*C*D;
[hznum1, hzden1, Ts1] = tfdata(hz1,'v');

xf1=filter(hznum1,hzden1,data);
subplot(2,1,2) % second subplot
plot(xf1)
