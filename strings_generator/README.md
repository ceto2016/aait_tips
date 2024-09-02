# Strings Generator
strings generator use watcher package 
so add it 
```watcher: ^{lastest_version}```
then type in terminal
``` dart generate/strings/main.dart```
now the genrator is working and listen to every change in lang.json file but
first create lang.json file in assets/translations directory
in the file write your word like this

**English value will be in the key (left)**
**Arabic value will be in the value (right)** 
Ex :
```
{"Login": "تسجيل دخول”}
```
The generator with take the English word and convert it to snack case key for both Langs in ar.json and en.json and assign lang value 
Then create var in locale Keys folder with getters to translate it
```
static const String _login = 'login';
static String get login => _login.tr();
```

**If  you have long word like this**
```
 “Check your internet connection": "تحقق من اتصالك بالانترنت"
```

**You can set custom key like this 
```
"checkInternet #$ Check your internet connection": "تحقق من اتصالك بالانترنت"
```
**Write the custom key then “ #$ “ then the English  value**
