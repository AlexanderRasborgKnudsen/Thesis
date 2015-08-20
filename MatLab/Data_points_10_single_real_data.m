clc; close all; clear all;

%Expresses the initial quantity
load adc1_10.txt
data=adc1_10(6200:16000);
data=data';
SampleNo = size(data,2);
ts=linspace(0,SampleNo-1,SampleNo);

%Moving Average Filter
 windowSize = 50;
b = (1/windowSize)*ones(1,windowSize);
a = 1;
y1 = filter(b,a,data);
dn=y1;

% figure(1)
% %subplot(2,1,1) % first subplot
% plot(ts,dn,'r',F(x,ts),'--')
% title('Estimation of equation based on data points')
% legend('Plot of function','Plot of estimated equation','location','southeast')
% xlabel('Time')
% ylabel('Voltage')
% % hold off

F = @(x,xdata)(x(1)*exp(-xdata/x(2)));

x0 = [1000 1000];

[x,resnorm,~,exitflag,output] = lsqcurvefit(F,x0,ts,dn)




figure(1)
hold on
plot(ts,dn,'r',ts,F(x,ts),'--')
title('Estimation of the equation based on data points')
%%
% 
%   for x = 1:10
%       disp(x)
%   end
% 
legend('Plot of function','Plot of estimated equation')
xlabel('Time')
ylabel('Voltage')
hold off

T_decay=x(1);
T_rise=x(2);


Fsumsquares = @(x)sum((F(x,ts) - dn).^2);
opts = optimoptions('fminunc','Algorithm','quasi-newton');
[xunc,ressquared,eflag,outputu] = ...
    fminunc(Fsumsquares,x0)

%Notice that fminunc found the same solution as lsqcurvefit,
%but took many more function evaluations to do so.

fprintf(['There were %d iterations using fminunc,' ...
    ' and %d using lsqcurvefit.\n'], ...
    outputu.iterations,output.iterations)
fprintf(['There were %d function evaluations using fminunc,' ...
    ' and %d using lsqcurvefit.'], ...
    outputu.funcCount,output.funcCount)


%filter parameters
%pulse period
Tpprd = 100;
%clock period [usec]
Tclk = 1./50;
Tclkn = Tclk*1e-6;
%high pass filter differentiation constant
val=1/x(2);
Taupk = 3;
Taupk_top = 50;
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
figure (2)
hold on
title('Output of the trapezoidal filter')
plot(xf1)