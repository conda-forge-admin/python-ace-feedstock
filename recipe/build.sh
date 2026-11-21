#!/bin/bash
set -ex

# Recent compiler activation scripts put bare tool names into CMAKE_ARGS
# (e.g. -DCMAKE_AR=x86_64-conda-linux-gnu-ar). CMake resolves such relative
# paths against the build directory, so archiving and stripping fail.
# Rewrite them to absolute paths found on PATH.
read -ra raw_args <<< "${CMAKE_ARGS}"
args=()
for arg in "${raw_args[@]}"; do
  if [[ "${arg}" =~ ^(-DCMAKE_[A-Z_]*(AR|RANLIB|STRIP|LINKER|NM|OBJCOPY|OBJDUMP))=([^/].*)$ ]]; then
    tool_path="$(command -v "${BASH_REMATCH[3]}" || true)"
    if [[ -n "${tool_path}" ]]; then
      arg="${BASH_REMATCH[1]}=${tool_path}"
    fi
  fi
  args+=("${arg}")
done
export CMAKE_ARGS="${args[*]}"

${PYTHON} -m pip install . -vv --no-deps --no-build-isolation
