#Requires AutoHotkey v2.0
#SingleInstance Force

InstallKeybdHook()

; Keep control, gesture, hotkey, and action columns aligned when editing bindings.
; A missing action uses the default dialog.
DeviceBindings := Map(
    "Top left",     Map(
        "single click",        {hotkey: "^!+F1",   action: SendVSCodeViewToggle, shortcut: "{F18}"},
        "double click",        {hotkey: "^!+F2",   action: SwitchDesktop,        direction: "Left"},
        "hold",                {hotkey: "^!+F3"}
    ),
    "Top middle",   Map(
        "single click",        {hotkey: "^!+F4",   action: RunVSCodeCommand,     command: "Chat: Open Chat"},
        "double click",        {hotkey: "^!+F5",   action: ToggleTeamsMute},
        "hold",                {hotkey: "^!+F6",   action: RunVSCodeCommand,     command: "Chat: Move Chat into New Window"}
    ),
    "Top right",    Map(
        "single click",        {hotkey: "^!+F7",   action: SendVSCodeViewToggle, shortcut: "{F19}"},
        "double click",        {hotkey: "^!+F8",   action: SwitchDesktop,        direction: "Right"},
        "hold",                {hotkey: "^!+F9"}
    ),
    "Left side 1",  Map(
        "single click",        {hotkey: "^!+q"},
        "double click",        {hotkey: "^!+w"},
        "hold",                {hotkey: "^!+e"}
    ),
    "Left side 2",  Map(
        "single click",        {hotkey: "^!+a"},
        "double click",        {hotkey: "^!+s"},
        "hold",                {hotkey: "^!+d"}
    ),
    "Right side 1", Map(
        "single click",        {hotkey: "^!+i",    action: SendShortcut,         shortcut: "^c"},
        "double click",        {hotkey: "^!+o",    action: RunVSCodeCommand,     command: "Copy Relative Path"},
        "hold",                {hotkey: "^!+p"}
    ),
    "Right side 2", Map(
        "single click",        {hotkey: "^!+j",    action: SendShortcut,         shortcut: "^v"},
        "double click",        {hotkey: "^!+k"},
        "hold",                {hotkey: "^!+l"}
    ),
    "Middle dial",  Map(
        "hold and turn left",  {hotkey: "F13"},
        "turn left",           {hotkey: "F14",     action: HandleDialTurn,       direction: "left"},
        "click",               {hotkey: "F15"},
        "turn right",          {hotkey: "F16",     action: HandleDialTurn,       direction: "right"},
        "hold and turn right", {hotkey: "F17"}
    )
)

for button, gestures in DeviceBindings {
    for gesture, binding in gestures {
        binding.button := button
        binding.gesture := gesture
        ; KeyWait needs the unmodified trigger key, not the full button hotkey.
        binding.triggerKey := SubStr(binding.hotkey, 1, 3) = "^!+" ? SubStr(binding.hotkey, 4) : binding.hotkey
        Hotkey(binding.hotkey, HandleDeviceHotkey.Bind(binding))
    }
}

HandleDeviceHotkey(binding, *) {
    WaitForDeviceShortcutRelease(binding.triggerKey)
    if binding.HasOwnProp("action")
        binding.action.Call(binding)
    else
        ShowKeyPress(binding)
}

SwitchDesktop(binding) {
    SendInput("#^{" binding.direction "}")
}

SendShortcut(binding) {
    SendInput(binding.shortcut)
}

SendVSCodeViewToggle(binding) {
    if IsVSCodeActive()
        SendInput(binding.shortcut)
    else
        ShowKeyPress(binding)
}

RunVSCodeCommand(binding) {
    if !IsVSCodeActive() {
        ShowKeyPress(binding)
        return
    }

    ; The palette preserves VS Code's editor/Explorer context for Copy Relative Path.
    SendInput("^+p")
    SendText(binding.command)
    SendInput("{Enter}")
}

HandleDialTurn(binding) {
    if IsVSCodeActive()
        SendInput(binding.direction = "left" ? "^-" : "^=")
    else if WinActive("ahk_exe WindowsTerminal.exe") || WinActive("ahk_exe WindowsTerminalPreview.exe")
        SendInput(binding.direction = "left" ? "^{NumpadSub}" : "^{NumpadAdd}")
    else
        SendInput(binding.direction = "left" ? "{Volume_Down}" : "{Volume_Up}")
}

IsVSCodeActive() {
    return WinActive("ahk_exe Code.exe") || WinActive("ahk_exe Code - Insiders.exe")
}

ToggleTeamsMute(binding) {
    ; "ahk_exe" is AutoHotkey's window filter for the owning process executable.
    ; WinExist finds a visible ms-teams.exe window and returns its HWND, or 0.
    teamsWindow := WinExist("ahk_exe ms-teams.exe")
    if !teamsWindow
        teamsWindow := WinExist("ahk_exe Teams.exe")
    if !teamsWindow {
        MsgBox("Microsoft Teams is not open; cannot toggle microphone mute.", "Ulanzi D100H")
        return
    }

    WinActivate("ahk_id " teamsWindow)
    if !WinWaitActive("ahk_id " teamsWindow, , 2) {
        MsgBox("Could not activate Microsoft Teams; microphone mute was not toggled.", "Ulanzi D100H")
        return
    }
    SendInput("^+m")
}

WaitForDeviceShortcutRelease(triggerKey) {
    ; Device-generated keys are injected, so wait for logical rather than physical release.
    KeyWait(triggerKey, "L")
    KeyWait("Control", "L")
    KeyWait("Alt", "L")
    KeyWait("Shift", "L")
}

ShowKeyPress(binding) {
    MsgBox("Ulanzi D100H: " binding.button " - " binding.gesture, "Ulanzi D100H")
}