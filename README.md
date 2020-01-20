# addon-opened-by

An add-on for handling varnings/locks when records are opened by someone else. OpenedBy uses REST-api calls to create OpenedBy records which also is queried upon opening records of a certain type. 

Only works in the desktop client. 

Is cloud compatible.

Installation:

Install the package with LIP. A VBA .bas file will be installed as well as a new table called OpenedBy along with some localization records.

Add the following line of code in the ControlsHandler.Class_Initialize of your desire:

```
Call OpenedBy.SetOpenedBy(m_controls.Record.ID, "<tablename>")
```

To delete the OpenedBy post you add the following line of code to the BeforeClose method in the InspectorHandler of your desire and to the BeforeRecordChanged in the ControlsHandler of your desire:

ControlsHandler.m_controls.BeforeRecordChanged:
```
'Opened By
If Not m_inspector Is Nothing Then
    Call OpenedBy.RemoveOpenedBy(m_Controls.Record.ID, m_Controls.Class.Name)
End If

```

InspectorHandler.BeforeClose:
```
Call OpenedBy.RemoveOpenedBy(m_inspector.Record.ID, m_inspector.Class.Name)
```

The following code should be added to the ExplorerHandler.BeforeCommand of your choice (remember to check for the right class if you're using the GeneralExplorerHandler):

```
'OpenedBy --------->
If Command = lkCommandOpen Then        
    If Not ActiveUser Is Nothing Then
        Cancel = OpenedBy.IsOpenedBy(m_explorer.ActiveItem.ID, "<tablename>")
    End If
End If
'<-------- OpenedBy
```

Finally you need to change the url for the REST-api which is defined in the General.Declarations of the OpenedBy.bas in VBA. There you can also choose if you want to block others from opening records that already are open.
```
'Change this if you want Lime to block locked posts
Const bBlockOnOpen As Boolean = False
'Change this according to your api adress
Const sUrlBase As String = "https://<server_name>/<app_name>/api/v1/limeobject/openedby/"
```
You can change the message through the localize posts that are related to the OpenedBy package.

If on premise, to clean up OpenedBy records that have accidentally been left behind (ex. if Lime crashes), create a job that clears records in OpenedBy table nightly . 

In Cloud this is not possible so there is a VBA method, CleanUpExpired, which clears OpenedBy records that are older than a day (this is a setting in the OpenedBy module). Add a call to the method in the ThisApplication method which suits best for it.  

The OpenedBy table should also be visible for administrators (it is by default) so that they can remove records manually if needed.


