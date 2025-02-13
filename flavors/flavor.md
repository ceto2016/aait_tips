## Collaboration with Eng / Mohamed Mahmoud and Eng/ Magdy 

#######################################################
#################### Build Flavors ####################
#######################################################

### Video [Marcus] : https://www.youtube.com/watch?v=Vhm1Cv2uPko

### Offical documentation : https://docs.flutter.dev/deployment/flavors

## Add various mainifist for each flavor : https://developer.android.com/build/manage-manifests#merge_rule_markers

#######################################################
####### App Info #######
#######################################################

## App Bundles :

                        ## IOS ##                      |          ## Android ##
                ------------------------------------------------------------------
    [User]      com.aait.flutter.mumayaz.user          |     com.aait.flutter.mumayz.user
    [Provider]  com.aait.flutter.mumayaz.provider      |     com.aait.flutter.mumayaz.provider

## BUILD APK && IPA:

- For IOS :
  flutter build ipa --flavor user -t lib/main_user.dart
  flutter build ipa --flavor provider -t lib/main_provider.dart

- For Android :
  flutter build apk --release --flavor user -t lib/main_user.dart
  flutter build apk --release --flavor provider -t lib/main_provider.dart

- for Android [Build App Bundle] :
  flutter build appbundle --flavor user -t lib/main_user.dart
  flutter build appbundle --flavor provider -t lib/main_provider.dart

## Flutter Fire Config Path [export PATH="$PATH":"$HOME/.pub-cache/bin"]

## Flutter Fire Apps Configs:

    flutterfire config \
    --project=mumayaz-484a1 \
    --out=lib/features/user/user_firebase_options.dart \
    --android-package-name=com.aait.flutter.mumayaz.user \
    --ios-bundle-id=com.aait.flutter.mumayaz.user

    flutterfire config \
    --project=mumayaz-484a1 \
    --out=lib/features/provider/provider_firebase_options.dart \
    --android-package-name=com.aait.flutter.mumayaz.provider \
    --ios-bundle-id=com.aait.flutter.mumayaz.provider

<!-- flutterfire configure --project=ajrni-5dbcc -->
## flavorAsset
String flavorAsset({
  required String userAsset,
  required String providerAsset,
}) {
  if (EnvironmentsConfig.appEnvironment == AppEnvironmentEnum.user) {
    return userAsset;
  } else {
    return providerAsset;
  }
} 

## FlavorBuilder
```
class FlavorBuilder extends StatelessWidget {
  const FlavorBuilder({super.key, this.user, this.provider, this.builder});
  final Widget? user;
  final Widget? provider;
  final Widget Function(AppEnvironmentEnum flavor)? builder;

  @override
  Widget build(BuildContext context) {
    final currentFlavor = EnvironmentsConfig.appEnvironment;
    if (builder != null) {
      return builder!(currentFlavor);
    } else if (currentFlavor == AppEnvironmentEnum.user && user != null) {
      return user!;
    } else if (currentFlavor == AppEnvironmentEnum.provider &&
        provider != null) {
      return provider!;
    }

    return const SizedBox();
  }
}
```