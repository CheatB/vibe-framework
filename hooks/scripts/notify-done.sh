#!/bin/bash
# Desktop Notifications — уведомление на Mac когда Claude завершил работу

osascript -e 'display notification "Claude завершил задачу ✅" with title "Claude Code" sound name "Glass"' 2>/dev/null || true
