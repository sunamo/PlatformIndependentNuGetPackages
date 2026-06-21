namespace SunamoRL._public.SunamoInterfaces.Interfaces;

/// <summary>
/// Provides methods for calculating percentages from cumulative values.
/// </summary>
public interface IPercentCalculator
{
    /// <summary>
    /// Gets or sets the overall sum used as the 100% reference.
    /// </summary>
    double OverallSum { get; set; }

    /// <summary>
    /// Gets or sets the last computed value.
    /// </summary>
    double Last { get; set; }

    /// <summary>
    /// Creates a new instance with the specified overall sum.
    /// </summary>
    /// <param name="overallSum">The total sum representing 100%.</param>
    IPercentCalculator Create(double overallSum);

    /// <summary>
    /// Adds one percent to the computed sum.
    /// </summary>
    void AddOnePercent();

    /// <summary>
    /// Calculates the percentage for the given value.
    /// </summary>
    /// <param name="value">The value to calculate the percentage for.</param>
    /// <param name="isLast">Whether this is the last value in the sequence.</param>
    int PercentFor(double value, bool isLast);

    /// <summary>
    /// Resets the computed sum to zero.
    /// </summary>
    void ResetComputedSum();
}