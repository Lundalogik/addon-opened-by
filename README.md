# package-opened-by

A package for handling varnings/locks when posts are opened by someone else.

Installation:

Install the package with LIP.

Add the following line of code in the ControlsHandler.Class_Initialize of your desire:

```
Call OpenedBy.SetAsOpenedBy(CStr(Application.ActiveUser.ID), CStr(m_Controls.Record.ID), m_Controls.Class.name, Application.ActiveUser.name)
```

To delete the OpenedBy post you add the following line of code to the BeforeClose method in the InspectorHandler of your desire and to the BeforeRecordChanged in the ControlsHandler of your desire:

ControlsHandler.BeforeRecordChanged:
```
Call OpenedBy.DeleteOpenedByRecord(CStr(Application.ActiveUser.ID), CStr(m_Controls.Record.ID), m_Controls.Class.name)
```

InspectorHandler.BeforeClose:
```
Call OpenedBy.DeleteOpenedByRecord(CStr(Application.ActiveUser.ID), CStr(m_Inspector.Record.ID), m_Inspector.Class.name)
```

The following code should be added to the ExplorerHandler.BeforeCommand of your choice (remember to check for the right class if you're using the GeneralExplorerHandler):

```
'OpenedBy --------->
    If Command = lkCommandOpen Then
        Dim lUserId As Long
        If Not ActiveUser Is Nothing Then
            'Added YYYY-MM-DD addon-opened-by
            Cancel = OpenedBy.AvailableCheck(CStr(Application.ActiveUser.ID), CStr(m_Explorer.ActiveItem.ID), "<tablename>")
        End If
    End If
'<-------- OpenedBy
```

You can change the message through the localize posts that are related to the OpenedBy package:
- i_openedbymessage
- i_openedbymessage2
- i_blockedopenedby


There is an option for blocking opening of posts that is already opened by someone. Change the value bBlockOnOpen to True at the top of the OpenedBy module. There you also need to specify the API url. 

Finally, instruct the superuser that if Lime crashes and records are locked even though there are no users using the record, they have to manually delete the post in the "openedby"-table.

