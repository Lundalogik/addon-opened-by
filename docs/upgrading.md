hero: Get a warning when trying to open a card that someone else already has open.

# Upgrading from v2.x.y from v1.x.y
Notice that the name of the following components have changed: 

* VBA module: OpenedBy.bas -> AO_OpenedBy.bas 
* sql procedure: csp_clear_openedby.sql -> csp_addon_openedby_clear_openedby.sql
* owner of the localization posts: OpenedBy -> AO_OpenedBy

Steps to upgrade

* Remove the VBA module OpenedBy.
* Remove the old localization posts, or change the name of the owner according to the change above.
* Follow the steps of the [installation](installation.md) and make sure to change names according to the changes listed above.
  

