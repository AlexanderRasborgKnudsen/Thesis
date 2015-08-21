clc; close all; clear all;
load TPE_9_3.txt
Dat = TPE_9_3;
Dat = padarray(Dat,10000,1900);
Dat = Dat - 1900;

%filter parameters
%clock period [usec]
tclk = 70;
%high pass filter differentiation constant
taud = 40;
taupk = 20;
taupk_top = 40;

[outp,M,val,z] = F_trapz_filter_digital_1(Dat,tclk,taud,taupk,taupk_top);

figure(1)

%subplot(2,1,1) % first subplot
plot(Dat)
hold on
%subplot(2,1,2) % second subplot
plot(outp)
title('TPE_5_2')
xlabel('Time')
ylabel('Voltage')