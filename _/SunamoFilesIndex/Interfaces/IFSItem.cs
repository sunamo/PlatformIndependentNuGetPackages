namespace SunamoFilesIndex.Interfaces;


internal interface IFSItem : IName, IPath, IIDParent
{
    long Length { get; set; }
}