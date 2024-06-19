import Foundation

class Regexps {
    public static let ipAddress = #"^((25[0-5]|(2[0-4]|1\d|[1-9]|)\d)(\.(?!$)|$)){4}$"#
    public static let domain =  #"^(([a-z0-9|-]+\.)*[a-z0-9|-]+\.[a-z]+)$"#
    public static let path = #"^\/\b([A-Za-z0-9_\-~/]*)[^\/|\.|\:]$"#
    public static let url = #"https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)"#
}
