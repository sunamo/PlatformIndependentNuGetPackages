namespace SunamoEssential.Essential.EventArgsNs;

/// <summary>
/// Event arguments containing a URI.
/// </summary>
public class UriEventArgs : EventArgs
{
    /// <summary>
    /// Initializes a new instance of <see cref="UriEventArgs"/> with the specified URI.
    /// </summary>
    /// <param name="uri">The URI associated with the event.</param>
    public UriEventArgs(Uri uri)
    {
        Uri = uri;
    }

    /// <summary>
    /// Gets the URI associated with this event.
    /// </summary>
    public Uri Uri { get; }
}
