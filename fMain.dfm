object fmMain: TfmMain
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsNone
  ClientHeight = 166
  ClientWidth = 400
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  Visible = True
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object pnlMain: TPanel
    Left = 0
    Top = 0
    Width = 400
    Height = 166
    Align = alClient
    BevelKind = bkFlat
    BevelOuter = bvNone
    TabOrder = 0
    object grdProjectCommands: TSembaDBGrid
      Left = 0
      Top = 0
      Width = 396
      Height = 126
      Align = alClient
      BorderStyle = bsNone
      DataSource = dsProjectCommands
      DefaultDrawing = False
      DynProps = <>
      EvenRowColor = 15137255
      FooterParams.Color = clWindow
      HorzScrollBar.Visible = False
      IndicatorOptions = []
      OddRowColor = clCream
      Options = [dgTabs, dgConfirmDelete, dgCancelOnExit]
      OptionsEh = [dghFixed3D, dghClearSelection, dghDialogFind, dghExtendVertLines]
      RowHeight = 18
      TabOrder = 0
      VertScrollBar.VisibleMode = sbNeverShowEh
      OnCellClick = grdProjectCommandsCellClick
      OnDrawColumnCell = grdProjectCommandsDrawColumnCell
      OnMouseMove = grdProjectCommandsMouseMove
      object RowDetailData: TRowDetailPanelControlEh
      end
    end
    object pnlConfig: TPanel
      Left = 0
      Top = 144
      Width = 396
      Height = 18
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 1
      Visible = False
      object btnConfig: TSpeedButton
        Left = 0
        Top = 0
        Width = 396
        Height = 18
        Action = actConfig
        Align = alClient
        Flat = True
      end
    end
    object pnlShowMore: TPanel
      Left = 0
      Top = 126
      Width = 396
      Height = 18
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 2
      object btnShowMore: TSpeedButton
        Left = 0
        Top = 0
        Width = 396
        Height = 18
        Action = actShowMore
        Align = alClient
        Flat = True
      end
    end
  end
  object alMain: TActionList
    Left = 208
    object actConfig: TAction
      Caption = 'Config...'
      Hint = 'Configuration'
      ImageIndex = 1
      OnExecute = actConfigExecute
    end
    object actShowMore: TAction
      Caption = 'More...'
      Checked = True
      Hint = 'Shows All Projects'
      ImageIndex = 0
      OnExecute = actShowMoreExecute
    end
  end
  object cdsProjects: TSembaClientDataSet
    Aggregates = <>
    AggregatesActive = True
    FieldDefs = <>
    IndexDefs = <>
    IndexFieldNames = 'PROJECT_NO'
    Params = <>
    StoreDefs = True
    OnNewRecord = cdsProjectsNewRecord
    Left = 240
    object cdsProjectsPROJECT_NO: TSembaFloatField
      DisplayLabel = 'No'
      FieldName = 'PROJECT_NO'
      Required = True
    end
    object cdsProjectsPROJECT_NAME: TSembaWideStringField
      DisplayLabel = 'Project Name'
      FieldName = 'PROJECT_NAME'
      Required = True
      Size = 50
    end
    object cdsProjectsPROJECT_DIR: TSembaWideStringField
      DisplayLabel = 'Project Dir'
      FieldName = 'PROJECT_DIR'
      Required = True
      Size = 250
    end
    object cdsProjectsIS_FAVORITE: TSembaFloatField
      DisplayLabel = 'Favorite'
      FieldName = 'IS_FAVORITE'
      Required = True
      FieldValueType = fvtBoolean
    end
    object cdsProjects_MAX_NO: TAggregateField
      FieldName = '_MAX_NO'
      Active = True
      DisplayName = ''
      Expression = 'Max(PROJECT_NO)'
    end
  end
  object cdsSCMCommands: TSembaClientDataSet
    Aggregates = <>
    AggregatesActive = True
    FieldDefs = <>
    IndexDefs = <>
    IndexFieldNames = 'COMMAND_NO'
    Params = <>
    StoreDefs = True
    OnNewRecord = cdsSCMCommandsNewRecord
    Left = 272
    object cdsSCMCommandsCOMMAND_NO: TSembaFloatField
      DisplayLabel = 'No'
      FieldName = 'COMMAND_NO'
      Required = True
    end
    object cdsSCMCommandsCOMMAND_NAME: TSembaWideStringField
      DisplayLabel = 'Command Name'
      FieldName = 'COMMAND_NAME'
      Required = True
      Size = 50
    end
    object cdsSCMCommandsCOMMAND_ARGUMENTS: TSembaWideStringField
      DisplayLabel = 'Arguments'
      FieldName = 'COMMAND_ARGUMENTS'
      Required = True
      Size = 250
    end
    object cdsSCMCommandsIS_FAVORITE: TSembaFloatField
      DisplayLabel = 'Favorite'
      FieldName = 'IS_FAVORITE'
      Required = True
      FieldValueType = fvtBoolean
    end
    object cdsSCMCommands_MAX_NO: TAggregateField
      FieldName = '_MAX_NO'
      Active = True
      DisplayName = ''
      Expression = 'Max(COMMAND_NO)'
    end
  end
  object dsProjectCommands: TDataSource
    DataSet = cdsProjectCommands
    Left = 368
  end
  object cdsProjectCommands: TSembaClientDataSet
    Aggregates = <>
    Filter = 'IS_FAVORITE = 1'
    Filtered = True
    Params = <>
    Left = 336
  end
  object aeAppEvents: TApplicationEvents
    OnDeactivate = aeAppEventsDeactivate
    Left = 64
  end
end
