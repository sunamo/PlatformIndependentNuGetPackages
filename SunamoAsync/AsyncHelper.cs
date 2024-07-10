namespace SunamoAsync;
public class AsyncHelper
{
    public static Dictionary<string, object> MergeDictionaries(Dictionary<string, Action> potentiallyValid,
        Dictionary<string, Func<Task>> potentiallyValidAsync)
    {
        var actionsMerge = new Dictionary<string, object>(potentiallyValid.Count + potentiallyValidAsync.Count);
        if (potentiallyValid != null)
            foreach (var item in potentiallyValid)
                actionsMerge.Add(item.Key, item.Value);
        if (potentiallyValidAsync != null)
            foreach (var item in potentiallyValidAsync)
                actionsMerge.Add(item.Key, item.Value);
        return actionsMerge;
    }
    public static
#if ASYNC
    async Task
#else
        void
#endif
        InvokeFuncTaskOrAction(object o)
    {
        var t = o.GetType();
        if (t == TypesDelegates.tAction)
        {
            (o as Action).Invoke();
        }
        else if (t == TypesDelegates.tFuncTask)
        {
            var taskVoid = o as Func<Task>;
#if ASYNC
            await
#endif
            taskVoid();
            ;
        }
    }

    public static AsyncHelper ci = new AsyncHelper();
    private AsyncHelper()
    {
    }
    /// <summary>
    /// To all regions insert comments whats not and what working
    ///
    /// Not working with Directory.GetFilesMoreMascAsync - with use https://stackoverflow.com/a/34518914 OK
    /// Task.Run<>(async () => await FunctionAsync()).Result;
    /// </summary>
    /// <typeparam name="T"></typeparam>
    /// <param name="task"></param>
    public T GetResult<T>(Task<T> task)
    {
        T result = default;
        task.LogExceptions();
        #region 1. ConfigureAwait(true)
        ConfiguredTaskAwaitable<T> t = task.Conf();
        ConfiguredTaskAwaitable<T>.ConfiguredTaskAwaiter t2 = t.GetAwaiter();
        result = t2.GetResult();
        #endregion
        #region 2. Sync
        //result = task.Result;
        #endregion
        #region 3. await
        //result = Await<T>(task);
        #endregion
        return result;
    }
    async Task<T> Await<T>(Task<T> t)
    {
        return await t;
    }
    public void GetResult(Task task)
    {
        task.LogExceptions();
        task.Conf();
    }
    async Task Await(Task t)
    {
        await t;
    }
    /// <summary>
    /// Execute's an T> method which has a void return value synchronously
    /// </summary>
    /// <param name="task">T> method to execute</param>
    public void RunSyncWithoutReturnValue(Func<Task> task)
    {
        var oldContext = SynchronizationContext.Current;
        var synch = new ExclusiveSynchronizationContext();
        SynchronizationContext.SetSynchronizationContext(synch);
        synch.Post(async _ =>
        {
            try
            {
                ci.GetResult(task());
            }
            catch (Exception e)
            {
                synch.InnerException = e;
                throw;
            }
            finally
            {
                synch.EndMessageLoop();
            }
        }, null);
        synch.BeginMessageLoop();
        SynchronizationContext.SetSynchronizationContext(oldContext);
        synch.Dispose();
    }

    public async Task RunAsync(Task task)
    {
        await task;
    }
    public void RunSyncWithoutReturnValue<T1>(Func<T1, Task> task, T1 a1)
    {
        var oldContext = SynchronizationContext.Current;
        var synch = new ExclusiveSynchronizationContext();
        SynchronizationContext.SetSynchronizationContext(synch);
        synch.Post(async _ =>
        {
            try
            {
                ci.GetResult(task(a1));
            }
            catch (Exception e)
            {
                synch.InnerException = e;
                throw;
            }
            finally
            {
                synch.EndMessageLoop();
            }
        }, null);
        synch.BeginMessageLoop();
        SynchronizationContext.SetSynchronizationContext(oldContext);
    }
    public void RunSyncWithoutReturnValue<T1, T2>(Func<T1, T2, Task> task, T1 a1, T2 a2)
    {
        var oldContext = SynchronizationContext.Current;
        var synch = new ExclusiveSynchronizationContext();
        SynchronizationContext.SetSynchronizationContext(synch);
        synch.Post(async _ =>
        {
            try
            {
                ci.GetResult(task(a1, a2));
            }
            catch (Exception e)
            {
                synch.InnerException = e;
                throw;
            }
            finally
            {
                synch.EndMessageLoop();
            }
        }, null);
        synch.BeginMessageLoop();
        SynchronizationContext.SetSynchronizationContext(oldContext);
        synch.Dispose();
    }
    public void RunSyncWithoutReturnValue<T1, T2, T3>(Func<T1, T2, T3, Task> task, T1 a1, T2 a2, T3 a3)
    {
        var oldContext = SynchronizationContext.Current;
        var synch = new ExclusiveSynchronizationContext();
        SynchronizationContext.SetSynchronizationContext(synch);
        synch.Post(async _ =>
        {
            try
            {
                ci.GetResult(task(a1, a2, a3));
            }
            catch (Exception e)
            {
                synch.InnerException = e;
                throw;
            }
            finally
            {
                synch.EndMessageLoop();
            }
        }, null);
        synch.BeginMessageLoop();
        SynchronizationContext.SetSynchronizationContext(oldContext);
        synch.Dispose();
    }
    /// <summary>
    /// Execute's an T> method which has a T return type synchronously
    /// </summary>
    /// <typeparam name="T">Return Type</typeparam>
    /// <param name="task">T> method to execute</param>
    public T RunSync<T, T1>(Func<T1, T> task, T1 a1)
    {
        var oldContext = SynchronizationContext.Current;
        var synch = new ExclusiveSynchronizationContext();
        SynchronizationContext.SetSynchronizationContext(synch);
        T ret = default;
        synch.Post(async _ =>
        {
            try
            {
                ret = task(a1);
            }
            catch (Exception e)
            {
                synch.InnerException = e;
                throw;
            }
            finally
            {
                synch.EndMessageLoop();
            }
        }, null);
        synch.BeginMessageLoop();
        SynchronizationContext.SetSynchronizationContext(oldContext);
        synch.Dispose();
        return ret;
    }
    /// <summary>
    /// Execute's an T> method which has a T return type synchronously
    /// </summary>
    /// <typeparam name="T">Return Type</typeparam>
    /// <param name="task">T> method to execute</param>
    public T RunSync<T, T1, T2>(Func<T1, T2, T> task, T1 a1, T2 a2)
    {
        var oldContext = SynchronizationContext.Current;
        var synch = new ExclusiveSynchronizationContext();
        SynchronizationContext.SetSynchronizationContext(synch);
        T ret = default;
        synch.Post(async _ =>
        {
            try
            {
                ret = task(a1, a2);
            }
            catch (Exception e)
            {
                synch.InnerException = e;
                throw;
            }
            finally
            {
                synch.EndMessageLoop();
            }
        }, null);
        synch.BeginMessageLoop();
        SynchronizationContext.SetSynchronizationContext(oldContext);
        synch.Dispose();
        return ret;
    }
    /// <summary>
    /// Execute's an T> method which has a T return type synchronously
    /// </summary>
    /// <typeparam name="T">Return Type</typeparam>
    /// <param name="task">T> method to execute</param>
    public T RunSync<T, T1, T2, T3>(Func<T1, T2, T3, T> task, T1 a1, T2 a2, T3 a3)
    {
        var oldContext = SynchronizationContext.Current;
        var synch = new ExclusiveSynchronizationContext();
        SynchronizationContext.SetSynchronizationContext(synch);
        T ret = default;
        synch.Post(async _ =>
        {
            try
            {
                ret = task(a1, a2, a3);
            }
            catch (Exception e)
            {
                synch.InnerException = e;
                throw;
            }
            finally
            {
                synch.EndMessageLoop();
            }
        }, null);
        synch.BeginMessageLoop();
        SynchronizationContext.SetSynchronizationContext(oldContext);
        synch.Dispose();
        return ret;
    }
    private class ExclusiveSynchronizationContext : SynchronizationContext, IDisposable
    {
        private bool done;
        public Exception InnerException { get; set; }
        readonly AutoResetEvent workItemsWaiting = new AutoResetEvent(false);
        readonly Queue<Tuple<SendOrPostCallback, object>> items =
            new Queue<Tuple<SendOrPostCallback, object>>();
        static Type type = typeof(ExclusiveSynchronizationContext);
        public override void Send(SendOrPostCallback d, object state)
        {
            throw new Exception("WeCannotSendToOurSameThread");
        }
        public override void Post(SendOrPostCallback d, object state)
        {
            lock (items)
            {
                items.Enqueue(Tuple.Create(d, state));
            }
            workItemsWaiting.Set();
        }
        public void EndMessageLoop()
        {
            Post(_ => done = true, null);
        }
        public void BeginMessageLoop()
        {
            while (!done)
            {
                Tuple<SendOrPostCallback, object> task = null;
                lock (items)
                {
                    if (items.Count > 0)
                    {
                        task = items.Dequeue();
                    }
                }
                if (task != null)
                {
                    task.Item1(task.Item2);
                    if (InnerException != null) // the method threw an exeption
                    {
                        throw new Exception("AsyncHelpersRunMethodThrewAnException" + ". " + InnerException);
                    }
                }
                else
                {
                    workItemsWaiting.WaitOne();
                }
            }
        }
        public override SynchronizationContext CreateCopy()
        {
            return this;
        }
        public void Dispose()
        {
            workItemsWaiting.Dispose();
        }
    }
    // Udělat pro IAsyncResult (dědí z něho Task) i IAsyncOperation
}
