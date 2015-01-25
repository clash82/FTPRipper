{
	FTP Ripper
	(c) 2008-2015 Rafa³ Toborek
	http://toborek.info
	http://github.com/clash82/FTPRipper
}

program ftp_rip;

uses
  Forms,
  main in 'main.pas' {MainForm},
  about in 'about.pas' {AboutForm};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'FTP Ripper';
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.