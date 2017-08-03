# package-opened-by

A package for handling varnings/locks when posts are opened by someone else.

Installation:

Install the package with LIP and make sure that you add the two csp:s.

Add the following line of code in the ControlsHandler.Class_Initialize of your desire:
 
Call OpenedBy.SetOpenedBy(m_controls.Record.ID, "<tablename>", 0)

To delete the OpenedBy post you add the following line of code to the BeforeRecordChanged in the ControlsHandler of your desire:

Call OpenedBy.RemoveOpenedBy(m_Controls.Record.ID, m_Controls.Class.Name)

The following code should be added to the ExplorerHandler.BeforeCommand of your choice (remember to check for the right class if you're using the GeneralExplorerHandler):

'OpenedBy --------->
If Command = lkCommandOpen Then
    Dim lUserId As Long
    Dim sOpenedBy As String
        
    If Not ActiveUser Is Nothing Then    
        sOpenedBy = OpenedBy.IsOpenedBy(m_Explorer.ActiveItem.ID, "<tablename>")
        If sOpenedBy <> "" Then
            Cancel = OpenedBy.Message(sOpenedBy)
        End If
    End If
End If
'<-------- OpenedBy

You can change the message through the localize posts that are related to the OpenedBy package.

There is an option for blocking opening of posts that is already opened by someone. Change the value bBlockOnOpen to True in the OpenedBy.Message function.

Limitations:

Opened By is not set if you
