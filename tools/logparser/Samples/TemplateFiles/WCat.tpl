<LPHEADER>[Configuration]
NumClientMachines:    1        # number of distinct client machines to use
NumClientThreads:     100     # number of threads per machine
AsynchronousWait:     TRUE     # asynchronous wait for think and delay
Duration:             5m      # length of experiment (m = minutes, s = seconds)
MaxRecvBuffer:        8192K      # suggested maximum received buffer
ThinkTime:            0s       # maximum think-time before next request
WarmupTime:           5s      # time to warm up before taking statistics
CooldownTime:         6s      # time to cool down at the end of the experiment

[Performance]

[Script]
SET RequestHeader = "Accept: */*\r\n"
APP RequestHeader = "Accept-Language: en-us\r\n"
APP RequestHeader = "User-Agent: Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.2; .NET CLR 1.0.3705)\r\n"
APP RequestHeader = "Host: %HOST%\r\n"

</LPHEADER>
<LPBODY>
NEW TRANSACTION
	classId = %UID%
	NEW REQUEST HTTP
	ResponseStatusCode = %STATUS%
	Weight = %TOTAL%
	verb = "%VERB%"
        URL = "%URI%"
	

</LPBODY>
<LPFOOTER>

</LPFOOTER>
