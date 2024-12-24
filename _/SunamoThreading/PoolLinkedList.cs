namespace SunamoThreading;
using SunamoThreading._sunamo;

public sealed class PoolLinkedList : IDisposable
{
    private readonly LinkedList<Thread> _workers; // queue of worker threads ready to process actions
    private readonly LinkedList<Action> _tasks = new LinkedList<Action>(); // actions to be processed by worker threads
    private bool _disallowAdd; // set to true when disposing queue but there are still tasks pending
    private bool _disposed; // set to true when disposing queue and no more tasks are pending

    public PoolLinkedList(int size)
    {
        _workers = new LinkedList<Thread>();
        for (var i = 0; i < size; ++i)
        {
            var worker = new Thread(Worker) { Name = string.Concat(sess.i18n(XlfKeys.Worker) + " ", i) };
            worker.Start();
            _workers.AddLast(worker);
        }
    }

    public void Dispose()
    {
        var waitForThreads = false;
        lock (_tasks)
        {
            if (!_disposed)
            {
                GC.SuppressFinalize(this);

                _disallowAdd = true; // wait for all tasks to finish processing while not allowing any more new tasks
                while (_tasks.Count > 0)
                {
                    Monitor.Wait(_tasks);
                }

                _disposed = true;
                Monitor.PulseAll(_tasks); // wake all workers (none of them will be active at this point; disposed flag will cause then to finish so that we can join them)
                waitForThreads = true;
            }
        }
        if (waitForThreads)
        {
            foreach (var worker in _workers)
            {
                worker.Join();
            }
        }
    }

    public void QueueTask(Action task)
    {
        lock (_tasks)
        {
            if (_disallowAdd) { throw new Exception(sess.i18n(XlfKeys.ThisPoolInstanceIsInTheProcessOfBeingDisposedCanTAddAnymore)); }
            if (_disposed) { throw new Exception(sess.i18n(XlfKeys.ThisPoolInstanceHasAlreadyBeenDisposed)); }
            _tasks.AddLast(task);
            Monitor.PulseAll(_tasks); // pulse because tasks count changed
        }
    }

    static Type type = typeof(PoolLinkedList);

    private void Worker()
    {
        Action task = null;
        while (true) // loop until threadpool is disposed
        {
            lock (_tasks) // finding a task needs to be atomic
            {
                while (true) // wait for our turn in _workers queue and an available task
                {
                    if (_disposed)
                    {
                        return;
                    }
                    if (null != _workers.First && ReferenceEquals(Thread.CurrentThread, _workers.First.Value) && _tasks.Count > 0) // we can only claim a task if its our turn (this worker thread is the first entry in _worker queue) and there is a task available
                    {
                        task = _tasks.First.Value;
                        _tasks.RemoveFirst();
                        _workers.RemoveFirst();
                        Monitor.PulseAll(_tasks); // pulse because current (First) worker changed (so that next available sleeping worker will pick up its task)
                        break; // we found a task to process, break out from the above 'while (true)' loop
                    }
                    Monitor.Wait(_tasks); // go to sleep, either not our turn or no task to process
                }
            }

            task(); // process the found task
            lock (_tasks)
            {
                _workers.AddLast(Thread.CurrentThread);
            }
            task = null;
        }
    }


}