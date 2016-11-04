unit PayamCallerIDServiceUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, SvcMgr, Dialogs,
  IdAntiFreezeBase, IdAntiFreeze, IdBaseComponent, IdComponent,
  IdTCPServer, ExtCtrls, IdThreadMgr, IdThreadMgrDefault,IdStack,IdSocketHandle,SyncObjs,Winsock,
  DB, ADODB  ,activeX;

 

type
  PClient   = ^TClient;
  TClient   = record
    PeerIP               : string[15];            { Cleint IP address }
    HostName             : String[40];            { Hostname }
    UserName             : String[200];           { Username }
    UserID               : Integer;               { UserID }
    Connected,                                    { Time of connect }
    LastAction           : TDateTime;             { Time of last transaction }
    Thread               : Pointer;               { Pointer to thread }
  end;

  TPayamCallerIDService = class(TService)
    Timer: TTimer;
    LogTimer: TTimer;
    TCPServer: TIdTCPServer;
    IdAntiFreeze: TIdAntiFreeze;
    ThreadManager: TIdThreadMgrDefault;
    InsertLogWhenDBDisconnected: TTimer;
    TestTimer: TTimer;
    ConnectionTimer: TTimer;
    procedure ServiceExecute(Sender: TService);
    procedure TCPServerConnect(AThread: TIdPeerThread);
    procedure TCPServerExecute(AThread: TIdPeerThread);
    procedure TCPServerDisconnect(AThread: TIdPeerThread);
    procedure TimerTimer(Sender: TObject);
    procedure LogTimerTimer(Sender: TObject);
    procedure InsertLogWhenDBDisconnectedTimer(Sender: TObject);
    procedure TestTimerTimer(Sender: TObject);
    procedure ConnectionTimerTimer(Sender: TObject);
 
  private
    { Private declarations }
    function  LogCallQuery(dateOfCall : string; gDateOfCall : string ; timeOfCall :string; internalNo:string;coLine:string;externalPhoneNumber:string;duration:string;centralCode:string;isIncoming:boolean):Boolean;overload;
    function  LogCallQuery(dateOfCall : string; gDateOfCall : string ; timeOfCall :string; internalNo:string;coLine:string;externalPhoneNumber:string;duration:string;centralCode:string;isIncoming:boolean;KeepLogOnDatabaseError:boolean):Boolean;overload;
    function  MakeComPortConnection():Boolean;
    procedure WriteToConfigFile(ConfigItemKey: string;ConfigItemValue : string);
    function  ReadFromConfigFile(ConfigItemKey: string):string;
    procedure Split(const Delimiter: Char;  Input: string; const Strings: TStrings) ;
    function  GetShamsiDateString():string;
    function  GetShamsiDate(Date : String;Time : String):string;
    function  GetGeorgianFormattedDate(Date : String;Time : String):string ;
    function  GetHour(Hour : String;Time : String):string ;
    function  GetMinute(Minute :String; Time : String):string ;
    function  GetTimeString():string;
    function  TokenizeString(stringToBeTokenized :string;stringsplitChar : char):TStringList;
    function  Get24Hour(hour: string; isAM : boolean):string;
    function  GetIPFromHost(var HostName, IPaddr, WSAErr: string): Boolean;
    function  GetProfileName(externalPhoneNumber : string):String;
    procedure ParseTDE100Log(s : string);
    procedure ParseTDE600Log(s : string);
    procedure ParseKX824Log(s : string);
    procedure ReadFromComport;
    procedure ParseDelimited(const sl : TStrings; const value : string; const delimiter : string) ;
    procedure NotifyClients(coLine : string;caller :string;timeOfCall:string);
    function  ConnectToComport():Boolean;
    procedure writeToLogFile(log : string);
    function  ReadFromLogFile():string;
    procedure writeToCallFile(call : string);
    function  ReadFromCallFile():string;
    function  writeToCentralCOLinesFile(coLines : string):boolean;
    function  ReadFromCentralCOLinesFile():string;
    procedure InsertLogsToDB(logs : string);
    procedure NotifyForPeigiriTamasFormWhenCallEnded(IsIncoming: Boolean; logID : Integer;internalNo : string;externalPhoneNumber:String;Duration:String);
    function  GetCallLogID():Integer;
    function  GetCityName(externalPhoneNumber : string):string;
    function  GetEmployeeID(internalNo : string):Integer;
    procedure ShowMessageM(message:string);
    function  InsertCall(coLine : string;caller : string;DateofCall : string;TimeOfCall : String):boolean;
    function  InsertCallerIDInfo(Name : String;ResponsibleEmployee:Integer;RelatedToName:String;Phonebook:String;coLine : string;caller : string;DateofCall : string;TimeOfCall : String):boolean;
    procedure InsertCallsToDB(calls : string);
    function  GetListOfOnlineUsers():string;
    function  GetPhoneWithoutCode(externalPhoneNumber :string):string;
    function IsValidMobile(phoneNum : string):boolean;
    function IsValidTel(phoneNum : string):boolean;
    function GetTelMobileLikeClause(IsMobile : boolean;phoneNum :string):string;
    function IsAdminUser(userName : String):boolean;
    Function GetTimeInMilliSeconds(theTime : TTime): Int64;
    function IsStrANumber(const S: string): Boolean;
    function IsNotAvailableCalls(number : string):boolean;
   
  public
    function GetServiceController: TServiceController; override;
    { Public declarations }
  end;

const
  DefaultServerIP = '127.0.0.1';
  DefaultServerPort = 7676;

  RxBufferSize = 256;
  TxBufferSize = 256;
  
  ConfigurationFileName  = 'Configuration.txt';
  ComPortKey =   'ComPort:';
  ComPortBaudRateKey = 'ComPortBaudRate:';
  CentralTypeKey     = 'CentralType:';
  LogFileName        = 'Log.txt';
  CallFileName        = 'Calls.txt';
  CentralSpecialCOLinesFileName = 'CSpecialCOs.txt';


 

var
  PayamCallerIDService: TPayamCallerIDService;
  Clients            : TThreadList;     // Holds the data of all clients
  ConfigurationFile  : TextFile;
  LogFile : TextFile;
  CallFile :TextFile;
  CentralCOLinesFile :TextFile;
  CentralType              : string;
  CentralPortNumber        : string;
  CentralBaudRate          : string;
  ComPortIsOpen            : Boolean;
  DatabaseIsConnected      : Boolean;
  ComFile: THandle;
  countero : Integer;
  LogBuffer : String;
  TestCounter : Integer;
  TempPortNumber,TempPortBaudRate:string;
  SpecialCOLines : string;
  NotAvailableCalls : string;


implementation

uses StrUtils, CallerIDServerDataModuleUnit , UConvert,UFaDate, DateUtils;
{$R *.DFM}

procedure ServiceController(CtrlCode: DWord); stdcall;
begin
  PayamCallerIDService.Controller(CtrlCode);
end;

function TPayamCallerIDService.GetServiceController: TServiceController;
begin
  Result := ServiceController;
end;

procedure TPayamCallerIDService.ServiceExecute(Sender: TService);
var
  Bindings                  : TIdSocketHandles;
  PortNumValue              : string;
  Host,ThisIP, Err          : string;
  DBServername,DBUsername,DBPassword          :string;
  ClientsCount : integer;
begin
    CoInitialize(nil);

    CentralType     := '';
    CentralBaudRate := '9600';
    CentralPortNumber := '';
    LogBuffer := '';


    TestCounter := 1;
    NotAvailableCalls := '';
   
   
  //Setup Com Port
    PortNumValue :=  ReadFromConfigFile(ComPortKey);
    if PortNumValue <> '' then
    begin
       CentralPortNumber :=  PortNumValue;
       CentralBaudRate   := ReadFromConfigFile(ComPortBaudRateKey);
       CentralType       := ReadFromConfigFile(CentralTypeKey);
       MakeComPortConnection();
    end;

  //Setup Database




   //setp Special Lines
   SpecialCOLines := ReadFromCentralCOLinesFile;

  //setup and start TCPServer
  Bindings := TIdSocketHandles.Create(TCPServer);
  try
    with Bindings.Add do
    begin
      if GetIPFromHost(Host, ThisIP, Err) then
      begin
         IP := ThisIP;
      end
      else
      begin
         IP := DefaultServerIP;
      end;
      Port := DefaultServerPort;
    end;
    try
      TCPServer.Bindings:=Bindings;
      TCPServer.Active:=True;
    except on E:Exception do
     // handle E.Message;
    end;
  finally
    Bindings.Free;
  end;
  //setup TCPServer

  //other startup settings
  Clients := TThreadList.Create;
  Clients.Duplicates := dupAccept;

//CentralType := 'TDE600';

//setup Timers
Timer.Enabled := True;
LogTimer.Enabled := True;
InsertLogWhenDBDisconnected.Enabled := True;
//TestTimer.Enabled := True;
ConnectionTimer.Enabled := True;





while not Terminated do
ServiceThread.ProcessRequests(True);// wait for termination

Timer.Enabled := False;
LogTimer.Enabled := False;
InsertLogWhenDBDisconnected.Enabled := False;
//TestTimer.Enabled := False;
ConnectionTimer.Enabled := False;


  try

    CallerIDServerDataModule.ADOConnection.Close;
    CloseHandle(ComFile);
    ClientsCount := Clients.LockList.Count;

  finally
    Clients.UnlockList;
  end;

 { if (ClientsCount > 0) then //and (TCPServer.Active) then
    begin
      Action := caNone;
      ShowMessage('Can''t close CallerID Server while there are connected clients!');
    end
  else }
  //begin
    TCPServer.Active := False;
    Clients.Free;
 // end;

  CoUninitialize();

end;

procedure TPayamCallerIDService.TCPServerConnect(AThread: TIdPeerThread);
var
  NewClient: PClient;
begin
  GetMem(NewClient, SizeOf(TClient));

  NewClient.PeerIP      := AThread.Connection.Socket.Binding.PeerIP;
  NewClient.HostName    := GStack.WSGetHostByAddr(NewClient.PeerIP);
  NewClient.Connected   := Now;
  NewClient.LastAction  := NewClient.Connected;
  NewClient.Thread      := AThread;

  AThread.Data := TObject(NewClient);

  try
    Clients.LockList.Add(NewClient);
  finally
    Clients.UnlockList;
  end;

end; (* TCPServer Connect *)

procedure TPayamCallerIDService.TCPServerExecute(AThread: TIdPeerThread);
var
  Client : PClient;
  Command : string;
  SelClient : PClient;
  i : Integer;
begin
  try
  if not AThread.Terminated and AThread.Connection.Connected then
  begin
    Client := PClient(AThread.Data);
    Client.LastAction := Now;

    try
      Command := AThread.Connection.ReadLn;
    except on err:Exception do begin
       AThread.Connection.Disconnect;
       exit;
       end;
    end;

    if  LeftStr(Command, Length('UserName:')) = 'UserName:' then
    begin
        Client.UserName := RightStr(Command, Length(Command)-Length('UserName:'));
    end
    else if LeftStr(Command, Length('UserID:')) = 'UserID:' then
    begin
        Client.UserID := StrtoInt(RightStr(Command, Length(Command)-Length('UserID:')));
    end
    else if LeftStr(Command, Length('FetchOnlineUsers')) = 'FetchOnlineUsers' then
    begin
        AThread.Connection.WriteLn('OnlineUsersAre:'+GetListOfOnlineUsers);
    end
    else if LeftStr(Command, Length('CentralType:')) = 'CentralType:' then
    begin
        CentralType := (RightStr(Command, Length(Command)-Length('CentralType:')));
    end
    else if LeftStr(Command, Length('ComPortNumber:')) = 'ComPortNumber:' then
    begin
        TempPortNumber := (RightStr(Command, Length(Command)-Length('ComPortNumber:')));
    end
    else if LeftStr(Command, Length('ComPortBaudRate:')) = 'ComPortBaudRate:' then
    begin
        TempPortBaudRate := (RightStr(Command, Length(Command)-Length('ComPortBaudRate:')));
    end
    else if Command = 'FetchSettings' then
    begin
        AThread.Connection.WriteLn('Settings'+'#0S#'+CentralType+'#0E#'+'#1S#'+CentralPortNumber+'#1E#'+'#2S#'+CentralBaudRate+'#2E#');
    end
    else if Command = 'ReadSpecialCOLines' then
    begin
        AThread.Connection.WriteLn('SpecialCOLines:'+SpecialCOLines);
    end
    else if  LeftStr(Command, Length('WriteSpecialCOLines:')) = 'WriteSpecialCOLines:' then
    begin
      if   writeToCentralCOLinesFile((RightStr(Command, Length(Command)-Length('WriteSpecialCOLines:')))) then
             AThread.Connection.WriteLn('SpecialCOLinesSuccess')
      else
             AThread.Connection.WriteLn('SpecialCOLinesError');       
    end
    else if Command = 'ApplyServiceSetting' then
    begin
       
       try
       if CentralType <> '' then
            WriteToConfigFile(CentralTypeKey,CentralType);
       if ComPortIsOpen and ((TempPortNumber <> CentralPortNumber)  or (TempPortBaudRate <> CentralBaudRate)) then
            CloseHandle(ComFile);
       except
            AThread.Connection.WriteLn('ComPortError');
       end;

       if ((TempPortNumber <> CentralPortNumber)  or (TempPortBaudRate <> CentralBaudRate)) then
       begin
           CentralPortNumber := TempPortNumber;
           CentralBaudRate   := TempPortBaudRate;
           ComPortIsOpen     := False;
           if not ConnectToComport then
           begin
              AThread.Connection.WriteLn('ComPortError');
           end
           else
           begin
              AThread.Connection.WriteLn('ComPortSuccess');
           end;   
       end;

        



       
     
      

       

    end
    else if Command = 'SetPasokhgooJaygozin' then
    begin
        if Not Assigned(Clients) then
        begin
          exit;
        end;
        with Clients.LockList do
           try
            for i := 0 to Count-1 do
            begin
             SelClient := PClient(Items[i]);
             TIdPeerThread(SelClient.Thread).Connection.WriteLn('PasokhgooJaygozinNotification');
           end;
           finally
             Clients.UnlockList;

           end;

    end
    else if Command = 'SetMarbootbeJaygozin' then
    begin
       if Not Assigned(Clients) then
        begin
          exit;
        end;
      with Clients.LockList do
           try
            for i := 0 to Count-1 do
            begin
             SelClient := PClient(Items[i]);
             TIdPeerThread(SelClient.Thread).Connection.WriteLn('MarbootbeJaygozinNotification');
           end;
           finally
             Clients.UnlockList;

           end;
    end;


  end;
  except  on E:exception do
      ShowMessageM('Exception In Execute Method : '+ E.Message);
  end;
end; (* TCPServer Execute *)

procedure TPayamCallerIDService.TCPServerDisconnect(
  AThread: TIdPeerThread);
var
  Client: PClient;
begin
  Client := PClient(AThread.Data);
  try
    Clients.LockList.Remove(Client);
  finally
    Clients.UnlockList;
  end;
  FreeMem(Client);
  AThread.Data := nil;
  ShowMessageM('Server Disconnected');


end; (* TCPServer Disconnect *)

procedure TPayamCallerIDService.TimerTimer(Sender: TObject);
begin
 Timer.Enabled := False;
 ReadFromComport();
 Timer.Enabled := True;
end;    (* TimerTimer *)

function  TPayamCallerIDService.GetShamsiDateString():string;
var
myDate,myDateTime : TDateTime;
shamsiConvertor : UFaDate.TFaDate;
fs                    : TFormatSettings;
Day,Month,Year        : integer;
DayStr,MonthStr,YearStr        : string;

begin
try
{ GetLocaleFormatSettings(LOCALE_SYSTEM_DEFAULT, fs);
 fs.ShortDateFormat := 'dd/mm/yyyy';
 fs.ShortTimeFormat := 'hh:nn';
 fs.DateSeparator   := '/';
 fs.TimeSeparator   := ':'; }

myDate := Now;
{Day :=  Integer(DayOf(myDate));
Month :=  Integer(MonthOf(myDate));
if Day < 10 then
     DayStr := '0'+IntToStr(Day)
else
     DayStr := IntToStr(Day);
if Month < 10 then
     MonthStr := '0'+IntToStr(Month)
else
     MonthStr := IntToStr(Month);
YearStr := IntTostr(Integer(YearOf(myDate)));
myDateTime :=  StrToDateTime(DayStr+'/'+MonthStr+'/'+YearStr+' 09:00',fs);  }

//shamsiConvertor := UFaDate.TFaDate.CreateByGregorianDate(myDateTime);
shamsiConvertor := UFaDate.TFaDate.CreateByGregorianDate(myDate);
Result  :=   shamsiConvertor.ToDateString();
except
    ShowMessageM('Exception In Shamsi DateString');
end;

end;   (* GetShamsiDateString *)

function  TPayamCallerIDService.GetTimeString():string;
var
myDate : TDateTime;
shamsiConvertor : UFaDate.TFaDate;

begin
try
myDate := Now;
shamsiConvertor := UFaDate.TFaDate.CreateByGregorianDate(myDate);
Result  :=   shamsiConvertor.ToTimeString;
except
    ShowMessageM('Exception In Shamsi TimString');
end;

end;   (* Get Time String *)


procedure TPayamCallerIDService.ReadFromComport;
var
s: String;
d: array[1..100] of Char;
BytesRead : Cardinal;
i: Integer;

begin
 try
  if not ReadFile (ComFile, d, sizeof(d), BytesRead ,Nil) then
   begin
      ShowMessageM('Error In Reading From Com Port ' + BoolToStr(ComPortIsOpen));
      exit;
   end;

   s := '';
   for i := 1 to BytesRead do s := s + d[I];
   LogBuffer := LogBuffer + s;
  except
    ShowMessageM('Exception in Reading from Com port');
  end;
end;  (* Read From Com port *)

procedure TPayamCallerIDService.ParseTDE600Log(s : string);
var
tokens: TStringList;

//Call Info
dateOfCall        : string;
gDateOfCall       : string;
timeOfCall        : string;
internalNo        : string;
coLine            : string;
externalPhoneNumber : string;
duration          : string;
centralCode       : string;
isIncoming        : boolean;

begin
  //ShowMessageM(s);
   isIncoming := False;
   try
   if ((s <> '')  and ((Trim(s))[1] in ['0'..'9'])) then
   begin
     tokens := TStringList.Create;
     Split(' ',s,tokens) ;


     dateOfCall  := GetShamsiDate(tokens[0],tokens[1]);//GetShamsiDateString();
     timeOfCall  := tokens[1];
     gDateOfCall := GetGeorgianFormattedDate(tokens[0],tokens[1]);//FormatDateTime('dd/mm/yyyy  hh:mm:ss', Now);

     //Incoming Call
     if (AnsiContainsStr(s, '<I>')) and (tokens.Count > 4 ) and ( LeftStr(tokens[4],Length('<I>')) = '<I>') then
     begin
          isIncoming := true;
          if ((tokens.Count = 7)  and (tokens[5] = '0''00') and (tokens[6] = 'AN') and (tokens[4] <> '<I>') and (trim(tokens[4]) <> '')) then begin
             NotAvailableCalls := NotAvailableCalls +tokens[4]+',';
             exit;
          end;
           //Call End
          {02/11/11 01:06PM   130 09 <I>02614301566            0'00 00:00'56            TR }
          if((AnsiContainsStr(s,'TR')) and (tokens.Count > 7 )) or((tokens.Count = 7 ) and (AnsiContainsStr(tokens[5], '''')) and (tokens[5] <> '0''00')  and (AnsiContainsStr(tokens[6], ':')) and (tokens[6] <> '00:00''00')) or
             ((tokens.Count = 7) and (tokens[5] = '0''00') and ((IsNotAvailableCalls(tokens[4])) or (AnsiContainsStr('-'+SpecialCOLines+'-','-'+tokens[3]+'-'))) and (AnsiContainsStr(tokens[6], ':')) and (tokens[6] <> '00:00''00')) then
          begin
            
             internalNo := tokens[2];
             coLine     := tokens[3];
             externalPhoneNumber := RightStr(tokens[4], Length(tokens[4])- 3);
             duration := StringReplace(StringReplace(tokens[6],'''',':', [rfReplaceAll, rfIgnoreCase]),'"','', [rfReplaceAll, rfIgnoreCase]);
             LogCallQuery( dateOfCall,
             gDateOfCall,
             timeOfCall,
             internalNo,
             coLine,
             externalPhoneNumber,
             duration,
             centralCode,
             isIncoming
            );


             
        
          {06/11/11 02:08PM   556 08 <I>77991693               0'00 00:00'22        }
         //  (( tokens.Count  = 7 ) and (tokens[6] = '00:00''00')) or
          end else if ((AnsiContainsStr(s, 'RC')) and (tokens.Count > 5 ) ) then
            begin
            //Call Waiting
             coLine     := tokens[3];
             externalPhoneNumber :=  RightStr(tokens[4], Length(tokens[4])- 3);
             NotifyClients(coLine,externalPhoneNumber,timeOfCall);
           end;
     {06/11/11 02:19PM   132 67 09192128583                    00:01'22  }      
     end else  if tokens.Count = 6 then
     begin
     //outgoing call
             internalNo := tokens[2];
             coLine     := tokens[3];
             externalPhoneNumber := tokens[4];
             duration := StringReplace(StringReplace(tokens[5],'''',':', [rfReplaceAll, rfIgnoreCase]),'"','', [rfReplaceAll, rfIgnoreCase]);
             LogCallQuery( dateOfCall,
             gDateOfCall,
             timeOfCall,
             internalNo,
             coLine,
             externalPhoneNumber,
             duration,
             centralCode,
             isIncoming
            );


     end;



   end;

 except
     ShowMessageM('Error in ParseTDE600 log : ' + s);
 end;
end; {ParseTDE600Log}

procedure TPayamCallerIDService.ParseTDE100Log(s : string);
var


tokens: TStringList;

//Call Info
dateOfCall        : string;
gDateOfCall       : string;
timeOfCall        : string;
internalNo        : string;
coLine            : string;
externalPhoneNumber : string;
duration          : string;
centralCode       : string;
isIncoming        : boolean;

begin
   isIncoming := False;
   try
   if ((s <> '')  and ((Trim(s))[1] in ['0'..'9'])) then
   begin
     tokens := TStringList.Create;
     Split(' ',s,tokens) ;


     dateOfCall  := GetShamsiDate(tokens[0],tokens[1]);//GetShamsiDateString();
     timeOfCall  := tokens[1];
     gDateOfCall := GetGeorgianFormattedDate(tokens[0],tokens[1]);//FormatDateTime('dd/mm/yyyy  hh:mm:ss', Now);

     //Incoming Call
     if (AnsiContainsStr(s, '<I>')) and (tokens.Count > 4 ) and ( LeftStr(tokens[4],Length('<I>')) = '<I>') then
     begin
          isIncoming := true;
          if ((tokens.Count = 7)  and (tokens[5] = '0''00') and (tokens[6] = 'AN') and (tokens[4] <> '<I>') and (trim(tokens[4]) <> '')) then begin
             NotAvailableCalls := NotAvailableCalls +tokens[4]+',';
             exit;
          end;
           //Call End
          {02/11/11 01:06PM   130 09 <I>02614301566            0'00 00:00'56            TR }
          if ((AnsiContainsStr(s,'TR')) and (tokens.Count > 7 )) or ((tokens.Count = 7 ) and (AnsiContainsStr(tokens[5], '''')) and (tokens[5] <> '0''00')  and (AnsiContainsStr(tokens[6], ':')) and (tokens[6] <> '00:00''00')) or
          ((tokens.Count = 7) and (tokens[5] = '0''00') and ((IsNotAvailableCalls(tokens[4])) or (AnsiContainsStr('-'+SpecialCOLines+'-','-'+tokens[3]+'-'))) and (AnsiContainsStr(tokens[6], ':')) and (tokens[6] <> '00:00''00')) then
          begin
             internalNo := tokens[2];
             coLine     := tokens[3];
             externalPhoneNumber := RightStr(tokens[4], Length(tokens[4])- 3);
             duration := StringReplace(StringReplace(tokens[6],'''',':', [rfReplaceAll, rfIgnoreCase]),'"','', [rfReplaceAll, rfIgnoreCase]);
             LogCallQuery( dateOfCall,
             gDateOfCall,
             timeOfCall,
             internalNo,
             coLine,
             externalPhoneNumber,
             duration,
             centralCode,
             isIncoming
            );


             
          {02/11/11 01:05PM   501 09 <I>02614301566                                     RC }
          end else  if (AnsiContainsStr(s, 'RC')) and (tokens.Count > 5 ) then
            begin
            //Call Waiting

             coLine     := tokens[3];
             externalPhoneNumber :=  RightStr(tokens[4], Length(tokens[4])- 3);
             NotifyClients(coLine,externalPhoneNumber,timeOfCall);
           end;
     end else  if tokens.Count = 6 then
     begin
     //outgoing call
             internalNo := tokens[2];
             coLine     := tokens[3];
             externalPhoneNumber := tokens[4];
             duration := StringReplace(StringReplace(tokens[5],'''',':', [rfReplaceAll, rfIgnoreCase]),'"','', [rfReplaceAll, rfIgnoreCase]);
             LogCallQuery( dateOfCall,
             gDateOfCall,
             timeOfCall,
             internalNo,
             coLine,
             externalPhoneNumber,
             duration,
             centralCode,
             isIncoming
            );


     end;



   end;

   except
      ShowMessageM('Error in TDE100 Log : ' + s );
   end;

end; {ParseTDE100Log}

procedure TPayamCallerIDService.ParseKX824Log(s : string);
var


tokens: TStringList;

//Call Info
dateOfCall        : string;
gDateOfCall       : string;
timeOfCall        : string;
internalNo        : string;
coLine            : string;
externalPhoneNumber : string;
duration          : string;
centralCode       : string;
isIncoming        : boolean;

begin
   isIncoming := False;
   try
   if ((s <> '')  and ((Trim(s))[1] in ['0'..'9'])) then
   begin
     tokens := TStringList.Create;
     Split(' ',s,tokens) ;


     dateOfCall  := GetShamsiDate(tokens[0],tokens[1]);//GetShamsiDateString();
     timeOfCall  := tokens[1];
     gDateOfCall := GetGeorgianFormattedDate(tokens[0],tokens[1]);//FormatDateTime('dd/mm/yyyy  hh:mm:ss', Now);

     //Incoming Call
     if  AnsiContainsStr(s, 'incoming') then
     begin
          isIncoming := true;
           //Call End
          {12/20/11   7:09PM  16  01   <    incoming    >02177461847       00:00'24" ....  }
          if (tokens.Count > 8 )then
          begin
             internalNo := tokens[2];
             coLine     := tokens[3];
             if AnsiContainsStr(s, 'DISA') then  begin
              externalPhoneNumber := RightStr(tokens[7], Length(tokens[7])- 1);
              duration := StringReplace(StringReplace(tokens[8],'''',':', [rfReplaceAll, rfIgnoreCase]),'"','', [rfReplaceAll, rfIgnoreCase]);
             end
             else begin
              externalPhoneNumber := RightStr(tokens[6], Length(tokens[6])- 1);
               duration := StringReplace(StringReplace(tokens[7],'''',':', [rfReplaceAll, rfIgnoreCase]),'"','', [rfReplaceAll, rfIgnoreCase]);
             end;

             LogCallQuery( dateOfCall,
             gDateOfCall,
             timeOfCall,
             internalNo,
             coLine,
             externalPhoneNumber,
             duration,
             centralCode,
             isIncoming
            );


             
          {12/20/11   7:09PM      01   <    incoming    >02177461847                 .... }
          end else
           begin
            //Call Waiting
             if tokens[3] = '<' then
             begin
               coLine     := tokens[2];
               externalPhoneNumber :=  RightStr(tokens[5], Length(tokens[5])- 1);
             end
             else if tokens[4] = '<' then
             begin
               coLine     := tokens[3];
               externalPhoneNumber :=  RightStr(tokens[6], Length(tokens[6])- 1);
             end;
             NotifyClients(coLine,externalPhoneNumber,timeOfCall);
           end;
     end else  if tokens.Count = 7 then
     begin
     //outgoing call
             internalNo := tokens[2];
             coLine     := tokens[3];
             externalPhoneNumber := tokens[4];
             duration := StringReplace(StringReplace(tokens[5],'''',':', [rfReplaceAll, rfIgnoreCase]),'"','', [rfReplaceAll, rfIgnoreCase]);
             LogCallQuery( dateOfCall,
             gDateOfCall,
             timeOfCall,
             internalNo,
             coLine,
             externalPhoneNumber,
             duration,
             centralCode,
             isIncoming
            );


     end;



   end;

   except
      ShowMessageM('Error in KX824 Log : ' + s );
   end;

end; {ParseKX824Log}

function    TPayamCallerIDService.TokenizeString(stringToBeTokenized :string;stringsplitChar : char):TStringList;
var
tokens: TStringList;
begin
try
tokens := TStringList.Create;
Split(stringsplitChar,stringToBeTokenized,tokens) ;
Result := tokens;
except
  ShowMessageM('Error in TokenizeString ');
end;
end;  {TokenizeString}

function    TPayamCallerIDService.Get24Hour(hour: string; isAM : boolean):string;
begin

try
if isAM then
begin
if StrToInt(hour) > 11 Then
begin
     Result := IntToStr(StrToInt(hour) - 12);
     exit;
end else
begin
      Result := hour;
      exit;
end;
end else
begin
    if StrToInt(hour) < 12 then
    begin
      Result := IntToStr(StrToInt(hour)+12);
      exit;
    end  else
    begin
        Result := hour;
        exit;
    end;
end;
  Result := hour;
except
    ShowMessageM('Error in Get 24 hour ');
end;

end;  {Get24Hour}

function   TPayamCallerIDService.LogCallQuery(dateOfCall : string; gDateOfCall : string ; timeOfCall :string; internalNo:string;coLine:string;externalPhoneNumber:string;duration:string;centralCode:string;isIncoming:boolean):Boolean;
begin
    Result :=  LogCallQuery(dateOfCall,gDateOfCall,timeOfCall,internalNo,coLine,externalPhoneNumber,duration,centralCode,isIncoming,True);
end;

function   TPayamCallerIDService.LogCallQuery(dateOfCall : string; gDateOfCall : string ; timeOfCall :string; internalNo:string;coLine:string;externalPhoneNumber:string;duration:string;centralCode:string;isIncoming:boolean;KeepLogOnDatabaseError:boolean):Boolean;
var
isValidTokens  : boolean;
isIncomingCall : string;
dateTokens,timeTokens,durationTokens : TStringList;
CallLogID      : Integer;
City           : string;



//Duration Tokens
DHour,DMinute,DSecond : string;
//Date of Call Tokens
DYear,DMonth,DDay     : string;
//Time of Call Tokens
THour,TMinute         : string;

begin
isValidTokens := false;
try
externalPhoneNumber := GetPhoneWithoutCode(externalPhoneNumber);
dateTokens :=   TokenizeString(dateOfCall,'/');
DYear   := dateTokens[0];
DMonth  := dateTokens[1];
DDay    := dateTokens[2];


timeTokens :=   TokenizeString(timeOfCall,':');
{if AnsiContainsStr(timeOfCall, 'AM')  then
begin
     THour := Get24Hour(timeTokens[0],true);
end
else begin
     THour := Get24Hour(timeTokens[0],false);
end; }
THour   := GetHour(timeTokens[0],timeOfCall);
TMinute := GetMinute(timeTokens[1],timeOfCall);//LeftStr(timeTokens[1],Length(timeTokens[1])-2);

durationTokens :=  TokenizeString(duration,':');
DHour := durationTokens[0];
DMinute := durationTokens[1];
DSecond := durationTokens[2];

if isIncoming  then
 begin
     isIncomingCall := '1';
 end
 else
 begin
     isIncomingCall := '0';
 end;

try
begin



CallLogID := GetCallLogID();
City      := GetCityName(externalPhoneNumber);

isValidTokens := true;


CallerIDServerDataModule.LogCallQuery.sql.text := 'insert into CallLog (ID,IsIncomingCall,DateOfCall,DYear,DMonth,DDay,TimeOfCall,THour,TMinute,InternalNo,CoLine,ExternalPhoneNumber,Duration,DHour,DMinute,DSecond,City,GDateOfCall) values ('+
      IntToStr(CallLogID)+','+isIncomingCall+','''+dateOfCall+''','+DYear+','+DMonth+','+DDay+','''+
      timeOfCall+''','+THour+','+TMinute+','''+
      internalNo+''','''+coLine+''','''+externalPhoneNumber+''','''+
      duration+''','+DHour+','+DMinute+','+DSecond+
      ','''+City+''','+'to_date('''+gDateOfCall+''',''dd/mm/yyyy hh24:mi:ss'')'+')';
CallerIDServerDataModule.LogCallQuery.ExecSQL;
CallerIDServerDataModule.LogCallQuery.Close;


//Notify For Peigiri Tamas
// KeepLogOnDatabaseError is true when log comes from Central Device else
//it would be false when the logs coming from a Log File (When Database Was DisConnected logs inserted into a log file)
if  KeepLogOnDatabaseError then
  NotifyForPeigiriTamasFormWhenCallEnded(isIncoming,CallLogID,internalNo,externalPhoneNumber,IntToStr((StrToInt(DHour)*3600)+(StrToInt(DMinute)*60)+StrToInt(DSecond)));

end
except

if ((isValidTokens) and (trim(externalPhoneNumber) <> '') and (IsStrANumber(externalPhoneNumber))) then begin
if  KeepLogOnDatabaseError  then
begin
writeToLogFile(
dateOfCall+','+
gDateOfCall+','+
timeOfCall+','+
internalNo+','+
coLine+','+
externalPhoneNumber+','+
duration+','+
'centralCode'+','+
BoolToStr(isIncoming)
);
end;
Result := False;
exit;
end;

end;

//Result := True;

except on E:exception do
    ShowMessageM('Error in Calllog Query '+ E.Message);
end;
Result := True;

end;  {LogCallQuery}

function  TPayamCallerIDService.GetPhoneWithoutCode(externalPhoneNumber :string):string;
var
PhoneNumber   : string;
begin
   PhoneNumber :=  externalPhoneNumber;
   try
   if LeftStr(PhoneNumber,Length('021')) = '021' then  begin
     PhoneNumber := RightStr(PhoneNumber,Length(PhoneNumber)-Length('021'));
   end
   else if LeftStr(PhoneNumber,Length('21')) = '21' then  begin
     PhoneNumber := RightStr(PhoneNumber,Length(PhoneNumber)-Length('21'));
   end
   else if LeftStr(PhoneNumber,Length('98')) = '98'  then  begin
     PhoneNumber := RightStr(PhoneNumber,Length(PhoneNumber)-Length('98'));
     if LeftStr(PhoneNumber,Length('9')) = '9' then begin
         PhoneNumber := '0'+PhoneNumber;
     end; 
   end
   else if LeftStr(PhoneNumber,Length('098')) = '098' then begin
     PhoneNumber := RightStr(PhoneNumber,Length(PhoneNumber)-Length('098'));
     if LeftStr(PhoneNumber,Length('9')) = '9' then begin
         PhoneNumber := '0'+PhoneNumber;
     end; 
   end
   else if LeftStr(PhoneNumber,Length('0098')) = '0098' then begin
     PhoneNumber := RightStr(PhoneNumber,Length(PhoneNumber)-Length('0098'));
     if LeftStr(PhoneNumber,Length('9')) = '9' then begin
         PhoneNumber := '0'+PhoneNumber;
     end;
   end
   else if LeftStr(PhoneNumber,Length('9')) = '9' then begin
        PhoneNumber := '0'+PhoneNumber;
   end
   else if LeftStr(PhoneNumber,Length('00')) = '00' then begin
        PhoneNumber := RightStr(PhoneNumber,Length(PhoneNumber)-Length('0'));
   end;
   except on E:Exception do
       ShowMessage('Error In GetPhoneWithoutCode : '+E.Message);
   end;
   PhoneNumber := StringReplace(PhoneNumber,'-','', [rfReplaceAll, rfIgnoreCase]);
   Result := PhoneNumber;

end;

function   TPayamCallerIDService.GetCityName(externalPhoneNumber : string):string;
var
City          : String;
RecordCount   : Integer;
PhoneNumber   : string;
begin

PhoneNumber :=  externalPhoneNumber;
City := '';
try

if LeftStr(PhoneNumber,Length('0098')) = '0098' then
     PhoneNumber := RightStr(PhoneNumber,Length(PhoneNumber)-Length('0098'))
else if LeftStr(PhoneNumber,Length('098')) = '098' then
     PhoneNumber := RightStr(PhoneNumber,Length(PhoneNumber)-Length('098'))
else if LeftStr(PhoneNumber,Length('98')) = '98'  then
     PhoneNumber := RightStr(PhoneNumber,Length(PhoneNumber)-Length('98'));
if LeftStr(PhoneNumber,Length('09')) = '09' then begin
  Result := 'Œÿ „Ê»«Ì·';
  exit;
end;
if LeftStr(PhoneNumber,Length('9')) = '9' then begin
  Result := 'Œÿ „Ê»«Ì·';
  exit;
end;



CallerIDServerDataModule.CityQuery.sql.text := ' '+
'select City from cityphonecode where ' +QuotedStr(PhoneNumber) +' like Code||''%''';
CallerIDServerDataModule.CityQuery.Open;
RecordCount :=  CallerIDServerDataModule.CityQuery.RecordCount;

if   RecordCount <> 0  then
begin
  City  :=  CallerIDServerDataModule.CityQuery.FieldByName('City').AsString;
end ;
 
CallerIDServerDataModule.CityQuery.Close;
except
ShowMessageM('Exception in Get City Query');
end;
Result := City ;



end; {GetCityName}


function   TPayamCallerIDService.GetCallLogID():Integer;
begin

try
begin

CallerIDServerDataModule.CallLogSequence.sql.text := 'select CALLLOG_SEQUENCE.nextval from dual';
CallerIDServerDataModule.CallLogSequence.Open;
Result := CallerIDServerDataModule.CallLogSequence.FieldByName('NextVal').AsInteger;
CallerIDServerDataModule.CallLogSequence.Close;
Exit;

end
except
   ShowMessageM('Error in Get CallLogID');
end;

Result := -1;
end;

function   TPayamCallerIDService.GetProfileName(externalPhoneNumber : string):String;
var
ProfileName   : String;
RecordCount   : Integer;
TelMobileLikeWhereClause : String;
begin

ProfileName := '';


try

if IsValidMobile(externalPhoneNumber) then
  TelMobileLikeWhereClause := GetTelMobileLikeClause(true,externalPhoneNumber)
else
  TelMobileLikeWhereClause := GetTelMobileLikeClause(false,externalPhoneNumber);

CallerIDServerDataModule.CallerQuery.sql.text := 'select Name from Profile where '   +
TelMobileLikeWhereClause;
CallerIDServerDataModule.CallerQuery.Open;
RecordCount :=  CallerIDServerDataModule.CallerQuery.RecordCount;

if   RecordCount = 1  then
begin
   ProfileName :=  CallerIDServerDataModule.CallerQuery.FieldByName('Name').AsString;
end ;
 
CallerIDServerDataModule.CallerQuery.Close;

except
    ShowMessageM('Error in Get Profile Name');
end;

Result := ProfileName ;



end; {GetProfileName}

function    TPayamCallerIDService.GetEmployeeID(internalNo : string):Integer;
var
RecordCount : Integer;
EmployeeID :  Integer;
begin

EmployeeID := 0;

try
CallerIDServerDataModule.EmployeeQuery.sql.text := 'select ID from Employee where InternalNo like'   +
QuotedStr('%-'+internalNo+'-%')+' Or InternalNo  like'+QuotedStr(internalNo+'-%')+' Or InternalNo like'+ QuotedStr('%-'+internalNo)+
' Or InternalNo ='+ QuotedStr(internalNo);
CallerIDServerDataModule.EmployeeQuery.Open;
RecordCount :=  CallerIDServerDataModule.EmployeeQuery.RecordCount;
if   RecordCount = 1  then
begin
  EmployeeID :=   CallerIDServerDataModule.EmployeeQuery.FieldByName('ID').AsInteger;
end;
CallerIDServerDataModule.EmployeeQuery.Close;
except

end;
Result := EmployeeID;
end;


procedure  TPayamCallerIDService.NotifyForPeigiriTamasFormWhenCallEnded(IsIncoming:Boolean;  logID : Integer;internalNo : string;externalPhoneNumber:String;Duration : String);
var
  SelClient           : PClient;
  i                   : Integer;
  ID : Integer;
  ProfileName:String;
  IncomingOutgoing    : String;
begin

if Not Assigned(Clients) then
begin
    exit;
end;

try

if IsIncoming then
  IncomingOutgoing := 'Incoming'
else
  IncomingOutgoing := 'Outgoing';
ID :=  GetEmployeeID(internalNo);
if   ID > 0  then
begin

  with Clients.LockList do
  try
    for i := 0 to Count-1 do
    begin
      SelClient := PClient(Items[i]);
      if (ID > 0) and (SelClient.UserID = ID) then
           TIdPeerThread(SelClient.Thread).Connection.WriteLn('OpenPeigiriTamas'+IncomingOutgoing+'#0S#'+IntToStr(logID)+'#0E#'+'#1S#'+externalPhoneNumber+'#1E#'+'#2S#'+GetProfileName(externalPhoneNumber)+'#2E#'+'#3S#'+Duration+'#3E#');
    end;
  finally
    Clients.UnlockList;
  end;

end;

except
    {hanlde exception here}
    ShowMessageM('Error in Notify Peigiri Tamas');
end;

end;


procedure   TPayamCallerIDService.NotifyClients(coLine : string; caller : string;timeOfCall:string);
var
  SelClient           : PClient;
  ID                  : Integer;
  ResponsibleEmployee : Integer;
  RelatedToID         : Integer;
  Name                : string;
  RecordCount         : Integer;
  i                   : Integer;
  NotificationMsg     : string;
  Gender    :Integer;
  Occupation,Email,Web,Tozihat,Country,State,City,AddressTitle,Address,
  Birthday,BirthMonth,Birthyear,PostalCode,Phonebook,Fax : string;
  RelatedToName : String;
  TelMobileLikeWhereClause     : String;

begin

if ((Trim(caller) = '') or (Trim(coLine) = '')) then
  exit;

if Not Assigned(Clients) then
begin
    exit;
end;

try

caller := GetPhoneWithoutCode(caller);
if IsValidMobile(Caller) then
    TelMobileLikeWhereClause  := GetTelMobileLikeClause(True,caller)
else
    TelMobileLikeWhereClause  := GetTelMobileLikeClause(false,caller);

CallerIDServerDataModule.CallerQuery.sql.text := 'select ProfileID,Profile.Name,Profile.Fax,PasokhgooyePishfarz,Profile.RELATEDTOID,Employee.Name as RelatedToName,GENDER,OCCUPATION,'+
'EMAIL,WEB,TOZIHAT,COUNTRY,STATE,CITY,ADDRESSTITLE,ADDRESS,BIRTHDAY,BIRTHMONTH,BIRTHYEAR,POSTALCODE,AddressBookName '+
' from Profile left outer join Employee on Profile.RelatedToID = Employee.ID inner join  AddressBook on Profile.AddressBookID = AddressBook.AddressBookID where '   +
TelMobileLikeWhereClause;
CallerIDServerDataModule.CallerQuery.Open;
RecordCount :=  CallerIDServerDataModule.CallerQuery.RecordCount;
if   RecordCount = 1  then
begin
  ID                  :=  CallerIDServerDataModule.CallerQuery.FieldByName('ProfileID').AsInteger;
  Name                :=  CallerIDServerDataModule.CallerQuery.FieldByName('Name').AsString;
  ResponsibleEmployee :=  CallerIDServerDataModule.CallerQuery.FieldByName('PasokhgooyePishfarz').AsInteger;
  RelatedToName       :=  CallerIDServerDataModule.CallerQuery.FieldByName('RelatedToName').AsString;
  RelatedToID         :=  CallerIDServerDataModule.CallerQuery.FieldByName('RELATEDTOID').AsInteger;
  Gender              :=  CallerIDServerDataModule.CallerQuery.FieldByName('GENDER').AsInteger;
  Fax                 :=  CallerIDServerDataModule.CallerQuery.FieldByName('Fax').AsString;


  Occupation := CallerIDServerDataModule.CallerQuery.FieldByName('OCCUPATION').AsString;
  Email      := CallerIDServerDataModule.CallerQuery.FieldByName('EMAIL').AsString;
  Web := CallerIDServerDataModule.CallerQuery.FieldByName('WEB').AsString;
  Tozihat := CallerIDServerDataModule.CallerQuery.FieldByName('TOZIHAT').AsString;
  Country := CallerIDServerDataModule.CallerQuery.FieldByName('COUNTRY').AsString;
  State := CallerIDServerDataModule.CallerQuery.FieldByName('STATE').AsString;
  City:=CallerIDServerDataModule.CallerQuery.FieldByName('CITY').AsString;
  AddressTitle:=CallerIDServerDataModule.CallerQuery.FieldByName('ADDRESSTITLE').AsString;
  Address:=CallerIDServerDataModule.CallerQuery.FieldByName('ADDRESS').AsString;

 Birthday:=CallerIDServerDataModule.CallerQuery.FieldByName('BIRTHDAY').AsString;
 BirthMonth:=CallerIDServerDataModule.CallerQuery.FieldByName('BIRTHMONTH').AsString;
 Birthyear:=CallerIDServerDataModule.CallerQuery.FieldByName('BIRTHYEAR').AsString;
 PostalCode:=CallerIDServerDataModule.CallerQuery.FieldByName('POSTALCODE').AsString;
 Phonebook:=CallerIDServerDataModule.CallerQuery.FieldByName('AddressBookName').AsString;



  with Clients.LockList do
  try
    for i := 0 to Count-1 do
    begin
      SelClient := PClient(Items[i]);
    {  if (IsAdminUser(SelClient.UserName) = false) and (ResponsibleEmployee > 0) and (SelClient.UserID <>  ResponsibleEmployee) then
          Continue; }
      NotificationMsg := 'KnownCaller'+       '#0S'+coLine+'#0E'+
                                              '#1S'+caller+'#1E'+
                                              '#2S'+IntToStr(ID)+'#2E'+
                                              '#3S'+IntToStr(ResponsibleEmployee)+'#3E'+
                                              '#4S'+IntToStr(Gender)+'#4E'+
                                              '#5S'+Name+'#5E'+
                                              '#6S'+Occupation+'#6E'+
                                              '#7S'+Email+'#7E'+
                                              '#8S'+Web+'#8E'+
                                              '#9S'+Tozihat+'#9E'+
                                              '#10S'+Country+'#10E'+
                                              '#11S'+State+'#11E'+
                                              '#12S'+City+'#12E'+
                                              '#13S'+AddressTitle+'#13E'+
                                              '#14S'+Address+'#14E'+
                                              '#15S'+Birthday+'#15E'+
                                              '#16S'+BirthMonth+'#16E'+
                                              '#17S'+Birthyear+ '#17E'+
                                              '#18S'+PostalCode+'#18E'+
                                              '#19S'+Phonebook+'#19E'+
                                              '#20S'+RelatedToName+'#20E'+
                                              '#21S'+IntToStr(RelatedToID)+'#21E';
      if Fax = caller then
         NotificationMsg := NotificationMsg + '#FAX#';
                                              

      TIdPeerThread(SelClient.Thread).Connection.WriteLn(NotificationMsg);

    end;
  finally
    Clients.UnlockList;
    InsertCallerIDInfo(Name,ResponsibleEmployee,RelatedToName,Phonebook,coLine,caller,GetShamsiDateString,timeOfCall);

  end;


end
else if RecordCount = 0  then
begin


 with Clients.LockList do
  try
    for i := 0 to Count-1 do
    begin
      SelClient := PClient(Items[i]);
      NotificationMsg := 'UnknowCaller'+'#0S'+coLine+'#0E'+'#1S'+caller+'#1E';
      TIdPeerThread(SelClient.Thread).Connection.WriteLn(NotificationMsg);

    end;
  finally
    Clients.UnlockList;
    InsertCallerIDInfo('',0,'','',coLine,caller,GetShamsiDateString,timeOfCall);
  end;


end;
CallerIDServerDataModule.CallerQuery.Close;
CallerIDServerDataModule.CallerQuery.SQL.Text := 'insert into PopupHistory (PDate,PTime,PhoneNumber,COLine) values ('''+
                                  GetShamsiDateString +''','''+GetTimeString+''','''+caller+''','''+coLine+''')';
CallerIDServerDataModule.CallerQuery.ExecSQL;
CallerIDServerDataModule.CallerQuery.Close;
except   on Exc:Exception do begin
   writeToCallFile(coLine+','+caller+','+GetShamsiDateString+','+timeOfCall);
  // ShowMessageM('Error In NotifyClient Query : '+CallerIDServerDataModule.CallerQuery.SQL.Text);
   ShowMessageM('Error Happend In Notiry Query : ' + Exc.Message);
   end;
end;


end; {NotifyClients}


function TPayamCallerIDService.MakeComPortConnection():Boolean;
var
  DCB       : TDCB;
  Config    : String;
  DeviceName: Array[0..80] of Char;
  CommTimeouts : TCommTimeouts;
  temp         : string;
begin

   StrPCopy(DeviceName, 'COM'+CentralPortNumber+':');

   ComFile := CreateFile(DeviceName,
                         GENERIC_READ or GENERIC_WRITE,
                         0, Nil,
                         OPEN_EXISTING,
                         FILE_ATTRIBUTE_NORMAL, 0);

   if ComFile = INVALID_HANDLE_VALUE then
   begin
     {hanlde invalidity of the com port which is being tried to connect to}
      Result := false;
      exit;
   end;


if not SetupComm(ComFile, RxBufferSize, TxBufferSize) then
begin
    {ShowMessage('Exception in Setup Port');  }
    Result := false;
    exit;
end;

if not GetCommState(ComFile, DCB) then
  begin
    {ShowMessage('Exception in Setup Port'); }
    Result := false;
    exit;
  end;

Config := 'baud='+CentralBaudRate+' parity=n data=8 stop=1';
if not BuildCommDCB(@Config[1], DCB) then
   begin
    {ShowMessage('Exception in Setup Port');}
    Result := false;
    exit;
  end;

if not SetCommState(ComFile, DCB) then
   begin
    {ShowMessage('Exception in Setup Port');}
    Result := false;
    exit;
  end;

with CommTimeouts do
begin
   ReadIntervalTimeout := 100;
   ReadTotalTimeoutMultiplier := 0;
   ReadTotalTimeoutConstant := 1000;
end;

if not SetCommTimeouts(ComFile, CommTimeouts) then
   begin
    {ShowMessage('Exception in Setup Port');}
    Result := false;
    exit;
   end;

   ComPortIsOpen := true;
   Result := true;
end;     {MakeComPortConnection}

function TPayamCallerIDService.ConnectToComport():Boolean;
begin
 try
 if MakeComPortConnection() then
     begin
        WriteToConfigFile(ComPortKey,CentralPortNumber);
        WriteToConfigFile(ComPortBaudRateKey,CentralBaudRate);
        Result:= true;
        exit;
     end;
 except
 end;    

 Result:= false;
end;  {ConnectToComport}


procedure  TPayamCallerIDService.WriteToConfigFile(ConfigItemKey: string;ConfigItemValue : string);
var
temp: string;
fileContent : String;
begin
   try
   fileContent  := '';
   if  FileExists(ConfigurationFileName) then
   begin

        AssignFile(ConfigurationFile, ConfigurationFileName);
        Reset(ConfigurationFile);
        while not Eof(ConfigurationFile) do
        begin
           ReadLn(ConfigurationFile, temp);
           if LeftStr(temp, Length(ConfigItemKey)) = ConfigItemKey  then
           begin
                  continue;

           end;
           fileContent :=   fileContent + temp + #13#10 ;
        end;
        CloseFile(ConfigurationFile);


       fileContent :=  fileContent  + ConfigItemKey +   ConfigItemValue + #13#10;
       Rewrite(ConfigurationFile);
       WriteLn(ConfigurationFile,fileContent);
       CloseFile(ConfigurationFile);
   end else
   begin
       AssignFile(ConfigurationFile, ConfigurationFileName);
       ReWrite(ConfigurationFile);
       WriteLn(ConfigurationFile,ConfigItemKey+ConfigItemValue);
       CloseFile(ConfigurationFile);

   end;
   except
       ShowMessageM('Error in Writing To Config File');
   end;
  
end;  {WriteToConfigFile}

function  TPayamCallerIDService.ReadFromConfigFile(ConfigItemKey: string):string;
var
temp : string;

begin
try
   if  FileExists(ConfigurationFileName) then
   begin

       AssignFile(ConfigurationFile, ConfigurationFileName);
       Reset(ConfigurationFile);
        while not Eof(ConfigurationFile) do
          begin
             ReadLn(ConfigurationFile, temp);   // Read and display one byte at a time
             if ( temp <> '') and (LeftStr(temp, Length(ConfigItemKey)) = ConfigItemKey) then
             begin
                Result := RightStr(temp, Length(temp)-Length(ConfigItemKey));
                CloseFile(ConfigurationFile);
                exit;
             end;
          end;
       Result := '';   
       CloseFile(ConfigurationFile);
   end;
   except
        ShowMessageM('Error in Reading From Config File');
   end;
end;  {ReadFromConfigFile}


procedure TPayamCallerIDService.writeToLogFile(log : string);
begin
try
AssignFile(LogFile,LogFileName);
if FileExists(LogFileName) then Append(LogFile)
else
Rewrite(LogFile);
writeln(LogFile,log);
CloseFile(LogFile);
except
    ShowMessageM('Error To Write Log File');
end;
end;

function  TPayamCallerIDService.ReadFromLogFile():string;
var
temp        : string;
finalString : string;

begin
    finalString := '';
try

   if  FileExists(LogFileName) then
   begin

       AssignFile(LogFile, LogFileName);
       Reset(LogFile);
        while not Eof(LogFile) do
          begin
             ReadLn(LogFile, temp);   // Read
             if finalString <> '' then
                finalString := finalString +#13#10 +temp
             else
                finalString := finalString +temp;

          end;
       Result := finalString;
       CloseFile(LogFile);
   end;
   except
     ShowMessageM('Error in Read From Log File');
   end;
   Result :=  finalString;
end;  {ReadFromConfigFile}

procedure TPayamCallerIDService.InsertLogsToDB(logs : string);
var
 i : Integer;
 s : String;
 tokens: TStringList;
begin
   
   try
   i :=  Pos( #10, logs );

   while (i <> 0)  do
   begin
      s          :=  LeftStr(logs,i-2);
      logs       :=  RightStr(logs,Length(logs)-i);
      tokens     := TStringList.Create;
      Split(',',s,tokens);
      try
      if not LogCallQuery(tokens[0],tokens[1]+' '+tokens[2],tokens[3],tokens[4],tokens[5],tokens[6],tokens[7],tokens[8],StrToBool(tokens[9]),False) then
      begin
         DeleteFile(LogFileName);
         writeToLogFile(s+#13#10+logs);
         exit;
      end;
      except

      end;
     i :=  Pos( #10, logs );
   end;


   if (i = 0) and (trim(logs) <> '') then
   begin
      s          := logs;
      tokens     := TStringList.Create;
      Split(',',s,tokens);
      try
      if not LogCallQuery(tokens[0],tokens[1]+' '+tokens[2],tokens[3],tokens[4],tokens[5],tokens[6],tokens[7],tokens[8],StrToBool(tokens[9]),False) then
      begin
         DeleteFile(LogFileName);
         writeToLogFile(s);
         exit;
      end;
      except

      end;
   end;

   DeleteFile(LogFileName);
   except
       ShowMessageM('Error in Inserting Logs To DB');
   end;

end;


procedure TPayamCallerIDService.writeToCallFile(call : string);
begin
try
AssignFile(CallFile,CallFileName);
if FileExists(CallFileName) then Append(CallFile)
else
Rewrite(CallFile);
writeln(CallFile,call);
CloseFile(CallFile);
except
    ShowMessageM('Error To Write Call File');
end;
end;

function  TPayamCallerIDService.ReadFromCallFile():string;
var
temp        : string;
finalString : string;

begin
    finalString := '';
try

   if  FileExists(CallFileName) then
   begin

       AssignFile(CallFile, CallFileName);
       Reset(CallFile);
        while not Eof(CallFile) do
          begin
             ReadLn(CallFile, temp);   // Read
             if finalString <> '' then
                finalString := finalString +#13#10 +temp
             else
                finalString := finalString +temp;

          end;
       Result := finalString;
       CloseFile(CallFile);
   end;
   except
     ShowMessageM('Error in Read From Call File');
   end;
   Result :=  finalString;
end;  {ReadFromCallFile}



function TPayamCallerIDService.InsertCall(coLine : string;caller : string;DateofCall : string;TimeOfCall : String):boolean;
var
RecordCount,ResponsibleEmployee : Integer;
Name,RelatedToName,Phonebook : String;
DateTokens,TimeTokens : TStringList;
DYear,DMonth,DDay,THour,TMinute : String;
begin

  try

CallerIDServerDataModule.MissedCallQuery.sql.text := 'select Profile.Name,PasokhgooyePishfarz,Employee.Name as RelatedToName,'+
'AddressBookName '+
' from Profile left outer join Employee on Profile.RelatedToID = Employee.ID left outer join  AddressBook on Profile.AddressBookID = AddressBook.AddressBookID where Tel like'   +
QuotedStr('%'+caller+'%')+' Or Fax  like'+QuotedStr('%'+caller+'%')+' Or Mobile like'+ QuotedStr('%'+caller+'%');
ShowMessageM(CallerIDServerDataModule.MissedCallQuery.sql.text);
CallerIDServerDataModule.MissedCallQuery.Open;
RecordCount :=  CallerIDServerDataModule.MissedCallQuery.RecordCount;
if   RecordCount <= 1  then
begin
  Name                :=  CallerIDServerDataModule.MissedCallQuery.FieldByName('Name').AsString;
  ResponsibleEmployee :=  CallerIDServerDataModule.MissedCallQuery.FieldByName('PasokhgooyePishfarz').AsInteger;
  RelatedToName       :=  CallerIDServerDataModule.MissedCallQuery.FieldByName('RelatedToName').AsString;
  Phonebook           :=  CallerIDServerDataModule.MissedCallQuery.FieldByName('AddressBookName').AsString;
  DateTokens := TokenizeString(DateofCall,'/');
  DYear   := dateTokens[0];
  DMonth  := dateTokens[1];
  DDay    := dateTokens[2];
  TimeTokens :=   TokenizeString(TimeOfCall,':');
  {if AnsiContainsStr(TimeOfCall, 'AM')  then
  begin
     THour := Get24Hour(TimeTokens[0],true);
  end
  else begin
     THour := Get24Hour(TimeTokens[0],false);
  end; }
  THour   := GetHour(TimeTokens[0],TimeOfCall);
  TMinute := GetMinute(TimeTokens[1],TimeOfCall);//LeftStr(TimeTokens[1],Length(TimeTokens[1])-2);
  CallerIDServerDataModule.MissedCallQuery.Close;
  CallerIDServerDataModule.MissedCallQuery.sql.text := ' insert into MissedCall (CoLine,Tel,Name,MarbootBe,PasokhgooPishfarz,PhoneBook,DateofCall,DYear,DMonth,DDay,TimeOfCall,THour,TMinute) values('+
                    QuotedStr(coLine)+','+QuotedStr(caller)+','+QuotedStr(Name)+','+QuotedStr(RelatedToName)+','+
                    IntToStr(ResponsibleEmployee)+','+QuotedStr(Phonebook)+','+QuotedStr(DateofCall)+','+
                    DYear+','+DMonth+','+DDay+','+QuotedStr(TimeOfCall)+','+THour+','+TMinute+')';
   {CallerIDServerDataModule.MissedCallQuery.sql.text := ' insert into MissedCall (CoLine,Tel,Name,MarbootBe,PasokhgooPishfarz,PhoneBook,DateofCall,DYear,DMonth,DDay,TimeOfCall,THour,TMinute) values('+
                    ''''+coLine+''','''+caller+''','''+Name+''','''+RelatedToName+''','+
                    IntToStr(ResponsibleEmployee)+','''+Phonebook+''','''+DateofCall+''','+
                    DYear+','+DMonth+','+DDay+','''+TimeOfCall+''','+THour+','+TMinute+')';
   ShowMessageM(CallerIDServerDataModule.MissedCallQuery.sql.text);}
  CallerIDServerDataModule.MissedCallQuery.ExecSQL;
end;
CallerIDServerDataModule.MissedCallQuery.Close;
except on E : Exception do
  begin
     ShowMessageM('Error In Insert A Call:'+ E.Message );
     Result  := false;
     Exit;
   end;  
end;

Result := True;

end;

function TPayamCallerIDService.InsertCallerIDInfo(Name : String;ResponsibleEmployee:Integer;RelatedToName:String;Phonebook:String;coLine : string;caller : string;DateofCall : string;TimeOfCall : String):boolean;
var
DateTokens,TimeTokens : TStringList;
DYear,DMonth,DDay,THour,TMinute : String;

begin

  try


  DateTokens := TokenizeString(DateofCall,'/');
  DYear   := dateTokens[0];
  DMonth  := dateTokens[1];
  DDay    := dateTokens[2];
  TimeTokens :=   TokenizeString(TimeOfCall,':');
  {if AnsiContainsStr(TimeOfCall, 'AM')  then
  begin
     THour := Get24Hour(TimeTokens[0],true);
  end
  else begin
     THour := Get24Hour(TimeTokens[0],false);
  end; }
  THour   := GetHour(TimeTokens[0],TimeOfCall);
  TMinute := GetMinute(TimeTokens[1],TimeOfCall);//LeftStr(TimeTokens[1],Length(TimeTokens[1])-2);
  CallerIDServerDataModule.MissedCallQuery.sql.text := ' insert into MissedCall (CoLine,Tel,Name,MarbootBe,PasokhgooPishfarz,PhoneBook,DateofCall,DYear,DMonth,DDay,TimeOfCall,THour,TMinute) values('+
                    QuotedStr(coLine)+','+QuotedStr(caller)+','+QuotedStr(Name)+','+QuotedStr(RelatedToName)+','+
                    IntToStr(ResponsibleEmployee)+','+QuotedStr(Phonebook)+','+QuotedStr(DateofCall)+','+
                    DYear+','+DMonth+','+DDay+','+QuotedStr(TimeOfCall)+','+THour+','+TMinute+')';  

   {CallerIDServerDataModule.MissedCallQuery.sql.text := ' insert into MissedCall (CoLine,Tel,Name,MarbootBe,PasokhgooPishfarz,PhoneBook,DateofCall,DYear,DMonth,DDay,TimeOfCall,THour,TMinute) values('+
                    ''''+coLine+''','''+caller+''','''+Name+''','''+RelatedToName+''','+
                    IntToStr(ResponsibleEmployee)+','''+Phonebook+''','''+DateofCall+''','+
                    DYear+','+DMonth+','+DDay+','''+TimeOfCall+''','+THour+','+TMinute+')';
   ShowMessageM(CallerIDServerDataModule.MissedCallQuery.sql.text);}
  CallerIDServerDataModule.MissedCallQuery.ExecSQL;
  CallerIDServerDataModule.MissedCallQuery.Close;
except on E : Exception do
  begin
     ShowMessageM('Error In Insert A Call:'+ E.Message );
     Result  := false;
     Exit;
   end;  
end;

Result := True;

end;

procedure TPayamCallerIDService.InsertCallsToDB(calls : string);
var
 i : Integer;
 s : String;
 tokens: TStringList;
begin
   try
   i :=  Pos( #10, calls );

   while (i <> 0)  do
   begin
      s          :=  LeftStr(calls,i-2);
      calls       :=  RightStr(calls,Length(calls)-i);
      tokens     := TStringList.Create;
      Split(',',s,tokens);
      try
      if not InsertCall(tokens[0],tokens[1],tokens[2],tokens[3]) then
      begin
         DeleteFile(CallFileName);
         writeToCallFile(s+#13#10+calls);
         exit;
      end;
      except

      end;
     i :=  Pos( #10, calls );
   end;


   if (i = 0) and (trim(calls) <> '') then
   begin
      s          := calls;
      tokens     := TStringList.Create;
      Split(',',s,tokens);
      try
      if not InsertCall(tokens[0],tokens[1],tokens[2],tokens[3]) then
      begin
         DeleteFile(CallFileName);
         writeToCallFile(s);
         exit;
      end;
      except

      end;
   end;

   DeleteFile(CallFileName);
   except
       ShowMessageM('Error in Inserting Calls To DB');
   end;
end; {Insert Calls To DB}

procedure TPayamCallerIDService.Split
   (const Delimiter: Char;
    Input: string;
    const Strings: TStrings) ;
begin
   try
   Assert(Assigned(Strings)) ;
   Strings.Clear;
   Strings.Delimiter := Delimiter;
   Strings.DelimitedText := Input;
   except
       ShowMessageM('Error in Split Method');
   end;
end; {Split}


function TPayamCallerIDService.GetIPFromHost
(var HostName, IPaddr, WSAErr: string): Boolean; 
type 
  Name = array[0..100] of Char; 
  PName = ^Name; 
var 
  HEnt: pHostEnt; 
  HName: PName; 
  WSAData: TWSAData; 
  i: Integer; 
begin 
  Result := False;     
  if WSAStartup($0101, WSAData) <> 0 then begin 
    WSAErr := 'Winsock is not responding."'; 
    Exit; 
  end; 
  IPaddr := ''; 
  New(HName); 
  if GetHostName(HName^, SizeOf(Name)) = 0 then
  begin 
    HostName := StrPas(HName^); 
    HEnt := GetHostByName(HName^); 
    for i := 0 to HEnt^.h_length - 1 do 
     IPaddr :=
      Concat(IPaddr,
      IntToStr(Ord(HEnt^.h_addr_list^[i])) + '.'); 
    SetLength(IPaddr, Length(IPaddr) - 1); 
    Result := True; 
  end
  else begin 
   case WSAGetLastError of
    WSANOTINITIALISED:WSAErr:='WSANotInitialised'; 
    WSAENETDOWN      :WSAErr:='WSAENetDown'; 
    WSAEINPROGRESS   :WSAErr:='WSAEInProgress'; 
   end; 
  end; 
  Dispose(HName); 
  WSACleanup; 
end;    {GetIPFromHost}






procedure TPayamCallerIDService.ParseDelimited(const sl : TStrings; const value : string; const delimiter : string) ;
var
   dx : integer;
   ns : string;
   txt : string;
   delta : integer;
begin
   delta := Length(delimiter) ;
   txt := value + delimiter;
   sl.BeginUpdate;
   sl.Clear;
   try
     while Length(txt) > 0 do
     begin
       dx := Pos(delimiter, txt) ;
       ns := Copy(txt,0,dx-1) ;
       sl.Add(ns) ;
       txt := Copy(txt,dx+delta,MaxInt) ;
     end;
   finally
     sl.EndUpdate;
   end;
end;  {ParseDelimited}




procedure TPayamCallerIDService.LogTimerTimer(Sender: TObject);
var
 i : Integer;
 s : String;
begin

   LogTimer.Enabled := false;
   try
   i :=  Pos( #10, LogBuffer );
   if ( i <> 0 ) then
   begin
      s         :=  LeftStr(LogBuffer,i-2);
      s         :=  TrimLeft(s);
      s         :=  StringReplace(s,'/ ','/', [rfReplaceAll, rfIgnoreCase]);
      s         :=  StringReplace(s,'*',' ', [rfReplaceAll, rfIgnoreCase]);
      LogBuffer :=  RightStr(LogBuffer,Length(LogBuffer)-i);
      if CentralType = 'TDE600' then
         ParseTDE600Log(s)
      else if CentralType = 'TDE100' then
         ParseTDE100Log(s)
      else if CentralType = 'KX824' then
         ParseKX824Log(s);   

   end;
   except on E:exception do
     ShowMessageM('Error in Log Timer Timer : ' + E.Message);

   end;
   LogTimer.Enabled := true;

end; {LogTimerTimer}

procedure TPayamCallerIDService.InsertLogWhenDBDisconnectedTimer(
  Sender: TObject);
var
logs:string;
calls:string;
begin
 try
 logs := ReadFromLogFile;
 InsertLogsToDB(logs);
 calls:= ReadFromCallFile;
 InsertCallsToDB(calls);
 except
   ShowMessageM('Error in Insert Log when DB disconnected Timer');
 end;

end;

procedure TPayamCallerIDService.TestTimerTimer(Sender: TObject);
begin


ShowMessageM('In Test Time');
if CentralType = ''  then
   exit;

if LogBuffer <> '' then
      LogBuffer := LogBuffer + #13#10 + '';
   LogBuffer := LogBuffer + '09/11/11 05:03PM   353 70 <I>09354099407            0''03 00:00''00 ' ;
   

{if LogBuffer <> '' then
      LogBuffer := LogBuffer + #13#10 + '';

   LogBuffer := LogBuffer + '09/11/11 05:00PM   353 09 <I>88755330               0''00 00:05''23            TR ';
  }

if TestCounter = 1  then
begin
   if LogBuffer <> '' then
      LogBuffer := LogBuffer + #13#10 + '';

   LogBuffer := LogBuffer + '09/11/11 05:03PM   353 70 <I>09354099407            0''03 00:00''00 ' ;
   TestCounter := TestCounter + 1;
end

else if TestCounter = 2  then
begin
   if LogBuffer <> '' then
      LogBuffer := LogBuffer + #13#10 + '';

   LogBuffer := LogBuffer + '09/11/11 05:04PM   561 70 <I>09354099407            0''00 00:00''23 ' ;
   TestCounter := TestCounter + 1;
end

else if TestCounter = 3  then
begin
   if LogBuffer <> '' then
      LogBuffer := LogBuffer + #13#10 + '';

   LogBuffer := LogBuffer + '09/11/11 04:59PM   582 23 <I>77834191               0''03 00:00''00 ';
   TestCounter := TestCounter + 1;
end
else if TestCounter = 4  then
begin
   if LogBuffer <> '' then
      LogBuffer := LogBuffer + #13#10 + '';

   LogBuffer := LogBuffer + '09/11/11 04:59PM   353 70 <I>88772756               0''04 00:00''00';
   TestCounter := TestCounter + 1;
end
else if TestCounter = 5  then
begin
   if LogBuffer <> '' then
      LogBuffer := LogBuffer + #13#10 + '';

   LogBuffer := LogBuffer + '09/11/11 05:00PM   308 09 <I>88755330               0''00 00:05''23            TR ';
   TestCounter := TestCounter + 1;
end;






end;

function  TPayamCallerIDService.GetListOfOnlineUsers():string;
var
  SelClient           : PClient;
  i                   : Integer;
  OnlineUsersString      : String;
begin

if Not Assigned(Clients) then
begin
    Result := '';
    exit;
end;

try

  OnlineUsersString := '';

  with Clients.LockList do
  try
    for i := 0 to Count-1 do
    begin
      SelClient := PClient(Items[i]);
      OnlineUsersString := OnlineUsersString +SelClient.UserName+'@###@';
    end;
  finally
    Clients.UnlockList;
  end;



except
    {hanlde exception here}
    ShowMessageM('Error in Notify Peigiri Tamas');
end;
Result :=   OnlineUsersString;

end;



procedure TPayamCallerIDService.ShowMessageM(message:string);
const
FileName = 'C:\message.txt';
var
F: TextFile;
begin
try
AssignFile(f,FileName);
if FileExists(FileName) then Append(f)
else
Rewrite(f);
writeln(f,message);
CloseFile(f);
except
end;
end;




procedure TPayamCallerIDService.ConnectionTimerTimer(Sender: TObject);
begin

try

CallerIDServerDataModule.TestConnection.sql.text := 'select 1 Result from dual';
CallerIDServerDataModule.TestConnection.Open;
CallerIDServerDataModule.TestConnection.Close;



except

try
 CallerIDServerDataModule.ADOConnection.Close;
except

end;

try
 CallerIDServerDataModule.ADOConnection.Open;
except

end;



end;


end;


function  TPayamCallerIDService.IsValidMobile(phoneNum : string):boolean;
begin
     if ((LeftStr(phoneNum,Length('098')) = '098' )   or
        (LeftStr(phoneNum,Length('98')) = '98' ))  then
           Result := False
     else if (LeftStr(phoneNum,Length('09')) = '09' )
          then
            Result := True
     else
            Result := False;

end;

function  TPayamCallerIDService.IsValidTel(phoneNum : string):boolean;
begin
    if ((LeftStr(phoneNum,Length('09')) = '09' )   or
         (LeftStr(phoneNum,Length('9')) = '9' ))  then
           Result := False
     else
           Result := True;

end;

function TPayamCallerIDService.GetTelMobileLikeClause(IsMobile : boolean;phoneNum :string):string;
begin

      if IsMobile then
           Result :=   '  ''-'' ||Mobile|| ''-'' like ''%-''||'+QuotedStr(phoneNum)+'||''-%'' '
       else
           Result :=   '  ''-'' ||Tel||''-''||Fax|| ''-'' like ''%-''||'+QuotedStr(phoneNum)+'||''-%'' ';


end;

function TPayamCallerIDService.IsAdminUser(userName : String):boolean;
begin
     if (userName = 'Admin') or (userName = 'ADMIN') or (userName = 'admin') then
        Result := true
     else
        Result  := false;

end;

function TPayamCallerIDService.GetShamsiDate(Date : String;Time : String):string ;
var
dateTokens,timeTokens : TStringList; 
DYear,DMonth,DDay     : string;
THour,TMinute         : string;


myDate,myDateTime : TDateTime;
shamsiConvertor : UFaDate.TFaDate;
fs                    : TFormatSettings;
Day,Month,Year        : integer;
DayStr,MonthStr,YearStr        : string;


begin
     try
     dateTokens :=   TokenizeString(Date,'/');
     if CentralType = 'KX824' then
     begin

       DMonth  := dateTokens[0];
       DDay    := dateTokens[1];
       DYear   := dateTokens[2];

     end
     else
     begin
       DDay    := dateTokens[0];
       DMonth  := dateTokens[1];
       DYear   := dateTokens[2]; 
     end;
     if Length(DYear) < 3 then
        DYear := '20'+DYear;
     if Length(DDay) < 2 then
        DDay  := '0'+ DDay;
     if Length(DMonth) < 2 then
        DMonth := '0' + DMonth;

    timeTokens :=   TokenizeString(Time,':');
    THour  :=  TimeTokens[0];
    TMinute := TimeTokens[1];

    if AnsiContainsStr(Time, 'AM')  then
     begin
       TMinute := LeftStr(timeTokens[1],Length(timeTokens[1])-2);
       if StrToInt(THour) > 11 Then
       begin
         THour := IntToStr(StrToInt(THour) - 12);
       end;
     end
    else if AnsiContainsStr(Time, 'PM') then
     begin
      TMinute := LeftStr(timeTokens[1],Length(timeTokens[1])-2);
      if StrToInt(THour) < 12 then
      begin
         THour := IntToStr(StrToInt(THour)+12);
      end;
     end;

    GetLocaleFormatSettings(LOCALE_SYSTEM_DEFAULT, fs);
    fs.ShortDateFormat := 'dd/mm/yyyy';
    fs.ShortTimeFormat := 'hh:nn';
    fs.DateSeparator   := '/';
    fs.TimeSeparator   := ':';


    myDateTime :=  StrToDateTime(DDay+'/'+DMonth+'/'+DYear+' '+THour+':'+TMinute,fs);
    shamsiConvertor := UFaDate.TFaDate.CreateByGregorianDate(myDateTime);
    Result  :=   shamsiConvertor.ToDateString();  
   except
    ShowMessageM('Exception In Shamsi Date From Central Date');
   end; 
end;

function TPayamCallerIDService.GetGeorgianFormattedDate(Date : String;Time : String):string ;
var
dateTokens,timeTokens : TStringList; 
DYear,DMonth,DDay     : string;
THour,TMinute         : string;





begin
     try
     dateTokens :=   TokenizeString(Date,'/');
     if CentralType = 'KX824' then
     begin

       DMonth  := dateTokens[0];
       DDay    := dateTokens[1];
       DYear   := dateTokens[2];

     end
     else
     begin
       DDay    := dateTokens[0];
       DMonth  := dateTokens[1];
       DYear   := dateTokens[2]; 
     end;
     if Length(DYear) < 3 then
        DYear := '20'+DYear;
     if Length(DDay) < 2 then
        DDay  := '0'+ DDay;
     if Length(DMonth) < 2 then
        DMonth := '0' + DMonth;

    timeTokens :=   TokenizeString(Time,':');
    THour  :=  TimeTokens[0];
    TMinute := TimeTokens[1];

    if AnsiContainsStr(Time, 'AM')  then
    begin
       TMinute := LeftStr(TMinute,Length(TMinute)-2);
       if StrToInt(THour) > 11 Then
       begin
         THour := IntToStr(StrToInt(THour) - 12);
       end;
    end
    else if AnsiContainsStr(Time, 'PM') then
    begin
      TMinute := LeftStr(TMinute,Length(TMinute)-2);
      if StrToInt(THour) < 12 then
      begin
         THour := IntToStr(StrToInt(THour)+12);
      end;
    end;




    Result :=  DDay+'/'+DMonth+'/'+DYear+' '+THour+':'+TMinute+':'+'00';

   except
    ShowMessageM('Exception In Georgian Formatted String');
   end; 

end;

function TPayamCallerIDService.GetHour(Hour : String;Time : String):string ;
var
THour         : string; 
begin

   THour := Hour;
   if AnsiContainsStr(Time, 'AM')  then
    begin
       if StrToInt(THour) > 11 Then
       begin
         THour := IntToStr(StrToInt(THour) - 12);
       end;
    end
    else if AnsiContainsStr(Time, 'PM') then
    begin
      if StrToInt(THour) < 12 then
      begin
         THour := IntToStr(StrToInt(THour)+12);
      end;
    end;
    Result := THour;

end;

function TPayamCallerIDService.GetMinute(Minute :String; Time : String):string ;
var    
TMinute         : string; 
begin

   TMinute := Minute;
   if ( AnsiContainsStr(Time, 'AM')) or (AnsiContainsStr(Time, 'PM')) then
    begin
       TMinute := LeftStr(TMinute,Length(TMinute)-2);
    end;
    Result := TMinute;

end;

Function TPayamCallerIDService.GetTimeInMilliSeconds(theTime : TTime): Int64;
var
Hour, Min, Sec, MSec: Word;
begin
DecodeTime(theTime,Hour, Min, Sec, MSec);

Result := (Hour * 3600000) + (Min * 60000) + (Sec * 1000) + MSec;
end;

function TPayamCallerIDService.IsStrANumber(const S: string): Boolean; 
var 
  P: PChar; 
begin 
  P      := PChar(S); 
  Result := False; 
  while P^ <> #0 do 
  begin 
    if not (P^ in ['0'..'9']) then Exit; 
    Inc(P); 
  end; 
  Result := True; 
end;

function TPayamCallerIDService.writeToCentralCOLinesFile(coLines : string):boolean;
var isSuccess : boolean;
begin
try
isSuccess := true;
AssignFile(CentralCOLinesFile,CentralSpecialCOLinesFileName);
{if FileExists(CentralCOLinesFile) then Append(CentralCOLinesFile)
else }
Rewrite(CentralCOLinesFile);
writeln(CentralCOLinesFile,coLines);
CloseFile(CentralCOLinesFile);
SpecialCOLines := coLines;
except
    isSuccess:= false;
    ShowMessageM('Error To Write CO Lines File');
end;

Result := isSuccess;

end;

function  TPayamCallerIDService.ReadFromCentralCOLinesFile():string;
var
temp        : string;
finalString : string;

begin
    finalString := '';
try

   if  FileExists(CentralSpecialCOLinesFileName) then
   begin

       AssignFile(CentralCOLinesFile, CentralSpecialCOLinesFileName);
       Reset(CentralCOLinesFile);
        while not Eof(CentralCOLinesFile) do
          begin
             ReadLn(CentralCOLinesFile, temp);   // Read
             if finalString <> '' then
                finalString := finalString +#13#10 +temp
             else
                finalString := finalString +temp;

          end;
       Result := finalString;
       CloseFile(CentralCOLinesFile);
   end;
   except
     ShowMessageM('Error in Read From Central COLines File');
   end;
   Result :=  finalString;
end;  {ReadFromCentralFile}

function  TPayamCallerIDService.IsNotAvailableCalls(number : string):boolean;
var i : integer;
    isNotAvailable : boolean;
begin
  isNotAvailable := false;
  if Length(NotAvailableCalls) > 0  then begin
    i :=  Pos(number,NotAvailableCalls);
    if i <> 0 then
    begin
      isNotAvailable := true;
      NotAvailableCalls := Copy(NotAvailableCalls,0,i-1)+Copy(NotAvailableCalls,i+Length(number)+1,Length(NotAvailableCalls));
    end;
  end;
    Result := isNotAvailable;
end;


end.
