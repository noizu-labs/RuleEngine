# RuleEngine
The Noizu Rule engine allows for runtime configurable execution of business logic and scripting.
It works by allowing the user to define formula/script structures and execute them at runtime with 
relevant context information. 

## Example Uses

### Transaction Email Triggering.
 Don't want to hard code how many messages a user posts with more than seven likes before they get an award?
 Don't want to hard code when you send a user message received emails, or friend online emails. 
 Define some global scripts using the rule engine, and when relevant events (vote on user's post, user logged in, user friend logged in, etc.)
 occur hook into the global script. The rule engine helps you track previous state, actual transactions tracked can be changed
 at runtime by updating the database object (remove friend log in notification, etc.)

 Want to allow users define their own notifications of a list of available ones, or set frequency reminders,
 allow them to setup their own personal notification script, that lists which events are checked. No need to 
 add a bunch of new logic to add per user customization, rejig your codebase to conditionally check which rules to trigger by looking up a user preference table, 
 just write a single rule entry for them that reuses other global components and execute this instead of a global script. 

### Random Events / Interactions / Game Events. 

 Want to have random events happen to game users, trigger quests, spawn monster attacks?
 Setup some scripts capable of running as their own process. Allow them to subscribe to event details
 and write out the specific events you wish to occur. The library handles scaffolding for tracking state,
 you can edit which events occur at runtime without code updates.  
 (Add global event that triggers a spooky ghost attack on Halloween if a user is in an abandoned building, just define the conditions for when the event will occur and output your generic event kick off identifier when it triggers.)

### Runtime system configuration & monitoring

Setup up scripts that control when backups occur etc, change the criteria or action taken when criteria is met
at runtime.

Setup up scripts that trigger if certain telemetrics are met. Change them on the fly. Build out an admin panel for ops
that easily lets them configure and extend what system alerts they receive globally or on an individual basis.

## Basic Example

# A script that hosts state internally 
```
context = Noizu.ElixirCore.CallingContext.system()

inline_state = %InlineStateManager{global_state: %{a: 1}, entity_state: %{entity_module: %{b: 2}}}
|> put_in([Access.key(:settings), Access.key(:user_settings), :user_setting], :foo)

# 
script = %AndOp{
      identifier: "1",
      arguments: [
        %ReturnTrueIfEntityModuleBIs7{identifier: "1.1"}, # user defined operation/task
        %AndOp{
          identifier: "1.2",
          arguments: [
            %ValueOp{identifier: "1.2.1", value: 2.0},
            %ValueOp{identifier: "1.2.2", value: 3.0},
            %ValueOp{identifier: "1.2.3", value: 4.0},
          ]
        },
        %ValueOp{identifier: "1.3", value: 5.0},
      ]
    }

# Set a  state[:entity_module].b = 7, useful if using a External State Manager that supports multiple input streams {:entity_module, 7}, etc.
Noizu.RuleEngine.StateProtocol.put!(inline_state, :entity_module, :b, 7, context)

# Execute.
r = Noizu.RuleEngine.ScriptProtocol.render(script, inline_state, context)
```

# A script that hosts state externally
```
 external_state = AgentStateManager.new(internal_state)
 State lives outside of the host process and can be shared between multiple scripts.
 
 # Other processes can access and set values on the external state at will
 spawn fn -> 
    Noizu.RuleEngine.StateProtocol.put!(external_state, :entity_module, :b, 7, context)
 end  
 
 # Run script same as before
 r = Noizu.RuleEngine.ScriptProtocol.render(script, external_state, context)
 
 # Peek at internal state
 {b_value, _full_state} = Noizu.RuleEngine.StateProtocol.get!(external_state, :entity_module, :b, context) 
```

## Additional Documentation
* [Api Documentation](http://noizu.github.io/RuleEngine)
