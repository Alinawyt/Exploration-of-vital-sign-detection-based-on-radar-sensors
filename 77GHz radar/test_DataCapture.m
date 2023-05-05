%=================================杩炴帴mmWaveStudio================================%
addpath(genpath('.\'))
%==============================鍒濆鍖朢adarStudio杩炴�?==============================%
RSTD_DLL_Path = 'D:/ti/mmwave_studio_02_00_00_00/mmWaveStudio/Clients/RtttNetClientController/RtttNetClientAPI.dll';
ErrStatus = Init_RSTD_Connection(RSTD_DLL_Path);
if (ErrStatus ~= 30000)
	disp('Error inside Init_RSTD_Connection');
    return;
end
%============================閰嶇疆AWR1642鍜孌CA1000鐨勮剼鏈�?1�?7===========================%
strFilename = ('D:\\ti\\mmwave_studio_02_00_00_00\\mmWaveStudio\\Scripts\\automation.lua');
Lua_String = sprintf('dofile("%s")', strFilename);
ErrStatus = RtttNetClientAPI.RtttNetClient.SendCommand(Lua_String);
%====================================鎹曡幏鏁版嵁======================================%
%杩炵画鎵ц浠ヤ笅鍐呭銆�?1�?7
idx = 0;
while 1
    %鎺у埗寮�1�?7濮嬪拰缁撴潫閲囬泦鐨勮剼鏈�?1�?7�?1�?7
    strFilename = 'D:\\ti\\mmwave_studio_02_00_00_00\\mmWaveStudio\\Scripts\\capture.lua';
    Lua_String = sprintf('dofile("%s")', strFilename);
    ErrStatus = RtttNetClientAPI.RtttNetClient.SendCommand(Lua_String);
    
%     command=['C:\ti\mmwave_studio_01_00_00_00\mmWaveStudio\PostProc\Packet_Reorder_Zerofill.exe C:\ti\mmwave_studio_01_00_00_00\mmWaveStudio\PostProc\adc_data_Raw_0',...
%     '.bin C:\ti\mmwave_studio_01_00_00_00\mmWaveStudio\PostProc_2\fall_soft_qyt',num2str(idx)];
    

    %鍛ㄦ湡閲囬泦(娴嬭瘯鐢�?1�?7)
%     command=['D:\ti\mmwave_studio_01_00_00_00\mmWaveStudio\PostProc\Packet_Reorder_Zerofill.exe D:\ti\mmwave_studio_01_00_00_00\mmWaveStudio\PostProc\adc_data_Raw_0',...
%     '.bin D:\ti\mmwave_studio_01_00_00_00\mmWaveStudio\PostProc2\data_',num2str(idx),'.bin'];
%     system(command);
    
    
    
       %零填�?
     command=['D:\ti\mmwave_studio_02_00_00_00\mmWaveStudio\PostProc\Packet_Reorder_Zerofill.exe D:\ti\mmwave_studio_02_00_00_00\mmWaveStudio\PostProc\adc_data_Raw_0',...
    '.bin D:\ti\mmwave_studio_02_00_00_00\mmWaveStudio\PostProc_2\data_',num2str(idx), ...
    '.bin D:\ti\mmwave_studio_02_00_00_00\mmWaveStudio\PostProc\logfile.txt'];
    system(command); 
   
    idx = idx + 1;
    pause(1);
    if idx == 10
        break;
    end
    

end