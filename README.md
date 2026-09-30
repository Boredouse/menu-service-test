# SSP Menu Service, take-home exercise

## Scenario

Point-of-sale systems in SSP outlets call this Menu Service to get the
current menu and prices for a unit. Your job is to build, test, secure
and deploy the service to Azure through Azure DevOps. One rule applies:
SSP blocks production deployments between 06:00 and 10:00 UK time,
because breakfast is the busiest trading period.

## What you have

- A Spring Boot API built with Maven, with two endpoints:
  `GET /menu/{unitId}` and `GET /health`.
- A starter `Dockerfile`, a starter `azure-pipelines.yml`, and a starter
  `infra/main.tf`. These starter files contain problems.

## Time limit

Spend no more than 3 hours. When you reach 3 hours, stop and list your
next steps at the bottom of this file.

## Tasks

1. Review and fix. Find the problems in the starter files. Fix each one
   and record what you changed and why it matters in `FIXES.md`.
2. Containerise. Write a multi-stage `Dockerfile`. Build with Maven in
   the first stage and run on a slim Java runtime image in the second.
   Run the app as a non-root user.
3. Infrastructure as Code. Define an Azure Container Registry, an App
   Service for Linux containers, a Key Vault, and Application Insights
   with a Log Analytics workspace, using Terraform. Use one
   configuration with a dev and a prod tfvars file.
4. Pipeline. Write a multi-stage `azure-pipelines.yml`: build and unit
   test with Maven, publish test results and coverage, fail the build
   below 70% coverage, scan the image for vulnerabilities, push to the
   registry, deploy to dev on every merge to main, and deploy to prod
   after a manual approval. Enforce the 06:00 to 10:00 block for prod.
5. Smoke test. Write a PowerShell script the pipeline runs after each
   deployment. Call `/health` and `/menu/LHR-T5-001`, retry up to 5
   times with 10 seconds between attempts, and exit non-zero on
   failure.
6. Monitoring. Add an alert that fires when prod returns more than 10
   HTTP 5xx responses in 5 minutes.

## What to submit

- A link to this repository with full commit history. Commit as you
  work.
- `FIXES.md`, covering every problem you found.
- This `README.md`, updated with your design choices, three things you
  left out and why, and what you would change to run this service
  across 38 countries.
- Optional: a screenshot of a successful pipeline run.

## Use of AI tools

You can use AI tools while you work. In the follow-up session you will
walk through every file and answer questions without AI help, and make
live changes to your solution while sharing your screen. Submit only
work you understand.
