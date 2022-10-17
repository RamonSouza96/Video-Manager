unit Unit1;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Memo.Types, FMX.ScrollBox,
  System.StrUtils,Math,System.Permissions, FMX.Objects, FMX.TabControl, FMX.Layouts, FMX.Effects,

  System.Messaging,
  Androidapi.JNI.GraphicsContentViewText,
  Androidapi.Helpers,
  Androidapi.JNI.App,
  System.IOUtils,
  Androidapi.JNI.JavaTypes,
  Androidapi.JNI.Net,
  Androidapi.JNI.Provider,
  Androidapi.JNI.Os,
  Androidapi.JNIBridge,
  FMX.Media,
  Androidapi.JNI.Media,
  FMX.Surfaces,
  FMX.Helpers.Android,
  Androidapi.JNI.Support;


  const
  RECORD_VIDEO = 9;

type
  TExecutaClickMobile = procedure(Sender: TObject; const Point: TPointF) of Object;
  TFrmMain = class(TForm)
    MediaPlayer1: TMediaPlayer;
    MediaPlayerControl1: TMediaPlayerControl;
    TabControl1: TTabControl;
    Permission: TTabItem;
    Lista: TTabItem;
    TabPreview: TTabItem;
    Rectangle1: TRectangle;
    Layout1: TLayout;
    Text1: TText;
    Rectangle2: TRectangle;
    Layout2: TLayout;
    Rectangle3: TRectangle;
    Layout3: TLayout;
    Image1: TImage;
    Text2: TText;
    Switch1: TSwitch;
    Image2: TImage;
    Text3: TText;
    Switch2: TSwitch;
    Image3: TImage;
    Text4: TText;
    Switch3: TSwitch;
    Image4: TImage;
    Text5: TText;
    Switch4: TSwitch;
    Rectangle4: TRectangle;
    BtnNext: TSpeedButton;
    VertScrollBox1: TVertScrollBox;
    Circle1: TCircle;
    Image5: TImage;
    Rectangle7: TRectangle;
    Rectangle5: TRectangle;
    ShadowEffect3: TShadowEffect;
    Rectangle6: TRectangle;
    BtnBack: TSpeedButton;
    Image10: TImage;
    ShadowEffect2: TShadowEffect;
    Rectangle8: TRectangle;
    ShadowEffect1: TShadowEffect;
    Image6: TImage;
    ImgPlay: TImage;

    function  OnActivityResult(RequestCode, ResultCode: Integer; Data: JIntent): Boolean;
    procedure HandleActivityMessage(const Sender: TObject; const M: TMessage);
    Procedure Rec;
    Procedure GetVideoThumbnail(Img: TBitmap; lPatch: string);

    procedure Switch1Switch(Sender: TObject);
    procedure SwitchCheck(Sender : TObject);
    procedure Circle1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure BtnNextClick(Sender: TObject);
    procedure BtnBackClick(Sender: TObject);


    function  CopyReverse(S: String; Index, Count : Integer) : String;
    function  ConvertBytes(Bytes: Int64): string;
    Procedure GetLocalfile(Param:string);
    procedure CardList(PatchFile, Date: string; ACallBack: TExecutaClickMobile = nil);
    Procedure ClickCard(Sender: TObject; const Point: TPointF);

  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmMain: TFrmMain;
  vPatchName,vFileName:string;

implementation

{$R *.fmx}

Procedure TFrmMain.ClickCard(Sender: TObject; const Point: TPointF);
Begin
MediaPlayer1.FileName:=TLayout(Sender).TagString;
TabControl1.GotoVisibleTab(2);
MediaPlayer1.Play;
End;

function TFrmMain.CopyReverse(S: String; Index, Count : Integer) : String;
begin
  Result := ReverseString(S);
  Result := Copy(Result, Index, Count);
  Result := ReverseString(Result);
end;

function TFrmMain.ConvertBytes(Bytes: Int64): string;
const
  Description: Array [0 .. 8] of string = ('Bytes', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB');
var
  i: Integer;
begin
  i := 0;

  while Bytes > Power(1024, i + 1) do
    Inc(i);

  Result := FormatFloat('###0.##', Bytes / IntPower(1024, i)) + ' ' + Description[i];
end;


procedure TFrmMain.GetLocalfile(Param: string);
var
  MySearch: TSearchRec;
  FindResult: Integer;
  St: string;
  FAge: Integer;
  FileParam:TDateTime;
begin

  TThread.CreateAnonymousThread(
  procedure
  begin

    St := System.IOUtils.TPath.GetSharedDocumentsPath;
    FindResult := FindFirst(St + '/*.*', faAnyFile, MySearch);

    while FindNext(MySearch) = 0 do
    begin

      if (MySearch.Attr <> faDirectory) and (MySearch.Name <> '.') and (MySearch.Name <> '..') then
      Begin

         if Param = '*' then
         Begin

           if CopyReverse(UpperCase(MySearch.Name), 1, 3) = 'MP4' then  // CARREGA TODOS OS ARQUIVOS MP4 DE GetSharedDocumentsPath
           Begin
           TabControl1.ActiveTab:=Lista;

           FAge:=FileAge(St+'/'+MySearch.Name);
           FileParam:=FileDateToDateTime(FAge);

           CardList(St+'/'+MySearch.Name,
                    DateToStr(FileParam)+' '
                    +TimeToStr(MySearch.TimeStamp)
                    +' - Size file: '
                    +ConvertBytes(MySearch.Size),
                    ClickCard);
           End;

         End
         else if Param = 'S' then
         Begin

           if (UpperCase(MySearch.Name)) = vFileName+'.MP4' then
           Begin
           FAge:=FileAge(St+'/'+MySearch.Name);
           FileParam:=FileDateToDateTime(FAge);

           CardList(St+'/'+MySearch.Name,DateToStr(FileParam)+' '
                    +TimeToStr(MySearch.TimeStamp)
                    +' - Size file: '
                    +ConvertBytes(MySearch.Size),
                    ClickCard);
           Abort;
           End;

         End;

      End;

    end;

  end).Start;

end;


procedure TFrmMain.CardList(PatchFile, Date: string; ACallBack: TExecutaClickMobile = nil);
var
iLayout1: TLayout;
iRect,iRect2 : TRectangle;
iText1, iText2: TText;
iLine : TLine;
iImg1  :Timage;
Begin

  iLayout1 := TLayout.Create(VertScrollBox1);
  with iLayout1 do
  begin
    Align       := TAlignLayout.Bottom;
    Size.Width  := 367;
    Size.Height := 270;
    Position.Y  := VertScrollBox1.Content.ChildrenCount * 2000;
  end;

  iRect := TRectangle.Create(iLayout1);
  with iRect do
  begin
    Align                := TAlignLayout.Top;
    HitTest              := true;
    Margins.Top          := 15;
    Margins.Left         := 20;
    Margins.Right        := 20;
    Margins.Bottom       := 20;
    Size.Height          := 240;
    TagString            := PatchFile;
    Fill.Kind            := TBrushKind.Bitmap;
    Stroke.Kind          := TBrushKind.None;
    Fill.Bitmap.WrapMode := TWrapMode.TileStretch;
    XRadius              := 10;
    YRadius              := 10;
    OnTap                := ACallBack;
   // Corners              := [TCorner.TopLeft, TCorner.TopRight,TCorner.BottomLeft,TCorner.BottomRight];
    Parent               := iLayout1;
  end;

  GetVideoThumbnail(iRect.Fill.Bitmap.Bitmap,PatchFile);

  iImg1 := TImage.create(iRect);
  with iImg1 do
  begin
    Align          := TAlignLayout.Center;
    HitTest        := false;
    MultiResBitmap.Height := 64;
    MultiResBitmap.Width := 64;
    Size.Width     := 65;
    Size.Height    := 65;
    bitmap         := ImgPlay.Bitmap;
    WrapMode:= TImageWrapMode.Place;
    Parent         := iRect;
  end;

  iRect2 := TRectangle.Create(iRect);
  with iRect2 do
  begin
    Align      := TAlignLayout.Bottom;
    Size.Height:= 50;
    Fill.Color := $96151515;
    Stroke.Kind:= TBrushKind.None;
    XRadius    := 10;
    YRadius    := 10;
    Parent     := iRect;
    Corners    := [TCorner.BottomLeft, TCorner.BottomRight];
  end;

  iText1:= TText.Create(iRect2);
  with iText1 do
  begin
    Align := TAlignLayout.Client;
    HitTest                 := false;
    AutoSize                := true;
    Size.Width              := 327;
    Size.Height             := 19;
    Margins.Top             := 8;
    Margins.Left            := 10;
    Margins.Right           := 10;
    Text                    := PatchFile;
    TextSettings.Font.Family:= 'Roboto';
    TextSettings.Font.Size  := 12;
    TextSettings.FontColor  := $FFFEFEFE;
    TextSettings.VertAlign  := TTextAlign.Center;
    TextSettings.HorzAlign  := TTextAlign.Leading;
    Parent                  := iRect2;
  end;

  iText2:= TText.Create(iRect2);
  with iText2 do
  begin
    Align := TAlignLayout.Bottom;
    HitTest                 := false;
    Size.Height             := 23;
    Margins.Left            := 10;
    Margins.Right           := 10;
    Margins.Bottom          := 3;
    Text                    := Date;
    TextSettings.Font.Family:= 'Roboto';
    TextSettings.Font.Size  := 11;
    TextSettings.FontColor  := $FFD4D4D4;
    TextSettings.HorzAlign  := TTextAlign.Leading;
    Parent                  := iRect2;
  end;

  iLine := TLine.Create(iLayout1);
  with iLine do
  begin
      Align        := TAlignLayout.MostBottom;
      LineType     := TLineType.Bottom;
      Size.Height  := 2;
      Stroke.Color := $FFD6D6D6;
      Parent       := iLayout1;
  end;


  TThread.Synchronize(TThread.CurrentThread,
  procedure
  begin
   iLayout1.Align := TAlignLayout.Top;
   iLayout1.Parent:=VertScrollBox1;
  end);

End;


procedure TFrmMain.Circle1Click(Sender: TObject);
begin
Rec;
end;

procedure TFrmMain.FormShow(Sender: TObject);
begin
  GetLocalfile('*');
end;

procedure TFrmMain.BtnBackClick(Sender: TObject);
begin
MediaPlayer1.Stop;
MediaPlayer1.Clear;
TabControl1.GotoVisibleTab(1);
end;

procedure TFrmMain.BtnNextClick(Sender: TObject);
begin

 if (Switch1.IsChecked) and
    (Switch2.IsChecked) and
    (Switch3.IsChecked) and
    (Switch4.IsChecked) then
     Begin
      TabControl1.GotoVisibleTab(1);
      Rec;
     End
     else
     begin
       ShowMessage('Habilite todas as permissões!!');
     end;
end;

procedure TFrmMain.Switch1Switch(Sender: TObject);
begin
 SwitchCheck(Sender);
end;

Procedure TFrmMain.SwitchCheck(Sender : TObject);
Begin

  if (TSwitch(Sender).IsChecked = true) and (TSwitch(Sender).Name = 'Switch1') then
  Begin
    PermissionsService.RequestPermissions
      ([JStringToString(TJManifest_permission.JavaClass.RECORD_AUDIO)], nil);
      Exit;
  End;

  if (TSwitch(Sender).IsChecked = true) and (TSwitch(Sender).Name = 'Switch2') then
  Begin
    PermissionsService.RequestPermissions
      ([JStringToString(TJManifest_permission.JavaClass.CAMERA)], nil);
      Exit;
  End;

  if (TSwitch(Sender).IsChecked = true) and (TSwitch(Sender).Name = 'Switch3') then
  Begin
    PermissionsService.RequestPermissions
      ([JStringToString(TJManifest_permission.JavaClass.
      READ_EXTERNAL_STORAGE)], nil);
      Exit;
  End;

  if (TSwitch(Sender).IsChecked = true) and (TSwitch(Sender).Name = 'Switch4') then
  Begin
    PermissionsService.RequestPermissions
      ([JStringToString(TJManifest_permission.JavaClass.
      WRITE_EXTERNAL_STORAGE)], nil);
     Exit;
  End;

End;

Procedure TFrmMain.Rec; //IMPORTANTE
var
  VideoIntent: JIntent;
  VideoUri   : Jnet_Uri;
  AFile      : JFile;
  FileName   : TFileName;
  LAuthority : JString;
begin

  TMessageManager.DefaultManager.SubscribeToMessage(TMessageResultNotification, HandleActivityMessage);//responsavel por receber um retorno
  VideoIntent := TJIntent.JavaClass.init(TJMediaStore.JavaClass.ACTION_VIDEO_CAPTURE);
  LAuthority := StringToJString(JStringToString(TAndroidHelper.Context.getApplicationContext.getPackageName) + '.fileprovider');
  vFileName   :=formatdatetime('dd-mm-yyyy_hh.mm.ss', now);

 if (VideoIntent.resolveActivity(TAndroidHelper.Context.getPackageManager()) <> nil) then
  begin
    FileName   := System.IOUtils.TPath.Combine(System.IOUtils.TPath.GetSharedDocumentsPath, vFileName+'.mp4');
    vPatchName := FileName;
    AFile      := TJFile.JavaClass.init(StringToJString(FileName));
    VideoUri   := TJFileProvider.JavaClass.getUriForFile(TAndroidHelper.Context, LAuthority, TJFile.JavaClass.init(StringToJString(FileName)));
    VideoIntent.addFlags(TJIntent.JavaClass.FLAG_GRANT_READ_URI_PERMISSION);
    VideoIntent.putExtra(TJMediaStore.JavaClass.EXTRA_OUTPUT,TJParcelable.Wrap((videoUri as ILocalObject).GetObjectID));
    TAndroidHelper.Activity.StartActivityForResult(VideoIntent, RECORD_VIDEO);
  end;

End;

procedure TFrmMain.HandleActivityMessage(const Sender: TObject; const M: TMessage); //IMPORTANTE
begin

  if M is TMessageResultNotification then
   begin
     OnActivityResult(TMessageResultNotification(M).RequestCode,
                      TMessageResultNotification(M).ResultCode,
                      TMessageResultNotification(M).Value);
   end;

end;

function TFrmMain.OnActivityResult(RequestCode, ResultCode: Integer; Data: JIntent): Boolean;  //IMPORTANTE
var
  FS: TFileStream;
begin
  Result := False;
  TMessageManager.DefaultManager.Unsubscribe(TMessageResultNotification, HandleActivityMessage);
  if RequestCode = RECORD_VIDEO then
  begin
    if ResultCode = TJActivity.JavaClass.RESULT_OK then
    begin

      TThread.Queue(nil,
        procedure
        begin
          if (TFile.Exists(vPatchName)) then
          begin
            try
              FS := TFileStream.Create(vPatchName, fmShareDenyNone);
            finally
              FS.Free;
              TabControl1.ActiveTab:=Lista;
              GetLocalfile('S');
            end;
          end;
          Invalidate;
        end);
    end;
  end;
end;

Procedure TFrmMain.GetVideoThumbnail(Img: TBitmap; lPatch: string);  //IMPORTANTE

function LoadBitmapFromJBitmap(const ABitmap: TBitmap; const AJBitmap: JBitmap): Boolean;
  var
    LSurface: TBitmapSurface;
  begin
    LSurface := TBitmapSurface.Create;
    try
      Result := JBitmapToSurface(AJBitmap, LSurface);
      if Result then
        ABitmap.Assign(LSurface);
    finally
      LSurface.Free;
    end;
    //https://stackoverflow.com/questions/61564514/how-can-i-retrieve-the-thumbnails-of-a-video-from-an-android-device-in-a-delphi
  end;

var
  LBitmap: JBitmap;
begin
  LBitmap := TJThumbnailUtils.JavaClass.createVideoThumbnail(StringToJString(lPatch),
  TJImages_Thumbnails.JavaClass.MINI_KIND); // MICRO_KIND 96 x 96 // MINI_KIND 512 x 384. FULL_SCREEN_KIND tamanho original
  LoadBitmapFromJBitmap(Img, LBitmap);
End;

end.
