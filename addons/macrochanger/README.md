# MacroChanger #

Detects job change and automatically switches in-game macro set to the [book] & [page] configured for the new job.

----
### Commands: ###
#### Enabled ####
```
//macrochanger enabled true
```

Enables all automated macro switching (not disabled individually).

```
//macrochanger enabled false
```

Disables all automated macro switching.

### Configuration Example: ###
```
<?xml version="1.1" ?>
<settings>
    <global>
        <default>true</default>
        <enabled>false</enabled>
    </global>
    <cecil>
        <default>false</default>
        <enabled>true</enabled>
        <macros>
            <war>
                <book>1</book>
                <page>1</page>
            </war>
            <mnk>
                <book>1</book>
                <page>6</page>
            </mnk>
            <warmnk>
                <book>2</book>
                <page>1</page>
            </warmnk>
        </macros>
    </cecil>
</settings>
```
