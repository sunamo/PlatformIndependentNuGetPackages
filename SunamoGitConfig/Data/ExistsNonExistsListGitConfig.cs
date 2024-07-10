namespace SunamoGitConfig.Data;

public class ExistsNonExistsListGitConfig
{
    public List<GitConfigSectionData> Exists = new List<GitConfigSectionData>();
    public List<GitConfigSectionData> NonExists = new List<GitConfigSectionData>();

    public string GetValue(GitConfigSection blockSection, string key)
    {
        var block = Exists.FirstOrDefault(d => d.Section == blockSection);

        if (block == default(GitConfigSectionData))
        {
            return null;
        }

        var pair = block.Settings.Where(d => d.Key == key);

        if (pair.Count() == 0)
        {
            return null;
        }

        return pair.First().Value;
    }

    public void SetValue(GitConfigSection blockSection, string key, string value)
    {
        var block = Exists.FirstOrDefault(d => d.Section == blockSection);

        if (block == default(GitConfigSectionData))
        {
            block = new GitConfigSectionData(blockSection);

            Exists.Add(block);
        }

        if (block.Settings.ContainsKey(key))
        {
            block.Settings[key] = value;
        }
        else
        {
            block.Settings.Add(key, value);
        }

    }


}
