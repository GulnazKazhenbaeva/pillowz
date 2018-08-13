
import UIKit

struct Constants {
    static let isTesting = true
    
    static let prodURL = "https://api.pillowz.kz/"
    static let testURL = "http://devapi.pillowz.kz/"
    static let baseURL = (isTesting) ? testURL : prodURL
    
    static let testOneSignalKey = "34bfdc23-9472-40c0-8ba3-32192b540b4a"
    static let prodOneSignalKey = "8bbbfcfc-7860-470b-b8d7-fd3773f8eabf"
    static let oneSignalKey = (isTesting) ? testOneSignalKey : prodOneSignalKey
    
    static let baseAPIURL = Constants.baseURL+"api/"
    
    static let screenFrame = UIScreen.main.bounds
    static let paletteVioletColor = UIColor(hexString: "#5263FF")
    static let paletteBlackColor = UIColor(hexString: "#333333")
    static let paletteLightBlackColor = UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 0.87)
    static let paletteLightGrayColor = UIColor(hexString: "#BDBDBD")
    static let basicOffset:CGFloat = 20
    
    static let oneSpaceWidthInHorizontalCollectionView = Constants.screenFrame.size.width - 40
    
    static let spaceImageHeight = UIScreen.main.bounds.size.width
    static let screenWidth = UIScreen.main.bounds.size.width
    
    static let googleMapsAPIKey = "AIzaSyCjpWgFUslHPd1StXTGdiz2QerHDcbfsGo"
    
    static let userDefaultsUserJsonStringKey = "userJSON"
    static let userCurrentRoleStringKey = "currentRole"
    static let userIsFreeStatusStringKey = "isFreeStatus"
    static let pushPlayerIdStringKey = "pushPlayerId"
    
    static let currentLanguage = (NSLocale.components(fromLocaleIdentifier: NSLocale.preferredLanguages.first!))["kCFLocaleLanguageCodeKey"]
    
    static let realtorModeCompletionText: String = "Для перехода в режим владельца,\nпожалуйста введите\nнедостающие данные"
    static let authorizationSignUpGuideText: String = "Находите жилье без посредников вместе с Pillowz. Для начала нужно пройти регистрацию. Это займет не больше минуты."
    static let authorizationSignUpPrivacyPolicyText: String = "Нажимая на кнопку «НАЧНЕМ!», я подтверждаю,\nчто ознакомлен(а) с условиями\nПубличной оферты и\nПолитики конфиденциальности\nи принимаю их условия"
    
    static let loadedCategoriesNotification = "loadedCategoriesNotification"
    static let loadedCountriesNotification = "loadedCountriesNotification"
    static let loadedLanguagesNotification = "loadedLanguagesNotification"
    
    static let changedFilterValueNotification = "changedFilterValueNotification"
    static let changedRequestFilterValueNotification = "changedRequestFilterValueNotification"
    
    static let needAuthText: String = "Для выполнения этого действия войдите в аккаунт"
}
