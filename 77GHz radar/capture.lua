--此脚本用于控制采集过程的开始和结束
ar1.CaptureCardConfig_StartRecord(adc_data_path, 1)--DCA1000开始收集
ar1.StartFrame()--AWR1642开始采集
RSTD.Sleep(23400)--单位：毫秒。sleep时长大于采集时长，目的是给mmWave Studio采集完后的其他操作给出时间
ar1.StopFrame()--AWR1642停止采集
ar1.CaptureCardConfig_StopRecord()--DCA1000停止收集