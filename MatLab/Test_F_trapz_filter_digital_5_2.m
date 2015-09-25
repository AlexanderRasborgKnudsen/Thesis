clc; close all; clear all;
load TPE_38_1_mod.txt
Dat = TPE_38_1_mod;
%Dat = padarray(Dat,10000,1900);
Dat = Dat - 1700;

 windowSize = 200;
b = (1/windowSize)*ones(1,windowSize);
a = 1;
y1 = filter(b,a,Dat);
Data=y1;



%filter parameters
%clock period [usec]
tclk = 10;
%high pass filter differentiation constant
taupk = 10;
taupk_top = 30;
M = 4.192522265764161e-04;
na = 100;
nb = 400;
b10 = -0.999580835647357;

[outp] = F_trapz_filter_digital_1(Data,na,nb,b10);

figure(2)

%subplot(2,1,1) % first subplot
plot(Data)
hold on
%subplot(2,1,2) % second subplot
diff_output = diff(outp);
plot(diff_output)
plot(outp)
title('TPE_5_2')
xlabel('Time')
ylabel('Voltage')