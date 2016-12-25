
class CProcessesInputContext : public ILogParserInputContext
{

public:
	CProcessesInputContext();
	~CProcessesInputContext();

	//IUnknown methods
	ULONG __stdcall AddRef();
	ULONG __stdcall Release();
	HRESULT __stdcall QueryInterface(REFIID iid, void** ppv);


	//ILogParserInputContext methods
	HRESULT STDMETHODCALLTYPE OpenInput( IN BSTR bszFromEntity );
    	HRESULT STDMETHODCALLTYPE GetFieldCount( OUT DWORD *pnFields );
    	HRESULT STDMETHODCALLTYPE GetFieldName(	IN DWORD fIndex, OUT BSTR *pbszFieldName );
    	HRESULT STDMETHODCALLTYPE GetFieldType(	IN DWORD fIndex, OUT DWORD *pnFieldType );
    	HRESULT STDMETHODCALLTYPE ReadRecord( OUT VARIANT_BOOL *pbDataAvailable );
    	HRESULT STDMETHODCALLTYPE GetValue( IN DWORD fIndex, OUT VARIANT *pvarValue );
    	HRESULT STDMETHODCALLTYPE CloseInput( IN VARIANT_BOOL bAbort );

private:

	//Handle of the processes snapshot
	HANDLE			m_hSnapshot;

	//Current process information
	PROCESSENTRY32	m_processEntry32;

	//IUnknown object reference counter
	ULONG			m_cRef;
};
