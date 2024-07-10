namespace SunamoCollectionOnDrive;


public class PpkOnDriveT<T> : PpkOnDriveBase<T> where T : IParserCollectionOnDrive
{
    public override
#if ASYNC
    async Task
#else
void
#endif
    Load()
    {
        if (File.Exists(a.file))
        {
            int dex = 0;
            foreach (string item in SHGetLines.GetLines(
#if ASYNC
            await
#endif
            File.ReadAllTextAsync(a.file)))
            //TFSE.ReadAllLines(a.file))
            {
                T t = (T)Activator.CreateInstance(typeof(T));
                t.Parse(item);
                Add(t);
                dex++;
            }
        }
    }

    public PpkOnDriveT(PpkOnDriveArgs a) : base(a)
    {

    }

    public PpkOnDriveT(string file2, bool load = true) : base(new PpkOnDriveArgs { file = file2, load = load })
    {
    }

    public PpkOnDriveT(string file, bool load, bool save) : base(new PpkOnDriveArgs { file = file, load = load, save = save })
    {
    }
}
