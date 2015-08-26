clc; close all; clear all;

%Expresses the initial quantity
load TPE_5_2.txt
%data=0.0001*adc1_10(5732:14000);
data = TPE_5_2;
SampleNo = size(data,1) ;
ts=linspace(0,SampleNo-1,SampleNo);

%Moving Average Filter
 windowSize = 100;
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

F = @(x,xdata)(x(1)*(exp(-xdata/x(2)) - exp(-xdata/x(3))));

x0 = [0.1 100 100];

[x,resnorm,~,exitflag,output] = lsqcurvefit(F,x0,ts',dn)



%subplot(2,1,2) % second subplot
%title('Plot of the resulting fit')
% hold on
% plot(ts,F(x,ts),'--')
% hold off

figure(1)
hold on
plot(ts,dn,'r',ts,F(x,ts),'--')
title('Estimation of the equation based on data points')
legend('Plot of function','Plot of estimated equation')
xlabel('Time')
ylabel('Voltage')
hold off
%%
% Test code to find the value of top
% The function findpeaks can be used to design the trapezoid filter
[pks,locs] = findpeaks(F(x,ts));
b=1/x(2);
a=1/x(3);
ln = @(x)(log(x));
Pikval=((b-a)^(-1))/(ln (b/a));
%%
T_decay=x(2);
T_rise=x(3);


Fsumsquares = @(x)sum((F(x,ts') - dn).^2);
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
% Taud1 = 2;
% Taud2 = 2;
Taupk = 10;
Taupk_top = 20;
val1=1/T_decay;
val2=1/T_rise;
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
xf1=filter(hznum1,hzden1,dn);

figure (2)
hold on
title('Output of the biexponential trapezoidal filter')
plot(xf1)