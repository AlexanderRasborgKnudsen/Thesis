clc; close all; clear all;
load TPE_5_2_g2.txt
Dat = TPE_5_2_g2;
Dat = padarray(Dat,10000,2300);
Dat = Dat - 2300;

%filter parameters
%clock period [usec]
tclk = 100;
%high pass filter differentiation constant
taud = 27;
taupk = 15;
taupk_top = 25;

[outp,M,val,z] = F_trapz_filter_digital_1(Dat,tclk,taud,taupk,taupk_top);

figure(1)

%subplot(2,1,1) % first subplot
plot(Dat')
hold on
%subplot(2,1,2) % second subplot
plot(outp)
title('TPE_5_2')
xlabel('Time')
ylabel('Voltage')