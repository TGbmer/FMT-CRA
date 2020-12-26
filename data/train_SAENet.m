clc
clear
close all
test_count = 678; %�ļ���
te_count = 100; %���д���  
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
%% ѵ����,���Լ�
%ѵ����
P_train = Zuo_Data(temp_n(1:350),:); %1:350
T_train = MaxPara_1(temp_n(1:350),:);
%���Լ�
P_test =Zuo_Data(temp_n(351:end),:); %351:400
T_test =MaxPara_1(temp_n(351:end),:);

%% III. ���ݹ�һ��
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
%% BP�����紴����ѵ�����������
ziseH1=200;
ziseH2=60;

rand('state',0);
sae = saesetup([480 ziseH1 ziseH2]);

%��ʼ����������ͣ�ѧϰ�ʣ������ϡ����Ȳ���
sae.ae{1}.activation_function       = 'sigm';
sae.ae{1}.learningRate              = 0.1;
sae.ae{1}.Zuo_DataZeroMaskedFraction   = 0;

sae.ae{2}.activation_function       = 'sigm';
sae.ae{2}.learningRate              = 0.1;
sae.ae{2}.Zuo_DataZeroMaskedFraction   = 0;
opts.numepochs =1000; %ͨ����������ɨ��Ĵ��� 
opts.batchsize =10; %�������������Ͻ���ƽ���ݶȲ��� 
sae = saetrain(sae,p_train,opts);
visualize(sae.ae{1}.W{1}(:,2:end)')

% Use the SDAE to initialize a FFNN % fine tuning
nn = nnsetup([480 ziseH1 ziseH2 7651]);
nn.activation_function              = 'sigm';
nn.learningRate                     = 1;

%add pretrained weights
nn.W{1} = sae.ae{1}.W{1};
nn.W{2} = sae.ae{2}.W{1};
%ѵ��FFNN
iteration=100; %200
iter_count = 1;
for d=1:iteration 
    disp(['Iterating:' num2str(iter_count)]);
    nn.learningRate          =0.1;
    opts.batchsize = 10;  
    opts.numepochs = 1000;%size(p_train,1)/opts.batchsize; %ѵ������
    nn = nntrain(nn, p_train, t_train, opts);
    nnn_02(d)=nn;
    iter_count = iter_count+1;
    %save nnn_01.mat nnn_01;
end

%�������ݣ�nntest��
%nnff�ǽ���ǰ�򴫲���nnbp�Ǽ�������Ȩֵ�ݶȣ�nnapplygrads�ǲ�������
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

%�������
%load CG_r1.mat
er02=mse(t_test',t_sim');
%err4=MSE(test_y',CG_r1');
rr02(d)=mean(er02);

end

save (['E:\������\FMT�������\6��ʵ��\����Ԥ��\' num2str(test_count) '_' num2str(te_count) '.mat'])
 
%error = abs(T_sim - T_test)./T_test;


%save rre6.mat rre6;
% figure('name','ͼ��ľ������');
% hold on;


% x=1:2;
% plot(x,rre,'k*-');
% legend('0.01-0.01-0.1-40');
% xlabel( '��������');
% ylabel(' MSE');
% hold off;

% predict3(i,j,:)  ��i�ε������ɵ�һ��654��һά����