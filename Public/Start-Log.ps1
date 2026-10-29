function Start-Log {
    <#
    .SYNOPSIS
        Start a new log file
    .DESCRIPTION
        Start a new log file
    .PARAMETER Directory
        Output directory for log file. Parent directory must exist.
    .PARAMETER Name
        log file name
    .PARAMETER Frequency
        Frequency of new log file creation (defaults to daily)
    .PARAMETER Unique
        Ensure file name is unique
    .PARAMETER Append
        Append to existing log (does not create log file)
    .INPUTS
        System.String.
    .OUTPUTS
        System.String.
    .EXAMPLE
        PS C:\> Start-Log -Directory C:\temp -Name myLog
        Creates a new log file in the folder C:\temp
    .NOTES
        Status: Stable
    #>
    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([System.String])]
    Param(
        [Parameter(Mandatory, HelpMessage = 'Output directory for log file')]
        [ValidateNotNullOrEmpty()]
        [System.String] $Directory,

        [Parameter(Mandatory, HelpMessage = 'Log file name')]
        [ValidatePattern('^[\w.\-]+$')]
        [System.String] $Name,

        [Parameter(HelpMessage = 'New log file creation frequency')]
        [ValidateSet('Daily', 'Monthly', 'Yearly')]
        [System.String] $Frequency = 'Daily',

        [Parameter(HelpMessage = 'Ensure filename is unique')]
        [System.Management.Automation.SwitchParameter] $Unique,

        [Parameter(HelpMessage = 'Append to existing log')]
        [System.Management.Automation.SwitchParameter] $Append
    )
    Begin {
        # CREATE DIRECTORY IF NOT EXIST
        if ( -not (Test-Path -Path $Directory) ) { New-Item -Path $Directory -ItemType 'Directory' -Force | Out-Null }

        # SET DATE FORMAT FOR LOG NAME
        $dateFormat = switch ($Frequency) {
            'Yearly'  { '{0:yyyy}' -f (Get-Date) }
            'Monthly' { '{0:yyyy-MM}' -f (Get-Date) }
            'Daily'   { '{0:yyyy-MM-dd}' -f (Get-Date) }
        }

        # SET FILE NAME
        if ($PSBoundParameters.ContainsKey('Unique')) {
            $random = [System.IO.Path]::GetRandomFileName().Split('.')
            $fileName = '{0}_{1}_{2}.log' -f $dateFormat, $Name, $random[0]
        }
        else {
            $fileName = '{0}_{1}.log' -f $Name, $dateFormat
        }

        # SET FILE LOG PATH
        $filePath = Join-Path -Path $Directory -ChildPath $fileName

        # ADD INITIAL LOG ENTRY
        $logEntry = '{0} [INFO ] # - Begin Logging' -f (Get-Date).ToString($FORMAT)

        # SHOULD PROCESS
        if ($PSCmdlet.ShouldProcess($filePath)) {

            # CHECK FOR PATH ONLY PARAMETER
            if ( $PSBoundParameters.ContainsKey('Append') ) {
                # ADD NEW LOG ENTRY
                Add-Content -Path $filePath -Value $logEntry
            }
            else {
                # CHECK FOR EXISTANCE OF LOG FILE
                if ( Test-Path -Path $filePath ) {
                    Write-Error -Message ('Log file already exists: {0}' -f $filePath) -ErrorAction Stop
                }

                # ADD FIRST ENTRY TO LOG FILE
                Set-Content -Path $filePath -Value $logEntry -Confirm:$false
            }

            # RETURN FILEPATH
            return $filePath
        }
    }
}