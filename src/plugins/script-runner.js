// script-runner OpenCode plugin
// Intercepts the /script command before the LLM sees it, runs the script via
// bash (or sh), and replaces output.parts with the execution details so the
// LLM can discuss the result.
import { existsSync } from "fs"
import { resolve } from "path"

export const ScriptRunnerPlugin = async ({ $, directory }) => {
  return {
    "command.execute.before": async (input, output) => {
      if (input.command !== "script") return

      // Normalise arguments — may be a string or an array
      const rawArgs =
        Array.isArray(input.arguments)
          ? input.arguments.join(" ")
          : (input.arguments ?? "")

      const trimmed = rawArgs.trim()

      if (!trimmed) {
        output.parts = [
          {
            type: "text",
            text: "[script-runner] Error: no script path provided.\nUsage: /script <path> [args...]",
          },
        ]
        return
      }

      const tokens = trimmed.split(/\s+/)
      const scriptPath = tokens[0]
      const scriptArgTokens = tokens.slice(1)

      // Resolve path relative to project root (absolute paths pass through)
      const resolvedPath = resolve(directory, scriptPath)

      if (!existsSync(resolvedPath)) {
        output.parts = [
          {
            type: "text",
            text: `[script-runner] Error: script not found: ${resolvedPath}`,
          },
        ]
        return
      }

      // Determine shell — prefer bash, fall back to sh
      let shell = "sh"
      try {
        const whichResult = await $`which bash`.quiet().nothrow()
        if (whichResult.exitCode === 0) {
          shell = whichResult.stdout.toString().trim() || "bash"
        }
      } catch {
        // keep sh
      }

      // Execute the script
      // Bun's $ template literal escapes each ${} as a single argument.
      // Use an array for scriptArgTokens so each arg is individually escaped.
      let result
      try {
        result = scriptArgTokens.length > 0
          ? await $`${shell} ${resolvedPath} ${scriptArgTokens}`.quiet().nothrow()
          : await $`${shell} ${resolvedPath}`.quiet().nothrow()
      } catch (err) {
        output.parts = [
          {
            type: "text",
            text: `[script-runner] Failed to execute script: ${err?.message ?? err}`,
          },
        ]
        return
      }

      const stdout = result.stdout?.toString().trim() || "(no output)"
      const stderr = result.stderr?.toString().trim() || "(no output)"
      const exitCode = result.exitCode ?? "unknown"

      const displayCmd = scriptArgTokens.length > 0
        ? `${shell} ${resolvedPath} ${scriptArgTokens.join(" ")}`
        : `${shell} ${resolvedPath}`

      output.parts = [
        {
          type: "text",
          text: [
            `[script-runner] Executed: ${displayCmd}`,
            `Working directory: ${directory}`,
            `Exit code: ${exitCode}`,
            "",
            "Stdout:",
            "```",
            stdout,
            "```",
            "",
            "Stderr:",
            "```",
            stderr,
            "```",
          ].join("\n"),
        },
      ]
    },
  }
}
