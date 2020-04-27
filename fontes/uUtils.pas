unit uUtils;

interface

uses Windows, Forms, SysUtils, Graphics, StdCtrls, Dialogs, Controls, StrUtils,
     rtTypes, DCPcrypt2, DCPrijndael, DCPBase64;

function  fInicializaForm(var AForm: TForm): boolean;
function  fSetaFoco(prOnde: Array of TWinControl): boolean;
function  ExtractChars(const S: string; Chars: TCharSet): string;
function  fSomenteNumeros(const Value: String): String;
function  Confirmar(const Texto: String; AColor: TColor = clBlack; ACaption: string = 'Confirme'): Boolean;
function  RemoveChars(const S: string; Chars: TCharSet): string;
function  ValidaCPFCNPJ(const sCPFCNPJ: string; AShowError: boolean = true): boolean;
function  ValidaEmail(const sEmail: string): boolean;
function  ValidaSenha(const sSenha: string): boolean;
function  ConferirCPF(aCPF: string): boolean;
function  ConferirCNPJ(aCNPJ: string): boolean;
function  CalcMod11(Numero: string; NumDig: integer=1; LimMult: integer=9): string;
function  ConferirMod11(const Num: string): boolean;
function  CalcDigitoRG(const Numero: String): String;
function  ConferirRG(const Num: string): boolean;
function  ConferirIE(const Num: string): boolean;
function  StrBefore(const Text, Token: string; Tag: boolean=false): string;
function  StrAfter(const Text, Token: string; Tag: boolean=false): string;
function  StrFetch(var Text: string; const Token: string; Tag: boolean=false): string;
function  StrFetchTrim(var Text: string; const Token: string; Tag: boolean=false): string;
function  StrFetchTrimHTML(var Text: string; const TagIni, TagFim: string; IncluirTags: boolean = True): string;
function  CopyBetween(const Texto, First, Last: string; Tag: boolean=false; Offset: integer=1): String;
function  DeleteBetween(Texto: string; const First, Last: string; Tag: boolean=false; Offset: integer=1): String;
function  FetchBetween(var Texto: string; const First, Last: string; Tag: boolean=false; Offset: integer=1): String;
procedure RestoreFormPos(Hnd: THandle; Comple: string = '');
procedure SaveFormPos(Hnd: THandle; Comple: string = '');
function  fGetCodigoCombo(prCombo: TComboBox): Integer;
procedure pSetCodigoCombo(prCombo: TComboBox; prCodigo: Integer);
function  rijndael_encrypt(data,passw,vetor: string): string;
function  rijndael_decrypt(data,passw,vetor: string): string;

implementation

uses
 IniFiles;
 
function fInicializaForm(var AForm: TForm): boolean;
begin
  try
    if (AForm <> nil) then
    begin
      if (not AForm.Visible) then
      begin
        FreeAndNil(AForm);
      end
      else
      begin
        if ((wsMinimized in [AForm.WindowState]) or (wsNormal in [AForm.WindowState])) then
          AForm.WindowState := wsNormal
        else
        begin
          if (wsMaximized in [AForm.WindowState]) then
          begin
            AForm.WindowState := wsMaximized;
            fSetaFoco([AForm]);
          end
          else
          begin
            FreeAndNil(AForm);
          end;
        end;
      end;
    end;
  except
    FreeAndNil(AForm);
  end;

  Result := (AForm = nil);
end;

function fSetaFoco(prOnde: Array of TWinControl): boolean;
var
  wInd: Integer;
begin
  Result := False;
  for wInd := 0 to Length(prOnde) -1 do
  begin
    try
      prOnde[wInd].SetFocus;
      Result := True;
      break;
    except
    end;
  end;
end;

function ExtractChars(const S: string; Chars: TCharSet): string;
var
  i, j: Integer;
begin
  SetLength(Result, Length(S));
  j := 0;
  for i:=1 to Length(S) do
  begin
    if (S[i] in Chars) then
    begin
      Inc(j);
      Result[j] := S[i];
    end;
  end;
  SetLength(Result,j);
end;

function fSomenteNumeros(const Value: String): String;
begin
  Result := '';
  if Length(Trim(Value)) > 0 then
    Result := ExtractChars(Value, ['0'..'9']);
end;

function Confirmar(const Texto: String; AColor: TColor = clBlack; ACaption: string = 'Confirme'): Boolean;
var
  lb: TLabel;
  bt: TButton;
begin
  with CreateMessageDialog(Texto, mtConfirmation, [mbYes, mbNo]) do
  try
    Caption := ' ' + Trim(ACaption);

    lb:= (FindComponent('Message') as TLabel);
    lb.WordWrap := false;
    lb.Font.Color := AColor;
    lb.Font.Style := [fsBold];

    bt:= (FindComponent('Yes') as TButton);
    ActiveControl:= bt; // default

    BorderWidth:=15;
    AutoSize := true;

    Result   := (ShowModal() = mrYes);
  finally
    Free;
  end;
end;

function RemoveChars(const S: string; Chars: TCharSet): string;
var
  pSource, pResult, pEnd: PChar;
begin
  SetLength(Result, Length(S)); //SetString(Result, PChar(S), Length(S));
  if (Length(S) > 0) then begin
    pSource := @S[1];
    pResult := @Result[1];
    pEnd := pSource + Length(S) - 1;
    while (pSource <= pEnd) do begin
      if not (pSource^ in Chars) then begin
        pResult^ := pSource^;
        inc(pResult);
      end;
      inc(pSource);
    end;
    SetLength(Result, (dword(pResult) - dword(@Result[1])));
  end;
end;

function ValidaCPFCNPJ(const sCPFCNPJ: string; AShowError: boolean = true): boolean;
var
  sStrAux :string;
begin
  Result := False;
  sStrAux := RemoveChars(sCPFCNPJ, ['.','-','/','\']);

  if (sStrAux = '') then exit;

  if (Length(sStrAux) = 11) then
  begin
    Result := ConferirCPF(sStrAux);
    if not Result then
      if AShowError then
        MessageDlg('CPF Inválido!', mtWarning, [mbOK], 0);
  end
  else
    if (Length(sStrAux) = 14) then
    begin
      Result := ConferirCNPJ(sStrAux);
      if not Result then
        if AShowError then
          MessageDlg('CNPJ Inválido!', mtWarning, [mbOK], 0);
    end
    else
      if AShowError then
        MessageDlg('CPF/CNPJ Inválido!', mtWarning, [mbOK], 0);
end;

function  ValidaEmail(const sEmail: string): boolean;
begin
  Result := pos('@', sEmail) > 1;
end;

function  ValidaSenha(const sSenha: string): boolean;
begin
  Result := Length(Trim(sSenha)) > 2;
end;

function ConferirCPF(aCPF: string): boolean;
var
  cpf: string;
  I: integer;
begin
  Result := False;

  for I := 0 to 9 do
  begin
    cpf := aCPF;
    cpf := AnsiReplaceStr(cpf, IntToStr(I), '');
    if Length(Trim(cpf)) = 0 then
      Exit;
  end;
  //
  cpf := Copy(aCPF,1,Length(aCPF)-2);
  cpf := cpf + CalcMod11(cpf, 2, 12);
  Result := (aCPF = cpf);
end;

function ConferirCNPJ(aCNPJ: string): boolean;
var
  cnpj: string;
  I: integer;
begin
  Result := False;

  for I := 0 to 9 do
  begin
    cnpj := aCNPJ;
    cnpj := AnsiReplaceStr(cnpj, IntToStr(I), '');
    if Length(Trim(cnpj)) = 0 then
      Exit;
  end;
  //
  cnpj:= Copy(aCNPJ,1,Length(aCNPJ)-2);
  cnpj:= cnpj + CalcMod11(cnpj, 2);
  Result := (aCNPJ = cnpj);
end;

function CalcMod11(Numero: string; NumDig: integer=1; LimMult: integer=9): string;
//261533-9
var Mult, Soma, i, n: word;
begin
  for n:=1 to NumDig do begin
    Soma:= 0;
    Mult:= 2;
    for i:=Length(Numero) downto 1 do begin
      Soma:= Soma + (Mult * (Integer(Numero[i])-48));
      Inc(Mult);
      if (Mult > LimMult) then Mult:= 2;
    end;
    //Numero:= Numero + Chr((((Soma * 10) mod 11) mod 10)+48);
    Soma:= ((Soma * 10) mod 11) mod 10;
    //Soma:= 11 - (Soma mod 11);
    //if (Soma > 9) then  Soma:= 0;
    Numero:= Numero + Chr(Soma+48);
  end;
  Result:= Copy(Numero, (Length(Numero) - NumDig)+1, NumDig);
end;

function ConferirMod11(const Num: string): boolean;
var s: string;
begin
  s:= Copy(Num,1,Length(Num)-1);
  s:= s + CalcMod11(s);
  Result := (Num = s);
end;

function CalcDigitoRG(const Numero: String): String;
// 1339705127-3
var i,Soma,Mult: integer;
begin
  Soma:=0;
  Mult:=9;
  for i:=Length(Numero) downto 1 do begin
    Soma:= Soma+(Mult * (Integer(Numero[i])-48));
    Dec(Mult);
    if (Mult < 2) then Mult:= 9;
  end;
  Soma:= (Soma mod 11) mod 10;
  Result:= Chr(Soma+48);
end;

function ConferirRG(const Num: string): boolean;
var s: string;
begin
  s:= Copy(Num,1,Length(Num)-1);
  s:= s + CalcDigitoRG(s);
  Result := (Num = s);
end;

function ConferirIE(const Num: string): boolean;
var s: string;
begin
  s:= Copy(Num,1,Length(Num)-1);
  s:= s + CalcDigitoRG(s);
  Result := (Num = s);
end;

function StrBefore(const Text, Token: string; Tag: boolean=false): string;
var index,len: integer;
begin
  index := Pos(Token, Text);
  if (index = 0) then
    Result := Text
  else begin
    len:= (index - 1);
    if Tag then
      len:= len+length(Token);
    Result := Copy(Text, 1, len);
  end;
end;

function StrAfter(const Text, Token: string; Tag: boolean=false): string;
var index,len: integer;
begin
  index := Pos(Token, Text);
  if (index = 0) then
    Result := ''
  else begin
    index:= (index + Length(Token));
    len:= Length(Text) -index +1;
    if Tag then begin
      index:= index-length(Token);
      len:= len+length(Token);
    end;
    Result := Copy(Text, index, len);
  end;
end;

function StrFetch(var Text: string; const Token: string; Tag: boolean=false): string;
var index,len: integer;
begin
  index:= Pos(Token, Text);
  if (index = 0) then begin
    Result:= Text;
    Text:= '';
  end
  else begin
    if Tag then
      Result:= Copy(Text, 1, (index -1)+Length(Token))
    else
      Result:= Copy(Text, 1, (index -1));
    index:= (index + Length(Token));

    len:= Length(Text) -index +1;
    Text:= Copy(Text, index, len);
  end;
end;

function StrFetchTrim(var Text: string; const Token: string; Tag: boolean=false): string;
var index,len: integer;
begin
  index:= Pos(Token, Text);
  if (index = 0) then begin
    Result:= Text;
    Text:= '';
  end
  else begin
    if Tag then
      Result:= Copy(Text, 1, (index -1)+Length(Token))
    else
      Result:= Copy(Text, 1, (index -1));
    index:= (index + Length(Token));

    len:= Length(Text) -index +1;
    Text:= Trim(Copy(Text, index, len));
  end;
end;

function StrFetchTrimHTML(var Text: string; const TagIni, TagFim: string; IncluirTags: boolean = True): string;
begin
  if IncluirTags then
    Result := TagIni + CopyBetween(Text, TagIni, TagFim) + TagFim
  else
    Result := CopyBetween(Text, TagIni, TagFim);
  Text := Trim(StrAfter(Text, TagFim));
end;

function CopyBetween(const Texto, First, Last: string; Tag: boolean=false; Offset: integer=1): String;
var f,l: integer;
begin
  Result := '';

  f := 1;
  l := length(Texto)+1;

  if (First <> '') then
    if (Offset > 1) then f := PosEx(First,Texto,Offset)
    else f := Pos(First,Texto);

  if (f > 0) and (Last <> '') then
    l := PosEx(Last,Texto,f+Length(First));

  if (f > 0) and (l > 0) then begin
    if Tag then
      l := l + Length(Last)
    else
      f := f + Length(First);

    l := (l - f);
    if (l > 0) then
      Result := Copy(Texto,f,l);
  end;
end;

function DeleteBetween(Texto: string; const First, Last: string; Tag: boolean=false; Offset: integer=1): String;
var f,l: integer;
begin
  f := 1;
  l := length(Texto)+1;

  if (First <> '') then
    if (Offset > 1) then f := PosEx(First,Texto,Offset)
    else f := Pos(First,Texto);

  if (f > 0) and (Last <> '') then
    l := PosEx(Last,Texto,f+Length(First));

  if (f > 0) and (l > 0) then begin
    if Tag then
      l := l + Length(Last)
    else
      f := f + Length(First);

    l := (l - f);
    if (l > 0) then
      Delete(Texto,f,l);
  end;

  Result := Texto;
end;

function FetchBetween(var Texto: string; const First, Last: string; Tag: boolean=false; Offset: integer=1): String;
var f,l: integer;
begin
  Result := '';
  
  f := 1;
  l := length(Texto)+1;

  if (First <> '') then
    if (Offset > 1) then f := PosEx(First,Texto,Offset)
    else f := Pos(First,Texto);

  if (f > 0) and (Last <> '') then
    l := PosEx(Last,Texto,f+Length(First));

  if (f > 0) and (l > 0) then begin
    if Tag then
      l := l + Length(Last)
    else
      f := f + Length(First);

    l := (l - f);
    if (l > 0) then begin
      Result:= Copy(Texto,f,l);
      Delete(Texto,f,l);
    end;
  end;
end;

procedure RestoreFormPos(Hnd: THandle; Comple: string = '');
var
  Ini: TIniFile;
  AppFilename: String;
  ClassName: array[0..512] of Char;
  Rect: TRect;
  l,t,w,h: integer;
  m: TMonitor;
  lp, tp: integer;
begin
  AppFilename := ChangeFileExt(Application.ExeName,'');
  AppFilename := (AppFilename +'cfg.ini');

  Ini:= TIniFile.Create(AppFilename);
  try
    windows.GetWindowRect(Hnd, Rect);
    w := (Rect.Right - Rect.Left) + 2;
    h := (Rect.Bottom - Rect.Top) + 2;

    // Valores padrao
    if (Application.MainForm <> nil) then
    begin
      lp := (Application.MainForm.Width  div 2) - (w div 2) + Application.MainForm.Left;
      tp := (Application.MainForm.Height div 2) - (h div 2) + Application.MainForm.Top;
    end
    else
    begin
      lp := (Screen.Width  div 2) - (w div 2) ;
      tp := (Screen.Height div 2) - (h div 2);
    end;

    FillChar(ClassName,SizeOf(ClassName),0);
    windows.GetClassName(Hnd,@ClassName,SizeOf(ClassName));
    l := Ini.ReadInteger(ClassName + Comple,'Left',lp);
    t := Ini.ReadInteger(ClassName + Comple,'Top',tp);

    { form.borderstyle = bsSizeable }
    if ((GetWindowLong(Hnd, GWL_STYLE) and WS_THICKFRAME) = WS_THICKFRAME) then
    begin
      w := Ini.ReadInteger(ClassName + Comple, 'Width', w);
      h := Ini.ReadInteger(ClassName + Comple, 'Height', h);
    end;
  finally
    Ini.Free;
  end;

  windows.SetWindowPos(Hnd, 0, l, t, w, h, SWP_NOZORDER or SWP_NOACTIVATE);

  m := Screen.MonitorFromWindow(Hnd);

  if (l < m.Left) then
  begin
    l := m.Left;
    windows.SetWindowPos(Hnd, 0, l, t, w, h, SWP_NOZORDER or SWP_NOACTIVATE);
  end;

  if ((l + w) > m.Width) then
  begin
    l := m.Width - w;
    windows.SetWindowPos(Hnd, 0, l, t, w, h, SWP_NOZORDER or SWP_NOACTIVATE);
  end;

  if (t < m.Top) or ((t + h) > m.Height) then
  begin
    t := m.Top;
    windows.SetWindowPos(Hnd, 0, l, t, w, h, SWP_NOZORDER or SWP_NOACTIVATE);
  end;
end;

procedure SaveFormPos(Hnd: THandle; Comple: string = '');
var Ini: TIniFile;
    AppFilename: String;
    ClassName: array[0..512] of Char;
    Rect: TRect;
    w,h: integer;
begin
  AppFilename:= ChangeFileExt(Application.ExeName,'');
  AppFilename:= (AppFilename +'cfg.ini');

  Ini:= TIniFile.Create(AppFilename);
  try
    windows.GetWindowRect(Hnd, Rect);
    w:= (Rect.Right - Rect.Left);
    h:= (Rect.Bottom - Rect.Top);

    FillChar(ClassName,SizeOf(ClassName),0);
    windows.GetClassName(Hnd,@ClassName,SizeOf(ClassName));
    Ini.WriteInteger(ClassName + Comple, 'Left', Rect.Left);
    Ini.WriteInteger(ClassName + Comple, 'Top', Rect.Top);
    Ini.WriteInteger(ClassName + Comple, 'Width', w);
    Ini.WriteInteger(ClassName + Comple, 'Height', h);
  finally
    Ini.Free;
  end;
end;

function fGetCodigoCombo(prCombo: TComboBox): Integer;
begin
  Result := -1;
  if prCombo.ItemIndex > -1 then
    Result := Integer(prCombo.Items.Objects[prCombo.ItemIndex]);
end;

procedure pSetCodigoCombo(prCombo: TComboBox; prCodigo: Integer);

  function fBuscaItem: Integer;
  var
    I: Integer;
  begin
    Result := -1;
    for I := 0 to prCombo.Items.Count -1 do
      if Integer(prCombo.Items.Objects[I]) = prCodigo then
        Result := I;
  end;

begin
  if (prCombo <> nil) then
    if (prCodigo > -1) then
      prCombo.ItemIndex := fBuscaItem
    else
      prCombo.ItemIndex := -1;
end;

function rijndael_encrypt(data,passw,vetor: string): string;
var Cipher: TDCP_rijndael;
    IV: array[0..15] of byte;
    Key: array[0..31{16/24/32}] of byte;
begin
  result := '';
  if (data = '') then exit;

  FillChar(Key, SizeOf(Key), 0);
  StrPLCopy(@Key, Passw, SizeOf(Key));

  FillChar(IV, SizeOf(IV), 0);
  StrPLCopy(@IV, vetor, SizeOf(IV));

  Cipher := TDCP_rijndael.Create(nil);
  try
    Cipher.Init(Key,256,@IV);
    Cipher.EncryptCBC(Data[1],Data[1],Length(Data));
  finally
    Cipher.Free;
  end;

  result := Base64EncodeStr(Data);
end;

function rijndael_decrypt(data,passw,vetor: string): string;
var Cipher: TDCP_rijndael;
    IV: array[0..15] of byte;
    Key: array[0..31{16/24/32}] of byte;
begin
  result := '';
  if (data = '') then exit;

  FillChar(Key, SizeOf(Key), 0);
  StrPLCopy(@Key, Passw, SizeOf(Key));

  FillChar(IV, SizeOf(IV), 0);
  StrPLCopy(@IV, vetor, SizeOf(IV));

  data := Base64DecodeStr(data);

  Cipher := TDCP_rijndael.Create(nil);
  try
    Cipher.Init(Key,256,@IV);
    Cipher.DecryptCBC(Data[1],Data[1],Length(Data));
  finally
    Cipher.Free;
  end;

  result := Data;
end;

end.
