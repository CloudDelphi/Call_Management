unit UFaDate;
{------------------------------------------}
{       Persian date functions unit        }
{Use this unit for persian date convertions}
{                                          }
{      Programmer: Salar Khalilzadeh       }
{            Copyright © 2008              }
{              SoftProjects                }
{                                          }
{---Website: www.softprojects.org ---------}
{----E-mail: SalarSoftwares@gmail.com -----}

{        Last update: 2008/04/13           }
interface
uses windows,sysutils,SysConst,math,DateUtils,strutils;


Const
  strDateSplitChar:string='/';
  faLeapMonth:word=12;
  enLeapMonth:word=2;
  faMonthNames:array [1..12] of string=
                   ('ÝÑæÑÏíä','ÇÑÏíÈåÔÊ','ÎÑÏÇÏ','ÊíÑ','ãÑÏÇÏ','ÔåÑíæÑ','ãåÑ','ÂÈÇä','ÂÐÑ','Ïí','Èåãä','ÇÓÝäÏ');
  faDayNames:array [1..7] of string=
                   ('ÔäÈå','íßÔäÈå','Ïæ ÔäÈå','Óå ÔäÈå','åÇÑ ÔäÈå','äÌ ÔäÈå','ÌãÚå');
  faDayNamesSmall:array [1..7] of string=
                   ('ÔäÈå','íß','Ïæ','Óå','åÇÑ','äÌ','ÌãÚå');
  faMonthDays: array [Boolean,1..12] of word=
    ((31, 31, 31, 31, 31, 31, 30, 30, 30, 30, 30, 29),
     (31, 31, 31, 31, 31, 31, 30, 30, 30, 30, 30, 30));

  enMonthDays: array [Boolean,1..12] of word =
    ((31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31),
     (31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31));

  faPassedDaysInMonths: array[1..13] of Word =
    (   0,  31,  62,  93, 124, 155, 186, 216, 246, 276, 306, 336, 365 );

  enPassedDaysInMonths: array[1..13] of Word =
    (   0,  31,  59,  90, 120, 151, 181, 212, 243, 273, 304, 334, 365 );

type
  TFaDate=class
  private
    fHasTimeData:boolean;
    fFaYear, fFaMonth, fFaDay: word;
    fFaHour, fFaMinute, fFaSecond, fFaMilliSecond: word;
    procedure ResetTimeData;
    procedure ResetDateData;
    procedure Initialize(gregorianDate: TDateTime); overload;
    procedure Initialize(persianDate: string); overload;
    procedure Initialize(persianYear, persianMonth, persianDay: word); overload;
    function GetDayName: string;
    function GetMonthName: string;
    function FormatString(format:string):string;

    procedure Util_ConvertToShamsi(gYear, gMonth, gDay: word; out faYear, faMonth, faDay: word);
    function Util_IsLeapYear(faYear: word): boolean;
    function Util_En_DaysInDate(gYear, gMonth, gDay: Word): Word;
    function Util_Fa_DaysInDate(faYear, faMonth, faDay: Word): Word;
    procedure Util_Fa_GetMonthAndDayByTotalDays(faTotalDays: word; out faMonth,
      faDay: Word);
    procedure Util_ConvertToGregorian(faYear, faMonth, faDay: word; out gYear,
      gMonth, gDay: word);
    procedure Util_En_GetMonthAndDayByTotalDays(enTotalDays, gYear: word;
      out gMonth, gDay: Word);
    function GetDaySmallName: string;
    procedure InitializeByGregorian(gregorianYear, gregorianMonth,
      gregorianDay: word);
    constructor Create(); overload;
  public
    constructor Create(gregorianDate: TDateTime); overload;
    constructor Create(persianDate: string); overload;
    constructor Create(persianYear, persianMonth, persianDay: word); overload;
    destructor Destroy();override;

    class function CreateByPersianDate(persianDate: string):TFaDate; overload;
    class function CreateByPersianDate(persianYear, persianMonth, persianDay: word):TFaDate; overload;
    class function CreateByGregorianDate(gregorianYear, gregorianMonth, gregorianDay: word):TFaDate;overload;
    class function CreateByGregorianDate(gregorianDate: TDateTime): TFaDate; overload;

    function ToString():string; overload;
    function ToString(format:string):string; overload;
    function ToDateString():string; overload;
    function ToTimeString():string; overload;
    function ToGregorianDate():TDateTime;
    function GetGregorianDateString():string;
    function GetDayOfWeek:Word;
    function GetDayOfYear:Word;
    function GetDaysInMonth: word;

    property DaySmallName:string read  GetDaySmallName;
    property HasTime:boolean read  fHasTimeData;
    property Year:word read  fFaYear;
    property Month:word read  fFaMonth;
    property Day:word read  fFaDay;
    property Hour:word read  fFaHour;
    property Minute:word read  fFaMinute;
    property Second:word read  fFaSecond;
    property MilliSecond:word read  fFaMilliSecond;
    property DayName:string read  GetDayName;
    property MonthName:string read  GetMonthName;
  end;
  
  TSplitedString = array of string;


implementation


function SplitString(str:string;splitChar:string):TSplitedString;
var
  index: Integer;
  spliterLength: Integer;
begin
  setLength(result,0);

  spliterLength:=Length(splitChar);
  while true do begin
    // Find splitter position
    index:=PosEx(splitChar,str, 1);

    // If something not found
    if(index=0)then begin
      // Oops thers is no maching case

      // if there is any rest of operation
      if(Length(str)>0) then begin
        // add it to result
        setLength(result,Length(result)+1);
        result[Length(result)-1]:=str;
      end;

      // exit from function
      Exit;
    end;

    // add to result
    setLength(result,Length(result)+1);
    result[Length(result)-1]:=copy(str,1,index-1);

    // delete it from string
    delete( str,1,index-1+spliterLength);
  end;
end;


{ TFarDate }

constructor TFaDate.Create(gregorianDate: TDateTime);
begin
     Initialize(gregorianDate);
end;

constructor TFaDate.Create(persianDate: string);
begin
     Initialize(persianDate);
end;

constructor TFaDate.Create(persianYear, persianMonth, persianDay: word);
begin
     Initialize(persianYear, persianMonth, persianDay);
end;

constructor TFaDate.Create;
begin
     //Nothing to do
end;

class function TFaDate.CreateByGregorianDate(gregorianDate: TDateTime): TFaDate;
begin
     Result:= TFaDate.Create();
     Result.Initialize(gregorianDate);
end;

class function TFaDate.CreateByPersianDate(persianDate: string): TFaDate;
begin
     Result:= TFaDate.Create(persianDate);
end;

class function TFaDate.CreateByGregorianDate(gregorianYear, gregorianMonth, gregorianDay: word): TFaDate;
begin
     Result:= TFaDate.Create();
     Result.InitializeByGregorian(gregorianYear, gregorianMonth, gregorianDay);
end;

class function TFaDate.CreateByPersianDate(persianYear, persianMonth, persianDay: word): TFaDate;
begin
     Result:= TFaDate.Create(persianYear, persianMonth, persianDay);
end;

destructor TFaDate.Destroy;
begin
     inherited;
end;

function TFaDate.FormatString(format: string): string;
var
  tempVal,tempStr,formatted: string;

begin
  formatted:=format;

  // Year formatting
  formatted:=StringReplace(formatted,'yyyy',inttostr(self.fFaYear),[rfReplaceAll, rfIgnoreCase]);
  formatted:=StringReplace(formatted,'yyy',inttostr(self.fFaYear),[rfReplaceAll, rfIgnoreCase]);
  formatted:=StringReplace(formatted,'yy',copy(inttostr(self.fFaYear),3,2),[rfReplaceAll, rfIgnoreCase]);

  // Day fromatting
  tempVal:=self.DayName;
  formatted:=StringReplace(formatted,'dddddd',tempVal,[rfReplaceAll, rfIgnoreCase]);
  formatted:=StringReplace(formatted,'ddddd',tempVal,[rfReplaceAll, rfIgnoreCase]);
  formatted:=StringReplace(formatted,'dddd',tempVal,[rfReplaceAll, rfIgnoreCase]);
  formatted:=StringReplace(formatted,'ddd',GetDaySmallName,[rfReplaceAll, rfIgnoreCase]);
  tempStr:=inttostr(self.fFaDay);
  if(self.fFaDay<10) then    tempStr:='0'+tempStr;
  formatted:=StringReplace(formatted,'dd',tempStr,[rfReplaceAll, rfIgnoreCase]);
  formatted:=StringReplace(formatted,'d',inttostr(self.fFaDay),[rfReplaceAll, rfIgnoreCase]);

  // month formatting
  tempVal:=self.MonthName;
  formatted:=StringReplace(formatted,'mmmm',tempVal,[rfReplaceAll, rfIgnoreCase]);
  formatted:=StringReplace(formatted,'mmm',tempVal,[rfReplaceAll, rfIgnoreCase]);
  tempStr:=inttostr(self.fFaMonth);
  if(self.fFaMonth<10) then    tempStr:='0'+tempStr;
  formatted:=StringReplace(formatted,'mm',tempStr,[rfReplaceAll]);
  formatted:=StringReplace(formatted,'m',inttostr(self.fFaMonth),[rfReplaceAll]);

  // Hour formatting
  tempStr:=inttostr(self.fFaHour);
  if(self.fFaHour<10) then    tempStr:='0'+tempStr;
  formatted:=StringReplace(formatted,'hh',tempStr,[rfReplaceAll, rfIgnoreCase]);
  formatted:=StringReplace(formatted,'h',inttostr(self.fFaHour),[rfReplaceAll, rfIgnoreCase]);

  // Minute formatting
  tempStr:=inttostr(self.fFaMinute);
  if(self.fFaMinute<10) then    tempStr:='0'+tempStr;
  formatted:=StringReplace(formatted,'nn',tempStr,[rfReplaceAll, rfIgnoreCase]);
  formatted:=StringReplace(formatted,'n',inttostr(self.fFaMinute),[rfReplaceAll, rfIgnoreCase]);
  formatted:=StringReplace(formatted,'MM',tempStr,[rfReplaceAll]);
  formatted:=StringReplace(formatted,'M',inttostr(self.fFaMinute),[rfReplaceAll]);

  // Second formatting
  tempStr:=inttostr(self.fFaSecond);
  if(self.fFaSecond<10) then    tempStr:='0'+tempStr;
  formatted:=StringReplace(formatted,'ss',tempStr,[rfReplaceAll, rfIgnoreCase]);
  formatted:=StringReplace(formatted,'s',inttostr(self.fFaSecond),[rfReplaceAll, rfIgnoreCase]);

  // MilliSecond formatting
  tempStr:=inttostr(self.fFaMilliSecond);
  if(self.fFaMilliSecond<10) then    tempStr:='00'+tempStr;
  if(self.fFaMilliSecond<100) then    tempStr:='0'+tempStr;
  formatted:=StringReplace(formatted,'zzz',tempStr,[rfReplaceAll, rfIgnoreCase]);
  formatted:=StringReplace(formatted,'z',inttostr(self.fFaMilliSecond),[rfReplaceAll, rfIgnoreCase]);

  result:=formatted;
end;

function TFaDate.GetDaysInMonth: word;
begin
     result:=faMonthDays[Util_IsLeapYear(fFaYear),fFaMonth];
end;

function TFaDate.GetDayName: string;
begin
     result:=faDayNames[GetDayOfWeek];
end;

function TFaDate.GetDayOfWeek: Word;
var
  weeks: Integer;
  LeapDays: Integer;
begin
  // All leap days
  LeapDays:=(fFaYear div 4)+1;

  // All days
  LeapDays:=(fFaYear*365)+LeapDays+GetDayOfYear;

  // weeks count
  weeks:=(LeapDays div 7)+0;

  // This day
  Result:=LeapDays-(weeks * 7);

  // If this is last day of week
  if(Result=0) then Result:=7;
end;

function TFaDate.GetDayOfYear: Word;
begin
     Result:=Util_Fa_DaysInDate(fFaYear,fFaMonth,fFaDay);
end;

function TFaDate.GetDaySmallName: string;
begin
     result:=faDayNamesSmall[GetDayOfWeek];
end;

function TFaDate.ToGregorianDate: TDateTime;
var gYear,gMonth,gDay:word;
begin
     // Convert it to persian format
     Util_ConvertToGregorian(fFaYear,fFaMonth,fFaDay,gYear, gMonth, gDay);

     Result:=EncodeDateTime(gYear,gMonth,gDay,fFaHour,fFaMinute,fFaSecond,fFaMilliSecond);
end;

function TFaDate.GetGregorianDateString: string;
begin
     Result:=DateToStr(ToGregorianDate);
end;

function TFaDate.GetMonthName: string;
begin
     result:=faMonthNames[fFaMonth];
end;

procedure TFaDate.ResetTimeData();
begin
     fFaHour:=0;
     fFaMilliSecond:=0;
     fFaMinute:=0;
     fFaSecond:=0;
end;

procedure TFaDate.ResetDateData();
begin
     fFaDay	:=0;
     fFaMonth	:=0;
     fFaYear	:=0;
end;

function TFaDate.ToString: string;
begin
  if(fHasTimeData) then
    result:=ToDateString
  else
    result:=FormatString('yyyy/mm/dd HH:nn');
end;

function TFaDate.ToDateString: string;
begin
     result:=FormatString('yyyy/mm/dd');
end;

function TFaDate.ToString(format: string): string;
begin
     result:=FormatString(format);
end;


function TFaDate.ToTimeString: string;
begin
     result:=FormatString('HH:nn');
end;

procedure TFaDate.Util_ConvertToShamsi(gYear, gMonth, gDay: word; out faYear, faMonth,
  faDay: word);
Const
  faFirstDay:word=79;
var
  LeapDay, PassedDays: Integer;
  LastYearWasLeapYear: Boolean;
begin
  PassedDays:=Util_En_DaysInDate(gYear,gMonth,gDay);

  LastYearWasLeapYear:=IsLeapYear(gYear-1);

  // Calculate the persian year
  faYear:=gYear-622;

  if Util_IsLeapYear(faYear) then
    LeapDay := 1
  else
    LeapDay := 0;

  // 79 is farvardin different from april first day
  if LastYearWasLeapYear and (LeapDay = 1) then
    Inc(PassedDays, (366-79)) // 287 days
  else
    Inc(PassedDays, (365-79)); //286 days

  if PassedDays > (365 + LeapDay) then
  begin
    Inc(faYear);
    Dec(PassedDays, 365 + LeapDay);
  end;

  // Calculate month and days
  Util_Fa_GetMonthAndDayByTotalDays(PassedDays,faMonth,faDay);
end;

procedure TFaDate.Util_ConvertToGregorian(faYear, faMonth, faDay : word; out gYear, gMonth, gDay: word);
Const
  faFirstDay:word=79;
var
  LeapDay, PassedDays: Integer;
  LastYearWasLeapYear: Boolean;
begin
  PassedDays:=Util_Fa_DaysInDate(faYear,faMonth,faDay);

  LastYearWasLeapYear:=Util_IsLeapYear(faYear-1);

  // Calculate the gregorian year
  gYear:=faYear+621;

  if IsLeapYear(gYear) then
    LeapDay := 1
  else
    LeapDay := 0;

  // 79 is farvardin different from aprils first day
  if LastYearWasLeapYear and (LeapDay = 1) then
    Inc(PassedDays, (80)) // 287 days
  else
    Inc(PassedDays, (79)); //286 days

  if PassedDays > (365 + LeapDay) then
  begin
    Inc(gYear);
    Dec(PassedDays, 365 + LeapDay);
  end;

  // Calculate month and days
  Util_En_GetMonthAndDayByTotalDays(PassedDays,gYear,gMonth,gDay);
end;

procedure TFaDate.Util_En_GetMonthAndDayByTotalDays(enTotalDays,gYear:word;out gMonth, gDay: Word);
var
  LeapDay, m: Integer;
  enIsLeapYear:boolean;
begin
  LeapDay := 0;
  gMonth := 0;
  gDay := 0;
  enIsLeapYear:=IsLeapYear(gYear);
  for m := 2 to 13 do
  begin
    if (m > enLeapMonth) and enIsLeapYear then
      LeapDay := 1;
    if enTotalDays <= (enPassedDaysInMonths[m] + LeapDay) then
    begin
      gMonth := m - 1;
      if gMonth <= enLeapMonth then LeapDay := 0;
      gDay := enTotalDays - (enPassedDaysInMonths[gMonth] + LeapDay);
      Break;
    end;
  end;
end;

procedure TFaDate.Util_Fa_GetMonthAndDayByTotalDays(faTotalDays:word;out faMonth, faDay: Word);
var
  temp: Integer;
begin
  // 186= 31*6
  if (faTotalDays <= 186)then
  begin
    temp:=faTotalDays mod 31;

    if(temp=0)then begin

         faMonth := faTotalDays div 31;
         faDay := 31;

    end else begin

         faMonth := (faTotalDays div 31) + 1;
         faDay := temp;
    end;

  end else begin
    // decrease first 6 month
    faTotalDays:=faTotalDays-186;

    // Get remainder value of devide operation with 30
    // 30 is length of persian months after 6 month 
    temp:=faTotalDays mod 30;

    if(temp=0)then begin

         faMonth := (faTotalDays div 30) + 6;
         faDay := 30;

    end else begin

         faMonth := (faTotalDays div 30) + 7;
         faDay := temp;
    end;

  end;
End;

function TFaDate.Util_IsLeapYear(faYear:word):boolean;
begin
  Result := (((faYear + 38) * 31) mod 128) <= 30;
end;

function TFaDate.Util_Fa_DaysInDate(faYear, faMonth, faDay: Word): Word;
begin
    Result := faPassedDaysInMonths[faMonth] + faDay;
    if (faMonth > faLeapMonth) and Util_IsLeapYear(Year) then
      Inc(Result);
end;


function TFaDate.Util_En_DaysInDate(gYear, gMonth, gDay: Word): Word;
begin
    Result := enPassedDaysInMonths[gMonth] + gDay;
    if (gMonth > enLeapMonth) and IsLeapYear(gYear) then
      Inc(Result);
end;



// Initialize the class
procedure TFaDate.Initialize(gregorianDate:TDateTime);
var gYear,gMonth,gDay:word;
begin
     // Decode the gregorian date
     DecodeDateTime	(gregorianDate,gYear,gMonth,gDay,
          fFaHour, fFaMinute, fFaSecond, fFaMilliSecond );

     // Convert it to persian format
     Util_ConvertToShamsi(gYear,gMonth,gDay,fFaYear, fFaMonth, fFaDay);
end;

// Initialize the class
procedure TFaDate.Initialize(persianDate: string);
var parts: TSplitedString;
begin
     // Split the input
     parts:=SplitString(persianDate,strDateSplitChar);

     // the result should have three parts at least
     if Length(parts)<3 then begin
       raise EInvalidArgument.Create('Invalid persian date format!');
     end;

     // There is no time information
     fHasTimeData:=false;
     ResetTimeData();

     try
        // Initialize the variables
        fFaYear:=strtoint(parts[0]);
        fFaMonth:=strtoint(parts[1]);
        fFaDay:=strtoint(parts[2]);
     except
        ResetDateData;
        raise;
     end;
end;

// Initialize the class
procedure TFaDate.Initialize(persianYear, persianMonth, persianDay: word);
begin
    // There is no time information
    fHasTimeData:=false;
    ResetTimeData();
    
    // Initialize the variables
    fFaYear:=persianYear;
    fFaMonth:=persianMonth;
    fFaDay:=persianDay;
end;

// Initialize the class
procedure TFaDate.InitializeByGregorian(gregorianYear, gregorianMonth, gregorianDay: word);
begin
    // There is no time information
    fHasTimeData:=false;
    ResetTimeData();
    
    // Convert it to persian format
    Util_ConvertToShamsi(gregorianYear,gregorianMonth,gregorianDay,fFaYear, fFaMonth, fFaDay);
end;


end.
