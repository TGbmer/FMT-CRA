clc 
clear 
close all
pathname = uigetdir;
if pathname(end)~='\' 
 pathname=[pathname,'\']; 
end 
filePattern =[pathname,'*.mat'];
 [file_dir] = getAllFilenames(filePattern);  %file_dir 是一个400*1的结构数组struct
for k = 1:length(file_dir)
   Data(k).name = file_dir(k).name; 
   Data(k).value = load([pathname file_dir(k).name]); %建立结构体数组Data 1*400struct
   Zuo_Data(k,:) = [Data(k).value.zuo1;Data(k).value.zuo2]';
   yi_value(k,:)=[Data(k).value.yi_value];
   yi_value0621=yi_value;
   MaxPara_1(k,:) = Data(k).value.MaxParameter1(:,1)';
   MaxPara_2(k,:) = Data(k).value.MaxParameter2(:,1)';
   MaxPara_Data(k,:) = [MaxPara_1(k,:),MaxPara_2(k,:) ];
end
 save input0621.mat   Zuo_Data yi_value0621; 
 save output0621.mat  MaxPara_1;

% load input.mat
% load output.mat
 
% save input.txt -ascii Zuo_Data; 
% save output.txt -ascii MaxPara_1;
% load input.mat
% load output.mat
% xlswrite('input.xlsx',Zuo_Data);
% xlswrite('output.xlsx',MaxPara_1)
% figure
% 
%     X =Data(1).value.node;
%     R=30;
%     d = -R:0.1:R;
%     [xx1,y1] = meshgrid(d,d);
%     XI = [xx1(:) y1(:)];
% 
%     Eitauaf = griddatan(X,MaxPara_2(1,:)',XI);
%     Eitauaf=reshape(Eitauaf,size(xx1));
%     pcolor(xx1,y1,Eitauaf)
%     shading interp;
%     colormap jet;
%     axis equal;
%     axis tight;
%     colorbar;