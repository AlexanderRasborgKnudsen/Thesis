clc; close all; clear all;
load TPE_9_3.txt
Dat = TPE_9_3;
%Dat = padarray(Dat,10000,1900);
Dat = Dat - 1900;

 windowSize = 200;
b = (1/windowSize)*ones(1,windowSize);
a = 1;
y1 = filter(b,a,Dat);
Data=y1;

Data_fit = Data(340:end);
Data_t = linspace(0,0.01,size(Data_fit,1))';
f2 = fit(Data_t,Data_fit,'exp1')
figure(1)
plot(f2,Data_t,Data_fit);

%filter parameters
%clock period [usec]
tclk = 70;
%high pass filter differentiation constant
taud = 40;
taupk = 20;
taupk_top = 40;

[outp,M,val,z] = F_trapz_filter_digital_1(Data,tclk,taud,taupk,taupk_top);

figure(2)

%subplot(2,1,1) % first subplot
plot(Data)
hold on
%subplot(2,1,2) % second subplot
plot(outp)
title('TPE_5_2')
xlabel('Time')
ylabel('Voltage')