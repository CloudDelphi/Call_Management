program PayamCallerIDServiceProject;

uses
  SvcMgr,
  PayamCallerIDServiceUnit in 'PayamCallerIDServiceUnit.pas' {PayamCallerIDService: TService},
  UConvert       in 'UConvert.pas',
  UFaDate        in 'UFaDate.pas',
  CallerIDServerDataModuleUnit in 'CallerIDServerDataModuleUnit.pas' {CallerIDServerDataModule: TDataModule};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TCallerIDServerDataModule, CallerIDServerDataModule);
  Application.CreateForm(TPayamCallerIDService, PayamCallerIDService);  
  Application.Run;
end.
