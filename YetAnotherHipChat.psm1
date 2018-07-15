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


Update-TypeData -TypeName 'HipChat.RoomData' -MemberType NoteProperty -Value $null -ErrorAction Ignore -MemberName 'Id'
Update-TypeData -TypeName 'HipChat.RoomData' -MemberType NoteProperty -Value $null -ErrorAction Ignore -MemberName 'IsArchived'
Update-TypeData -TypeName 'HipChat.RoomData' -MemberType NoteProperty -Value $null -ErrorAction Ignore -MemberName 'Name'
Update-TypeData -TypeName 'HipChat.RoomData' -MemberType NoteProperty -Value $null -ErrorAction Ignore -MemberName 'Privacy'
Update-TypeData -TypeName 'HipChat.RoomData' -MemberType NoteProperty -Value $null -ErrorAction Ignore -MemberName 'Version'

Update-TypeData -TypeName 'HipChat.RoomMessageData' -MemberType NoteProperty -Value $null -ErrorAction Ignore -MemberName 'Id'
Update-TypeData -TypeName 'HipChat.RoomMessageData' -MemberType NoteProperty -Value $null -ErrorAction Ignore -MemberName 'Timestamp'


filter GetValidMentionNameOrOther([string] $UserIdentity)
{
    if ([string]::IsNullOrEmpty($UserIdentity)) {
        return $UserIdentity
    }
    # Probably an email address:
    elseif ($UserIdentity.IndexOf('@') -gt 0) {
        return $UserIdentity
    }
    # If identity contains only numbers, it is a numeric ID then:
    elseif ($UserIdentity -match '^\d+$') {
        return $UserIdentity
    }
    # else it is a mention_name; prepend '@':
    elseif (-not ($UserIdentity.StartsWith('@'))) {
        return '@' + $UserIdentity
    }
    else {
        return $UserIdentity
    }
}


<#
.SYNOPSIS
Sends a private message to an user.

.DESCRIPTION
Sends a private message to an user. This cmdlet can only be called using an user access token.

.PARAMETER UserIdentity
The id, email address, or mention name (beginning with an '@') of the user to send a message to.

.PARAMETER Message
The message body.
Valid length range: 1 - 10000 characters.

.PARAMETER AccessToken
An user access token with required 'send_message' scope.

.PARAMETER Format
Determines how the message is treated by the server and rendered inside HipChat applications.

Html - Message is rendered as HTML and receives no special treatment. Must be valid HTML and entities must be escaped (e.g.: '&amp;' instead of '&'). May contain basic tags: a, b, i, strong, em, br, img, pre, code, lists, tables.

Text - Message is treated just like a message sent by a user. Can include @mentions, emoticons, pastes, and auto-detected URLs (Twitter, YouTube, images, etc).

Default is 'Text'.

.PARAMETER HostName
HipChat server fully qualified DNS hostname.

.PARAMETER UseSSL
Whether to use TLS when connecting to the HipChat server.

.PARAMETER Proxy
HTTP web proxy URL. If $null, default system proxy will be used.

.PARAMETER ProxyCredential
Credential to authenticate with HTTP proxy.

.PARAMETER ProxyUseDefaultCredentials
Use current thread's Windows identity to authenticate with HTTP proxy.

.EXAMPLE
Import-Module YetAnotherHipChat
Send-HipChatPrivateMessage -AccessToken 'YOUR-TOKEN-HERE' -EMail 'user@example.com' -Message 'Hello there!'

.EXAMPLE
You can store access token and host name in your PowerShell profile like this:

$Global:PSDefaultParameterValues['*-HipChat*:AccessToken'] = 'WRITE-YOUR-TOKEN-HERE'
$Global:PSDefaultParameterValues['*-HipChat*:HostName'] = 'api.hipchat.com'

and it will become available to all HipChat cmdlets automatically.
#>
function Send-PrivateMessage
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [Alias('ID', 'Identity', 'EMail', 'Mention', 'MentionName')]
        [string] $UserIdentity,

        [Parameter(Mandatory = $true, Position = 2)]
        [ValidateNotNullOrEmpty()]
        [ValidateLength(1, 10000)]
        [string] $Message,

        [Parameter(Mandatory = $true, Position = 3)]
        [ValidateNotNullOrEmpty()]
        [string] $AccessToken,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Text', 'Html')]
        [string] $Format = 'Text',

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('Server')]
        [string] $HostName,

        [Parameter()]
        [switch] $UseSSL,

        [Parameter()]
        [uri] $Proxy = $null,

        [Parameter()]
        [pscredential] $ProxyCredential = $null,

        [Parameter()]
        [switch] $ProxyUseDefaultCredentials = $false
    )

    Set-StrictMode -Version Latest
    $Local:ErrorActionPreference = 'Stop'

    if ([string]::IsNullOrWhiteSpace($Format)) { $Format = 'Text' }

    $Local:PostUrl = "$(if($UseSSL){'https'}else{'http'})://$HostName/v2/user/$(GetValidMentionNameOrOther $UserIdentity)/message"
    $Local:Headers = @{ Authorization = "Bearer $AccessToken" }

    $Local:BodyParams = @{
        message        = $Message
        notify         = 'true'
        message_format = $Format.ToLowerInvariant()
    }

    $Local:BodyJson = ConvertTo-Json -InputObject $Local:BodyParams -Compress

    Invoke-RestMethod -Uri $Local:PostUrl -Method Post -UseBasicParsing -Headers $Local:Headers -Body $Local:BodyJson -ContentType 'application/json' -Proxy $Proxy -ProxyCredential $ProxyCredential -ProxyUseDefaultCredentials:$ProxyUseDefaultCredentials
}


function Get-User
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [Alias('ID', 'Identity', 'EMail', 'Mention', 'MentionName')]
        [string] $UserIdentity,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $AccessToken,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('Server')]
        [string] $HostName,

        [Parameter()]
        [switch] $UseSSL,

        [Parameter()]
        [uri] $Proxy = $null,

        [Parameter()]
        [pscredential] $ProxyCredential = $null,

        [Parameter()]
        [switch] $ProxyUseDefaultCredentials = $false
    )

    Set-StrictMode -Version Latest
    $Local:ErrorActionPreference = 'Stop'

    $Local:GetUrl = "$(if($UseSSL){'https'}else{'http'})://$HostName/v2/user/$(GetValidMentionNameOrOther $UserIdentity)"
    $Local:Headers = @{ Authorization = "Bearer $AccessToken" }

    $Local:User = Invoke-RestMethod -Uri $Local:GetUrl -Method Get -UseBasicParsing -Headers $Local:Headers -ContentType 'application/json' -Proxy $Proxy -ProxyCredential $ProxyCredential -ProxyUseDefaultCredentials:$ProxyUseDefaultCredentials

    # Need custom type name for YetAnotherHipChat.ps1xml formatting tables to work:
    $Local:User.PSTypeNames.Add('HipChatGetUserResult')

    Write-Output -InputObject $Local:User
}


function Get-AllUsers
{
    [CmdletBinding(SupportsPaging = $true)]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $AccessToken,

        [Parameter()]
        [switch] $IncludeGuests = $false,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('Server')]
        [string] $HostName,

        [Parameter()]
        [switch] $UseSSL,

        [Parameter()]
        [uri] $Proxy = $null,

        [Parameter()]
        [pscredential] $ProxyCredential = $null,

        [Parameter()]
        [switch] $ProxyUseDefaultCredentials = $false
    )

    Set-StrictMode -Version Latest
    $Local:ErrorActionPreference = 'Stop'

    $Local:QueryParams = "start-index=$($PSCmdlet.PagingParameters.Skip)&max-results=$($PSCmdlet.PagingParameters.First)&include-guests=$($IncludeGuests.ToBool().ToString().ToLowerInvariant())"
    $Local:GetUrl = "$(if($UseSSL){'https'}else{'http'})://$HostName/v2/user?$($Local:QueryParams)"
    $Local:Headers = @{ Authorization = "Bearer $AccessToken" }

    $Local:Users = Invoke-RestMethod -Uri $Local:GetUrl -Method Get -UseBasicParsing -Headers $Local:Headers -ContentType 'application/json' -Proxy $Proxy -ProxyCredential $ProxyCredential -ProxyUseDefaultCredentials:$ProxyUseDefaultCredentials

    # Need custom type name for YetAnotherHipChat.ps1xml formatting tables to work:
    $Local:Users.items | ForEach-Object { $_.PSTypeNames.Add('HipChatGetAllUsersResult') }

    if ($PSCmdlet.PagingParameters.IncludeTotalCount) {
        Write-Output -InputObject $PSCmdlet.PagingParameters.NewTotalCount((($Local:Users.items) | Measure-Object | Select-Object -ExpandProperty 'Count'), 1.0)
    }

    Write-Output -InputObject ($Local:Users.items)
}


function New-Room
{
    [CmdletBinding()]
    [OutputType('HipChat.RoomData')]
    param (
        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [ValidateLength(1, 50)]
        $Name,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Public', 'Private')]
        [string] $Privacy = 'Public',

        [Parameter()]
        [string] $Topic = $null,

        [Parameter()]
        [switch] $AllowGuestAccess = $false,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $AccessToken,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('Server')]
        [string] $HostName,

        [Parameter()]
        [switch] $UseSSL,

        [Parameter()]
        [uri] $Proxy = $null,

        [Parameter()]
        [pscredential] $ProxyCredential = $null,

        [Parameter()]
        [switch] $ProxyUseDefaultCredentials = $false
    )

    $Local:PostUrl = "$(if($UseSSL){'https'}else{'http'})://$HostName/v2/room"
    $Local:Headers = @{ Authorization = "Bearer $AccessToken" }

    $Local:Body = @{
        name         = $Name
        privacy      = $Privacy.ToLowerInvariant()
        topic        = $Topic
        guest_access = $AllowGuestAccess.ToBool()
    }

    $Local:BodyJson = ConvertTo-Json -InputObject $Local:Body -Compress

    $Local:Room = Invoke-RestMethod -Uri $Local:PostUrl -Method Post -UseBasicParsing -Headers $Local:Headers -Body $Local:BodyJson -ContentType 'application/json' -Proxy $Proxy -ProxyCredential $ProxyCredential -ProxyUseDefaultCredentials:$ProxyUseDefaultCredentials

    [pscustomobject] @{
        Id         = $Local:Room.id
        Name       = $Local:Room.entity.name
        Privacy    = $Local:Room.entity.privacy
        IsArchived = $Local:Room.entity.is_archived
        Version    = $Local:Room.entity.version
    }
}


function Send-RoomMessage
{
    [CmdletBinding()]
    [OutputType('HipChat.RoomMessageData')]
    param (
        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [ValidateLength(1, 100)]
        [Alias('RoomID', 'RoomName')]
        [string] $RoomIdentity,

        [Parameter(Mandatory = $true, Position = 2)]
        [ValidateNotNullOrEmpty()]
        [ValidateLength(1, 1000)]
        [string] $Message,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $AccessToken,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('Server')]
        [string] $HostName,

        [Parameter()]
        [switch] $UseSSL,

        [Parameter()]
        [uri] $Proxy = $null,

        [Parameter()]
        [pscredential] $ProxyCredential = $null,

        [Parameter()]
        [switch] $ProxyUseDefaultCredentials = $false
    )

    $Local:PostUrl  = "$(if($UseSSL){'https'}else{'http'})://$HostName/v2/room/$RoomIdentity/message"
    $Local:Headers  = @{ Authorization = "Bearer $AccessToken" }
    $Local:Body     = @{ message = $Message }
    $Local:BodyJson = ConvertTo-Json -InputObject $Local:Body -Compress
    $Local:MsgObj   = Invoke-RestMethod -Uri $Local:PostUrl -Method Post -UseBasicParsing -Headers $Local:Headers -Body $Local:BodyJson -ContentType 'application/json' -Proxy $Proxy -ProxyCredential $ProxyCredential -ProxyUseDefaultCredentials:$ProxyUseDefaultCredentials

    [pscustomobject] @{
        Id        = $Local:MsgObj.id
        Timestamp = $Local:MsgObj.timestamp
    }
}


function Send-RoomNotification
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [ValidateLength(1, 100)]
        [Alias('RoomID', 'RoomName')]
        [string] $RoomIdentity,

        [Parameter(Mandatory = $true, Position = 2)]
        [ValidateNotNullOrEmpty()]
        [ValidateLength(1, 10000)]
        [string] $Message,

        [Parameter()]
        [ValidateLength(0, 64)]
        [Alias('Label')]
        [string] $From = $null,

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Text', 'Html')]
        [string] $Format = 'Text',

        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Yellow', 'Green', 'Red', 'Purple', 'Gray', 'Random')]
        [string] $Color = 'Yellow',

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $AccessToken,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias('Server')]
        [string] $HostName,

        [Parameter()]
        [switch] $UseSSL,

        [Parameter()]
        [uri] $Proxy = $null,

        [Parameter()]
        [pscredential] $ProxyCredential = $null,

        [Parameter()]
        [switch] $ProxyUseDefaultCredentials = $false
    )

    $Local:PostUrl = "$(if($UseSSL){'https'}else{'http'})://$HostName/v2/room/$RoomIdentity/notification"
    $Local:Headers = @{ Authorization = "Bearer $AccessToken" }

    $Local:Body = @{
        message_format = $Format.ToLowerInvariant()
        message        = $Message
        from           = $From
        color          = $Color.ToLowerInvariant()
        notify         = 'true'
    }

    $Local:BodyJson = ConvertTo-Json -InputObject $Local:Body -Compress

    Invoke-RestMethod -Uri $Local:PostUrl -Method Post -UseBasicParsing -Headers $Local:Headers -Body $Local:BodyJson -ContentType 'application/json' -Proxy $Proxy -ProxyCredential $ProxyCredential -ProxyUseDefaultCredentials:$ProxyUseDefaultCredentials
}

