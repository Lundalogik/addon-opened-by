Attribute VB_Name = "AO_OpenedBy"
Option Explicit
'Settings
'Change this if you want Lime to block locked posts
Const bBlockOnOpen As Boolean = False
'Change this according to your api adress
Const sUrlBase As String = "https://<server name>/<database name>/api/v1/limeobject/openedby/"
'Change this
Const iExpireDays As Integer = 1

Public Sub CleanUpExpired()
    ' mwe quick hack to clean up (2019-11-26)
    On Error GoTo errorhandler

    Dim pFilter As New LDE.Filter
    Dim pRecords As New LDE.Records
    Dim pRecord As New LDE.Record
    Dim pBatch As New LDE.Batch
    Set pBatch.Database = Application.Database
    
    Call pFilter.AddCondition("createdtime", lkOpLess, Now - 1)

    Call pRecords.Open(Classes("openedby"), pFilter)
    For Each pRecord In pRecords
        pRecord.delete
        Call pRecord.Update(pBatch)
    Next
    Call pBatch.Execute
    Exit Sub
errorhandler:
End Sub




Function IsOpenedBy(sRecordId As String, sTableName As String) As Boolean
    On Error GoTo errorhandler
    
    Dim sResponse As String
    Dim sMyUrl As String
    Dim oJson As Object
    Dim embedded As Object
    Dim iAnswer As Integer
    Dim sOpenedByUser As String
    Dim bIsOpenedByOther As Boolean
    Dim i As Integer
    Dim bCancelOpen As Boolean
    
    'Use the REST API to see if someone has opened the record already
    sMyUrl = sUrlBase + "?recordid=" + sRecordId + "&tablename=" + sTableName
    sResponse = XmlHttpSend("GET", sMyUrl, Nothing)
    
    'Warning should not be shown
    bCancelOpen = False
    'Warning should be shown
    IsOpenedBy = bCancelOpen
    
    If sResponse <> "" Then
        Set oJson = JSON.parse(sResponse)
        Set embedded = oJson("_embedded")
        
        If embedded("limeobjects").count <> 0 Then
            'If post is opened by another user
            For i = 1 To embedded("limeobjects").count
                If embedded("limeobjects")(i)("iduser") <> CStr(Application.ActiveUser.ID) Then
                    bIsOpenedByOther = True
                    sOpenedByUser = embedded("limeobjects")(i)("name")
                    Exit For
                End If
            Next i
            If bIsOpenedByOther Then
                'If record already is opened then block or allow the iduser to proceed
                If Not bBlockOnOpen Then
                    iAnswer = Lime.MessageBox(Localize.GetText("AO_OpenedBy", "i_openedbymessage"), VBA.vbYesNo + VBA.vbQuestion + vbDefaultButton2, sOpenedByUser)
                    If iAnswer = vbYes Then
                        bCancelOpen = False
                        IsOpenedBy = bCancelOpen
                    Else
                        bCancelOpen = True
                        IsOpenedBy = bCancelOpen
                    End If
                Else
                    Call Lime.MessageBox(Localize.GetText("AO_OpenedBy", "i_blockedopenedby"), vbOKOnly + vbExclamation, sOpenedByUser)
                    bCancelOpen = True
                    IsOpenedBy = bCancelOpen
                End If
            End If
        End If
    End If

    Exit Function
errorhandler:
    IsOpenedBy = True
    Call LC_UI.ShowError("AO_OpenedBy.IsOpenedBy")
End Function

Sub SetOpenedBy(sRecordId As String, sTableName As String)
    On Error GoTo errorhandler
    
    Dim sResponse As String
    Dim oPayloadBody As New Scripting.Dictionary
    
    oPayloadBody.Add "iduser", ActiveUser.ID
    oPayloadBody.Add "recordid", sRecordId
    oPayloadBody.Add "tablename", sTableName
    oPayloadBody.Add "name", ActiveUser.Name
        
    sResponse = XmlHttpSend("POST", sUrlBase, oPayloadBody)
    
    Exit Sub
errorhandler:
    Call LC_UI.ShowError("AO_OpenedBy.SetAsOpenedBy")
End Sub

Sub RemoveOpenedBy(sRecordId As String, sTableName As String)
    On Error GoTo errorhandler
    
    'Settings
    Dim sResponse As String
    Dim geturl As String
    Dim deleteurl As String
    Dim ID As String
    Dim limeobjects As Collection
    Dim embedded As Object
    Dim oJson As Object
    Dim i As Integer
    
    'REST API GET idopenedby from tablename
    geturl = sUrlBase & "?recordid=" & sRecordId & "&iduser=" & ActiveUser.ID & "&tablename=" & sTableName
    sResponse = XmlHttpSend("GET", geturl, Nothing)

    'REST API DELETE if idopenedby found
    If sResponse <> "" Then
        Set oJson = JSON.parse(sResponse)
        Set embedded = oJson("_embedded")
        If embedded("limeobjects").count > 0 Then
            For i = 1 To embedded("limeobjects").count
                Set limeobjects = embedded("limeobjects")
                ID = CStr(limeobjects(i)("_id"))
            
                deleteurl = sUrlBase & ID & "/"
        
                sResponse = OpenedBy.XmlHttpSend("DELETE", deleteurl, Nothing)
            Next
        End If
    End If
    
    Exit Sub
errorhandler:
    Call LC_UI.ShowError("AO_OpenedBy.RemoveOpenedBy")
End Sub

Function XmlHttpSend(sMethod As String, sUrl As String, payload As Scripting.Dictionary) As String
    On Error GoTo errorhandler
    
    Dim xmlhttp As New MSXML2.XMLHTTP60
    
    xmlhttp.Open sMethod, sUrl, False
    xmlhttp.setRequestHeader "Content-Type", "application/json"
    xmlhttp.setRequestHeader "sessionid", Application.Database.SessionID
    
    If payload Is Nothing Then
        xmlhttp.Send
    Else
        xmlhttp.Send JsonConverter.ConvertToJson(payload)
    End If
    
    If xmlhttp.Status > 199 And xmlhttp.Status < 205 Then
        XmlHttpSend = xmlhttp.responseText
    Else
        Lime.MessageBox ("API call returned " & xmlhttp.Status & " " & xmlhttp.statusText), vbOKOnly + vbExclamation
        XmlHttpSend = ""
    End If
    
    Exit Function
errorhandler:
    Call LC_UI.ShowError("AO_OpenedBy.XmlHttpSend")
End Function
