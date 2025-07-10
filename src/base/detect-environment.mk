# Used to set QEMU settings
IS_WSL := $(shell \
  if grep -qEi "(Microsoft|WSL)" /proc/version 2>/dev/null; then echo 1; \
  else echo 0; fi \
)