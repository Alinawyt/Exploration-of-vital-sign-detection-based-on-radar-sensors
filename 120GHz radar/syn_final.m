clear;
close all;
clc;

%set 采集的帧�?
numframe=128;
% set Serial Port (modify number after "COM")
serialPort_string = 'COM14';
% open com port
serialPort = [];
comPort = serialport(serialPort_string, 1000000, 'DataBits', 8, 'FlowControl', 'none', 'StopBits', 1, 'Parity', 'none', 'Timeout', 1); %230400
serialPort= comPort;
configureTerminator(serialPort, 'CR/LF'); %帧以停止标记（�?CR”和“LF”）结束matlab:matlab.internal.language.introspective.errorDocCallback('serialport', 'G:\Program Files\MATLAB\R2021b\toolbox\matlab\serialport\serialport.m', 116)
flush(serialPort); %清空输入和输出缓冲区
pause(0.1);
% system and processing settings
% ------------------------------------------------------------------------
SYS_CONFIG = '!S18056012';  % set to self_trigger mode  128Hz  7-011 D-110 !S78056012
writeline(serialPort, SYS_CONFIG);
flush(serialPort);

BB_CONFIG = '!B0452C01D';  %1ramp 256Sample
writeline(serialPort, BB_CONFIG);
flush(serialPort);

% B
% PLL_CONFIG = '!P00000001';  % bandwidth 5 GHz
% writeline(serialPort, PLL_CONFIG);
% flush(serialPort);
% ------------------------------------------------------------------------

% automatic frequency settings
% ------------------------------------------------------------------------
FSCAN = '!J';  % auto detect frequency DO FREQUENCY SCAN
writeline(serialPort, FSCAN);
flush(serialPort);
pause(0.5);

MAXBW = '!K';  % set to max bandwidth
writeline(serialPort, MAXBW);
flush(serialPort);
pause(0.5);

%% 参数设置
n_adc_samples = 256; % number of ADC samples per chirp
chirpLoop = 1;
n_rx=1;
Fs=0.218e6;

% Fs=5e6;             %ADC采样�?
c=3*1e8;            %光�?
t_ramp=124*(n_adc_samples+55)/27e6;
% ts=n_adc_samples/Fs;%ADC采样时间
Periodicity=47e-3; %帧周�??
% B_valid =ts*slope;  %有效带宽
% B =3997.56e9;  %有效带宽
B=5000e6; %5000MHz
k=B/t_ramp;    %调频斜率 
fs=1/Periodicity;

% t=0;
% m=0;
% p = plot(t,m,'*',...
%    'EraseMode','background','MarkerSize',5);
figure('Name','Real-Time Display','NumberTitle', 'off');
counter=0;
while(counter<=100)
    pause(6);
    data=read(serialPort,serialPort.NumBytesAvailable,'string');
    flush(serialPort);
    counter=counter+1;

    rawdata = split(data,'!');
%     fid = fopen('C:\Users\asd\Desktop\120GHz0318\intermediate.bin','wb');
    % ax1=linspace(1,256,256);
    % ax2=linspace(1,256,256);
    RawData = zeros();%加窗处理心跳信号
    if counter==1
        if length(rawdata)>numframe*2
            for i = 1:1:5
                if (strfind(rawdata(i), 'I0') == 1)
                    for row = i+1:(numframe*2+i)
                        if (strfind(rawdata(row), 'MI') == 1)
                            dataStrI=strsplit(rawdata(row));
                            dataStrI=dataStrI(4:259);
                            dataI=str2double(dataStrI);
                            RawData = [RawData,dataI];
    %                         fwrite(fid,dataI,'int16');
                            
                %             figure(1)
                %             plot(ax1,dataI);
                        elseif (strfind(rawdata(row), 'MQ') == 1)
                            dataStrQ=strsplit(rawdata(row));
                            dataStrQ=dataStrQ(4:259);
                            dataQ=str2double(dataStrQ);
                            RawData = [RawData,dataQ];
    %                         fwrite(fid,dataQ,'int16');
                        end
                    end
                    break;
                end
            end
        else
            disp('Not enough time to get data!');
        end
    else
        flag=0;
        if length(rawdata)>numframe*2
            for row = 2:(numframe*2+3)
                if (strfind(rawdata(row), 'MI') == 1)
                    flag=1;
                    dataStrI=strsplit(rawdata(row));
                    dataStrI=dataStrI(4:259);
                    dataI=str2double(dataStrI);
                    if(length(RawData)<numframe*256*2)
                        RawData = [RawData,dataI];
                    end
%                     fwrite(fid,dataI,'int16');
                    
        %             figure(1)
        %             plot(ax1,dataI);
                elseif (strfind(rawdata(row), 'MQ') == 1)
                    if(flag==1)
                        dataStrQ=strsplit(rawdata(row));
                        dataStrQ=dataStrQ(4:259);
                        dataQ=str2double(dataStrQ);
                        if(length(RawData)<numframe*256*2)
                            RawData = [RawData,dataQ];
                        end
%                         fwrite(fid,dataQ,'int16');
                    end
        
        %             figure(2)
        %             plot(ax2,dataQ);
                else
                    continue;
                end
            end
        else
            disp('Not enough time to get data!');
        end
    end

%     fclose(fid);
%     
%     fidd = fopen(fname, 'r');
%     RawData = fread(fidd, 'int16')
%     fclose(fidd);
%     delete('C:\Users\asd\Desktop\120GHz0318\intermediate.bin');
    RawData(1)=[];
    RawData=RawData';
    fileSize = size(RawData, 1);
    %计算chirps数：数据�?天线�?采样点数/2(实部和虚部各占一个数�?�?
    n_chirps= fileSize/2/n_adc_samples;
    %读取�?��ComplexData数据并写入数组ComplexData，�?维数为：数据�?2(实部和虚部各占一个数�?�?
    ComplexData = zeros(1, fileSize/2);
    IQ_matrix = reshape(RawData,[256,n_chirps*2]);
    IQ_matrix=IQ_matrix';%每行256 I�?��，Q�?��
    I_matrix=IQ_matrix(1:2:end,:);
    Q_matrix=IQ_matrix(2:2:end,:);
    I_chirps=reshape(I_matrix',[1,n_chirps*256]);
    Q_chirps=reshape(Q_matrix',[1,n_chirps*256]);
    for i=1:1:fileSize/2
        ComplexData(1, i) = I_chirps(i) + 1i*Q_chirps(i);
    end
    %将数组ComplexData转换成矩阵Chirp_Division，每行数据为1个chirp的数�?�?个天�?，行高为总chirp数�?
    Chirp_Division = reshape(ComplexData, n_adc_samples*n_rx, n_chirps);
    %转置�?
    Chirp_Division = Chirp_Division.';
    
    %定义Rx_Division为�?Rx行，n_chirps*n_adc_samples列�?的矩�?其每行数据为每根天线接受的�?数据�?
    Rx_Division = zeros(n_rx, n_chirps*n_adc_samples);
    for row = 1:n_rx
        for i = 1: n_chirps
            Rx_Division(row, (i-1)*n_adc_samples+1:i*n_adc_samples) = Chirp_Division(i, (row-1)*n_adc_samples+1:row*n_adc_samples);
        end
    end
        
    %将Rx_Division数据按�?采样点数，天线，chirp*frame”重排列成Sample_Division，按采样点分离数据�?
    Sample_Division = reshape(Rx_Division, n_adc_samples, n_rx, n_chirps);
    %取第1根天线的采样数据�?
    Rx_1 = zeros(n_adc_samples, n_chirps);
    Rx_1(:) = Sample_Division(:, 1, :);
    %时间平均背景减法�?
    Data1filtOut = zeros(size(Rx_1));
    Background = mean(Rx_1, 2);     %返回矩阵每行的平均�?�?               	
    for i=1:n_chirps                                             
        %data1每个值都减去�?��行的平均�?background)�?
        Data1filtOut(:, i) = Rx_1(:, i) - Background;    
    end


    % n=chirpLoop/2:chirpLoop:length(Data1filtOut);
    IF_mat=Data1filtOut;
    [N,M]=size(IF_mat); %N为每chirp采样点，M为chirp�?
    
    %% 生成�?
    range_win = hamming(N);  %生成range�?
    
    %% range fft
    for i = 1:1:M
        temp = IF_mat(:,i) .* range_win;
        temp_fft = fft(temp,N);
        IF_mat(:,i) = temp_fft;
    %     IF_mat(:,i)=temp_fft-mean(temp_fft); %平均相消法滤除杂�?
    end
    
    %找range-bin
    % range_bin=(0:N-1)*c*Fs/N/2/k*100; %转换为cm
    range_bin=(0:N-1)*c*Fs/N/2/k*100; %转换为cm
    time=linspace(0,M*Periodicity,M);
    [Val,Locs]=max(abs(IF_mat));
    [Locs,ord]=mode(Locs); %众数，频�?
    % range_bin(Locs)
    
    % 某chirp�?D-fft�?
    for i = 1:1:M
        [a,b]=max(abs(IF_mat(:,i)));
        if b==Locs
           example_chirp=b;
           example_Val=a;
           break
        end
    end

    subplot(3,2,6)
    plot(range_bin, abs(IF_mat(:,i))); %abs
%     text(range_bin(example_chirp),example_Val,['  ',num2str(range_bin(example_chirp))],'Color','red'); %]
%     hold on
%     plot(range_bin(example_chirp),example_Val,'ro');
    xlim([0,150]);
    title('Range Profile');
    ylabel('Amplitude'); 
    xlabel('range(cm)');
%     hold off

    %慢时间采样：Locs代表每个chirp取第Locs个采样点的数据�?
    % n=chirpLoop/2:chirpLoop:length(Data1filtOut);
    Data_tmp=Data1filtOut;
    Data_tmp = reshape(Data_tmp(Locs, :), [], 1);
    % Data_tmp=Data_tmp(1:1024);
    data_num=length(Data_tmp);

    % 不�?虑IQ不平�?
    I =real(Data_tmp);
    Q =imag(Data_tmp);
    signal_IQ = I+Q*1j;


    %相位提取和解缠绕
    angle_data=angle(signal_IQ);
    angle_data=unwrap(angle_data);
    %线�?去趋�?
    % angle_data = detrend(angle_data);
    % %转置
    % angle_data=angle_data'; 
    % angle_data=(angle_data-mean(angle_data));
    t=linspace(0,data_num*Periodicity,data_num);
    subplot(3,2,5)
    plot(t, angle_data);
    xlim([0,6]);
    xlabel('Time (s)'); 
    ylabel('Amplitude'); 
    title('Chest Displacememt');


    %呼吸信号提取
    x = angle_data;
    lev=6;
    wtecg=modwt(x,'coif1',lev); %coiflet消失�?，层数为7 coif5
    mra=modwtmra(wtecg,'coif1');%MRA
    respiration=mra(6,:);



    x = angle_data;
    lev=6;
    wtecg=modwt(x,'coif1',lev); %coiflet消失�?，层数为7 coif5
    mra=modwtmra(wtecg,'coif1');%MRA
    energy_by_level = sum(wtecg.^2,2);
    low_lev=2; % 
    high_lev=3; %假设(1.6-5Hz)与mra第low_lev至high_lev行相对应
    energy_subsum=sum(energy_by_level(low_lev:high_lev));
    Sec_harmonic_heartbeat=zeros([1,data_num]);
    for i = low_lev:1:high_lev
    %     Sec_harmonic_heartbeat=Sec_harmonic_heartbeat+mra(i,:);
        Sec_harmonic_heartbeat=Sec_harmonic_heartbeat+(energy_by_level(i)/energy_subsum)*mra(i,:);
    end



    %估计呼吸频率
    %https://ieeexplore.ieee.org/stamp/stamp.jsp?tp=&arnumber=679118
    x=respiration';
    N=length(x); 
    X=fft(x,N); 
    z_dec=(1/2)*ifft([(X(1)+X(N/2+1));2*X(2:N/2)],N/2); %长度减半
    
    %MUSIC算法
    %https://blog.csdn.net/I_am_mengxinxin/article/details/106046389?ops_request_misc=%257B%2522request%255Fid%2522%253A%2522167774676416800215034888%2522%252C%2522scm%2522%253A%252220140713.130102334..%2522%257D&request_id=167774676416800215034888&biz_id=0&utm_medium=distribute.pc_search_result.none-task-blog-2~all~sobaiduend~default-1-106046389-null-null.142^v73^pc_new_rank,201^v4^add_ask,239^v2^insert_chatgpt&utm_term=%E9%A2%91%E7%8E%87%E4%BC%B0%E8%AE%A1%20music&spm=1018.2226.3001.4187
    n=length(z_dec); %信号样本�?
    s=z_dec;  %估计频率的信�? '
    m=8; %自相关矩阵的阶数
    for i=1:n-m
        xx(:,i)=s(i+m-1:-1:i).';  %构�?样本矩阵
    end
    R=xx*xx'/(n-m);%自相关矩�?
    [EV,D]=eig(R);%特征值分�?
    EVA=diag(D)';
    [EVA,I]=sort(EVA);%特征值从小到大排�?
    EVA=fliplr(EVA);%左右翻转，从大到小排�?
    EV=fliplr(EV(:,I));%对应特征矢量排列
    G=EV(:,2:m); %噪声子空�?可以认为只有心跳二次谐波�?��分量
    NF=2048;
    
    w=linspace(-pi,pi,NF);
    for ii=1:NF
        a=exp(-1j*w(ii)*(0:m-1)');% -
        Pmusic(ii)=1/(a'*G*G'*a);
    end
    Pmusic=abs(Pmusic)/max(abs(Pmusic));
    
    Pmusic=10*log10(Pmusic);
%     [Val,Locs]=findpeaks(Pmusic,'minpeakheight',-5);
    [Val,Locs]=max(Pmusic);
%     figure
%     for i = 1:1:length(Locs)
%         plot(w(Locs(i))/(2*pi),Val(i),'ro');
%         text(w(Locs(i))/(2*pi),Val(i),num2str(w(Locs(i))/(2*pi)))
%         hold on
%     end
%     plot(w/(2*pi),Pmusic);
%     xlabel('Normalized frequency(Hz)');
%     % ylim([-35,5]);
%     ylabel('db');
%     % title('The frequency of respiration');
%     title('The frequency of heartbeat');
    Respiratory_fre=w(Locs)/(2*pi)*(fs/2);%/2;
    Respiratory_fre=floor(Respiratory_fre*60);%/100*60; %不四舍五�?
    % fprintf ('The Respiratory rate is %.2f Hz',heartbeat_fre);
%     fprintf ('The heartbeat frequency is %.2f Hz',heartbeat_fre);
    %画图
    subplot(3,2,3)
    plot(t,respiration);
    xlim([0,6]);
    xlabel('Time (s)'); 
    ylabel('Amplitude'); 
    title('Breathing Waveform');

    %估计心跳频率
    %https://ieeexplore.ieee.org/stamp/stamp.jsp?tp=&arnumber=679118
    x=Sec_harmonic_heartbeat';
    N=length(x); 
    X=fft(x,N); 
    z_dec=(1/2)*ifft([(X(1)+X(N/2+1));2*X(2:N/2)],N/2); %长度减半
    
    %MUSIC算法
    %https://blog.csdn.net/I_am_mengxinxin/article/details/106046389?ops_request_misc=%257B%2522request%255Fid%2522%253A%2522167774676416800215034888%2522%252C%2522scm%2522%253A%252220140713.130102334..%2522%257D&request_id=167774676416800215034888&biz_id=0&utm_medium=distribute.pc_search_result.none-task-blog-2~all~sobaiduend~default-1-106046389-null-null.142^v73^pc_new_rank,201^v4^add_ask,239^v2^insert_chatgpt&utm_term=%E9%A2%91%E7%8E%87%E4%BC%B0%E8%AE%A1%20music&spm=1018.2226.3001.4187
    n=length(z_dec); %信号样本�?
    s=z_dec;  %估计频率的信�? '
    m=8; %自相关矩阵的阶数
    for i=1:n-m
        xx(:,i)=s(i+m-1:-1:i).';  %构�?样本矩阵
    end
    R=xx*xx'/(n-m);%自相关矩�?
    [EV,D]=eig(R);%特征值分�?
    EVA=diag(D)';
    [EVA,I]=sort(EVA);%特征值从小到大排�?
    EVA=fliplr(EVA);%左右翻转，从大到小排�?
    EV=fliplr(EV(:,I));%对应特征矢量排列
    G=EV(:,2:m); %噪声子空�?可以认为只有心跳二次谐波�?��分量
    NF=2048;
    
    w=linspace(-pi,pi,NF);
    for ii=1:NF
        a=exp(-1j*w(ii)*(0:m-1)');% -
        Pmusic(ii)=1/(a'*G*G'*a);
    end
    Pmusic=abs(Pmusic)/max(abs(Pmusic));
    
    Pmusic=10*log10(Pmusic);
%     [Val,Locs]=findpeaks(Pmusic,'minpeakheight',-5);
    [Val,Locs]=max(Pmusic);
%     figure
%     for i = 1:1:length(Locs)
%         plot(w(Locs(i))/(2*pi),Val(i),'ro');
%         text(w(Locs(i))/(2*pi),Val(i),num2str(w(Locs(i))/(2*pi)))
%         hold on
%     end
%     plot(w/(2*pi),Pmusic);
%     xlabel('Normalized frequency(Hz)');
%     % ylim([-35,5]);
%     ylabel('db');
%     % title('The frequency of respiration');
%     title('The frequency of heartbeat');
    heartbeat_fre=w(Locs)/(2*pi)*(fs/2);%/2;
    heartbeat_fre=floor(heartbeat_fre*60); %不四舍五�?
    % fprintf ('The Respiratory rate is %.2f Hz',heartbeat_fre);
%     fprintf ('The heartbeat frequency is %.2f Hz',heartbeat_fre);
    subplot(3,2,4)
    plot(t,Sec_harmonic_heartbeat);
    xlim([0,6]);
    xlabel('Time (s)'); 
    ylabel('Amplitude'); 
    title('Heart Waveform');
    
    subplot(3,2,1)
    delete(findobj('type','text'));
    set(gca,'xtick',[],'ytick',[],'xcolor','w','ycolor','w')
    text(0.25,0.8,'Breathing Rate','Color','black','FontSize',10); %]
%     hold on
    text(0.4,0.3,num2str(Respiratory_fre),'Color','black','FontSize',18); %]
%     hold off
    subplot(3,2,2)
%     delete(findobj('type','text'));
    set(gca,'xtick',[],'ytick',[],'xcolor','w','ycolor','w')
    text(0.32,0.8,'Heart Rate','Color','black','FontSize',10); %]
%     hold on
    text(0.4,0.3,num2str(heartbeat_fre),'Color','black','FontSize',18); %]
%     hold off
end
% fclose(fid);
delete(serialPort);