
extern long g_cComponents;

class CProcessInputContextClassFactory : public IClassFactory
{

public:

	CProcessInputContextClassFactory()
	{
		m_cRef = 1;
		g_cComponents++;
	};
	
	~CProcessInputContextClassFactory()
	{
		g_cComponents--;
	};


	//IUnknown methods

	HRESULT __stdcall QueryInterface( REFIID riid, LPVOID * ppv )
	{
		if ( riid == IID_IUnknown  || riid == IID_IClassFactory )
		{
			*ppv = (IClassFactory*)(this);
		}
		else
		{   
			*ppv = NULL;
			return E_NOINTERFACE;
		}

		AddRef();

		return S_OK;
	};

	ULONG __stdcall AddRef()
	{
		return ++m_cRef;
	};

	STDMETHODIMP_(ULONG) Release()
	{
		if(--m_cRef != 0)
		 return m_cRef;

		delete this;

		return 0;
	};



	// IClassFactory methods

	HRESULT __stdcall CreateInstance(IUnknown *pUnk, REFIID riid, void **ppv)
	{
		if( pUnk!=NULL )
		{
			return CLASS_E_NOAGGREGATION;
		}

		CProcessesInputContext *pObj = new CProcessesInputContext;
		if ( pObj == NULL )
		{
			return E_OUTOFMEMORY;
		}

		HRESULT hr = pObj->QueryInterface ( riid, ppv );
		pObj->Release();
		if ( FAILED(hr) )
		{
			delete pObj;
		}

		return hr;
	}

    HRESULT __stdcall LockServer(BOOL bLock)
	{
		return S_OK;
	}

private:

	//IUnknown object reference counter
	ULONG			m_cRef;

};


