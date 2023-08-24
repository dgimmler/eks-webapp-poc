{
  "Id": "KmsKeyPolicy",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "KeyAdminAccess",
      "Effect": "Allow",
      "Principal": {
        "AWS": ${key_admins},
        "Service": ${key_services}
      },
      "Action": [
        "kms:Create*",
        "kms:Describe*",
        "kms:Enable*",
        "kms:List*",
        "kms:Put*",
        "kms:Update*",
        "kms:Revoke*",
        "kms:Disable*",
        "kms:Get*",
        "kms:Delete*",
        "kms:TagResource",
        "kms:UntagResource",
        "kms:ScheduleKeyDeletion",
        "kms:ScheduleKeyDeletion",
        "kms:CancelKeyDeletion",
        "kms:Decrypt",
        "kms:Encrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*"
      ],
      "Resource": "*"
    }
  ]
}
