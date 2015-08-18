clc; close all; clear all;
%load Data
load TPE_5_2_mod.txt
data=TPE_5_2_mod;
data=data';

grid on
figure(1)
subplot(2,1,1)
plot(data)
title('Signal Input');
grid on
%filter parameters
%pulse period
Tpprd = 0.1;
%clock period [usec]
Tclk = 1./70;
Tclkn = Tclk*1e-6;
%high pass filter differentiation constant
Taud = 49;
Taupk = 40;
Taupk_top = 60;
b10 = exp(-Tclk/Taud);
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
subplot(2,1,2)
    plot(xf1)
  title('Signal after Trapezoidal filter');
  grid on

