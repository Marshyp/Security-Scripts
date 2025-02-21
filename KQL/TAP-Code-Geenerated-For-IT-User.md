let ITDepartment = "IT Department";  // Define the department to filter by
let ITMembers = 
    IdentityInfo
    | where isnotempty(Department)  // Ensure the department field is not empty
    | where Department == ITDepartment  // Check if the user's department is "IT Department"
    | where TimeGenerated >= ago(7d)  // Filter for records from the past 7 days
    | project AccountUPN  // Extract relevant user principal names
;
let TAPEvents = 
    AuditLogs
    | where (LoggedByService == "Authentication Methods" and ResultDescription == "Admin registered temporary access pass method for user")
    | extend 
        Timestamp = TimeGenerated,
        GeneratedFor = tostring(TargetResources[0].userPrincipalName),  // User for whom the TAP was generated
        GeneratedBy = tostring(InitiatedBy.user.userPrincipalName),    // User who created the TAP
        AdditionalDetails = tostring(parse_json(tostring(TargetResources[0].modifiedProperties)))
    | where TimeGenerated >= ago(1d)  // Filter for TAP events from the past day
    | project Timestamp, GeneratedFor, GeneratedBy, AdditionalDetails;
TAPEvents
| join kind=inner (ITMembers) on $left.GeneratedFor == $right.AccountUPN  // Join TAP events with IT members
| project Timestamp, GeneratedFor, GeneratedBy
| order by Timestamp desc
