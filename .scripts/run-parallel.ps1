$skipPackages = @(
    'SunamoFtp','SunamoIni','SunamoMarkdown','SunamoCsv','SunamoFluentFtp',
    'SunamoDebugIO','SunamoMail','SunamoPS','SunamoClearScript','SunamoDebugging',
    'SunamoPInvoke','SunamoYouTube','SunamoCrypt','SunamoCl','SunamoPackageJson',
    'SunamoWinStd','SunamoXml','SunamoVcf','SunamoValues','SunamoUri',
    'SunamoUnderscore','SunamoTwoWayDictionary','SunamoThread','SunamoThisApp',
    'SunamoTextOutputGenerator','SunamoStringTrim','SunamoStringSubstring',
    'SunamoStringSplit','SunamoStringReplace','SunamoStringJoin','SunamoStringGetLines'
)

& "E:\vs\Projects\PlatformIndependentNuGetPackages\.scripts\republish-parallel.ps1" -NuGetApiKey 'oy2ptjv7ussu3sxsdyrqee7a4kcpo5qu5gsavxgsal32ze' -ThrottleLimit 8 -SkipPackages $skipPackages
