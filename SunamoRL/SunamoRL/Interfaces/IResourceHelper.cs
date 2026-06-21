namespace SunamoRL.Interfaces;

/// <summary>
/// Interface for loading resources by name.
/// </summary>
public interface IResourceHelper
{
    /// <summary>
    /// Gets a string resource by name.
    /// </summary>
    /// <param name="name">The resource name.</param>
    string GetString(string name);

    /// <summary>
    /// Gets a stream resource by name.
    /// </summary>
    /// <param name="name">The resource name.</param>
    Stream GetStream(string name);
}
