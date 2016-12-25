// Main.cpp : Defines the entry point for the DLL 
//

#include <windows.h>
#include <oleauto.h>
#include <tlhelp32.h>
#include <stdio.h>


#define INITGUID

#include <guiddef.h>

#include "ILogParserInputContext.hxx"

//CLSID of the ProcessesInputContext COM object
DEFINE_GUID(CLSID_ProcessesInputContext,              /* 89698A30-5873-4491-8394-2FEEFF2D5FB9 */
    0x89698a30, 0x5873, 0x4491, 0x83, 0x94, 0x2f, 0xee, 0xff, 0x2d, 0x5f, 0xb9);
#define CLSID_ProcessesInputContext_TEXT	"{89698A30-5873-4491-8394-2FEEFF2D5FB9}"

#undef INITGUID


#include "ProcessesInputContext.h"
#include "ClassFactory.h"

//Registry helper functions
BOOL SetKeyAndValue(const char* pszPath, const char* szSubkey, const char* szValue);
BOOL RecursiveDeleteKey(HKEY hKeyParent, const char* szKeyChild);

//External counter of live objects in this dll
long g_cComponents = 0;

//Handle to this module
HANDLE g_hModule;

BOOL APIENTRY DllMain( HANDLE hModule, 
                       DWORD  ul_reason_for_call, 
                       LPVOID lpReserved
					 )
{
	//Store this module handle
	g_hModule=hModule;

    return TRUE;
}

HRESULT __stdcall DllCanUnloadNow()
{
	//The DLL can be unloaded only if it's not hosting any object

	if( g_cComponents == 0 )
		return S_OK;
	else
		return S_FALSE;
}

HRESULT __stdcall DllGetClassObject(REFCLSID clsid, REFIID iid, void** ppv)
{
	if ( clsid == CLSID_ProcessesInputContext )
	{
		//Create class factory

		CProcessInputContextClassFactory *pCF = new CProcessInputContextClassFactory;
		if( pCF == NULL )
			return E_OUTOFMEMORY;

		//Retrieve the requested interface

		HRESULT hr = pCF->QueryInterface( iid, ppv );
		if( FAILED( hr ) )
		{
			*ppv = NULL;
		}

		pCF->Release();

		return S_OK;
	}
	else
	{
		//We do not implement the requested class factory

		return CLASS_E_CLASSNOTAVAILABLE;
	}
}

HRESULT __stdcall DllRegisterServer()
{
	// Get this dll location.
	char szModule[512];
	GetModuleFileNameA((HMODULE)g_hModule, szModule, sizeof(szModule));
  
	// Add the CLSID to the registry.
	SetKeyAndValue("CLSID\\" CLSID_ProcessesInputContext_TEXT, NULL, "LogQuery.Sample.Processes");

	// Add the server filename subkey under the CLSID key.
	SetKeyAndValue("CLSID\\" CLSID_ProcessesInputContext_TEXT, "InprocServer32", szModule);

	// Add the ProgID subkey under the CLSID key.
	SetKeyAndValue("CLSID\\" CLSID_ProcessesInputContext_TEXT, "ProgID", "MSUtil.LogQuery.Sample.Processes.1");

	// Add the version-independent ProgID subkey under CLSID key.
	SetKeyAndValue("CLSID\\" CLSID_ProcessesInputContext_TEXT, "VersionIndependentProgID", "MSUtil.LogQuery.Sample.Processes");

	// Add the version-independent ProgID subkey under HKEY_CLASSES_ROOT.
	SetKeyAndValue("MSUtil.LogQuery.Sample.Processes", NULL, "LogQuery.Sample.Processes"); 
	SetKeyAndValue("MSUtil.LogQuery.Sample.Processes", "CLSID", CLSID_ProcessesInputContext_TEXT);
	SetKeyAndValue("MSUtil.LogQuery.Sample.Processes", "CurVer", "MSUtil.LogQuery.Sample.Processes.1");

	// Add the versioned ProgID subkey under HKEY_CLASSES_ROOT.
	SetKeyAndValue("MSUtil.LogQuery.Sample.Processes.1", NULL, "LogQuery.Sample.Processes"); 
	SetKeyAndValue("MSUtil.LogQuery.Sample.Processes.1", "CLSID", CLSID_ProcessesInputContext_TEXT);

	return S_OK;
}

HRESULT __stdcall DllUnregisterServer()
{
	// Delete the CLSID Key
	RecursiveDeleteKey(HKEY_CLASSES_ROOT, "CLSID\\" CLSID_ProcessesInputContext_TEXT);

	// Delete the version-independent ProgID Key.
	RecursiveDeleteKey(HKEY_CLASSES_ROOT, "MSUtil.LogQuery.Sample.Processes.1");

	// Delete the ProgID key.
	RecursiveDeleteKey(HKEY_CLASSES_ROOT, "MSUtil.LogQuery.Sample.Processes.1");

	return S_OK;
}



// Registry helper functions

BOOL SetKeyAndValue(const char* szKey, const char* szSubkey, const char* szValue)
{
	HKEY hKey;
	char szKeyBuf[1024];

	// Add subkey name to buffer.
	if(szSubkey != NULL)
	 _snprintf(szKeyBuf, 1024, "%s\\%s", szKey, szSubkey);
	else
	 strncpy(szKeyBuf, szKey, 1024);
	szKeyBuf[1023]='\0';

	// Create and open key and subkey.
	long lResult = RegCreateKeyExA(HKEY_CLASSES_ROOT, szKeyBuf, 0, NULL, REG_OPTION_NON_VOLATILE, KEY_ALL_ACCESS, NULL, &hKey, NULL);
	if(lResult != ERROR_SUCCESS)
		return FALSE;

	// Set the Value.
	if(szValue != NULL)
		RegSetValueExA(hKey, NULL, 0, REG_SZ, (BYTE *)szValue, strlen(szValue)+1);

	RegCloseKey(hKey);
	return TRUE;
}

BOOL RecursiveDeleteKey(HKEY hKeyParent, const char* lpszKeyChild)
{
	// Open the child.
	HKEY hKeyChild;
	LONG lRes = RegOpenKeyExA(hKeyParent, lpszKeyChild, 0, KEY_ALL_ACCESS, &hKeyChild);
	if(lRes != ERROR_SUCCESS)
		return FALSE;

	// Enumerate all of the decendents of this child.
	FILETIME time;
	char szBuffer[256];
	DWORD dwSize = 256;
	while(RegEnumKeyExA(hKeyChild, 0, szBuffer, &dwSize, NULL, NULL, NULL, &time) == S_OK)
	{
		// Delete the decendents of this child.
		if( !RecursiveDeleteKey(hKeyChild, szBuffer) )
		{
			// Cleanup before exiting.
			RegCloseKey(hKeyChild);
			return FALSE;
		}

		dwSize = 256;
	}

	// Close the child.
	RegCloseKey(hKeyChild);

	// Delete this child.
	lRes = RegDeleteKeyA(hKeyParent, lpszKeyChild);

	return (lRes == ERROR_SUCCESS);
}
