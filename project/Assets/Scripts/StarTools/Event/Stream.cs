using System;
using System.Collections.Generic;

namespace StarTools.Event
{
    public interface IStream
    {
        IDisposable Listen(Action action);
    }
    
    public interface IStream<out T>
    {
        IDisposable Listen(Action<T> action);
    }
    
    public class Stream : IStream
    {
        private class ListenHandle : IDisposable
        {
            private Stream _stream;
            private Action _action;

            public ListenHandle(Stream stream, Action action)
            {
                _stream = stream;
                _action = action;
            }
            
            public void Dispose()
            {
                
            }
        }

        private readonly IList<Action> _callbacks = new List<Action>(16);
        private readonly IList<Action> _callbacksToAdd = new List<Action>(4);
        private readonly IList<Action> _callbacksToRemove = new List<Action>(4);
        
        public IDisposable Listen(Action action)
        {
            _callbacksToAdd.Add(action);
            
            return new ListenHandle(this, action);
        }

        private void DisposeHandle(Action action)
        {
            _callbacksToRemove.Add(action);
        }
    }
}
