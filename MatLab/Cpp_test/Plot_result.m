close all; clc; clear all;

data_r_f = csvread('Result.csv');
data = load('TPE_38_1_mod_3.txt');
data_r_uf = csvread('Result_38_uf.csv');
% Baseline restore
data = data - 1500;
%differale
data_diff_f = abs(diff(data_r_f));
data_diff_uf = abs(diff(data_r_uf));
%Plot
plot(data,'y')
%plot(data_diff_f,'b')
hold on
plot(data_r_f,'r')

plot(data_r_uf,'g')
plot(data_diff_uf)

peak_f=zeros(length(data_diff_f),1);
%% Fixed point

% finding the elements where the diff is big Fixed
for i = 1:length(data_diff_f)
    data_diff_f(i) = data_diff_f(i);
    if(data_diff_f(i) > 15)
        peak_f(i) = 1;
    end
end

% getting the index of them
T = find(peak_f==1);

%under the assumption that the peak is symmetric, the middel value is the
%left handed end of the peak and that + 1 is the right handed 
Tm = length(T)/2;

% Area of the whole peaken
area_f = trapz(data_r_f(T(1):T(end)));



intavg = T(Tm+1)-T(Tm-1);
Integraleavg = 0;
% Avervage of the flat peak
for i = 0:intavg
    Sumavg = sum(data_r_f(T(Tm-1)+i));
    Integraleavg = Integraleavg + Sumavg;
end
avgTop = Integraleavg/intavg;

%% UnFixed Point

peak_uf=zeros(length(data_diff_f),1);
% finding the elements where the diff is big UnFixed
for i = 1:length(data_diff_uf)
    data_diff_uf(i) = data_diff_uf(i);
    if(data_diff_uf(i) > 15)
        peak_uf(i) = 1;
    end
end

T_u = find(peak_uf==1);
Tm_u = length(T_u)/2;

% Area of the whole peaken
area_uf = trapz(data_r_uf(T_u(1):T_u(end)));

intavg_u = T_u(Tm_u+1)-T_u(Tm_u-1);
Integraleavg_u = 0;

% Avervage of the flat peak
for i = 0:intavg_u
    Sumavg_u = sum(data_r_uf(T_u(Tm_u-1)+i));
    Integraleavg_u = Integraleavg_u + Sumavg_u;
end
avgTop_u = Integraleavg_u/intavg_u;

%% Compare Fixed /UnFixed

Differences = avgTop_u - avgTop;