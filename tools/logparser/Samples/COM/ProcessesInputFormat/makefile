
# Type here the path to your SDK include files
INCLUDES=C:\PROGRA~1\MICROS~2.NET\VC7\PlatformSDK\Include

# Type here the path to your C runtime include files
INCLUDES_CRT=C:\PROGRA~1\MICROS~2.NET\VC7\include

# Type here the path to your SDK libraries
SDKLIBPATH=C:\PROGRA~1\MICROS~2.NET\VC7\PlatformSDK\Lib

# Type here the path to your C runtime libraries
CRTLIBPATH=C:\PROGRA~1\MICROS~2.NET\VC7\lib

OBJ=ProcessesInputContext.obj Main.obj

.cpp.obj:
	cl /c /nologo /MT /W3 /GX /O2 /D "NDEBUG" /D "WIN32" /D "_WINDOWS" /D "_USRDLL" /D "UNICODE" /I$(INCLUDES) /I$(INCLUDES_CRT) $*.cpp

ProcessesInputContext.dll: $(OBJ)
	cl *.obj advapi32.lib oleaut32.lib ProcessesInputContext.def /LD /link /libpath:$(SDKLIBPATH) /libpath:$(CRTLIBPATH) /out:ProcessesInputContext.dll

$(OBJ): 