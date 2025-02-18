Get-ChildItem -Path . -Filter *.vcxproj -Recurse | ForEach-Object {
    (Get-Content $_.FullName) -replace '<CppWinRTVersion>.*?</CppWinRTVersion>', '<CppWinRTVersion>2.0.230511.6</CppWinRTVersion>' | Set-Content $_.FullName
}