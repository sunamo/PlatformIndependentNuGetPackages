namespace SunamoCssGenerator.Cmd
{
    class Program
    {
        public static string outputFileCss = @"D:\_Test\SunamoCssGenerator.Cmd\Output\output.css";

        static void Main(string[] args)
        {
            PropertiesConversions.Init();

            Dictionary<int, Dictionary<string, int>> d = new Dictionary<int, Dictionary<string, int>>();

            foreach (var item in CssResponsiveGenerator.sizes.Skip(2))
            {
                d.Add(item, GetDict(item));
            }

            CssResponsiveGenerator g = new CssResponsiveGenerator();
            g.Generate(d);

            outputFileCss = @"E:\vs\Projects\sunamoWithoutLocalDep.cz\lyrics.sunamo.cz\css\R_Lyr3.css";

            TF.WriteAllText(outputFileCss, g.ToString());
        }

        private static Dictionary<string, int> GetDict(int item)
        {
            var dx = CssResponsiveGenerator.sizes.IndexOf(item) - 2;
            var size = CssResponsiveGenerator.sizes[dx];
            Dictionary<string, int> d = new Dictionary<string, int>();

            // ic,content2
            // menu,cd

            d.Add("cd", 200);
            d.Add("menu", 200);

            d.Add("ic", size - 200);
            d.Add("content2", size - 200);
            d.Add("main", size);

            return d;
        }
    }
}
