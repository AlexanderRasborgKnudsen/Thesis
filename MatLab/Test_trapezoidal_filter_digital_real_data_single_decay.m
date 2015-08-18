clc; close all; clear all;
SampleNo = 3000 ;
LoopNumber =100 ;
t=linspace(0,LoopNumber-1,LoopNumber);
ts=linspace(0,SampleNo-1,SampleNo);

z1=1000;
t1=1000;

spacing=1000;
 
dz1=zeros(1,z1);
dz2=zeros(1,(spacing-1000));
dz3=zeros(1,(spacing-1000));

Decay_T=100;

M= Decay_T - 0.5 ;

d_rise = [1 2 3 4 5 6];

signal = exp(-ts/Decay_T);  % single decaying pulse 
Falltime = falltime( signal,ts);
F = falltime(signal,'PercentReferenceLevels',[26.8 90]);

%fig=[ dz1 d_rise 16*signal(1:1000)];
% figure(3)
% plot(fig)
% title('Pulse with ramp and an exponential decay')
% xlabel('Time')
% ylabel('Voltage')
% ylim([0 17])
%d = [dz1 d_rise 16*signal(1:1000) dz2 d_rise 6*signal(1:1000) dz3 d_rise 8*signal(1:1000) dz3 d_rise 12*signal(1:1000)];% Amplitue of decay pulse
d = [dz1 d_rise 16*signal dz2];
%load adc1_10.txt
load TPE_5_2_mod.txt
data=TPE_5_2_mod;
data=data';
syms ts  tau
F = int((exp(-ts/Decay_T)).^2, ts, 0, Inf)



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
Tclk = 1./75;
Tclkn = Tclk*1e-6;
%high pass filter differentiation constant
Taud = 35;
Taupk = 30;
Taupk_top = 50;
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

