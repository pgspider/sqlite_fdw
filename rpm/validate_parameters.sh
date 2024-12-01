#!/bin/bash

################################################################################
#
# This script validates user supplied parameters.
# Not 100% accurate but somewhat avoids the risk.
#
# Usage: ./validate_parameters.sh [param 1] [param 2] [param 3] ...
#
################################################################################

# Check if no parameters are passed
if [ "$#" -eq 0 ]; then
  echo "Usage: $0 param1 param2 param3 ..."
  exit 1
fi

# Create a list of variables from the passed parameters
required_vars=("$@")

# List of variables that must be numeric
number_vars=(
"PACKAGE_RELEASE_VERSION"
"PGSPIDER_BASE_POSTGRESQL_VERSION"
"SQLITE_FDW_PROJECT_ID"
"PGSPIDER_PROJECT_ID"
"PGSPIDER_RPM_ID"
"SQLITE_FDW_RELEASE_ID"
"SQLITE_YEAR"
)

# List of variables to check for package version format
version_vars=(
"SQLITE_VERSION"
"SQLITE_FDW_RELEASE_VERSION"
)

# List of missing variables
missing_vars=()

# Check each variable to see if it is defined.
for var in "${required_vars[@]}"; do
  if [[ "$var" == "PGSPIDER_RPM_ID" ]]; then
    continue
  fi

  if [[ "$var" == "POSTGRESQL_VERSION" ]]; then
    # Check if the value does not conform to the expected version format
    if ! [[ "${!var}" =~ ^[0-9]+\.[0-9]+-[0-9]+$ ]]; then
      echo "Error: Variable '$var' with value '${!var}' is not in valid version format x.y-z."
      missing_vars+=("$var")
    fi
  fi

  if [[ "$var" == "PGSPIDER_RELEASE_VERSION" ]]; then
    # Check if the value does not conform to the expected version format
    if ! [[ "${!var}" =~ ^[0-9]+\.[0-9]+\.[0-9]+-[0-9]+$ ]]; then
      echo "Error: Variable '$var' with value '${!var}' is not in valid version format x.y.z-w."
      missing_vars+=("$var")
    fi
  fi

  if [[ "$var" == "PGSPIDER_RELEASE_PACKAGE_VERSION" ]]; then
    # Check if the value does not conform to the expected version format
    if ! [[ "${!var}" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
      echo "Error: Variable '$var' with value '${!var}' is not in valid version format x.y.z."
      missing_vars+=("$var")
    fi
  fi

  if [ -z "${!var}" ]; then
    echo "Error: Required variable '$var' is not set or empty."
    missing_vars+=("$var")
  else
    # Check if variable in list must be numeric
    if [[ " ${number_vars[@]} " =~ " $var " ]]; then
      # Check if value is not a number
      if ! [[ "${!var}" =~ ^[0-9]+$ ]]; then
        echo "Error: Variable '$var' with value '${!var}' is not a valid number."
        missing_vars+=("$var")
      fi
    fi

    # Check if variable in list must be numeric
    if [[ " ${number_vars[@]} " =~ " $var " ]]; then
      # Check if value is not a number
      if ! [[ "${!var}" =~ ^[0-9]+$ ]]; then
        echo "Error: Variable '$var' with value '${!var}' is not a valid number."
        missing_vars+=("$var")
      fi
    fi

    # Check if variable is in list to check package version format
    if [[ " ${version_vars[@]} " =~ " $var " ]]; then
      # Check if the value does not conform to the expected version format
      if ! [[ "${!var}" =~ ^[0-9]+\.[0-9]+\.[0-9]+(\.[0-9]+)?$ ]]; then
        echo "Error: Variable '$var' with value '${!var}' is not in valid version format (x.y.z or x.y.z.w)."
        missing_vars+=("$var")
      fi
    fi
  fi
done

# If any variable is missing, report and exit with error code
if [ ${#missing_vars[@]} -gt 0 ]; then
  exit 1
fi
