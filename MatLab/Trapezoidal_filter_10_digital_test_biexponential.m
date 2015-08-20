clc; close all; clear all;

%Expresses the initial quantity
load adc1_10.txt
data=adc1_10(4001:18000);
data=0.1*data';
%save('dat.txt','data')


%Moving Average Filter
 windowSize = 10;
b = (1/windowSize)*ones(1,windowSize);
a = 1;
y1 = filter(b,a,data);
data=y1;
Signal=data;



SampleNo = 18000-4000 ;
ts=linspace(0,SampleNo-1,SampleNo);
%ts=ts';
%dlmwrite('y.txt',data')
%dlmwrite('ts.txt',ts')
%save('pqfile.txt','ts','data','-ascii')
%data=data';
%ts=ts';
[Max_val,Index]=max(data);
expp=data(Index:end);
expp1=data(1:Index);
ts1=ts(Index:end);
T_decay=abs((-(ts1)/log(expp)));
T_decay_cal=(max(find(expp>=Max_val*0.3678))-2);
%T_rise_cal=max(find(expp1>=Max_val*0.6322));
%T_rise=-ts/(log((exp(-ts/T_decay)-Signal)));
T_rise=0.4;

%figure,plot(data(900:2000))
figure,plot(data)

%filter parameters
%pulse period
Tpprd = 100;
%clock period [usec]
Tclk = 1./50;
Tclkn = Tclk*1e-6;
%high pass filter differentiation constant
% Taud1 = 2;
% Taud2 = 2;
Taupk = 20;
Taupk_top = 40;
val1=1/T_decay_cal;
val2=1/real(T_rise);
a = exp(-val1);
b = exp(-val2);
na = (Taupk/Tclk);
nad = na-3;
nb = (Taupk_top+Taupk)/Tclk;
nbd = nb-3;
z = tf('z', Tclk);
% Trapezoidal filter Z-transfer function
A=(1-(b*(z^-1)));
B=(1-(a*(z^-1)));
C=( (1-z^-na)/(1-z^-1));
D=( (1-z^-nb)/(1-z^-1));
E=z^-1/na;
F=(a-a*b)*(z^-2);

hz1=A*B*C*D*E*F;
[hznum1, hzden1, Ts1] = tfdata(hz1,'v');

Signal_reconstrcuted =(exp(-ts/T_decay)-exp(-ts/T_rise));

xf1=filter(hznum1,hzden1,data);
figure,plot(xf1)

%figure,plot(Signal_reconstrcuted)