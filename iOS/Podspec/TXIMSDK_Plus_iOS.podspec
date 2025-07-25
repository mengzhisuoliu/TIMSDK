
Pod::Spec.new do |spec|
  spec.name         = 'TXIMSDK_Plus_iOS'
  spec.version      = '8.6.7040'
  spec.platform     = :ios 
  spec.ios.deployment_target = '8.0'
  spec.license      = { :type => 'Proprietary',
      :text => <<-LICENSE
        copyright 2017 tencent Ltd. All rights reserved.
        LICENSE
       }
  spec.homepage     = 'https://cloud.tencent.com/document/product/269/3794'
  spec.documentation_url = 'https://cloud.tencent.com/document/product/269/9147'
  spec.authors      = 'tencent video cloud'
  spec.summary      = 'TXIMSDK_Plus_iOS'
  
  spec.requires_arc = true

  spec.source = { :http => 'https://im.sdk.cloud.tencent.cn/download/plus/8.6.7040/ImSDK_Plus_8.6.7040.framework.zip'}
  spec.preserve_paths = '**/ImSDK_Plus.framework'
  spec.source_files = '**/ImSDK_Plus.framework/Headers/*.h', '**/ImSDK_Plus.framework/cpluscplus/include/*.h'
  spec.public_header_files = '**/ImSDK_Plus.framework/Headers/*.h', '**/ImSDK_Plus.framework/cpluscplus/include/*.h'
  spec.vendored_frameworks = '**/ImSDK_Plus.framework'
  spec.resource_bundle = {
    "#{spec.module_name}_Privacy" => '**/ImSDK_Plus.framework/PrivacyInfo.xcprivacy'
  }
  spec.xcconfig = { 'HEADER_SEARCH_PATHS' => '${PODS_ROOT}/TXIMSDK_Plus_iOS/ImSDK_Plus.framework/Headers/, ${PODS_ROOT}/TXIMSDK_Plus_iOS/ImSDK_Plus.framework/cpluscplus/include/'}
  spec.pod_target_xcconfig = {
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
  }
  spec.user_target_xcconfig = { 
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
  } 

end
