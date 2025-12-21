# INSTRUKCE PRO PŘEJMENOVÁNÍ PROMĚNNÝCH

**VŠECHNY instrukce pro pojmenování proměnných samopopisnými názvy najdeš v:**

```
E:\vs\Projects\PlatformIndependentNuGetPackages\CLAUDE.md
```

Přečti si ten soubor před jakoukoliv prací na přejmenování proměnných v tomto projektu!

**KRITICKÉ pravidla (zkrácená verze, plná verze v hlavním CLAUDE.md):**
- ❌ NIKDY nepřidávej komentář `// variables names: ok` - to dělá pouze uživatel
- ❌ NIKDY nepoužívaj doménově specifické názvy (`columnCount`, `rowSize`) pro univerzální parametry → použij `groupSize`, `chunkSize`
- ❌ NIKDY nepoužívaj jednoslovné názvy (`s`, `v`, `l`) → použij `text`, `value`, `list`
- ❌ NIKDY nepoužívaj `item` pro parametry metod → vyhrazeno pro foreach
- ✅ VŽDY maž nepoužívané parametry z hlaviček metod
- ✅ VŽDY dbej na konzistenci v rámci jednoho souboru