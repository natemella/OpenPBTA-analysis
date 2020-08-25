#!/bin/bash
# Module author: Komal S. Rathi
# 2020

# This script runs the steps for molecular subtyping of Medulloblastoma samples

set -e
set -o pipefail

# This option controls whether on not the step that generates the MB only
# files gets run -- it will be turned off in CI
SUBSET=${OPENPBTA_SUBSET:-1}

# This script should always run as if it were being called from
# the directory it lives in.
script_directory="$(perl -e 'use File::Basename;
  use Cwd "abs_path";
  print dirname(abs_path(@ARGV[0]));' -- "$0")"
cd "$script_directory" || exit


if [ "$SUBSET" -gt "0" ]; then
  # filter to MB samples and/or batch correct
  Rscript --vanilla 00-filter-and-batch-correction.R \
  --batch_col RNA_library \
  --output_prefix medulloblastoma-exprs \
  --output_dir input
fi

# classify MB subtypes
Rscript --vanilla 01-classify-mb.R \
--corrected_mat input/medulloblastoma-exprs-batch-corrected.rds \
--uncorrected_mat input/medulloblastoma-exprs.rds \
--output_prefix mb-classified