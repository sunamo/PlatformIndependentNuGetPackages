namespace SunamoSelenium.Services;
using OpenQA.Selenium;
using OpenQA.Selenium.Support.UI;

public class SeleniumService(IWebDriver driver)
{
    public void WaitForPageReady()
    {
        WebDriverWait wait = new WebDriverWait(driver, TimeSpan.FromSeconds(15));
        wait.Until(d => ((IJavaScriptExecutor)d).ExecuteScript("return document.readyState").Equals("complete"));
    }

    //public void WaitForElementIsVisible(By by)
    //{
    //    WebDriverWait wait = new WebDriverWait(TimeSpan.FromSeconds(3));
    //    wait.Until(ExpectedConditions.ElementIsVisible(by));
    //}

    public IWebElement? FindElement(By by)
    {
        var elements = driver.FindElements(by);
        return elements.FirstOrDefault();
    }

    //public static System.Net.Cookie ToNetCookie(this OpenQA.Selenium.Cookie seleniumCookie)
    //{
    //    var netCookie = new System.Net.Cookie(
    //        seleniumCookie.Name,
    //        seleniumCookie.Value,
    //        seleniumCookie.Path,
    //        seleniumCookie.Domain)
    //    {
    //        HttpOnly = seleniumCookie.IsHttpOnly,
    //        Secure = seleniumCookie.Secure
    //    };
    //    if (seleniumCookie.Expiry.HasValue)
    //    {
    //        netCookie.Expires = seleniumCookie.Expiry.Value;
    //    }
    //    // SameSite mapování
    //    //switch (seleniumCookie.SameSite)
    //    //{
    //    //    case SameSiteMode.None:
    //    //        netCookie.SameSite = SameSiteMode.None;
    //    //        break;
    //    //    case SameSiteMode.Lax:
    //    //        netCookie.SameSite = SameSiteMode.Lax;
    //    //        break;
    //    //    case SameSiteMode.Strict:
    //    //        netCookie.SameSite = SameSiteMode.Strict;
    //    //        break;
    //    //    default:
    //    //        // Pro neznámé hodnoty SameSite v Selenium Cookie, 
    //    //        // nastavte SameSiteMode.Unspecified v .NET Cookie.
    //    //        netCookie.SameSite = SameSiteMode.Unspecified;
    //    //        break;
    //    //}
    //    return netCookie;
    //}
}