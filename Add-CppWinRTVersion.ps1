# Add-CppWinRTVersion.ps1
$cppWinRTVersion = "2.0.230511.6"

# Get all .vcxproj files recursively from the current directory
$vcxprojFiles = Get-ChildItem -Path . -Filter *.vcxproj -Recurse

foreach ($file in $vcxprojFiles) {
    $xml = New-Object System.Xml.XmlDocument
    $xml.PreserveWhitespace = $true
    $xml.Load($file.FullName)
    
    # Create namespace manager
    $ns = New-Object System.Xml.XmlNamespaceManager($xml.NameTable)
    $ns.AddNamespace("ns", $xml.DocumentElement.NamespaceURI)
    
    # Find the first PropertyGroup under Project
    $propertyGroup = $xml.SelectSingleNode("/ns:Project/ns:PropertyGroup[1]", $ns)
    
    if ($propertyGroup -ne $null) {
        # Check if CppWinRTVersion already exists
        $existingNode = $propertyGroup.SelectSingleNode("ns:CppWinRTVersion", $ns)
        
        if ($existingNode -eq $null) {
            # Create new element
            $newElement = $xml.CreateElement("CppWinRTVersion", $xml.DocumentElement.NamespaceURI)
            $newElement.InnerText = $cppWinRTVersion
            
            # Append to PropertyGroup
            $propertyGroup.AppendChild($newElement) | Out-Null
            
            # Save changes
            $xml.Save($file.FullName)
            Write-Host "Added CppWinRTVersion to $($file.FullName)"
        }
        else {
            Write-Host "CppWinRTVersion already exists in $($file.FullName)"
        }
    }
    else {
        Write-Host "No PropertyGroup found in $($file.FullName)"
    }
}

Write-Host "Processing complete."