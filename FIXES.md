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

## Design Choices

The pipeline uses separate stages for build, image scanning and push, dev deployment, and production deployment. Maven caching is used to reduce build times, and Docker images use the Azure DevOps Build ID as an immutable tag. The Dockerfile uses separate build and runtime stages and runs the application as a non-root user.

Azure Container Registry uses managed identity rather than admin credentials. Key Vault is used for application secrets. Terraform uses remote state with separate state keys for each environment. Production requires manual approval before deployment.

## Not fixed / known limits

* **Spring Boot 2.7.18** is past open-source support. Real fix is a 3.x upgrade. Trivy may flag CVEs only that upgrade resolves.

* **Not run against Azure.** Terraform `validate`, the pipeline and the alert still need a real run (see test plan).

* **Assumed app port 8080** and that the app reads `DB_PASSWORD`. Confirm in the source and adjust `WEBSITES_PORT` / `secret_app_settings`.

* **Names are duplicated** between tfvars and the pipeline variables block; they must be changed together.

- **Not run against Azure.** Terraform was validated with `terraform validate`, but `terraform plan/apply`, the pipeline and the alert still need a real run against Azure.

## pom.xml

Spring Boot 2.7.18 is end of OSS support and was not changed. The real fix is to upgrade to 3.x.

JaCoCo is already configured in the pom, so the pipeline runs `clean test` instead of calling JaCoCo goals itself (avoids a duplicate agent).

## Remaining Work

If continuing beyond the 3-hour limit, I would have:

- Implemented `check-coverage.ps1` to enforce the 70% coverage threshold.
- Implemented `check-deploy-window.ps1` to enforce the 06:00–10:00 UK production deployment block.
- Implemented `smoke-test.ps1` to test `/health` and `/menu/LHR-T5-001` with retries.
- Added and tested the production HTTP 5xx alert.
- Run `terraform validate`, `terraform plan`, and, where Azure access was available, apply the infrastructure and run the pipeline end-to-end.
- Verify the assumed application port and `DB_PASSWORD` configuration against the application source.
- Test the deployment and rollback behaviour in Azure.

### Assumptions and Trade-offs

- The application is assumed to listen on port 8080 and consume `DB_PASSWORD`.
- The solution uses separate dev and prod Azure resources rather than designing the full multi-country architecture.
- Spring Boot 2.7.18 was left unchanged because upgrading to Spring Boot 3.x could require application-level changes and testing.
- The production alert and PowerShell scripts were identified but not fully implemented within the time limit.

## Scaling to 38 Countries

I would use reusable Terraform modules to deploy the service consistently across multiple Azure regions. Each country or region would have its own environment configuration, secrets and Terraform state where required.

Azure Front Door could provide global routing to regional deployments. Monitoring would be centralised while retaining regional metrics and alerts. Deployments would be rolled out progressively across regions rather than deploying to all countries simultaneously, as specified in the 1st stage interview.

I would also consider data residency and local compliance requirements, regional disaster recovery, autoscaling, DNS and TLS management, and per-region cost monitoring.

## Areas to Explore Further

- Multi-region Azure architecture for operating across 38 countries.
- Data residency and country-specific compliance requirements.
- Automated rollback and deployment strategies.
- High availability and disaster recovery.
- Further testing, including integration and end-to-end testing.
- Cost optimisation at larger scale.