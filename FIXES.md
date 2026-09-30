# Fixes

**## Problem 1**

File: Dockerfile

Fix: Image tag

Why it matters: Not using a fixed version. Image can change overtime, resulting in different builds which are unaccounted for.

**## Problem 2**

File: Dockerfile

Fix: Stages

Why it matters: More efficient to have seperate build and runtime stages. Maven is only required at the build stage to compile and package JAR, not at runtime unlike the JRE which executes the JAR. Results in a lgihter weight image

**## Problem 3**

File: Dockerfile

Fix: Docker layer caching

Why it matters: Only pom.xml is required to resolve Maven dependencies. It is more efficent for docker to only re-run the maven layer only if depedency changes have been made, rather than non-build related files.

**## Problem 4**

File: Dockerfile

Fix: Run application as a user

Why it matters: Unecessary amounts of permission given to application to run as root by default. Changing to use a non-root user follows principle of least permission. Limits what the application can modify if compromised.

**## Problem 5**

File: pom.xml

Fix: Log4j version updated

Why it matters: Log4j 2.14.1 is an outdated and vulnerable version affected by Log4Shell (CVE-2021-44228). Updating it reduces the application's exposure to known security vulnerabilities.

**## Problem 6**

File: azure-pipelines.yml

Fix: Remove 'continueOnError: true'

Why it matters: Removing condition ensures test failures prevent deployment

**## Problem 7**

File: azure-pipelines.yml

Fix: Trigger conditions

Why it matters: Pull Requests targeting main build, test and run coverage checks without deploying. Once changes are merged into main, the pipeline can push the image and proceed through the dev and production deployment stages. Allowing for changes to be validated before merging, while avoiding unnecessary deployments from Pull Requests, saving time and resources.

**## Problem 8**

File: azure-pipelines.yml

Fix: Image build and push order

Why it matters: Broken or vulnerable images reached the registry

**## Problem 9**

File: azure-pipelines.yml

Fix: Deployments

Why it matters: No gate, no staging

**## Problem 10**

File: azure-pipelines.yml

Fix: Image tag

Why it matters: Mutable tag: can't tell what's running or roll back

**## Problem 11**

File: azure-pipelines.yml

Fix: AzureWebApp task

Why it matters: Task did not do what it looked like

**## Problem 12**

File: azure-pipelines.yml

Fix: Coverage and vulnerability scanning

Why it matters: Required by brief; also catches known CVEs pre-deploy

**## Problem 13**

File: azure-pipelines.yml

Fix: Deployment window

Why it matters: Business rule; fixed-UTC would be wrong half the year

**## Problem 14**

File: azure-pipelines.yml

Fix: Smoke test

Why it matters: Deploy "succeeded" even if app was down

**## Problem 15**

File: azure-pipelines.yml

Fix: Pinned image, stages, Maven cache

Why it matters: Reproducibility, clarity, speed

**## Problem 16**

File: azure-pipelines.yml

Fix: Pipeline variables

Why it matters: A rename no longer means hunting through the file; a mismatch points deploys at resources that don't exist

**## Problem 17**

File: pom.xml

Fix: Spring Boot version

Why it matters: No more free security patches. Upgrade to 3.x is the real fix

**## Problem 18**

File: infra/main.tf

Fix: ACR authentication

Why it matters: Starter could not actually pull from a private registry, and admin user is a shared static password

**## Problem 19**

File: infra/main.tf

Fix: HTTPS

Why it matters: Menu/price traffic allowed over plain HTTP

**## Problem 20**

File: infra/main.tf

Fix: Image tag

Why it matters: Mutable tag, and Terraform would fight the pipeline over what is deployed

**## Problem 21**

File: infra/main.tf

Fix: Key Vault, App Insights, Log Analytics and alert

Why it matters: Required by brief; no way to see or be told about failures

**## Problem 22**

File: infra/main.tf

Fix: State backend

Why it matters: Local state is lost or overwritten, cannot be shared in a pipeline, and dev/prod could collide

**## Problem 23**

File: infra/main.tf

Fix: Terraform and provider versions

Why it matters: Reproducible runs

**## Problem 24**

File: infra/main.tf

Fix: Health check, always_on and WEBSITES_PORT

Why it matters: App Service cannot detect an unhealthy instance; container port may not be detected; B1+ idles without always_on

**## Problem 25**

File: infra/main.tf

Fix: Per-environment settings

Why it matters: Prod-only settings need an explicit switch per env, and the pipeline needs names it can match

**## Problem 26**

File: infra/main.tf

Fix: Tags and variable validation

Why it matters: Cost tracking and typo protection

**## Problem 27**

File: infra/main.tf

Fix: Resource naming

Why it matters: ACR names are global, so a clearer prefix avoids collisions; RG and app names no longer blur

**## Problem 28**

File: infra/main.tf

Fix: Secret handling

Why it matters: Secrets stay out of code, state and pipeline; no credentials to rotate in the app
