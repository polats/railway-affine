#!/bin/sh
# Generates AFFiNE copilot config.json from API key env vars.
# Supports: NVIDIA_NIM_API_KEY or GOOGLE_GEMINI_API_KEY (or both).
# Runs before the main server starts.

CONFIG_DIR="/root/.affine/config"
CONFIG_FILE="$CONFIG_DIR/config.json"

if [ -z "$NVIDIA_NIM_API_KEY" ] && [ -z "$GOOGLE_GEMINI_API_KEY" ]; then
  echo "[copilot] No AI API key set, copilot disabled."
  exit 0
fi

mkdir -p "$CONFIG_DIR"

# Build provider configs and scenario mappings
PROVIDERS=""
TEXT_MODEL=""

# --- NVIDIA NIM (OpenAI-compatible) ---
if [ -n "$NVIDIA_NIM_API_KEY" ]; then
  NIM_URL="${NVIDIA_NIM_BASE_URL:-https://integrate.api.nvidia.com/v1}"
  NIM_MODEL="${NVIDIA_NIM_MODEL:-moonshotai/kimi-k2.5}"
  TEXT_MODEL="$NIM_MODEL"

  PROVIDERS="\"openai\": {
        \"apiKey\": \"${NVIDIA_NIM_API_KEY}\",
        \"baseURL\": \"${NIM_URL}\",
        \"oldApiStyle\": true
      }"
  echo "[copilot] NIM provider: $NIM_MODEL at $NIM_URL"
fi

# --- Google Gemini ---
if [ -n "$GOOGLE_GEMINI_API_KEY" ]; then
  GEMINI_MODEL="${GOOGLE_GEMINI_MODEL:-gemini-2.5-flash}"

  if [ -n "$PROVIDERS" ]; then
    PROVIDERS="${PROVIDERS},
      "
  fi
  PROVIDERS="${PROVIDERS}\"gemini\": {
        \"apiKey\": \"${GOOGLE_GEMINI_API_KEY}\"
      }"

  # Use Gemini as default text model if NIM isn't set
  if [ -z "$TEXT_MODEL" ]; then
    TEXT_MODEL="$GEMINI_MODEL"
  fi

  echo "[copilot] Gemini provider: $GEMINI_MODEL"
fi

cat > "$CONFIG_FILE" <<EOF
{
  "copilot": {
    "enabled": true,
    "scenarios": {
      "override_enabled": true,
      "scenarios": {
        "chat": "${TEXT_MODEL}",
        "coding": "${TEXT_MODEL}",
        "quick_text_generation": "${TEXT_MODEL}",
        "complex_text_generation": "${TEXT_MODEL}",
        "quick_decision_making": "${TEXT_MODEL}",
        "polish_and_summarize": "${TEXT_MODEL}"
      }
    },
    "providers": {
      ${PROVIDERS}
    }
  }
}
EOF

echo "[copilot] Config written. Default model: $TEXT_MODEL"
