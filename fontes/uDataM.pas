unit uDataM;

interface

uses
  Windows, SysUtils, Classes, Dialogs, Forms, Controls, WinSock2, Messages,
  DB, DBClient, rtTypes, Consts, StdCtrls, StrUtils, Ioctl, PsAPI, rxToolEdit,
  FIBDatabase, pFIBDatabase, FIBDataSet, pFIBDataSet, FIBSQLMonitor, FIBQuery, pFIBQuery;

type
  TfDataM = class(TDataModule)
    FIB_Db: TpFIBDatabase;
    FIB_Tr: TpFIBTransaction;
    QueryDM: TpFIBQuery;
    TransDM: TpFIBTransaction;
    QueryData: TpFIBQuery;
    TransDATA: TpFIBTransaction;
    QueryDMGrava: TpFIBQuery;
    TransDMGrava: TpFIBTransaction;
    QueryBusca: TpFIBQuery;
    TransBusca: TpFIBTransaction;
    procedure DataModuleCreate(Sender: TObject);
  private
    fLoaded: Boolean;
    fEmpresa: Integer;
    fUsuario: Integer;
    fEmpresaNome, fEmpresaApel, fEmpresaCPFC: String;
    procedure pCriaTabelas;
  public
    LastClassName: string;
    procedure AppOnMessage(var Msg: TMsg; var Handled: Boolean);
    procedure AppOnException(Sender: TObject; E: Exception);

    function  fDataHoraServidor: TDateTime;
    procedure pGerarCategorias(prEmpresa: Integer);
    procedure pGerarHistoricos(prEmpresa: Integer);
    procedure pGerarBandeiras;
    property  Loaded: Boolean read fLoaded;
    property  Empresa: Integer read fEmpresa;
    property  Usuario: Integer read fUsuario;
    property  EmpresaNome: String read fEmpresaNome write fEmpresaNome;
    property  EmpresaApel: String read fEmpresaApel write fEmpresaApel;
    property  EmpresaCPFC: String read fEmpresaCPFC write fEmpresaCPFC;

    function  fBuscaMoeda(prMoeda: Integer): String;
    function  fBuscaCartao(prTip, prCod: Integer): String;
    function  fBuscaStatusFATURA(prSTA: Integer): String;
    function  fBuscaStatusPARCE(prSTA: Integer): String;
    function  fBuscaStatusBAIXA(prSTA: Integer): String;
  end;

var
  fDataM: TfDataM;
LastActive: TDateTime=0;

function  FIBQueryCriar(var prQuery: TpFIBQuery; var prTrans: TpFIBTransaction): Boolean; overload;
function  FIBQueryCriar(var prQuery: TFIBDataSet; var prTrans: TpFIBTransaction): Boolean; overload;
procedure FIBQueryDestruir(prQuery: TpFIBQuery); overload;
procedure FIBQueryDestruir(prQuery: TFIBDataSet); overload;
procedure FIBQueryAtribuirSQL(prQuery: TpFIBQuery; prSQLTexto: WideString); overload;
procedure FIBQueryAtribuirSQL(prQuery: TpFIBDataSet; prSQLTexto: WideString); overload;
procedure FIBQueryCommit(prQuery: TpFIBQuery);
procedure FIBQueryRollback(prQuery: TpFIBQuery);
procedure FIBCriaGenerator(prQuery: TpFIBQuery; prNomeGenerator: String);
function  fGetGenerator(prNome: string; prIncremento: Integer = 1): Integer;
function  fGetMax(prTab, prCam: String; prEmpre: Boolean): Integer;
function  fPastaScript: String;
function  fLoadFromScript(const prFileName: String): WideString;
function  fEstaCadastrado(prCodigo: Integer; prTabela, prCampo: String; prEmpre: Boolean): Boolean;
procedure pPreencheCombo(prCombo: TComboBox; prTab, prCod, prDes: String; prEmpre: Boolean);
procedure pControlesTabela(prDataSet: TDataSet; prHabilitar: boolean);

function CampoExiste(Tabela, Campo: String): Boolean;
function TabelaExiste(Tabela: String): Boolean;
function TriggerExiste(Trigger: String): Boolean;
function ProcedureExiste(Proc: String): Boolean;
function GeneratorExiste(Gen: String): Boolean;

function GetAppVersion(): string;
function fGetVersao(prVersao: string): string;
function GetNroBuild(prVersao: string): string;
function GetFileSize(const FileName: String): Int64;
function GetFileDate(const FileName: String): TDateTime;
function GetProcessMemorySize(_sProcessName: string; var _nMemSize: Cardinal): Boolean;
function VolumeInfo(DriveLetter: string = ''): string;
function GetIP(HostName: string=''): string;
function GetMacAddress(const IPAddress: string): string; overload;
function GetMacAddress: string; overload;
function CurrentProcessMemory(): Cardinal;
function LoadFromFileEx(const AFileName: string; Length: DWord): string;
procedure FileList(var List: TStringList; SearchFile: string = '*'; DoRecursive: Boolean = False);

implementation

uses ucLogin, rtTypesCat, DateUtils;

{$R *.dfm}

function FIBQueryCriar(var prQuery: TpFIBQuery; var prTrans: TpFIBTransaction): Boolean;
begin
  prQuery := TpFIBQuery.Create(nil);
  prTrans := TpFIBTransaction.Create(nil);
  prTrans.DefaultDatabase := fDataM.FIB_Db;
  prQuery.Transaction     := prTrans;
  Result := (prTrans <> nil) and (prQuery <> nil);
end;

function FIBQueryCriar(var prQuery: TFIBDataSet; var prTrans: TpFIBTransaction): Boolean;
begin
  prQuery := TFIBDataSet.Create(nil);
  prTrans := TpFIBTransaction.Create(nil);
  prTrans.DefaultDatabase := fDataM.FIB_Db;
  prQuery.Transaction     := prTrans;
  Result := (prTrans <> nil) and (prQuery <> nil);
end;

procedure FIBQueryDestruir(prQuery: TpFIBQuery);
begin
  if (prQuery <> nil) then
  begin
    if prQuery.Transaction.InTransaction then
      prQuery.Transaction.Rollback;

    prQuery.Close;

    if (prQuery.Transaction <> nil) then
      prQuery.Transaction.Free;

    prQuery.Free;
  end;
end;

procedure FIBQueryDestruir(prQuery: TFIBDataSet);
begin
  if (prQuery <> nil) then
  begin
    if prQuery.Transaction.InTransaction then
      prQuery.Transaction.Rollback;

    prQuery.Close;

    if (prQuery.Transaction <> nil) then
      prQuery.Transaction.Free;

    prQuery.Free;
  end;
end;

procedure FIBQueryAtribuirSQL(prQuery: TpFIBQuery; prSQLTexto: WideString);
begin
  if (prQuery <> nil) then
  begin
    if not prQuery.Transaction.InTransaction then
      prQuery.Transaction.StartTransaction;

    prQuery.Close;
    prQuery.SQL.Text := prSQLTexto;
  end;
end;

procedure FIBQueryAtribuirSQL(prQuery: TpFIBDataSet; prSQLTexto: WideString); overload;
begin
  if (prQuery <> nil) then
  begin
    if not prQuery.Transaction.InTransaction then
      prQuery.Transaction.StartTransaction;

    prQuery.Close;
    prQuery.QSelect.SQL.Text := prSQLTexto;
  end;
end;

procedure FIBQueryCommit(prQuery: TpFIBQuery);
begin
  if (prQuery <> nil) and (prQuery.Transaction.InTransaction) then
    prQuery.Transaction.Commit;
end;

procedure FIBQueryRollback(prQuery: TpFIBQuery);
begin
  if (prQuery <> nil) and (prQuery.Transaction.InTransaction) then
    prQuery.Transaction.Rollback;
end;

procedure FIBCriaGenerator(prQuery: TpFIBQuery; prNomeGenerator: String);
var
  wMsgErro: String;
begin
  wMsgErro := 'Criando o generator ' + prNomeGenerator;
  if Length(Trim(prNomeGenerator)) = 0 then
  begin
    raise Exception.Create(wMsgErro + ' - Faltou passar o nome do generator a ser criado');
  end;

  try
    if prQuery <> nil then
    begin
      prQuery.Transaction.StartTransaction;
      prQuery.Close;
      prQuery.SQL.Text := 'CREATE SEQUENCE ' + prNomeGenerator + ';';
      prQuery.ExecQuery;
      prQuery.Transaction.Commit;

      prQuery.Transaction.StartTransaction;
      prQuery.Close;
      prQuery.SQL.Text := 'ALTER SEQUENCE ' + prNomeGenerator + ' RESTART WITH 0;';
      prQuery.ExecQuery;
      prQuery.Transaction.Commit;
    end
    else
    begin
      raise Exception.Create(wMsgErro + ' - Faltou passar a QUERY nos parâmetros');
    end;
  except
    on e: exception do
    begin
      if prQuery.Transaction.Active then
        prQuery.Transaction.Rollback;
      raise Exception.Create(E.Message + #13#10 + wMsgErro);
    end;
  end;
end;

function  fGetGenerator(prNome: string; prIncremento: Integer = 1): Integer;
var
  fQueryLocal: TpFIBQuery;
  fTransLocal: TpFIBTransaction;
begin
  Result := 0;

  fTransLocal := TpFIBTransaction.Create(nil);
  fQueryLocal := TpFIBQuery.Create(nil);

  fTransLocal.DefaultDatabase := fDataM.FIB_Db;
  fQueryLocal.Transaction := fTransLocal;

  fQueryLocal.Transaction.StartTransaction;

  try
    try
      fQueryLocal.SQL.Text := 'SELECT gen_id(' + prNome + ','+IntToStr(prIncremento)+') from rdb$database';
      fQueryLocal.ExecQuery;
      Result := fQueryLocal.Fields[0].AsInteger;
      fQueryLocal.Close;
      fQueryLocal.Transaction.Commit;
    except
      on E:Exception do
      begin
        fQueryLocal.Transaction.Rollback;
        MessageDlg('Erro ao buscar o generator "' + prNome + '"' + eol + e.Message, mtWarning, [mbOk], 0);
      end;
    end;

  finally
    fQueryLocal.Free;
    fTransLocal.Free;
  end;
end;

function  fGetMax(prTab, prCam: String; prEmpre: Boolean): Integer;
var
  fQueryLocal: TpFIBQuery;
  fTransLocal: TpFIBTransaction;
  wWhere: string;
begin
  Result := 0;
  wWhere := '';
  if prEmpre then
    wWhere := ' where Empre='+IntToStr(fDataM.Empresa);

  FIBQueryCriar(fQueryLocal, fTransLocal);
  try
    try
      FIBQueryAtribuirSQL(fQueryLocal, 'SELECT MAX('+prCam+') from '+prTab+wWhere);
      fQueryLocal.ExecQuery;
      Result := fQueryLocal.Fields[0].AsInteger;
      FIBQueryCommit(fQueryLocal);
    except
      on E:Exception do
      begin
        FIBQueryRollback(fQueryLocal);
        MessageDlg('Erro ao buscar máximo código da tabela "'+prTab+'" e campo "'+prCam+'"'+eol+e.Message, mtWarning, [mbOk], 0);
      end;
    end;
  finally
    FIBQueryDestruir(fQueryLocal);
  end;
end;

function  fPastaScript: String;
begin
  Result := ExtractFilePath(ParamStr(0)) + '\Scripts';
end;

function  fLoadFromScript(const prFileName: String): WideString;
var
  wFile: String;
  wSL: TStringList;
begin
  Result := '';
  wFile  := fPastaScript+'\'+prFileName;
  if (wFile <> '') and (FileExists(wFile)) then
  begin
    wSL := TStringList.Create;
    try
      wSL.LoadFromFile(wFile);
      Result := wSL.Text;
    finally
      wSL.Free;
    end;
  end
  else
  begin
    raise Exception.Create('Erro: SCRIPT NÃO ENCONTRADO: "'+wFile+'" - Verifique!');
  end;
end;

function  fEstaCadastrado(prCodigo: Integer; prTabela, prCampo: String; prEmpre: Boolean): Boolean;
var
  fQueryLocal: TpFIBQuery;
  fTransLocal: TpFIBTransaction;
  wWhere: string;
begin
  Result := False;
  wWhere := '';
  if prEmpre then
    wWhere := ' where Empre='+IntToStr(fDataM.Empresa);

  FIBQueryCriar(fQueryLocal, fTransLocal);
  try
    try
      FIBQueryAtribuirSQL(fQueryLocal, 'SELECT '+prCampo+' from '+prTabela+wWhere);
      fQueryLocal.ExecQuery;
      Result := (not fQueryLocal.Eof);
      FIBQueryCommit(fQueryLocal);
    except
      on E:Exception do
      begin
        FIBQueryRollback(fQueryLocal);
        MessageDlg('fEstaCadastrado: Erro ao verificar se o "'+prCampo+'" está cadastrado na tabela "'+prTabela+'"'+eol+e.Message, mtWarning, [mbOk], 0);
      end;
    end;
  finally
    FIBQueryDestruir(fQueryLocal);
  end;
end;

procedure pPreencheCombo(prCombo: TComboBox; prTab, prCod, prDes: String; prEmpre: Boolean);
var
  fQueryLocal: TpFIBQuery;
  fTransLocal: TpFIBTransaction;
  wWhere,wOrder: string;
begin
  prCombo.Items.Clear;
  wWhere := '';
  if prEmpre then
    wWhere := ' where Empre='+IntToStr(fDataM.Empresa);
  wOrder := ' order by '+prCod;
  FIBQueryCriar(fQueryLocal, fTransLocal);
  try
    try
      FIBQueryAtribuirSQL(fQueryLocal, 'SELECT '+prCod+', '+prDes+' from '+prTab+wWhere+wOrder);
      fQueryLocal.ExecQuery;
      while (not fQueryLocal.Eof) do
      begin
        prCombo.Items.AddObject(fQueryLocal.FieldByName(prDes).AsString, Pointer(fQueryLocal.FieldByName(prCod).AsInteger));
        fQueryLocal.Next;
      end;
      FIBQueryCommit(fQueryLocal);
    except
      on E:Exception do
      begin
        FIBQueryRollback(fQueryLocal);
        MessageDlg('Erro ao preencher a lista de opções da "'+prTab+'" e campo "'+prDes+'"'+eol+e.Message, mtWarning, [mbOk], 0);
      end;
    end;
  finally
    FIBQueryDestruir(fQueryLocal);
  end;
end;

procedure pControlesTabela(prDataSet: TDataSet; prHabilitar: boolean);
begin
  if (prDataSet <> nil) then
  begin
    if (prHabilitar) and (prDataSet.ControlsDisabled) then
      prDataSet.EnableControls
    else
      if (not prHabilitar) and (not prDataSet.ControlsDisabled) then
        prDataSet.DisableControls;
  end;
end;

function CampoExiste(Tabela, Campo: String): Boolean;
var
  wQuery: TpFIBQuery;
  wTrans: TpFIBTransaction;
begin
  Result := False;
  if Length(Trim(Tabela)) = 0 then Exit;
  if Length(Trim(Campo)) = 0 then Exit;

  FIBQueryCriar(wQuery, wTrans);
  try
    // Verifica se a tabela existe
    FIBQueryAtribuirSQL(wQuery, 'Select count(*) From rdb$relations where rdb$relations.rdb$relation_name = :Tabela');
    wQuery.ParamByName('Tabela').AsString := AnsiUpperCase(Tabela);
    wQuery.ExecQuery;
    if (wQuery.Fields[00].AsInteger > 0) then
    begin
      // Seleciona o campo nas tabelas de sistema
      FIBQueryAtribuirSQL(wQuery, 'Select Count(rdb$relation_fields.rdb$field_name)' +
                                  'From rdb$relations, rdb$relation_fields ' +
                                  'Where rdb$relations.rdb$relation_name = rdb$relation_fields.rdb$relation_name ' +
                                  'And   rdb$relations.rdb$relation_name = :Tabela ' +
                                  'And   rdb$relation_fields.rdb$field_name = :Campo');
      wQuery.ParamByName('Tabela').AsString := AnsiUpperCase(Tabela);
      wQuery.ParamByName('Campo').AsString  := AnsiUpperCase(Campo);
      wQuery.ExecQuery;
      // Se existir retorna verdadeiro, senao falso
      Result := (wQuery.Fields[00].AsInteger > 0);
    end
    else
    begin
      raise Exception.Create('Erro ao verificar se o campo existe: A tabela "' + Tabela + '" não existe. Verifique!');
    end;
  finally
    FIBQueryDestruir(wQuery);
  end;
end;

function TabelaExiste(Tabela: String): Boolean;
var
  wQuery: TpFIBQuery;
  wTrans: TpFIBTransaction;
begin
  Result := False;
  if Length(Trim(Tabela)) = 0 then Exit;

  FIBQueryCriar(wQuery, wTrans);
  try
    FIBQueryAtribuirSQL(wQuery, 'Select count(*) From rdb$relations where rdb$relations.rdb$relation_name = :Tabela');
    wQuery.ParamByName('Tabela').AsString := AnsiUpperCase(Tabela);
    wQuery.ExecQuery;
    Result := (wQuery.Fields[00].AsInteger > 0);
  finally
    FIBQueryDestruir(wQuery);
  end;
end;

function TriggerExiste(Trigger: String): Boolean;
var
  wQuery: TpFIBQuery;
  wTrans: TpFIBTransaction;
begin
  FIBQueryCriar(wQuery, wTrans);
  try
    FIBQueryAtribuirSQL(wQuery, 'select count(rdb$triggers.rdb$trigger_name) from rdb$triggers '+
                                'where rdb$triggers.rdb$trigger_name = :Trig');
    wQuery.ParamByName('Trig').AsString := AnsiUpperCase(Trigger);
    wQuery.ExecQuery;
    Result := (wQuery.Fields[00].AsInteger > 0);
  finally
    FIBQueryDestruir(wQuery);
  end;
end;

function ProcedureExiste(Proc: String): Boolean;
var
  wQuery: TpFIBQuery;
  wTrans: TpFIBTransaction;
begin
  FIBQueryCriar(wQuery, wTrans);
  try
    FIBQueryAtribuirSQL(wQuery, 'select Count(rdb$procedures.rdb$procedure_name) from rdb$procedures ' +
                                'where rdb$procedures.rdb$procedure_name = :Proc');
    wQuery.ParamByName('Proc').AsString := AnsiUpperCase(Proc);
    wQuery.ExecQuery;
    Result := (wQuery.Fields[00].AsInteger > 0);
  finally
    FIBQueryDestruir(wQuery);
  end;
end;

function GeneratorExiste(Gen: String): Boolean;
var
  wQuery: TpFIBQuery;
  wTrans: TpFIBTransaction;
begin
  FIBQueryCriar(wQuery, wTrans);
  try
    FIBQueryAtribuirSQL(wQuery, 'Select Count(rdb$generators.rdb$generator_name) from rdb$generators '+
                                'where rdb$generators.rdb$generator_name = :Nome');
    wQuery.ParamByName('Nome').AsString := AnsiUpperCase(Gen);
    wQuery.ExecQuery;
    Result := (wQuery.Fields[00].AsInteger > 0);
  finally
    FIBQueryDestruir(wQuery);
  end;
end;

function GetAppVersion(): string;
var
  VerInfoSize: DWORD;
  VerInfo: Pointer;
  VerValueSize: DWORD;
  VerValue: PVSFixedFileInfo;
  Dummy: DWORD;
begin
  Result := '';

  Dummy := 0;
  VerInfoSize := GetFileVersionInfoSize(PChar(Application.exename), Dummy);
  if (VerInfoSize = 0) then exit;

  GetMem(VerInfo, VerInfoSize);
  try
    GetFileVersionInfo(PChar(Application.exename), 0, VerInfoSize, VerInfo);

    VerQueryValue(VerInfo, '\', Pointer(VerValue), VerValueSize);

    Result := IntToStr(VerValue^.dwFileVersionMS shr 16) +'.'+
              IntToStr(VerValue^.dwFileVersionMS and $FFFF) +'.'+
              IntToStr(VerValue^.dwFileVersionLS shr 16) +'.'+
              IntToStr(VerValue^.dwFileVersionLS and $FFFF);
  finally
    FreeMem(VerInfo, VerInfoSize);
  end;
end;

function fGetVersao(prVersao: string): string;
var
  wMai, wMin, wRel, wBui: Integer;
begin
  if (Length(Trim(prVersao)) = 7) and (pos('311', prVersao) = 1) and (prVersao < '3112075') then
  begin
    Insert('.', prVersao, 2);
    Insert('.', prVersao, 4);
    Insert('.', prVersao, 6);
  end;
  //
  wMai := StrToIntDef(Copy(prVersao, 1, pos('.', prVersao) -1), 0);
  Delete(prVersao, 1, pos('.', prVersao));

  wMin := StrToIntDef(Copy(prVersao, 1, pos('.', prVersao) -1), 0);
  Delete(prVersao, 1, pos('.', prVersao));

  wRel := StrToIntDef(Copy(prVersao, 1, pos('.', prVersao) -1), 0);
  Delete(prVersao, 1, pos('.', prVersao));

  wBui := StrToIntDef(prVersao, 0);

  Result   := Format('%3.3u', [wMai]) + '.' + Format('%3.3u', [wMin]) + '.' + Format('%3.3u', [wRel]) + '.' + Format('%4.4u', [wBui]);
end;

function GetNroBuild(prVersao: string): string;
begin
  if (pos('311', prVersao) = 1) then
    prVersao := Copy(prVersao, 4, 4);

  if (pos('.', prVersao) > 0) then
  begin
    prVersao := ReverseString(prVersao);
    Result   := ReverseString(Copy(prVersao, 1, pos('.', prVersao) -1));
  end
  else
  begin
    Result   := IntToStr(StrToIntDef(prVersao, 0));
  end;
end;

function GetFileSize(const FileName: String): Int64;
var
  wfd: TWin32FindData;
  hnd: THandle;
begin
  Result := 0;
  hnd := FindFirstFile(PChar(FileName), wfd);
  if (hnd <> INVALID_HANDLE_VALUE) then begin
    Result := (wfd.nFileSizeHigh shl 32) + wfd.nFileSizeLow;
    Windows.FindClose(hnd);
  end;
end;

function GetFileDate(const FileName: String): TDateTime;
var
  wfd: TWin32FindData;
  ft: TFileTime;
  st: TSystemTime;
  hnd: THandle;
begin
  Result := 0;
  hnd := Windows.FindFirstFile(PChar(FileName), wfd);
  if (hnd <> INVALID_HANDLE_VALUE) then begin
    FileTimeToLocalFileTime(wfd.ftLastWriteTime, ft);
    FileTimeToSystemTime(ft, st);
    Result := SystemTimeToDateTime(st);
    Windows.FindClose(hnd);
  end;
end;

function VolumeInfo(DriveLetter: string = ''): string;
var VolumeNameBuffer, FileSystemName: array[0..MAX_PATH] of Char;
    VolumeSerialNumber: DWord;
    MaximumComponentLength: DWord;
    FileSystemFlags: DWord;
begin
  if (DriveLetter = '') then
    DriveLetter:= PChar(Application.ExeName)^
  else
    DriveLetter:= PChar(DriveLetter)^;

  GetVolumeInformation(PChar(DriveLetter+':\'),
                       VolumeNameBuffer, DWORD(sizeof(VolumeNameBuffer)),
                       @VolumeSerialNumber,
                       MaximumComponentLength,
                       FileSystemFlags,
                       FileSystemName, SizeOf(FileSystemName));
  Result:= IntToHex(VolumeSerialNumber,8);
end;

function GetIP(HostName: string=''): string;
var wsa: TWSADATA;
    phe: PHostEnt;
    buf: array[0..254] of char;
begin
  Result:= '';

  if WSAStartup($202, wsa) = -1 then
     raise exception.Create('uDataM: Erro ao inicializar o Winsock.');
  try
    if (inet_addr(PChar(HostName)) <> INADDR_NONE) then
    begin
      Result := HostName;
      exit;
    end;
    if (HostName = '') then begin
      GetHostName(PChar(@buf), SizeOf(buf));
      SetString(HostName, PChar(@buf), StrLen(@buf));
    end;
    phe:= GetHostByName(PChar(HostName));
    if (phe <> nil) then
      Result:= inet_ntoa(PInAddr(phe^.h_addr_list^)^);
  finally
    WSACleanup;
  end;
end;

function GetIDESerialNumber(DriveLetter: string=''): string;
var hDevice         : THandle;
    nIdSectorSize   : LongInt;
    aIdBuffer       : array [0..IDENTIFY_BUFFER_SIZE-1] of Byte;
    IdSector        : TIdSector absolute aIdBuffer;
    DriveNum        : SmallInt;
    hVolume         : THandle;
    SDN             : STORAGE_DEVICE_NUMBER;
    lpBytesReturned : DWORD;
begin
  Result:='';
  DriveNum:=-1;

  if (DriveLetter = '') then
    DriveLetter:= PChar(Application.ExeName)^
  else
    DriveLetter:= PChar(DriveLetter)^;

  hVolume:= CreateFile(PChar('\\.\'+DriveLetter+':'),
                       GENERIC_READ,
                       FILE_SHARE_READ or FILE_SHARE_WRITE,
                       nil,
                       OPEN_EXISTING, 0, 0);
  if (hVolume <> INVALID_HANDLE_VALUE) then begin
    if DeviceIOControl(hVolume,
                       IOCTL_STORAGE_GET_DEVICE_NUMBER,
                       nil, 0,
                       @SDN, SizeOf(SDN),
                       lpBytesReturned, nil) then
    begin
      if (SDN.DeviceType = FILE_DEVICE_DISK) then
        DriveNum:= SDN.DeviceNumber;
    end;

    CloseHandle(hVolume);
  end;

  if (DriveNum < 0) then exit;

  FillChar(aIdBuffer, SizeOf(aIdBuffer), #0);
  hDevice:= GetPhysicalDriveHandle(DriveNum, GENERIC_READ or GENERIC_WRITE);
  if (hDevice = INVALID_HANDLE_VALUE) then exit;
  try
    if SmartIdentifyDirect(hDevice, 0, IDE_ID_FUNCTION, IdSector, nIdSectorSize) then begin
      //ChangeByteOrder(IdSector.sModelNumber, SizeOf(IdSector.sModelNumber));
      //ChangeByteOrder(IdSector.sFirmwareRev, SizeOf(IdSector.sFirmwareRev) );
      ChangeByteOrder(IdSector.sSerialNumber, SizeOf(IdSector.sSerialNumber));
      //SetString(Result, IdSector.sModelNumber, SizeOf(IdSector.sModelNumber));
      //SetString(Result, IdSector.sFirmwareRev, SizeOf(IdSector.sFirmwareRev));
      SetString(Result, IdSector.sSerialNumber, SizeOf(IdSector.sSerialNumber));
      Result:= Trim(Result);
    end;
  finally
    CloseHandle(hDevice);
  end;
end;

function GetProcessMemorySize(_sProcessName: string; var _nMemSize: Cardinal): Boolean;
var
  l_nWndHandle, l_nProcID, l_nTmpHandle: HWND;
  l_pPMC: PPROCESS_MEMORY_COUNTERS;
  l_pPMCSize: Cardinal;
begin
  l_nWndHandle := FindWindow(nil, PChar(_sProcessName));
  if l_nWndHandle = 0 then
  begin
    Result := False;
    Exit;
  end;
  l_pPMCSize := SizeOf(PROCESS_MEMORY_COUNTERS);
  GetMem(l_pPMC, l_pPMCSize);
  l_pPMC^.cb := l_pPMCSize;
  GetWindowThreadProcessId(l_nWndHandle, @l_nProcID);
  l_nTmpHandle := OpenProcess(PROCESS_ALL_ACCESS, False, l_nProcID);
  if (GetProcessMemoryInfo(l_nTmpHandle, l_pPMC, l_pPMCSize)) then
    _nMemSize := l_pPMC^.WorkingSetSize
  else
    _nMemSize := 0;
  FreeMem(l_pPMC);
  Result := True;
end;

function CurrentProcessMemory(): Cardinal;
var MemCounters: TProcessMemoryCounters;
begin
  Result := 0;
  MemCounters.cb := SizeOf(MemCounters);
  if GetProcessMemoryInfo(GetCurrentProcess(), @MemCounters, SizeOf(MemCounters)) then
    Result := MemCounters.WorkingSetSize
  else
    RaiseLastOSError;
end;

function GetMacAddress(const IPAddress: string): string;
const
  MAX_ADAPTER_NAME_LENGTH        = 256;
  MAX_ADAPTER_DESCRIPTION_LENGTH = 128;
  MAX_ADAPTER_ADDRESS_LENGTH     = 8;

type
  PIPAddrList = ^TIPAddrList;
  TIPAddrList = packed record
    Next      : PIPAddrList;
    IPAddress : array[0..15] of Char;
    IPMask    : array[0..15] of Char;
    Context   : Cardinal;
  end;

  PIPAdapterInfo = ^TIPAdapterInfo;
  TIPAdapterInfo = packed record
    Next                : PIPAdapterInfo;
    ComboIndex          : Cardinal;
    AdapterName         : array[0..MAX_ADAPTER_NAME_LENGTH + 3] of Char;
    Description         : array[0..MAX_ADAPTER_DESCRIPTION_LENGTH + 3] of Char;
    AddressLength       : Cardinal;
    Address             : array[0..MAX_ADAPTER_ADDRESS_LENGTH - 1] of Byte;
    Index               : Cardinal;
    lngType             : Cardinal;
    DhcpEnabled         : BOOL;
    CurrentIPAddress    : PIPAddrList;
    IPAddressList       : TIPAddrList;
    GatewayList         : TIPAddrList;
    DhcpServer          : TIPAddrList;
    HaveWins            : BOOL;
    PrimaryWinsServer   : TIPAddrList;
    SecondaryWinsServer : TIPAddrList;
    LeaseObtained       : LongInt;
    LeaseExpires        : LongInt;
  end;

  TGetAdaptersInfo = function(pAdapterInfo: PIPAdapterInfo; var OutBufLen: Cardinal): DWORD; stdcall;

var
  GetAdaptersInfo: TGetAdaptersInfo;
  hLib: HMODULE;
  Adapter, Adapters: PIPAdapterInfo;
  IPAddr: PIPAddrList;
  Size: Cardinal;
begin
  Result := '';

  hLib := LoadLibrary('IPHlpAPI.dll');
  if (hLib <> 0) then
  begin
    try
      @GetAdaptersInfo := GetProcAddress(hLib, 'GetAdaptersInfo');
      if Assigned(GetAdaptersInfo) then begin
        if (GetAdaptersInfo(nil, Size) = ERROR_BUFFER_OVERFLOW) then begin
          Adapters := AllocMem(Size);//GetMem(Adapters, Size);
          try
            if (GetAdaptersInfo(Adapters, Size) = NO_ERROR) then begin
              Adapter:= Adapters;
              while (Adapter <> nil) do begin
                IPAddr := @Adapter^.IPAddressList;
                while (IPAddr <> nil) do begin
                  if (IPAddress = PChar(@IPAddr^.IPAddress)) then begin
                    Result:= IntToHex(Adapter^.Address[0], 2) +'-'+
                             IntToHex(Adapter^.Address[1], 2) +'-'+
                             IntToHex(Adapter^.Address[2], 2) +'-'+
                             IntToHex(Adapter^.Address[3], 2) +'-'+
                             IntToHex(Adapter^.Address[4], 2) +'-'+
                             IntToHex(Adapter^.Address[5], 2);
                    break;
                  end;

                  IPAddr := IPAddr^.Next;
                end;

                Adapter := Adapter^.Next;
              end;
            end;
          finally
            FreeMem(Adapters);
          end;
        end;
      end;
    finally
      FreeLibrary(hLib);
    end;
  end
  else
  begin
    MessageDlg('GetMacAddress: Falhou ao carregar a IPHlpAPI.dll', mtWarning, [mbOk], 0);
  end;
end;

function GetMacAddress: string;
var
  LocalIP: string;
begin
  Result := '';

  LocalIP := GetIP();
  Result  := GetMacAddress(LocalIP);
  // Sem cabo placa de rede ou conexão
  if (LocalIP = '127.0.0.1') or (Result = '') then
    Result := '00-00-00-00-00-00';
end;

function LoadFromFileEx(const AFileName: string; Length: DWord): string;
begin
  with TFileStream.Create(AFileName, fmOpenRead) do begin
    try
      try
        if (Length > Size) then
          Length:= Size;
        SetLength(Result, Length);
        Read(Pointer(Result)^, Length);
      except
        Result := ''; // Deallocates memory
        raise;
      end;
    finally
      Free;
    end;
  end;
end;

procedure FileList(var List: TStringList; SearchFile: string = '*'; DoRecursive: Boolean = False);
const ACK=#6;
var
  wfd: TWin32FindData;
  hFile: THandle;
  RootFolder, Parse: string;
  p: integer;
begin
  p:= Pos(';', SearchFile);
  if (p > 0) then begin
    repeat
      Parse:= Copy(SearchFile, 1, p - 1);
      FileList(List, Parse+ACK, DoRecursive);
      Delete(SearchFile, 1, p);
      p:= Pos(';', SearchFile);
    until (p = 0);

    FileList(List, SearchFile+ACK, DoRecursive);
    exit;
  end;

  RootFolder:= ExtractFilePath(SearchFile);
  SearchFile:= ExtractFileName(SearchFile);
  if (SearchFile = '') then SearchFile := '*';

  { Limpar lista }
  p:=Length(SearchFile);
  if (SearchFile[p] = ACK) then
    Delete(SearchFile,p,1)
  else
    List.Clear;

  hFile := FindFirstFile(PChar(RootFolder + SearchFile), wfd);
  try
    if (hFile <> INVALID_HANDLE_VALUE) then
      repeat
        if (wfd.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY) <> FILE_ATTRIBUTE_DIRECTORY then
          List.Add(RootFolder + string(wfd.cFileName));
      until FindNextFile(hFile, wfd) = False;
  finally
    Windows.FindClose(hFile);
  end;

  if DoRecursive then begin
    hFile := FindFirstFile(PChar(RootFolder + '*'), wfd);
    try
      if (hFile <> INVALID_HANDLE_VALUE) then
        repeat
          if (wfd.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY) = FILE_ATTRIBUTE_DIRECTORY then
            if (string(wfd.cFileName) <> '.') and (string(wfd.cFileName) <> '..') then //if (wfd.cFileName[0] <> '.') then
              FileList(List, RootFolder + wfd.cFileName +'\'+ SearchFile +ACK, true);
        until FindNextFile(hFile, wfd) = False;
    finally
      windows.FindClose(hFile);
    end;
  end;
end;



function TfDataM.fDataHoraServidor: TDateTime;
begin
  try
    FIBQueryAtribuirSQL(QueryData, 'select current_timestamp from RDB$DATABASE');
    QueryData.ExecQuery;
    Result := QueryData.Fields[0].AsDateTime;
    FIBQueryCommit(QueryData);
  except
    on e: exception do
    begin
      Result := Now;
    end;
  end;
end;

procedure TfDataM.pGerarCategorias(prEmpresa: Integer);
var
  wTransLoc: TpFIBTransaction;
  wQueryLoc: TpFIBQuery;
  wMsgErro: string;
  wInd, wCodigo, wTpConta: Integer;
  wClassi, wApelido, wDescricao: string;
  wDataHoje: TDateTime;

  procedure pGeraConta;
  begin
    wCodigo    := co_CategPadrao[wInd].Codigo;
    wTpConta   := co_CategPadrao[wInd].TpConta;
    wClassi    := co_CategPadrao[wInd].Classi;
    wApelido   := AnsiUpperCase(Trim(co_CategPadrao[wInd].Apelido));
    wDescricao := co_CategPadrao[wInd].Descricao;
  end;

begin
  FIBQueryCriar(wQueryLoc, wTransLoc);
  try
    try
      wDataHoje := Now;
      for wInd := Low(co_CategPadrao) to High(co_CategPadrao) do
      begin
        pGeraConta;
        wMsgErro := 'Erro ao gerar a categoria '+IntToStr(wCodigo);
        FIBQueryAtribuirSQL(wQueryLoc, 'INSERT INTO Categoria ( id,  Empre,  Codigo,  Classificacao,  Apelido,  Descricao,  ContaTIP,  DataCadastro,  STATUS) '+
                                       '               VALUES (:ID, :Empre, :Codigo, :Classificacao, :Apelido, :Descricao, :ContaTIP, :DataCadastro, :STATUS) ');
        wQueryLoc.ParamByName('id').AsInteger            := fGetGenerator('GEN_CATEGORIA');
        wQueryLoc.ParamByName('Empre').AsInteger         := prEmpresa;
        wQueryLoc.ParamByName('Codigo').AsInteger        := wCodigo;
        wQueryLoc.ParamByName('Classificacao').AsString  := wClassi;
        wQueryLoc.ParamByName('Apelido').AsString        := wApelido;
        wQueryLoc.ParamByName('Descricao').AsString      := wDescricao;
        wQueryLoc.ParamByName('ContaTIP').AsInteger      := wTpConta;
        wQueryLoc.ParamByName('DataCadastro').AsDateTime := wDataHoje;
        wQueryLoc.ParamByName('STATUS').AsInteger        := 1;
        wQueryLoc.ExecQuery;
        FIBQueryCommit(wQueryLoc);
      end;
    except
      on E:Exception do
        raise Exception.Create('pGerarCategorias'+#13#10+wMsgErro+#13#10+E.Message);
    end;
  finally
    FIBQueryCommit(wQueryLoc);
  end;
end;

procedure TfDataM.pGerarHistoricos(prEmpresa: Integer);
var
  wTransLoc: TpFIBTransaction;
  wQueryLoc: TpFIBQuery;
  wMsgErro: string;
  wInd, wCodigo: Integer;
  wDescricao: string;

  procedure pGeraHisto;
  begin
    wCodigo    := co_HistoPadrao[wInd].Codigo;
    wDescricao := co_HistoPadrao[wInd].Descricao;
  end;

begin
  FIBQueryCriar(wQueryLoc, wTransLoc);
  try
    try
      for wInd := Low(co_HistoPadrao) to High(co_HistoPadrao) do
      begin
        pGeraHisto;
        wMsgErro := 'Erro ao gerar o histórico padrão '+IntToStr(wCodigo);
        FIBQueryAtribuirSQL(wQueryLoc, 'INSERT INTO Historico ( id,  Empre,  Codigo,  Descricao,  Status) '+
                                       '               VALUES (:ID, :Empre, :Codigo, :Descricao, :Status) ');
        wQueryLoc.ParamByName('id').AsInteger            := fGetGenerator('GEN_HISTORICO');
        wQueryLoc.ParamByName('Empre').AsInteger         := prEmpresa;
        wQueryLoc.ParamByName('Codigo').AsInteger        := wCodigo;
        wQueryLoc.ParamByName('Descricao').AsString      := wDescricao;
        wQueryLoc.ParamByName('STATUS').AsInteger        := 1;
        wQueryLoc.ExecQuery;
        FIBQueryCommit(wQueryLoc);
      end;
    except
      on E:Exception do
        raise Exception.Create('pGerarHistoricos'+#13#10+wMsgErro+#13#10+E.Message);
    end;
  finally
    FIBQueryCommit(wQueryLoc);
  end;
end;

procedure TfDataM.pGerarBandeiras;
var
  wTransLoc: TpFIBTransaction;
  wQueryLoc: TpFIBQuery;
  wMsgErro: string;
  wInd, wCodigo: Integer;
  wDescricao: string;

  procedure pGeraBande;
  begin
    wCodigo    := co_BandePadrao[wInd].Codigo;
    wDescricao := co_BandePadrao[wInd].Descricao;
  end;

begin
  FIBQueryCriar(wQueryLoc, wTransLoc);
  try
    try
      for wInd := Low(co_BandePadrao) to High(co_BandePadrao) do
      begin
        pGeraBande;
        wMsgErro := 'Erro ao gerar a bandeira padrão '+IntToStr(wCodigo);
        FIBQueryAtribuirSQL(wQueryLoc, 'SELECT * FROM Bandeira WHERE Descricao = :Descricao ');
        wQueryLoc.ParamByName('Descricao').AsString      := wDescricao;
        wQueryLoc.ExecQuery;
        if wQueryLoc.Eof then
        begin
          FIBQueryAtribuirSQL(wQueryLoc, 'INSERT INTO Bandeira ( id,  Descricao) '+
                                         '              VALUES (:ID, :Descricao) ');
          wQueryLoc.ParamByName('id').AsInteger            := fGetGenerator('GEN_BANDEIRA');
          wQueryLoc.ParamByName('Descricao').AsString      := wDescricao;
          wQueryLoc.ExecQuery;
          FIBQueryCommit(wQueryLoc);
        end;
      end;
    except
      on E:Exception do
        raise Exception.Create('pGerarBandeiras'+#13#10+wMsgErro+#13#10+E.Message);
    end;
  finally
    FIBQueryCommit(wQueryLoc);
  end;
end;

procedure TfDataM.DataModuleCreate(Sender: TObject);

  procedure SetResourceString(AResString: PResStringRec; ANewValue: PChar);
  var
    POldProtect: DWORD;
  begin
    VirtualProtect(AResString, SizeOf(AResString^), PAGE_EXECUTE_READWRITE, @POldProtect);
    AResString^.Identifier := Integer(ANewValue);
    VirtualProtect(AResString, SizeOf(AResString^), POldProtect, @POldProtect);
  end;

var
  sBaseDb, User_name, Password, Charset: String;
  SQLDialect: Integer;
begin
  SetResourceString(@SOKButton, '&Ok');
  SetResourceString(@SCancelButton, '&Cancelar');
  SetResourceString(@SYesButton, '&Sim');
  SetResourceString(@SNoButton, '&Não');
  SetResourceString(@SHelpButton, 'Ajuda');
  SetResourceString(@SCloseButton, '&Fechar');
  SetResourceString(@SIgnoreButton, '&Ignorar');
  SetResourceString(@SRetryButton, '&Repetir');
  SetResourceString(@SAbortButton, '&Abortar');
  SetResourceString(@SAllButton, '&Todos');

  SetResourceString(@SMsgDlgWarning, 'Atenção');
  SetResourceString(@SMsgDlgError, 'Erro');
  SetResourceString(@SMsgDlgInformation, 'Informação');
  SetResourceString(@SMsgDlgConfirm, 'Confirmação');
  SetResourceString(@SMsgDlgYes, '&Sim');
  SetResourceString(@SMsgDlgNo, '&Não');
  SetResourceString(@SMsgDlgOK, '&Ok');
  SetResourceString(@SMsgDlgCancel, '&Cancelar');
  SetResourceString(@SMsgDlgHelp, 'Ajuda');
  SetResourceString(@SMsgDlgHelpNone, 'No help available');
  SetResourceString(@SMsgDlgHelpHelp, 'Ajuda');
  SetResourceString(@SMsgDlgAbort, '&Abortar');
  SetResourceString(@SMsgDlgRetry, '&Repetir');
  SetResourceString(@SMsgDlgIgnore, '&Ignorar');
  SetResourceString(@SMsgDlgAll, '&Todos');
  SetResourceString(@SMsgDlgNoToAll, 'Não para todos');
  SetResourceString(@SMsgDlgYesToAll, 'Sim para todos');
  //
  ShortDateFormat:= 'dd/MM/yyyy';
  DecimalSeparator:= ',';
  ThousandSeparator:= '.';
  //
  fLoaded  := False;
  fEmpresa := 0;
  fUsuario := 0;
  fEmpresaNome := '';
  fEmpresaApel := '';
  fEmpresaCPFC := '';

  Application.OnMessage := AppOnMessage;

  // Cria a base de dados
  sBaseDb := ExtractFilePath(ParamStr(0)) + '\Dados\Financeiro.gdb';
  ForceDirectories(ExtractFileDir(sBaseDb));

  User_name  := 'SYSDBA';
  Password   := 'masterkey';
  Charset    := 'ISO8859_2';
  SQLDialect := 3;

  FIB_Db.Connected := False;
  FIB_Db.DBParams.Clear;
  FIB_Db.DBParams.Add('user_name='+ User_name);
  FIB_Db.DBParams.Add('password='+ Password);
  FIB_Db.DBName := sBaseDb;
  FIB_Db.DBParams.Add('lc_ctype='+ Charset);
  FIB_Db.SQLDialect := SQLDialect;
  try
    FIB_Db.Open(False);
  except
    on e:exception do
    begin
      MessageDlg('FIB: Erro ao conectar-se na base de dados: ' + sBaseDb + #13#10 + e.Message, mtError, [mbOK], 0);
      raise;
    end;
  end;

  // criar a base de dados
  if (not FIB_Db.Connected) and (Length(Trim(ExtractFileDrive(sBaseDb))) = 0) or ((Length(Trim(ExtractFileDrive(sBaseDb))) > 0) and (not FileExists(sBaseDb))) then
  begin
    FIB_Db.Connected := False;
    FIB_Db.Connected := False;
    FIB_Db.DBParams.Clear;
    FIB_Db.DBParams.Add('USER ' + QuotedStr(User_name) + ' PASSWORD ' + QuotedStr(Password));
    FIB_Db.DBParams.Add('PAGE_SIZE = 2048');
    FIB_Db.DBParams.Add('DEFAULT CHARACTER SET ' + Charset);
    FIB_Db.SQLDialect := SQLDialect;
    FIB_Db.DBName     := sBaseDb;

    try
      FIB_Db.CreateDataBase;
      FIB_Db.Connected := False;
    except
      on e:exception do
      begin
        MessageDlg('FIB: Erro ao criar a base de dados de documentos e textos: ' + sBaseDb + #13#10 + e.Message, mtError, [mbOK], 0);
        raise;
      end;
    end;
  end;


  FIB_Db.Connected := False;
  FIB_Db.DBParams.Clear;
  FIB_Db.DBParams.Add('user_name='+ User_name);
  FIB_Db.DBParams.Add('password='+ Password);
  FIB_Db.DBName := sBaseDb;
  FIB_Db.DBParams.Add('lc_ctype='+ Charset);
  FIB_Db.SQLDialect := SQLDialect;
  try
    FIB_Db.Open(True);
  except
    on e:exception do
    begin
      MessageDlg('FIB: Erro ao conectar-se na base de dados: ' + sBaseDb + #13#10 + e.Message, mtError, [mbOK], 0);
      raise;
    end;
  end;

  if FIB_Db.Connected then
    pCriaTabelas;

  frmLogin := TfrmLogin.Create(Application.MainForm);
  frmLogin.ShowModal;
  fEmpresa     := frmLogin.ppEmpresa;
  fEmpresaNome := frmLogin.ppEmpresaNome;
  fEmpresaApel := frmLogin.ppEmpresaApel;
  fEmpresaCPFC := frmLogin.ppEmpresaCPFC;
  fLoaded      := frmLogin.ModalResult = mrOk;
  Application.OnException := AppOnException;
end;

procedure TfDataM.pCriaTabelas;
var
  wMsgErro: string;
  wTransLoc: TpFIBTransaction;
  wQueryLoc: TpFIBQuery;

  procedure pCriarEndereco;
  begin
    wMsgErro := 'Criando a tabela Endereco';
    try
      try
        if (not TabelaExiste('Endereco')) then
        begin
          FIBCriaGenerator(wQueryLoc, 'GEN_ENDERECO');
          FIBQueryAtribuirSQL(wQueryLoc, 'CREATE TABLE Endereco ( '+
                                         '    id                INTEGER NOT NULL, '+
                                         '    CEP               VARCHAR(10), '+
                                         '    UF                VARCHAR(02) NOT NULL, '+
                                         '    CIDADE            VARCHAR(50) NOT NULL, '+
                                         '    LOGRADOURO        VARCHAR(100) NOT NULL, '+
                                         '    NUMERO            VARCHAR(12) NOT NULL, '+
                                         '    BAIRRO            VARCHAR(50) NOT NULL, '+
                                         '    COMPLEMENTO       VARCHAR(50), '+
                                         '    EMAIL             VARCHAR(255), '+
                                         '    SITE              VARCHAR(255));');
          wQueryLoc.ExecQuery;
          FIBQueryCommit(wQueryLoc);

          wMsgErro := 'Criando a chave primária da tabela "Endereco"';
          FIBQueryAtribuirSQL(wQueryLoc, 'ALTER TABLE Endereco ADD PRIMARY KEY (id)');
          wQueryLoc.ExecQuery;
          FIBQueryCommit(wQueryLoc);
        end;
      except
        on E:Exception do
          raise Exception.Create('pCriarEndereco'+#13#10+wMsgErro+#13#10+E.Message);
      end;
    finally
      FIBQueryCommit(wQueryLoc);
    end;
  end;

  procedure pCriarFone;
  begin
    wMsgErro := 'Criando a tabela Fone';
    try
      try
        if (not TabelaExiste('Fone')) then
        begin
          FIBCriaGenerator(wQueryLoc, 'GEN_FONE');
          FIBQueryAtribuirSQL(wQueryLoc, 'CREATE TABLE Fone ( '+
                                         '    id                INTEGER NOT NULL, '+
                                         '    FoneCenDDD        VARCHAR(03), '+
                                         '    FoneCenNRO        VARCHAR(12), '+
                                         '    FoneComDDD        VARCHAR(03), '+
                                         '    FoneComNRO        VARCHAR(12), '+
                                         '    FoneCelDDD        VARCHAR(03), '+
                                         '    FoneCelNRO        VARCHAR(12), '+
                                         '    FoneFaxDDD        VARCHAR(03), '+
                                         '    FoneFaxNRO        VARCHAR(12));');
          wQueryLoc.ExecQuery;
          FIBQueryCommit(wQueryLoc);

          wMsgErro := 'Criando a chave primária da tabela "Fone"';
          FIBQueryAtribuirSQL(wQueryLoc, 'ALTER TABLE Fone ADD PRIMARY KEY (id)');
          wQueryLoc.ExecQuery;
          FIBQueryCommit(wQueryLoc);
        end;
      except
        on E:Exception do
          raise Exception.Create('pCriarFone'+#13#10+wMsgErro+#13#10+E.Message);
      end;
    finally
      FIBQueryCommit(wQueryLoc);
    end;
  end;

  procedure pCriarEmpresa;
  begin
    wMsgErro := 'Criando a tabela Empresa';
    try
      try
        if (not TabelaExiste('Empresa')) then
        begin
          FIBCriaGenerator(wQueryLoc, 'GEN_EMPRESA');
          FIBQueryAtribuirSQL(wQueryLoc, 'CREATE TABLE Empresa ( '+
                                         '    id                INTEGER NOT NULL, '+
                                         '    Email             VARCHAR(255), '+
                                         '    Senha             VARCHAR(255), '+
                                         '    CPFCNPJ           VARCHAR(14) NOT NULL, '+
                                         '    NOME              VARCHAR(100) NOT NULL, '+
                                         '    APELIDO           VARCHAR(20) NOT NULL, '+
                                         '    status            INTEGER NOT NULL, '+
                                         '    endereco          INTEGER NOT NULL, '+
                                         '    fone              INTEGER NOT NULL);');
          wQueryLoc.ExecQuery;
          FIBQueryCommit(wQueryLoc);

          wMsgErro := 'Criando a chave primária da tabela "Empresa"';
          FIBQueryAtribuirSQL(wQueryLoc, 'ALTER TABLE Empresa ADD PRIMARY KEY (id)');
          wQueryLoc.ExecQuery;
          FIBQueryCommit(wQueryLoc);
        end;
      except
        on E:Exception do
          raise Exception.Create('pCriarEmpresa'+#13#10+wMsgErro+#13#10+E.Message);
      end;
    finally
      FIBQueryCommit(wQueryLoc);
    end;
  end;

  procedure pCriarUsuario;
  begin
    wMsgErro := 'Criando a tabela Usuario';
    try
      try
        if (not TabelaExiste('Usuario')) then
        begin
          FIBCriaGenerator(wQueryLoc, 'GEN_USUARIO');
          FIBQueryAtribuirSQL(wQueryLoc, 'CREATE TABLE Usuario ( '+
                                         '    id                INTEGER NOT NULL, '+
                                         '    Empre             INTEGER NOT NULL, '+
                                         '    CPFCNPJ           VARCHAR(14) NOT NULL, '+
                                         '    NOME              VARCHAR(100) NOT NULL, '+
                                         '    APELIDO           VARCHAR(20) NOT NULL, '+
                                         '    menu              INTEGER NOT NULL, '+
                                         '    status            INTEGER NOT NULL, '+
                                         '    endereco          INTEGER NOT NULL, '+
                                         '    fone              INTEGER NOT NULL);');
          wQueryLoc.ExecQuery;
          FIBQueryCommit(wQueryLoc);

          wMsgErro := 'Criando a chave primária da tabela "Usuario"';
          FIBQueryAtribuirSQL(wQueryLoc, 'ALTER TABLE Usuario ADD PRIMARY KEY (id)');
          wQueryLoc.ExecQuery;
          FIBQueryCommit(wQueryLoc);

          wMsgErro := 'Criando índice "Usuario_IDX_EMPRESA" da tabela "Usuario"';
          FIBQueryAtribuirSQL(wQueryLoc, 'CREATE UNIQUE INDEX Usuario_IDX_EMPRESA ON Usuario(Id,Empre);');
          wQueryLoc.ExecQuery;
          FIBQueryCommit(wQueryLoc);
        end;
      except
        on E:Exception do
          raise Exception.Create('pCriarUsuario'+#13#10+wMsgErro+#13#10+E.Message);
      end;
    finally
      FIBQueryCommit(wQueryLoc);
    end;
  end;

  procedure pCriarMenu;
  begin
    wMsgErro := 'Criando a tabela Menu';
    try
      try
        if (not TabelaExiste('Menu')) then
        begin
          FIBCriaGenerator(wQueryLoc, 'GEN_MENU');
          FIBQueryAtribuirSQL(wQueryLoc, 'CREATE TABLE Menu ( '+
                                         '    id                INTEGER NOT NULL, '+
                                         '    Empre             INTEGER NOT NULL, '+
                                         '    DESCRICAO         VARCHAR(100) NOT NULL, '+
                                         '    status            INTEGER NOT NULL);');
          wQueryLoc.ExecQuery;
          FIBQueryCommit(wQueryLoc);

          wMsgErro := 'Criando a chave primária da tabela "Menu"';
          FIBQueryAtribuirSQL(wQueryLoc, 'ALTER TABLE Menu ADD PRIMARY KEY (id)');
          wQueryLoc.ExecQuery;
          FIBQueryCommit(wQueryLoc);

          wMsgErro := 'Criando índice "Menu_IDX_EMPRESA" da tabela "Menu"';
          FIBQueryAtribuirSQL(wQueryLoc, 'CREATE UNIQUE INDEX Menu_IDX_EMPRESA ON Menu(Id,Empre);');
          wQueryLoc.ExecQuery;
          FIBQueryCommit(wQueryLoc);
        end;
      except
        on E:Exception do
          raise Exception.Create('pCriarMenu'+#13#10+wMsgErro+#13#10+E.Message);
      end;
    finally
      FIBQueryCommit(wQueryLoc);
    end;

    wMsgErro := 'Criando a tabela MenuItem';
    try
      try
        if (not TabelaExiste('MenuItem')) then
        begin
          FIBCriaGenerator(wQueryLoc, 'GEN_MENUITEM');
          FIBQueryAtribuirSQL(wQueryLoc, 'CREATE TABLE MenuItem ( '+
                                         '    id                INTEGER NOT NULL, '+
                                         '    Empre             INTEGER NOT NULL, '+
                                         '    menu              INTEGER NOT NULL, '+
                                         '    DESCRICAO         VARCHAR(100) NOT NULL, '+
                                         '    status            INTEGER NOT NULL);');
          wQueryLoc.ExecQuery;
          FIBQueryCommit(wQueryLoc);

          wMsgErro := 'Criando a chave primária da tabela "MenuItem"';
          FIBQueryAtribuirSQL(wQueryLoc, 'ALTER TABLE MenuItem ADD PRIMARY KEY (id)');
          wQueryLoc.ExecQuery;
          FIBQueryCommit(wQueryLoc);

          wMsgErro := 'Criando índice "MenuItem_IDX_EMPRESA" da tabela "MenuItem"';
          FIBQueryAtribuirSQL(wQueryLoc, 'CREATE UNIQUE INDEX MenuItem_IDX_EMPRESA ON MenuItem(Id,Empre);');
          wQueryLoc.ExecQuery;
          FIBQueryCommit(wQueryLoc);
        end;
      except
        on E:Exception do
          raise Exception.Create('pCriarMenuItem'+#13#10+wMsgErro+#13#10+E.Message);
      end;
    finally
      FIBQueryCommit(wQueryLoc);
    end;
  end;

  procedure pCriarCliente;
  begin
    wMsgErro := 'Criando a tabela Cliente';
    try
      try
        if (not TabelaExiste('Cliente')) then
        begin
          FIBCriaGenerator(wQueryLoc, 'GEN_CLIENTE');
          FIBQueryAtribuirSQL(wQueryLoc, 'CREATE TABLE Cliente ( '+
                                         '    id                INTEGER NOT NULL, '+
                                         '    Empre             INTEGER NOT NULL, '+
                                         '    Codigo            INTEGER NOT NULL, '+
                                         '    CPFCNPJ           VARCHAR(14) NOT NULL, '+
                                         '    NOME              VARCHAR(100) NOT NULL, '+
                                         '    APELIDO           VARCHAR(20) NOT NULL, '+
                                         '    Status            INTEGER NOT NULL, '+
                                         '    MoedaTIP          INTEGER NOT NULL, '+                                         
                                         '    CartaoTIP         INTEGER NOT NULL, '+
                                         '    CartaoCOD         INTEGER NOT NULL, '+
                                         '    Endereco          INTEGER NOT NULL, '+
                                         '    Fone              INTEGER NOT NULL);');
          wQueryLoc.ExecQuery;
          FIBQueryCommit(wQueryLoc);

          wMsgErro := 'Criando a chave primária da tabela "Cliente"';
          FIBQueryAtribuirSQL(wQueryLoc, 'ALTER TABLE Cliente ADD PRIMARY KEY (id)');
          wQueryLoc.ExecQuery;
          FIBQueryCommit(wQueryLoc);

          wMsgErro := 'Criando índice "Cliente_IDX_EMPRESA" da tabela "Cliente"';
          FIBQueryAtribuirSQL(wQueryLoc, 'CREATE UNIQUE INDEX Cliente_IDX_EMPRESA ON Cliente(Id,Empre);');
          wQueryLoc.ExecQuery;
          FIBQueryCommit(wQueryLoc);

          wMsgErro := 'Criando índice "Cliente_IDX_CODIGO" da tabela "Cliente"';
          FIBQueryAtribuirSQL(wQueryLoc, 'CREATE UNIQUE INDEX Cliente_IDX_CODIGO ON Cliente(Empre,Codigo);');
          wQueryLoc.ExecQuery;
          FIBQueryCommit(wQueryLoc);
        end;
      except
        on E:Exception do
          raise Exception.Create('pCriarCliente'+#13#10+wMsgErro+#13#10+E.Message);
      end;
    finally
      FIBQueryCommit(wQueryLoc);
    end;
  end;

  procedure pCriarFornecedor;
  begin
    wMsgErro := 'Criando a tabela Fornecedor';
    try
      try
        if (not TabelaExiste('Fornecedor')) then
        begin
          FIBCriaGenerator(wQueryLoc, 'GEN_FORNECEDOR');
          FIBQueryAtribuirSQL(wQueryLoc, 'CREATE TABLE Fornecedor ( '+
                                         '    id                INTEGER NOT NULL, '+
                                         '    Empre             INTEGER NOT NULL, '+
                                         '    Codigo            INTEGER NOT NULL, '+
                                         '    CPFCNPJ           VARCHAR(14) NOT NULL, '+
                                         '    NOME              VARCHAR(100) NOT NULL, '+
                                         '    APELIDO           VARCHAR(20) NOT NULL, '+
                                         '    Status            INTEGER NOT NULL, '+
                                         '    MoedaTIP          INTEGER NOT NULL, '+
                                         '    CartaoTIP         INTEGER NOT NULL, '+
                                         '    CartaoCOD         INTEGER NOT NULL, '+
                                         '    Endereco          INTEGER NOT NULL, '+
                                         '    Fone              INTEGER NOT NULL);');
          wQueryLoc.ExecQuery;
          FIBQueryCommit(wQueryLoc);

          wMsgErro := 'Criando a chave primária da tabela "Fornecedor"';
          FIBQueryAtribuirSQL(wQueryLoc, 'ALTER TABLE Fornecedor ADD PRIMARY KEY (id)');
          wQueryLoc.ExecQuery;
          FIBQueryCommit(wQueryLoc);

          wMsgErro := 'Criando índice "Fornecedor_IDX_EMPRESA" da tabela "Fornecedor"';
          FIBQueryAtribuirSQL(wQueryLoc, 'CREATE UNIQUE INDEX Fornecedor_IDX_EMPRESA ON Fornecedor(Id,Empre);');
          wQueryLoc.ExecQuery;
          FIBQueryCommit(wQueryLoc);

          wMsgErro := 'Criando índice "Fornecedor_IDX_CODIGO" da tabela "Fornecedor"';
          FIBQueryAtribuirSQL(wQueryLoc, 'CREATE UNIQUE INDEX Fornecedor_IDX_CODIGO ON Fornecedor(Empre,Codigo);');
          wQueryLoc.ExecQuery;
          FIBQueryCommit(wQueryLoc);
        end;
      except
        on E:Exception do
          raise Exception.Create('pCriarFornecedor'+#13#10+wMsgErro+#13#10+E.Message);
      end;
    finally
      FIBQueryCommit(wQueryLoc);
    end;
  end;

  procedure pCriarHistorico;
  begin
    wMsgErro := 'Criando a tabela Historico';
    try
      try
        if (not TabelaExiste('Historico')) then
        begin
          FIBCriaGenerator(wQueryLoc, 'GEN_HISTORICO');
          FIBQueryAtribuirSQL(wQueryLoc, 'CREATE TABLE Historico ( '+
                                         '    id                INTEGER NOT NULL, '+
                                         '    Empre             INTEGER NOT NULL, '+
                                         '    Codigo            INTEGER NOT NULL, '+
                                         '    Descricao         VARCHAR(100) NOT NULL, '+
                                         '    status            INTEGER NOT NULL);');
          wQueryLoc.ExecQuery;
          FIBQueryCommit(wQueryLoc);

          wMsgErro := 'Criando a chave primária da tabela "Historico"';
          FIBQueryAtribuirSQL(wQueryLoc, 'ALTER TABLE Historico ADD PRIMARY KEY (id)');
          wQueryLoc.ExecQuery;
          FIBQueryCommit(wQueryLoc);

          wMsgErro := 'Criando índice "Historico_IDX_CODIGO" da tabela "Historico"';
          FIBQueryAtribuirSQL(wQueryLoc, 'CREATE UNIQUE INDEX Historico_IDX_CODIGO ON Historico(Empre,Codigo);');
          wQueryLoc.ExecQuery;
          FIBQueryCommit(wQueryLoc);

          wMsgErro := 'Criando índice "Historico_IDX_EMPRESA" da tabela "Historico"';
          FIBQueryAtribuirSQL(wQueryLoc, 'CREATE UNIQUE INDEX Historico_IDX_EMPRESA ON Historico(Id,Empre);');
          wQueryLoc.ExecQuery;
          FIBQueryCommit(wQueryLoc);

        end;
      except
        on E:Exception do
          raise Exception.Create('pCriarHistorico'+#13#10+wMsgErro+#13#10+E.Message);
      end;
    finally
      FIBQueryCommit(wQueryLoc);
    end;
  end;

  procedure pCriarCategoria;
  begin
    wMsgErro := 'Criando a tabela Categoria';
    try
      try
        if (not TabelaExiste('Categoria')) then
        begin
          FIBCriaGenerator(wQueryLoc, 'GEN_CATEGORIA');
          FIBQueryAtribuirSQL(wQueryLoc, 'CREATE TABLE Categoria ( '+
                                         '    id                INTEGER NOT NULL, '+
                                         '    Empre             INTEGER NOT NULL, '+
                                         '    CODIGO            INTEGER NOT NULL, '+
                                         '    CLASSIFICACAO     VARCHAR(30) NOT NULL, '+
                                         '    APELIDO           VARCHAR(30), '+
                                         '    DESCRICAO         VARCHAR(60) NOT NULL, '+
                                         '    CONTATIP          INTEGER NOT NULL, '+
                                         '    DATACADASTRO      DATE NOT NULL, '+
                                         '    status            INTEGER NOT NULL);');
          wQueryLoc.ExecQuery;
          FIBQueryCommit(wQueryLoc);

          wMsgErro := 'Criando a chave primária da tabela "Categoria"';
          FIBQueryAtribuirSQL(wQueryLoc, 'ALTER TABLE Categoria ADD PRIMARY KEY (id)');
          wQueryLoc.ExecQuery;
          FIBQueryCommit(wQueryLoc);

          wMsgErro := 'Criando índice "Categoria_IDX_EMPRESA" da tabela "Categoria"';
          FIBQueryAtribuirSQL(wQueryLoc, 'CREATE UNIQUE INDEX Categoria_IDX_EMPRESA ON Categoria(Id,Empre);');
          wQueryLoc.ExecQuery;
          FIBQueryCommit(wQueryLoc);

          wMsgErro := 'Criando índice "Categoria_IDX_CLASSI" da tabela "Categoria"';
          FIBQueryAtribuirSQL(wQueryLoc, 'CREATE UNIQUE INDEX Categoria_IDX_CLASSI ON Categoria(Empre,CLASSIFICACAO);');
          wQueryLoc.ExecQuery;
          FIBQueryCommit(wQueryLoc);

          wMsgErro := 'Criando índice "Categoria_IDX_CODIGO" da tabela "Categoria"';
          FIBQueryAtribuirSQL(wQueryLoc, 'CREATE UNIQUE INDEX Categoria_IDX_CODIGO ON Categoria(Empre,CODIGO);');
          wQueryLoc.ExecQuery;
          FIBQueryCommit(wQueryLoc);

          wMsgErro := 'Criando índice "Categoria_IDX_APELIDO" da tabela "Categoria"';
          FIBQueryAtribuirSQL(wQueryLoc, 'CREATE INDEX Categoria_IDX_APELIDO ON Categoria(Empre,APELIDO);');
          wQueryLoc.ExecQuery;
          FIBQueryCommit(wQueryLoc);
        end;
      except
        on E:Exception do
          raise Exception.Create('pCriarCategoria'+#13#10+wMsgErro+#13#10+E.Message);
      end;
    finally
      FIBQueryCommit(wQueryLoc);
    end;
  end;

  procedure pCriarBandeira;
  begin
    wMsgErro := 'Criando a tabela Bandeira';
    try
      try
        if (not TabelaExiste('Bandeira')) then
        begin
          FIBCriaGenerator(wQueryLoc, 'GEN_BANDEIRA');
          FIBQueryAtribuirSQL(wQueryLoc, 'CREATE TABLE Bandeira ( '+
                                         '    id                INTEGER NOT NULL, '+
                                         '    DESCRICAO         VARCHAR(30) NOT NULL);');
          wQueryLoc.ExecQuery;
          FIBQueryCommit(wQueryLoc);

          wMsgErro := 'Criando a chave primária da tabela "Bandeira"';
          FIBQueryAtribuirSQL(wQueryLoc, 'ALTER TABLE Bandeira ADD PRIMARY KEY (id)');
          wQueryLoc.ExecQuery;
          FIBQueryCommit(wQueryLoc);
        end;
      except
        on E:Exception do
          raise Exception.Create('pCriarBandeira'+#13#10+wMsgErro+#13#10+E.Message);
      end;
    finally
      FIBQueryCommit(wQueryLoc);
    end;
  end;

  procedure pCriarCartaoDebCre;
  begin
    wMsgErro := 'Criando a tabela CartaoDebCre';
    try
      try
        if (not TabelaExiste('CartaoDebCre')) then
        begin
          FIBCriaGenerator(wQueryLoc, 'GEN_CARTAODEBCRE');
          FIBQueryAtribuirSQL(wQueryLoc, 'CREATE TABLE CartaoDebCre ( '+
                                         '    id                INTEGER NOT NULL, '+
                                         '    Empre             INTEGER NOT NULL, '+
                                         '    Codigo            Integer NOT NULL, '+
                                         '    TpDebCre          Integer NOT NULL, '+ // 0-Débito || 1-Crédito || 2-Ambos
                                         '    Bandeira          INTEGER NOT NULL, '+
                                         '    DESCRICAO         VARCHAR(30) NOT NULL, '+
                                         '    NOME              VARCHAR(30) NOT NULL, '+
                                         '    NROINI            VARCHAR(04) NOT NULL, '+
                                         '    NROFIM            VARCHAR(05) NOT NULL, '+
                                         '    SENHACOMP         VARCHAR(255), '+
                                         '    SITEBANCO         VARCHAR(255), '+
                                         '    SENHASITE         VARCHAR(255), '+
                                         '    VALIDADE          DATE NOT NULL, '+
                                         '    DiaFatFec         INTEGER NOT NULL, '+
                                         '    DiaFatVen         INTEGER NOT NULL, '+
                                         '    CategoriaDeb      INTEGER NOT NULL, '+
                                         '    CategoriaCre      INTEGER NOT NULL, '+
                                         '    Status            INTEGER NOT NULL);');
          wQueryLoc.ExecQuery;
          FIBQueryCommit(wQueryLoc);

          wMsgErro := 'Criando a chave primária da tabela "CartaoDebCre"';
          FIBQueryAtribuirSQL(wQueryLoc, 'ALTER TABLE CartaoDebCre ADD PRIMARY KEY (id)');
          wQueryLoc.ExecQuery;
          FIBQueryCommit(wQueryLoc);

          wMsgErro := 'Criando índice "CartaoDebCre_IDX_EMPRESA" da tabela "CartaoDebCre"';
          FIBQueryAtribuirSQL(wQueryLoc, 'CREATE UNIQUE INDEX CartaoDebCre_IDX_EMPRESA ON CartaoDebCre(Id,Empre);');
          wQueryLoc.ExecQuery;
          FIBQueryCommit(wQueryLoc);
        end;
      except
        on E:Exception do
          raise Exception.Create('pCriarCartaoDebCre'+#13#10+wMsgErro+#13#10+E.Message);
      end;
    finally
      FIBQueryCommit(wQueryLoc);
    end;
  end;

  procedure pCriarLancamento;
  begin
    wMsgErro := 'Criando a tabela Lancamento';
    try
      try
        if (not TabelaExiste('Lancamento')) then
        begin
          FIBCriaGenerator(wQueryLoc, 'GEN_LANCAMENTO');
          FIBQueryAtribuirSQL(wQueryLoc, 'CREATE TABLE Lancamento ( '+
                                         '    id                INTEGER NOT NULL, '+
                                         '    Empre             INTEGER NOT NULL, '+
                                         '    DataLancto        DATE NOT NULL, '+
                                         '    DtHrLancto        TIMESTAMP NOT NULL, '+
                                         '    CategoriaEnt      INTEGER NOT NULL, '+
                                         '    CategoriaSai      INTEGER NOT NULL, '+
                                         '    ValorLancto       NUMERIC(18,2) NOT NULL, '+
                                         '    CliForTIP         INTEGER, '+ // -1: Indefinido || 0-Fornecedor || 1-Cliente
                                         '    CliForCOD         INTEGER, '+ // Código do Fornecedor ou Cliente
                                         '    FaturaID          INTEGER, '+ // ID da Fatura
                                         '    FaturaCOD         INTEGER, '+ // Codigo da Fatura
                                         '    FaturaPAR         INTEGER, '+ // Parcela da Fatura
                                         '    DoctoNRO          VARCHAR(30), '+
                                         '    HistoCOD          INTEGER NOT NULL, ' +
                                         '    HistoDES          VARCHAR(100) NOT NULL, '+
                                         '    Status            INTEGER NOT NULL);');
          wQueryLoc.ExecQuery;
          FIBQueryCommit(wQueryLoc);

          wMsgErro := 'Criando a chave primária da tabela "Lancamento"';
          FIBQueryAtribuirSQL(wQueryLoc, 'ALTER TABLE Lancamento ADD PRIMARY KEY (id)');
          wQueryLoc.ExecQuery;
          FIBQueryCommit(wQueryLoc);

          wMsgErro := 'Criando índice "Lancamento_IDX_DATALAN" da tabela "Lancamento"';
          FIBQueryAtribuirSQL(wQueryLoc, 'CREATE INDEX Lancamento_IDX_DATALAN ON Lancamento(Empre,DATALANCTO);');
          wQueryLoc.ExecQuery;
          FIBQueryCommit(wQueryLoc);

          wMsgErro := 'Criando índice "Lancamento_IDX_CATENT" da tabela "Lancamento"';
          FIBQueryAtribuirSQL(wQueryLoc, 'CREATE INDEX Lancamento_IDX_CATENT ON Lancamento(Empre,CategoriaEnt);');
          wQueryLoc.ExecQuery;
          FIBQueryCommit(wQueryLoc);

          wMsgErro := 'Criando índice "Lancamento_IDX_CATSAI" da tabela "Lancamento"';
          FIBQueryAtribuirSQL(wQueryLoc, 'CREATE INDEX Lancamento_IDX_CATSAI ON Lancamento(Empre,CategoriaSai);');
          wQueryLoc.ExecQuery;
          FIBQueryCommit(wQueryLoc);

          wMsgErro := 'Criando índice "Lancamento_IDX_EMPRESA" da tabela "Lancamento"';
          FIBQueryAtribuirSQL(wQueryLoc, 'CREATE UNIQUE INDEX Lancamento_IDX_EMPRESA ON Lancamento(Id,Empre);');
          wQueryLoc.ExecQuery;
          FIBQueryCommit(wQueryLoc);
        end;
      except
        on E:Exception do
          raise Exception.Create('pCriarLancamento'+#13#10+wMsgErro+#13#10+E.Message);
      end;
    finally
      FIBQueryCommit(wQueryLoc);
    end;
  end;

  procedure pCriaCTAPAG;
  begin
    wMsgErro := 'Criando a tabela CtaPagDocto';
    try
      try
        if (not TabelaExiste('CtaPagDocto')) then
        begin
          FIBCriaGenerator(wQueryLoc, 'GEN_CTAPAG');
          FIBQueryAtribuirSQL(wQueryLoc, 'CREATE TABLE CtaPagDocto ( '+
                                         '    id                INTEGER NOT NULL, '+
                                         '    Empre             INTEGER NOT NULL, '+
                                         '    Codigo            INTEGER NOT NULL, '+
                                         '    EmitenteTIP       INTEGER NOT NULL, '+ // -1: Indefinido || 0-Fornecedor || 1-Cliente
                                         '    EmitenteCOD       INTEGER NOT NULL, '+
                                         '    DoctoNRO          VARCHAR(30), '+
                                         '    Descricao         VARCHAR(255), '+
                                         '    DataEmissao       DATE NOT NULL, '+
                                         '    ParcelaQTDE       INTEGER NOT NULL, '+
                                         '    ParcelaTIPO       INTEGER NOT NULL, '+ // 0-Fixo || 1-Continuo
                                         '    PrimParceData     DATE NOT NULL, '+
                                         '    PrimParceValor    NUMERIC(18,2) NOT NULL, '+
                                         '    DiaFixoVencto     INTEGER NOT NULL, '+
                                         '    ValorParcela      NUMERIC(18,2) NOT NULL, '+
                                         '    ValorPrincipal    NUMERIC(18,2) NOT NULL, '+
                                         '    ValorPago         NUMERIC(18,2), '+
                                         '    HistoDES          VARCHAR(255) NOT NULL, '+
                                         '    MoedaTIP          INTEGER NOT NULL, '+
                                         '    CartaoTIP         INTEGER NOT NULL, '+
                                         '    CartaoCOD         INTEGER NOT NULL, '+
                                         '    CategoriaDes      INTEGER NOT NULL, '+  // Conta de Despesas
                                         '    CategoriaSai      INTEGER NOT NULL, '+  // Conta Pagadora
                                         '    Status            INTEGER NOT NULL);'); // 0-Pendente || 1-Desdobrada || 2-Pagto Parcial || 3-Quitada || 7-Cancelada
          wQueryLoc.ExecQuery;
          FIBQueryCommit(wQueryLoc);

          wMsgErro := 'Criando a chave primária da tabela "CtaPagDocto"';
          FIBQueryAtribuirSQL(wQueryLoc, 'ALTER TABLE CtaPagDocto ADD PRIMARY KEY (id)');
          wQueryLoc.ExecQuery;
          FIBQueryCommit(wQueryLoc);

          wMsgErro := 'Criando índice "CtaPagDocto_IDX_CODIGO" da tabela "CtaPagDocto"';
          FIBQueryAtribuirSQL(wQueryLoc, 'CREATE INDEX CtaPagDocto_IDX_CODIGO ON CtaPagDocto(Empre,Codigo);');
          wQueryLoc.ExecQuery;
          FIBQueryCommit(wQueryLoc);

          wMsgErro := 'Criando índice "CtaPagDocto_IDX_DATAEMI" da tabela "CtaPagDocto"';
          FIBQueryAtribuirSQL(wQueryLoc, 'CREATE INDEX CtaPagDocto_IDX_DATAEMI ON CtaPagDocto(Empre,DataEmissao);');
          wQueryLoc.ExecQuery;
          FIBQueryCommit(wQueryLoc);

          wMsgErro := 'Criando índice "CtaPagDocto_IDX_Docto" da tabela "CtaPagDocto"';
          FIBQueryAtribuirSQL(wQueryLoc, 'CREATE INDEX CtaPagDocto_IDX_CATENT ON CtaPagDocto(Empre,DoctoNRO);');
          wQueryLoc.ExecQuery;
          FIBQueryCommit(wQueryLoc);

          wMsgErro := 'Criando índice "CtaPagDocto_IDX_EMPRESA" da tabela "CtaPagDocto"';
          FIBQueryAtribuirSQL(wQueryLoc, 'CREATE UNIQUE INDEX CtaPagDocto_IDX_EMPRESA ON CtaPagDocto(Id,Empre);');
          wQueryLoc.ExecQuery;
          FIBQueryCommit(wQueryLoc);
        end;
      except
        on E:Exception do
          raise Exception.Create('pCriaCTAPAG: CtaPagDocto'+#13#10+wMsgErro+#13#10+E.Message);
      end;
    finally
      FIBQueryCommit(wQueryLoc);
    end;

    wMsgErro := 'Criando a tabela CtaPagParce';
    try
      try
        if (not TabelaExiste('CtaPagParce')) then
        begin
          FIBQueryAtribuirSQL(wQueryLoc, 'CREATE TABLE CtaPagParce ( '+
                                         '    DoctoId           INTEGER NOT NULL, '+
                                         '    Parcela           INTEGER NOT NULL, '+
                                         '    DataVencto        DATE NOT NULL, '+
                                         '    ValorParcela      NUMERIC(18,2) NOT NULL, '+
                                         '    ValorPago         NUMERIC(18,2), '+
                                         '    MoedaTIP          INTEGER NOT NULL, '+
                                         '    CartaoTIP         INTEGER NOT NULL, '+  // 0-Débito || 1-Crédito
                                         '    CartaoCOD         INTEGER NOT NULL, '+
                                         '    CodigoBarras      VARCHAR(100), '+
                                         '    Status            INTEGER NOT NULL);'); // 0-Em aberto || 2-Pagto Parcial || 3-Quitada || 7-Cancelada
          wQueryLoc.ExecQuery;
          FIBQueryCommit(wQueryLoc);

          wMsgErro := 'Criando a chave primária da tabela "CtaPagParce"';
          FIBQueryAtribuirSQL(wQueryLoc, 'ALTER TABLE CtaPagParce ADD PRIMARY KEY (DoctoId,Parcela)');
          wQueryLoc.ExecQuery;
          FIBQueryCommit(wQueryLoc);

          wMsgErro := 'Criando índice "CtaPagParce_IDX_DATAVEN" da tabela "CtaPagParce"';
          FIBQueryAtribuirSQL(wQueryLoc, 'CREATE INDEX CtaPagParce_IDX_DATAVEN ON CtaPagParce(DoctoId,Parcela,DataVencto);');
          wQueryLoc.ExecQuery;
          FIBQueryCommit(wQueryLoc);
        end;
      except
        on E:Exception do
          raise Exception.Create('pCriaCTAPAG: CtaPagParce'+#13#10+wMsgErro+#13#10+E.Message);
      end;
    finally
      FIBQueryCommit(wQueryLoc);
    end;

    wMsgErro := 'Criando a tabela CtaPagParceBaixa';
    try
      try
        if (not TabelaExiste('CtaPagParceBaixa')) then
        begin
          FIBQueryAtribuirSQL(wQueryLoc, 'CREATE TABLE CtaPagParceBaixa ( '+
                                         '    DoctoId           INTEGER NOT NULL, '+
                                         '    Parcela           INTEGER NOT NULL, '+
                                         '    Sequencia         INTEGER NOT NULL, '+
                                         '    MoedaTIP          INTEGER NOT NULL, '+
                                         '    DataBaixa         TIMESTAMP NOT NULL, '+
                                         '    DataLancto        TIMESTAMP NOT NULL, '+                                         
                                         '    ValorPrincipal    NUMERIC(18,2) NOT NULL, '+
                                         '    ValorJuros        NUMERIC(18,2) NOT NULL, '+
                                         '    ValorMulta        NUMERIC(18,2) NOT NULL, '+
                                         '    ValorDesconto     NUMERIC(18,2) NOT NULL, '+
                                         '    ValorTotal        NUMERIC(18,2) NOT NULL, '+
                                         '    HistoDES          VARCHAR(255) NOT NULL, '+
                                         '    Status            INTEGER NOT NULL);'); // 0-Normal || 1-Estorno
          wQueryLoc.ExecQuery;
          FIBQueryCommit(wQueryLoc);

          wMsgErro := 'Criando a chave primária da tabela "CtaPagParceBaixa"';
          FIBQueryAtribuirSQL(wQueryLoc, 'ALTER TABLE CtaPagParceBaixa ADD PRIMARY KEY (DoctoId,Parcela,Sequencia)');
          wQueryLoc.ExecQuery;
          FIBQueryCommit(wQueryLoc);

          wMsgErro := 'Criando índice "CtaPagParceBaixa_IDX_DATABAI" da tabela "CtaPagParceBaixa"';
          FIBQueryAtribuirSQL(wQueryLoc, 'CREATE INDEX CtaPagParceBaixa_IDX_DATABAI ON CtaPagParceBaixa(DoctoId,Parcela,Sequencia,DataBaixa);');
          wQueryLoc.ExecQuery;
          FIBQueryCommit(wQueryLoc);
        end;
      except
        on E:Exception do
          raise Exception.Create('pCriaCTAPAG: CtaPagParceBaixa'+#13#10+wMsgErro+#13#10+E.Message);
      end;
    finally
      FIBQueryCommit(wQueryLoc);
    end;

    wMsgErro := 'Criando a trigger CTAPAGPARCEBAIXA_AIUD';
    try
      try
        if (not TriggerExiste('CTAPAGPARCEBAIXA_AIUD')) then
        begin
          FIBQueryAtribuirSQL(wQueryLoc, fLoadFromScript('CtaPagParceBaixa_aiud.sql'));
          wQueryLoc.ExecQuery;
          FIBQueryCommit(wQueryLoc);
        end;
      except
        on E:Exception do
          raise Exception.Create('pCriaCTAPAG: CTAPAGPARCEBAIXA_AIUD'+#13#10+wMsgErro+#13#10+E.Message);
      end;
    finally
      FIBQueryCommit(wQueryLoc);
    end;
  end;


  procedure pCriaCTAREC;
  begin
    wMsgErro := 'Criando a tabela CtaRecDocto';
    try
      try
        if (not TabelaExiste('CtaRecDocto')) then
        begin
          FIBCriaGenerator(wQueryLoc, 'GEN_CTAREC');
          FIBQueryAtribuirSQL(wQueryLoc, 'CREATE TABLE CtaRecDocto ( '+
                                         '    id                INTEGER NOT NULL, '+
                                         '    Empre             INTEGER NOT NULL, '+
                                         '    Codigo            INTEGER NOT NULL, '+
                                         '    EmitenteTIP       INTEGER NOT NULL, '+ // -1: Indefinido || 0-Fornecedor || 1-Cliente
                                         '    EmitenteCOD       INTEGER NOT NULL, '+
                                         '    DoctoNRO          VARCHAR(30), '+
                                         '    Descricao         VARCHAR(255), '+
                                         '    DataEmissao       DATE NOT NULL, '+
                                         '    ParcelaQTDE       INTEGER NOT NULL, '+
                                         '    ParcelaTIPO       INTEGER NOT NULL, '+ // 0-Fixo || 1-Continuo
                                         '    PrimParceData     DATE NOT NULL, '+
                                         '    PrimParceValor    NUMERIC(18,2) NOT NULL, '+
                                         '    DiaFixoVencto     INTEGER NOT NULL, '+
                                         '    ValorParcela      NUMERIC(18,2) NOT NULL, '+
                                         '    ValorPrincipal    NUMERIC(18,2) NOT NULL, '+
                                         '    ValorPago         NUMERIC(18,2), '+
                                         '    HistoDES          VARCHAR(255) NOT NULL, '+
                                         '    MoedaTIP          INTEGER NOT NULL, '+
                                         '    CartaoTIP         INTEGER NOT NULL, '+
                                         '    CartaoCOD         INTEGER NOT NULL, '+
                                         '    CategoriaRec      INTEGER NOT NULL, '+  // Conta de Receita
                                         '    CategoriaEnt      INTEGER NOT NULL, '+  // Conta Recebedora
                                         '    Status            INTEGER NOT NULL);'); // 0-Pendente || 1-Desdobrada || 2-Pagto Parcial || 3-Quitada || 7-Cancelada
          wQueryLoc.ExecQuery;
          FIBQueryCommit(wQueryLoc);

          wMsgErro := 'Criando a chave primária da tabela "CtaRecDocto"';
          FIBQueryAtribuirSQL(wQueryLoc, 'ALTER TABLE CtaRecDocto ADD PRIMARY KEY (id)');
          wQueryLoc.ExecQuery;
          FIBQueryCommit(wQueryLoc);

          wMsgErro := 'Criando índice "CtaRecDocto_IDX_CODIGO" da tabela "CtaRecDocto"';
          FIBQueryAtribuirSQL(wQueryLoc, 'CREATE INDEX CtaRecDocto_IDX_CODIGO ON CtaRecDocto(Empre,Codigo);');
          wQueryLoc.ExecQuery;
          FIBQueryCommit(wQueryLoc);

          wMsgErro := 'Criando índice "CtaRecDocto_IDX_DATAEMI" da tabela "CtaRecDocto"';
          FIBQueryAtribuirSQL(wQueryLoc, 'CREATE INDEX CtaRecDocto_IDX_DATAEMI ON CtaRecDocto(Empre,DataEmissao);');
          wQueryLoc.ExecQuery;
          FIBQueryCommit(wQueryLoc);

          wMsgErro := 'Criando índice "CtaRecDocto_IDX_Docto" da tabela "CtaRecDocto"';
          FIBQueryAtribuirSQL(wQueryLoc, 'CREATE INDEX CtaRecDocto_IDX_CATENT ON CtaRecDocto(Empre,DoctoNRO);');
          wQueryLoc.ExecQuery;
          FIBQueryCommit(wQueryLoc);

          wMsgErro := 'Criando índice "CtaRecDocto_IDX_EMPRESA" da tabela "CtaRecDocto"';
          FIBQueryAtribuirSQL(wQueryLoc, 'CREATE UNIQUE INDEX CtaRecDocto_IDX_EMPRESA ON CtaRecDocto(Id,Empre);');
          wQueryLoc.ExecQuery;
          FIBQueryCommit(wQueryLoc);
        end;
      except
        on E:Exception do
          raise Exception.Create('pCriaCTAREC: CtaRecDocto'+#13#10+wMsgErro+#13#10+E.Message);
      end;
    finally
      FIBQueryCommit(wQueryLoc);
    end;

    wMsgErro := 'Criando a tabela CtaRecParce';
    try
      try
        if (not TabelaExiste('CtaRecParce')) then
        begin
          FIBQueryAtribuirSQL(wQueryLoc, 'CREATE TABLE CtaRecParce ( '+
                                         '    DoctoId           INTEGER NOT NULL, '+
                                         '    Parcela           INTEGER NOT NULL, '+
                                         '    DataVencto        DATE NOT NULL, '+
                                         '    ValorParcela      NUMERIC(18,2) NOT NULL, '+
                                         '    ValorPago         NUMERIC(18,2), '+
                                         '    MoedaTIP          INTEGER NOT NULL, '+
                                         '    CartaoTIP         INTEGER NOT NULL, '+  // 0-Débito || 1-Crédito
                                         '    CartaoCOD         INTEGER NOT NULL, '+
                                         '    CodigoBarras      VARCHAR(100), '+                                         
                                         '    Status            INTEGER NOT NULL);'); // 0-Em aberto || 2-Pagto Parcial || 3-Quitada || 7-Cancelada
          wQueryLoc.ExecQuery;
          FIBQueryCommit(wQueryLoc);

          wMsgErro := 'Criando a chave primária da tabela "CtaRecParce"';
          FIBQueryAtribuirSQL(wQueryLoc, 'ALTER TABLE CtaRecParce ADD PRIMARY KEY (DoctoId,Parcela)');
          wQueryLoc.ExecQuery;
          FIBQueryCommit(wQueryLoc);

          wMsgErro := 'Criando índice "CtaRecDocto_IDX_DATAVEN" da tabela "CtaRecParce"';
          FIBQueryAtribuirSQL(wQueryLoc, 'CREATE INDEX CtaRecParce_IDX_DATAVEN ON CtaRecParce(DoctoId,Parcela,DataVencto);');
          wQueryLoc.ExecQuery;
          FIBQueryCommit(wQueryLoc);
        end;
      except
        on E:Exception do
          raise Exception.Create('pCriaCTAREC: CtaRecParce'+#13#10+wMsgErro+#13#10+E.Message);
      end;
    finally
      FIBQueryCommit(wQueryLoc);
    end;

    wMsgErro := 'Criando a tabela CtaRecParceBaixa';
    try
      try
        if (not TabelaExiste('CtaRecParceBaixa')) then
        begin
          FIBQueryAtribuirSQL(wQueryLoc, 'CREATE TABLE CtaRecParceBaixa ( '+
                                         '    DoctoId           INTEGER NOT NULL, '+
                                         '    Parcela           INTEGER NOT NULL, '+
                                         '    Sequencia         INTEGER NOT NULL, '+
                                         '    MoedaTIP          INTEGER NOT NULL, '+
                                         '    DataBaixa         TIMESTAMP NOT NULL, '+
                                         '    DataLancto        TIMESTAMP NOT NULL, '+
                                         '    ValorPrincipal    NUMERIC(18,2) NOT NULL, '+
                                         '    ValorJuros        NUMERIC(18,2) NOT NULL, '+
                                         '    ValorMulta        NUMERIC(18,2) NOT NULL, '+
                                         '    ValorDesconto     NUMERIC(18,2) NOT NULL, '+
                                         '    ValorTotal        NUMERIC(18,2) NOT NULL, '+
                                         '    HistoDES          VARCHAR(255) NOT NULL, '+
                                         '    Status            INTEGER NOT NULL);');  // 0-Normal || 7-Cancelada
          wQueryLoc.ExecQuery;
          FIBQueryCommit(wQueryLoc);

          wMsgErro := 'Criando a chave primária da tabela "CtaRecParceBaixa"';
          FIBQueryAtribuirSQL(wQueryLoc, 'ALTER TABLE CtaRecParceBaixa ADD PRIMARY KEY (DoctoId,Parcela,Sequencia)');
          wQueryLoc.ExecQuery;
          FIBQueryCommit(wQueryLoc);

          wMsgErro := 'Criando índice "CtaRecParceBaixa_IDX_DATABAI" da tabela "CtaRecParceBaixa"';
          FIBQueryAtribuirSQL(wQueryLoc, 'CREATE INDEX CtaRecParceBaixa_IDX_DATABAI ON CtaRecParceBaixa(DoctoId,Parcela,Sequencia,DataBaixa);');
          wQueryLoc.ExecQuery;
          FIBQueryCommit(wQueryLoc);
        end;
      except
        on E:Exception do
          raise Exception.Create('pCriaCTAREC: CtaRecParceBaixa'+#13#10+wMsgErro+#13#10+E.Message);
      end;
    finally
      FIBQueryCommit(wQueryLoc);
    end;

    wMsgErro := 'Criando a trigger CTARECPARCEBAIXA_AIUD';
    try
      try
        if (not TriggerExiste('CTARECPARCEBAIXA_AIUD')) then
        begin
          FIBQueryAtribuirSQL(wQueryLoc, fLoadFromScript('CtaRecParceBaixa_aiud.sql'));
          wQueryLoc.ExecQuery;
          FIBQueryCommit(wQueryLoc);
        end;
      except
        on E:Exception do
          raise Exception.Create('pCriaCTAREC: CTARECPARCEBAIXA_AIUD'+#13#10+wMsgErro+#13#10+E.Message);
      end;
    finally
      FIBQueryCommit(wQueryLoc);
    end;
  end;

  procedure pCriaFLUXO;
  begin
    wMsgErro := 'Criando a tabela TMPFLUXO';
    try
      try
        if (not TabelaExiste('TMPFLUXO')) then
        begin
          FIBQueryAtribuirSQL(wQueryLoc, 'CREATE TABLE TMPFLUXO ('+
                                         '    USUARIO   INTEGER, '+
                                         '    EMPRE     INTEGER, '+
                                         '    TPLANCTO  INTEGER, '+ // 10-Receitas || 19-SubTotal Receitas || 20-Despesas || 29-SubTotal Despesas || 9999-Total Geral
                                         '    CONTACOD  INTEGER, '+
                                         '    CONTADES  VARCHAR(100), '+
                                         '    MOEDACOD  INTEGER, '+
                                         '    MOEDADES  VARCHAR(100), '+
                                         '    FORMAPAG  VARCHAR(100), '+
                                         '    DESPRECE  VARCHAR(255), '+

                                         '    VLRA00M01 NUMERIC(18,2), '+

                                         '    VLRA01M01 NUMERIC(18,2), '+
                                         '    VLRA01M02 NUMERIC(18,2), '+
                                         '    VLRA01M03 NUMERIC(18,2), '+
                                         '    VLRA01M04 NUMERIC(18,2), '+
                                         '    VLRA01M05 NUMERIC(18,2), '+
                                         '    VLRA01M06 NUMERIC(18,2), '+
                                         '    VLRA01M07 NUMERIC(18,2), '+
                                         '    VLRA01M08 NUMERIC(18,2), '+
                                         '    VLRA01M09 NUMERIC(18,2), '+
                                         '    VLRA01M10 NUMERIC(18,2), '+
                                         '    VLRA01M11 NUMERIC(18,2), '+
                                         '    VLRA01M12 NUMERIC(18,2), '+

                                         '    VLRA02M01 NUMERIC(18,2), '+
                                         '    VLRA02M02 NUMERIC(18,2), '+
                                         '    VLRA02M03 NUMERIC(18,2), '+
                                         '    VLRA02M04 NUMERIC(18,2), '+
                                         '    VLRA02M05 NUMERIC(18,2), '+
                                         '    VLRA02M06 NUMERIC(18,2), '+
                                         '    VLRA02M07 NUMERIC(18,2), '+
                                         '    VLRA02M08 NUMERIC(18,2), '+
                                         '    VLRA02M09 NUMERIC(18,2), '+
                                         '    VLRA02M10 NUMERIC(18,2), '+
                                         '    VLRA02M11 NUMERIC(18,2), '+
                                         '    VLRA02M12 NUMERIC(18,2), '+

                                         '    VLRA03M01 NUMERIC(18,2), '+
                                         '    VLRA03M02 NUMERIC(18,2), '+
                                         '    VLRA03M03 NUMERIC(18,2), '+
                                         '    VLRA03M04 NUMERIC(18,2), '+
                                         '    VLRA03M05 NUMERIC(18,2), '+
                                         '    VLRA03M06 NUMERIC(18,2), '+
                                         '    VLRA03M07 NUMERIC(18,2), '+
                                         '    VLRA03M08 NUMERIC(18,2), '+
                                         '    VLRA03M09 NUMERIC(18,2), '+
                                         '    VLRA03M10 NUMERIC(18,2), '+
                                         '    VLRA03M11 NUMERIC(18,2), '+
                                         '    VLRA03M12 NUMERIC(18,2), '+

                                         '    VLRA04M01 NUMERIC(18,2), '+
                                         '    VLRA04M02 NUMERIC(18,2), '+
                                         '    VLRA04M03 NUMERIC(18,2), '+
                                         '    VLRA04M04 NUMERIC(18,2), '+
                                         '    VLRA04M05 NUMERIC(18,2), '+
                                         '    VLRA04M06 NUMERIC(18,2), '+
                                         '    VLRA04M07 NUMERIC(18,2), '+
                                         '    VLRA04M08 NUMERIC(18,2), '+
                                         '    VLRA04M09 NUMERIC(18,2), '+
                                         '    VLRA04M10 NUMERIC(18,2), '+
                                         '    VLRA04M11 NUMERIC(18,2), '+
                                         '    VLRA04M12 NUMERIC(18,2), '+

                                         '    VLRA05M01 NUMERIC(18,2), '+
                                         '    VLRA05M02 NUMERIC(18,2), '+
                                         '    VLRA05M03 NUMERIC(18,2), '+
                                         '    VLRA05M04 NUMERIC(18,2), '+
                                         '    VLRA05M05 NUMERIC(18,2), '+
                                         '    VLRA05M06 NUMERIC(18,2), '+
                                         '    VLRA05M07 NUMERIC(18,2), '+
                                         '    VLRA05M08 NUMERIC(18,2), '+
                                         '    VLRA05M09 NUMERIC(18,2), '+
                                         '    VLRA05M10 NUMERIC(18,2), '+
                                         '    VLRA05M11 NUMERIC(18,2), '+
                                         '    VLRA05M12 NUMERIC(18,2), '+

                                         '    VLRA06M01 NUMERIC(18,2), '+
                                         '    VLRA06M02 NUMERIC(18,2), '+
                                         '    VLRA06M03 NUMERIC(18,2), '+
                                         '    VLRA06M04 NUMERIC(18,2), '+
                                         '    VLRA06M05 NUMERIC(18,2), '+
                                         '    VLRA06M06 NUMERIC(18,2), '+
                                         '    VLRA06M07 NUMERIC(18,2), '+
                                         '    VLRA06M08 NUMERIC(18,2), '+
                                         '    VLRA06M09 NUMERIC(18,2), '+
                                         '    VLRA06M10 NUMERIC(18,2), '+
                                         '    VLRA06M11 NUMERIC(18,2), '+
                                         '    VLRA06M12 NUMERIC(18,2), '+

                                         '    VLRA07M01 NUMERIC(18,2), '+
                                         '    VLRA07M02 NUMERIC(18,2), '+
                                         '    VLRA07M03 NUMERIC(18,2), '+
                                         '    VLRA07M04 NUMERIC(18,2), '+
                                         '    VLRA07M05 NUMERIC(18,2), '+
                                         '    VLRA07M06 NUMERIC(18,2), '+
                                         '    VLRA07M07 NUMERIC(18,2), '+
                                         '    VLRA07M08 NUMERIC(18,2), '+
                                         '    VLRA07M09 NUMERIC(18,2), '+
                                         '    VLRA07M10 NUMERIC(18,2), '+
                                         '    VLRA07M11 NUMERIC(18,2), '+
                                         '    VLRA07M12 NUMERIC(18,2), '+

                                         '    VLRA99M12 NUMERIC(18,2)) ');
          wQueryLoc.ExecQuery;
          FIBQueryCommit(wQueryLoc);

          wMsgErro := 'Criando índice "TMPFLUXO_IDX_USUEMPCTA" da tabela "TMPFLUXO"';
          FIBQueryAtribuirSQL(wQueryLoc, 'CREATE INDEX TMPFLUXO_IDX_USUEMPCTA ON TMPFLUXO(USUARIO,EMPRE,CONTACOD);');
          wQueryLoc.ExecQuery;
          FIBQueryCommit(wQueryLoc);
        end;
      except
        on E:Exception do
          raise Exception.Create('pCriaFLUXO: TMPFLUXO'+#13#10+wMsgErro+#13#10+E.Message);
      end;
    finally
      FIBQueryCommit(wQueryLoc);
    end;
  end;
  
begin
  FIBQueryCriar(wQueryLoc, wTransLoc);
  try
    pCriarEndereco;
    pCriarFone;
    pCriarEmpresa;
    pCriarUsuario;
    pCriarMenu;
    pCriarCliente;
    pCriarFornecedor;
    pCriarHistorico;
    pCriarCategoria;
    pCriarBandeira;
    pCriarCartaoDebCre;
    pCriarLancamento;
    pCriaCTAPAG;
    pCriaCTAREC;
    pCriaFluxo;
  finally
    FIBQueryDestruir(wQueryLoc);
  end;
end;

function TfDataM.fBuscaMoeda(prMoeda: Integer): String;
begin
  Result := '';
  case prMoeda of
    0: Result := '';
    1: Result := 'Dinheiro';
    2: Result := 'Cheque';
    3: Result := 'Cartão de Crédito';
    4: Result := 'Cartão de Débito';
    5: Result := 'Depósito Bancário';
    6: Result := 'Permuta';
    7: Result := 'Outros';
  end;
end;

function TfDataM.fBuscaStatusFATURA(prSTA: Integer): String;
begin
  Result := '';
  case prSTA of
    0: Result := 'Pendente';
    1: Result := 'Desdobrada';
    2: Result := 'Pagto Parcial';
    3: Result := 'Quitada';
    7: Result := 'Cancelada';
  end;
end;

function TfDataM.fBuscaStatusPARCE(prSTA: Integer): String;
begin
  Result := '';
  case prSTA of
    0: Result := 'Em aberto';
    2: Result := 'Pagto Parcial';
    3: Result := 'Quitada';
    7: Result := 'Cancelada';
  end;
end;

function TfDataM.fBuscaStatusBAIXA(prSTA: Integer): String;
begin
  Result := '';
  case prSTA of
    0: Result := 'Normal';
    7: Result := 'Cancelada';
  end;
end;

function TfDataM.fBuscaCartao(prTip, prCod: Integer): String;
begin
  Result := '';
  if (prCod > 0) then
  begin
    Result := 'Não cadastrado';
    FIBQueryAtribuirSQL(QueryDM, 'SELECT DESCRICAO, NROINI, NROFIM FROM CARTAODEBCRE '+
                                 'WHERE Empre = :Empre and Codigo = :Codigo');
    QueryDM.ParamByName('Empre').AsInteger  := Empresa;
    QueryDM.ParamByName('Codigo').AsInteger := prCod;
    QueryDM.ExecQuery;
    if (not QueryDM.Eof) then
    begin
      Result := QueryDM.FieldByName('DESCRICAO').AsString + ' - '+
                QueryDM.FieldByName('NROINI').AsString+'...'+QueryDM.FieldByName('NROFIM').AsString;

    end;
  end;
end;

procedure TfDataM.AppOnException(Sender: TObject; E:Exception);
var
  wTmp, wDT, wMsg: String;

  // Grava o log de erros
  procedure pGravaException(prMsg: String);
  var
    wPasta, wNewDir, wLogName: String;
    wSL: TStringList;
  begin
    try
      wPasta  := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0)));
      wNewDir := (wPasta+'Logs');

      if (not DirectoryExists(wNewDir)) then
      begin
        if (not ForceDirectories(wNewDir)) then
        begin
          MessageDlg('Erro ao criar a pasta "'+wNewDir+'"', mtWarning, [mbOk], 0);
          Exit;
        end;
      end;

      wLogName := (wNewDir +'\Excecoes.Log');

      wSL := TStringList.Create;
      try
        if FileExists(wLogName) then
          wSL.LoadFromFile(wLogName);
        wSL.Insert(0, prMsg);

        while (wSL.Count > 3000) do
          wSL.Delete(wSL.Count -1);

        wSL.SaveToFile(wLogName);
      finally
        wSL.Free;
      end;
    except
      on e: Exception do
        MessageDlg(e.Message, mtError, [mbOk], 0);
    end;
    MessageDlg(prMsg, mtWarning, [mbOK], 0);
  end;

begin
  if (pos('connection shutdown', AnsiLowerCase(e.Message)) > 0) or
     (pos('transaction is not active', AnsiLowerCase(e.Message)) > 0) then
  begin
    pGravaException('AppOnException: '+e.Message);
    Halt;
  end;

  if (Sender is TDateEdit) and (pos('is not a valid date', AnsiLowerCase(e.Message)) > 0) then
  begin
    MessageDlg('A data informada ' + (Sender as TDateEdit).Text + ' não é uma data válida!', mtWarning, [mbOk], 0);
    (Sender as TDateEdit).Clear;
    Exit;
  end;

  wTmp := getAppVersion();
  wDT  := DateTimeToStr(GetFileDate(Application.ExeName));

  if (Sender is TWinControl) then
  begin
    wMsg := 'Versão do sistema: ' + wTmp + ' de ' + wDT +eol+
            'Data       : '+ DateTimeToStr(Now)+#13#10+
            'Empresa    : '+ IntToStr(Empresa)+':'+EmpresaNome +eol+
            'Componente : '+ TWinControl(Sender).Name +eol+
            'Erro       : '+ E.Message +eol+
            '--------------------------------------------------------------------------------------';
    pGravaException(wMsg);
  end
  else
  begin
    wMsg := 'Versão do sistema: ' + wTmp + ' de ' + wDT +eol+
            'Data       : '+ DateTimeToStr(Now) +eol+
            'Empresa    : '+ IntToStr(Empresa)+':'+EmpresaNome +eol+
            'Erro       : '+ e.Message +eol+
            '--------------------------------------------------------------------------------------';
    pGravaException(wMsg);
  end;
end;

procedure TfDataM.AppOnMessage(var Msg: TMsg; var Handled: Boolean);

  function EnumProc(wnd: HWND; Data: lParam): BOOL; stdcall;
  var Buff: array[0..254] of char;
      l: integer;
  begin
    Result:= True;
    if IsWindowVisible(wnd) then begin
      l:=GetClassName(wnd, @Buff, SizeOf(Buff));
      Move(Buff[0], PChar(Data)^, l+1);
      if (StrPas(@Buff) = 'ComboLBox') then  Result:= False;
    end;
  end;

var Buf: array[0..254] of char;
    List: TList;
    i: integer;
    Delta: SmallInt;
begin
  if (Msg.message >= WM_KEYFIRST) and (Msg.message <= WM_KEYLAST) then
  begin
    LastActive := now;

    if (Msg.message = WM_KEYDOWN) then
    begin
      if (Msg.wParam = vk_Return) then
      begin
        LastClassName:='';
        if (Screen.ActiveControl is TCustomComboBox) then
        begin
          EnumThreadWindows(GetCurrentThreadID, @EnumProc, Integer(@Buf));
          if (StrPas(@Buf) = 'ComboLBox') then LastClassName:='ComboLBox';
        end;
      end;
    end;

    if (Msg.message = WM_CHAR) then
    begin
      if (Screen.ActiveControl is TForm) then exit;

      if (Msg.wParam = vk_Escape) then
      begin
        // avaliar se está no primeiro controle do form (ESC - close form)
        List:= TList.Create;
        try
          Screen.ActiveForm.GetTabOrderList(List);
          for i:=0 to List.Count -1 do
          begin
            if TWinControl(List.Items[i]).TabStop then
              if (Screen.ActiveControl = TWinControl(List.Items[i])) then
              begin
                PostMessage(Screen.ActiveForm.Handle{GetActiveWindow}, WM_Close, 0, 0);
                exit;
              end
              else Break;
          end;
        finally
          List.Free;
        end;

        SendMessage(Screen.ActiveForm.Handle, WM_NextDlgCtl, wParam(True), 0);
      end;

      if (Msg.wParam = vk_Return) then begin
        if (Screen.ActiveControl.ClassName = 'TMemo')
          or (Screen.ActiveControl.ClassName = 'TButton')
          or (Screen.ActiveControl.ClassName = 'TRichEdit')
          or (Screen.ActiveControl.ClassName = 'TRichViewEdit')
          or (Screen.ActiveControl.ClassName = 'TStringGrid') then Exit;

        if (LastClassName = 'ComboLBox') then Exit;

        SendMessage(Screen.ActiveForm.Handle, WM_NextDlgCtl, wParam(False), 0);
      end;
    end;
  end;

  if (Msg.message >= WM_MOUSEFIRST) and (Msg.message <= WM_MOUSELAST) then
  begin
    LastActive := now;

    if (Msg.message = WM_MOUSEWHEEL) then
    begin
      Msg.message := WM_KEYDOWN;
      Msg.lParam := 0;
      {$R-}
       Delta := SmallInt(HiWord(Msg.wParam));
      {$R+}
      if (Delta > 0) then
        Msg.wParam := vk_UP
      else
        Msg.wParam := vk_Down;
      Handled:= false;
    end;
  end;
end;

end.
