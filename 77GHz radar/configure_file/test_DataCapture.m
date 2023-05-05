%=================================æ©ç‚´å¸´mmWaveStudio================================%
addpath(genpath('.\'))
%==============================é’æ¿†îé–æœ¢adarStudioæ©ç‚´å¸?==============================%
RSTD_DLL_Path = 'D:/ti/mmwave_studio_02_00_00_00/mmWaveStudio/Clients/RtttNetClientController/RtttNetClientAPI.dll';
ErrStatus = Init_RSTD_Connection(RSTD_DLL_Path);
if (ErrStatus ~= 30000)
	disp('Error inside Init_RSTD_Connection');
    return;
end
%============================é–°å¶‡ç–†AWR1642éœå­ŒCA1000é¨å‹®å‰¼éˆï¿?1ï¿?7===========================%
strFilename = ('D:\\ti\\mmwave_studio_02_00_00_00\\mmWaveStudio\\Scripts\\automation.lua');
Lua_String = sprintf('dofile("%s")', strFilename);
ErrStatus = RtttNetClientAPI.RtttNetClient.SendCommand(Lua_String);
%====================================éŽ¹æ›¡å¹éç‰ˆåµ======================================%
%æ©ç‚µç”»éŽµÑ†î”‘æµ ãƒ¤ç¬…éå‘­î†éŠ†ï¿?1ï¿?7
idx = 0;
while 1
    %éŽºÑƒåŸ—å¯®ï¿½1ï¿?7æ¿®å¬ªæ‹°ç¼æ’´æ½«é–²å›¬æ³¦é¨å‹®å‰¼éˆîƒ¾ï¿?1ï¿?7ï¿?1ï¿?7
    strFilename = 'D:\\ti\\mmwave_studio_02_00_00_00\\mmWaveStudio\\Scripts\\capture.lua';
    Lua_String = sprintf('dofile("%s")', strFilename);
    ErrStatus = RtttNetClientAPI.RtttNetClient.SendCommand(Lua_String);
    
%     command=['C:\ti\mmwave_studio_01_00_00_00\mmWaveStudio\PostProc\Packet_Reorder_Zerofill.exe C:\ti\mmwave_studio_01_00_00_00\mmWaveStudio\PostProc\adc_data_Raw_0',...
%     '.bin C:\ti\mmwave_studio_01_00_00_00\mmWaveStudio\PostProc_2\fall_soft_qyt',num2str(idx)];
    

    %é›ã„¦æ¹¡é–²å›¬æ³¦(å¨´å¬­ç˜¯é¢ï¿?1ï¿?7)
%     command=['D:\ti\mmwave_studio_01_00_00_00\mmWaveStudio\PostProc\Packet_Reorder_Zerofill.exe D:\ti\mmwave_studio_01_00_00_00\mmWaveStudio\PostProc\adc_data_Raw_0',...
%     '.bin D:\ti\mmwave_studio_01_00_00_00\mmWaveStudio\PostProc2\data_',num2str(idx),'.bin'];
%     system(command);
    
    
    
       %é›¶å¡«å…?
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
