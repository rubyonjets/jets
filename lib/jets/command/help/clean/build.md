Removes the build files that jets creates. Essentially, deletes `/tmp/jets`. This will remove all build files for all jets projects. This is safe as jets uses `/tmp/jets` merely as a cache to speed up incrementally builds. Cleaning this out can clean up cruft in the `/tmp/jets` directory that builds over time.

## Example

    jets clean:build