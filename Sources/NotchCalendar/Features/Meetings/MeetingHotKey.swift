import Carbon
import Foundation

@MainActor
protocol MeetingHotKeyRegistering: AnyObject {
    func register(letter: String, modifiers: MeetingHotKeyModifiers, action: @escaping @MainActor () -> Void) -> Bool
    func unregister()
}

/// Carbon's public hot-key registration does not require Accessibility access.
@MainActor
final class MeetingHotKey: MeetingHotKeyRegistering {
    private var hotKey: EventHotKeyRef?
    private var handler: EventHandlerRef?
    private var action: (@MainActor () -> Void)?
    private static let signature: OSType = 0x4E434D4A // NCMJ

    func register(letter: String, modifiers: MeetingHotKeyModifiers, action: @escaping @MainActor () -> Void) -> Bool {
        unregister()
        guard let keyCode = Self.keyCodes[letter] else { return false }
        self.action = action
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        let installed = InstallEventHandler(GetApplicationEventTarget(), { _, event, userData in
            guard let event, let userData else { return OSStatus(eventNotHandledErr) }
            var identifier = EventHotKeyID()
            let result = GetEventParameter(event, EventParamName(kEventParamDirectObject), EventParamType(typeEventHotKeyID),
                                           nil, MemoryLayout<EventHotKeyID>.size, nil, &identifier)
            guard result == noErr, identifier.signature == 0x4E434D4A, identifier.id == 1 else {
                return OSStatus(eventNotHandledErr)
            }
            let owner = Unmanaged<MeetingHotKey>.fromOpaque(userData).takeUnretainedValue()
            Task { @MainActor [weak owner] in owner?.action?() }
            return noErr
        }, 1, &eventType, Unmanaged.passUnretained(self).toOpaque(), &handler)
        guard installed == noErr else { unregister(); return false }
        let identifier = EventHotKeyID(signature: Self.signature, id: 1)
        // Exclusive registration turns collisions with other apps into a visible
        // failure instead of allowing both apps to handle the same shortcut.
        let registered = RegisterEventHotKey(keyCode, Self.carbonModifiers(modifiers), identifier,
                                            GetApplicationEventTarget(), OptionBits(kEventHotKeyExclusive), &hotKey)
        guard registered == noErr else { unregister(); return false }
        return true
    }

    func unregister() {
        if let hotKey { UnregisterEventHotKey(hotKey) }
        if let handler { RemoveEventHandler(handler) }
        hotKey = nil
        handler = nil
        action = nil
    }

    private static func carbonModifiers(_ value: MeetingHotKeyModifiers) -> UInt32 {
        switch value {
        case .controlOption: UInt32(controlKey | optionKey)
        case .commandShift: UInt32(cmdKey | shiftKey)
        case .commandOption: UInt32(cmdKey | optionKey)
        case .controlCommand: UInt32(controlKey | cmdKey)
        }
    }

    private static let keyCodes: [String: UInt32] = [
        "A": 0, "B": 11, "C": 8, "D": 2, "E": 14, "F": 3, "G": 5, "H": 4, "I": 34,
        "J": 38, "K": 40, "L": 37, "M": 46, "N": 45, "O": 31, "P": 35, "Q": 12,
        "R": 15, "S": 1, "T": 17, "U": 32, "V": 9, "W": 13, "X": 7, "Y": 16, "Z": 6
    ]
}
