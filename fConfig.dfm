object fmConfig: TfmConfig
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Configuration'
  ClientHeight = 535
  ClientWidth = 746
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
    Top = 499
    Width = 746
    Height = 36
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 3
    DesignSize = (
      746
      36)
    object btnCancel: TBitBtn
      Left = 656
      Top = 4
      Width = 83
      Height = 25
      Anchors = [akTop, akRight]
      Kind = bkCancel
      NumGlyphs = 2
      TabOrder = 1
    end
    object btnOk: TBitBtn
      Left = 568
      Top = 4
      Width = 83
      Height = 25
      Anchors = [akTop, akRight]
      Kind = bkOK
      NumGlyphs = 2
      TabOrder = 0
    end
  end
  object gbTortoiseProcFileName: TGroupBox
    Left = 8
    Top = 8
    Width = 729
    Height = 57
    Caption = ' TortoiseProc Executable '
    TabOrder = 0
    object edtTortoiseProcFileName: TEdit
      Left = 16
      Top = 24
      Width = 681
      Height = 21
      ReadOnly = True
      TabOrder = 0
    end
    object tlbSelectTortoiseProc: TToolBar
      Left = 697
      Top = 23
      Width = 23
      Height = 22
      Align = alNone
      AutoSize = True
      Images = ilActions
      List = True
      TabOrder = 1
      object btnSelectTortoiseProc: TToolButton
        Left = 0
        Top = 0
        Action = actSelectTortoiseProc
      end
    end
  end
  object gbProjects: TGroupBox
    Left = 8
    Top = 80
    Width = 729
    Height = 225
    Caption = ' Projects '
    TabOrder = 1
    object btnMoveProjectUp: TSpeedButton
      Left = 700
      Top = 103
      Width = 25
      Height = 25
      Action = actMoveProjectUp
    end
    object btnMoveProjectDown: TSpeedButton
      Left = 700
      Top = 127
      Width = 25
      Height = 25
      Action = actMoveProjectDown
    end
    object btnIndent: TSpeedButton
      Left = 91
      Top = 22
      Width = 25
      Height = 25
      Hint = 'Indent'
      Glyph.Data = {
        76010000424D7601000000000000760000002800000020000000100000000100
        04000000000000010000130B0000130B00001000000000000000000000000000
        800000800000008080008000000080008000808000007F7F7F00BFBFBF000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00333333333333
        333333333333333333FF33333333333330003FF3FFFFF3333777003000003333
        300077F777773F333777E00BFBFB033333337773333F7F33333FE0BFBF000333
        330077F3337773F33377E0FBFBFBF033330077F3333FF7FFF377E0BFBF000000
        333377F3337777773F3FE0FBFBFBFBFB039977F33FFFFFFF7377E0BF00000000
        339977FF777777773377000BFB03333333337773FF733333333F333000333333
        3300333777333333337733333333333333003333333333333377333333333333
        333333333333333333FF33333333333330003333333333333777333333333333
        3000333333333333377733333333333333333333333333333333}
      NumGlyphs = 2
      ParentShowHint = False
      ShowHint = True
      OnClick = btnIndentClick
    end
    object navProjects: TDBColorNavigator
      Left = 16
      Top = 22
      Width = 75
      Height = 25
      DataSource = dsProjects
      VisibleButtons = [nbInsert, nbDelete, nbEdit]
      TabOrder = 0
      BeforeAction = navProjectsBeforeAction
    end
    object grdProjects: TDBGrid
      Left = 16
      Top = 48
      Width = 681
      Height = 165
      DataSource = dsProjects
      Options = [dgTitles, dgIndicator, dgColLines, dgRowLines, dgTabs, dgRowSelect, dgConfirmDelete, dgCancelOnExit]
      TabOrder = 1
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -11
      TitleFont.Name = 'Tahoma'
      TitleFont.Style = []
      OnDblClick = grdProjectsDblClick
      Columns = <
        item
          Expanded = False
          FieldName = 'PROJECT_NAME'
          Title.Alignment = taCenter
          Title.Caption = 'Project Name'
          Width = 186
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'PROJECT_DIR'
          Title.Alignment = taCenter
          Title.Caption = 'Project Dir'
          Width = 408
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'IS_FAVORITE'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Symbol'
          Font.Style = []
          Title.Alignment = taCenter
          Title.Caption = 'Favorite'
          Width = 51
          Visible = True
        end>
    end
  end
  object gbCommands: TGroupBox
    Left = 8
    Top = 320
    Width = 729
    Height = 171
    Caption = ' Commands '
    TabOrder = 2
    object btnMoveCommandDown: TSpeedButton
      Left = 700
      Top = 111
      Width = 25
      Height = 25
      Action = actMoveCommandDown
    end
    object btnMoveCommandUp: TSpeedButton
      Left = 700
      Top = 87
      Width = 25
      Height = 25
      Action = actMoveCommandUp
    end
    object lblMacroHint: TLabel
      Left = 552
      Top = 32
      Width = 146
      Height = 13
      Caption = 'Possible Macro: %ProjectDir%'
    end
    object navCommands: TDBColorNavigator
      Left = 16
      Top = 22
      Width = 56
      Height = 25
      DataSource = dsCommands
      VisibleButtons = [nbInsert, nbDelete]
      TabOrder = 0
    end
    object grdCommands: TDBGrid
      Left = 16
      Top = 48
      Width = 681
      Height = 111
      DataSource = dsCommands
      Options = [dgEditing, dgTitles, dgIndicator, dgColLines, dgRowLines, dgTabs, dgConfirmDelete, dgCancelOnExit]
      TabOrder = 1
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -11
      TitleFont.Name = 'Tahoma'
      TitleFont.Style = []
      OnCellClick = grdCommandsCellClick
      OnDblClick = grdCommandsDblClick
      Columns = <
        item
          Expanded = False
          FieldName = 'COMMAND_NAME'
          Title.Alignment = taCenter
          Title.Caption = 'Command Name'
          Width = 146
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'COMMAND_ARGUMENTS'
          Title.Alignment = taCenter
          Title.Caption = 'Arguments'
          Width = 448
          Visible = True
        end
        item
          Expanded = False
          FieldName = 'IS_FAVORITE'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Symbol'
          Font.Style = []
          Title.Alignment = taCenter
          Title.Caption = 'Favorite'
          Width = 51
          Visible = True
        end>
    end
  end
  object dsCommands: TDataSource
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
    object actSelectTortoiseProc: TAction
      ImageIndex = 2
      OnExecute = actSelectTortoiseProcExecute
    end
  end
  object ilActions: TImageList
    Left = 320
    Bitmap = {
      494C010103000500040010001000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
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
      00000000000000000000000000000000000000000000000000006E6E6E006E6E
      6E006E6E6E006E6E6E006E6E6E006E6E6E006E6E6E006E6E6E006E6E6E000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000007F5B0000CF980800FFF3D500CF980800000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000007F5B0000F6CB9700F6CB9700F6CB9700FFF3D500CF9808000000
      000000000000000000000000000000000000000000004CBABA004CBABA004CBA
      BA004CBABA004CBABA004CBABA004CBABA004CBABA004CBABA004CBABA004C4C
      4C00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000007F5B0000CF980800F6CB9700F6CB9700FFF3D500CF9808000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000007F5B0000F6CB9700F6CB9700F6CB9700FFF3D500CF9808000000
      000000000000000000000000000000000000000000004CBABA004CBABA00FFFF
      FF00BADDFF00BADDFF00BADDFF00BADDFF00BADDFF00BADDFF00BADDFF004CBA
      BA004C4C4C000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00007F5B0000CF980800F6CB9700F6CB9700F6CB9700F6CB9700FFF3D500CF98
      0800000000000000000000000000000000000000000000000000000000000000
      0000000000007F5B0000F6CB9700F6CB9700F6CB9700FFF3D500CF9808000000
      000000000000000000000000000000000000000000004CBABA00BAFFFF004CBA
      BA00FFFFFF00BAFFFF00BADDFF00BAFFFF00BAFFFF00BAFFFF00BADDFF00BADD
      FF004CBABA004C4C4C0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000007F5B
      0000CF980800F6CB9700F6CB9700F6CB9700F6CB9700F6CB9700F6CB9700FFF3
      D500CF98080000000000000000000000000000000000CF9808007F5B00007F5B
      00007F5B00007F5B0000F6CB9700F6CB9700F6CB9700FFF3D5007F5B00007F5B
      00007F5B00007F5B00007F5B000000000000000000004CBABA00BAFFFF00BADD
      FF004CBABA00FFFFFF00FFFFFF00BAFFFF00BAFFFF00FFFFFF00BAFFFF00FFFF
      FF00BAFFFF004CBABA004C4C4C00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000007F5B0000CF98
      0800F6CB9700F6CB9700F6CB9700F6CB9700F6CB9700F6CB9700F6CB9700F6CB
      9700FFF3D500CF9808000000000000000000000000007F5B0000CF980800F6CB
      9700F6CB9700F6CB9700F6CB9700F6CB9700F6CB9700FFF3D500FFF3D500FFF3
      D500FFF3D500FFF3D500CF98080000000000000000004CBABA00BAFFFF00BAFF
      FF00BADDFF004CBABA004CBABA004CBABA004CBABA004CBABA004CBABA004CBA
      BA004CBABA004CBABA004CBABA00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000007F5B0000CF980800F6CB
      9700F6CB9700F6CB9700F6CB9700F6CB9700F6CB9700FFF3D500FFF3D500FFF3
      D500FFF3D500FFF3D500CF9808000000000000000000000000007F5B0000CF98
      0800F6CB9700F6CB9700F6CB9700F6CB9700F6CB9700F6CB9700F6CB9700F6CB
      9700FFF3D500CF9808000000000000000000000000004CBABA00BAFFFF00BADD
      FF00BAFFFF00BADDFF00BAFFFF00BAFFFF00BADDFF00BAFFFF004CBABA004C4C
      4C00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000CF9808007F5B00007F5B
      00007F5B00007F5B0000F6CB9700F6CB9700F6CB9700FFF3D5007F5B00007F5B
      00007F5B00007F5B00007F5B0000000000000000000000000000000000007F5B
      0000CF980800F6CB9700F6CB9700F6CB9700F6CB9700F6CB9700F6CB9700FFF3
      D500CF980800000000000000000000000000000000004CBABA00BAFFFF00BAFF
      FF00BADDFF00BAFFFF00BADDFF00BAFFFF00BADDFF00BAFFFF004CBABA004C4C
      4C00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000007F5B0000F6CB9700F6CB9700F6CB9700FFF3D500CF9808000000
      0000000000000000000000000000000000000000000000000000000000000000
      00007F5B0000CF980800F6CB9700F6CB9700F6CB9700F6CB9700FFF3D500CF98
      080000000000000000000000000000000000000000004CBABA00BAFFFF00BAFF
      FF00BAFFFF004CBABA004CBABA004CBABA004CBABA004CBABA004CBABA000000
      0000BA4C4C00BA4C4C00BA4C4C00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000007F5B0000F6CB9700F6CB9700F6CB9700FFF3D500CF9808000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000007F5B0000CF980800F6CB9700F6CB9700FFF3D500CF9808000000
      00000000000000000000000000000000000000000000000000004CBABA004CBA
      BA004CBABA000000000000000000000000000000000000000000000000000000
      000000000000BA4C4C00BA4C4C00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000007F5B0000F6CB9700F6CB9700F6CB9700FFF3D500CF9808000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000007F5B0000CF980800FFF3D500CF980800000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000BA4C4C0000000000000000000000
      0000BA4C4C0000000000BA4C4C00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000CF9808007F5B00007F5B00007F5B00007F5B0000CF9808000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000007F5B0000CF98080000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000BA4C4C00BA4C4C00BA4C
      4C00000000000000000000000000000000000000000000000000000000000000
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
      000000000000000000000000FFFFFF00FFFFFFFFFFFF0000FFFFFFFFFFFF0000
      FE7FF81FC01F0000FC3FF81F800F0000F81FF81F80070000F00FF81F80030000
      E007800180010000C0038001800100008001C003800F00008001E007800F0000
      F81FF00F80110000F81FF81FC7F90000F81FFC3FFF750000F81FFE7FFF8F0000
      FFFFFFFFFFFF0000FFFFFFFFFFFF000000000000000000000000000000000000
      000000000000}
  end
  object odTortoiseProcFileName: TOpenDialog
    Filter = 'Executable|*.exe'
    Options = [ofHideReadOnly, ofFileMustExist, ofEnableSizing]
    Left = 416
  end
end
