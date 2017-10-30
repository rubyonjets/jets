functions order and structure:
1. lambda: (handlers/functions/posts.create - posts.js)
2. handlers/functions/posts.js (create function)
3. processors/function_processor.rb (event, context, handler)
4. app/functions/posts.rb (create method)

controllers order and structure before ruby support:
1. lambda: (handlers/controllers/posts.create - posts.js)
2. handlers/controllers/posts.js (create function)
3. processors/controller_processor.rb (event, context, handler)
4. app/controllers/posts_controller.rb (create method)

controllers order and structure after ruby support:
1. lambda: (handlers/controllers/posts.create - posts.rb)
2. handlers/controllers/posts.js (create function)
3. processors/controller_processor.rb (event, context, handler)
4. app/controllers/posts_controller.rb (create method)

workers order and structure:
1. lambda: (handlers/workers/posts.create)
2. handlers/workers/posts.js (create function)
3. processors/worker_processor.rb (event, context, handler)
4. app/worker/posts_worker.rb (create method)

Misc
* handler must be generated in the shim, not in event or context. Only way to know what function, controller or worker code to call.
* config/routes.rb for controllers
* config/events.yml for workers
