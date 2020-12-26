clc
clear
close all
test_count = 678; %文件名
te_count = 100; %运行次数  
% load temp_n.mat
% load Anom_inf.mat;
% load I_Amp.mat;
%load input_T_56.1.mat;
load input_T0727.mat
%load output_unite0414.mat;
load output_combined0727.mat
%load Y_Amp_n.mat;

% temp_n = temp;
% temp_n = randperm(size(Anom_inf,1));
%temp_n = randperm(size(Zuo_Data,1));
temp_n =1:size(Zuo_Data,1);
%  save temp_n temp_n
%% 训练集,测试集
%训练集
P_train = Zuo_Data(temp_n(1:350),:); %1:350
T_train = MaxPara_1(temp_n(1:350),:);
%测试级
P_test =Zuo_Data(temp_n(351:end),:); %351:400
T_test =MaxPara_1(temp_n(351:end),:);

%% III. 数据归一化
[p_train, ps_input] = mapminmax(P_train',0,1);
p_test = mapminmax('apply',P_test',ps_input);

[t_train,ps_output] = mapminmax(T_train',0,1);
t_test = mapminmax('apply',T_test',ps_output);

p_train = p_train';
t_train = t_train';
p_test = p_test';
t_test = t_test';

% p_train = P_train;
% t_train = T_train;
% p_test = P_test;
% t_test = T_test;
%% BP神经网络创建、训练及仿真测试
ziseH1=200;
ziseH2=60;

rand('state',0);
sae = saesetup([480 ziseH1 ziseH2]);

%初始化激活函数类型，学习率，动量项，稀疏项等参数
sae.ae{1}.activation_function       = 'sigm';
sae.ae{1}.learningRate              = 0.1;
sae.ae{1}.Zuo_DataZeroMaskedFraction   = 0;

sae.ae{2}.activation_function       = 'sigm';
sae.ae{2}.learningRate              = 0.1;
sae.ae{2}.Zuo_DataZeroMaskedFraction   = 0;
opts.numepochs =1000; %通过数据完整扫描的次数 
opts.batchsize =10; %在这个多个样本上进行平均梯度步骤 
sae = saetrain(sae,p_train,opts);
visualize(sae.ae{1}.W{1}(:,2:end)')

% Use the SDAE to initialize a FFNN % fine tuning
nn = nnsetup([480 ziseH1 ziseH2 7651]);
nn.activation_function              = 'sigm';
nn.learningRate                     = 1;

%add pretrained weights
nn.W{1} = sae.ae{1}.W{1};
nn.W{2} = sae.ae{2}.W{1};
%训练FFNN
iteration=100; %200
iter_count = 1;
for d=1:iteration 
    disp(['Iterating:' num2str(iter_count)]);
    nn.learningRate          =0.1;
    opts.batchsize = 10;  
    opts.numepochs = 1000;%size(p_train,1)/opts.batchsize; %训练迭代
    nn = nntrain(nn, p_train, t_train, opts);
    nnn_02(d)=nn;
    iter_count = iter_count+1;
    %save nnn_01.mat nnn_01;
end

%测试数据（nntest）
%nnff是进行前向传播，nnbp是计算误差和权值梯度，nnapplygrads是参数更新
for d = 1:iteration
nntest = nnff(nnn_02(d), p_test, t_test);

meanerror = mean(abs(nntest.e));
varerror = var(abs(nntest.e));
maxerror = max(abs(nntest.e));
%error=min(abs(nntest.e))
t_sim = nntest.a{nntest.n};
T_sim = mapminmax('reverse',t_sim',ps_output);
T_sim = T_sim';
 
all_err(d,:,:) = nntest.e;
all_t_sim(d,:,:)=t_sim;
all_T_sim(d,:,:)=T_sim;
% all_p02(d,:,:)=t_sim;

%均方误差
%load CG_r1.mat
er02=mse(t_test',t_sim');
%err4=MSE(test_y',CG_r1');
rr02(d)=mean(er02);

end

save (['E:\冯天姿\FMT课题程序\6月实验\网络预测\' num2str(test_count) '_' num2str(te_count) '.mat'])
 
%error = abs(T_sim - T_test)./T_test;


%save rre6.mat rre6;
% figure('name','图像的均方误差');
% hold on;


% x=1:2;
% plot(x,rre,'k*-');
% legend('0.01-0.01-0.1-40');
% xlabel( '迭代次数');
% ylabel(' MSE');
% hold off;

% predict3(i,j,:)  第i次迭代生成的一组654个一维数组