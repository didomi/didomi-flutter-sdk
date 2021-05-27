import Flutter
import UIKit
import Didomi

public class SwiftDidomiSdkPlugin: NSObject, FlutterPlugin {

    /// Default message if SDK is not ready
    private static let didomiNotReadyException: String = "Didomi SDK is not ready. Use the onReady callback to access this method."
    
    static var eventStreamHandler: DidomiEventStreamHandler? = nil
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: Constants.methodsChannelName, binaryMessenger: registrar.messenger())
        let instance = SwiftDidomiSdkPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        
        let eventStreamHandler = DidomiEventStreamHandler()
        SwiftDidomiSdkPlugin.eventStreamHandler = eventStreamHandler
        Didomi.shared.addEventListener(listener: eventStreamHandler.eventListener)

        let eventChannel = FlutterEventChannel(name: Constants.eventsChannelName, binaryMessenger: registrar.messenger())
        eventChannel.setStreamHandler(eventStreamHandler)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch(call.method) {
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
        case "initialize":
            initialize(call, result: result)
        case "isReady":
            result(Didomi.shared.isReady())
        case "onReady":
            Didomi.shared.onReady {
                SwiftDidomiSdkPlugin.eventStreamHandler?.onReadyCallback()
            }
        case "onError":
            Didomi.shared.onError { _ in
                SwiftDidomiSdkPlugin.eventStreamHandler?.onErrorCallback()
            }
        case "shouldConsentBeCollected":
            result(Didomi.shared.shouldConsentBeCollected())
        case "isConsentRequired":
            result(Didomi.shared.isConsentRequired())
        case "isUserConsentStatusPartial":
            result(Didomi.shared.isUserConsentStatusPartial())
        case "isUserLegitimateInterestStatusPartial":
            result(Didomi.shared.isUserLegitimateInterestStatusPartial())
        case "reset":
            Didomi.shared.reset()
            result(nil)
        case "setupUI":
            setupUI(result: result)
        case "showNotice":
            Didomi.shared.showNotice()
            result(nil)
        case "hideNotice":
            Didomi.shared.hideNotice()
            result(nil)
        case "isNoticeVisible":
            result(Didomi.shared.isNoticeVisible())
        case "showPreferences":
            showPreferences(call, result: result)
        case "hidePreferences":
            Didomi.shared.hidePreferences()
            result(nil)
        case "isPreferencesVisible":
            result(Didomi.shared.isPreferencesVisible())
        case "getJavaScriptForWebView":
            result(Didomi.shared.getJavaScriptForWebView())
        case "updateSelectedLanguage":
            updateSelectedLanguage(call, result: result)
        case "getText":
            getText(call, result: result)
        case "getTranslatedText":
            getTranslatedText(call, result: result)
        case "getDisabledPurposeIds":
            getDisabledPurposeIds(result: result)
        case "getDisabledVendorIds":
            getDisabledVendorIds(result: result)
        case "getEnabledPurposeIds":
            getEnabledPurposeIds(result: result)
        case "getEnabledVendorIds":
            getEnabledVendorIds(result: result)
        case "getRequiredPurposeIds":
            getRequiredPurposeIds(result: result)
        case "getRequiredVendorIds":
            getRequiredVendorIds(result: result)
        case "setLogLevel":
            setLogLevel(call, result: result)
        case "setUserAgreeToAll":
            setUserAgreeToAll(result: result)
        case "setUserDisagreeToAll":
            setUserDisagreeToAll(result: result)
        case "getUserConsentStatusForPurpose":
            getUserConsentStatusForPurpose(call, result: result)
        case "getUserConsentStatusForVendor":
            getUserConsentStatusForVendor(call, result: result)
        case "getUserConsentStatusForVendorAndRequiredPurposes":
            getUserConsentStatusForVendorAndRequiredPurposes(call, result: result)
        case "getUserLegitimateInterestStatusForPurpose":
            getUserLegitimateInterestStatusForPurpose(call, result: result)
        case "getUserLegitimateInterestStatusForVendor":
            getUserLegitimateInterestStatusForVendor(call, result: result)
        case "getUserLegitimateInterestStatusForVendorAndRequiredPurposes":
            getUserLegitimateInterestStatusForVendorAndRequiredPurposes(call, result: result)
        case "getUserStatusForVendor":
            getUserStatusForVendor(call, result: result)
        case "setUserStatus":
            setUserStatus(call, result: result)
        case "setUser":
            setUser(call, result: result)
        case "setUserWithAuthentication":
            setUserWithAuthentication(call, result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    func initialize(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? Dictionary<String, Any> else {
            result(FlutterError.init(code: "invalid_args", message: "Wrong arguments for initialize", details: nil))
            return
        }
        guard let apiKey = args["apiKey"] as? String else {
            result(FlutterError.init(code: "invalid_args", message: "initialize: Missing argument apiKey", details: nil))
            return
        }
        guard let disableDidomiRemoteConfig = args["disableDidomiRemoteConfig"] as? Bool else {
            result(FlutterError.init(code: "invalid_args", message: "initialize: Missing argument disableDidomiRemoteConfig", details: nil))
            return
        }
        let didomi = Didomi.shared
        didomi.initialize(
            apiKey: apiKey,
            localConfigurationPath: args["localConfigurationPath"] as? String,
            remoteConfigurationURL: args["remoteConfigurationURL"] as? String,
            providerId: args["providerId"] as? String,
            disableDidomiRemoteConfig: disableDidomiRemoteConfig,
            languageCode: args["languageCode"] as? String,
            noticeId: args["noticeId"] as? String)
        result(nil)
    }
    
    func setupUI(result: @escaping FlutterResult) {
        let viewController: UIViewController =
            (UIApplication.shared.delegate?.window??.rootViewController)!
        Didomi.shared.setupUI(containerController: viewController)
        result(nil)
    }
    
    func showPreferences(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let viewController: UIViewController =
            (UIApplication.shared.delegate?.window??.rootViewController)!
        guard let args = call.arguments as? Dictionary<String, Any> else {
            result(FlutterError.init(code: "invalid_args", message: "Wrong arguments for initialize", details: nil))
            return
        }
        let view: Didomi.Views
        if let viewArgument = args["view"] as? String, viewArgument == "vendors" {
            view = .vendors
        } else {
            view = .purposes
        }
        Didomi.shared.showPreferences(controller: viewController, view: view)
        result(nil)
    }
    
    func updateSelectedLanguage(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? Dictionary<String, Any> else {
            result(FlutterError.init(code: "invalid_args", message: "Wrong arguments for updateSelectedLanguage", details: nil))
            return
        }
        guard let languageCode = args["languageCode"] as? String else {
            result(FlutterError.init(code: "invalid_args", message: "updateSelectedLanguage: Missing argument languageCode", details: nil))
            return
        }
        Didomi.shared.updateSelectedLanguage(languageCode: languageCode)
        result(nil)
    }
    
    func getText(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? Dictionary<String, Any> else {
            result(FlutterError.init(code: "invalid_args", message: "Wrong arguments for getText", details: nil))
            return
        }
        guard let key = args["key"] as? String else {
            result(FlutterError.init(code: "invalid_args", message: "getText: Missing argument key", details: nil))
            return
        }
        result(Didomi.shared.getText(key: key))
    }
    
    func getTranslatedText(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? Dictionary<String, Any> else {
            result(FlutterError.init(code: "invalid_args", message: "Wrong arguments for getTranslatedText", details: nil))
            return
        }
        guard let key = args["key"] as? String else {
            result(FlutterError.init(code: "invalid_args", message: "getTranslatedText: Missing argument key", details: nil))
            return
        }
        result(Didomi.shared.getTranslatedText(key: key))
    }
        
    /**
     * Get the disabled purpose IDs
     - Returns: Array of purpose ids
     */
    func getDisabledPurposeIds(result: @escaping FlutterResult) {
        if !Didomi.shared.isReady() {
            result(FlutterError.init(code: "sdk_not_ready", message: SwiftDidomiSdkPlugin.didomiNotReadyException, details: nil))
            return
        }
        let purposeIdList = Array(Didomi.shared.getDisabledPurposeIds())
        result(purposeIdList)
    }

    /**
     * Get the disabled vendor IDs
     - Returns: Array of vendor ids
     */
    func getDisabledVendorIds(result: @escaping FlutterResult) {
        if !Didomi.shared.isReady() {
            result(FlutterError.init(code: "sdk_not_ready", message: SwiftDidomiSdkPlugin.didomiNotReadyException, details: nil))
            return
        }
        let vendorIdList = Array(Didomi.shared.getDisabledVendorIds())
        result(vendorIdList)
    }

    /**
     * Get the enabled purpose IDs
     - Returns: Array of purpose ids
     */
    func getEnabledPurposeIds(result: @escaping FlutterResult) {
        if !Didomi.shared.isReady() {
            result(FlutterError.init(code: "sdk_not_ready", message: SwiftDidomiSdkPlugin.didomiNotReadyException, details: nil))
            return
        }
        let purposeIdList = Array(Didomi.shared.getEnabledPurposeIds())
        result(purposeIdList)
    }

    /**
     * Get the enabled vendor IDs
     - Returns: Array of vendor ids
     */
    func getEnabledVendorIds(result: @escaping FlutterResult) {
        if !Didomi.shared.isReady() {
            result(FlutterError.init(code: "sdk_not_ready", message: SwiftDidomiSdkPlugin.didomiNotReadyException, details: nil))
            return
        }
        let vendorIdList = Array(Didomi.shared.getEnabledVendorIds())
        result(vendorIdList)
    }

    /**
     * Get the required purpose IDs
     - Returns: Array of purpose ids
     */
    func getRequiredPurposeIds(result: @escaping FlutterResult) {
        if !Didomi.shared.isReady() {
            result(FlutterError.init(code: "sdk_not_ready", message: SwiftDidomiSdkPlugin.didomiNotReadyException, details: nil))
            return
        }
        let purposeIdList = Array(Didomi.shared.getRequiredPurposeIds())
        result(purposeIdList)
    }

    /**
     * Get the required vendor IDs
     - Returns: Array of vendor ids
     */
    func getRequiredVendorIds(result: @escaping FlutterResult) {
        if !Didomi.shared.isReady() {
            result(FlutterError.init(code: "sdk_not_ready", message: SwiftDidomiSdkPlugin.didomiNotReadyException, details: nil))
            return
        }
        let vendorIdList = Array(Didomi.shared.getRequiredVendorIds())
        result(vendorIdList)
    }

    /**
     Set the minimum level of messages to log

     Messages with a level below `minLevel` will not be logged.
     Levels are standard levels from `OSLogType` (https://developer.apple.com/documentation/os/logging/choosing_the_log_level_for_a_message):
      - OSLogType.info (1)
      - OSLogType.debug (2)
      - OSLogType.error (16)
      - OSLogType.fault (17)

     We recommend setting `OSLogType.error` (16) in production
     */
    func setLogLevel(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? Dictionary<String, UInt8> else {
                result(FlutterError.init(code: "invalid_args", message: "Wrong arguments for setLogLevel", details: nil))
                return
            }
        Didomi.shared.setLogLevel(minLevel: args["minLevel"] ?? 1)
        result(nil)
    }

    /**
     Method that allows to enable consent and legitimate interest for all the required purposes.
     - Returns: **true** if consent status has been updated, **false** otherwise.
     */
    func setUserAgreeToAll(result: @escaping FlutterResult) {
        if !Didomi.shared.isReady() {
            result(FlutterError.init(code: "sdk_not_ready", message: SwiftDidomiSdkPlugin.didomiNotReadyException, details: nil))
            return
        }
        result(Didomi.shared.setUserAgreeToAll())
    }

    /**
     Method that allows to disable consent and legitimate interest for all the required purposes and vendors.
     - Returns: **true** if consent status has been updated, **false** otherwise.
     */
    func setUserDisagreeToAll(result: @escaping FlutterResult) {
        if !Didomi.shared.isReady() {
            result(FlutterError.init(code: "sdk_not_ready", message: SwiftDidomiSdkPlugin.didomiNotReadyException, details: nil))
            return
        }
        result(Didomi.shared.setUserDisagreeToAll())
    }

    /**
     Get the user consent status for a specific purpose
     - Parameter purposeId: The purpose ID to check consent for
     - Returns: The user consent status for the specified purpose
     */
    func getUserConsentStatusForPurpose(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if !Didomi.shared.isReady() {
            result(FlutterError.init(code: "sdk_not_ready", message: SwiftDidomiSdkPlugin.didomiNotReadyException, details: nil))
            return
        }
        guard let args = call.arguments as? Dictionary<String, String> else {
                result(FlutterError.init(code: "invalid_args", message: "Wrong arguments for getUserConsentStatusForPurpose", details: nil))
                return
            }

        let purposeId = args["purposeId"] ?? ""
        if purposeId.isEmpty {
            result(FlutterError.init(code: "invalid_args", message: "Missing purposeId argument for getUserConsentStatusForPurpose", details: nil))
            return
        }

        let consentStatusForPurpose = Didomi.shared.getUserConsentStatusForPurpose(purposeId: purposeId)
        switch consentStatusForPurpose {
        case .disable:
          result(0)
        case .enable:
          result(1)
        default:
          result(2)
        }
    }

    /**
     Get the user consent status for a specific vendor
     - Parameter vendorId: The vendor ID to check consent for
     - Returns: The user consent status for the specified vendor
     */
    func getUserConsentStatusForVendor(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if !Didomi.shared.isReady() {
            result(FlutterError.init(code: "sdk_not_ready", message: SwiftDidomiSdkPlugin.didomiNotReadyException, details: nil))
            return
        }
        guard let args = call.arguments as? Dictionary<String, String> else {
                result(FlutterError.init(code: "invalid_args", message: "Wrong arguments for getUserStatusForVendor", details: nil))
                return
            }

        let vendorId = args["vendorId"] ?? ""
        if vendorId.isEmpty {
            result(FlutterError.init(code: "invalid_args", message: "Missing vendorId argument for getUserStatusForVendor", details: nil))
            return
        }

        let consentStatusForVendor = Didomi.shared.getUserConsentStatusForVendor(vendorId: vendorId)
        switch consentStatusForVendor {
        case .disable:
          result(0)
        case .enable:
          result(1)
        default:
          result(2)
        }
    }

    /**
     Get the user consent status for a specific vendor and all its purposes
     - Parameter vendorId: The ID of the vendor
     - Returns: The user consent status corresponding to the specified vendor and all its required purposes
     */
    func getUserConsentStatusForVendorAndRequiredPurposes(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if !Didomi.shared.isReady() {
            result(FlutterError.init(code: "sdk_not_ready", message: SwiftDidomiSdkPlugin.didomiNotReadyException, details: nil))
            return
        }
        guard let args = call.arguments as? Dictionary<String, String> else {
                result(FlutterError.init(code: "invalid_args", message: "Wrong arguments for getUserConsentStatusForVendorAndRequiredPurposes", details: nil))
                return
            }

        let vendorId = args["vendorId"] ?? ""
        if vendorId.isEmpty {
            result(FlutterError.init(code: "invalid_args", message: "Missing vendorId argument for getUserConsentStatusForVendorAndRequiredPurposes", details: nil))
            return
        }

        let consentStatusForVendor = Didomi.shared.getUserConsentStatusForVendorAndRequiredPurposes(vendorId: vendorId)
        switch consentStatusForVendor {
        case .disable:
          result(0)
        case .enable:
          result(1)
        default:
          result(2)
        }
    }
    
    /**
     Get the user legitimate interest status for a specific purpose
     - Parameter purposeId: The purpose ID to check consent for
     - Returns: The user legitimate interest status for the specified purpose
     */
    func getUserLegitimateInterestStatusForPurpose(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if !Didomi.shared.isReady() {
            result(FlutterError.init(code: "sdk_not_ready", message: SwiftDidomiSdkPlugin.didomiNotReadyException, details: nil))
            return
        }
        guard let args = call.arguments as? Dictionary<String, String> else {
                result(FlutterError.init(code: "invalid_args", message: "Wrong arguments for getUserLegitimateInterestStatusForPurpose", details: nil))
                return
            }

        let purposeId = args["purposeId"] ?? ""
        if purposeId.isEmpty {
            result(FlutterError.init(code: "invalid_args", message: "Missing purposeId argument for getUserLegitimateInterestStatusForPurpose", details: nil))
            return
        }

        let legitimateInterestStatusForPurpose = Didomi.shared.getUserLegitimateInterestStatusForPurpose(purposeId: purposeId)
        switch legitimateInterestStatusForPurpose {
        case .disable:
          result(0)
        case .enable:
          result(1)
        default:
          result(2)
        }
    }

    /**
     Get the user legitimate interest status for a specific vendor
     - Parameter vendorId: The vendor ID to check consent for
     - Returns: The user consent status for the specified vendor
     */
    func getUserLegitimateInterestStatusForVendor(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if !Didomi.shared.isReady() {
            result(FlutterError.init(code: "sdk_not_ready", message: SwiftDidomiSdkPlugin.didomiNotReadyException, details: nil))
            return
        }
        guard let args = call.arguments as? Dictionary<String, String> else {
                result(FlutterError.init(code: "invalid_args", message: "Wrong arguments for getUserLegitimateInterestStatusForVendor", details: nil))
                return
            }

        let vendorId = args["vendorId"] ?? ""
        if vendorId.isEmpty {
            result(FlutterError.init(code: "invalid_args", message: "Missing vendorId argument for getUserLegitimateInterestStatusForVendor", details: nil))
            return
        }

        let legitimateInterestStatusForVendor = Didomi.shared.getUserLegitimateInterestStatusForVendor(vendorId: vendorId)
        switch legitimateInterestStatusForVendor {
        case .disable:
          result(0)
        case .enable:
          result(1)
        default:
          result(2)
        }
    }
    
    /**
     Get the user status (consent and legitimate interest) for a specific vendor
     - Parameter vendorId: The vendor ID to check consent for
     - Returns: The user status for the specified vendor
     */
    func getUserStatusForVendor(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if !Didomi.shared.isReady() {
            result(FlutterError.init(code: "sdk_not_ready", message: SwiftDidomiSdkPlugin.didomiNotReadyException, details: nil))
            return
        }
        guard let args = call.arguments as? Dictionary<String, String> else {
                result(FlutterError.init(code: "invalid_args", message: "Wrong arguments for getUserStatusForVendor", details: nil))
                return
            }

        let vendorId = args["vendorId"] ?? ""
        if vendorId.isEmpty {
            result(FlutterError.init(code: "invalid_args", message: "Missing vendorId argument for getUserStatusForVendor", details: nil))
            return
        }

        let statusForVendor = Didomi.shared.getUserStatusForVendor(vendorId: vendorId)
        switch statusForVendor {
        case .disable:
          result(0)
        case .enable:
          result(1)
        default:
          result(2)
        }
    }

    /**
     Get the user legitimate interest status for a specific vendor and all its purposes
     - Parameter vendorId: The ID of the vendor
     - Returns: The user legitimate interest status corresponding to the specified vendor and all its required purposes
     */
    func getUserLegitimateInterestStatusForVendorAndRequiredPurposes(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if !Didomi.shared.isReady() {
            result(FlutterError.init(code: "sdk_not_ready", message: SwiftDidomiSdkPlugin.didomiNotReadyException, details: nil))
            return
        }
        guard let args = call.arguments as? Dictionary<String, String> else {
                result(FlutterError.init(code: "invalid_args", message: "Wrong arguments for getUserLegitimateInterestStatusForVendorAndRequiredPurposes", details: nil))
                return
            }

        let vendorId = args["vendorId"] ?? ""
        if vendorId.isEmpty {
            result(FlutterError.init(code: "invalid_args", message: "Missing vendorId argument for getUserLegitimateInterestStatusForVendorAndRequiredPurposes", details: nil))
            return
        }

        let legitimateInterestStatusForVendor = Didomi.shared.getUserLegitimateInterestStatusForVendorAndRequiredPurposes(vendorId: vendorId)
        switch legitimateInterestStatusForVendor {
        case .disable:
          result(0)
        case .enable:
          result(1)
        default:
          result(2)
        }
    }

    /**
     Set the user status for purposes and vendors for consent and legitimate interest.
     - Parameters purposesConsentStatus: boolean used to determine if consent will be enabled or disabled for all purposes.
     - Parameters purposesLIStatus: boolean used to determine if legitimate interest will be enabled or disabled for all purposes.
     - Parameters vendorsConsentStatus: boolean used to determine if consent will be enabled or disabled for all vendors.
     - Parameters vendorsLIStatus: boolean used to determine if legitimate interest will be enabled or disabled for all vendors.
     - Returns: **true** if consent status has been updated, **false** otherwise.
     */
    func setUserStatus(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if !Didomi.shared.isReady() {
            result(FlutterError.init(code: "sdk_not_ready", message: SwiftDidomiSdkPlugin.didomiNotReadyException, details: nil))
            return
        }
        guard let args = call.arguments as? Dictionary<String, Bool> else {
                result(FlutterError.init(code: "invalid_args", message: "Wrong arguments for setUserStatus", details: nil))
                return
            }

        result(Didomi.shared.setUserStatus(
            purposesConsentStatus: args["purposesConsentStatus"] ?? false,
            purposesLIStatus: args["purposesLIStatus"] ?? false,
            vendorsConsentStatus: args["vendorsConsentStatus"] ?? false,
            vendorsLIStatus: args["vendorsLIStatus"] ?? false
        ))
    }
    
    func setUser(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? Dictionary<String, Any> else {
                result(FlutterError.init(code: "invalid_args", message: "Wrong arguments for setUser", details: nil))
                return
            }

        guard let userId = argumentOrError(argumentName: "organizationUserId", methodName: "setUser", args: args, result: result) else {
            return
        }
        Didomi.shared.setUser(id: userId)
        result(nil)
    }
    
    func setUserWithAuthentication(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? Dictionary<String, Any> else {
                result(FlutterError.init(code: "invalid_args", message: "Wrong arguments for setUserWithAuthentication", details: nil))
                return
            }

        guard let userId = argumentOrError(argumentName: "organizationUserId", methodName: "setUserWithAuthentication", args: args, result: result) else {
            return
        }
        guard let organizationUserIdAuthAlgorithm = argumentOrError(argumentName: "organizationUserIdAuthAlgorithm", methodName: "setUserWithAuthentication", args: args, result: result) else {
            return
        }
        guard let organizationUserIdAuthSid = argumentOrError(argumentName: "organizationUserIdAuthSid", methodName: "setUserWithAuthentication", args: args, result: result) else {
            return
        }
        guard let organizationUserIdAuthDigest = argumentOrError(argumentName: "organizationUserIdAuthDigest", methodName: "setUserWithAuthentication", args: args, result: result) else {
            return
        }
        Didomi.shared.setUser(
            id: userId,
            algorithm: organizationUserIdAuthAlgorithm,
            secretId: organizationUserIdAuthSid,
            salt: args["organizationUserIdAuthSalt"] as? String,
            digest: organizationUserIdAuthDigest)
        result(nil)
    }
    
    /// Return the requested argument as non-empty String, or raise an error in result and return null
    private func argumentOrError(argumentName: String, methodName: String, args: Dictionary<String, Any>, result: FlutterResult) -> String? {
        let argument = args[argumentName] as? String ?? ""
        if argument.isEmpty {
            result(FlutterError.init(code: "invalid_args", message: "Missing \(argumentName) argument for \(methodName)", details: nil))
            return nil
        }
        return argument
    }
}
