Q: Is it slower using a node shim?
Yes, the node shim adds a little bit of overhead. The overhead is of the node shim is about 500ms with a function configured to use 1.5GB of RAM. If your application requires faster response times than than then you will have to wait for official ruby support from AWS.

