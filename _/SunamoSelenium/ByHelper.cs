namespace SunamoSelenium;
using OpenQA.Selenium;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

public static class ByHelper
{
    public static By ClassName(string classes)
    {
        return By.CssSelector("." + classes.Replace(" ", "."));
    }
}