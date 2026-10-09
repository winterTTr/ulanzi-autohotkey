# Ulanzi D100H AutoHotkey

This repository uses AutoHotkey on Windows to handle shortcuts emitted by a
Ulanzi D100H. Configure the device so that each control action sends its
assigned shortcut, then run `ulanzi-d100h-autohotkey.ahk` with AutoHotkey v2.
Most handlers currently show a dialog naming the control and action; replace
those placeholder actions as the desired behavior is implemented.
The script's `DeviceBindings` map groups each physical control by gesture.
Each gesture specifies the full Windows hotkey sent by the device and the
optional AutoHotkey action; without an action, it shows a dialog identifying
the control and gesture. Configure the device's gestures separately:

| Ulanzi control | Gesture | Windows hotkey | Implementation |
| --- | --- | --- | --- |
| Top left | Single click | Ctrl + Alt + Shift + F1 | Toggle VS Code Explorer (otherwise dialog) |
| Top left | Double click | Ctrl + Alt + Shift + F2 | Switch desktop left |
| Top left | Hold | Ctrl + Alt + Shift + F3 | Dialog |
| Top middle | Single click | Ctrl + Alt + Shift + F4 | Open VS Code Chat (otherwise dialog) |
| Top middle | Double click | Ctrl + Alt + Shift + F5 | Toggle Teams mute |
| Top middle | Hold | Ctrl + Alt + Shift + F6 | Move VS Code Chat into new window (otherwise dialog) |
| Top right | Single click | Ctrl + Alt + Shift + F7 | Toggle VS Code Tasks (otherwise dialog) |
| Top right | Double click | Ctrl + Alt + Shift + F8 | Switch desktop right |
| Top right | Hold | Ctrl + Alt + Shift + F9 | Dialog |
| Left side 1 | Single click | Ctrl + Alt + Shift + Q | Dialog |
| Left side 1 | Double click | Ctrl + Alt + Shift + W | Dialog |
| Left side 1 | Hold | Ctrl + Alt + Shift + E | Dialog |
| Left side 2 | Single click | Ctrl + Alt + Shift + A | Dialog |
| Left side 2 | Double click | Ctrl + Alt + Shift + S | Dialog |
| Left side 2 | Hold | Ctrl + Alt + Shift + D | Dialog |
| Right side 1 | Single click | Ctrl + Alt + Shift + I | Copy |
| Right side 1 | Double click | Ctrl + Alt + Shift + O | VS Code Copy Relative Path (otherwise dialog) |
| Right side 1 | Hold | Ctrl + Alt + Shift + P | Dialog |
| Right side 2 | Single click | Ctrl + Alt + Shift + J | Paste |
| Right side 2 | Double click | Ctrl + Alt + Shift + K | Dialog |
| Right side 2 | Hold | Ctrl + Alt + Shift + L | Dialog |
| Middle dial | Hold and turn left | F13 | Dialog |
| Middle dial | Turn left | F14 | Zoom out in VS Code/Terminal; otherwise volume down |
| Middle dial | Click | F15 | Dialog |
| Middle dial | Turn right | F16 | Zoom in in VS Code/Terminal; otherwise volume up |
| Middle dial | Hold and turn right | F17 | Dialog |

Button shortcuts use the **Ctrl + Alt + Shift** prefix; dial shortcuts are
**bare F13-F17**. The action details and setup requirements follow.

Top-left double click (Ctrl + Alt + Shift + F2) switches to the Windows virtual
desktop on the left; top-right double click (Ctrl + Alt + Shift + F8) switches
to the one on the right. These handlers send Win + Ctrl + Left Arrow and
Win + Ctrl + Right Arrow respectively, instead of showing a dialog. They wait
until the triggering keys are released before sending the Windows shortcut,
so the incoming Ctrl + Alt + Shift modifiers do not overlap it.

When the pointer is over VS Code, top-left single click
(Ctrl + Alt + Shift + F1) switches the Explorer view open/closed; top-right single click
(Ctrl + Alt + Shift + F7) switches the `task.vscode-task` extension's Tasks
view open/closed. With the pointer outside VS Code, both still show their
placeholder dialogs. The script activates the hovered VS Code window and
sends F18 or F19. VS Code needs these context-aware keybindings in the
**user** Keyboard Shortcuts JSON:

```jsonc
{
  "key": "f18",
  "command": "workbench.view.explorer",
  "when": "!explorerViewletVisible"
},
{
  "key": "f18",
  "command": "workbench.action.toggleSidebarVisibility",
  "when": "sideBarVisible && explorerViewletVisible"
},
{
  "key": "f19",
  "command": "vscode-task.tasks.focus",
  "when": "!auxiliaryBarVisible || activeAuxiliary != 'workbench.views.service.auxiliarybar.e28be743-84fc-42c9-b993-c0e48cfbb426'"
},
{
  "key": "f19",
  "command": "workbench.action.toggleAuxiliaryBar",
  "when": "auxiliaryBarVisible && activeAuxiliary == 'workbench.views.service.auxiliarybar.e28be743-84fc-42c9-b993-c0e48cfbb426'"
}
```

Add these four objects inside VS Code's user `keybindings.json` array. The
Tasks `activeAuxiliary` ID reflects this machine's placement of that extension
view in the secondary sidebar; on another setup, replace it with the value
shown by **Developer: Inspect Context Keys** while the Tasks view is active.
The `task.vscode-task` extension must be installed. These shortcuts do not
depend on any personal F1/F3 mappings.

Top-middle single click (Ctrl + Alt + Shift + F4) opens or focuses the main
Copilot Chat view in the VS Code window under the pointer with **Chat: Open
Chat** via the Command Palette. With the pointer outside VS Code, it still
shows the placeholder dialog.
Top-middle double click (Ctrl + Alt + Shift + F5) finds an open Microsoft
Teams window (new or classic Teams), activates it, and sends Ctrl + Shift + M
to toggle microphone mute during a Teams meeting, regardless of pointer
position. It leaves Teams in front.
If no Teams window is open or it cannot be activated, it shows a message
instead of sending the shortcut to another app. Teams is not launched
automatically.
Top-middle hold (Ctrl + Alt + Shift + F6) runs **Chat: Move Chat into New
Window** in the hovered VS Code window to move the last-focused panel Chat
conversation into a separate window. Open the Chat view (for example, with
top-middle single click) before using it; if there is no panel Chat session to
move, VS Code may open a new Chat session in the window instead. With the
pointer outside VS Code, it shows the placeholder dialog. This command uses
the English Command Palette label and the default Ctrl + Shift + P shortcut.

Right Side 1 single click (Ctrl + Alt + Shift + I) sends Ctrl + C to copy in
the window under the pointer. Right Side 2 single click
(Ctrl + Alt + Shift + J) sends Ctrl + V to paste there. Both first activate
the hovered window; they do not click or select whatever is under the pointer,
so the app's existing keyboard focus and selection determine what is copied
or where text is pasted. Right Side 1 double click
(Ctrl + Alt + Shift + O) copies the relative path of the selected Explorer
file or active editor file **when the pointer is over VS Code**; otherwise it
still shows the placeholder dialog. It activates that VS Code window, opens
its Command Palette (Ctrl + Shift + P), and runs **Copy Relative Path**; no custom VS Code
keybinding is needed. This uses the English command name and assumes VS Code's
default Command Palette shortcut is available.

Turning the dial left (F14) zooms **out** when the pointer is over VS Code or
Windows Terminal; turning it right (F16) zooms **in**. The script identifies
the app under the pointer without changing focus, then activates it only for
zoom. VS Code zooms its entire interface (Ctrl + = / Ctrl + -), while Windows
Terminal changes terminal font size (Ctrl + Numpad+ / Ctrl + Numpad-). When the
pointer is over any other window (including Teams), a left turn lowers Windows
system volume and a right turn raises it using Windows volume keys, without
changing the focused window. These keys also display the volume overlay.
Hold-and-turn actions are still placeholders. The unmodified F13-F17 mapping
avoids the overlapping modifier sequences and stray printable number keys
observed during rapid turns.

App-specific actions capture the window under the pointer when the device
shortcut fires, then wait for its keys to be released before activating the
target and sending keys. They do not click the pointed-at item. If activation
fails, the action is not sent to the previously focused window. Desktop
switching and Teams mute do not use the hovered window.

The repeated Left Side 1 mapping in the original design is listed once here.
Other device controls are not mapped yet. These are ordinary Windows
shortcuts, so pressing the same combinations on another keyboard also
triggers the script; the script does not identify the originating device.
