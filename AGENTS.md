# Repository context

- The Ulanzi D100H is a configurable hardware shortcut controller. In this
  project its buttons send Windows keyboard shortcuts for single click, double
  click, and hold; the middle round dial sends shortcuts for click, turns, and
  hold-and-turn actions.
- This repository contains the host-side AutoHotkey v2 script for Windows.
  The device decides which shortcut to send; the script implements the
  corresponding action. It does not read the device directly or distinguish
  its shortcuts from those typed on another keyboard.
- `README.md` documents each Ulanzi control and gesture, full Windows hotkey,
  and action. `DeviceBindings` in `ulanzi-d100h-autohotkey.ahk` groups by
  control, then gesture, with a `hotkey` field and optional action function.
  Button shortcuts start with Ctrl + Alt + Shift; the five dial gestures send
  bare F13-F17. Keep both synchronized when changing a binding.
- Most handlers display a dialog identifying the control and action. Top-left
  and top-right double clicks instead switch Windows virtual desktops left and
  right after the triggering shortcut's keys are released. Their single
  clicks run VS Code view commands only when VS Code is active. Top-middle
  single click opens the main VS Code Copilot Chat view, while double click
  activates an existing Microsoft Teams window and sends Ctrl + Shift + M to
  toggle microphone mute, leaving Teams in front; it does not launch Teams.
  Top-middle hold moves the last-focused panel Chat session into a new
  window in VS Code (F6).
  Replace other placeholders with real actions as requested, retaining clear
  labels for the physical control and action.
- Do not assume other device controls have bindings in this project.

## Device-generated key events

- The D100H emits injected/artificial keyboard events. In AutoHotkey's Key
  history they appear with type `a`, while keys sent by this script appear as
  `i`. An ordinary keyboard is not an equivalent test for device behavior.
- When a handler sends a new shortcut, release of the device's triggering key
  and Ctrl + Alt + Shift matters. With the keyboard hook installed, the
  default `KeyWait()` checks physical state and can return immediately for
  injected keys even while their logical modifiers remain down. Use
  `KeyWait(key, "L")` for the triggering key and each modifier, as
  `WaitForDeviceShortcutRelease()` does, before sending another
  modifier-based shortcut. The shared hotkey dispatcher binds each map entry
  (including its triggering key) and waits before calling its action function
  or showing the default dialog. Keep this wait in the shared dispatcher
  rather than hardcoding a key inside individual actions.
- Sending Win + Ctrl + Arrow before the D100H releases its modifiers switched
  desktops **and** unexpectedly opened Windows Copilot. Changing `Send` to
  `SendInput` alone did not fix it; waiting for logical key-up events did.
  Avoid globally suppressing Copilot shortcuts to mask this timing problem.
- After editing the script, reload it in AutoHotkey and test the actual D100H
  buttons in both directions. For input diagnostics, the script installs the
  keyboard hook; use the AutoHotkey tray icon's Open window, View > Key history
  and script info, then F5 after reproducing the action.
- `DeviceBindings` is keyed by physical control, then gesture. Each gesture's
  `hotkey` is the full AutoHotkey shortcut (for example `^!+F4` for a button,
  `F14` for a bare dial turn). Registration uses that hotkey directly and
  derives its unmodified `triggerKey` for the logical-release wait. Each
  binding record goes to the common handler. Add a function object in its
  `action` field for a custom action; otherwise the handler shows the usual
  dialog. Action functions accept the binding record containing `hotkey`,
  `triggerKey`, `button`, and `gesture`; existing actions may also use fields
  such as `direction`. When editing the map, preserve the visual alignment of
  control names, gesture keys, `hotkey` values, and `action` fields so the
  device-to-shortcut-to-implementation flow remains easy to scan.
- Right Side 1/2 single clicks send Ctrl+C/Ctrl+V to the active app. Right Side
  1 double click uses VS Code's Command Palette to run Copy Relative Path
  only while VS Code is active; otherwise it keeps the placeholder dialog.
- Top-left/top-right singles send F18/F19 only while VS Code is active;
  otherwise they keep the default dialogs. Four VS Code user keybindings in
  `README.md` use `when` conditions to toggle Explorer/Tasks in sync with
  VS Code's actual view state. AutoHotkey cannot read VS Code's `when` keys
  outside the IDE. The Tasks view needs the `task.vscode-task` extension and
  its active secondary-sidebar container ID can differ between machines.
  Install those four bindings on each machine; do not depend on the user's
  personal F1/F3 shortcuts. Both toggles and their behavior after manual view
  changes were verified on the physical device.
- The Copy Relative Path palette command was checked with both a focused
  Explorer file and an active editor file. Do not depend on the user's custom
  Ctrl+Shift+C binding. Top-middle single click also uses the palette command
  `Chat: Open Chat` to show the main Copilot Chat view in VS Code; double click
  instead uses the global Teams mute action. Top-middle hold uses
  `Chat: Move Chat into New Window` (`workbench.action.chat.openInNewWindow`);
  on the installed VS Code version it moves the last-focused panel Chat
  session, but opens a new session if no panel Chat session is available.
  Open Chat first when the intent is to move the current conversation.
  The palette route assumes an English VS Code UI and the default Ctrl+Shift+P
  palette shortcut.
- The five dial gestures send bare F13 through F17 in order; plain turns
  use `F14` for zoom out (left) and `F16` for zoom in (right)
  when VS Code or Windows Terminal is active. VS Code uses Ctrl+= / Ctrl+-
  for whole-interface zoom; Windows Terminal uses Ctrl+Numpad+ /
  Ctrl+Numpad- for font-size zoom. With neither app active, left and right
  send Volume_Down / Volume_Up to adjust system volume with the Windows
  overlay. The earlier Ctrl+Alt+Shift+2/4 mapping emitted stray printable
  digits during rapid turns, and Ctrl+Alt+Shift+F13-F17 still triggered app
  shortcuts as modifiers overlapped. With bare F13-F17, the media-key sends
  show the Windows volume overlay without unintended app actions even during
  rapid turns; this was verified on the physical device.
  Hold-and-turn gestures remain separate.

## Maintaining long-term context

- Before finishing a task, update this file with any newly verified
  device-specific behavior, AutoHotkey/Windows interaction, non-obvious
  failure mode, or validation step that future changes depend on. Do not
  assume future agents can see the conversation that uncovered it.
- Record the relevant trigger, symptom, cause (if established), working
  approach, and how it was verified. Distinguish observations from
  hypotheses; do not present untested workarounds as known fixes.
- Keep these notes concise and current: amend or replace stale guidance
  rather than accumulating a chronological debugging log. Keep user-facing
  shortcut mappings in `README.md` and implementation details aligned with
  the script.
- When the user asks why code works a certain way, explain it in the reply
  and, by default, add a concise comment beside the confusing code to
  preserve the explanation for future readers. Focus on non-obvious intent
  or behavior, not a restatement of the code; do not alter its behavior
  merely to add the comment.
