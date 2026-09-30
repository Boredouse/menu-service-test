# Fixes

List every problem you found in the starter files. For each one, note
the file, the fix, and why it matters for a service running across
3,000 outlets.

## Problem 1

File: Dockerfile
Fix: Image tag
Why it matters: Not using a fixed version. Image can change overtime, resulting in different builds which are unaccounted for.

## Problem 2

File: Dockerfile
Fix: Stages
Why it matters: More efficient to have seperate build and runtime stages. Maven is only required at the build stage to compile and package JAR, not at runtime unlike the JRE which executes the JAR. Results in a lgihter weight image

## Problem 3

File: Dockerfile
Fix: Docker layer caching
Why it matters: Only pom.xml is required to resolve Maven dependencies. It is more efficent for docker to only re-run the maven layer only if depedency changes have been made,  rather than non-build related files.


## Problem 4

File: Dockerfile
Fix: Run application as a user
Why it matters: Unecessary amounts of permission given to application to run as root by default. Changing to use a non-root user follows principle of least permission. Limits what the application can modify if compromised. 

## Problem 5

File:
Fix:
Why it matters:

## Problem 6

File:
Fix:
Why it matters:

