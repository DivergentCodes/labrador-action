# labrador-action (alpha)

Pull values (e.g. secrets and config) from remote stores, and automatically
load them as environment variables in your workflow using
[labrador](https://github.com/DivergentCodes/labrador). No need to copy values
between remote stores and pipelines, use more than one store, or synchronize values.

A primary use case is secretless pipelines. By combining this with Github Actions'
[OpenID Connect support](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect),
you can have zero secrets stored in your pipelines, including cloud API keys.

## Features

- **Configuration file**: Using an optional `.labrador.yaml` file, your Github
  workflow can load all required environment variables with a single
  line of configuration ([example](#using-a-labrador-configuration-file)).
  The file is portable and consistent across other CI providers, environments,
  and anywhere that Labrador can run. Use an alternate config file for the pipeline
  with the `inputs.config` option
  ([example](#using-an-alternate-labrador-configuration-file)).
- **Wildcard paths**: For supported value stores, use a single wildcard resource
  path to recursively load all child values into the workflow
  ([example](#fetch-multiple-values-from-ssm-parameter-store-using-wildcard-paths)).
- **Multi-system fetching**: Labrador will pull from multiple remote stores in a
  single run. This can alleviate infrastructure migrations, multi-team situations,
  and other "real world quirks."
- **Use standard environment variables**: This action will read AWS environment
  variables for default configuration and authentication.
- **Setting environment variables**: Rather than having one step to pull the
  variables and then requiring another step to load them into environment variables,
  this action automatically sets them.

### Supported Value Stores

- **AWS SSM Parameter Store**: this action can pull individual parameters, or recursively pull a wildcard path with all child variables, as individual environment variables.
- **AWS Secrets Manager**: this action can pull all key/value pairs in a single secret are loaded as individual environment variables.


## Quickstart

Make sure that your Github Actions workflow has access to the target value stores,
ideally using Github Action's support for
[OpenID Connect to cloud providers](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect).

```yaml
# .github/workflows/my-workflow.yaml

...snip...

      - uses: DivergentCodes/labrador-action@v0.0.4
        with:
          # The base path that Labrador will recursively fetch parameters from.
          aws-ssm-parameter: /path/to/this/pipeline/specific/params/*
          # The name of the secret that Labrador will fetch values from.
          aws-sm-secret: name/of/the/secret

...snip...
```

## Example Usage

### Using a Labrador Configuration File

With a `.labrador.yaml` configuration file in your repository, all environment
variables can be loaded into your workflow with a single line. For more details,
look at the
[example Labrador configuration file](https://github.com/DivergentCodes/labrador/blob/main/.labrador.example.yaml).

```yaml
# .github/workflows/my-workflow.yaml

...snip...

      - uses: DivergentCodes/labrador-action@v0.0.4

...snip...
```

### Using an Alternate Labrador Configuration File

You can have multiple Labrador configurations for different environments, for
instance: local development, QA, CI/CD, and production. To use a specific
configuration file with the action, use `inputs.config`.

```yaml
# .github/workflows/my-workflow.yaml

...snip...

      - uses: DivergentCodes/labrador-action@v0.0.4
        with:
          # Specific Labrador config file for this workflow.
          config: .labrador.ci.yaml

...snip...
```


### Fetch Values From SSM Parameter Store Using Wildcard Paths

One wildcard path can be used to fetch all parameters for a workflow. This can
mean less maintenance to update workflows when values change.

```yaml
# .github/workflows/my-workflow.yaml

...snip...

      - uses: DivergentCodes/labrador-action@v0.0.4
        with:
          aws-ssm-parameter: |
            /path/to/global/shared/params/*
            /path/to/this/pipeline/specific/params/*

...snip...
```

### Fetch Values from a Different AWS Region

You might have a situation where all configuration is stored in the `us-east-2`
region, but your workflow is deploying things to `us-west-1`. This action will
accept an explicit AWS region override.

```yaml
# .github/workflows/my-workflow.yaml

...snip...

env:
  AWS_REGION: us-west-1

...snip...

      - uses: DivergentCodes/labrador-action@v0.0.4
        with:
          aws-region: us-east-2
          aws-sm-secret: name/of/secret/

...snip...
```

## Reference

Here are all the action inputs available through `with`:

Input               | Default   | Required | Description
--------------------|-----------|----------|-------------
`aws-region`        | `""`      | No       | Explicit AWS region, if different from configured environment variables.
`aws-sm-secret`     | `""`      | No       | One or more AWS Secrets Manager secrets to fetch values from.
`aws-ssm-parameter` | `""`      | No       | One or more AWS SSM Parameter Store paths to fetch values from. Each can be individual or wildcard.
`config`            | `""`      | No       | Specify an alternative Labrador config file in the repo.
`install-only`      | `"false"` | No       | Only install the `Labrador` binary in the workflow.
`set-env`           | `"true"`  | No       | Set the fetched values as workflow environment variables.


## Relevant Projects

- [segmentio/chamber](https://github.com/segmentio/chamber)
- [hashicorp/vault-action](https://github.com/hashicorp/vault-action)
- [aws-actions/aws-secretsmanager-get-secrets](https://github.com/aws-actions/aws-secretsmanager-get-secrets)
- [google-github-actions/get-secretmanager-secrets](https://github.com/google-github-actions/get-secretmanager-secrets)
