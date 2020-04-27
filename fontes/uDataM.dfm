object fDataM: TfDataM
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Left = 708
  Top = 202
  Height = 411
  Width = 328
  object FIB_Db: TpFIBDatabase
    DBParams.Strings = (
      'user_name=SYSDBA'
      'password=masterkey')
    DefaultTransaction = FIB_Tr
    DefaultUpdateTransaction = FIB_Tr
    SQLDialect = 3
    Timeout = 0
    GeneratorsCache.GeneratorList = <>
    WaitForRestoreConnect = 0
    Left = 40
    Top = 12
  end
  object FIB_Tr: TpFIBTransaction
    DefaultDatabase = FIB_Db
    TimeoutAction = TARollback
    MDTTransactionRole = mtrAutoDefine
    Left = 120
    Top = 12
  end
  object QueryDM: TpFIBQuery
    Transaction = TransDM
    Database = FIB_Db
    Left = 40
    Top = 96
  end
  object TransDM: TpFIBTransaction
    DefaultDatabase = FIB_Db
    TimeoutAction = TARollback
    MDTTransactionRole = mtrAutoDefine
    Left = 120
    Top = 96
  end
  object QueryData: TpFIBQuery
    Transaction = TransDATA
    Database = FIB_Db
    Left = 40
    Top = 160
  end
  object TransDATA: TpFIBTransaction
    DefaultDatabase = FIB_Db
    TimeoutAction = TARollback
    MDTTransactionRole = mtrAutoDefine
    Left = 120
    Top = 160
  end
  object QueryDMGrava: TpFIBQuery
    Transaction = TransDMGrava
    Database = FIB_Db
    Left = 40
    Top = 232
  end
  object TransDMGrava: TpFIBTransaction
    DefaultDatabase = FIB_Db
    TimeoutAction = TARollback
    MDTTransactionRole = mtrAutoDefine
    Left = 120
    Top = 232
  end
  object QueryBusca: TpFIBQuery
    Transaction = TransBusca
    Database = FIB_Db
    Left = 40
    Top = 296
  end
  object TransBusca: TpFIBTransaction
    DefaultDatabase = FIB_Db
    TimeoutAction = TARollback
    MDTTransactionRole = mtrAutoDefine
    Left = 120
    Top = 296
  end
end
