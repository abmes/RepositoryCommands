object fmConfig: TfmConfig
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Configuration'
  ClientHeight = 533
  ClientWidth = 546
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object pnlOkCancelButtons: TPanel
    Left = 0
    Top = 497
    Width = 546
    Height = 36
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    DesignSize = (
      546
      36)
    object btnCancel: TBitBtn
      Left = 456
      Top = 4
      Width = 83
      Height = 25
      Anchors = [akTop, akRight]
      Kind = bkCancel
      NumGlyphs = 2
      TabOrder = 0
    end
    object btnOk: TBitBtn
      Left = 368
      Top = 4
      Width = 83
      Height = 25
      Anchors = [akTop, akRight]
      Kind = bkOK
      NumGlyphs = 2
      TabOrder = 1
    end
  end
  object gbTortoiseSVNProcFileName: TGroupBox
    Left = 8
    Top = 8
    Width = 529
    Height = 57
    Caption = ' TortoiseSVNProc Executable '
    TabOrder = 1
    DesignSize = (
      529
      57)
    object fneTortoiseSVNProcFileName: TJvFilenameEdit
      Left = 16
      Top = 24
      Width = 497
      Height = 21
      Filter = 'Executable|*.exe'
      DialogOptions = [ofHideReadOnly, ofFileMustExist]
      DirectInput = False
      Anchors = [akLeft, akTop, akRight]
      TabOrder = 0
    end
  end
  object gbProjects: TGroupBox
    Left = 8
    Top = 72
    Width = 529
    Height = 233
    Caption = ' Projects '
    TabOrder = 2
    object btnMoveProjectUp: TSpeedButton
      Left = 500
      Top = 103
      Width = 25
      Height = 25
      Action = actMoveProjectUp
    end
    object btnMoveProjectDown: TSpeedButton
      Left = 500
      Top = 127
      Width = 25
      Height = 25
      Action = actMoveProjectDown
    end
    object grdProjects: TSembaDBGrid
      Left = 16
      Top = 48
      Width = 481
      Height = 171
      DataGrouping.GroupLevels = <>
      DataSource = dsProjects
      Flat = False
      FooterColor = clWindow
      FooterFont.Charset = DEFAULT_CHARSET
      FooterFont.Color = clWindowText
      FooterFont.Height = -11
      FooterFont.Name = 'Tahoma'
      FooterFont.Style = []
      IndicatorOptions = [gioShowRowIndicatorEh]
      Options = [dgTitles, dgIndicator, dgColLines, dgRowLines, dgTabs, dgConfirmDelete, dgCancelOnExit]
      OptionsEh = [dghFixed3D, dghHighlightFocus, dghClearSelection, dghDialogFind, dghExtendVertLines]
      TabOrder = 0
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -11
      TitleFont.Name = 'Tahoma'
      TitleFont.Style = []
      UseMultiTitle = True
      Columns = <
        item
          EditButtons = <>
          FieldName = 'PROJECT_NAME'
          Footers = <>
          Title.Caption = 'Project Name'
          Width = 146
        end
        item
          EditButtons = <>
          FieldName = 'PROJECT_DIR'
          Footers = <>
          Title.Caption = 'Project Dir'
          Width = 249
        end
        item
          Checkboxes = True
          EditButtons = <>
          FieldName = 'IS_FAVORITE'
          Footers = <>
          Title.Caption = 'Favorite'
          Width = 51
        end>
      object RowDetailData: TRowDetailPanelControlEh
      end
    end
    object navProjects: TDBColorNavigator
      Left = 16
      Top = 22
      Width = 56
      Height = 25
      DataSource = dsProjects
      VisibleButtons = [nbInsert, nbDelete]
      Kind = dbnHorizontal
      TabOrder = 1
      BeforeAction = navProjectsBeforeAction
    end
  end
  object gbSVNCommands: TGroupBox
    Left = 8
    Top = 312
    Width = 529
    Height = 177
    Caption = ' SVN Commands '
    TabOrder = 3
    object btnMoveCommandDown: TSpeedButton
      Left = 500
      Top = 111
      Width = 25
      Height = 25
      Action = actMoveCommandDown
    end
    object btnMoveCommandUp: TSpeedButton
      Left = 500
      Top = 87
      Width = 25
      Height = 25
      Action = actMoveCommandUp
    end
    object lblMacroHint: TLabel
      Left = 352
      Top = 32
      Width = 146
      Height = 13
      Caption = 'Possible Macro: %ProjectDir%'
    end
    object grdSVNCommands: TSembaDBGrid
      Left = 16
      Top = 48
      Width = 481
      Height = 117
      DataGrouping.GroupLevels = <>
      DataSource = dsSVNCommands
      Flat = False
      FooterColor = clWindow
      FooterFont.Charset = DEFAULT_CHARSET
      FooterFont.Color = clWindowText
      FooterFont.Height = -11
      FooterFont.Name = 'Tahoma'
      FooterFont.Style = []
      IndicatorOptions = [gioShowRowIndicatorEh]
      Options = [dgEditing, dgTitles, dgIndicator, dgColLines, dgRowLines, dgTabs, dgConfirmDelete, dgCancelOnExit]
      OptionsEh = [dghFixed3D, dghHighlightFocus, dghClearSelection, dghDialogFind, dghExtendVertLines]
      TabOrder = 0
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -11
      TitleFont.Name = 'Tahoma'
      TitleFont.Style = []
      UseMultiTitle = True
      Columns = <
        item
          EditButtons = <>
          FieldName = 'COMMAND_NAME'
          Footers = <>
          Title.Caption = 'Command Name'
          Width = 146
        end
        item
          EditButtons = <>
          FieldName = 'COMMAND_ARGUMENTS'
          Footers = <>
          Title.Caption = 'Arguments'
          Width = 249
        end
        item
          Checkboxes = True
          EditButtons = <>
          FieldName = 'IS_FAVORITE'
          Footers = <>
          Title.Caption = 'Favorite'
          Width = 51
        end>
      object RowDetailData: TRowDetailPanelControlEh
      end
    end
    object navSVNCommands: TDBColorNavigator
      Left = 16
      Top = 22
      Width = 56
      Height = 25
      DataSource = dsSVNCommands
      VisibleButtons = [nbInsert, nbDelete]
      Kind = dbnHorizontal
      TabOrder = 1
    end
  end
  object dsSVNCommands: TDataSource
    Left = 240
  end
  object dsProjects: TDataSource
    Left = 208
  end
  object alMain: TActionList
    Images = ilActions
    Left = 288
    object actAddProject: TAction
      Hint = 'Choose Project Dir'
      OnExecute = actAddProjectExecute
    end
    object actMoveProjectUp: TAction
      Hint = 'Move Up'
      ImageIndex = 1
      OnExecute = actMoveProjectUpExecute
    end
    object actMoveProjectDown: TAction
      Hint = 'Move Down'
      ImageIndex = 0
      OnExecute = actMoveProjectDownExecute
    end
    object actMoveCommandUp: TAction
      Hint = 'Move Up'
      ImageIndex = 1
      OnExecute = actMoveCommandUpExecute
    end
    object actMoveCommandDown: TAction
      Hint = 'Move Down'
      ImageIndex = 0
      OnExecute = actMoveCommandDownExecute
    end
  end
  object sdProjectDir: TJvSelectDirectory
    ClassicDialog = False
    Options = []
    Title = 'Project Dir'
    Left = 384
  end
  object ilActions: TImageList
    Left = 320
    Bitmap = {
      494C010102000800200010001000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000001000000001002000000000000010
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000007F5B0000CF98080000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000CF9808007F5B00007F5B00007F5B00007F5B0000CF9808000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000007F5B0000CF980800FFF3D500CF980800000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000007F5B0000F6CB9700F6CB9700F6CB9700FFF3D500CF9808000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000007F5B0000CF980800F6CB9700F6CB9700FFF3D500CF9808000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000007F5B0000F6CB9700F6CB9700F6CB9700FFF3D500CF9808000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00007F5B0000CF980800F6CB9700F6CB9700F6CB9700F6CB9700FFF3D500CF98
      0800000000000000000000000000000000000000000000000000000000000000
      0000000000007F5B0000F6CB9700F6CB9700F6CB9700FFF3D500CF9808000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000007F5B
      0000CF980800F6CB9700F6CB9700F6CB9700F6CB9700F6CB9700F6CB9700FFF3
      D500CF98080000000000000000000000000000000000CF9808007F5B00007F5B
      00007F5B00007F5B0000F6CB9700F6CB9700F6CB9700FFF3D5007F5B00007F5B
      00007F5B00007F5B00007F5B0000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000007F5B0000CF98
      0800F6CB9700F6CB9700F6CB9700F6CB9700F6CB9700F6CB9700F6CB9700F6CB
      9700FFF3D500CF9808000000000000000000000000007F5B0000CF980800F6CB
      9700F6CB9700F6CB9700F6CB9700F6CB9700F6CB9700FFF3D500FFF3D500FFF3
      D500FFF3D500FFF3D500CF980800000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000007F5B0000CF980800F6CB
      9700F6CB9700F6CB9700F6CB9700F6CB9700F6CB9700FFF3D500FFF3D500FFF3
      D500FFF3D500FFF3D500CF9808000000000000000000000000007F5B0000CF98
      0800F6CB9700F6CB9700F6CB9700F6CB9700F6CB9700F6CB9700F6CB9700F6CB
      9700FFF3D500CF98080000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000CF9808007F5B00007F5B
      00007F5B00007F5B0000F6CB9700F6CB9700F6CB9700FFF3D5007F5B00007F5B
      00007F5B00007F5B00007F5B0000000000000000000000000000000000007F5B
      0000CF980800F6CB9700F6CB9700F6CB9700F6CB9700F6CB9700F6CB9700FFF3
      D500CF9808000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000007F5B0000F6CB9700F6CB9700F6CB9700FFF3D500CF9808000000
      0000000000000000000000000000000000000000000000000000000000000000
      00007F5B0000CF980800F6CB9700F6CB9700F6CB9700F6CB9700FFF3D500CF98
      0800000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000007F5B0000F6CB9700F6CB9700F6CB9700FFF3D500CF9808000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000007F5B0000CF980800F6CB9700F6CB9700FFF3D500CF9808000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000007F5B0000F6CB9700F6CB9700F6CB9700FFF3D500CF9808000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000007F5B0000CF980800FFF3D500CF980800000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000CF9808007F5B00007F5B00007F5B00007F5B0000CF9808000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000007F5B0000CF98080000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000040000000100000000100010000000000800000000000000000000000
      000000000000000000000000FFFFFF00FFFFFFFF00000000FFFFFFFF00000000
      FE7FF81F00000000FC3FF81F00000000F81FF81F00000000F00FF81F00000000
      E007800100000000C0038001000000008001C003000000008001E00700000000
      F81FF00F00000000F81FF81F00000000F81FFC3F00000000F81FFE7F00000000
      FFFFFFFF00000000FFFFFFFF0000000000000000000000000000000000000000
      000000000000}
  end
end
