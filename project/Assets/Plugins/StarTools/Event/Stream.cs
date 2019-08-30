using System;
using System.Collections.Generic;

namespace StarTools.Event
{
    /// <summary>
    /// Stream
    /// </summary>
    public interface IStream
    {
        IDisposable Listen(Action action);
    }
    
    /// <summary>
    /// IStream<T>
    /// </summary>
    public interface IStream<out T>
    {
        IDisposable Listen(Action<T> action);
    }
    
    /// <summary>
    /// Stream
    /// </summary>
    public sealed class Stream : IStream
    {
        private class ListenHandle : IDisposable
        {
            private readonly Stream _stream;
            private readonly Action _action;

            public ListenHandle(Stream stream, Action action)
            {
                _stream = stream;
                _action = action;
            }
            
            public void Dispose()
            {
                _stream.RemoveAction(_action);
            }
        }

        private readonly ICollection<Action> _actions = new HashSet<Action>();
        private readonly ICollection<Action> _actionsToAdd = new HashSet<Action>();
        private readonly ICollection<Action> _actionsToRemove = new HashSet<Action>();
        
        public IDisposable Listen(Action action)
        {
            _actionsToAdd.Add(action);
            
            return new ListenHandle(this, action);
        }

        public void Send()
        {
            foreach (var action in _actionsToAdd)
            {
                _actions.Add(action);
            }
            _actionsToAdd.Clear();

            foreach (var action in _actionsToRemove)
            {
                _actions.Remove(action);
            }
            _actionsToRemove.Clear();

            foreach (var action in _actions)
            {
                action.Invoke();
            }
        }

        private void RemoveAction(Action action)
        {
            _actionsToRemove.Add(action);
        }
    }
    
    /// <summary>
    /// Stream<T>
    /// </summary>
    public sealed class Stream<T> : IStream<T>
    {
        private class ListenHandle : IDisposable
        {
            private readonly Stream<T> _stream;
            private readonly Action<T> _action;

            public ListenHandle(Stream<T> stream, Action<T> action)
            {
                _stream = stream;
                _action = action;
            }
            
            public void Dispose()
            {
                _stream.RemoveAction(_action);
            }
        }

        private readonly ICollection<Action<T>> _actions = new HashSet<Action<T>>();
        private readonly ICollection<Action<T>> _actionsToAdd = new HashSet<Action<T>>();
        private readonly ICollection<Action<T>> _actionsToRemove = new HashSet<Action<T>>();
        
        public IDisposable Listen(Action<T> action)
        {
            _actionsToAdd.Add(action);
            
            return new ListenHandle(this, action);
        }

        public void Send(T obj)
        {
            foreach (var action in _actionsToAdd)
            {
                _actions.Add(action);
            }
            _actionsToAdd.Clear();

            foreach (var action in _actionsToRemove)
            {
                _actions.Remove(action);
            }
            _actionsToRemove.Clear();

            foreach (var action in _actions)
            {
                action.Invoke(obj);
            }
        }

        private void RemoveAction(Action<T> action)
        {
            _actionsToRemove.Add(action);
        }
    }
}
