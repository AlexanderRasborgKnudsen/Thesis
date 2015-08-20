clc; close all; clear all;
load adc1_10.txt
data=adc1_10(1:20000);
data=data';

SampleNo = 31744 ;
ts=linspace(0,SampleNo-1,SampleNo);

[Max_val,Index]=max(data);
expp=data(Index:end);
expp1=data(1:Index);
M=max(find(expp>=Max_val*0.3678));
M1=max(find(expp1>=Max_val*0.6322));

figure(1)
subplot(2,1,1) % first subplot
plot(data)

%filter parameters
%pulse period
Tpprd = 100;
%clock period [usec]
Tclk = 1./50;
Tclkn = Tclk*1e-6;
%high pass filter differentiation constant

Taupk = 3;
Taupk_top = 50;
% val1=1/M;
% val2=1/M1;
% a = exp(-val1);
% b = exp(-val2);
% na = (Taupk/Tclk);
% nad = na-3;
% nb = (Taupk_top+Taupk)/Tclk;
% nbd = nb-3;
% z = tf('z', Tclk);
% % Trapezoidal filter Z-transfer function
% A=(1-(b*(z^-1)));
% B=(1-(a*(z^-1)));
% C=( (1-z^-na)/(1-z^-1));
% D=( (1-z^-nb)/(1-z^-1));
% E=z^-1/na;
% F=(a-a*b)*(z^-2);
% hz1=A*B*C*D*E*F;


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
