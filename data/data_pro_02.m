%% 输入数据组合（增加维度）
clc
clear
close all
%a=load('input_newtrypro0724.mat');
%aa=a.Zuo_Data;
b=load('input_newtrypro0725.mat');
bb=b.Zuo_Data;
c=load('input_newtrypro0726.mat');
cc=c.Zuo_Data;
% Zuo_Data=[aa,bb,cc];
Zuo_Data=[bb,cc];
save input_combined0819.mat Zuo_Data

%% 输出数据组合
clc
clear
close all
a=load('output_newtrypro0724.mat');
a_output=a.MaxPara_1;
b=load('output_newtrypro0725.mat');
b_output=b.MaxPara_1;
% c=load('output_newtrypro0726.mat');
% c_output=c.MaxPara_1;
%MaxPara_1=a_output+b_output+c_output;
MaxPara_1=a_output+b_output;
save output_combined0812.mat MaxPara_1