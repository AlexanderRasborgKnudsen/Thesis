clear all;clc;
close all;
load adc1_10.txt
load adc1_11.txt
load adc1_12.txt
load adc1_13.txt
load adc1_14.txt
load adc1_15.txt
load adc1_16.txt
load adc1_17.txt
data=adc1_10;
% figure,plot(data)
% title('Signal input') 

 %Moving Average Filter
 windowSize = 6;
b = (1/windowSize)*ones(1,windowSize);
a = 3;
filtered_signal = filter(b,a,data);
figure,plot(filtered_signal);
title('Pulse after the Moving Average Filter ')
xlabel('Time')
ylabel('Voltage')





% Timing filter
T=5e-8; % Sampling Interval
tau = 5e-6; % Time Constant
t=4*tau;
a=1/tau;
alpha=exp(-T/tau);
%syms z;
z = tf('z', T);
% CR-RC Z-transfer function
hz1 =(z^2-(z*alpha*(1+a*T)))/((z-alpha)^2);
[hznum1, hzden1, Ts1] = tfdata(hz1,'v');
% CR-RC^2 Z-transfer function
hz2 =(z^2*alpha*T*(2-(a*T))-(z*T*alpha^2*(2+a*T)))/(2*(z-alpha)^3);
[hznum2, hzden2, Ts2] = tfdata(hz2,'v');
% CR-RC^3 Z-transfer function
hz3 =(z^3*alpha*T^2*(3-(a*T))-(4*a*z^2*T^3*alpha^2)-(z*T^2*alpha^3*(3+a*T)))/(6*(z-alpha)^4);
[hznum3, hzden3, Ts3] = tfdata(hz3,'v');
% CR-RC^4 Z-transfer function
hz4 = (z^4*alpha*T^3*(4-(a*T)) + z^3*alpha^2*T^3*(12-11*a*T) +...
z^2*alpha^3*T^3*(-12-11*a*T) + z*alpha^4*T^3*(-4-a*T)) / (24*(z-alpha)^...
5); 
[hznum4, hzden4, Ts4] = tfdata(hz4,'v');
[H,W] = freqz(hznum4,hzden4);
% Baseline correction for data
% sz = size(data,1);
% pct = .25;
% psz = round(pct*sz);
% baselinemode = mode(data(psz,1));
% data2 = data - baselinemode;
sz = size(filtered_signal,1);
pct = .25;
psz = round(pct*sz);
baselinemode = mode(filtered_signal(psz,1));
data2 = filtered_signal - baselinemode;
% Filter for signal of n=1...4 (when higher order then more computations)
xf1=filter(hznum1,hzden1,data2);
% figure,plot(xf1)
% title('Signal filtered with CR-RC filter ')
xf2=filter(hznum2,hzden2,data2);
% figure,plot(xf2)
% title('Signal filtered with CR-RC^2 filter ')
xf3=filter(hznum3,hzden3,data2);
% figure,plot(xf3)
% title('Signal filtered with CR-RC^3 filter ')
xf4=filter(hznum4,hzden4,data2);
% figure,plot(xf4)
% title('Signal filtered with CR-RC^4 filter ')

% Zero crossings of a vector or a matrix, with hysteresis
% thresholds.
MIN1=-0.25e4; % Minimum thresholds for CR-RC filter
MAX1=0.25e4;  % Maximum thresholds for CR-RC filter
MIN2=-0.1e-1; % Minimum thresholds for CR-RC^2 filter
MAX2=0.1e-1;  % Maximum thresholds for CR-RC^2 filter
MIN3=-0.5e-7; % Minimum thresholds for CR-RC^3 filter
MAX3=0.5e-7;  % Maximum thresholds for CR-RC^3 filter
MIN4=-3e-13; % Minimum thresholds for CR-RC^4 filter
MAX4=3e-13;  % Maximum thresholds for CR-RC^4 filter

plot(2)
subplot(2, 3, [1, 2]) % first subplot
plot(data,'r')
title('Signal input')
xlabel('Time')
ylabel('Voltage')

ZC1 = Zcrossfunction(xf1, MIN1, MAX1,-1,3);
%subplot(2,2,2) % first subplot
ZC2 = Zcrossfunction(xf2, MIN2, MAX2,-1,4);
%subplot(2,2,3) % first subplot
ZC3 = Zcrossfunction(xf3, MIN3, MAX3,-1,5);
%subplot(2,2,4) % first subplot
ZC4 = Zcrossfunction(xf4, MIN4, MAX4,-1,6);
% Find the points crossing thresholds
[X1_pos1,Y1_pos]=find(ZC1==1);
[X2_pos2,Y2_pos]=find(ZC2==1);
[X3_pos,Y3_pos]=find(ZC3==1);
[X4_pos,Y4_pos]=find(ZC4==1);




% ZC(ZC==0) = -1; 
%  stairs(ZC);
% zeroNb=0;
% for i=1:length(x)-1 %length : get x size
% if ((x(i)>=0 && x(i+1)<0) || (x(i)<=0 && x(i+1)>0))
%     %if(x(i+10)>=0 || (x(i+10)<=0))
%     %if((x(i+20)<=0))
% zeroNb=1+zeroNb;
%     %end
% end
% end