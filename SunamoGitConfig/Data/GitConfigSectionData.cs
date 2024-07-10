namespace SunamoGitConfig.Data;

public class GitConfigSectionData
{
    public GitConfigSection Section { get; set; }
    public Dictionary<string, string> Settings { get; set; } = new Dictionary<string, string>();
    public string Header { get; set; }

    public GitConfigSectionData(GitConfigSection section)
    {
        Section = section;
    }
}
