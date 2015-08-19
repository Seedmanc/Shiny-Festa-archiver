unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, DialogsX, StrUtils,    ComCtrls, filectrl, math,
  XPMan,shlobj,shellapi, Menus;

type
  TForm1 = class(TForm)
    openBtn: TButton;
    FileOpenDialog1: TFileOpenDialog;
    TreeView1: TTreeView;
    ListView1: TListView;
    Button1: TButton;
    pathEdit: TEdit;
    checkallBox: TCheckBox;
    StatusBar1: TStatusBar;
    XPManifest1: TXPManifest;
    Panel1: TPanel;
    Panel2: TPanel;
    Splitter1: TSplitter;
    repBtn: TButton;
    wriBtn: TButton;
    PopupMenu1: TPopupMenu;
    About1: TMenuItem;
    CheckBox1: TCheckBox;
    procedure openfile(fname:string);
    procedure openBtnClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure checkallBoxClick(Sender: TObject);
    procedure TreeView1Click(Sender: TObject);
    procedure showcontents(offset:cardinal);
    procedure checkIncluded();
    procedure ListView1ColumnClick(Sender: TObject; Column: TListColumn);
    procedure ListView1Compare(Sender: TObject; Item1, Item2: TListItem;
      Data: Integer; var Compare: Integer);
    procedure repBtnClick(Sender: TObject);
    procedure wriBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure recalculate();
    procedure ListView1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    function  selectdir2(out dir:string):boolean ;
    procedure About1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  Stream1: TFileStream;
  Buf: Cardinal;
  count: word;
  filename:string;
  filenameR:string;
  block:byte=sizeof(buf);
  x:integer;
  order:boolean;
  replaced:boolean=false;
  sortallowed:boolean=true;
  names:boolean;
  n:byte;
  filenamers:tstringlist;
implementation

uses Unit2;

{$R *.dfm}

function GetFileSize3(const FileName: string): Int64;
var
  fad: TWin32FileAttributeData;
begin
  if not GetFileAttributesEx(PChar(FileName), GetFileExInfoStandard, @fad) then begin
    Raise Exception.CreateFmt('Can not read filesize, possibly unaccessible file',[]);
    exit;
  end;
  Int64Rec(Result).Lo := fad.nFileSizeLow;
  Int64Rec(Result).Hi := fad.nFileSizeHigh;
end;

function C2S(N: Cardinal): String;
begin
  SetLength(Result,SizeOf(Cardinal));
  Result[4] := Chr(N shr 24);
  Result[3] := Chr((N shr 16) and $ff);
  Result[2] := Chr((N shr 8) and $ff);
  Result[1] := Chr(N and $ff);
end;

function checkheader(offset:cardinal):boolean;
begin
  Stream1.Seek(offset+4,soFromBeginning);
  stream1.Read(buf,block);
  result:= (buf=1065353216);      // 80 3F
end;

function StripNonAlpha(str: string): string;
var
  i:byte;
begin
result:='';
  for i:=0 to length(str) do
    if str[i] in ['A'..'Z'] then
      result := result+str[i];

end;

procedure tform1.showcontents(offset:cardinal);
var curCount:word; i:word; s:array[0..31] of char; str:string;  j,k:byte; fnd:boolean ;
begin
  listview1.Items.Clear;
  stream1.Seek(offset+8,soFromBeginning);
  Stream1.Read(Buf,block);
  curcount:=buf;
  Stream1.Read(Buf,block);
  names:=(buf=8);
  StatusBar1.Panels[0].Text:=' Found '+inttostr(curcount)+' files, ';
  listview1.items.BeginUpdate;
    for i:=0 to curcount-1 do begin
      Stream1.Seek(offset+ 4*block+2*curcount*block+i*block*8,soFromBeginning);
      stream1.Read(s,32);
      fnd:=false; k:=0;
     with ListView1.Items.Add do begin
       for j:=0 to listview1.items.count-1 do
        if (s=listview1.items[j].Caption) then begin
          fnd:=true;
          k:=k+1;
        end;
       Caption:=s;
       if fnd then
        caption:=changefileext(caption,'')+' ('+inttostr(k)+')'+extractfileext(caption);
       Stream1.Seek(offset+ 4*block+i*block*2,soFromBeginning);
       stream1.Read(buf,block);
       SubItems.Add(IntToStr(buf));
       Stream1.Seek(offset+ 4*block+i*block*2+block,soFromBeginning);
       stream1.Read(buf,block);
       SubItems.Add(IntToStr(buf ));
       subitems.add('');
     end;

    end;
  if not(names) then begin
    StatusBar1.Panels[0].Text:=StatusBar1.Panels[0].Text+'NO filenames.';
    for i:=0 to curcount-1 do begin
      Stream1.Seek(offset+ strtoint(listview1.Items.Item[i].SubItems[0]),soFromBeginning);
      stream1.Read(buf,block);
      str:=c2s(buf);
      str:=StripNonAlpha(str);
      if str='MIG' then str:='GIM'
        else if str='' then str:='0'
        else if str='PSP' then
         if checkheader(offset+ strtoint(listview1.Items.Item[i].SubItems[0])) then
          str:='BIN';

      listview1.Items.Item[i].caption:='('+ChangeFileExt(ExtractFileName(filename),'')+') '+Format('%.3d', [i])+'.'+str;
    end;
  end
  else StatusBar1.Panels[0].Text:=StatusBar1.Panels[0].Text+'with filenames.';
  listview1.Items.EndUpdate;
  form1.Width:=form1.width+1;
 // filenamers.Capacity:=listview1.Items.Count;
  filenamers.Clear;
  for i:=0 to curcount-1 do begin
    filenamers.Add('');
    str:=ExtractFileExt(listview1.Items.Item[i].Caption);
    str:=StripNonAlpha(uppercase(str));
    if str='' then str:='?';
     listview1.Items.Item[i].SubItems[2]:=str;

  end;
  form1.Width:=form1.width-1;


end;

procedure tform1.checkIncluded();
var i:word;      s:string;  c:cardinal;   node:ttreenode; found:boolean;
begin
  found:=false;
  for i:=0 to listview1.Items.Count-1 do
    if  AnsiContainsStr(uppercase(listview1.Items.Item[i].Caption),'.BIN')  then begin
      s:=ChangeFileExt(ExtractFileName(listview1.Items.Item[i].Caption),'');
      c:=cardinal(treeview1.Selections[0].data)+strtoint(listview1.Items.Item[i].SubItems[0]);
      node:=treeview1.Selections[0].getFirstChild;
      while (node<>nil) do begin
        found:=found OR (cardinal(node.Data)=c);
        node:=node.getNextSibling;
      end;
      if not(found) then treeview1.Items.Addchild(treeview1.Selections[0],s).Data:=pointer(c);
    end;
   treeview1.FullExpand;
end;

procedure tform1.openfile(fname:string);
 var  it: TListItem;  s:string; tr:ttreenode;
begin
   try

    Stream1 := TFileStream.Create(fname,fmOpenRead);
    Stream1.Read(Buf,sizeof(buf));
    if (ansiLeftStr(c2s(buf),3)<>'PSP') then
      Raise Exception.CreateFmt('Invalid filetype.'+#10#13+'Expected header "PSP", got "%s" instead',[c2s(buf)])
    else if not(checkheader(0)) then
      Raise Exception.CreateFmt('Invalid filetype.'+#10#13+'"PSP" header is correct, but Hex "80 3F" not found.',[]);
    filename:=fname;
   //      fileopendialog1.Files[0]:=fname;
    replaced:=false;
    pathEdit.Text:=filename;
    treeview1.Items.Clear;
     treeview1.Items.Add(nil,ChangeFileExt(ExtractFileName(filename),''));
    Stream1.Seek(1*sizeof(buf),soFromCurrent);
    Stream1.Read(Buf,sizeof(buf));
    count:=word(buf);
     repbtn.Enabled:=true;
    showcontents(0);
    treeview1.Select(treeview1.items.Item[0]);
     checkIncluded();
    button1.Enabled:=true;
    checkallbox.Enabled:=true;
  finally

  stream1.Free();
 end;
end;

procedure TForm1.openBtnClick(Sender: TObject);

begin

fileopendialog1.FileTypes.Items[0].DisplayName:='PSP BIN archives';
fileopendialog1.FileTypes.Items[0].FileMask:='*.bin';
  fileopendialog1.Options:=[fdofilemustexist];

  if (fileopendialog1.execute) then

    openfile(fileopendialog1.files[0]);




end;

function tform1.selectdir2(out dir:string):boolean ;
var
  OpenDialog: TFileOpenDialog;
  SelectedFolder: string;
begin
OpenDialog := TFileOpenDialog.Create(application.MainForm);
try
  OpenDialog.Options := OpenDialog.Options + [fdoPickFolders];
  opendialog.DefaultFolder:=dir;
  selectdir2:=true;
  if not OpenDialog.Execute then begin
  result:=false;
    Abort;
  end;
  dir := OpenDialog.FileName;
  result:=true;
finally
  OpenDialog.Free;
end;
end;

function selectdir(out dir:string):boolean;
var
  BrowseInfo: TBrowseInfo;
    lpItemID : PItemIDList;
     TempPath : array[0..MAX_PATH] of char;
begin
  FillChar(BrowseInfo, SizeOf(BrowseInfo), 0);
  BrowseInfo.ulFlags := BIF_NEWDIALOGSTYLE;
  lpitemid:=SHBrowseForFolder(BrowseInfo);
  result:=(lpItemID<>nil)  ;
  if result then
   SHGetPathFromIDList( lpItemID , TempPath);
   dir:=temppath;
end;

procedure TForm1.Button1Click(Sender: TObject);
var it:tlistitem; dir:string; I,c:byte; suboffset:cardinal; checked:boolean;  stream22: TfileStream;
begin
  c:=0;
  checked:=false;
  for i:=0 to listview1.Items.Count-1 do
    checked:=checked OR listview1.Items.Item[i].Checked;
  if not(checked) then Raise Exception.CreateFmt('No files checked for extraction.',[]);
  dir:=ExtractFilePath(filename);
  if (selectdir2(dir)) then
  for i:=0 to listview1.Items.Count-1 do begin
  it:=listview1.Items.Item[i];
     if it.Checked then begin
       suboffset:=cardinal(treeview1.Selections[0].Data);
  {      try stream1.Free(); except else end;
        try stream2.Free(); except else end;   }
       stream1 := TFileStream.Create(filename, fmOpenRead);
       Stream1.Seek(suboffset+strtoint(it.SubItems[0]),soFromBeginning);
      try
        stream22:= TFileStream.Create(dir+'\'+it.Caption, fmCreate);
        stream22.Seek(0,sofrombeginning);
        try

          stream22.CopyFrom(stream1, strtoint(it.SubItems[1]));
          c:=c+1;
      finally
      stream22.Free;
    end;
  finally
  stream1.Free;
 end;
end;
StatusBar1.Panels[0].Text:=' Extracted '+inttostr(c)+' file(s).';
end;
end;

procedure TForm1.checkallBoxClick(Sender: TObject);
var   i:byte;
begin
if listview1.Items.Count>0 then
  for i:=0 to ListView1.Items.Count-1  do ListView1.Items.Item[i].Checked:=checkallbox.Checked;
end;

procedure TForm1.TreeView1Click(Sender: TObject);
begin
treeview1.Items.BeginUpdate;
wribtn.Enabled:=false;
  fileopendialog1.Options:=[fdofilemustexist];
 replaced:=false;
if treeview1.Items.Count>0 then begin
filenamers.clear;
filenamers.Capacity:=0;
sortallowed:=true;
  button1.Enabled:=true;
  checkallbox.Enabled:=true;
//repbtn.enabled:=(treeview1.Selections[0].AbsoluteIndex=0 );
       stream1 := TFileStream.Create(filename, fmOpenRead);
  showcontents( cardinal(treeview1.Selections[0].Data));
   checkIncluded();
  stream1.Free;
  end;
treeview1.Items.EndUpdate;
end;



procedure TForm1.ListView1ColumnClick(Sender: TObject;
  Column: TListColumn);
begin
 if sortallowed then begin
  x:=column.Index ;
  order:=not(order);
  (Sender as TCustomListView).AlphaSort;
  listview1.Refresh;
 end
  else showmessage('Sorting is not allowed during replacement.');
end;

procedure TForm1.ListView1Compare(Sender: TObject; Item1, Item2: TListItem;
  Data: Integer; var Compare: Integer );
var
 ix: Integer;
 begin
 if (x = 0) OR (x=3) then
 Compare := CompareText(Item1.Caption,Item2.Caption)
 else begin
 ix := x - 1;
 Compare := StrToInt(Item1.SubItems[ix]) - StrToInt(Item2.SubItems[ix])
end;
if not(order) then compare:=-compare;
end;


procedure TForm1.repBtnClick(Sender: TObject);
var it:tlistitem; i,j,c:byte; found:boolean; size,oldsize:cardinal;
begin
  order:=true;
  x:=1;
  listview1.AlphaSort;
  listview1.Refresh;
  sortallowed:=false;
  found:=false;
  fileopendialog1.Options:=[fdofilemustexist,fdoallowmultiselect];
 // filenamers.Capacity:=listview1.Items.Count;
  fileopendialog1.FileTypes.Items[0].displayname:='Existing files';
  fileopendialog1.FileTypes.Items[0].FileMask:='*'+ExtractFileExt(listview1.Items[0].Caption);
  for i:=0 to listview1.Items.count-1 do begin
    if not(AnsiContainsStr(fileopendialog1.FileTypes.Items[0].FileMask,ExtractFileExt(listview1.Items[i].Caption))) then
      fileopendialog1.FileTypes.Items[0].FileMask:=fileopendialog1.FileTypes.Items[0].FileMask+';*'+ExtractFileExt(listview1.Items[i].Caption);
  end;
  if (fileopendialog1.execute) then begin
  listview1.ClearSelection;
  //  filenamer:=fileopendialog1.Files[0];
    for i:=0 to listview1.Items.Count-1 do begin
      it:=listview1.Items[i];
      for j:=0 to fileopendialog1.Files.Count-1 do begin
       if (ansireplacestr(it.caption,'   ','')=ansireplacestr(ExtractFileName(fileopendialog1.Files[j]),'_new','')) then begin
        listview1.Items[i].Selected:=true;
        listview1.Items[i].Checked:=true;
        listview1.Items[i].Caption:='   '+ ansireplacestr(listview1.Items[i].caption ,'   ','');
        filenamers.strings[i]:=fileopendialog1.Files[j];
        found:=true;
        c:=c+1;
        break;
       end
       else if not(leftstr(it.caption,3)='   ') then filenamers.strings[i]:=filename;
      end;
    end;
    replaced:=found;
    if not(found) then Raise Exception.CreateFmt('No matching filename(s) found.',[]);
 //   showmessage(filenamers.Text);
    button1.Enabled:=false;
    checkallbox.Enabled:=false;
    listview1.SetFocus;
 //   it:=listview1.items[n];
//    it.Focused:=true;  it.checked:=true;
//    it.Caption:='   '+it.caption;
    recalculate();
    statusbar1.Panels[0].Text:=' Matched '+inttostr(c)+' file(s) out of '+inttostr(fileopendialog1.Files.Count)+' opened.';
    wribtn.Enabled:=true;
  end;
  if checkbox1.Checked then wriBtnClick(wribtn);
end;

procedure tform1.recalculate();
var i,j:byte;  it:tlistitem; size,oldsize,offset,k,l:cardinal;
begin
  for i:=0 to listview1.Items.count-1 do begin
    it:=listview1.Items.Item[i];
    if (filenamers.Strings[i]<>filename) then
     if it.checked then begin
      size:=getfilesize3(filenamers.Strings[i]);
      oldsize:=strtoint(it.SubItems[1]);
      it.SubItems[1]:=inttostr(size);
      size:=ceil(size/32)*32;
      oldsize:=ceil(oldsize/32)*32;
      for j:=i+1 to listview1.Items.Count-1 do
        listview1.Items[j].SubItems[0]:=inttostr(strtoint(listview1.Items[j].SubItems[0])+integer(size-oldsize));
     end
     else begin
      offset:=cardinal(treeview1.Selections[0].Data);
      stream1 := TFileStream.Create(filename,fmOpenRead);
      stream1.Seek(16+i*2*block+4+offset,sofrombeginning);
      stream1.Read(size,block);
      oldsize:=strtoint(it.SubItems[1]);
      it.SubItems[1]:=inttostr(size);
      size:=ceil(size/32)*32;
      oldsize:=ceil(oldsize/32)*32;
      for j:=i+1 to listview1.Items.Count-1 do
        listview1.Items[j].SubItems[0]:=inttostr(strtoint(listview1.Items[j].SubItems[0])+integer(size-oldsize));
      stream1.Free;
     end;
  end;
  offset:=cardinal(treeview1.Selections[0].Data);
  size:=strtoint(listview1.Items[listview1.Items.count-1].SubItems[0])+strtoint(listview1.Items[listview1.Items.count-1].SubItems[1]);
  size:=ceil(size/32)*32;
  stream1 := TFileStream.Create(filename,fmOpenRead);
  stream1.seek(offset+16+8*(listview1.Items.count-1),sofrombeginning);
  stream1.Read(k,4);
  stream1.read(l,4);
  oldsize:=k+l;
  oldsize:=ceil(oldsize/32)*32;
  statusbar1.Panels[0].Text:=' Resulting size='+inttostr(size)+', difference='+inttostr(integer(size-oldsize) )+'.';
  stream1.free;
end;


procedure TForm1.wriBtnClick(Sender: TObject);
var stream2:tfilestream;     filename3:string;  i,offset:cardinal; s: byte; c,j:integer;
var stream3:tfilestream;
begin
 try
  offset:=cardinal(treeview1.Selections[0].data);
  Stream1:=TFileStream.Create(filename,fmOpenRead);
//
  filename3:=extractfilepath(filename)+treeview1.selections[0].Text+'_new'+ExtractFileExt(filename);
  stream3:=TFileStream.Create(filename3,fmCreate);
  stream1.Seek(0+offset,soFrombeginning);
  stream3.CopyFrom(stream1, 4*block);
  for i:=0 to listview1.Items.Count-1 do begin
    buf:=strtoint(listview1.Items[i].SubItems[0]);
    stream3.WriteBuffer(buf,block);
    buf:=strtoint(listview1.Items[i].SubItems[1]);
    stream3.WriteBuffer(buf,block);
  end;
  stream1.Seek((listview1.Items.Count)*block*2+16+offset,soFromBeginning);
  i:=strtoint(listview1.Items[0].subitems[0])+offset-stream1.position;
  stream3.CopyFrom(stream1, i);
  stream1.Free;
  for c:=0 to listview1.items.count-1 do begin
    filenamer:=filenamers.Strings[c];
    if not(listview1.Items[c].Checked) then filenamer:=filename;
    Stream2:=TFileStream.Create(filenamer,fmOpenRead);
    i:=strtoint(listview1.Items[c].SubItems[1]);
    if filenamer=filename then begin
      stream2.seek(offset+16+c*8,sofrombeginning);
      stream2.Read(j,4);                                   //derp
      stream2.seek(offset+j,sofrombeginning);
    end;
    stream3.CopyFrom(stream2,i);
    if c=listview1.items.count-1 then
      if true then begin                        //derp
        i:=strtoint(listview1.Items[c].SubItems[1])+strtoint(listview1.Items[c].SubItems[0]);
        i:=ceil(i/32)*32-i;
      end
      else i:=0
    else
      i:=strtoint(listview1.Items[c+1].SubItems[0])-strtoint(listview1.Items[c].SubItems[1])-strtoint(listview1.Items[c].SubItems[0]);
    s:=0;
    for j:=0 to integer(i-1) do
      stream3.WriteBuffer(s,1);
    stream2.free;
  end;

  statusbar1.Panels[0].Text:=' Saved to '+extractfilename(filename3);
 finally
  stream3.free;
//try  stream2.free;  except else end;
//try   stream1.free;   except else end;
  
 end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
   filenamers:=TStringList.Create;
    if paramcount()>0 then begin
     if extractfileext(paramstr(1))='.bin' then begin
     openfile(paramstr(1));
     end
     else
     Raise Exception.CreateFmt('Invalid extension, only .bin files are accepted.',[]);
  end;

end;

procedure TForm1.ListView1Click(Sender: TObject);
var sel:boolean; i:integer;  it:tlistitem;
begin
if  replaced then begin
  wribtn.Enabled:=false;
  for i:=0 to listview1.Items.count-1 do begin
    it:=listview1.items[i];
    if it.Checked and (ansileftstr(it.caption,3)='   ') then wribtn.Enabled:=true;
  end;
end;
if  (replaced) then

  recalculate;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  filenamers.Free;
end;

procedure TForm1.About1Click(Sender: TObject);
begin
about.showmodal;
end;

end.
