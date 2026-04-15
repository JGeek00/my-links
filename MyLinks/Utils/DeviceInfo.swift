import Foundation
#if canImport(UIKit)
import UIKit
#endif

@MainActor
func getDeviceInfo() -> String {
    #if os(iOS)
    
    var systemInfo = utsname()
    uname(&systemInfo)
    let modelCode = withUnsafePointer(to: &systemInfo.machine) {
        $0.withMemoryRebound(to: CChar.self, capacity: 1) {
            String(validatingCString: $0)
        }
    }
    let device = modelCode ?? "Unknown"

    let osVersion = UIDevice.current.systemVersion
    
    return "\(device) - iOS \(osVersion)"
    
    #elseif os(macOS)
    
    var size: size_t = 0
    sysctlbyname("hw.model", nil, &size, nil, 0)
    var model = [CChar](repeating: 0, count: Int(size))
    sysctlbyname("hw.model", &model, &size, nil, 0)
    let device = String(cString: model)
    
    let osVersion = ProcessInfo.processInfo.operatingSystemVersion
    
    return "\(device) - macOS \(osVersion.majorVersion).\(osVersion.minorVersion).\(osVersion.patchVersion)"
    
    #endif
}
