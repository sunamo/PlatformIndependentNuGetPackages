namespace SunamoCollectionsValuesTableGrid;

/// <summary>
/// Similar class with two dimension array is UniqueTableInWhole
/// Allow make query to parallel collections as be one
/// </summary>
/// <typeparam name="T"></typeparam>
public class ValuesTableGrid<T> : List<List<T>>//, IValuesTableGrid<T>
{
    /// <summary>
    /// Row - wrapper - files 2
    /// Column - inner - apps 4
    /// </summary>
    private List<List<T>> _exists;
    public List<string> captions;
    /// <summary>
    /// Must be initialized captions variable
    /// All rows must be trimmed from \r \n
    /// </summary>
    public DataTable SwitchRowsAndColumn()
    {
        DataTable newTable = new DataTable();
        if (_exists.Count > 0)
        {
            // Prvně přidám prázdný sloupec kde budou captions
            newTable.Columns.Add(string.Empty);
            // Můžu přidám sloupec pro B,C,D...
            for (int i = 0; i < _exists.Count; i++)
                newTable.Columns.Add();
            var s = _exists[0];
            for (int i = 0; i < s.Count; i++)
            {
                DataRow newRow = newTable.NewRow();
                var caption = captions[i]; //CASH.GetIndex(captions, i);
                newRow[0] = caption == null ? string.Empty : caption.ToString();
                for (int j = 0; j < _exists.Count; j++)
                    newRow[j + 1] = _exists[j][i];
                newTable.Rows.Add(newRow);
            }
        }
        return newTable;
    }
    public DataTable ToDataTable()
    {
        DataTable dt = new DataTable();
        var min = CAG.MinElementsItemsInnerList(_exists);
        var max = CAG.MaxElementsItemsInnerList(_exists);
        var cc = captions.Count;
        if (min != cc)
        {
            ThrowEx.DifferentCountInLists("min", min, "cc", cc);
            return null;
        }
        if (max != cc)
        {
            ThrowEx.DifferentCountInLists("max", max, "cc", cc);
            return null;
        }
        for (int i = 0; i < cc; i++)
        {
            dt.Columns.Add();
        }
        var ts = captions.ToArray();
        //var t1 = ts.GetType();
        dt.Rows.Add(ts);
        foreach (var item in _exists)
        {
            List<string> ls = new List<string>(item.Count);
            foreach (var item2 in item)
            {
                ls.Add(item2.ToString());
            }
            //var ts2 = CASH.ToListStringIList(item).ToArray();
            //var t2 = ts2.GetType();
            dt.Rows.Add(ls);
        }
        return dt;
    }
    public ValuesTableGrid(List<List<T>> exists, bool keepInSizeOfSmallest = true)
    {
        if (keepInSizeOfSmallest)
        {
            var lowest = CAG.LowestCount(exists);
            exists = CAG.TrimInnersToCount(exists, lowest);
        }
        _exists = exists;
    }
    public bool IsAllInColumn(int i, T value)
    {
        return _exists[i].All(d => EqualityComparer<T>.Default.Equals(d, value)); //CAG.IsAllTheSame<T>(value, );
    }
    public bool IsAllInRow(int i, T value)
    {
        var list = _exists[i];
        foreach (var item in list)
        {
            if (!EqualityComparer<T>.Default.Equals(item, value))
            {
                return false;
            }
        }
        return true;
    }
}
