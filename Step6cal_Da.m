%pwr

clear;clc;
filepath1=uigetdir();% pwr
filepath2=uigetdir();% date

files = dir(fullfile(filepath1, 'mli*.mat'));
n = numel(files);

% 
Iaver_sum=0;
for i=1:n
    load([filepath1 '\' 'mli' num2str(i) '.mat'])
    temp=temp(1:4456,1:6421);temp(isnan(temp))=0;% 

    temp1=temp;%
    eval(['Iaver',num2str(i),'=sum(sum(temp1))/numel(find(temp1~=0));']);%
    % eval(['Iaver',num2str(i),'=sum(sum(temp))/(8695*8581);']);% 
    eval(['Iaver_sum=Iaver_sum+Iaver',num2str(i),';']);
    display(num2str(i))
end
Taver=Iaver_sum./n;
figure(1);imagesc(Taver);axis image off;
% exportgraphics(figure(1),[filepath2 '\' 'Taver' '.tif'],'Resolution',380)
save([filepath2 '\' 'Taver.mat'],'Taver');

% 
for i0=1:n
    eval(['K',num2str(i0),'=Taver/Iaver',num2str(i0),';']);
    display(num2str(i0))
end


% 
AC_sum=0;
for i1=1:n
    load([filepath1 '\' 'mli' num2str(i1) '.mat'])
    temp=temp(1:4456,1:6421);temp(isnan(temp))=0;%  
    eval(['AC=temp*K',num2str(i1),';'])
    AC_sum=AC_sum+AC;
    display(num2str(i1))
end
mA=AC_sum./n;
mli=log10(mA)/10;
mli(mli<0)=0;
figure(2);imagesc(mli);axis image off;colormap(gray);
% exportgraphics(figure(2),[filepath2 '\' 'log10mA' '.tif'],'Resolution',380)
save([filepath2 '\' 'mli.mat'],'mli');
% 
Sum=0;
for i2=1:n
    load([filepath1 '\' 'mli' num2str(i2) '.mat'])
    temp=temp(1:4456,1:6421);temp(isnan(temp))=0;%    
    eval(['AC=temp*K',num2str(i2),';'])
    AC=AC-mA;
    Sum=Sum+AC.^2;
    display(num2str(i2))
end
sigma=sqrt(Sum/n);
Da=sigma./(10.*mA);
figure(3);imagesc(Da,[0,1]);colorbar;axis image off;
title('Amplitude dispersion index','FontSize',16);
% exportgraphics(figure(3),[filepath2 '\' 'Da' '.tif'],'Resolution',1000)
save([filepath2 '\' 'Da.mat'],'Da');