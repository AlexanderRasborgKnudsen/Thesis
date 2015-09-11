clc; close all; clear all;
load TPE_38_1_mod_2.txt
Dat = TPE_38_1_mod_2;
%Dat = padarray(Dat,10000,1900);
Dat = Dat - 1600;

 windowSize = 50;
b = (1/windowSize)*ones(1,windowSize);
a = 1;
y1 = filter(b,a,Dat);
Data=round(y1);

for i = 1:length(Data)
    Data(i) = Data(i)+',';
end

csvwrite('TPE_38_1_avg.csv',Data)
dlmwrite('TPE_38_1_avg.txt',Data); 