#!/usr/bin/bash
gh release create "v${FACTORIO_MODVERSION}" "${FACTORIO_MODPACKAGE}" -t "Version ${FACTORIO_MODVERSION}" -F changes.txt
rm changes.txt
