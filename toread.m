%%
%read_hea
PATH= 'C:\Users\纳豆够巷\Desktop\大二做的事\大创hololens\MIT-BIH'; 
HEADERFILE= '114.hea';  
signalh= fullfile(PATH, HEADERFILE);

fid1=fopen(signalh,'r');

z= fgetl(fid1);

A= sscanf(z, '%*s %d %d %d',[1,3]);

nosig= A(1);   
sfreq=A(2);    
SAMPLES2READ = 10*sfreq;    

for k=1:nosig           
    z= fgetl(fid1);
    A= sscanf(z, '%*s %d %d %d %d %d',[1,5]);
    dformat(k)= A(1);      
    gain(k)= A(2);         
    bitres(k)= A(3);       
    zerovalue(k)= A(4);    
    firstvalue(k)= A(5);    
end;
fclose(fid1);
clear A;
%%
%read_dat
PATH= 'C:\Users\纳豆够巷\Desktop\大二做的事\大创hololens\MIT-BIH';
DATAFILE='114.dat'; 

signald = fullfile(PATH , DATAFILE);
fid2 = fopen(signald,'r');
A= fread(fid2, [3, SAMPLES2READ], 'uint8')';
fclose(fid2);

M_R_H = bitshift(A(:,2), -4);

M_L_H = bitand(A(:,2), 15);

PRL=bitshift(bitand(A(:,2),8),9); 

PRR=bitshift(bitand(A(:,2),128),5);

M( : , 1)= bitshift(M_L_H,8)+ A(:,1)-PRL;
M( : , 2)= bitshift(M_R_H,8)+ A(:,3)-PRR;

M( : , 1)= (M( : , 1)- zerovalue(1))/gain(1);
M( : , 2)= (M( : , 2)- zerovalue(2))/gain(2);
TIME =(0:(SAMPLES2READ-1))/sfreq;
clear A M_R_H M_L_H PRR PRL;
%%
%read_atr
PATH= 'C:\Users\纳豆够巷\Desktop\大二做的事\大创hololens\MIT-BIH';
ATRFILE='114.atr';
atrd= fullfile(PATH, ATRFILE);
fid3=fopen(atrd,'r');
A= fread(fid3, [2, inf], 'uint8')';
fclose(fid3);
ATRTIME=[];
ANNOT=[];
sa=size(A);
saa=sa(1);
i=1;
while i<=saa
    annoth=bitshift(A(i,2),-2);
    if annoth==59
        ANNOT=[ANNOT;bitshift(A(i+3,2),-2)];
        ATRTIME=[ATRTIME;A(i+2,1)+bitshift(A(i+2,2),8)+...
                bitshift(A(i+1,1),16)+bitshift(A(i+1,2),24)];
        i=i+3;
    elseif annoth==60   
    elseif annoth==61   
    elseif annoth==62  
    elseif annoth==63
        hilfe=bitshift(bitand(A(i,2),3),8)+A(i,1);
        hilfe=hilfe+mod(hilfe,2);
        i=i+hilfe/2;
    else
        ATRTIME=[ATRTIME;bitshift(bitand(A(i,2),3),8)+A(i,1)];
        ANNOT=[ANNOT;bitshift(A(i,2),-2)];
   end;
   i=i+1;
end;

ANNOT(length(ANNOT))=[];       

ATRTIME(length(ATRTIME))=[];   
clear A;
ATRTIME= (cumsum(ATRTIME))/sfreq;
ind= find(ATRTIME <= TIME(end));
ATRTIMED= ATRTIME(ind);
ANNOT=round(ANNOT);
ANNOTD= ANNOT(ind);
%%
%pic
a = M(:, 1);
b = M(:, 2);
cal=a-b;
plot(TIME,cal,'g');
set(gcf,'color','white'); %窗口背景白色
colordef black; %2D/3D图背景黑色