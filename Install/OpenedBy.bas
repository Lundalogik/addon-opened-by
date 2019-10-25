Option Explicit

'Settings
'Change this if you want Lime to block locked posts
Const bBlockOnOpen As Boolean = False
'Change this according to your api adress
Const urlbase As String = "https://localhost/lime_testing/api/v1/limeobject/openedby/"



Function AvailableCheck(userid As String, recordid As String, tablename As String) As Boolean
    On Error GoTo ErrorHandler
    
    Dim sResponse As String
    Dim myurl As String
    Dim oJson As Object
    Dim embedded As Object
    Dim iAnswer As Integer
    Dim openedByUser As String
    Dim bIsOpened As Boolean
    Dim i As Integer
    bIsOpened = False
    
    'Use the REST API to see if someone has opened the record already
    myurl = urlbase + "?recordid=" + recordid
    sResponse = OpenedBy.callxmlhttp("GET", myurl, Nothing)
    
    'Count the number of userids that have opened the record
    If sResponse <> "" Then
        Set oJson = JSON.parse(sResponse)
        Set embedded = oJson("_embedded")
        
        If embedded("limeobjects").Count <> 0 Then
            'If post is opened by this user
            For i = 1 To embedded("limeobjects").Count
                If embedded("limeobjects")(i)("userid") = CStr(Application.ActiveUser.ID) Then
                    bIsOpened = True
                End If
            Next i
            If Not bIsOpened Then
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
        Else
            AvailableCheck = False
        End If
        
    End If

    Exit Function
ErrorHandler:
    AvailableCheck = True
    Call LC_UI.ShowError("OpenedBy.AvailableCheck")
End Function

Sub SetAsOpenedBy(userid As String, recordid As String, tablename As String, username As String)
    On Error GoTo ErrorHandler
    
    Dim sResponse As String
    Dim oBody As New Scripting.Dictionary
    
    'Payload
    oBody.Add "userid", userid
    oBody.Add "recordid", recordid
    oBody.Add "tablename", tablename
    oBody.Add "name", username
    
    'REST API POST CALL
    sResponse = OpenedBy.callxmlhttp("POST", urlbase, oBody)
    
    
    
    Exit Sub
ErrorHandler:
    Call LC_UI.ShowError("OpenedBy.SetAsOpenedBy")
End Sub

Sub DeleteOpenedByRecord(userid As String, recordid As String, tablename As String)
    On Error GoTo ErrorHandler
    
    'Settings
    Dim sResponse As String
    Dim geturl As String
    Dim deleteurl As String
    Dim ID As String
    Dim limeobjects As Collection
    Dim embedded As Object
    Dim oJson As Object
    
    'REST API GET idopenedby from tablename
    geturl = urlbase & "?recordid=" & recordid & "&userid=" & userid & "&tablename=" & tablename
    sResponse = OpenedBy.callxmlhttp("GET", geturl, Nothing)

    'REST API DELETE if idopenedby found
    If sResponse <> "" Then
        Set oJson = JSON.parse(sResponse)
        Set embedded = oJson("_embedded")
        If embedded("limeobjects").Count > 0 Then
            Set limeobjects = embedded("limeobjects")
            ID = CStr(limeobjects(1)("_id"))
        
            deleteurl = urlbase & ID & "/"
            sResponse = OpenedBy.callxmlhttp("DELETE", deleteurl, Nothing)
        End If
    End If
    
    Exit Sub
ErrorHandler:
    Call LC_UI.ShowError("OpenedBy.DeleteOpenedByRecord")
End Sub

Function callxmlhttp(method As String, url As String, payload As Scripting.Dictionary) As String
    On Error GoTo ErrorHandler
    
    Dim xmlhttp As New MSXML2.XMLHTTP60
    
    xmlhttp.Open method, url, False
    xmlhttp.setRequestHeader "Content-Type", "application/json"
    xmlhttp.setRequestHeader "sessionid", Application.Database.SessionID
    
    If payload Is Nothing Then
        xmlhttp.Send
    Else
        xmlhttp.Send JsonConverter.ConvertToJson(payload)
    End If
    
    If xmlhttp.Status > 199 Or xmlhttp.Status < 205 Then
        callxmlhttp = xmlhttp.responseText
    Else
        MsgBox ("API call returned " & xmlhttp.Status & " " & xmlhttp.statusText)
        callxmlhttp = ""
    End If
    
    Exit Function
ErrorHandler:
    Call LC_UI.ShowError("OpenedBy.callxmlhttp")
End Function
