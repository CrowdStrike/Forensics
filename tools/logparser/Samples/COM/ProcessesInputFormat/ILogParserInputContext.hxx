
#ifndef _ILOGPARSERINPUTCONTEXT_HXX_
#define _ILOGPARSERINPUTCONTEXT_HXX_

//
// Interface GUID
//

DEFINE_GUID(IID_ILogParserInputContext,             /* 27E78867-48AB-433c-9AFD-9D78D8B1CFC7 */
    0x27E78867,0x48AB,0x433C,0x9A, 0xFD, 0x9D, 0x78, 0xD8, 0xB1, 0xCF, 0xC7);


//
// LogParserInputContext Interface implemented by Log Parser Input plugins and called by Log Parser. 
//

class ILogParserInputContext  : public IUnknown
{
    public:

    enum FieldType
    {
        Integer     =1,
        Real        =2,
        String      =3,
        Timestamp   =4,
        Null        =5
    };

    virtual HRESULT STDMETHODCALLTYPE
    OpenInput( IN BSTR bszFromEntity ) =0;

    virtual HRESULT STDMETHODCALLTYPE
    GetFieldCount( OUT DWORD *pnFields ) = 0;

    virtual HRESULT STDMETHODCALLTYPE
    GetFieldName( IN DWORD fIndex,
                  OUT BSTR *pbszFieldName ) = 0;

    virtual HRESULT STDMETHODCALLTYPE
    GetFieldType( IN DWORD fIndex,
                  OUT DWORD *pnFieldType ) = 0;

    virtual HRESULT STDMETHODCALLTYPE
    ReadRecord( OUT VARIANT_BOOL *pbDataAvailable ) =0;

    virtual HRESULT STDMETHODCALLTYPE
    GetValue( IN DWORD fIndex,
              OUT VARIANT *pvarValue ) =0;

    virtual HRESULT STDMETHODCALLTYPE
    CloseInput( IN VARIANT_BOOL bAbort ) =0;
};



#endif //_ILOGPARSERINPUTCONTEXT_HXX_