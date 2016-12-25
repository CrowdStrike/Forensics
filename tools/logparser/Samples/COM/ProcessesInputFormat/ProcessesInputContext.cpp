/*
This sample implements the ILogParserInputContext interface to generate process information that
 can be supplied to Log Parser.
The process information is retrieved from the "ToolHelp32" API's.
*/


#include <windows.h>
#include <oleauto.h>
#include <tlhelp32.h>

#include "ILogParserInputContext.hxx"

#include "ProcessesInputContext.h"


//External counter of live objects in this dll
extern long g_cComponents;


//Constructor

CProcessesInputContext::CProcessesInputContext()
{
	m_cRef = 1;

	//This DLL is currently hosting this object
	g_cComponents++;

	//Initialize the snapshot
	m_hSnapshot = INVALID_HANDLE_VALUE;

	//Initialize our PROCESSENTRY32 struct
	m_processEntry32.dwSize = sizeof( m_processEntry32 );
}

//Destructor

CProcessesInputContext::~CProcessesInputContext()
{
	//Close the snapshot handle
	if( m_hSnapshot != INVALID_HANDLE_VALUE )
	{
		CloseHandle( m_hSnapshot );
		m_hSnapshot = INVALID_HANDLE_VALUE;
	}

	//This DLL is not hosting this object anymore
	g_cComponents--;
}

//IUnknown methods

ULONG CProcessesInputContext::AddRef()
{
	return ++m_cRef;
}

ULONG CProcessesInputContext::Release()
{
	if(--m_cRef != 0)
		return m_cRef;

	delete this;

	return 0;
}

HRESULT CProcessesInputContext::QueryInterface(REFIID riid, void** ppv)
{
	if(riid == IID_IUnknown)
		*ppv = (IUnknown*)this;
	else if(riid == IID_ILogParserInputContext)
		*ppv = (ILogParserInputContext*)this;
	else 
	{
		//We have been asked for an interface that we do not implement...

		*ppv = NULL;

		return E_NOINTERFACE;
	}

	AddRef();

	return S_OK;
}



// ILogParserInputContext methods

HRESULT CProcessesInputContext::OpenInput( IN BSTR bszFromEntity )
{
	//Nothing to do here...
	//...and we don't care for the from-entity

	return S_OK;
}

HRESULT CProcessesInputContext::GetFieldCount( OUT DWORD *pnFields )
{
	//This Input Context just exports 4 fields

	*pnFields = 4;

	return S_OK;
}

HRESULT CProcessesInputContext::GetFieldName(	IN DWORD fIndex, OUT BSTR *pbszFieldName )
{
	switch(fIndex)
	{
		case 0:	{
					*pbszFieldName = SysAllocString(L"ImageName");
					break;
				}

		case 1:	{
					*pbszFieldName = SysAllocString(L"PID");
					break;
				}

		case 2:	{
					*pbszFieldName = SysAllocString(L"ParentPID");
					break;
				}

		case 3:	{
					*pbszFieldName = SysAllocString(L"Threads");
					break;
				}
	}

	return S_OK;
}

HRESULT CProcessesInputContext::GetFieldType(	IN DWORD fIndex, OUT DWORD *pnFieldType )
{
	switch(fIndex)
	{
		case 0:	{
					//ImageName
					*pnFieldType = ILogParserInputContext::String;
					break;
				}

		case 1:	{
					//PID
					*pnFieldType = ILogParserInputContext::Integer;
					break;
				}

		case 2:	{
					//ParentPID
					*pnFieldType = ILogParserInputContext::Integer;
					break;
				}

		case 3:	{
					//Threads
					*pnFieldType = ILogParserInputContext::Integer;
					break;
				}
	}

	return S_OK;
}

HRESULT CProcessesInputContext::ReadRecord( OUT VARIANT_BOOL *pbDataAvailable )
{
	if( m_hSnapshot == INVALID_HANDLE_VALUE )
	{
		//This is the first time we have been called

		//Get a shapshot of the current processes
		m_hSnapshot = CreateToolhelp32Snapshot( TH32CS_SNAPPROCESS, 0 );
		if( m_hSnapshot == INVALID_HANDLE_VALUE )
		{
			//Error
			return HRESULT_FROM_WIN32( GetLastError() );
		}

		//Get the first entry
		if( !Process32First( m_hSnapshot, &m_processEntry32 ) )
		{
			DWORD dwLastError = GetLastError();
			if( dwLastError == ERROR_NO_MORE_FILES )
			{
				//No processes
				*pbDataAvailable = VARIANT_FALSE;
				return S_OK;
			}
			else
			{
				//Error
				return HRESULT_FROM_WIN32( GetLastError() );
			}
		}
		else
		{
			//There is data available
			*pbDataAvailable = VARIANT_TRUE;
			return S_OK;
		}
	}
	else
	{
		//We have already been called before, and we have already taken a snapshot

		//Get the next entry
		if( !Process32Next( m_hSnapshot, &m_processEntry32 ) )
		{
			DWORD dwLastError = GetLastError();
			if( dwLastError == ERROR_NO_MORE_FILES )
			{
				//No more processes
				*pbDataAvailable = VARIANT_FALSE;
				return S_OK;
			}
			else
			{
				//Error
				return HRESULT_FROM_WIN32( GetLastError() );
			}
		}
		else
		{
			//There is data available
			*pbDataAvailable = VARIANT_TRUE;
			return S_OK;
		}
	}
}

HRESULT CProcessesInputContext::GetValue( IN DWORD fIndex, OUT VARIANT *pvarValue )
{
	//Initialize return value
	VariantInit( pvarValue );
	

	switch(fIndex)
	{
		case 0:	{
					//ImageName
					V_VT( pvarValue ) = VT_BSTR;
					V_BSTR( pvarValue ) = SysAllocString( m_processEntry32.szExeFile );
					break;
				}

		case 1:	{
					//PID
					V_VT( pvarValue ) = VT_I4;
					V_I4( pvarValue ) = m_processEntry32.th32ProcessID;
					break;
				}

		case 2:	{
					//ParentPID
					V_VT( pvarValue ) = VT_I4;
					V_I4( pvarValue ) = m_processEntry32.th32ParentProcessID;
					break;
				}

		case 3:	{
					//Threads
					V_VT( pvarValue ) = VT_I4;
					V_I4( pvarValue ) = m_processEntry32.cntThreads;
					break;
				}
	}

	return S_OK;
}

HRESULT CProcessesInputContext::CloseInput( IN VARIANT_BOOL bAbort )
{
	//Close the snapshot handle
	if( m_hSnapshot != INVALID_HANDLE_VALUE )
	{
		CloseHandle( m_hSnapshot );
		m_hSnapshot = INVALID_HANDLE_VALUE;
	}
	
	return S_OK;
}