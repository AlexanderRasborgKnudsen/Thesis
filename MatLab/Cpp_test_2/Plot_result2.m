data_r_f = csvread('Result_fixed.csv');
data = load('TPE_38_1_mod_3.txt');
data_r_uf = csvread('Result_ufixed.csv');
close all
clc
% Baseline restore
data = data - 1500;

energy_uf = data_r_uf(1);
energy_f = data_r_f(1);

data_uf = data_r_uf(2:end);
data_f = data_r_f(2:end);
%differale
data_diff_f = abs(diff(data_f));
data_diff_uf = abs(diff(data_uf));

%Plot
plot(data,'y')
%plot(data_diff_f,'b')
hold on
plot(data_r_f,'r')

plot(data_r_uf,'g')
plot(data_diff_uf)

procent = energy_f / energy_uf*100;
