# PS.Log

![validate](https://github.com/jjohns-dev/PS.Log/actions/workflows/ci.yml/badge.svg)
![PSScriptAnalyzer](https://github.com/jjohns-dev/PS.Log/actions/workflows/pssa-sarif.yml/badge.svg)
![License](https://img.shields.io/github/license/jjohns-dev/PS.Log)
![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B%20%7C%20Core-blue)

PS.Log is a lightweight PowerShell module for structured trace logging. It provides a consistent set of log levels — `Info`, `Warn`, `Error`, and `Debug` — with no external dependencies, making it suitable for use inside secure or air-gapped environments. Compatible with Windows PowerShell 5.1 and PowerShell Core.

## Installation

PS.Log is not published to the PowerShell Gallery. Install it by cloning the repository:

```powershell
git clone https://github.com/jjohns-dev/PS.Log.git
Import-Module ./PS.Log/PS.Log.psd1
```

To make the module available in all sessions, copy the module folder to a path in `$env:PSModulePath`:

```powershell
Copy-Item -Path ./PS.Log -Destination "$HOME\Documents\PowerShell\Modules\PS.Log" -Recurse
```

## Usage

`Start-Log` creates the log file and returns its full path. Pass that path to every subsequent call.

```powershell
Import-Module PS.Log

$logPath = Start-Log -Directory "C:\Logs" -Name "app"
Write-LogInfo  -Path $logPath -Message "Application started"
Write-LogWarn  -Path $logPath -Message "Low disk space detected"
Write-LogError -Path $logPath -Message "Connection failed"
Write-LogDebug -Path $logPath -Message "Retrying in 5 seconds"
Stop-Log -Path $logPath
```

## Available Commands

| Command | Description |
|---|---|
| [`Start-Log`](Documentation/Start-Log.md) | Initializes a new log session and returns the log file path |
| [`Stop-Log`](Documentation/Stop-Log.md) | Closes the active log session |
| [`Write-LogInfo`](Documentation/Write-LogInfo.md) | Writes an informational entry |
| [`Write-LogWarn`](Documentation/Write-LogWarn.md) | Writes a warning entry |
| [`Write-LogError`](Documentation/Write-LogError.md) | Writes an error entry |
| [`Write-LogDebug`](Documentation/Write-LogDebug.md) | Writes a debug entry |

## Contributing

Contributions are welcome. Please read [CONTRIBUTING.md](CONTRIBUTING.md) for full details. Key points:

- For minor fixes (typos, docs), open a PR directly.
- For new functions or significant changes, open an issue first to discuss the proposal.
- Keep each PR focused on a single function or change to simplify review.
- Before submitting, ensure your changes pass all checks:

  ```powershell
  ./Build/build.ps1 -ResolveDependency -TaskList Test     # Pester tests
  ./Build/build.ps1 -ResolveDependency -TaskList Analyze  # PSScriptAnalyzer
  ```

  The test suite requires PowerShell 7.4+ (Pester 6 does not support Windows PowerShell), so CI exercises 7.4+ only. Windows PowerShell 5.1 is still expected to work, but is no longer verified.

- The repo includes a dev container for VS Code. Open the workspace in a devcontainer for a fully configured environment.

## License

This project is licensed under the terms of the [LICENSE](LICENSE) file.
