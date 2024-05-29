#!/usr/bin/env bash

# Read from stdin
cat > input.json && \

layout=$(jq -r '.layout' input.json) && \
jq -r '.program_input | join(" ")' input.json | tr -d '\n' > program_input.txt && \
jq '.program' input.json > program.sierra.json && \

cairo1-run \
    --trace_file program_trace.trace \
    --memory_file program_memory.memory \
    --layout $layout \
    --proof_mode \
    --air_public_input program_public_input.json \
    --air_private_input program_private_input.json \
    --args_file program_input.txt \
    program.sierra.json \
    2>&1 > /dev/null && \

config-generator.py < program_public_input.json > cpu_air_params.json && \

stone \
    --public_input_file program_public_input.json \
    --private_input_file program_private_input.json \
    --prover_config_file cpu_air_prover_config.json \
    --parameter_file cpu_air_params.json \
    -generate_annotations \
    --out_file program_proof.json && \

cat program_proof.json
