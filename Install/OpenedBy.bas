Attribute VB_Name = "OpenedBy"
Option Explicit

'Settings
'Change this if you want Lime to block locked posts
Const bBlockOnOpen As Boolean = False
'Change this according to your api adress
Const urlbase As String = "https://localhost/lime_testing/api/v1/limeobject/openedby/"



Function AvailableCheck(userid As String, recordid As String, tablename As String) As Boolean
    On Error GoTo ErrorHandler
    
    Dim xmlhttp As New MSXML2.XMLHTTP60
    Dim myurl As String
    Dim oJson As Object
    Dim embedded As Object
    Dim iAnswer As Integer
    Dim openedByUser As String
    
    'Use the REST API to see if someone has opened the record already
    myurl = urlbase + "?recordid=" + recordid
    xmlhttp.Open "GET", myurl, False
    xmlhttp.setRequestHeader "Content-Type", "application/json"
    xmlhttp.setRequestHeader "sessionid", Application.Database.SessionID
    xmlhttp.Send
    
    'Count the number of userids that have opened the record
    Set oJson = JSON.parse(xmlhttp.responseText)
    Set embedded = oJson("_embedded")

    If embedded("limeobjects").Count <> 0 Then
        'If record already is opened then block or allow the userid to proceed
        openedByUser = embedded("limeobjects")(1)("name")
        If Not bBlockOnOpen Then
            iAnswer = Lime.MessageBox(Localize.GetText("OpenedBy", "i_openedbymessage") & " " & openedByUser & Localize.GetText("OpenedBy", "i_openedbymessage2"), VBA.vbYesNo + VBA.vbQuestion + vbDefaultButton2)
            If iAnswer = vbYes Then
                AvailableCheck = False
            Else
                AvailableCheck = True
            End If
        Else
            Call Lime.MessageBox(Localize.GetText("OpenedBy", "i_blockedopenedby") & " " & openedByUser, vbOKOnly + vbExclamation)
            AvailableCheck = True
        End If
    Else
        AvailableCheck = False
    End If

    Exit Function
ErrorHandler:
    AvailableCheck = True
    Call LC_UI.ShowError("OpenedBy.AvailableCheck")
End Function

Sub SetAsOpenedBy(userid As String, recordid As String, tablename As String, username As String)
    On Error GoTo ErrorHandler
    
    Dim xmlhttp As New MSXML2.XMLHTTP60
    Dim oBody As New Scripting.Dictionary
    
    'REST API POST CALL
    xmlhttp.Open "POST", urlbase, False
    xmlhttp.setRequestHeader "Content-Type", "application/json"
    xmlhttp.setRequestHeader "sessionid", Application.Database.SessionID
    oBody.Add "userid", userid
    oBody.Add "recordid", recordid
    oBody.Add "tablename", tablename
    oBody.Add "name", username
    xmlhttp.Send JsonConverter.ConvertToJson(oBody)
    
    Exit Sub
ErrorHandler:
    Call LC_UI.ShowError("OpenedBy.SetAsOpenedBy")
End Sub

Sub DeleteOpenedByRecord(userid As String, recordid As String, tablename As String)
    On Error GoTo ErrorHandler
    
    'Settings
    Dim xmlhttp As New MSXML2.XMLHTTP60
    Dim geturl As String
    Dim deleteurl As String
    Dim ID As String
    Dim limeobjects As Collection
    Dim embedded As Object
    Dim oJson As Object
    
    'REST API GET idopenedby from tablename
    geturl = urlbase & "?recordid=" & recordid & "&userid=" & userid & "&tablename=" & tablename
    xmlhttp.Open "GET", geturl, False
    xmlhttp.setRequestHeader "Content-Type", "application/json"
    xmlhttp.setRequestHeader "sessionid", Application.Database.SessionID
    xmlhttp.Send
    
    'REST API DELETE if idopenedby found
    Set oJson = JSON.parse(xmlhttp.responseText)
    Set embedded = oJson("_embedded")
    If embedded("limeobjects").Count > 0 Then
        Set limeobjects = embedded("limeobjects")
        ID = CStr(limeobjects(1)("_id"))
    
        deleteurl = urlbase & ID & "/"
        xmlhttp.Open "DELETE", deleteurl, False
        xmlhttp.setRequestHeader "Content-Type", "application/json"
        xmlhttp.setRequestHeader "sessionid", Application.Database.SessionID
        xmlhttp.Send
    End If
    
    Exit Sub
ErrorHandler:
    Call LC_UI.ShowError("OpenedBy.DeleteOpenedByRecord")
End Sub



