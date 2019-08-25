platform :ios, '8.4'
use_frameworks!

target 'SNUTT' do
  pod 'EGOTableViewPullRefreshAndLoadMore'
  pod 'Alamofire'
  pod 'Fabric'
  pod 'Crashlytics'
  pod 'ChameleonFramework/Swift', :git => 'https://github.com/ViccAlexander/Chameleon.git'
  pod 'ActionSheetPicker-3.0'
  pod 'Color-Picker-for-iOS', '~> 2.0'
  pod 'FBSDKCoreKit'
  pod 'FBSDKLoginKit'
  pod 'FBSDKShareKit'
  pod 'Carte'
  pod 'SwiftyUserDefaults', :git => 'https://github.com/Rajin9601/SwiftyUserDefaults.git'
  pod 'TTRangeSlider'
  pod 'Firebase'
  pod 'Firebase/Messaging'
  pod 'DZNEmptyDataSet', :git => 'https://github.com/Rajin9601/DZNEmptyDataSet.git', :branch => 'fix-hitTest'
  pod 'TPKeyboardAvoiding'
  pod 'MarqueeLabel/Swift'
  pod 'UITextView+Placeholder', '~> 1.2'
  pod 'Swinject'
  pod 'RxSwift'
  pod 'RxSwiftExt'
  pod 'RxCocoa'
  pod 'RxGesture', '~> 2.1.0'
  pod 'RxDataSources'
  pod 'SnapKit', '~> 4.0.0'
  pod 'Moya/RxSwift'
end

target 'SNUTT Today' do
  pod 'SwiftyUserDefaults', :git => 'https://github.com/Rajin9601/SwiftyUserDefaults.git'
  pod 'RxSwift'
  pod 'RxSwiftExt'
  pod 'RxCocoa'
  pod 'RxGesture', '~> 2.1.0'
  pod 'SnapKit', '~> 4.0.0'
end

post_install do |installer|
  pods_dir = File.dirname(installer.pods_project.path)
  at_exit { `ruby #{pods_dir}/Carte/Sources/Carte/carte.rb configure` }
end
