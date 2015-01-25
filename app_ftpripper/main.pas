{
  TODO:
  - w momencie, gdy sciezka (nie plik) zawiera w sobie kropke, wystepuje blad powodujacy zapetlenie
}

unit main;

interface

uses
  SysUtils, Forms, Dialogs, IniFiles, OverbyteIcsWndControl, OverbyteIcsFtpCli, Controls, Classes, StdCtrls, ExtCtrls,
  WinTypes, ShlObj, XPMan, ShellAPI, Spin, ComCtrls, Messages, Menus, Graphics, CoolTrayIcon;

type
  TMainForm = class(TForm)
    StartButton: TButton;
    QuitButton: TButton;
    SettingsGroupBox: TGroupBox;
    PathsLabel: TLabel;
    SubDirsLabel: TLabel;
    FilesLabel: TLabel;
    CountTimer: TTimer;
    TimeLeftLabel: TLabel;
    FtpClient: TFtpClient;
    AboutButton: TButton;
    HostsLabel: TLabel;
    LogGroupBox: TGroupBox;
    FtpLabel: TLabel;
    FtpComboBox: TComboBox;
    ShowDetailsCheckBox: TCheckBox;
    DestinationLabel: TLabel;
    DestinationEdit: TEdit;
    BrowseButton: TButton;
    ErrorsLabel: TLabel;
    CompressCheckBox: TCheckBox;
    ReconnectionsSpinEdit: TSpinEdit;
    ReconnectionsLabel: TLabel;
    LogRichEdit: TRichEdit;
    TrayMenu: TPopupMenu;
    ClearMenuItem: TMenuItem;
    BreakCheckBox: TCheckBox;
    VersionLabel: TLabel;
    StatusPanel: TPanel;
    TimeLeftCountLabel: TLabel;
    HostsCountLabel: TLabel;
    PathsCountLabel: TLabel;
    SubDirsCountLabel: TLabel;
    FilesCountLabel: TLabel;
    ErrorsCountLabel: TLabel;
    CoolTrayIcon: TCoolTrayIcon;
    procedure QuitButtonClick(Sender: TObject);
    procedure StartButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure CountTimerTimer(Sender: TObject);
    procedure FtpClientRequestDone(Sender: TObject; RqType: TFtpRequest;
      ErrCode: Word);
    procedure FtpClientSessionConnected(Sender: TObject; ErrCode: Word);
    procedure FtpClientSessionClosed(Sender: TObject; ErrCode: Word);
    procedure FtpClientDisplay(Sender: TObject; var Msg: String);
    procedure AboutButtonClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FtpClientError(Sender: TObject; var Msg: String);
    procedure FtpClientBgException(Sender: TObject; E: Exception;
      var CanClose: Boolean);
    procedure BrowseButtonClick(Sender: TObject);
    procedure ClearMenuItemClick(Sender: TObject);
    procedure CoolTrayIconMinimizeToTray(Sender: TObject);
    procedure CoolTrayIconDblClick(Sender: TObject);
  private
    IsMinimized: boolean;
  public
  end;

var
  MainForm: TMainForm;
  StopNow: boolean;
  AppName, SettingsFilePath, lgStartFolder: string;
  DirList: TStringList;
  Stoper: Integer;
  SettingsFile: TIniFile;

  // text type file extensions, everything else is treated as binary
  TextFiles: array[1..32] of string = ('txt', 'htm', 'html', 'php', 'php3',
                                        'php4', 'php5', 'php6', 'js', 'bat',
                                        'sh', 'shtml', 'css', 'sql', 'xml',
                                        'htc', 'ini', 'md5', 'inc', 'afm', 'schema',
                                        'cgi', 'pl', 'xul', 'cache', 'htaccess',
                                        'conf', 'dhtml', 'xhtml', 'asp', 'vb',
                                        'log');

const
  // current app version
  FTP_RIPPER_VERSION = '0.7.0.0 beta';

  // colors
  COLOR_ERROR = $000000FF;
  COLOR_INFO = $00008000;
  COLOR_FTP = $00800080;
  COLOR_DETAILS = $00800040;
  COLOR_INTERNAL = $0086610D;

  // open folder dialog flags
  BIF_NEWDIALOGSTYLE = $40;
  BIF_NONEWFOLDERBUTTON = $200;

implementation

uses about;

{$R *.dfm}

function BrowseForFolderCallBack(Wnd: HWND; uMsg: UINT; lParam, lpData: LPARAM): Integer stdcall;
begin
  if uMsg = BFFM_INITIALIZED then
    SendMessage(Wnd,BFFM_SETSELECTION, 1, Integer(@lgStartFolder[1]));
  result := 0;
end;

function BrowseForFolder(const browseTitle: String; const initialFolder: String =''; mayCreateNewFolder: Boolean = False): String;
var
  browse_info: TBrowseInfo;
  folder: array[0..MAX_PATH] of char;
  find_context: PItemIDList;
begin
  FillChar(browse_info,SizeOf(browse_info),#0);
  lgStartFolder := initialFolder;
  browse_info.pszDisplayName := @folder[0];
  browse_info.lpszTitle := PChar(browseTitle);
  browse_info.ulFlags := BIF_RETURNONLYFSDIRS or BIF_NEWDIALOGSTYLE;
  if not mayCreateNewFolder then
    browse_info.ulFlags := browse_info.ulFlags or BIF_NONEWFOLDERBUTTON;

  browse_info.hwndOwner := Application.Handle;
  if initialFolder <> '' then
    browse_info.lpfn := BrowseForFolderCallBack;
  find_context := SHBrowseForFolder(browse_info);
  if Assigned(find_context) then
  begin
    if SHGetPathFromIDList(find_context,folder) then
      result := folder
    else
      result := '';
    GlobalFreePtr(find_context);
  end
  else
    result := '';
end;

// add extra zero to date
function FormatDate(Data: string): string;
  begin
    if Length(Data) < 2 then
      Result:= '0'+Data
    else
      Result:= Data;
  end;

// display formatted stoper
function FormatStoper(Stoper: integer): string;
  begin
    result:= FormatDate(inttostr(Stoper div 3600))+':'+FormatDate(inttostr((Stoper mod 3600) div 60))+':'+FormatDate(inttostr((Stoper mod 3600) mod 60));
  end;

// log events to screen
procedure Log(Msg: string; Color: integer = $00000000; Bold: boolean = false);
  var
    h, m, s, ms: Word;
    LogFile: TextFile;
    Time: string;
  begin
    DecodeTime(now, h, m, s, ms);
    if not FileExists(ChangeFileExt(ParamStr(0), '.log')) then
      begin
        AssignFile(LogFile, ChangeFileExt(ParamStr(0), '.log'));
        Rewrite(LogFile);
        CloseFile(LogFile);
      end;

      AssignFile(LogFile, ChangeFileExt(ParamStr(0), '.log'));
      Append(LogFile);

      MainForm.LogRichEdit.Lines.BeginUpdate;
      MainForm.LogRichEdit.SelStart := MainForm.LogRichEdit.GetTextLen;
      MainForm.LogRichEdit.SelAttributes.Color:= $00000000;
      Time:= '['+FormatDate(IntToStr(h))+':'+FormatDate(IntToStr(m))+':'+FormatDate(IntToStr(s))+'] ';
      MainForm.LogRichEdit.SelText:= Time;
      MainForm.LogRichEdit.SelAttributes.Color:= Color;
      if Bold then
        MainForm.LogRichEdit.SelAttributes.Style:= [fsBold]
      else
        MainForm.LogRichEdit.SelAttributes.Style:= [];
      MainForm.LogRichEdit.SelText:= Msg+#13;
      MainForm.LogRichEdit.Lines.EndUpdate;
      MainForm.LogRichEdit.SelAttributes.Color:= $000000;
      MainForm.LogRichEdit.SelStart:= Length(MainForm.LogRichEdit.Text);
      MainForm.LogRichEdit.Perform(EM_SCROLLCARET, 0, 0);
      WriteLn(LogFile, Time+Msg);
      CloseFile(LogFile);
      if Color = COLOR_ERROR then
        if MainForm.IsMinimized then
          MainForm.CoolTrayIcon.ShowBalloonHint(Application.Title, Msg, bitError, 20);
  end;

// cuts file mask
function CutMask(Path: string): string;
  var
    s: TStringList;
    i: Integer;
  begin
    s:= TStringList.Create;
    ExtractStrings(['|'], [], PChar(Path), S);
    for I := 0 to S.Count -1 do
      if (i>0) then
        Result:= s[i];
    s.free;
  end;

// cuts directory path
function CutPath(Path: string): string;
  var
    s: TStringList;
  begin
    s:= TStringList.Create;
    ExtractStrings(['|'], [], PChar(Path), S);
    Result:= copy(Path, 0, length(s[0]));
  end;

// append extra slash to path if needed
function Slash(Value: string): string;
 begin
  if (Value='') then
    Result:='' else
   begin
    if (Value[Length(Value)]<>'/') then
      Result:= Value+'/'
    else
      Result:= Value;
   end;
 end;

// append extra backslash to path if needed
function Backslash(Value: string): string;
 begin
  if (Value='') then Result:='' else
   begin
    if (Value[Length(Value)]<>'\') then
      Result:= Value+'\'
    else
      Result:= Value;
   end;
 end;

// returns temporary file name and path
Function GetTempFile: string;
 Var
  Dir: Array[0..255] Of Char;
  Size: Integer;
 Begin
  Size:= SizeOf(Dir) - 1;
  GetTempPath(Size, Dir);
  Result:= BackSlash(Dir)+ExtractFileName(ChangeFileExt(ParamStr(0), '.tmp'));
 End;

// checks if subdirectories are meant to be scanned
function ScanSubDirectories(Path: string): boolean;
  begin
    if ((Path[Length(Path)] = '/') and (Length(Path)>1)) then
      Result:= True
    else
      Result:= False;
  end;

// checks connection status
procedure ValidateConnection;
  var
    i: Byte;
  begin
    i:= 0;
    while (not MainForm.FtpClient.Connected) and (i<MainForm.ReconnectionsSpinEdit.Value) do
      begin
        i:= i+1;
        Log('Connection interrupted, reconnecting (max '+inttostr(MainForm.ReconnectionsSpinEdit.value)+' attempts): '+inttostr(i), COLOR_ERROR, true);
        MainForm.FtpClient.Connect;
        if MainForm.FtpClient.Connected and (i<MainForm.ReconnectionsSpinEdit.Value) then
          Log('Connection established again', COLOR_INFO, True)
        else
          begin
            MainForm.ErrorsCountLabel.Caption:= inttostr(strtoint(MainForm.ErrorsCountLabel.caption)+1);
            MainForm.ErrorsCountLabel.Font.Color:= COLOR_ERROR;
            Log('Can''t connect to server', COLOR_ERROR);
            if MainForm.BreakCheckBox.checked then
              StopNow:= true;
          end;
      end;
  end;

// checks if file is binary type
function IsBinary(FileName: string): boolean;
  var
    i: Byte;
  begin
    FileName:= ExtractFileExt(FileName);
    Result:= True;
    for i:= 1 to Length(TextFiles) do
      begin
        if FileName='.'+TextFiles[i] then
          Result:= False;
      end;

    // TODO:
    // aktualnie ka¿dy plik jest binarny :-)
    // niestety komponent zachowuje siê bardzo dziwnie w przypadku, gdy sciagany jest
    // plik graficzny - niszczy jego zawartosc

     Result:= True;
  end;

// scans directories recursively
procedure ScanDirs(Path: string);
  var
    FilesList: TStringList;
    TempFile: TextFile;
    TextData: string;
    s: TStringList;
    i: Integer;
  begin
    FilesList:= TStringList.Create;
    if StopNow then Exit;
      with MainForm.FtpClient do
        begin
          // za pomoc¹ komponentu pobieramy zawartosc katalogu zdalnego
          Log('Scanning path: "'+Path+'"');
          LocalFileName:= GetTempFile;
          // wycinamy dodatkowy slash ze sciezki '//'
          if Path[2] = '/' then
            Path:= Copy(Path, 2, Length(Path));
          HostDirName:= Path;
          HostFileName:= '';
          if MainForm.ShowDetailsCheckBox.Checked then
            Log('Setting text mode file transfer', COLOR_DETAILS);
          Binary:= False;

          ValidateConnection;
          if connected then
            begin
              Cwd;
              Dir;
            end;

          if FileExists(GetTempFile) and not StopNow then
            begin
              // przetwarzamy odpowiedz z serwera na liste katalogow
              AssignFile(TempFile, GetTempFile);
              Reset(TempFile);
              while not Eof(TempFile) and (not StopNow) do
                begin
                  ReadLn(TempFile, TextData);
                  if ((length(TextData)<>0) and (TextData[1]='d')) then
                    begin
                      s:= TStringList.Create;
                      ExtractStrings([' '], [], PChar(TextData), S);
                      for I := 0 to S.Count -1 do
                        begin
                          if (i>0) then TextData:= s[i];
                        end;
                      s.free;
                      if (TextData[1]<>'.') then
                        begin
                          Log('Subdirectory found: "'+Slash(Path)+TextData+'"');
                          DirList.Add(Slash(Path)+TextData);
                          FilesList.Add(Slash(Path)+TextData)
                        end;
                    end;
                end;
              CloseFile(TempFile);
              DeleteFile(PChar(GetTempFile));
            end;

          if not StopNow then
            begin
              for i:= 0 to FilesList.Count-1 do
                begin
                  ScanDirs(FilesList.Strings[i]);
                end;
            end;
          end;
      FilesList.free;
end;

procedure TMainForm.QuitButtonClick(Sender: TObject);
begin
  if FtpClient.Connected then
    begin
      if Application.MessageBox('Abort current process?', 'Operation in progress', MB_YESNO or MB_ICONASTERISK) = ID_YES then
        StopNow:= True
      else
        Close;
    end
  else
    Close;
end;

procedure TMainForm.StartButtonClick(Sender: TObject);
var
  x, y, w, q: integer;
  Section, Entry, Text, Compressor, ToolTip: string;
  Year, Month, Day: Word;
  TempFile: TextFile;
  FileList: TStringList;
begin
  Stoper:= 0;
  CountTimer.Enabled:= true;
  StopNow:= false;
  ErrorsCountLabel.font.color:= $00000000;
  ErrorsCountLabel.Caption:= '0';
  StatusPanel.Color:= clWhite;
  StartButton.enabled:= false;
  BrowseButton.Enabled:= false;
  AboutButton.Enabled:= false;
  DestinationEdit.enabled:= false;
  ReconnectionsSpinEdit.Enabled:= false;
  FtpComboBox.Enabled:= false;
  QuitButton.Caption:= 'Cancel';
  ShowDetailsCheckBox.Enabled:= false;
  CompressCheckBox.enabled:= false;
  BreakCheckBox.Enabled:= false;

  DecodeDate(Now, Year, Month, Day);
  Log('*** Starting ['+FormatDate(inttostr(Year))+'-'+FormatDate(inttostr(Month))+'-'+FormatDate(inttostr(Day))+']', COLOR_INTERNAL, true);
  DirList:= TStringList.Create;
  if FtpComboBox.ItemIndex = 0 then
    begin
      x:= 1;
      while SettingsFile.ReadString('ftp'+inttostr(x), 'Name', '') <> '' do
        begin
         HostsCountLabel.Caption:= IntToStr(StrToInt(HostsCountLabel.Caption)+1);
         x:= x+1;
        end;
      x:= 1;
    end
  else
    begin
      HostsCountLabel.Caption:= '1';
      x:= FtpComboBox.itemindex;
    end;

  while ((SettingsFile.ReadString('ftp'+inttostr(x), 'Name', '')<>'') and (not StopNow)) do
    begin
      DirList.Clear;
      Section:= 'ftp'+inttostr(x);
      x:= x+1;

      Log('Preparing to work on server: "'+SettingsFile.ReadString(Section, 'Name', '[error: missing server name]')+'"', $, true);
      CoolTrayIcon.Hint:= Application.Title+#13+'Working on server: '+SettingsFile.ReadString(Section, 'Name', '[error: missing server name]');
      ToolTip:= CoolTrayIcon.Hint;
      MainForm.Caption:= AppName+' — '+ SettingsFile.ReadString(Section, 'Name', '[error: missing server name]');

          // ustawiamy parametry dla komponentu
          FtpClient.HostName:= SettingsFile.ReadString(Section, 'Host', '');
          FtpClient.UserName:= SettingsFile.ReadString(Section, 'User', '');
          FtpClient.PassWord:= SettingsFile.ReadString(Section, 'Password', '');
          FtpClient.HostFileName:= '';
          FtpClient.LocalFileName:= GetTempFile;
          if SettingsFile.readinteger(Section, 'PassiveMode', 0)=1 then
            begin
              FtpClient.Passive:= true;
              Log('Opening passive mode', COLOR_INFO);
            end else FtpClient.Passive:= false;
          // laczymy sie z serwerem
          FtpClient.Connect;
          ValidateConnection;

          // skanujemy ilosc sciezek do przetworzenia (statystyka)
          y:= 1;
          while (SettingsFile.ReadString(Section, 'Path'+IntToStr(y), '')<>'') do
            begin
              y:= y+1;
            end;
          PathsCountLabel.Caption:= inttostr(y-1);

          // skanujemy katalogi oraz zapisujemy pliki do odpowiednich folderow
          y:= 1;
          while (SettingsFile.ReadString(Section, 'Path'+IntToStr(y), '')<>'') and (not StopNow) and (FtpClient.connected) do
            begin
              DirList.Clear;
              Entry:= 'Path'+IntToStr(y);
              y:= y+1;

              // skanujemy strukture katalogow
              Log('Reading directory structure: "'+CutPath(SettingsFile.readstring(Section, Entry, '[error: directory not found]'))+'"');
              CoolTrayIcon.Hint:= ToolTip+#13+'Reading directory structure: '+CutPath(SettingsFile.readstring(Section, Entry, '[error: directory not found]'));
              SubDirsCountLabel.Caption:= 'counting...';
              if ScanSubDirectories(CutPath(SettingsFile.readstring(Section, Entry, ''))) then
                begin
                  // jesli mamy skanowac rowniez podkatalogi
                  ScanDirs(CutPath(SettingsFile.readstring(Section, Entry, '')));
                end;
              SubDirsCountLabel.caption:= inttostr(DirList.count+1);
              DirList.Add(slash(CutPath(SettingsFile.readstring(Section, Entry, ''))));
              Log('Found directories: '+inttostr(DirList.count), COLOR_INFO);
              if StopNow then break;

              // rozpoczynamy sciaganie plikow
              for w:= 0 to DirList.Count-1 do
                begin
                  if StopNow then break;
                  Log('Downloading file list from directory: "'+DirList.Strings[w]+'"');
                  CoolTrayIcon.Hint:= ToolTip+#13+'Downloading file list from directory: '+DirList.Strings[w];
                  FtpClient.HostFileName:= CutMask(SettingsFile.readstring(Section, Entry, '[error: directory not found]'));
                  FtpClient.HostDirName:= DirList.Strings[w];
                  FtpClient.LocalFileName:= GetTempFile;

                  if ShowDetailsCheckBox.Checked then Log('Settings text mode file transfer', COLOR_DETAILS);
                  FtpClient.Binary:= False;
                  ValidateConnection;
                  if FtpClient.connected then
                    begin
                      FtpClient.Cwd;
                      FtpClient.Ls;
                    end;

                  FileList:= TStringList.create;

                  // zapisujemy liste plikow
                  if fileexists(GetTempFile) then
                    begin
                       AssignFile(TempFile, GetTempFile);
                       Reset(TempFile);
                       while not Eof(TempFile) do
                         begin
                           ReadLn(TempFile, Text);
                           FileList.Add(Text);
                         end;
                       CloseFile(TempFile);
                       DeleteFile(PChar(GetTempFile));
                    end;

                  FilesCountLabel.Caption:= inttostr(FileList.count);

                  // jesli sa jakies pliki na liscie to zaczynamy je pobierac
                  if ((FileList.Count<>0) and (not StopNow)) then
                    begin

                      // tworzymy odpowiedni katalog na dysku
                      if not directoryexists(backslash(DestinationEdit.text)+StringReplace((SettingsFile.readstring(Section, 'Name', '')+DirList.Strings[w]), '/', '\', [rfReplaceAll])) then
                        begin
                         if not forcedirectories(backslash(DestinationEdit.text)+StringReplace((SettingsFile.readstring(Section, 'Name', '')+DirList.Strings[w]), '/', '\', [rfReplaceAll])) then
                           begin
                             Log('ERROR: Can''t create directory structure: '+backslash(DestinationEdit.text)+StringReplace((SettingsFile.readstring(Section, 'Name', '')+DirList.Strings[w]), '/', '\', [rfReplaceAll]));
                             StopNow:= true;
                           end;
                        end;

                      // pobieramy plik(i) z danego katalogu
                      for q:= 0 to FileList.count-1 do
                        begin
                          if StopNow then break;
                          Log('Downloading file: "'+FileList.strings[q]+'"');
                          CoolTrayIcon.Hint:= ToolTip+#13+'Downloading file: '+FileList.strings[q];
                          FtpClient.HostFileName:= slash(DirList.strings[w])+FileList.strings[q];
                          FtpClient.LocalFileName:= backslash(DestinationEdit.text)+SettingsFile.ReadString(Section, 'Name', '[erorr: missing file name]')+backslash(StringReplace(DirList.Strings[w], '/', '\', [rfReplaceAll]))+FileList.strings[q];

                          // ustawiamy tryb przesylania plików
                          if IsBinary(FileList.strings[q]) then
                            begin
                              if ShowDetailsCheckBox.Checked then Log('Setting binary mode file transfer', COLOR_DETAILS);
                              FtpClient.Binary:= True;
                            end
                          else
                            begin
                              if ShowDetailsCheckBox.Checked then Log('Setting text mode file transfer', COLOR_DETAILS);
                             FtpClient.Binary:= False;
                            end;

                           ValidateConnection;
                           if FtpClient.Connected then FtpClient.Get;

                          FilesCountLabel.Caption:= inttostr(strtoint(FilesCountLabel.caption)-1);
                        end;
                      DeleteFile(PChar(GetTempFile));
                    end
                  else
                    begin
                      Log('Files not found');
                    end;

                  SubDirsCountLabel.Caption:= inttostr(strtoint(SubDirsCountLabel.Caption)-1);
                  FileList.Free;

                end;
              PathsCountLabel.Caption:= inttostr(strtoint(PathsCountLabel.caption)-1);
            end;

        if FtpClient.connected then FtpClient.Quit;

        // kompresujemy pliki
        Log('Finishing work on server: "'+SettingsFile.ReadString(Section, 'Name', '[error: missing server name]')+'"', $, true);
        if CompressCheckBox.Checked and not StopNow then
          begin
            Compressor:= SettingsFile.ReadString('SETTINGS', 'CompressionParams', '');
            Compressor:= StringReplace(Compressor, '%1', backslash(DestinationEdit.text)+SettingsFile.ReadString(Section, 'Name', ''), [rfReplaceAll, rfIgnoreCase]);
            Compressor:= StringReplace(Compressor, '%2', backslash(DestinationEdit.text)+StringReplace(SettingsFile.readstring(Section, 'Name', ''), '/', '\', [rfReplaceAll]), [rfReplaceAll, rfIgnoreCase]);
            Log('Executing: '+Compressor, COLOR_INFO);
            ShellExecute(application.Handle, 'open', pChar(SettingsFile.ReadString('SETTINGS', 'CompressionExecutable', '')), PChar(Compressor), nil, SW_ShowMinimized);
          end;
        HostsCountLabel.Caption:= inttostr(strtoint(HostsCountLabel.caption)-1);
        if FtpComboBox.ItemIndex <> 0 then
          break;
      end;

  if StopNow then
    Log('Operation aborted by user or because of errors', COLOR_ERROR, true);
  DirList.Free;
  Log('Operation duration: '+FormatStoper(Stoper), COLOR_INFO);
  if ErrorsCountLabel.caption<>'0' then
    Log('Errors: '+ErrorsCountLabel.caption, COLOR_ERROR);
  Log('*** Stopping ['+FormatDate(inttostr(Year))+'-'+FormatDate(inttostr(Month))+'-'+FormatDate(inttostr(Day))+']', COLOR_INTERNAL, true);
  if IsMinimized then
    CoolTrayIcon.ShowBalloonHint(Application.Title, 'Closing application', bitInfo, 20);
  CoolTrayIcon.Hint:= Application.Title;
  CountTimer.Enabled:= False;
  TimeLeftCountLabel.Caption:= '00:00:00';
  HostsCountLabel.Caption:= '0';
  FilesCountLabel.Caption:= '0';
  PathsCountLabel.Caption:= '0';
  SubDirsCountLabel.Caption:= '0';
  StatusPanel.Color:= clBtnFace;
  FtpComboBox.Enabled:= True;
  StartButton.Enabled:= True;
  AboutButton.Enabled:= True;
  BrowseButton.Enabled:= True;
  DestinationEdit.enabled:= True;
  ReconnectionsSpinEdit.Enabled:= True;
  MainForm.Caption:= AppName;
  QuitButton.Caption:= 'Close';
  ShowDetailsCheckBox.Enabled:= True;
  BreakCheckBox.Enabled:= True;
  if FileExists(SettingsFile.ReadString('SETTINGS', 'CompressionExecutable', '')) then
    CompressCheckBox.Enabled:= True
  else
    CompressCheckBox.enabled:= False;
end;


procedure TMainForm.FormCreate(Sender: TObject);
var
  x: Integer;
begin
  CoolTrayIcon.Hint:= Application.Title;
  if ParamStr(1) = '' then
    SettingsFilePath:= ChangeFileExt(Application.ExeName, '.ini')
  else
    SettingsFilePath:= ParamStr(1);
  VersionLabel.Caption:= VersionLabel.Caption+' '+FTP_RIPPER_VERSION;
  LogRichEdit.Lines.Clear; // musimy wyczyscic, bo inaczej pierwszy wpis nie jest kolorowany
  Log('FTP Ripper version: '+FTP_RIPPER_VERSION+#13, COLOR_INFO);

  if FileExists(SettingsFilePath) then
    begin
     SettingsFile := TIniFile.Create(SettingsFilePath);
     if FileExists(SettingsFile.ReadString('SETTINGS', 'CompressionExecutable', '')) then
      CompressCheckBox.Enabled:= True
     else
      CompressCheckBox.Enabled:= False;
    end
  else
    begin
      Log('Error: file not found: "'+SettingsFilePath+'"', COLOR_ERROR, True);
      Log('Download latest version from http://github.com/clash82/FTPRipper', COLOR_INFO);
      FtpComboBox.Enabled:= False;
      ShowDetailsCheckBox.Enabled:= False;
      DestinationEdit.Enabled:= False;
      BrowseButton.Enabled:= False;
      StartButton.Enabled:= False;
      AboutButton.Enabled:= False;
      StopNow:= True;
      CompressCheckBox.Enabled:= False;
      BreakCheckBox.Enabled:= False;
      ReconnectionsSpinEdit.Enabled:= False;
    end;

  MainForm.Caption:= Application.Title;
  AppName:= MainForm.Caption;
  if FileExists(SettingsFilePath) then
    DestinationEdit.Text:= SettingsFile.ReadString('SETTINGS', 'DestinationDir', 'c:\');

  FtpComboBox.Items.Add('[All]');

  if FileExists(SettingsFilePath) then
    begin
      x:= 1;
      while SettingsFile.ReadString('ftp'+IntToStr(x), 'Name', '') <> '' do
        begin
          FtpComboBox.Items.Add(SettingsFile.ReadString('ftp'+IntToStr(x), 'Name', ''));
          Inc(x, 1);
        end;
      FtpComboBox.ItemIndex:= 0;
    end;
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if FileExists(PChar(GetTempFile)) then
    DeleteFile(PChar(GetTempFile));
  if FileExists(ChangeFileExt(Application.ExeName,'.ini')) then
    SettingsFile.Free;
end;

procedure TMainForm.CountTimerTimer(Sender: TObject);
begin
  Inc(Stoper, 1);
  TimeLeftCountLabel.Caption:= FormatStoper(Stoper);
end;

procedure TMainForm.FtpClientRequestDone(Sender: TObject; RqType: TFtpRequest; ErrCode: Word);
begin
  if ShowDetailsCheckBox.Checked then
    begin
      Log('Request ' + IntToStr(Ord(RqType)) + ' completed, server response code: '+IntToStr(FtpClient.StatusCode), COLOR_DETAILS);
      Log('Server response code: "' + FtpClient.LastResponse + '"', COLOR_DETAILS);
      if ErrCode = 0 then
        Log('Operation successfully completed', COLOR_DETAILS)
      else
        Log('Operation cannot be completed, reason: "' + IntToStr(ErrCode) +' (' + FtpClient.ErrorMessage + ')"', COLOR_DETAILS, True);
    end;
end;

procedure TMainForm.FtpClientSessionConnected(Sender: TObject; ErrCode: Word);
begin
  if ShowDetailsCheckBox.Checked then
    Log('Connection established, server response code: ' + IntToStr(ErrCode), COLOR_DETAILS);
end;

procedure TMainForm.FtpClientSessionClosed(Sender: TObject; ErrCode: Word);
begin
  if ShowDetailsCheckBox.Checked then
    Log('Connection close, server response code: ' + IntToStr(ErrCode), COLOR_DETAILS);
end;

procedure TMainForm.FtpClientDisplay(Sender: TObject; var Msg: String);
begin
  if ShowDetailsCheckBox.Checked then
    Log('FTP: ' + Msg, COLOR_FTP);
end;

procedure TMainForm.AboutButtonClick(Sender: TObject);
begin
  AboutForm.Show(FTP_RIPPER_VERSION);
end;

procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if FtpClient.Connected and not StopNow then
    begin
      CanClose:= False;
      Application.Minimize;
      IsMinimized:= true;
    end
  else
    CanClose:= True;
end;

procedure TMainForm.FtpClientError(Sender: TObject; var Msg: String);
begin
  Log('Error: '+Msg, COLOR_ERROR, True);
  ErrorsCountLabel.Font.Color:= COLOR_ERROR;
  ErrorsCountLabel.Caption:= IntToStr(StrToInt(ErrorsCountLabel.Caption)+1);
end;

procedure TMainForm.FtpClientBgException(Sender: TObject; E: Exception; var CanClose: Boolean);
begin
  ShowMessage('Application exception, please contact with author');
end;

procedure TMainForm.BrowseButtonClick(Sender: TObject);
var
  Path: string;
begin
  Path:= BrowseForFolder('Select destination directory:', '', true);
  if Path <> '' then
    DestinationEdit.Text:= Path;
end;

procedure TMainForm.ClearMenuItemClick(Sender: TObject);
begin
  LogRichEdit.Lines.Clear;
end;

procedure TMainForm.CoolTrayIconMinimizeToTray(Sender: TObject);
begin
  IsMinimized:= true;
end;

procedure TMainForm.CoolTrayIconDblClick(Sender: TObject);
begin
  if IsMinimized then
    begin
      CoolTrayIcon.ShowMainForm;
      IsMinimized:= false;
    end
  else
    begin
      Application.Minimize;
      IsMinimized:= true;
    end;
end;

end.
