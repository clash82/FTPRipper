program OverbyteIcsSslMailSnd;

{$R '..\..\OverbyteIcsXpManifest.res' '..\..\OverbyteIcsXpManifest.rc'}
{$R '..\..\OverbyteIcsCommonVersion.res'  '..\..\OverbyteIcsCommonVersion.rc'}

uses
  Forms,
  OverbyteIcsIniFiles in '..\..\OverbyteIcsIniFiles.pas',
  OverbyteIcsSslMailSnd1 in 'OverbyteIcsSslMailSnd1.pas' {SslSmtpTestForm};

{$R *.RES}

begin
  Application.CreateForm(TSslSmtpTestForm, SslSmtpTestForm);
  Application.Run;
end.
