func fromPermissionsToRole(canCreate: Bool, canUpdate: Bool, canDelete: Bool) -> Enums.MemberRole {
    if canDelete == true {
        return .admin
    }
    if canCreate == true && canUpdate == false {
        return .contributor
    }
    return .viewer
}

func fromRoleToPermissions(role: Enums.MemberRole) -> (canCreate: Bool, canUpdate: Bool, canDelete: Bool) {
    switch role {
    case .admin:
        return (true, true, true)
    case .contributor:
        return (true, false, false)
    case .viewer:
        return (false, false, false)
    }
}
