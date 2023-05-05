##Project Purpose:  
The project uses 77 GHz and 120 GHz FMCW radar for non-contact vital sign detection and aims to find the optimal vital sign detection method.

##Project equipment:  
77GHz radar system(AWR1642+DCA1000EVM);  
120GHz radar system(SiRad Easy r4 EvalKit).  
                  
##Project procedures:  
(1)Collect samples(store in 'bin'file)   
(2)Echo Signal Preprocessing  
(3)Extract vital signs signals  

##Algorithms that have been tried:  
(1)Methods of Phase extraction:arctangent demodulation、DACM、modified DACM  
(2)Methods of respiration and heartbeat extraction:Digital filter、CWT、EEMD、MODWT  

##Conclusion:  
120 GHz radar is better than the 77 GHz radar in detecting vital signs.  
The detection accuracy of MODWT is higher than other algorithms under the same radar system.  

##The optimal strategy:  
Arctangent demodulation + MODWT method + MUSIC frequency estimation  
