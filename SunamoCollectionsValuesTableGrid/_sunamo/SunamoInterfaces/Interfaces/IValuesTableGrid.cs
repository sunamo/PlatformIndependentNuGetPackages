namespace SunamoCollectionsValuesTableGrid._sunamo.SunamoInterfaces.Interfaces;


internal interface IValuesTableGrid<T>
{
    bool IsAllInColumn(int i, T value);
    bool IsAllInRow(int i, T value);
    DataTable SwitchRowsAndColumn();
    DataTable ToDataTable();
}
