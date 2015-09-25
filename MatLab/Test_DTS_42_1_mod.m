% Test_cpp
clc; close all;
load TPE_38_1_mod_two_peak.txt
Dat = TPE_38_1_mod_two_peak;
[Max_val,Index]=max(Dat);
expp=Dat(Index:end);
M=max(find(expp>=Max_val*0.3678));
b10_t = exp(-1/M);
Dat = Dat - 1500;

na = 100;
nb = 400;
b10 = 0.999580835647357;

[output] = F_trapz_filter_digital_1(Dat,na,nb,b10);


plot(Dat)
hold on
%subplot(2,1,2) % second subplot
plot(output)