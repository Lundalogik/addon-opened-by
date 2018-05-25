Attribute VB_Name = "OpenedBy"
Option Explicit

Public Function SetOpenedBy(recordid As Long, tableName As String, delete As Integer) As Boolean
    On Error GoTo ErrorHandler
    
    Dim oProc As New LDE.Procedure
    Dim oResults As Integer
    
    Set oProc = Database.Procedures.Lookup("csp_set_openedby", lkLookupProcedureByName)

    oProc.Parameters("@@iduser").InputValue = ActiveUser.ID
    oProc.Parameters("@@idrecord").InputValue = recordid
    oProc.Parameters("@@delete").InputValue = delete
    oProc.Parameters("@@tablename").InputValue = tableName
    
    Call oProc.Execute(False)
    
    SetOpenedBy = False
    
    Exit Function
ErrorHandler:
    SetOpenedBy = True
    Call UI.ShowError("OpenedBy.SetOpenedBy")
End Function

Public Function IsOpenedBy(recordid As Long, tableName As String)
    On Error GoTo ErrorHandler
    
    Dim oProc As New LDE.Procedure
        
    Set oProc = Database.Procedures.Lookup("csp_is_openedby", lkLookupProcedureByName)
    
    oProc.Parameters("@@idrecord").InputValue = recordid
    oProc.Parameters("@@tablename").InputValue = tableName
    
    Call oProc.Execute(False)
    
    IsOpenedBy = IIf(IsNull(oProc.Parameters("@@openedby").OutputValue), "", oProc.Parameters("@@openedby").OutputValue)
    
    Exit Function
ErrorHandler:
    Call UI.ShowError("OpenedBy.IsOpenedBy")
End Function

Public Sub RemoveOpenedBy(recordid As Long, tableName As String)
    On Error GoTo ErrorHandler
    
    Dim delete As Integer
    delete = 1
    
    Call SetOpenedBy(recordid, tableName, delete)
    
    Exit Sub
ErrorHandler:
    Call UI.ShowError("OpenedBy.RemoveOpenedBy")
End Sub

'Called when a ticket is opened by someone.
'Should be dynamic and customizable
Public Function Message(sOpenedBy As String) As Boolean
    On Error GoTo ErrorHandler
    
    'Settings
    Dim bBlockOnOpen As Boolean: bBlockOnOpen = False
    'Change this if you want Lime to block locked posts
    
    Dim sOpenedByMessage As String
    Dim vOpenedBy As Variant
    Dim vIdUser As Variant
    Dim bOpenedByYou As Boolean
    
    vOpenedBy = Split(sOpenedBy, ";")
    For Each vIdUser In vOpenedBy
        If vIdUser <> "" Then
            If vIdUser <> CStr(ActiveUser.ID) Then
                If sOpenedByMessage <> "" Then
                    sOpenedByMessage = sOpenedByMessage + ", " + Database.Users.Lookup(vIdUser, lkLookupUserByID).Name
                Else
                    sOpenedByMessage = sOpenedByMessage + Database.Users.Lookup(vIdUser, lkLookupUserByID).Name
                End If
            Else
                bOpenedByYou = True
            End If
        End If
    Next
    
    If Not bOpenedByYou Then
        If Not bBlockOnOpen Then
            Dim iAnswer As Integer
            iAnswer = Lime.MessageBox(Localize.GetText("OpenedBy", "i_openedbymessage"), VBA.vbYesNo + VBA.vbQuestion + vbDefaultButton2, sOpenedByMessage)
            If iAnswer = vbYes Then
                Message = False
            Else
                Message = True
            End If
        Else
            Call Lime.MessageBox(Localize.GetText("OpenedBy", "i_blockedopenedby"), vbOKOnly + vbExclamation, sOpenedByMessage)
            Message = True
        End If
    End If
            
    Exit Function
ErrorHandler:
    Message = False
    Call UI.ShowError("OpenedBy.Message")
End Function
