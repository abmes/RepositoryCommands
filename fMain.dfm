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
    object pnlConfig: TPanel
      Left = 0
      Top = 144
      Width = 396
      Height = 18
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 0
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
      TabOrder = 1
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
    object grdProjectCommands: TDBGrid
      Left = 0
      Top = 0
      Width = 396
      Height = 126
      Align = alClient
      BorderStyle = bsNone
      DataSource = dsProjectCommands
      DefaultDrawing = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -15
      Font.Name = 'Tahoma'
      Font.Style = []
      Options = [dgRowLines, dgTabs, dgConfirmDelete, dgCancelOnExit, dgTitleClick, dgTitleHotTrack]
      ParentFont = False
      TabOrder = 2
      TitleFont.Charset = DEFAULT_CHARSET
      TitleFont.Color = clWindowText
      TitleFont.Height = -11
      TitleFont.Name = 'Tahoma'
      TitleFont.Style = []
      OnCellClick = grdProjectCommandsCellClick
      OnDrawColumnCell = grdProjectCommandsDrawColumnCell
      OnMouseMove = grdProjectCommandsMouseMove
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
  object dsProjectCommands: TDataSource
    DataSet = cdsProjectCommands
    Left = 368
  end
  object aeAppEvents: TApplicationEvents
    OnDeactivate = aeAppEventsDeactivate
    OnMessage = aeAppEventsMessage
    Left = 64
  end
  object cdsProjects: TClientDataSet
    Aggregates = <>
    AggregatesActive = True
    IndexFieldNames = 'PROJECT_NO'
    Params = <>
    OnNewRecord = cdsProjectsNewRecord
    Left = 240
    object cdsProjectsPROJECT_NO: TFloatField
      DisplayLabel = 'No'
      FieldName = 'PROJECT_NO'
      Required = True
    end
    object cdsProjectsPROJECT_NAME: TWideStringField
      DisplayLabel = 'Project Name'
      FieldName = 'PROJECT_NAME'
      Required = True
      Size = 50
    end
    object cdsProjectsPROJECT_DIR: TWideStringField
      DisplayLabel = 'Project Dir'
      FieldName = 'PROJECT_DIR'
      Required = True
      Size = 250
    end
    object cdsProjectsIS_FAVORITE: TBooleanField
      Alignment = taCenter
      DisplayLabel = 'Favorite'
      FieldName = 'IS_FAVORITE'
      Required = True
      DisplayValues = #1062';'
    end
    object cdsProjects_MAX_NO: TAggregateField
      FieldName = '_MAX_NO'
      Active = True
      DisplayName = ''
      Expression = 'Max(PROJECT_NO)'
    end
  end
  object cdsCommands: TClientDataSet
    Aggregates = <>
    AggregatesActive = True
    IndexFieldNames = 'COMMAND_NO'
    Params = <>
    OnNewRecord = cdsCommandsNewRecord
    Left = 272
    object cdsCommandsCOMMAND_NO: TFloatField
      DisplayLabel = 'No'
      FieldName = 'COMMAND_NO'
      Required = True
    end
    object cdsCommandsCOMMAND_NAME: TWideStringField
      DisplayLabel = 'Command Name'
      FieldName = 'COMMAND_NAME'
      Required = True
      Size = 50
    end
    object cdsCommandsCOMMAND_ARGUMENTS: TWideStringField
      DisplayLabel = 'Arguments'
      FieldName = 'COMMAND_ARGUMENTS'
      Required = True
      Size = 2000
    end
    object cdsCommandsIS_FAVORITE: TBooleanField
      Alignment = taCenter
      DisplayLabel = 'Favorite'
      FieldName = 'IS_FAVORITE'
      Required = True
      DisplayValues = #1062';'
    end
    object cdsCommands_MAX_NO: TAggregateField
      FieldName = '_MAX_NO'
      Active = True
      DisplayName = ''
      Expression = 'Max(COMMAND_NO)'
    end
  end
  object cdsProjectCommands: TClientDataSet
    Aggregates = <>
    Filter = 'IS_FAVORITE = True'
    Filtered = True
    FieldDefs = <>
    IndexDefs = <>
    Params = <>
    StoreDefs = True
    Left = 336
  end
end
