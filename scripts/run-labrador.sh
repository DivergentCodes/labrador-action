#!/bin/bash


# Determine outfile. Use local file for development,
# and env file in Github Actions.
if [ -n $GITHUB_ENV ]; then
    GHACTION_LABRADOR_OUTFILE="$GITHUB_ENV"
else
    GHACTION_LABRADOR_OUTFILE=./labrador-outfile.txt
fi

# Assemble optional CLI args.
OPTIONAL_ARGS=""
if [ -n "$GHACTION_LABRADOR_CONFIG_FILE" ]; then
    echo "Using alternate config file: $GHACTION_LABRADOR_CONFIG_FILE"
    OPTIONAL_ARGS=" --config $GHACTION_LABRADOR_CONFIG_FILE "
fi

if [ -n "$GHACTION_LABRADOR_AWS_SSM_PARAM" ]; then
    echo "Received AWS SSM Parameters to fetch: $GHACTION_LABRADOR_AWS_SSM_PARAM"
fi

# Run Labrador.
echo "./labrador fetch --verbose --outfile $GHACTION_LABRADOR_OUTFILE $OPTIONAL_ARGS"
./labrador fetch --verbose --outfile "$GHACTION_LABRADOR_OUTFILE" $OPTIONAL_ARGS
