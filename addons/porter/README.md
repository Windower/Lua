**Author:** Giuliano Riccio  
**Version:** v 1.20130529

# Porter #
This addon shows the slips' items highlighting those that are stored.

## Commands ##
### porter ###
Shows the specified slip or slip's page. if "owned" is specified, only the owned items will be shown. if no parameter is specified, all the owned slips will be shown.

```
porter [<slip> [<page>]] [owned]
```
* **_slip_:** the number of the slip you want to show.
* **_page_:** the page of the slip you want to show.
* **owned:** shows only the items you own.
```
porter find
```
Shows storable items found in all inventory bags.
----

##changelog##
### v1.20200419
* **add**: New command, porter find.
* **change**: Adjusted resource handling.

### v1.20130529
* **fix**: Fixed parameters validation.
* **change**: Aligned to Windower's addon development guidelines.

### v1.20130525.1
* **add**: Added the "owned" param. if present, only the owned items will be shown.

### v1.20130525
* **change**: If no parameter is specified all the owned slips will be shown.

### v1.20130524
* First release.