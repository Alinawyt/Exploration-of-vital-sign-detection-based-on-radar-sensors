--http://www.lua.org/manual/5.1/manual.html#5.4
--mmwave studio installation path
--RSTD.PATH = RSTD.GetRstdPath()
--declare the loading function
ar1.FullReset()--重置系统
RSTD.Sleep(1000)
ar1.SOPControl(2)--对应mmWave Studio中的SOP control按钮
RSTD.Sleep(1000)
ar1.Connect(8,115200,1000)--对应mmWave Studio中的Connect，8为RS232所在的端口号，115200为波特率
RSTD.Sleep(1000)
ar1.Calling_IsConnected()
RSTD.Sleep(1000)
ar1.SelectChipVersion("XWR1642")--选择雷达板型号
RSTD.Sleep(1000)

--BSS and MSS firmware download，下载BSS和MSS固件
info = debug.getinfo(1,'S');
file_path = (info.source);
file_path = string.gsub(file_path, "@","");
file_path = string.gsub(file_path, "automation.lua","");
fw_path   = file_path.."..\\..\\rf_eval_firmware"

--Export bit operation file
bitopfile = file_path.."\\".."bitoperations.lua"
dofile(bitopfile)

--Read part ID
res, efuserow9 = ar1.ReadRegister(0xffffe210, 0, 31)
if (bit_and(efuserow9, 3) == 0) then
    partId = 1243
elseif (bit_and(efuserow9, 3) == 1) then
    partId = 1443
else
    partId = 1642
end

--ES version
res, ESVersion = ar1.ReadRegister(0xFFFFE218, 0, 31)
ESVersion = bit_and(ESVersion, 15)

--ADC_Data file and Raw file and PacketReorder utitlity log file path
data_path     = file_path.."..\\PostProc"
adc_data_path = data_path.."\\adc_data.bin"
Raw_data_path = data_path.."\\adc_data_Raw_0.bin"
pkt_log_path  = data_path.."\\pktlogfile.txt"

-- Download BSS Firmware(AR16xx)
if((partId == 1642) and (ESVersion == 1)) then
    BSS_FW    = fw_path.."\\radarss\\xwr16xx_radarss_rprc_ES1.0.bin"
    MSS_FW    = fw_path.."\\masterss\\xwr16xx_masterss_rprc_ES1.0.bin"
elseif((partId == 1642) and (ESVersion == 2)) then
    BSS_FW    = fw_path.."\\radarss\\xwr16xx_radarss_rprc_ES2.0.bin"
    MSS_FW    = fw_path.."\\masterss\\xwr16xx_masterss_rprc_ES2.0.bin"
elseif((partId == 1243) and (ESVersion == 2)) then
    BSS_FW    = fw_path.."\\radarss\\xwr12xx_xwr14xx_radarss_ES2.0.bin"
    MSS_FW    = fw_path.."\\masterss\\xwr12xx_xwr14xx_masterss_ES2.0.bin"
elseif((partId == 1243) and (ESVersion == 3)) then
    BSS_FW    = fw_path.."\\radarss\\xwr12xx_xwr14xx_radarss_ES3.0.bin"
    MSS_FW    = fw_path.."\\masterss\\xwr12xx_xwr14xx_masterss_ES3.0.bin"
elseif((partId == 1443) and (ESVersion == 2)) then
    BSS_FW    = fw_path.."\\radarss\\xwr12xx_xwr14xx_radarss_ES2.0.bin"
    MSS_FW    = fw_path.."\\masterss\\xwr12xx_xwr14xx_masterss_ES2.0.bin"
elseif((partId == 1443) and (ESVersion == 3))then
    BSS_FW    = fw_path.."\\radarss\\xwr12xx_xwr14xx_radarss_ES3.0.bin"
    MSS_FW    = fw_path.."\\masterss\\xwr12xx_xwr14xx_masterss_ES3.0.bin"
else
    WriteToLog("Inavlid Device partId FW\n" ..partId)
    WriteToLog("Inavlid Device ESVersion\n" ..ESVersion)
end

-- Download BSS Firmware(AR16xx)
if (ar1.DownloadBSSFw(BSS_FW) == 0) then
    WriteToLog("BSS FW Download Success\n", "green")
else
    WriteToLog("BSS FW Download failure\n", "red")
end
RSTD.Sleep(2000)

-- Download MSS Firmware
if (ar1.DownloadMSSFw(MSS_FW) == 0) then
    WriteToLog("MSS FW Download Success\n", "green")
else
    WriteToLog("MSS FW Download failure\n", "red")
end
RSTD.Sleep(2000)

-- SPI Connect
if (ar1.PowerOn(1, 1000, 0, 0) == 0) then
    WriteToLog("Power On Success\n", "green")
else
   WriteToLog("Power On failure\n", "red")
end
RSTD.Sleep(1000)

-- RF Power UP
if (ar1.RfEnable() == 0) then
    WriteToLog("RF Enable Success\n", "green")
else
    WriteToLog("RF Enable failure\n", "red")
end
RSTD.Sleep(1000)


-- ********************配置区******************** --
-- ChanNAdcConfig(Tx1,Tx2,Tx3,Rx1,Rx2,Rx3,Rx4, , )
--if (ar1.ChanNAdcConfig(1, 0, 0, 1, 0, 0, 0, 2, 1, 0) == 0) then
if (ar1.ChanNAdcConfig(1, 0, 0, 1, 0, 0, 0, 2, 1, 0) == 0) then

    WriteToLog("ChanNAdcConfig Success\n", "green")
else
    WriteToLog("ChanNAdcConfig failure\n", "red")
end
RSTD.Sleep(1000)

-- ar1.LPModConfig(0,ADC_Mode)
if (partId == 1642) then
    if (ar1.LPModConfig(0, 1) == 0) then
        WriteToLog("LPModConfig Success\n", "green")
    else
        WriteToLog("LPModConfig failure\n", "red")
    end
else
    if (ar1.LPModConfig(0, 0) == 0) then
        WriteToLog("Regualar mode Cfg Success\n", "green")
    else
        WriteToLog("Regualar mode Cfg failure\n", "red")
    end
end
RSTD.Sleep(2000)

if (ar1.RfInit() == 0) then
    WriteToLog("RfInit Success\n", "green")
else
    WriteToLog("RfInit failure\n", "red")
end
RSTD.Sleep(1000)

if (ar1.DataPathConfig(1, 1, 0) == 0) then
    WriteToLog("DataPathConfig Success\n", "green")
else
    WriteToLog("DataPathConfig failure\n", "red")
end
RSTD.Sleep(1000)

-- ar1.LvdsClkConfig(1,lvds_data_rate)
if (ar1.LvdsClkConfig(1, 1) == 0) then
    WriteToLog("LvdsClkConfig Success\n", "green")
else
    WriteToLog("LvdsClkConfig failure\n", "red")
end
RSTD.Sleep(1000)

-- ar1.LVDSLaneConfig(0,Lane1,Lane2,Lane3,Lane4,MSB_on,0,0)
if(partId == 1642) then
    --if (ar1.LVDSLaneConfig(0, 1, 1, 1, 1, 1, 0, 0) == 0) then
	if (ar1.LVDSLaneConfig(0, 1, 1, 1, 1, 1, 0, 0) == 0) then
        WriteToLog("LVDSLaneConfig Success\n", "green")
    else
        WriteToLog("LVDSLaneConfig failure\n", "red")
    end
elseif ((partId == 1243) or (partId == 1443)) then
    if (ar1.LVDSLaneConfig(0, 1, 1, 1, 1, 1, 0, 0) == 0) then
        WriteToLog("LVDSLaneConfig Success\n", "green")
    else
        WriteToLog("LVDSLaneConfig failure\n", "red")
    end
end
RSTD.Sleep(1000)

-- ar1.ProfileConfig(0,start_freq,idle_time,adc_start_time,ramp_end_time,0,0,0,0,0,0,slope,0,adc_samples,sample_freq,0,0,rx_gain)
if(partId == 1642) then
    --if(ar1.ProfileConfig(0, 77, 100, 6, 80, 0, 0, 0, 0, 0, 0, 22.981, 0, 64, 5000, 0, 0, 30) == 0) then
	if(ar1.ProfileConfig(0, 77, 100, 6, 60, 0, 0, 0, 0, 0, 0, 66.626, 0, 256, 5000, 0, 0, 30) == 0) then
	--if(ar1.ProfileConfig(0, 77, 100, 6, 60, 0, 0, 0, 0, 0, 0, 33, 0, 256, 5000, 0, 0, 30) == 0) then
	--if(ar1.ProfileConfig(0, 77, 50, 6, 60, 0, 0, 0, 0, 0, 0, 29.982, 0, 256, 5000, 0, 0, 30) == 0) then
      WriteToLog("ProfileConfig Success\n", "green")
   else
       WriteToLog("ProfileConfig failure\n", "red")
   end
elseif((partId == 1243) or (partId == 1443)) then
   if(ar1.ProfileConfig(0, 77, 100, 6, 60, 0, 0, 0, 0, 0, 0, 29.982, 0, 256, 10000, 0, 0, 30) == 0) then
       WriteToLog("ProfileConfig Success\n", "green")
   else
       WriteToLog("ProfileConfig failure\n", "red")
   end
end
RSTD.Sleep(1000)

-- ar1.ChirpConfig(0,0,0,0,0,0,0,Tx1_Enable,Tx2_Enable,Tx3_Enable)
if (ar1.ChirpConfig(0, 0, 0, 0, 0, 0, 0, 1, 0, 0) == 0) then
   WriteToLog("ChirpConfig Success\n", "green")
else
   WriteToLog("ChirpConfig failure\n", "red")
end
RSTD.Sleep(1000)

-- ar1.FrameConfig(start_chirp_tx,end_chirp_tx,nframes,nchirp_loops,Inter_Frame_Interval,0,trig_list)
if (ar1.FrameConfig(0, 0, 1024, 16, 47, 0, 1) == 0) then
--if (ar1.FrameConfig(0, 0, 128, 128, 100, 0, 1) == 0) then
   WriteToLog("FrameConfig Success\n", "green")
else
   WriteToLog("FrameConfig failure\n", "red")
end
RSTD.Sleep(1000)

--select Device type
if (ar1.SelectCaptureDevice("DCA1000") == 0) then
   WriteToLog("SelectCaptureDevice Success\n", "green")
else
   WriteToLog("SelectCaptureDevice failure\n", "red")
end
RSTD.Sleep(1000)

--DATA CAPTURE CARD API
if (ar1.CaptureCardConfig_EthInit("192.168.33.30", "192.168.33.180", "12:34:56:78:90:12", 4096, 4098) == 0) then
   WriteToLog("CaptureCardConfig_EthInit Success\n", "green")
else
   WriteToLog("CaptureCardConfig_EthInit failure\n", "red")
end
RSTD.Sleep(1000)

--AR12xx or AR14xx-1, AR16xx- 2 (second parameter indicates the device type)
if (partId == 1642) then
   if (ar1.CaptureCardConfig_Mode(1, 2, 1, 2, 3, 30) == 0) then
       WriteToLog("CaptureCardConfig_Mode Success\n", "green")
   else
       WriteToLog("CaptureCardConfig_Mode failure\n", "red")
   end
elseif ((partId == 1243) or (partId == 1443)) then
   if (ar1.CaptureCardConfig_Mode(1, 1, 1, 2, 3, 30) == 0) then
       WriteToLog("CaptureCardConfig_Mode Success\n", "green")
   else
       WriteToLog("CaptureCardConfig_Mode failure\n", "red")
   end
end
RSTD.Sleep(1000)

if (ar1.CaptureCardConfig_PacketDelay(25) == 0) then
   WriteToLog("CaptureCardConfig_PacketDelay Success\n", "green")
else
   WriteToLog("CaptureCardConfig_PacketDelay failure\n", "red")
end
RSTD.Sleep(1000)
