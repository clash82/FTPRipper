unit about;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, StdCtrls, ShellApi;

type
  TAboutForm = class(TForm)
    LegalLabel: TLabel;
    CompilerLabel: TLabel;
    IcsLabel: TLabel;
    CloseButton: TButton;
    LogoImage: TImage;
    UrlLabel: TLabel;
    CopyrightLabel: TLabel;
    NameLabel: TLabel;
    CoolTrayIconLabel: TLabel;
    GitUrlLabel: TLabel;
    procedure UrlLabelClick(Sender: TObject);
  private
    { Private declarations }
  public
    procedure Show(Version: String);
    { Public declarations }
  end;

var
  AboutForm: TAboutForm;

implementation

{$R *.dfm}

procedure TAboutForm.Show(Version: String);
begin
 Application.CreateForm(TAboutForm, AboutForm);
 AboutForm.NameLabel.Caption:= Application.Title+' '+Version;
 AboutForm.ShowModal;
 AboutForm.Free;
end;

procedure TAboutForm.UrlLabelClick(Sender: TObject);
begin
  ShellExecute(Application.Handle, 'open', PChar((Sender as TLabel).Caption), nil, nil, SW_ShowNormal);
end;

end.
