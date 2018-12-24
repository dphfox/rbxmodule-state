# API Reference


## Functions
### `GetAllStates() -> array<any>`
Returns an array of all registered state IDs.

### `Create(id: any)`
Creates a new state internally, using the given state ID as the unique identifier. If there already exists a state using the given state ID, this function returns silently.

It's recommended to use string IDs, but any type is accepted except nil. You must always create a state before you can use it.

### `Wrap(id: any) -> proxy`
Returns a proxy object that lets you omit the `id` parameter from all functions in the module. Once returned, this proxy object can be used identically to the State module itself, except without specifying the `id` parameter when calling functions.

Example: 
```Lua
State.Create "MyState"
local Proxy = State.Wrap "MyState"

-- the two statements below are identical
State.Push("MyState", {foo = 2})
Proxy.Push {foo = 2}
```

### `GetCopy(id: any) -> table`
Returns a copy of the internal state using the given state ID. This copy is not related to the true internal state; modifications made to the internal state are not reflected in the copy, and vice versa.

### `Push(id: any, newState: table [, mutationInfo: any])`
Merges the new state with the original state for the given state ID. The optional `mutationInfo` parameter is passed to listeners of the `StateMutated` event.

### `Push(id: any, mutator: function(oldState: table) -> table [, mutationInfo: any])`
Generates new state using the `mutator` function, and merges it with the original state for the given state ID. More specifically, the `mutator` function is called with a copy of the old state, and returns some new state. The returned new state is then merged with the old state and stored.

The optional `mutationInfo` parameter is passed to listeners of the `StateMutated` event.

### `On(id: any, eventName: string, callback: function(...))`
For the given state ID, listens for events called `eventName` and invokes the callback with any arguments passed. See the Events section for a complete list of events.


## Events
### `StateMutated(oldState: table, newState: table [, mutatorInfo: any])`
Fired when the state is mutated (e.g. by a call to `Push()`). `oldState` is a copy of the state before mutation, `newState` is the final state after mutation, and `mutatorInfo` is optionally provided by the code which mutated the state.