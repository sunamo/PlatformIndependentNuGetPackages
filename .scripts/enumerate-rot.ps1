# EN: Enumerate Running Object Table (ROT) to find all registered DTE objects
# CZ: Enumeruj Running Object Table (ROT) pro nalezení všech registrovaných DTE objektů

Write-Host "=== Running Object Table (ROT) Enumerator ===" -ForegroundColor Cyan
Write-Host ""

# EN: Load necessary types for COM interop
# CZ: Načti potřebné typy pro COM interop
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
using System.Runtime.InteropServices.ComTypes;

public class ROTEnumerator
{
    [DllImport("ole32.dll")]
    private static extern int GetRunningObjectTable(int reserved, out IRunningObjectTable prot);

    [DllImport("ole32.dll")]
    private static extern int CreateBindCtx(int reserved, out IBindCtx ppbc);

    public static void EnumerateROT()
    {
        IRunningObjectTable rot;
        IEnumMoniker enumMoniker;
        int hr = GetRunningObjectTable(0, out rot);

        if (hr != 0)
        {
            Console.WriteLine("Failed to get ROT: HRESULT = 0x{0:X8}", hr);
            return;
        }

        rot.EnumRunning(out enumMoniker);
        enumMoniker.Reset();

        IMoniker[] monikers = new IMoniker[1];
        IntPtr fetchedCount = IntPtr.Zero;

        int vsCount = 0;
        Console.WriteLine("Enumerating ROT entries...");
        Console.WriteLine("");

        while (enumMoniker.Next(1, monikers, fetchedCount) == 0)
        {
            IBindCtx bindCtx;
            CreateBindCtx(0, out bindCtx);

            string displayName;
            try
            {
                monikers[0].GetDisplayName(bindCtx, null, out displayName);

                // EN: Filter for Visual Studio DTE objects
                // CZ: Filtruj DTE objekty Visual Studia
                if (displayName.Contains("VisualStudio.DTE") || displayName.Contains("!VisualStudio"))
                {
                    Console.ForegroundColor = ConsoleColor.Green;
                    Console.WriteLine("Found DTE object:");
                    Console.ResetColor();
                    Console.ForegroundColor = ConsoleColor.Cyan;
                    Console.WriteLine("  DisplayName: {0}", displayName);
                    Console.ResetColor();

                    // EN: Try to get the actual object
                    // CZ: Zkus získat skutečný objekt
                    try
                    {
                        object obj;
                        rot.GetObject(monikers[0], out obj);

                        if (obj != null)
                        {
                            Type objType = obj.GetType();
                            Console.ForegroundColor = ConsoleColor.Yellow;
                            Console.WriteLine("  Type: {0}", objType.FullName);

                            // EN: Try to get DTE version and edition
                            // CZ: Zkus získat verzi a edici DTE
                            try
                            {
                                dynamic dte = obj;
                                Console.WriteLine("  Version: {0}", dte.Version);
                                Console.WriteLine("  Edition: {0}", dte.Edition);

                                if (dte.Solution != null && !string.IsNullOrEmpty(dte.Solution.FullName))
                                {
                                    Console.WriteLine("  Solution: {0}", dte.Solution.FullName);
                                }
                            }
                            catch (Exception ex)
                            {
                                Console.WriteLine("  (Could not get DTE properties: {0})", ex.Message);
                            }

                            Console.ResetColor();
                        }
                    }
                    catch (Exception ex)
                    {
                        Console.ForegroundColor = ConsoleColor.Red;
                        Console.WriteLine("  Error getting object: {0}", ex.Message);
                        Console.ResetColor();
                    }

                    Console.WriteLine("");
                    vsCount++;
                }
            }
            catch (Exception ex)
            {
                // EN: Skip entries that can't be read
                // CZ: Přeskoč položky které nelze přečíst
            }
            finally
            {
                Marshal.ReleaseComObject(bindCtx);
            }
        }

        if (vsCount == 0)
        {
            Console.ForegroundColor = ConsoleColor.Red;
            Console.WriteLine("No Visual Studio DTE objects found in ROT!");
            Console.ResetColor();
            Console.WriteLine("");
            Console.ForegroundColor = ConsoleColor.Yellow;
            Console.WriteLine("This means:");
            Console.WriteLine("  1. Visual Studio is not running, OR");
            Console.WriteLine("  2. Visual Studio is running but not fully initialized, OR");
            Console.WriteLine("  3. Visual Studio is in a blocking dialog state");
            Console.ResetColor();
        }
        else
        {
            Console.ForegroundColor = ConsoleColor.Green;
            Console.WriteLine("Total DTE objects found: {0}", vsCount);
            Console.ResetColor();
        }

        Marshal.ReleaseComObject(enumMoniker);
        Marshal.ReleaseComObject(rot);
    }
}
"@

# EN: Run the enumerator
# CZ: Spusť enumerátor
try {
    [ROTEnumerator]::EnumerateROT()
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "This script must be run in Windows PowerShell 5.1 (not PowerShell 7+)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "=== DONE ===" -ForegroundColor Cyan
