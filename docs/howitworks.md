hero: Get a warning when trying to open a card that someone else already has open.

# How it Works

OpenedBy uses the REST-api to create OpenedBy records to keep track of which records that are open and who has them open. 

Before a record of a limetype that is tracked by OpenedBy, is opened. OpenedBy queries the OpenedBy table to see if someone else has that record open and if that is the case you either get a warning or a message saying that the record is locked (depends of your config).

OpenedBy only works in the desktop client. 
