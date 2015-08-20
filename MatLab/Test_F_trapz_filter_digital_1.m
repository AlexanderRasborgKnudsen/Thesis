clc; close all; clear all;
load adc1_12.txt
Dat=adc1_12(1000:15000);
tclk = 50;
taupk = 11.1;
taupk_top = 11.1;

[outp,M,val,z] = F_trapz_filter_digital_1(Dat,tclk,taupk,taupk_top);

figure(1)
%subplot(2,1,1) % first subplot
plot(Dat')
hold on
%subplot(2,1,2) % second subplot
plot(outp)