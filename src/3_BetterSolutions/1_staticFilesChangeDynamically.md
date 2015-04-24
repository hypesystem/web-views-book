Static Files that Change Dynamically
====================================

Basically an overview of static-page-blog, how it works, allows static pages to change dynamically.

The result is API calls that do this:

1. Calculate/execute
2. Render results
3. Respond

Possible Improvements
---------------------

### Render after responding

This can be improved by not pausing to render the results before responding.
This limitation was, in the original project, imposed by PHP.
By using a better tool for the job, ie. node.js, this can easily be changed.

Rendering results and responding could happen in parallel, or responding could happen first, closing the communication, then followed by server-side rendering. This would give faster responses.

I think we should write a quick example that does this for some API calls in the blog (on a branch), and compare the results.

### Separate concerns with event sourcing

Event sourcing would allow the system to react in different ways.
The API call would basically trigger an event and respond.
All the business logic would happen as a result of the event.
The business logic would also trigger another event.
The render would then occur as a result of the last event.

This would give way to a more natural separation of concerns, and solves many of the issues with the static-page-blog, primarily the bad cohesion.

With event sourcing, the business logic code would be completely out in the back with only two types of hooks to the presentation layer:

- A user did something
- Something changed on the business side that requires a re-render.

