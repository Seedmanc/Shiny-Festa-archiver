object Form1: TForm1
  Left = 238
  Top = 161
  Width = 678
  Height = 365
  Caption = 'Shiny Festa patcher'
  Color = clBtnFace
  Constraints.MinHeight = 180
  Constraints.MinWidth = 625
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -10
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PopupMenu = PopupMenu1
  Position = poDefaultPosOnly
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 185
    Top = 0
    Height = 305
    ResizeStyle = rsUpdate
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 305
    Width = 662
    Height = 22
    Panels = <
      item
        Text = ' Ready'
        Width = 50
      end>
    SimpleText = 'Text'
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 185
    Height = 305
    Align = alLeft
    Caption = 'Panel1'
    Constraints.MinWidth = 75
    ParentBackground = False
    TabOrder = 1
    DesignSize = (
      185
      305)
    object openBtn: TButton
      Left = 7
      Top = 7
      Width = 171
      Height = 27
      Anchors = [akLeft, akTop, akRight]
      Caption = 'Open...'
      TabOrder = 0
      OnClick = openBtnClick
    end
    object Button1: TButton
      Left = 7
      Top = 273
      Width = 171
      Height = 27
      Anchors = [akLeft, akRight, akBottom]
      Caption = 'Extract...'
      Enabled = False
      TabOrder = 1
      OnClick = Button1Click
    end
    object TreeView1: TTreeView
      Left = 7
      Top = 39
      Width = 171
      Height = 230
      Anchors = [akLeft, akTop, akRight, akBottom]
      AutoExpand = True
      HideSelection = False
      Indent = 19
      ReadOnly = True
      ShowRoot = False
      TabOrder = 2
      OnClick = TreeView1Click
    end
  end
  object Panel2: TPanel
    Left = 188
    Top = 0
    Width = 474
    Height = 305
    Align = alClient
    Caption = 'Panel2'
    Constraints.MinWidth = 420
    ParentBackground = False
    TabOrder = 2
    DesignSize = (
      474
      305)
    object pathEdit: TEdit
      Left = 5
      Top = 9
      Width = 462
      Height = 24
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
      Color = clMenuBar
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ImeName = 'Russian'
      ParentFont = False
      ReadOnly = True
      TabOrder = 0
      Text = 'Filepath'
    end
    object ListView1: TListView
      Left = 5
      Top = 39
      Width = 462
      Height = 230
      Anchors = [akLeft, akTop, akRight, akBottom]
      Checkboxes = True
      Columns = <
        item
          AutoSize = True
          Caption = '      Filename'
        end
        item
          Alignment = taCenter
          Caption = 'Offset'
          Width = 76
        end
        item
          Alignment = taCenter
          Caption = 'Size'
          Width = 75
        end
        item
          Alignment = taRightJustify
          Caption = 'Type'
          Width = 45
        end>
      FlatScrollBars = True
      GridLines = True
      HideSelection = False
      MultiSelect = True
      ReadOnly = True
      RowSelect = True
      ShowWorkAreas = True
      TabOrder = 1
      ViewStyle = vsReport
      OnClick = ListView1Click
      OnColumnClick = ListView1ColumnClick
      OnCompare = ListView1Compare
    end
    object checkallBox: TCheckBox
      Left = 11
      Top = 46
      Width = 13
      Height = 13
      TabOrder = 2
      OnClick = checkallBoxClick
    end
    object repBtn: TButton
      Left = 5
      Top = 273
      Width = 171
      Height = 27
      Anchors = [akLeft, akBottom]
      Caption = 'Replace...'
      Enabled = False
      TabOrder = 3
      OnClick = repBtnClick
    end
    object wriBtn: TButton
      Left = 297
      Top = 273
      Width = 171
      Height = 27
      Anchors = [akRight, akBottom]
      Caption = 'Apply'
      Enabled = False
      TabOrder = 4
      OnClick = wriBtnClick
    end
    object CheckBox1: TCheckBox
      Left = 203
      Top = 278
      Width = 67
      Height = 17
      Anchors = [akBottom]
      Caption = 'Auto-apply'
      TabOrder = 5
    end
  end
  object FileOpenDialog1: TFileOpenDialog
    DefaultExtension = 'bin'
    FavoriteLinks = <>
    FileTypes = <
      item
        DisplayName = 'PSP BIN archives'
        FileMask = '*.bin;*.wsb'
      end
      item
        DisplayName = 'Any files'
        FileMask = '*.*'
      end>
    Options = [fdoFileMustExist]
    Left = 368
    Top = 8
  end
  object XPManifest1: TXPManifest
    Left = 280
    Top = 8
  end
  object PopupMenu1: TPopupMenu
    Alignment = paCenter
    Left = 468
    Top = 16
    object About1: TMenuItem
      Caption = 'About'
      Default = True
      ShortCut = 112
      OnClick = About1Click
    end
  end
end
