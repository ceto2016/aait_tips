
# 🧹 تنظيف مشاريع Flutter بضغطة واحدة (Mac & Windows)

لو عندك فولدر فيه كل مشاريع Flutter بتاعتك، وعايز تفضي مساحة من غير ما تلف على كل مشروع وتكتب `flutter clean` بنفسك... استخدم السكربت المناسب لجهازك 👇

---

## 🍏 لأصحاب الـ Mac

افتح **Terminal** وشغّل السكربت ده بعد ما تبدّل المسار بالـ **path** بتاع فولدر المشاريع عندك:

```bash
for dir in /Users/apple/Desktop/projects/*; do
  if [ -d "$dir" ] && [ -f "$dir/pubspec.yaml" ]; then
    echo "Cleaning $dir"
    (cd "$dir" && flutter clean)
  fi
done
```

### ✅ السكربت بيعمل:
- يلف على كل اللي جوه المسار
- يتأكد إن اللي جوه ده فولدر وفيه `pubspec.yaml` (يعني مشروع Flutter)
- يطبع اسم المشروع اللي بيعمله تنظيف
- يدخل يعمل `flutter clean`

---

## 🖥️ لأصحاب Windows (PowerShell)

افتح **PowerShell** وشغّل السكربت ده بعد ما تبدّل المسار في `$projectsPath` للمسار بتاع فولدر المشاريع عندك:

```powershell
$projectsPath = "C:\Users\mohamed\Desktop\projects"

Get-ChildItem -Path $projectsPath -Directory | ForEach-Object {
    $pubspec = Join-Path $_.FullName "pubspec.yaml"
    if (Test-Path $pubspec) {
        Write-Host "Cleaning $($_.FullName)"
        Set-Location $_.FullName
        flutter clean
    }
}
```

### ✅ السكربت بيعمل:
- يلف على كل الفولدرات جوا المسار اللي اخترته
- يتأكد إن فيه `pubspec.yaml` (يعني مشروع Flutter)
- يطبع اسم المشروع
- يعمل `flutter clean` جواه

---

ريح بالك وسيب الجهاز ينضف المشاريع عنك 🤝💻
