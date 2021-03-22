hero: Get a warning when trying to open a card that someone else already has open.

# Configuration
Finally you need to change the url for the REST-api which is defined in the General declarations of the AO_OpenedBy.bas in VBA. There you can also choose if you want to block others from opening records that already are open.
```
'Change this if you want Lime to block locked posts
Const bBlockOnOpen As Boolean = False
'Change this according to your api adress
Const sUrlBase As String = "https://<server_name>/<app_name>/api/v1/limeobject/openedby/"
```
You can change the messages through the localize posts that are related to the OpenedBy package.