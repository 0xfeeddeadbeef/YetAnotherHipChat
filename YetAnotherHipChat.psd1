<#
   Copyright 2017 George Chakhidze

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
#>

@{

ModuleToProcess = 'YetAnotherHipChat.psm1'
RootModule = 'YetAnotherHipChat.psm1'

# Version number of this module.
ModuleVersion = '0.1.0'

# ID used to uniquely identify this module
GUID = 'C3D5486F-9E0D-4EC8-AD7B-A54C6989F067'

# Author of this module
Author = 'George Chakhidze'

# Company or vendor of this module
CompanyName = 'George Chakhidze'

# Copyright statement for this module
Copyright = '(c) 2017 George Chakhidze. All rights reserved.'

# Description of the functionality provided by this module
Description = 'HipChat automation, simplistic and minimal.'

# Minimum version of the Windows PowerShell engine required by this module
PowerShellVersion = '4.0'

# Name of the Windows PowerShell host required by this module
# PowerShellHostName = ''

# Minimum version of the Windows PowerShell host required by this module
# PowerShellHostVersion = ''

# Minimum version of Microsoft .NET Framework required by this module
# DotNetFrameworkVersion = '4.0'

# Minimum version of the common language runtime (CLR) required by this module
# CLRVersion = ''

# Processor architecture (None, X86, Amd64) required by this module
# ProcessorArchitecture = ''

# Modules that must be imported into the global environment prior to importing this module
RequiredModules = @('Microsoft.PowerShell.Utility')

# Assemblies that must be loaded prior to importing this module
# RequiredAssemblies = @()

# Script files (.ps1) that are run in the caller's environment prior to importing this module.
# ScriptsToProcess = @()

# Type files (.ps1xml) to be loaded when importing this module
# TypesToProcess = @()

# Format files (.ps1xml) to be loaded when importing this module
FormatsToProcess = @('YetAnotherHipChat.ps1xml')

# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
# NestedModules = @()

# Functions to export from this module
FunctionsToExport = @('Send-PrivateMessage', 'Get-User', 'Get-AllUsers', 'New-Room', 'Send-RoomMessage', 'Send-RoomNotification')

# Cmdlets to export from this module
# CmdletsToExport = '*'

# Variables to export from this module
# VariablesToExport = '*'

# Aliases to export from this module
# AliasesToExport = '*'

# List of all modules packaged with this module
# ModuleList = @()

# List of all files packaged with this module
# FileList = @()

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = @('HipChat')

        # A URL to the license for this module.
        LicenseUri = 'https://github.com/0xfeeddeadbeef/YetAnotherHipChat/blob/master/LICENSE'

        # A URL to the main website for this project.
        ProjectUri = 'https://github.com/0xfeeddeadbeef/YetAnotherHipChat'

        # A URL to an icon representing this module.
        IconUri = 'https://www.hipchat.com/favicon-96x96.png'

        # ReleaseNotes of this module
        # ReleaseNotes = ''

    } # End of PSData hashtable

} # End of PrivateData hashtable

# HelpInfo URI of this module
# HelpInfoURI = ''

DefaultCommandPrefix = 'HipChat'

}

