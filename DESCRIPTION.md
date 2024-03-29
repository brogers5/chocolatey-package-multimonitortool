## MultiMonitorTool

MultiMonitorTool is a small tool that allows you to do some actions related to working with multiple monitors.

With MultiMonitorTool, you can disable/enable monitors, set the primary monitor, save and load the configuration of all monitors, and move windows from one monitor to another. You can do these actions from the user interface or from command-line, without displaying user interface.

MultiMonitorTool also provides a preview window, which allows you to watch a preview of every monitor on your system.

![MultiMonitorTool Screenshot](https://cdn.jsdelivr.net/gh/brogers5/chocolatey-package-multimonitortool@ee26537e9b0fb922c60252e6b7a4366295e73ad8/Screenshot.png)

## Package Parameters

* `/NoShim` - Opt out of creating a GUI shim.
* `/NoDesktopShortcut` - Opt out of creating a Desktop shortcut.
* `/NoProgramsShortcut` - Opt out of creating a Programs shortcut in your Start Menu.
* `/Start` - Automatically start MultiMonitorTool after installation completes.

## Package Notes

For future upgrade operations, consider opting into Chocolatey's `useRememberedArgumentsForUpgrades` feature to avoid having to pass the same arguments with each upgrade:

```shell
choco feature enable --name="'useRememberedArgumentsForUpgrades'"
```
