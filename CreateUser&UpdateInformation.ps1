#-------------------------------------------------------------------------------------------------------------------------------
# SCRIPT NAME:               CreateUser&UpdateInformation.ps1
#-------------------------------------------------------------------------------------------------------------------------------
# SCRIPT AUTHOR:             Sachin Tewari 
# SCRIPT CREATE DATE  :      08/29/2018
#===============================================================================================================================
#                                  CHANGE LOG - ADD NEW ENTRIES TO TOP
#=================================================================================================================================
# DATE        || VERSION  || AUTHOR  || TICKET || 				DESCRIPTION
#================================================================================================================================*/
# 
#--------------------------------------------------------------------------------------------------------------------------------
# 08/29/2018   || v. 1.0   || Sachin  || TBD || First Version
#--------------------------------------------------------------------------------------------------------------------------------

#--------------------------------------------------------------------------------------------------------------------------------
# SCRIPT DESCRIPTION:
# 
# v 1.0: Connect to Active Directory Azure and create Random Unique users & set properties
# 
#-------------------------------------------------------------------------------------------------------------------------------*/
#                                INSTRUCTIONS

#SETUP YOUR MSOL-PASSWORD TO BE USED IN THE SCRIPT USING THE BELOW CMDLET
#"<Your Password>" | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString | Out-File "C:\users\124708\Desktop\pass.txt"

#USE THE BELOW CMDLET TO RETRIEVE YOUR PASSWORD
#$password= Get-Content "C:\users\124708\Desktop\pass.txt" | ConvertTo-SecureString
#-------------------------------------------------------------------------------------------------------------------------------*/


$File="C:\users\124708\Desktop\pass.txt"

$username = 'sachin@sherlockbotoutlook.onmicrosoft.com'

$MyCredential=New-Object -TypeName System.Management.Automation.PSCredential `
 -ArgumentList $username, (Get-Content $File | ConvertTo-SecureString)

Connect-MsolService -Credential $MyCredential

$RandomNameArray='Alpha','Bravo','Charlie','Mike','George','Oscar','Sierra','Romeo','Victor','Juliett','Bravo'  #RANDOM NAMES
$city='Bangalore','Kolkata','Noida','Mumbai','New York','Toronto','Dubai','Hyderabad'                           #RANDOM LOCATION
$zipcode='560033','700001','121031','400001','123456','111001','234123','234124'                                #RANDOM NAMES
$phone='9743841100','9743841101','9743841102','9743841103','9743841121','9743841122','9743841123'               #RANDOM PHONE NUMBERS


$iteration= 2;                                                                                                  #NUMBER OF USERS TO BE GENERATED

for($i=0;$i -lt $iteration;$i++)
{
    
    $RandomName=$RandomNameArray[(Get-Random -Maximum ($RandomNameArray.length))]
    $RandomSurname=$RandomNameArray[(Get-Random -Maximum ($RandomNameArray.length))]
    #$RandomSurname= -join ([char[]](65..90+97..122) | Get-Random -Count 5)
    $NamesID = @{"$($RandomName) $($RandomSurname)" = (get-random -Minimum 100000 -Maximum 999999)}  #Hash (RandomName RandomSurname, RandomEmpID[6 Digit]) 
                                                                                                     #CREATING USERS USING HASH TABLE/QUICKER
    
    foreach ($NID in $NamesID.getEnumerator())
    {
        Try
        {
            $CheckIfUserExists= Get-MsolUser -UserPrincipalName "$($NID.Value)@sherlockbotoutlook.onmicrosoft.com" -ErrorAction Stop
            Write-Host "User $($NID.Value)@sherlockbotoutlook.onmicrosoft.com Exists"
        }
        Catch
        {
            $user="$($NID.Value)@sherlockbotoutlook.onmicrosoft.com"
            New-MsolUser -DisplayName $NID.Name -UserPrincipalName "$($NID.Value)@sherlockbotoutlook.onmicrosoft.com"
            $commonLocation=$city[(Get-Random -Maximum ($city.length))]
            $User_City=Set-MsolUser -UserPrincipalName $user -City $commonLocation
            $User_Office=Set-MsolUser -UserPrincipalName $user -Office $commonLocation
            $User_Code=Set-MsolUser -UserPrincipalName $user -PostalCode $zipcode[(Get-Random -Maximum ($zipcode.length))]
            $User_Phone=Set-MsolUser -UserPrincipalName $user -PhoneNumber $phone[(Get-Random -Maximum ($phone.length))]
            $User_City= Get-MsolUser -UserPrincipalName $user | select city
            $User_Office= Get-MsolUser -UserPrincipalName $user | select Office
            $User_Code= Get-MsolUser -UserPrincipalName $user | select postalcode
            $User_Phone= Get-MsolUser -UserPrincipalName $user | select PhoneNumber
            Write-Host "Created User $($NID.Value)@sherlockbotoutlook.onmicrosoft.com"
            Write-Host "These details were updated for the user:$User_City,$User_Office,$User_Code,$User_Phone"
            
        }
        
    
    }
}
