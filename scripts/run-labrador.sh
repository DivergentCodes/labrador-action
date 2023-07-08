#!/bin/bash

GHACTION_LABRADOR_OUTFILE=./labrador-outfile.txt

OPTIONAL_ARGS=""

# --config
if [ -n "$GHACTION_LABRADOR_CONFIG_FILE" ]; then
    echo "Using alternate config file: $GHACTION_LABRADOR_CONFIG_FILE"
    OPTIONAL_ARGS=" --config $GHACTION_LABRADOR_CONFIG_FILE "
fi

# --aws-region
if [ -n "$GHACTION_LABRADOR_AWS_REGION" ]; then
    echo "Using alternate config file: $GHACTION_LABRADOR_AWS_REGION"
    OPTIONAL_ARGS=" --aws-region $GHACTION_LABRADOR_AWS_REGION "
fi

# --aws-param
# Loop over multi-line variables to read multiple resources from input.
if [ -n "$GHACTION_LABRADOR_AWS_SSM_PARAM" ]; then
    echo "Received AWS SSM Parameters to fetch:"
    while IFS= read -r resource; do
        if [[ -n $(echo $resource | tr -d '[:space:]') ]]; then
            echo "    $resource"
            OPTIONAL_ARGS="$OPTIONAL_ARGS --aws-param $resource "
        fi
    done <<< "$GHACTION_LABRADOR_AWS_SSM_PARAM"
fi

# --aws-secret
# Loop over multi-line variables to read multiple resources from input.
if [ -n "$GHACTION_LABRADOR_AWS_SM_SECRET" ]; then
    echo "Received AWS Secrets Manager secrets to fetch:"
    while IFS= read -r resource; do
        if [[ -n $(echo $resource | tr -d '[:space:]') ]]; then
            echo "    $resource"
            OPTIONAL_ARGS="$OPTIONAL_ARGS --aws-secret $resource "
        fi
    done <<< "$GHACTION_LABRADOR_AWS_SM_SECRET"
fi

# Run Labrador.
echo "./labrador fetch --verbose --outfile $GHACTION_LABRADOR_OUTFILE $OPTIONAL_ARGS"
./labrador fetch --verbose --outfile "$GHACTION_LABRADOR_OUTFILE" $OPTIONAL_ARGS

# Apply fetched values as action outputs.
if [ -n $GITHUB_OUTPUT ]; then
    cat "$GHACTION_LABRADOR_OUTFILE" >> "$GITHUB_OUTPUT"
fi

# Apply fetched values as environment variables.
if [[ $GHACTION_LABRADOR_SET_ENV = "true" ]]; then
    if [ -n $GITHUB_ENV ]; then
        cat "$GHACTION_LABRADOR_OUTFILE" >> "$GITHUB_ENV"
    fi
fi
